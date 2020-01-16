resource "aws_s3_bucket" "notebook" {
  bucket = var.notebook_bucket_name
  force_destroy = true
  acl = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "sagemaker" {
  bucket = var.sagemaker_bucket_name
  force_destroy = true
  acl = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_object" "notebook" {
  bucket = aws_s3_bucket.notebook.id
  key = "sagemaker/sample/notebooks/Scikit-learn_Estimator_Example_With_Terraform.ipynb"
  source = "${path.module}/../../source/notebooks/Scikit-learn_Estimator_Example_With_Terraform.ipynb"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = "${filemd5("${path.module}/../../source/notebooks/Scikit-learn_Estimator_Example_With_Terraform.ipynb")}"
}

resource "aws_s3_bucket_object" "script" {
  bucket = aws_s3_bucket.notebook.id
  key = "sagemaker/sample/scripts/scikit_learn_script.py"
  source = "${path.module}/../../source/scripts/scikit_learn_script.py"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = "${filemd5("${path.module}/../../source/scripts/scikit_learn_script.py")}"
}

