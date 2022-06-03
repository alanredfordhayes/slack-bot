resource "aws_cloudwatch_log_group" "event_api" {
  name = local.aws_cloudwatch_log_event_api_group_name
  retention_in_days = 30
}