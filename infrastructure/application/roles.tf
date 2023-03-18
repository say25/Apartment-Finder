resource "aws_iam_role" "lambda_role" {
  name = var.application_name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# resource "aws_iam_role" "cloudwatch_event_role" {
#     name = "${var.application_name}-cloudwatch-event-role"
# }

###########################
# Core Lambda Permissions #
###########################

resource "aws_iam_role_policy" "lambda_permissions" {
  role   = aws_iam_role.lambda_role.name
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect = "Allow"

    resources = ["*"]
  }

  # Allow Lambda to Publish Custom Metrics to CloudWatch
  statement {
    actions = [
      "cloudwatch:PutMetricData"
    ]

    effect = "Allow"

    resources = ["*"]
  }
}