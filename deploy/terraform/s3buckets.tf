resource "aws_s3_bucket" "s3-photo-inbox" {
  bucket = "s3-photo-inbox"
  force_destroy = true

  tags = {
    Name        = "Usage"
    Environment = "Receive uploaded JPG files"
  }
}

resource "aws_s3_bucket" "s3-photo-outbox" {
  bucket = "s3-photo-outbox"
  force_destroy = true

  tags = {
    Name        = "Usage"
    Environment = "Store processed JPG files"
  }
}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
    bucket = "${aws_s3_bucket.s3-photo-inbox.id}"
    lambda_function {
        lambda_function_arn = "${aws_lambda_function.lambda_process_photo.arn}"
        events              = ["s3:ObjectCreated:*"]
        filter_suffix       = ".jpg"
    }
}