provider "aws" {
  source_account_id = "12345Z-----12" # Source AWS Account ID
  region = "us-east-1"  # Update with your desired region
}

provider "aws" {
  alias              = "destination"
  assume_role {
    role_arn         = "arn:aws:iam::DESTINATION_ACCOUNT_ID:role/role-name"  # Destination AWS Account IAM Role ARN
  }
  region = "us-east-1"  # Update with your desired region
}

resource "aws_s3_bucket" "source_bucket" {
  bucket = "source-bucket-name" # Source bucket name
  acl    = "private"
}

resource "aws_s3_bucket" "destination_bucket" {
  provider = aws.destination
  bucket   = "destination-bucket-name" # Destination bucket name
  acl      = "private"
}

resource "aws_s3_bucket_object" "copy_objects" {
  for_each = aws_s3_bucket.source_bucket.objects
  bucket   = aws_s3_bucket.destination_bucket.bucket
  key      = each.key

  source = "arn:aws:s3:::${aws_s3_bucket.source_bucket.bucket}/${each.key}"
}
