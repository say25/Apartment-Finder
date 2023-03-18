resource "aws_cloudwatch_event_rule" "evening" {
  name                = "${var.application_name}-evening"
  description         = "Checks for apartments every 15 minutes during the overnight."
  schedule_expression = "cron(0/15 02-14 * * ? *)"
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html#CronExpressions
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.evening.id
  arn  = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_evening_trigger" {
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.evening.arn
  function_name = aws_lambda_function.lambda.arn
}

resource "aws_cloudwatch_event_rule" "daytime" {
  name                = "${var.application_name}-daytime"
  description         = "Checks for apartments every 5 minutes during the day."
  schedule_expression = "cron(0/5 14-02 * * ? *)"
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html#CronExpressions
}

resource "aws_cloudwatch_event_target" "daytime" {
  rule = aws_cloudwatch_event_rule.daytime.id
  arn  = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_daytime_trigger" {
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daytime.arn
  function_name = aws_lambda_function.lambda.arn
}
