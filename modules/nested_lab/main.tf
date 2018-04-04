data "vsphere_datacenter" "dc" {
  name = "SDDC-Datacenter"
}

data "vsphere_resource_pool" "pool" {
  name          = "Compute-ResourcePool"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "datastore" {
  name          = "WorkloadDatastore"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_distributed_virtual_switch" "dvs" {
  name          = "vmc-dvs"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "random_integer" "length" {
  min = 16
  max = 32
}

resource "random_string" "password" {
  length  = "${random_integer.length.result}"
  upper   = true
  lower   = true
  number  = true
  special = true
}

resource "vsphere_folder" "folder" {
  path          = "Workloads/${var.folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  count = "${length(var.ipaddresses)}"

  name     = "ESX${count.index + 1}"
  guest_id = "vmkernel65Guest"

  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "Workloads/${var.folder}"

  num_cpus = 2
  memory   = 6144

  wait_for_guest_net_timeout = 0

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label            = "sda"
    unit_number      = 0
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  disk {
    label            = "sdb"
    unit_number      = 1
    size             = "${data.vsphere_virtual_machine.template.disks.1.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.1.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.1.thin_provisioned}"
  }

  disk {
    label            = "sdc"
    unit_number      = 2
    size             = "${data.vsphere_virtual_machine.template.disks.2.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.2.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.2.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  vapp {
    properties {
      "guestinfo.hostname"   = "esx${count.index + 1}.${var.domain_name}"
      "guestinfo.ipaddress"  = "${element(var.ipaddresses, count.index)}"
      "guestinfo.netmask"    = "${var.netmask}"
      "guestinfo.gateway"    = "${var.gateway}"
      "guestinfo.vlan"       = "${var.vlan}"
      "guestinfo.dns"        = "${var.dns_server}"
      "guestinfo.domain"     = "${var.domain_name}"
      "guestinfo.ntp"        = "${var.ntp_server}"
      "guestinfo.syslog"     = "${var.syslog}"
      "guestinfo.password"   = "${var.random_password ? random_string.password.result : var.default_password}"
      "guestinfo.ssh"        = "${var.ssh}"
      "guestinfo.createvmfs" = "${var.createvmfs}"
      "guestinfo.debug"      = "${var.debug}"
    }
  }

  lifecycle {
    ignore_changes = [
      "annotation",
      "vapp.0.properties",
    ]
  }

  depends_on = ["vsphere_folder.folder"]
}
