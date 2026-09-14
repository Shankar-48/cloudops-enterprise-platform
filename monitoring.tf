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