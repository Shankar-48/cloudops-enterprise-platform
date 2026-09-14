import csv
import joblib
from pathlib import Path

from sklearn.linear_model import LogisticRegression


BASE_DIR = Path(__file__).parent
DATA_FILE = BASE_DIR.parent.parent / "data" / "sample_data.csv"
MODEL_FILE = BASE_DIR / "model.joblib"


def main():
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

    model = LogisticRegression()
    model.fit(X, y)

    joblib.dump(model, MODEL_FILE)

    print(f"Model saved to: {MODEL_FILE}")


if __name__ == "__main__":
    main()