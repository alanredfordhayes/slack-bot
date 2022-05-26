locals {
  #aws_lambda_function
  aws_lambda_name = "event-api"
  aws_lambda_function_runtime = "python3.9"
  aws_lambda_function_handler = "event-api.lambda_handler"

  #aws_lambda_permission
  aws_lambda_permission_statement_id = "AllowExecutionFromAPIGateway"
  aws_lambda_permission_action = "lambda:InvokeFunction"
  aws_lambda_permission_principal = "apigateway.amazonaws.com"

  #aws_cloudwatch_log_group
  aws_cloudwatch_log_group_name = "/aws/lambda/${aws_lambda_function.event-api.function_name}"
}

resource "aws_lambda_function" "event-api" {
  function_name = local.aws_lambda_name
  description = local.aws_lambda_name
  s3_bucket = aws_s3_bucket.event-api.id
  s3_key    = aws_s3_object.event-api.key
  runtime = local.aws_lambda_function_runtime
  handler = local.aws_lambda_function_handler
  source_code_hash = data.archive_file.event-api.output_base64sha256
  role = aws_iam_role.event-api.arn
}

resource "aws_lambda_permission" "event-api" {
  statement_id  = local.aws_lambda_permission_statement_id
  action        = local.aws_lambda_permission_action
  function_name = aws_lambda_function.event-api.function_name
  principal     = local.aws_lambda_permission_principal
}

resource "aws_cloudwatch_log_group" "event-api" {
  name = local.aws_cloudwatch_log_group_name
  retention_in_days = 30
}