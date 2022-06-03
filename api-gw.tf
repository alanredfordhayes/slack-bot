resource "aws_api_gateway_rest_api" "slack_bot" {
  name = local.aws_api_gateway_rest_api_name
  endpoint_configuration { types = local.aws_api_gateway_rest_api_endpoint_configuration_types }
}

resource "aws_api_gateway_deployment" "slack_bot" {
  rest_api_id = aws_api_gateway_rest_api.slack_bot.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.event_api.id,
      aws_api_gateway_method.event_api.id,
      aws_api_gateway_integration.event_api.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "event_api" {
  parent_id   = aws_api_gateway_rest_api.slack_bot.root_resource_id
  path_part   = local.aws_api_gateway_resource_path_part
  rest_api_id = aws_api_gateway_rest_api.slack_bot.id
}

resource "aws_api_gateway_method" "event_api" {
  authorization = local.aws_api_gateway_method_authorization
  http_method   = local.aws_api_gateway_method_http_method
  resource_id   = aws_api_gateway_resource.event_api.id
  rest_api_id   = aws_api_gateway_rest_api.slack_bot.id
}

resource "aws_api_gateway_integration" "event_api" {
  http_method             = aws_api_gateway_method.event_api.http_method
  resource_id             = aws_api_gateway_resource.event_api.id
  rest_api_id             = aws_api_gateway_rest_api.slack_bot.id
  integration_http_method = local.aws_api_gateway_integration_integration_http_method
  type                    = local.aws_api_gateway_integration_type
  uri                     = aws_lambda_function.event_api.invoke_arn
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.slack_bot.id
  rest_api_id   = aws_api_gateway_rest_api.slack_bot.id
  stage_name    = local.aws_api_gateway_stage_stage_name
}