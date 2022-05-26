resource "aws_dynamodb_table" "event-api" {
  name           = local.slack_bot_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EventID"

  attribute {
    name = "EventID"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

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

resource "aws_appautoscaling_policy" "devent-api" {
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

resource "aws_iam_policy" "event-api-log" {
    name = "${var.name}-log"
    path = "/"
    description = "Policy for slackbot event-api dynamodb"
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

resource "aws_iam_policy" "event-api-loggroup" {
    name = "${var.name}-loggroup"
    path = "/"
    description = "Policy for slackbot event-api dynamodb"
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

resource "aws_iam_policy_attachment" "event-api-dynamodb" {
  name       = aws_iam_policy.event-api-dynamodb.name
  roles      = [
    aws_iam_role.event-api.name,
  ]
  policy_arn = aws_iam_policy.event-api-dynamodb.arn
}

resource "aws_iam_policy_attachment" "event-api-log" {
  name       = aws_iam_policy.event-api-log.name
  roles      = [
    aws_iam_role.event-api.name,
  ]
  policy_arn = aws_iam_policy.event-api-log.arn
}

resource "aws_iam_policy_attachment" "event-api-loggroup" {
  name       = aws_iam_policy.event-api-log.name
  roles      = [
    aws_iam_role.event-api.name,
  ]
  policy_arn = aws_iam_policy.event-api-loggroup.arn
}
