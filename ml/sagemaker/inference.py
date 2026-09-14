import json
import math


COEF_1 = 0.55409203
COEF_2 = 0.55408259
INTERCEPT = -26.62434195


def model_fn(model_dir):
    return True


def input_fn(request_body, request_content_type):
    if request_content_type != "application/json":
        raise ValueError("Expected application/json")
    return json.loads(request_body)


def predict_fn(input_data, model):
    feature_1 = float(input_data["feature_1"])
    feature_2 = float(input_data["feature_2"])

    score = (
        COEF_1 * feature_1
        + COEF_2 * feature_2
        + INTERCEPT
    )

    probability = 1 / (1 + math.exp(-score))
    prediction = 1 if probability >= 0.5 else 0

    return {
        "prediction": prediction,
        "probability": round(probability, 4),
        "score": round(score, 4)
    }


def output_fn(prediction, accept):
    if accept != "application/json":
        accept = "application/json"

    return json.dumps(prediction), accept