from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/health")
def health():
    return jsonify({
        "service": "order-service",
        "status": "healthy"
    })


@app.get("/orders")
def orders():
    return jsonify({
        "service": "order-service",
        "orders": [
            {"id": 101, "user_id": 1, "product": "Cloud Platform"},
            {"id": 102, "user_id": 2, "product": "DevOps Service"}
        ]
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)