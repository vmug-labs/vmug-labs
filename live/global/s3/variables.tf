variable "aws_profile" {
  description = "Specifies the AWS credential profile."
}

variable "aws_region" {
  description = "Specifies the AWS region."
  default     = "us-west-2"
}

variable "aws_s3_bucket" {
  description = "Specifies the name of the AWS S3 bucket that stores the terraform remote state."
}
