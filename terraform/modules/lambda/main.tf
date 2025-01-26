resource "aws_lambda_function" "lambda_function" {
  filename         = var.file_name
  function_name    = var.function_name
  role             = var.role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = var.environment_vars
  }
}
