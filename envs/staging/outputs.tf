output "alb_url" {
  description = "Visit this in your browser"
  value       = "http://${module.compute.alb_dns_name}"
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_endpoint
}