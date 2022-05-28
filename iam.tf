# ROLES
## Event API
resource "aws_iam_role" "event_api" {
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

resource "aws_iam_role_policy_attachment" "event_api" {
  role       = aws_iam_role.event_api.name
  policy_arn = local.aws_iam_role_policy_attachment_policy_arn
}

resource "aws_iam_policy" "event_api" {
    name = local.aws_iam_policy_event_api_name
    path = local.aws_iam_policy_path
    description = local.aws_iam_policy_event_api_description
    policy = jsonencode(
        {
          Version = "2012-10-17"
          Statement = [
            {
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
              Resource = "arn:aws:dynamodb:us-east-1:${var.AWS_ACCOUNT_NUMBER}:table/${aws_dynamodb_table.event_api.name}"
            },
            {
              Effect = "Allow"
              Action = [
              "logs:CreateLogStream",
              "logs:PutLogEvents"
              ]
              Resource = "arn:aws:dynamodb:us-east-1:${var.AWS_ACCOUNT_NUMBER}:table/${aws_dynamodb_table.event_api.name}"
            },
            {
              Effect = "Allow"
              Action = "logs:CreateLogGroup"
              Resource = "*"
            }
          ]
        }
    )
}

resource "aws_iam_policy_attachment" "event_api" {
  name       = aws_iam_policy.event_api.name
  roles      = [aws_iam_role.event_api.name]
  policy_arn = aws_iam_policy.event_api.arn
}