import json
import math
import boto3
from decimal import Decimal
from datetime import datetime, timezone

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("cloudops-enterprise-data")

COEF_1 = Decimal("0.55409203")
COEF_2 = Decimal("0.55408259")
INTERCEPT = Decimal("-26.62434195")


def predict(feature_1, feature_2):
    score = (
        float(COEF_1) * float(feature_1)
        + float(COEF_2) * float(feature_2)
        + float(INTERCEPT)
    )

    probability = 1 / (1 + math.exp(-score))
    prediction = 1 if probability >= 0.5 else 0

    return {
        "prediction": prediction,
        "probability": Decimal(str(round(probability, 4))),
        "score": Decimal(str(round(score, 4)))
    }


def store_item(item_id, message, inference=None):
    item = {
        "id": str(item_id),
        "message": str(message),
        "status": "stored",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

    if inference is not None:
        item["prediction"] = Decimal(str(inference["prediction"]))
        item["probability"] = inference["probability"]
        item["score"] = inference["score"]

    table.put_item(Item=item)
    return item


def process_record(data):
    item_id = data.get(
        "id",
        datetime.now(timezone.utc).strftime("%Y%m%d%H%M%S%f")
    )

    message = data.get("message", "CloudOps request")

    inference = None

    if "feature_1" in data and "feature_2" in data:
        inference = predict(
            data["feature_1"],
            data["feature_2"]
        )

    return store_item(item_id, message, inference)


def lambda_handler(event, context):
    if "Records" in event:
        results = []

        for record in event["Records"]:
            body = record.get("body", "{}")

            try:
                data = json.loads(body)
            except json.JSONDecodeError:
                data = {"message": body}

            results.append(process_record(data))

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "SQS events processed successfully",
                "items": results
            }, default=str)
        }

    body = event.get("body")

    if isinstance(body, str):
        try:
            body = json.loads(body)
        except json.JSONDecodeError:
            body = {"message": body}

    if not isinstance(body, dict):
        body = event

    item = process_record(body)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "CloudOps ML inference completed",
            "item": item
        }, default=str)
    }