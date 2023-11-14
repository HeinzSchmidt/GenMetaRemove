data "archive_file" "lambda_function_archive" {
  type        = "zip"
  output_path = "lambda_function.zip"
  source_dir = "${path.module}/../../src/lambda_function/"
}

resource "aws_lambda_function" "lambda_process_photo" {

  filename      = "lambda_function.zip"
  function_name = "genmetaremove"
  role          = aws_iam_role.lambda-function-role.arn
  handler       = "index.lambda_handler"
  runtime = "python3.8"

  environment {
    variables = {
      bucket_inbox = "${aws_s3_bucket.s3-photo-inbox.id}"
      bucket_outbox = "${aws_s3_bucket.s3-photo-outbox.id}"
      bucket_region = "${var.region}"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.attach-iampolicy-to-iamrole, data.archive_file.lambda_function_archive]
}

