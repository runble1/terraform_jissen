# ====================
#
# S3 Private
#
# ====================
resource "aws_s3_bucket" "private" {
  bucket = "private-pragmatic-terraform5"

  # バージョニング
  versioning {
    enabled = true
  }

  # 暗号化
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_s3_bucket_public_access_block" "private" {
  bucket                  = aws_s3_bucket.private.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ====================
#
# S3 for Log
#
# ====================
data "aws_elb_service_account" "alb_log" {
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-pragmatic-terraform5"

  # ライフサイクルルール
  lifecycle_rule {
    enabled = true
    expiration {
      days = "180"
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_elb_service_account.alb_log.id}:root",
      ]
    }
  }
}
