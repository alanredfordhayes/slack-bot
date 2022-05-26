resource "random_string" "event-api" {
  length           = 8
  special          = false
}

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
}