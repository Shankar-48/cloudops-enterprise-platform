# -------------------------
# ML / Data Lake S3 Bucket
# -------------------------

resource "aws_s3_bucket" "cloudops_data_lake" {
  bucket = "cloudops-enterprise-data-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name    = "cloudops-enterprise-data-lake"
    Project = "CloudOps Enterprise Platform"
  }
}

resource "aws_s3_bucket_versioning" "cloudops_data_lake_versioning" {
  bucket = aws_s3_bucket.cloudops_data_lake.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudops_data_lake_encryption" {
  bucket = aws_s3_bucket.cloudops_data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_caller_identity" "current" {}

output "ml_data_lake_bucket" {
  value = aws_s3_bucket.cloudops_data_lake.bucket
}