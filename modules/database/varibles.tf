variable "project" {
  description = "Project name, used for naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs the database is allowed to live in"
  type        = list(string)
}

variable "database_security_group_id" {
  description = "Security group ID for the database (from the security module)"
  type        = string
}

variable "db_name" {
  description = "Name of the initial database"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "appadmin"
}

variable "db_port" {
  description = "Database port (5432 = Postgres)"
  type        = number
  default     = 5432
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage in GB (free tier allows up to 20)"
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
}