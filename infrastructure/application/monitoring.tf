# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html#alarm-evaluation

# Verify the lambda is consistently erroring in the last 30 minutes
resource "aws_cloudwatch_metric_alarm" "function_failure" {
  alarm_name                = "${var.application_name}-execution-failures"
  statistic                 = "Sum"
  metric_name               = "Errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "1"
  period                    = "600" # ten minutes
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3" # after three consectutive failures within three periods, alarm
  namespace                 = "AWS/Lambda"
  treat_missing_data        = "notBreaching"
  alarm_description         = "${var.application_name} run failed."
  alarm_actions             = ["${aws_sns_topic.monitoring_topic.arn}"]
  ok_actions                = ["${aws_sns_topic.monitoring_topic.arn}"]
  insufficient_data_actions = ["${aws_sns_topic.monitoring_topic.arn}"]

  dimensions = {
    FunctionName = aws_lambda_function.lambda.function_name
  }
}

# Verify the lambda is being invoked at least once in the last 30 minutes
resource "aws_cloudwatch_metric_alarm" "function_failed_to_invoke" {
  alarm_name                = "${var.application_name}-invocations-failures"
  statistic                 = "Sum"
  metric_name               = "Invocations"
  comparison_operator       = "LessThanThreshold"
  threshold                 = "1"
  period                    = "600" # ten minutes
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3" # after three consectutive failures within three periods, alarm
  namespace                 = "AWS/Lambda"
  treat_missing_data        = "breaching"
  alarm_description         = "${var.application_name} failed to be invoked."
  alarm_actions             = ["${aws_sns_topic.monitoring_topic.arn}"]
  ok_actions                = ["${aws_sns_topic.monitoring_topic.arn}"]
  insufficient_data_actions = ["${aws_sns_topic.monitoring_topic.arn}"]

  dimensions = {
    FunctionName = aws_lambda_function.lambda.function_name
  }
}

######################################################
# SNS Topic and Pagerduty Integration for Monitoring #
######################################################

locals {
  monitoring_pagerduty_integration_key = lookup(var.pagerduty_integration_keys, "${var.environment}-monitoring", "")
}

resource "aws_sns_topic" "monitoring_topic" {
  name = "${var.application_name}-cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "monitoring_pagerduty" {
  count                  = local.monitoring_pagerduty_integration_key == "" ? 0 : 1
  topic_arn              = aws_sns_topic.monitoring_topic.arn
  protocol               = "https"
  endpoint               = "https://events.pagerduty.com/integration/${local.monitoring_pagerduty_integration_key}/enqueue"
  endpoint_auto_confirms = true
}
