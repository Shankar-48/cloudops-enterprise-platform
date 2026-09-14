import json
import os

import joblib
from flask import Flask, request, jsonify

app = Flask(__name__)

MODEL_PATH = "/opt/ml/model/model.joblib"
model = joblib.load(MODEL_PATH)


@app.get("/ping")
def ping():
    return "", 200


@app.post("/invocations")
def invocations():
    payload = request.get_json(force=True)

    feature_1 = float(payload["feature_1"])
    feature_2 = float(payload["feature_2"])

    prediction = int(
        model.predict([[feature_1, feature_2]])[0]
    )

    probability = float(
        model.predict_proba([[feature_1, feature_2]])[0][1]
    )

    return jsonify({
        "prediction": prediction,
        "probability": round(probability, 4),
        "status": "success"
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
