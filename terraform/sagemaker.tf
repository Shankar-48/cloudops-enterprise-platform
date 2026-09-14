# -------------------------
# SageMaker Execution Role
# -------------------------

resource "aws_iam_role" "cloudops_sagemaker_role" {
  name = "cloudops-sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "sagemaker.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "CloudOps Enterprise Platform"
  }
}

# -------------------------
# SageMaker S3 Access
# -------------------------

resource "aws_iam_role_policy" "cloudops_sagemaker_s3" {
  name = "cloudops-sagemaker-s3"
  role = aws_iam_role.cloudops_sagemaker_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]

        Resource = [
          aws_s3_bucket.cloudops_data_lake.arn,
          "${aws_s3_bucket.cloudops_data_lake.arn}/*"
        ]
      }
    ]
  })
}

output "sagemaker_role_arn" {
  value = aws_iam_role.cloudops_sagemaker_role.arn
}
# -------------------------
# SageMaker Model
# -------------------------

resource "aws_sagemaker_model" "cloudops_ml_model" {
  name               = "cloudops-ml-model"
  execution_role_arn = aws_iam_role.cloudops_sagemaker_role.arn

  primary_container {
    image = "285977275310.dkr.ecr.eu-north-1.amazonaws.com/cloudops-enterprise-app:sagemaker-final"
  }

  tags = {
    Name    = "cloudops-ml-model"
    Project = "CloudOps Enterprise Platform"
  }
}
# -------------------------
# SageMaker ECR Pull Access
# -------------------------

resource "aws_iam_role_policy" "cloudops_sagemaker_ecr" {
  name = "cloudops-sagemaker-ecr"
  role = aws_iam_role.cloudops_sagemaker_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]

        Resource = "*"
      }
    ]
  })
}

