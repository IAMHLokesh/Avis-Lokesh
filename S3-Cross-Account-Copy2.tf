provider "aws" {
  region = "us-east-2"  # Update with your desired region
}

provider "aws" {
  alias              = "destination"
  assume_role {
    role_arn         = "arn:aws:iam::987568177412:role/role-name"  # Destination AWS Account IAM Role ARN
  }
  region = "us-east-2"  # Update with your desired region
}

# IAM Role in Source Account
resource "aws_iam_role" "source_role" {
  name               = "source-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::987568177412:root"  # Destination AWS Account ID
    },
    "Action": "sts:AssumeRole"
  }]
}
EOF
}

# IAM Role in Destination Account
resource "aws_iam_role" "destination_role" {
  name               = "destination-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "s3.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
EOF
}

# IAM Policy for Source Role (read permissions for source bucket)
resource "aws_iam_policy" "source_policy" {
  name        = "source-policy"
  description = "Allows read access to source S3 bucket"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::lokesh-02-08-2024",
        "arn:aws:s3:::lokesh-02-08-2024/*"
      ]
    }]
  })
}

# IAM Policy for Destination Role (write permissions for destination bucket)
resource "aws_iam_policy" "destination_policy" {
  name        = "destination-policy"
  description = "Allows write access to destination S3 bucket"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::destination-bucket-name",
        "arn:aws:s3:::destination-bucket-name/*"
      ]
    }]
  })
}

# Attaching policies to IAM roles
resource "aws_iam_role_policy_attachment" "attach_source_policy" {
  policy_arn = aws_iam_policy.source_policy.arn
  role       = aws_iam_role.source_role.name
}

resource "aws_iam_role_policy_attachment" "attach_destination_policy" {
  policy_arn = aws_iam_policy.destination_policy.arn
  role       = aws_iam_role.destination_role.name
}

# S3 Bucket in Source Account
resource "aws_s3_bucket" "source_bucket" {
  bucket = "lokesh-02-08-2024"
  acl    = "private"
}

# S3 Bucket in Destination Account
resource "aws_s3_bucket" "destination_bucket" {
  provider = aws.destination
  bucket   = "destination-bucket-name"
  acl      = "private"
}

# Copying objects from source bucket to destination bucket
resource "aws_s3_bucket_object" "copy_objects" {
  for_each = aws_s3_bucket.source_bucket.objects
  bucket   = aws_s3_bucket.destination_bucket.bucket
  key      = each.key
  source   = "arn:aws:s3:::${aws_s3_bucket.source_bucket.bucket}/${each.key}"
}
