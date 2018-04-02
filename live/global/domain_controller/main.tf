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
    profile = "${module.global_variables.aws_profile}"
    region  = "${module.global_variables.aws_region}"
    bucket  = "${module.global_variables.terrform_remote_state_s3_bucket}"
    key     = "${module.global_variables.terrform_remote_state_vpc_key}"
  }
}

data "template_file" "user_data" {
  template = "${file("user-data.template")}"
  }

resource "aws_instance" "domain_controller" {
  ami                    = "ami-ef9a0e97"
  instance_type          = "${var.instance_type}"
  key_name               = "${module.global_variables.key_name}"
  user_data              = "${data.template_file.user_data.rendered}"
  get_password_data      = true
  vpc_security_group_ids = ["${aws_security_group.domain_controller.id}"]

  tags {
    Name = "domain_controller"
  }
}

resource "aws_security_group" "domain_controller" {
  name        = "domain_controller"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Reference: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/dd772723(v=ws.10)"
}

resource "aws_security_group_rule" "allow_25_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 25
  to_port           = 25
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_53_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_53_udp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_88_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 88
  to_port           = 88
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_88_udp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 88
  to_port           = 88
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_123_udp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_135_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 135
  to_port           = 135
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_137-138_udp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 137
  to_port           = 138
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_139_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 139
  to_port           = 139
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_389_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 389
  to_port           = 389
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_389_udp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 389
  to_port           = 389
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_445_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 445
  to_port           = 445
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_445_udp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 445
  to_port           = 445
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_464_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 464
  to_port           = 464
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_464_udp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 464
  to_port           = 464
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_636_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 636
  to_port           = 636
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_3268-3269_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 3268
  to_port           = 3269
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_3389_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_5722_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 5722
  to_port           = 5722
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_9389_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 9389
  to_port           = 9389
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_49152-65535_tcp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 49152
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_49152-65535_udp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 49152
  to_port           = 65535
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 0
  to_port           = -1
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}
