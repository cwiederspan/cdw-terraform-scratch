# Setup Up the Azure Resources

## Create a Service Principal

```bashrc

az ad sp create-for-rbac -n "cdw_dns_validation_20210609"

```

## Terraform Init

```bash

# Use remote storage
terraform init

```

## Terraform Plan and Apply

```bash

# Apply the script with the specified variable values
terraform apply \
-var 'root_dns_name=apimdemo.com' \
-var 'dns_resource_group=cdw-apimdemo-20210608' \
-var 'contact_email=chwieder@microsoft.com' \
--var-file=secrets.tfvars

```
