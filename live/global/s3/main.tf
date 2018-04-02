terraform {
  required_version = ">= 0.11, < 0.12"

  backend "s3" {}
}

module "global_variables" {
  source = "../../../modules/global_variables"
}

provider "aws" {
  version = "~> 1.13"
  profile = "${module.global_variables.aws_profile}"
  region  = "${module.global_variables.aws_region}"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${module.global_variables.terrform_remote_state_s3_bucket}"

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
