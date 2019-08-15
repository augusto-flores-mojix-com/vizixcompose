# ViZix in a Box maker

These scripts combine Packer and the cloud installation files for ViZix to generate a Vagrant image that's easy to import and manage for non-technical people. It's destined for demos and quick POCs.

> Due to general constraints virtualizing software, ViZix in a box is highly discouraged for production usage.

## Implementation

It all starts with Packer virtualizing Ubuntu Xenial from the official ISO; from there, Packer reuses the bootstrap scripts and files found on the root folder (`provision.sh`, `launch.sh`, `docker-compose.yml`, etc.) to build a ViZix image almost identical to a ViZix cloud installation.

To avoid installing all dependencies and generate the image locally, we are leveraging Terraform to generate the box on a Packet host. This allows us to use excellent network speed, use all the host resources and take advantage of Packet's 

So in simple steps, the implementation goes like this:

1. Terraform launches a Type-1 Packet host
2. Virtualbox, Packer and Vagrant are installed
3. All needed files are copied from this repository to the newly created host
4. Packer validates the configuration
5. Packer builds the ViZix image from scratch
6. The image is exported as a Vagrant box file
7. The box file is uploaded to Amazon S3
8. Terraform destroy the host to avoid extra-charges

## Building a Box

Clone the repository and go to the `packer/terraform` folder:

	$ cd packer/terraform

Copy the `sample.terraform.tfvars` to `terraform.tfvars`

	$ cp sample.terraform.tfvars terraform.tfvars
	
Edit `terraform.tfvars` with the Packer API key, Docker Hub credentials, ViZix version and Amazon keys.

```hcl
packet_api_key = ""
packet_project_id = ""
aws_access_key = ""
aws_secret_key = ""
vizix_version = ""
docker_hub_username = ""
docker_hub_password = ""
```

Execute the plan command to verify state:

	$ terraform plan
	
Launch the machine:

	$ terraform apply
	
This process takes around 25 minutes and it pushes the resulting box to Amazon S3.

Destroy the machine once the build process is completed:

	$ terraform destroy -force
	
Profit!