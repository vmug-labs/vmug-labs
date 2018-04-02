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

resource "aws_default_vpc" "default" {
  tags {
    Name = "VMUG1"
  }
}
