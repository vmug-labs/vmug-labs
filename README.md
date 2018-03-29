# VMUG Labs

This project is intended to automatically provision infrastructure for VMUG events such as Hackathons.

## Getting Started

### Prerequisites

#### Software

* A [VMware Cloud on AWS account](https://cloud.vmware.com/vmc-aws) with administrative rights
* [HashiCorp Terraform v0.11.x](https://www.terraform.io/)
* [Gruntwork Terragrunt v0.14.x](https://www.gruntwork.io/)
* An [AWS S3 bucket](https://aws.amazon.com/s3/) for [Terraform remote backend state storage](https://www.terraform.io/intro/getting-started/remote.html)
* An [AWS DynamoDB database](https://aws.amazon.com/dynamodb/) for [Terraform state lock management](https://www.terraform.io/docs/state/locking.html)
