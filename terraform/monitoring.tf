# -------------------------
# CloudWatch Log Group - Lambda
# -------------------------

resource "aws_cloudwatch_log_group" "cloudops_lambda_logs" {
  name              = "/aws/lambda/cloudops-enterprise-lambda"
  retention_in_days = 7

  tags = {
    Project = "CloudOps Enterprise Platform"
  }
}

# -------------------------
# EC2 CPU Alarm
# -------------------------

resource "aws_cloudwatch_metric_alarm" "cloudops_ec2_cpu" {
  alarm_name          = "cloudops-ec2-high-cpu"
  alarm_description   = "Alarm when EC2 CPU utilization is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    InstanceId = aws_instance.cloudops_server.id
  }

  treat_missing_data = "notBreaching"
}

# -------------------------
# Lambda Errors Alarm
# -------------------------

resource "aws_cloudwatch_metric_alarm" "cloudops_lambda_errors" {
  alarm_name          = "cloudops-lambda-errors"
  alarm_description   = "Alarm when Lambda reports execution errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = aws_lambda_function.cloudops_lambda.function_name
  }

  treat_missing_data = "notBreaching"
}

# -------------------------
# Lambda Duration Alarm
# -------------------------

resource "aws_cloudwatch_metric_alarm" "cloudops_lambda_duration" {
  alarm_name          = "cloudops-lambda-high-duration"
  alarm_description   = "Alarm when Lambda execution duration is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = 5000

  dimensions = {
    FunctionName = aws_lambda_function.cloudops_lambda.function_name
  }

  treat_missing_data = "notBreaching"
}
# -------------------------
# CloudWatch Dashboard
# -------------------------

resource "aws_cloudwatch_dashboard" "cloudops_dashboard" {
  dashboard_name = "cloudops-enterprise-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title = "EC2 CPU Utilization"
          view  = "timeSeries"

          region = var.aws_region

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              aws_instance.cloudops_server.id
            ]
          ]

          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title = "Lambda Errors"

          view   = "timeSeries"
          region = var.aws_region

          metrics = [
            [
              "AWS/Lambda",
              "Errors",
              "FunctionName",
              aws_lambda_function.cloudops_lambda.function_name
            ]
          ]

          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title = "Lambda Duration"

          view   = "timeSeries"
          region = var.aws_region

          metrics = [
            [
              "AWS/Lambda",
              "Duration",
              "FunctionName",
              aws_lambda_function.cloudops_lambda.function_name
            ]
          ]

          period = 300
          stat   = "Average"
        }
      }
    ]
  })
}
# -------------------------
# EC2 Uptime / Status Alarm
# -------------------------

resource "aws_cloudwatch_metric_alarm" "cloudops_ec2_status" {
  alarm_name          = "cloudops-ec2-status-check"
  alarm_description   = "Alarm when EC2 instance status checks fail"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0

  dimensions = {
    InstanceId = aws_instance.cloudops_server.id
  }

  treat_missing_data = "breaching"
}