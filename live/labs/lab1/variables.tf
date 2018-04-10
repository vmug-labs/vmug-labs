variable "vsphere_server" {
  description = "Specifies the IP address or the DNS name of the vSphere server to which you want to connect."
}

variable "vsphere_user" {
  description = "Specifies the user name you want to use for authenticating with the server."
}

variable "vsphere_password" {
  description = "Specifies the password you want to use for authenticating with the server."
}

variable "folder" {
  description = "Specifies the name of the VM folder that will be created."
}

variable "network" {
  description = "Specifies the name of the logical network."
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

variable "dns_server" {
  description = "Specifies the primary DNS server."
  default     = "8.8.8.8"
}
