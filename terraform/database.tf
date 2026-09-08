# -------------------------
# DynamoDB Table
# -------------------------

resource "aws_dynamodb_table" "cloudops_data" {
  name         = "cloudops-enterprise-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name    = "cloudops-enterprise-data"
    Project = "CloudOps Enterprise Platform"
  }
}

# -------------------------
# Lambda DynamoDB Access
# -------------------------

resource "aws_iam_role_policy" "cloudops_lambda_dynamodb" {
  name = "cloudops-lambda-dynamodb"
  role = aws_iam_role.cloudops_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]

        Resource = aws_dynamodb_table.cloudops_data.arn
      }
    ]
  })
}

# -------------------------
# DynamoDB Output
# -------------------------

output "dynamodb_table_name" {
  value = aws_dynamodb_table.cloudops_data.name
}