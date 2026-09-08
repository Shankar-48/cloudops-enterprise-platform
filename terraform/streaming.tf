# -------------------------
# SQS Queue
# -------------------------

resource "aws_sqs_queue" "cloudops_events" {
  name                       = "cloudops-enterprise-events"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400

  tags = {
    Name    = "cloudops-enterprise-events"
    Project = "CloudOps Enterprise Platform"
  }
}

# -------------------------
# Lambda SQS Permissions
# -------------------------

resource "aws_iam_role_policy" "cloudops_lambda_sqs" {
  name = "cloudops-lambda-sqs"
  role = aws_iam_role.cloudops_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.cloudops_events.arn
      }
    ]
  })
}

# -------------------------
# SQS -> Lambda Trigger
# -------------------------

resource "aws_lambda_event_source_mapping" "cloudops_sqs_trigger" {
  event_source_arn = aws_sqs_queue.cloudops_events.arn
  function_name    = aws_lambda_function.cloudops_lambda.arn
  batch_size       = 10
  enabled          = true
}

# -------------------------
# Output
# -------------------------

output "sqs_queue_url" {
  value = aws_sqs_queue.cloudops_events.url
}