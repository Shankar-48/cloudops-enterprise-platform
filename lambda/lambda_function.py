import json


def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "CloudOps Enterprise Platform Lambda is working!",
            "status": "success"
        })
    }
