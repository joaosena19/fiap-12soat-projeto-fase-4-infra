import {
  to = aws_s3_bucket.bucket_fiap_fase4
  id = var.bucket_name
}

resource "aws_s3_bucket" "bucket_fiap_fase4" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true # Como o proprio tfstate esta no bucket, previnimos que ele seja destruido acidentalmente
  }

  tags = {
    Name              = "Bucket ${var.project_name}"
    Environment       = var.environment
    ProjectIdentifier = var.project_identifier
  }
}
