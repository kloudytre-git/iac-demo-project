variable "project" {
  description = "Project name, used for naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the security groups live in"
  type        = string
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Port the database listens on (5432 = Postgres, 3306 = MySQL)"
  type        = number
  default     = 5432
}