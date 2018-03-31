terraform {
  required_version = ">= 0.11, < 0.12"

  backend "s3" {}
}

provider "aws" {
  version = "~> 1.13"
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.aws_s3_bucket}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
