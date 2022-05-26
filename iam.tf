locals {
  #aws_iam_role
  aws_iam_role_event_api_name = format("${var.name}-%s-%s","event-api", "role")
  aws_iam_role_db_processor_name = format("${var.name}-%s-%s","event-api", "role")

  #aws_iam_role_policy_attachment
  aws_iam_role_policy_attachment_policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Event API

resource "aws_iam_role" "event-api" {
  name = local.aws_iam_role_event_api_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "event-api" {
  role       = aws_iam_role.event-api.name
  policy_arn = local.aws_iam_role_policy_attachment_policy_arn
}

# Db Processor

resource "aws_iam_role" "db_processor" {
  name = local.aws_iam_role_db_processor_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "db_processor" {
  role       = aws_iam_role.db_processor.name
  policy_arn = local.aws_iam_role_policy_attachment_policy_arn
}