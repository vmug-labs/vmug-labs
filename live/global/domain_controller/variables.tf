variable "instance_type" {
  description = "Specifies the AWS EC2 Instance Type."
  default     = "t2.micro"
}
  default = {
    ap-northeast-1 = "ami-6ccf9d0a"
    ap-northeast-2 = "ami-ece04f82"
    ap-south-1     = "ami-cabde6a5"
    ap-southeast-1 = "ami-b294cbce"
    ap-southeast-2 = "ami-058a4667"
    ca-central-1   = "ami-d5fd7bb1"
    eu-central-1   = "ami-29c192c2"
    eu-west-1      = "ami-2316475a"
    eu-west-2      = "ami-9c6b8dfb"
    eu-west-3      = "ami-7225930f"
    sa-east-1      = "ami-9ede8af2"
    us-east-1      = "ami-ed14c790"
    us-east-2      = "ami-8e1627eb"
    us-west-1      = "ami-6d04120d"
    us-west-2      = "ami-8b1886f3"
  }
}

variable "instance_type" {
  description = "Specifies the AWS EC2 Instance Type."
  default     = "t2.micro"
}

variable "domain_name" {
  description = "Specifies the Active Directory DNS domain name."
}

variable "domain_netbios_name" {
  description = "Specifies the Active Directory NetBIOS domain name."
}
