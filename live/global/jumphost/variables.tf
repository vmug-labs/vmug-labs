variable "aws_profile" {
  description = "Specifies the AWS credential profile."
}

variable "aws_region" {
  description = "Specifies the AWS region."
  default     = "us-west-2"
}

variable "instance_type" {
  description = "Specifies the AWS EC2 Instance Type."
  default     = "t2.micro"
}

variable "key_name" {
  description = "Specifies the AWS EC2 Key Pair name."
}
