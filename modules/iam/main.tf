resource "aws_iam_role" "default" {
  name = var.iam_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [var.identifier]
    }
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

resource "aws_iam_policy" "default" {
  name = var.iam_name
  path = "/"
  description = "Policy for the Notebook Instance to manage training jobs, models and endpoints"
  policy = data.aws_iam_policy_document.sagemaker_role_policy.json
}

data "aws_iam_policy_document" "sagemaker_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetBucketCors",
      "s3:PutBucketCors"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sagemaker:CreateTrainingJob",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:CreateModel",
      "sagemaker:DescribeModel",
      "sagemaker:DeleteModel",
      "sagemaker:CreateEndpoint",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:DescribeEndpoint",
      "sagemaker:DescribeEndpointConfig",
      "sagemaker:DeleteEndpoint"
    ]
    resources = [
      "arn:aws:sagemaker:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateVpcEndpoint",
      "ec2:DescribeRouteTables"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics"
    ]
    resources = [
      "arn:aws:cloudwatch:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/sagemaker/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "${aws_iam_role.default.arn}"
    ]
    condition {
      test = "StringEquals"
      variable = "iam:PassedToService"
      values = ["sagemaker.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    actions = ["iam:GetRole"]
    resources = [
      "${aws_iam_role.default.arn}"
    ]
  }
}

