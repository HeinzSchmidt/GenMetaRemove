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

# IAM Users
resource "aws_iam_user" "inbox-user" {
  name = var.inbox_user
}

resource "aws_iam_user" "outbox-user" {
  name = var.outbox_user
}

# S3 Bucket Policies
resource "aws_s3_bucket_policy" "allow-read-from-lambda" {
    bucket = aws_s3_bucket.s3-photo-inbox.id
    policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::682162187525:role/lambda-function-role"
			},
			"Action": [
				"s3:GetObject",
				"s3:ListBucket"
			],
			"Resource": [
			    "${aws_s3_bucket.s3-photo-inbox.arn}/*",
                "${aws_s3_bucket.s3-photo-inbox.arn}"
			]
		},
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.inbox-user.arn}"
            },
            "Action": [
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "${aws_s3_bucket.s3-photo-inbox.arn}/*",
                "${aws_s3_bucket.s3-photo-inbox.arn}"
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
			    "${aws_s3_bucket.s3-photo-outbox.arn}/*",
                "${aws_s3_bucket.s3-photo-outbox.arn}"
			]
		},
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.outbox-user.arn}"
            },
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.s3-photo-outbox.arn}/*",
                "${aws_s3_bucket.s3-photo-outbox.arn}"
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

