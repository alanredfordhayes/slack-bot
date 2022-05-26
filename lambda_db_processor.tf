locals {
  #aws_lambda_function
  aws_lambda_name = "db_processor"
  aws_lambda_function_runtime = "python3.9"
  aws_lambda_function_handler = "db_processor.lambda_handler"

  #aws_lambda_permission
  aws_lambda_permission_statement_id = "AllowExecutionFromAPIGateway"
  aws_lambda_permission_action = "lambda:InvokeFunction"
  aws_lambda_permission_principal = "apigateway.amazonaws.com"

  #aws_cloudwatch_log_group
  aws_cloudwatch_log_group_name = "/aws/lambda/${aws_lambda_function.db_processor.function_name}"
}

resource "aws_lambda_function" "db_processor" {
  function_name = local.aws_lambda_name
  description = local.aws_lambda_name
  s3_bucket = aws_s3_bucket.db_processor.id
  s3_key    = aws_s3_object.db_processor.key
  runtime = local.aws_lambda_function_runtime
  handler = local.aws_lambda_function_handler
  source_code_hash = data.archive_file.db_processor.output_base64sha256
  role = aws_iam_role.db_processor.arn

  environment {
    variables = {
        slack_bot_table_name = local.slack_bot_table_name
    }
  }
}

resource "aws_lambda_permission" "db_processor" {
  statement_id  = local.aws_lambda_permission_statement_id
  action        = local.aws_lambda_permission_action
  function_name = aws_lambda_function.db_processor.function_name
  principal     = local.aws_lambda_permission_principal
}

resource "aws_cloudwatch_log_group" "db_processor" {
  name = local.aws_cloudwatch_log_group_name
  retention_in_days = 30
}