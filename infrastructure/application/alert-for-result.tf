resource "aws_cloudwatch_metric_alarm" "function_found_units" {
  alarm_name                = "${var.application_name}-matching-units"
  statistic                 = "Sum"
  metric_name               = "MATCHING_UNITS"
  comparison_operator       = "GreaterThanThreshold"
  threshold                 = "0"
  period                    = "300" # five minutes
  evaluation_periods        = "1"
  datapoints_to_alarm       = "1"
  namespace                 = "APARTMENT_FINDER"
  treat_missing_data        = "notBreaching"
  alarm_description         = "${var.application_name} matching units found!"
  alarm_actions             = ["${aws_sns_topic.matching_units_topic.arn}"]
  ok_actions                = ["${aws_sns_topic.matching_units_topic.arn}"]
  insufficient_data_actions = ["${aws_sns_topic.matching_units_topic.arn}"]

  dimensions = {
    UNITS = "UnitCount"
  }
}

#########################################################
# SNS Topic and Pagerduty Integration for Matching Data #
#########################################################

locals {
  matching_units_pagerduty_integration_key = lookup(var.pagerduty_integration_keys, "${var.environment}-matching", "")
}

resource "aws_sns_topic" "matching_units_topic" {
  name = "${var.application_name}-cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "matching_units_pagerduty" {
  count                  = local.matching_units_pagerduty_integration_key == "" ? 0 : 1
  topic_arn              = aws_sns_topic.matching_units_topic.arn
  protocol               = "https"
  endpoint               = "https://events.pagerduty.com/integration/${local.matching_units_pagerduty_integration_key}/enqueue"
  endpoint_auto_confirms = true
}