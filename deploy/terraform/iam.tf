# Lambda IAM role
resource "aws_iam_role" "lambda-function-role" {
    name   = "lambda-function-role"
    assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

# Lambda logging policy
resource "aws_iam_policy" "iam-policy-for-lambda-function" {
    name         = "iam-policy-for-terraform-lambda-role"
    path         = "/"
    description  = "AWS IAM Policy - aws lambda role"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-iampolicy-to-iamrole" {
    role        = aws_iam_role.lambda-function-role.name
    policy_arn  = aws_iam_policy.iam-policy-for-lambda-function.arn
}

# S3 Object read policy for Lambda
resource "aws_s3_bucket_policy" "allow-read-from-lambda" {
    bucket = aws_s3_bucket.s3-photo-inbox.id
    policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "GetObjectStmt",
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::682162187525:role/lambda-function-role"
			},
			"Action": [
				"s3:GetObject",
				"s3:ListBucket"
			],
			"Resource": [
			    "arn:aws:s3:::s3-photo-inbox",
                "arn:aws:s3:::s3-photo-inbox/*"
			]
		}
	]
}
EOF
}


# S3 Object write policy for Lambda
resource "aws_s3_bucket_policy" "allow-write-from-lambda" {
    bucket = aws_s3_bucket.s3-photo-outbox.id
    policy = <<EOF
{
    "Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "PutObjectStmt",
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::682162187525:role/lambda-function-role"
			},
			"Action": [
				"s3:PutObject",
				"s3:PutObjectAcl",
				"s3:ListBucket"
			],
			"Resource": [
			    "arn:aws:s3:::s3-photo-outbox",
                "arn:aws:s3:::s3-photo-outbox/*"
			]
		}
    ]
}
EOF
}

resource "aws_lambda_permission" "invoke-lambda-function" {
    statement_id  = "AllowS3Invoke"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_process_photo.function_name}"
    principal = "s3.amazonaws.com"
    source_arn = "arn:aws:s3:::${aws_s3_bucket.s3-photo-inbox.id}"
}

