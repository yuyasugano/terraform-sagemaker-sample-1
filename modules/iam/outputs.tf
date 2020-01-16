output "iam_role_arn" {
  value = aws_iam_role.default.arn
}

output "iam_role_name" {
  value = aws_iam_role.default.name
}

output "policy_attachment_id" {
  value = aws_iam_role_policy_attachment.default.id
}

