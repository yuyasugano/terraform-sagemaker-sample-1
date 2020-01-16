provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
  version = "2.23.0"
}

module "iam" {
  source = "../modules/iam"
  aws_region = var.aws_region

  iam_name = var.iam_name
  identifier = var.identifier
}

module "s3" {
  source = "../modules/s3"

  notebook_bucket_name = var.notebook_bucket_name
  sagemaker_bucket_name = var.sagemaker_bucket_name
}

module "sagemaker" {
  source = "../modules/sagemaker"

  sagemaker_notebook_name = var.sagemaker_notebook_name
  aws_iam_role = "${module.iam.iam_role_arn}"
  bucket_name = "${module.s3.bucket_name}"
}

