output "alb_security_group_id" {
  description = "Security group ID for the load balancer"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID for the app tier"
  value       = aws_security_group.app.id
}

output "database_security_group_id" {
  description = "Security group ID for the database tier"
  value       = aws_security_group.database.id
}

output "instance_profile_name" {
  description = "Name of the instance profile for EC2 instances"
  value       = aws_iam_instance_profile.instance.name
}