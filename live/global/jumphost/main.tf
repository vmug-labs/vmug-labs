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

provider "template" {
  version = "~> 1.0"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket  = "${module.global_variables.terrform_remote_state_s3_bucket}"
    profile = "${module.global_variables.aws_profile}"
    region  = "${module.global_variables.aws_region}"
    key     = "${module.global_variables.terrform_remote_state_vpc_key}"
  }
}

data "terraform_remote_state" "domain_controller" {
  backend = "s3"

  config {
    profile = "${module.global_variables.aws_profile}"
    region  = "${module.global_variables.aws_region}"
    bucket  = "${module.global_variables.terrform_remote_state_s3_bucket}"
    key     = "${module.global_variables.terrform_remote_state_domain_controller_key}"
  }
}

data "template_file" "user_data" {
  template = "${file("user-data.template")}"

  vars {
    domain_name          = "${data.terraform_remote_state.domain_controller.domain_name}"
    domain_controller_ip = "${data.terraform_remote_state.domain_controller.private_ip}"
    password             = "${data.terraform_remote_state.domain_controller.password}"
  }
}

resource "aws_instance" "jumphost" {
  ami                    = "ami-ef9a0e97"
  instance_type          = "${var.instance_type}"
  key_name               = "${module.global_variables.key_name}"
  user_data              = "${data.template_file.user_data.rendered}"
  get_password_data      = true
  vpc_security_group_ids = ["${aws_security_group.jumphost.id}"]

  tags {
    Name = "jumphost"
  }
}

resource "aws_security_group" "jumphost" {
  name   = "jumphost"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
}

resource "aws_security_group_rule" "allow_3389_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.jumphost.id}"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.jumphost.id}"
  from_port         = 0
  to_port           = -1
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}
