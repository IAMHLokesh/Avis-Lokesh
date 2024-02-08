provider "aws" {
  region = "us-east-1" 
}

# Create an IAM role in the source account
resource "aws_iam_role" "source_account_role" {
  name               = "SourceAccountRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::DESTINATION_ACCOUNT_ID:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF
}

# Attach a policy to the IAM role to access the source S3 bucket
resource "aws_iam_role_policy_attachment" "source_account_role_policy_attachment" {
  role       = aws_iam_role.source_account_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" # Adjust policy as needed
}

# Create a bucket policy for the source S3 bucket to allow access from the IAM role in the destination account
resource "aws_s3_bucket_policy" "source_bucket_policy" {
  bucket = "source-bucket-name"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowGetObject",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::DESTINATION_ACCOUNT_ID:role/SourceAccountRole"
        },
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::source-bucket-name/*"
      }
    ]
  })
}

# Output the ARN of the source IAM role
output "source_account_role_arn" {
  value = aws_iam_role.source_account_role.arn
}


################################################################################
#   Required changes are below to make it complete                             #
################################################################################
# Update the provider block with "us-east-1" to the desired AWS region.        #
#                                                                              #
# Set the DESTINATION_ACCOUNT_ID in the assume_role_policy and Principal       #
# and Principal fields with the AWS account ID of the destination              #
# account where you want to grant access.                                      #
#                                                                              #
# Specify the name of the source S3 bucket "source-bucket-name" with           #
# name of the S3 bucket in the source account that you want to grant access to #
#                                                                              #
################################################################################
