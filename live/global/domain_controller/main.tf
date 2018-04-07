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

provider "random" {
  version = "~> 1.1"
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

resource "random_integer" "length" {
  min = 16
  max = 32
}

resource "random_string" "safe_mode_administrator_password" {
  length  = "${random_integer.length.result}"
  upper   = true
  lower   = true
  number  = true
  special = true
}

data "template_file" "user_data" {
  template = "${file("user-data.template")}"

  vars {
    domain_name                      = "${var.domain_name}"
    domain_netbios_name              = "${var.domain_netbios_name}"
    safe_mode_administrator_password = "${random_string.safe_mode_administrator_password.result}"
  }
}

resource "aws_instance" "domain_controller" {
  ami                    = "${lookup(var.ami, module.global_variables.aws_region)}"
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
  description       = "SMTP: Replication"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 25
  to_port           = 25
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_53_tcp_inbound" {
  description       = "DNS: User and Computer Authentication, Name Resolution, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_53_udp_inbound" {
  description       = "DNS: User and Computer Authentication, Name Resolution, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_88_tcp_inbound" {
  description       = "Kerberos: User and Computer Authentication, Forest Level Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 88
  to_port           = 88
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_88_udp_inbound" {
  description       = "Kerberos: User and Computer Authentication, Forest Level Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 88
  to_port           = 88
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_123_udp_inbound" {
  description       = "NTP: Windows Time, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_135_tcp_inbound" {
  description       = "RPC, EPM: Replication"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 135
  to_port           = 135
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_137_udp_inbound" {
  description       = "NetLogon, NetBIOS Name Resolution: User and Computer Authentication"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 137
  to_port           = 137
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_138_udp_inbound" {
  description       = "DFSN, NetLogon, NetBIOS Datagram Service: DFS, Group Policy"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 138
  to_port           = 138
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_139_tcp_inbound" {
  description       = "DFSN, NetBIOS Session Service, NetLogon: User and Computer Authentication, Replication"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 139
  to_port           = 139
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_389_tcp_inbound" {
  description       = "LDAP: Directory, Replication, User and Computer Authentication, Group Policy, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 389
  to_port           = 389
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_389_udp_inbound" {
  description       = "LDAP: Directory, Replication, User and Computer Authentication, Group Policy, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 389
  to_port           = 389
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_445_tcp_inbound" {
  description       = "SMB,CIFS,SMB2, DFSN, LSARPC, NbtSS, NetLogonR, SamR, SrvSvc: Replication, User and Computer Authentication, Group Policy, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 445
  to_port           = 445
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_445_udp_inbound" {
  description       = "SMB,CIFS,SMB2, DFSN, LSARPC, NbtSS, NetLogonR, SamR, SrvSvc: Replication, User and Computer Authentication, Group Policy, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 445
  to_port           = 445
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_464_tcp_inbound" {
  description       = "Kerberos change/set password: Replication, User and Computer Authentication, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 464
  to_port           = 464
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_464_udp_inbound" {
  description       = "Kerberos change/set password: Replication, User and Computer Authentication, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 464
  to_port           = 464
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_636_tcp_inbound" {
  description       = "LDAPS: Directory, Replication, User and Computer Authentication, Group Policy, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 636
  to_port           = 636
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_3268_tcp_inbound" {
  description       = "LDAP GC: Directory, Replication, User and Computer Authentication, Group Policy, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 3268
  to_port           = 3268
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_3269_tcp_inbound" {
  description       = "LDAP GC SSL: Directory, Replication, User and Computer Authentication, Group Policy, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 3269
  to_port           = 3269
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_3389_tcp_inbound" {
  description       = "RDP"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_5722_tcp_inbound" {
  description       = "RPC, DFSR (SYSVOL): File Replication"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 5722
  to_port           = 5722
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_9389_tcp_inbound" {
  description       = "SOAP: AD DS Web Services"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 9389
  to_port           = 9389
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_49152-65535_tcp_inbound" {
  description       = "RPC, DCOM, EPM, DRSUAPI, NetLogonR, SamR, FRS: Replication, User and Computer Authentication, Group Policy, Trusts"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 49152
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_49152-65535_udp_inbound" {
  description       = "DCOM, RPC, EPM: Group Policy"
  type              = "ingress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 49152
  to_port           = 65535
  protocol          = "udp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  description       = "Allow all outbound"
  type              = "egress"
  security_group_id = "${aws_security_group.domain_controller.id}"
  from_port         = 0
  to_port           = -1
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}
