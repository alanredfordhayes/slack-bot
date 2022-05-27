resource "aws_dynamodb_table" "event_api" {
  name           = local.aws_dynamodb_table_event_api_name
  billing_mode   = local.aws_dynamodb_table_billing_mode
  read_capacity  = local.aws_dynamodb_table_read_capacity
  write_capacity = local.aws_dynamodb_table_write_capacity
  hash_key       = local.aws_dynamodb_table_hash_key

  attribute {
    name = local.aws_dynamodb_table_hash_key
    type = local.aws_dynamodb_table_attribute_type
  }

  stream_enabled   = local.aws_dynamodb_table_stream_enabled
  stream_view_type = local.aws_dynamodb_table_stream_view_type

  lifecycle {
    ignore_changes = [write_capacity, read_capacity]
  }
}

resource "aws_dynamodb_table" "db_processor" {
  name           = local.aws_dynamodb_table_db_processor_name
  billing_mode   = local.aws_dynamodb_table_billing_mode
  read_capacity  = local.aws_dynamodb_table_read_capacity
  write_capacity = local.aws_dynamodb_table_write_capacity
  hash_key       = local.aws_dynamodb_table_hash_key

  attribute {
    name = local.aws_dynamodb_table_hash_key
    type = local.aws_dynamodb_table_attribute_type
  }

  lifecycle {
    ignore_changes = [write_capacity, read_capacity]
  }
}

resource "aws_appautoscaling_target" "event_api" {
  max_capacity       = local.aws_appautoscaling_target_max_capacity
  min_capacity       = local.aws_appautoscaling_target_min_capacity
  resource_id        = "table/${aws_dynamodb_table.event_api.name}"
  scalable_dimension = local.aws_appautoscaling_target_scalable_dimension
  service_namespace  = local.aws_appautoscaling_target_service_namespace
}

resource "aws_appautoscaling_target" "db_processor" {
  max_capacity       = local.aws_appautoscaling_target_max_capacity
  min_capacity       = local.aws_appautoscaling_target_min_capacity
  resource_id        = "table/${aws_dynamodb_table.db_processor.name}"
  scalable_dimension = local.aws_appautoscaling_target_scalable_dimension
  service_namespace  = local.aws_appautoscaling_target_service_namespace
}

resource "aws_appautoscaling_policy" "event_api" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.event_api.resource_id}"
  policy_type        = local.aws_appautoscaling_policy_policy_type
  resource_id        = aws_appautoscaling_target.event_api.resource_id
  scalable_dimension = aws_appautoscaling_target.event_api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.event_api.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = local.aws_appautoscaling_policy_predefined_metric_type
    }

    target_value = 70
  }

  depends_on = [aws_appautoscaling_target.event_api]
}

resource "aws_appautoscaling_policy" "db_processor" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.db_processor.resource_id}"
  policy_type        = local.aws_appautoscaling_policy_policy_type
  resource_id        = aws_appautoscaling_target.db_processor.resource_id
  scalable_dimension = aws_appautoscaling_target.db_processor.scalable_dimension
  service_namespace  = aws_appautoscaling_target.db_processor.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = local.aws_appautoscaling_policy_predefined_metric_type
    }

    target_value = 70
  }

  depends_on = [aws_appautoscaling_target.db_processor]
}