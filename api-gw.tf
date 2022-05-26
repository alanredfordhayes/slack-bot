locals {
  aws_api_gateway_rest_api_name = format("${var.name}-%s", "api-gateway")
  aws_api_gateway_resource_path_part = var.path_part
  aws_api_gateway_method_authorization = "NONE"
  aws_api_gateway_method_http_method = "ANY"
  aws_api_gateway_integration_integration_http_method = "POST"
  aws_api_gateway_integration_type = "AWS_PROXY"
  aws_api_gateway_stage_stage_name = var.stage_name
  aws_api_gateway_rest_api_endpoint_configuration_types = ["REGIONAL"]
}

resource "aws_api_gateway_rest_api" "slack-bot" {
  name = local.aws_api_gateway_rest_api_name
  endpoint_configuration { types = local.aws_api_gateway_rest_api_endpoint_configuration_types }
}

resource "aws_api_gateway_resource" "slack-bot" {
  parent_id   = aws_api_gateway_rest_api.slack-bot.root_resource_id
  path_part   = local.aws_api_gateway_resource_path_part
  rest_api_id = aws_api_gateway_rest_api.slack-bot.id
}

resource "aws_api_gateway_method" "slack-bot" {
  authorization = local.aws_api_gateway_method_authorization
  http_method   = local.aws_api_gateway_method_http_method
  resource_id   = aws_api_gateway_resource.slack-bot.id
  rest_api_id   = aws_api_gateway_rest_api.slack-bot.id
}

resource "aws_api_gateway_integration" "slack-bot" {
  http_method             = local.aws_api_gateway_method_http_method
  resource_id             = aws_api_gateway_resource.slack-bot.id
  rest_api_id             = aws_api_gateway_rest_api.slack-bot.id
  integration_http_method = local.aws_api_gateway_integration_integration_http_method
  type                    = local.aws_api_gateway_integration_type
  uri                     = aws_lambda_function.event-api.invoke_arn
}

resource "aws_api_gateway_deployment" "slack-bot" {
  rest_api_id = aws_api_gateway_rest_api.slack-bot.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.slack-bot.id,
      aws_api_gateway_method.slack-bot.id,
      aws_api_gateway_integration.slack-bot.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "slack-bot" {
  deployment_id = aws_api_gateway_deployment.slack-bot.id
  rest_api_id   = aws_api_gateway_rest_api.slack-bot.id
  stage_name    = local.aws_api_gateway_stage_stage_name
}