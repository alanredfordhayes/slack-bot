locals {
  aws_dynamodb_table_billing_mode = "PROVISIONED"
  aws_dynamodb_table_hash_key = "EventID"
  aws_dynamodb_table_read_capacity = 1
  aws_dynamodb_table_write_capacity = 1
  aws_dynamodb_table_attribute_type = "S"
}

resource "aws_dynamodb_table" "event-api" {
  name           = local.slack_bot_table_name
  billing_mode   = local.aws_dynamodb_table_billing_mode
  read_capacity  = local.aws_dynamodb_table_read_capacity
  write_capacity = local.aws_dynamodb_table_write_capacity
  hash_key       = local.aws_dynamodb_table_hash_key

  attribute {
    name = local.aws_dynamodb_table_hash_key
    type = local.aws_dynamodb_table_attribute
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  lifecycle {
    ignore_changes = [write_capacity, read_capacity]
  }
}

resource "aws_dynamodb_table" "db_processor" {
  name           = "db_processor"
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

resource "aws_appautoscaling_target" "event-api" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.event-api.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_target" "db_processor" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.db_processor.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "event-api" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.event-api.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.event-api.resource_id
  scalable_dimension = aws_appautoscaling_target.event-api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.event-api.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }

  depends_on = [aws_appautoscaling_target.event-api]
}

resource "aws_appautoscaling_policy" "db_processor" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.db_processor.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.db_processor.resource_id
  scalable_dimension = aws_appautoscaling_target.db_processor.scalable_dimension
  service_namespace  = aws_appautoscaling_target.db_processor.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }

  depends_on = [aws_appautoscaling_target.db_processor]
}

resource "aws_iam_policy" "event-api-dynamodb" {
    name = "${var.name}-dynamodb"
    path = "/"
    description = "Policy for slackbot event-api dynamodb"
    policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [{
                Effect = "Allow"
                Action = [
                "dynamodb:BatchGetItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
                ]
                Resource = "arn:aws:dynamodb:us-east-1:216608214837:table/${aws_dynamodb_table.event-api.name}"
            }]
        }
    )
}

resource "aws_iam_policy" "db_processor-dynamodb" {
    name = "${var.name}-db_processor-dynamodb"
    path = "/"
    description = "Policy for slackbot db_processor dynamodb"
    policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [{
                Effect = "Allow"
                Action = [
                "dynamodb:BatchGetItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
                ]
                Resource = "arn:aws:dynamodb:us-east-1:216608214837:table/${aws_dynamodb_table.db_processor.name}"
            }]
        }
    )
}

resource "aws_iam_policy" "event-api-log" {
    name = "${var.name}-log"
    path = "/"
    description = "Policy for slackbot event-api dynamodb log"
    policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [{
                Effect = "Allow"
                Action = [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
                ]
                Resource = "arn:aws:dynamodb:us-east-1:216608214837:table/${aws_dynamodb_table.event-api.name}"
            }]
        }
    )
}

resource "aws_iam_policy" "db_processor-log" {
    name = "${var.name}-db_processor-log"
    path = "/"
    description = "Policy for slackbot db_processor dynamodb log"
    policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [{
                Effect = "Allow"
                Action = [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
                ]
                Resource = "arn:aws:dynamodb:us-east-1:216608214837:table/${aws_dynamodb_table.db_processor.name}"
            }]
        }
    )
}

resource "aws_iam_policy" "event-api-loggroup" {
    name = "${var.name}-loggroup"
    path = "/"
    description = "Policy for slackbot event-api dynamodb loggroup"
    policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [{
                Effect = "Allow"
                Action = "logs:CreateLogGroup"
                Resource = "*"
            }]
        }
    )
}

resource "aws_iam_policy" "db_processor-loggroup" {
    name = "${var.name}-db_processor-loggroup"
    path = "/"
    description = "Policy for slackbot db_processor dynamodb loggroup"
    policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [{
                Effect = "Allow"
                Action = "logs:CreateLogGroup"
                Resource = "*"
            }]
        }
    )
}

resource "aws_iam_policy" "event-api-stream" {
    name = "${var.name}-stream"
    path = "/"
    description = "Policy for ddm slackbot challenge dynamodb stream"
    policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [{
                Effect = "Allow"
                Action = [
                  "dynamodb:DescribeStream",
                  "dynamodb:GetRecords",
                  "dynamodb:GetShardIterator",
                  "dynamodb:ListStreams"
                ]
                Resource = "arn:aws:dynamodb:us-east-1:216608214837:table/${aws_dynamodb_table.event-api.name}/stream/*"
            }]
        }
    )
}

resource "aws_iam_policy_attachment" "event-api-dynamodb" {
  name       = aws_iam_policy.event-api-dynamodb.name
  roles      = [
    aws_iam_role.event-api.name,
    aws_iam_role.db_processor.name
  ]
  policy_arn = aws_iam_policy.event-api-dynamodb.arn
}

resource "aws_iam_policy_attachment" "db_processor-dynamodb" {
  name       = aws_iam_policy.db_processor-dynamodb.name
  roles      = [
    aws_iam_role.db_processor.name,
  ]
  policy_arn = aws_iam_policy.db_processor-dynamodb.arn
}

resource "aws_iam_policy_attachment" "event-api-log" {
  name       = aws_iam_policy.event-api-log.name
  roles      = [
    aws_iam_role.event-api.name,
    aws_iam_role.db_processor.name
  ]
  policy_arn = aws_iam_policy.event-api-log.arn
}

resource "aws_iam_policy_attachment" "db_processor-log" {
  name       = aws_iam_policy.db_processor-log.name
  roles      = [
    aws_iam_role.db_processor.name
  ]
  policy_arn = aws_iam_policy.db_processor-log.arn
}

resource "aws_iam_policy_attachment" "event-api-loggroup" {
  name       = aws_iam_policy.event-api-log.name
  roles      = [
    aws_iam_role.db_processor.name
  ]
  policy_arn = aws_iam_policy.event-api-loggroup.arn
}

resource "aws_iam_policy_attachment" "db_processor-loggroup" {
  name       = aws_iam_policy.db_processor-log.name
  roles      = [
    aws_iam_role.db_processor.name
  ]
  policy_arn = aws_iam_policy.db_processor-loggroup.arn
}

resource "aws_iam_policy_attachment" "event-api-stream" {
  name       = aws_iam_policy.event-api-stream.name
  roles      = [
    aws_iam_role.db_processor.name
  ]
  policy_arn = aws_iam_policy.event-api-stream.arn
}