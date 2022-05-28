# LAMBDA
## EVENT API

resource "aws_lambda_layer_version" "slack_bolt" {
  filename   = local.aws_lambda_layer_version_slack_bolt_filename
  layer_name = local.aws_lambda_layer_version_slack_bolt_layer_name
  compatible_runtimes = local.aws_lambda_layer_version_slack_bolt_compatible_runtimes
}

resource "aws_lambda_function" "event_api" {
  function_name = local.aws_lambda_function_event_api_function_name
  description = local.aws_lambda_function_event_api_description
  s3_bucket = aws_s3_bucket.event_api.id
  s3_key    = aws_s3_object.event_api.key
  runtime = local.aws_lambda_function_runtime
  handler = local.aws_lambda_function_event_api_handler
  source_code_hash = data.archive_file.event_api.output_base64sha256
  layers = [aws_lambda_layer_version.slack_bolt.arn]
  role = aws_iam_role.event_api.arn
  environment {
    variables ={
      event_api_table = local.aws_lambda_function_event_api_env_event_api_table
      SLACK_BOT_TOKEN = var.SLACK_BOT_TOKEN
      SLACK_SIGNING_SECRET = var.SLACK_SIGNING_SECRET
    }
  }
}

resource "aws_lambda_permission" "event_api" {
  statement_id  = local.aws_lambda_permission_statement_id
  action        = local.aws_lambda_permission_action
  function_name = aws_lambda_function.event_api.function_name
  principal     = local.aws_lambda_permission_principal
}

resource "aws_cloudwatch_log_group" "event_api" {
  name = local.aws_cloudwatch_log_event_api_group_name
  retention_in_days = 30
}

##DB PROCESSOR