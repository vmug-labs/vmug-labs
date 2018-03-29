terraform {
  required_version = ">= 0.11, < 0.12"
  backend          "s3"             {}
}

provider "aws" {
  version = "~> 1.12"
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

provider "template" {
  version = "~> 1.0"
}

data "template_file" "user_data" {
  template = "${file("user-data.template")}"
}

resource "aws_instance" "jumphost" {
  ami                    = "ami-ef9a0e97"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  user_data              = "${data.template_file.user_data.rendered}"
  get_password_data      = true
  vpc_security_group_ids = ["${aws_security_group.jumphost.id}"]

  tags {
    Name = "jumphost"
  }
}

resource "aws_security_group" "jumphost" {
  name = "jumphost"
}

resource "aws_security_group_rule" "allow_rdp_inbound" {
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
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
