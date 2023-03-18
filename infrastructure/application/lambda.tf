resource "aws_lambda_function" "lambda" {
  function_name = var.application_name
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = "empty-lambda/empty-lambda.zip"
  # Almost no memory is consumed by this application, this is a pretty small number that is still fairly reasonable
  memory_size = 256
  timeout     = 30

  environment {
    variables = {
      ENVIRONMENT  = var.environment
      COMPLEX_URL  = "CHANGE ME"
      COMPLEX_NAME = "CHANGE ME"
    }
  }

  lifecycle {
    ignore_changes = [filename, s3_key, s3_bucket]
  }

  depends_on = [
    # This dependency is required at creation time, but Terraform doesn't know that.
    aws_iam_role_policy.lambda_permissions
  ]
}
