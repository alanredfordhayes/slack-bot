resource "aws_dynamodb_table" "event_api" {
  name           = local.aws_dynamodb_table_event_api_name
  billing_mode   = local.aws_dynamodb_table_billing_mode
  read_capacity  = local.aws_dynamodb_table_read_capacity
  write_capacity = local.aws_dynamodb_table_write_capacity
  hash_key       = local.aws_dynamodb_table_hash_key
  lifecycle { ignore_changes = [write_capacity, read_capacity] }
  attribute {
    name = local.aws_dynamodb_table_hash_key
    type = local.aws_dynamodb_table_attribute_type
  }
}