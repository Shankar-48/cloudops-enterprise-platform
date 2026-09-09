import json
import math
from pathlib import Path


MODEL_FILE = Path(__file__).parent.parent / "model.json"


def load_model():
    with open(MODEL_FILE, encoding="utf-8") as file:
        return json.load(file)


def predict(event):
    model = load_model()

    feature_1 = float(event.get("feature_1", 0))
    feature_2 = float(event.get("feature_2", 0))

    score = (
        model["coefficients"][0] * feature_1
        + model["coefficients"][1] * feature_2
        + model["intercept"]
    )

    probability = 1 / (1 + math.exp(-score))
    prediction = 1 if probability >= 0.5 else 0

    return {
        "model": model["model"],
        "prediction": prediction,
        "probability": round(probability, 4),
        "status": "success"
    }


if __name__ == "__main__":
    print(
        json.dumps(
            predict({
                "feature_1": 30,
                "feature_2": 40
            }),
            indent=2
        )
    )