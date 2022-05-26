resource "random_string" "event-api" {
  length           = 16
  special          = false
}

data "archive_file" "event-api" { 
  type = "zip"

  source_dir  = "${path.module}/event-api"
  output_path = "${path.module}/event-api.zip"
}

resource "aws_s3_bucket" "event-api" {
  bucket = "event_api_${random_string.event-api.result}"
  force_destroy = true
}

resource "aws_s3_object" "event-api" {
  bucket = aws_s3_bucket.event-api.id

  key    = "event-api.zip"
  source = data.archive_file.event-api.output_path
}