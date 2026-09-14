FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    flask \
    joblib \
    scikit-learn==1.5.2

COPY app.py /app/app.py
COPY ../model.joblib /opt/ml/model/model.joblib

EXPOSE 8080

CMD ["python", "/app/app.py"]