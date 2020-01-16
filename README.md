## Machine Learning Infrastructure with Terraform

This example show how to set up end to end demo architecture for predicting boston housing dataset with Machine Learning using `Amazon SageMaker` and `Terraform`. 

## Terraform version

Ensure your `Terraform` version is as follows (some modifications would be required if you run other `Terraform` versions):
```sh
$ cd main
$ terraform --version
Terraform v0.12.6
+ provider.aws v2.23.0
+ provider.template v2.1.2
```
To download `Terraform`, visit https://releases.hashicorp.com/terraform/

## Setup steps

From `terraform` folder:
1. Copy `terraform_backend.tf.template` to `terraform_backend.tf` and modify values accordingly. You need to manually create an S3 bucket or use an existing one to store the Terraform state file.
2. Copy `terraform.tfvars.template` to `terraform.tfvars` and modify input variables accordingly. You don't need to create any buckets specified in here, they're to be created by terraform apply.
3. Run the followings:
```sh
export AWS_PROFILE=<your desired profile>

terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Clean up

```
terraform plan -destroy -var-file=terraform.tfvars
terraform destroy -var-file=terraform.tfvars
```

## License

This library is licensed under the Apache 2.0 License.
