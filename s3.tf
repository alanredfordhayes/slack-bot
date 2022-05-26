data "archive_file" "event-api" {
  type = local.archive_file_type

  source_dir  = "${path.module}/event-api"
  output_path = "${path.module}/event-api.zip"
}

resource "aws_s3_bucket" "event-api" {
  bucket = var.name
  force_destroy = true
}

resource "aws_s3_object" "event-api" {
  bucket = aws_s3_bucket.event-api.id

  key    = "event-api.zip"
  source = data.archive_file.event-api.output_path
}