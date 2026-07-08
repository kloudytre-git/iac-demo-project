variable "project" {
  description = "Project name, used for naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs (the ALB lives here)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs (the instances live here)"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB (from the security module)"
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID for the app instances (from the security module)"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name (from the security module)"
  type        = string
}

variable "app_port" {
  description = "Port the app listens on"
  type        = number
  default     = 8080
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}