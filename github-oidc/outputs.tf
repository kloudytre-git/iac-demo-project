output "role_arn" {
  description = "ARN to paste into the workflow's role-to-assume"
  value       = aws_iam_role.github_actions.arn
}