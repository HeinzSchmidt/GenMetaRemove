# GenMetaRemove
Author: Heinz Donnelly Schmidt

## Purpose
Removes meta information from a JPG file uploaded to an AWS S3 bucket

## Prerequisite Requirements
In order to deploy this tool, you will need the following:
1. An AWS account
2. AWS CLI installed and configured with administrative IAM user
3. Terraform CLI installed
4. Sufficient budget to run:
 - One Lamdba function
 - Two AWS S3 buckets
5. Run this deployment using a Linux laptop/workstation 
   (for MacOS or Windows, please ensure the requirements are satisfied.)

### (Optional) Terraform state management:
In order to store the Terraform state for future updates to the architecture on AWS, please:
1. create an S3 bucket to store the Terraform state.
2. Add a 'backend' code block in the /deploy/terraform/providers.tf file, and provide your S3 bucket details.
3. Add a DynamoDB table if you are working in a team and need state locking. 

## Deployment

Run the INSTALL.sh file from a Bash terminal:

```
    bash ./INSTALL.sh
```
NOTE: You will be prompted to approve the deployment after reviewing the plan.

## Usage

Upload a JPG image that has EXIF metadata to the S3 bucket called: 's3-photo-inbox'
NOTE: Only image files with a .jpg file extension will be processed by the function.

The image will be processed and copies to the S3 bucket called: 's3-photo-outbox'
Please download the imae and check the EXIF information has been removed (using EXIFTool or similar)

## Debugging

Please refer to the Cloudwatch log group: /aws/lambda/genmetaremove to inspect the function run logs 