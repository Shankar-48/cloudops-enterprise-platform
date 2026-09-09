from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/health")
def health():
    return jsonify({
        "service": "user-service",
        "status": "healthy"
    })


@app.get("/users")
def users():
    return jsonify({
        "service": "user-service",
        "users": [
            {"id": 1, "name": "Admin"},
            {"id": 2, "name": "CloudOps User"}
        ]
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)