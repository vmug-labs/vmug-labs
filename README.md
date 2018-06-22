# VMUG Labs

This project is intended to automatically provision infrastructure for VMUG events such as Hackathons.

## Getting Started

### Prerequisites

#### Software

* 1+ vCenter instance (6.5, 6.7, & [VMware Cloud on AWS account](https://cloud.vmware.com/vmc-aws) have all been tested successfully)
  * 1+ vSphere ESXi node that is managed by the above vCenter instance
  * 1 VirtuallyGhetto Nested ESXi [6.5](https://www.virtuallyghetto.com/2017/05/updated-nested-esxi-6-0u3-6-5d-virtual-appliances.html) or [6.7](https://virtuallyghetto.com/2018/04/nested-esxi-6-7-virtual-appliance-updates.html) OVA file deployed as a VM on the above ESXi node
    * This VM will be used as a VM template by Terraform for deploying the nested ESXi nodes.
    * Windows PowerShell or PowerShell Core for running the `Enable-VmVappProperties.ps1` script in the root of the project, which will set all VM vApp properties on the template VM to user configurable, which is a requirement in Terraform v0.11.7 and earlier.
    * [VMware PowerCLI 10.0+](https://powershellgallery.com/packages/VMware.PowerCLI)
* [HashiCorp Terraform v0.11.x](https://www.terraform.io/)
* [Gruntwork Terragrunt v0.14.x](https://www.gruntwork.io/)
* An [AWS S3 bucket](https://aws.amazon.com/s3/) for [Terraform remote backend state storage](https://www.terraform.io/intro/getting-started/remote.html)
* An [AWS DynamoDB database](https://aws.amazon.com/dynamodb/) for [Terraform state lock management](https://www.terraform.io/docs/state/locking.html)
* An [IAM AWS Access Key](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) for programmatic remote access to your AWS account
  * These should be stored in a [profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html) in your `~/.aws/credentials` file.
* An [EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) for credential encryption/decryption

### Prepare the Template nested ESXi VM

* Run the following, where `$vCenter` is the prerequisite vCenter instance, and `$name` is the name of the prerequisite VirtuallyGhetto Nested ESXi 6.5 or 6.7 VM
    ```powershell
    Connect-VIServer -Server $vCenter
    ./Enable-VmVappProperties.ps1 -Name $name
    ```

### Configure Terraform

* Copy all `terraform.tfvars.example` files in the project to `terraform.tfvars` files
  * Note: Terraform `tfvars` files tend to contain sensitive information, and should not be checked into source control, which is why there is an entry for this in the `.gitignore` file.
* Update all values in each `tfvars` file per your environment.

### Init, Plan, Apply, & Destroy

* `terragrunt init`: This will initialize your environment, including: download all terraform modules necessary, create the S3 bucket for storing remote state, create the DynamoDB table for lock management.
* `terragrunt plan`: This will analyze the state of your environment, and list what components need to be deployed, modified, and/or destroyed.
* `terragrunt apply`: If approved, this will deploy the environment per your specifications.
* `terragrunt destroy`: If approved, this will tear down the environment when your done.
