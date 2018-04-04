variable "network" {
  description = "Specifies the logical network for the virtual machines."
}

variable "template" {
  description = "Specifies the VM template name."
  default     = "Nested_ESXi6.5u1_Appliance_Template_v1.0"
}

variable "folder" {
  description = "The path to the folder to put this virtual machine in, relative to the datacenter that the resource pool is in."
}

variable "random_password" {
  description = "Specifies whether to generate a random password for the hosts."
  default     = false
}

variable "default_password" {
  description = "Specifies the default password for the hosts if var.random_password == false."
  default     = "VMware1!"
}

variable "domain_name" {
  description = "Specifies the DNS domain name."
}

variable "ipaddresses" {
  description = "One ESXi host VM will be provisioned for each IPv4 address entered.  Defaults to one instance configured for DHCP."
  type        = "list"
  default     = [""]
}

variable "netmask" {
  description = "Specifies the netmask."
  default     = ""
}

variable "gateway" {
  description = "Specifies the default gateway."
  default     = ""
}

variable "vlan" {
  description = "Specifies the VLAN ID of vmk0."
  default     = ""
}

variable "dns_server" {
  description = "Specifies the primary DNS server."
  default     = "8.8.8.8"
}

variable "ntp_server" {
  description = "Specifies the NTP server."
  default     = "pool.ntp.org"
}

variable "syslog" {
  description = "Specifies the remote syslog server."
  default     = ""
}

variable "ssh" {
  description = "Enable SSH."
  default     = "True"
}

variable "createvmfs" {
  description = "Format the secondary disks as datastores."
  default     = "False"
}

variable "debug" {
  description = "Enable debug mode."
  default     = "False"
}
