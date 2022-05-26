# Event API

data "archive_file" "event-api" { 
  type = "zip"

  source_dir  = "${path.module}/event-api"
  output_path = "${path.module}/event-api.zip"
}

resource "aws_s3_bucket" "event-api" {
  bucket_prefix = var.name
  force_destroy = true
}

resource "aws_s3_object" "event-api" {
  bucket = aws_s3_bucket.event-api.id

  key    = "event-api.zip"
  source = data.archive_file.event-api.output_path
  etag = filemd5(data.archive_file.event-api.output_path)
}

# DB Processor

data "archive_file" "db_processor" { 
  type = "zip"

  source_dir  = "${path.module}/db_processor"
  output_path = "${path.module}/db_processor.zip"
}

resource "aws_s3_object" "db_processor" {
  bucket = aws_s3_bucket.event-api.id

  key    = "db_processor.zip"
  source = data.archive_file.db_processor.output_path
  etag = filemd5(data.archive_file.db_processor.output_path)
}