resource "aws_sagemaker_notebook_instance" "default" {
  name = var.sagemaker_notebook_name
  role_arn = var.aws_iam_role
  instance_type = "ml.t2.medium"
  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.default.name
}

data "template_file" "instance_init" {
  template = "${file("${path.module}/template/sagemaker_instance_init.sh")}"

  vars = {
    bucket_name = "${var.bucket_name}"
  }
}

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "default" {
  name = var.sagemaker_notebook_name
  on_start = "${base64encode(data.template_file.instance_init.rendered)}"
}

