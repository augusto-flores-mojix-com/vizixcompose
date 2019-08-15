# Terraform for Azure
---
Now you can deploy instances according to the [sizing guideline][sizing].
# Requirements:
  - [Terraform 0.11.3 or higher][terraform] or later
# Usage
To use it create a directory, then a file with the following content:
```sh
module "azure" {
  source                 = "git@github.com:tierconnect/vizix-compose.git//terraform/azure/m"
  azure_subscription_id  = "d25..."
  azure_client_id        = "55b..."
  azure_client_secret    = "cdf..."
  azure_tenant_id        = "a1a..."
  resource_group_name    = "terraform.test.io"
  public_key_path        = "~/.ssh/id_rsa.pub"
}
output "public_ip" {
  description = "Public IPs of Instances"
  value = "${module.azure.vizix_mojix_hosts}"
}
output "itermocil" {
  description = "Itermocil File Content"
  value = "${module.azure.itermocil}"
}

```
Change the source for different sizes:
#### XS
```
  source                 = "git@github.com:tierconnect/vizix-compose.git//terraform/azure/xs"
```
#### S
```
  source                 = "git@github.com:tierconnect/vizix-compose.git//terraform/azure/s"
```
#### M
```
  source                 = "git@github.com:tierconnect/vizix-compose.git//terraform/azure/m"
```
#### L
```
  source                 = "git@github.com:tierconnect/vizix-compose.git//terraform/azure/l"
```

After this, initialize the terraform environment with terraform init, you should have a similar output like this one:
```sh
$ terraform init

Initializing modules...
- module.azure

Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.azurerm: version = "~> 1.6"

Terraform has been successfully initialized!
```
Run terraform plan if you want to review it, or run terraform apply to create it:
```sh
$ terraform apply
```
After the command runs successfully the servers are up.
Enjoy!
And if you aren't enjoying and want to delete the servers, run terraform destroy:
```sh
$ terraform destroy
```
## FAQ
- I want a itermocil file to connect with ease.
-- At the end of the run, there's an output named itermocil, copy the content, create and share the file, replace it with the KEYNAME and you're done
```sh
Apply complete! Resources: 30 added, 0 changed, 0 destroyed.

Outputs:

itermocil =
windows:
  - name: terraform.test.io
    root: ~/Dropbox*/Ke*/
    layout: main-vertical
    panes:
      - ssh -i KEYNAME.pem vizix@40.121.15.236
      - ssh -i KEYNAME.pem vizix@40.121.12.241
      - ssh -i KEYNAME.pem vizix@40.121.9.47
      - ssh -i KEYNAME.pem vizix@40.121.13.240
```

- My terraform apply failed! What should I do?
-- Run it again, it will create the remaining items.

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [sizing]: <https://docs.google.com/presentation/d/1KTHAY7cD_q7q6Yn9Mt2KaIdKiOxYopDIcLrtNoYZjP4/edit#slide=id.g3bb605f2ca_2_75>
   [terraform]: <https://www.terraform.io/>
