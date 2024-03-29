resource "random_string" "random" {
  length           = 8
  special          = false
  min_lower        = 8
}

locals {
  # Project Specifc Locals
  project = "${var.name}_${random_string.random.result}"

  # Technology Locals
  lambda = "${local.project}_lambda"
  dynamodb = "${local.project}_dynamodb"
  apigw = "${local.project}_apigw"
  iam_policy = "${local.project}_iam_policy"
  iam_role = "${local.project}_iam_role"

  # Layers
  ## SLACK EVENT API
  event_api = "event_api"
  event_api_lambda = "${local.lambda}_${local.event_api}"
  event_api_dynamodb = "${local.dynamodb}_${local.event_api}"
  event_api_iam_policy = "${local.iam_policy}_${local.event_api}"
  event_api_iam_role = "${local.iam_policy}_${local.event_api}"

  # Configuration
  ## API GATEWAY
  ### aws_api_gateway_rest_api
  aws_api_gateway_rest_api_name = "${local.apigw}"
  aws_api_gateway_rest_api_endpoint_configuration_types = ["REGIONAL"]
  ### aws_api_gateway_deployment
  ### aws_api_gateway_resource
  #### EVENT API
  aws_api_gateway_resource_path_part = "${local.event_api}"
  ### aws_api_gateway_method
  aws_api_gateway_method_authorization = "NONE"
  aws_api_gateway_method_http_method = "ANY"
  ### aws_api_gateway_integration
  aws_api_gateway_integration_integration_http_method = "POST"
  aws_api_gateway_integration_type = "AWS_PROXY"
  ### aws_api_gateway_stage
  aws_api_gateway_stage_stage_name = "dev"

  ## DYNAMODB
  ### aws_dynamodb_table
  aws_dynamodb_table_event_api_name = "${local.event_api_dynamodb}"
  aws_dynamodb_table_billing_mode = "PROVISIONED"
  aws_dynamodb_table_read_capacity = 1
  aws_dynamodb_table_write_capacity = 1
  aws_dynamodb_table_hash_key = "EventID"
  aws_dynamodb_table_attribute_type = "S"

  ## IAM
  ### aws_iam_role
  aws_iam_role_event_api_name = "${local.event_api_iam_role}"
  ### aws_iam_role_policy_attachment
  aws_iam_role_policy_attachment_policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ### Policies
  aws_iam_policy_event_api_name = "${local.event_api_iam_policy}"
  aws_iam_policy_path = "/"
  aws_iam_policy_event_api_description = "Access Policy for the ${local.event_api} lambda"

  ##Lambda
  ###aws_lambda_layer_version
  aws_lambda_layer_version_slack_bolt_filename = "slack_bolt.zip"
  aws_lambda_layer_version_slack_bolt_layer_name = "slack_bolt"
  aws_lambda_layer_version_slack_bolt_compatible_runtimes = ["python3.9"]
  ###aws_lambda_function
  aws_lambda_function_event_api_function_name = "${local.event_api}"
  aws_lambda_function_event_api_description = "Lambda for the ${local.event_api}"
  aws_lambda_name = "${local.event_api}"
  aws_lambda_function_runtime = "python3.9"
  aws_lambda_function_event_api_handler = "${local.event_api}.lambda_handler"
  aws_lambda_function_event_api_env_event_api_table = "${local.event_api_dynamodb}"
  ###aws_lambda_permission
  aws_lambda_permission_statement_id = "AllowExecutionFromAPIGateway"
  aws_lambda_permission_action = "lambda:InvokeFunction"
  aws_lambda_permission_principal = "apigateway.amazonaws.com"

  ##CloudWatch
  ###aws_cloudwatch_log_group
  aws_cloudwatch_log_event_api_group_name = "/aws/lambda/${aws_lambda_function.event_api.function_name}"
}
