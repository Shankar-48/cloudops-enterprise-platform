import json
import boto3
import os
from datetime import datetime, timezone

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("cloudops-enterprise-data")


def store_item(item_id, message):
    item = {
        "id": item_id,
        "message": message,
        "status": "stored",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

    table.put_item(Item=item)
    return item


def lambda_handler(event, context):
    # SQS event
    if "Records" in event:
        results = []

        for record in event["Records"]:
            body = record.get("body", "{}")

            try:
                data = json.loads(body)
            except json.JSONDecodeError:
                data = {"message": body}

            item_id = data.get(
                "id",
                datetime.now(timezone.utc).strftime("%Y%m%d%H%M%S%f")
            )

            message = data.get("message", "CloudOps SQS event")

            results.append(store_item(item_id, message))

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "SQS events processed successfully",
                "items": results
            })
        }

    # Direct/API Gateway invocation
    body = event.get("body")

    if isinstance(body, str):
        try:
            body = json.loads(body)
        except json.JSONDecodeError:
            body = {"message": body}

    if not isinstance(body, dict):
        body = event

    item_id = body.get(
        "id",
        datetime.now(timezone.utc).strftime("%Y%m%d%H%M%S%f")
    )

    message = body.get("message", "CloudOps Lambda request")

    item = store_item(item_id, message)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "Data stored successfully in DynamoDB",
            "item": item
        })
    }