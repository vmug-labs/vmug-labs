terraform {
  required_version = ">= 0.11, < 0.12"

  backend "s3" {}
}

module "global_variables" {
  source = "../../../modules/global_variables"
}

provider "vsphere" {
  version              = "~> 1.3"
  vsphere_server       = "${var.vsphere_server}"
  allow_unverified_ssl = false
  user                 = "${var.vsphere_user}"
  password             = "${var.vsphere_password}"
}

provider "random" {
  version = "~> 1.1"
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

module "nested_lab" {
  source = "../../../modules/nested_lab"

  network     = "${var.network}"
  folder      = "${var.folder}"
  domain_name = "${data.terraform_remote_state.domain_controller.domain_name}"

  ipaddresses = "${var.ipaddresses}"

  netmask = "${var.netmask}"
  gateway = "${var.gateway}"
}
