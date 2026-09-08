import csv
import json
from pathlib import Path

from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split


DATA_FILE = Path(__file__).parent.parent / "data" / "sample_data.csv"
MODEL_OUTPUT = Path(__file__).parent / "model_metrics.json"


def load_data():
    X = []
    y = []

    with open(DATA_FILE, newline="", encoding="utf-8") as file:
        reader = csv.DictReader(file)

        for row in reader:
            X.append([
                float(row["feature_1"]),
                float(row["feature_2"])
            ])
            y.append(int(row["target"]))

    return X, y


def main():
    X, y = load_data()

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.3,
        random_state=42,
        stratify=y
    )

    model = LogisticRegression()
    model.fit(X_train, y_train)

    predictions = model.predict(X_test)
    accuracy = accuracy_score(y_test, predictions)

    result = {
        "model": "LogisticRegression",
        "dataset": "sample_data.csv",
        "features": ["feature_1", "feature_2"],
        "accuracy": round(float(accuracy), 4),
        "status": "success"
    }

    with open(MODEL_OUTPUT, "w", encoding="utf-8") as file:
        json.dump(result, file, indent=2)

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()