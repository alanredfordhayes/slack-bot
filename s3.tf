# Event API
data "archive_file" "event_api" { 
  type = "zip"

  source_dir  = "${path.module}/event_api"
  output_path = "${path.module}/event_api.zip"
}

resource "aws_s3_bucket" "event_api" {
  bucket_prefix = var.name
  force_destroy = true
}

resource "aws_s3_object" "event_api" {
  bucket = aws_s3_bucket.event_api.id

  key    = "event_api.zip"
  source = data.archive_file.event_api.output_path
  etag = filemd5(data.archive_file.event_api.output_path)
}

# DB Processor
data "archive_file" "db_processor" { 
  type = "zip"

  source_dir  = "${path.module}/db_processor"
  output_path = "${path.module}/db_processor.zip"
}

resource "aws_s3_object" "db_processor" {
  bucket = aws_s3_bucket.event_api.id

  key    = "db_processor.zip"
  source = data.archive_file.db_processor.output_path
  etag = filemd5(data.archive_file.db_processor.output_path)
}