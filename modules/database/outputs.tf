output "db_endpoint" {
  description = "Connection endpoint (host:port)"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "Database hostname"
  value       = aws_db_instance.this.address
}

output "db_name" {
  description = "Initial database name"
  value       = var.db_name
}

output "db_password_ssm_parameter" {
  description = "SSM parameter name where the password is stored"
  value       = aws_ssm_parameter.db_password.name
}