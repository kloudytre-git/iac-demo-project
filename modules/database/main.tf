locals {
  name = "${var.project}-${var.environment}"
}

# --- Generate a strong random password (never typed or hardcoded) ---
resource "random_password" "db" {
  length  = 20
  special = true
  # RDS disallows / @ " and spaces in passwords, so restrict the special set
  override_special = "!#$%^&*()-_=+[]{}"
}

# --- Store it as an encrypted SecureString in SSM Parameter Store ---
# Path matches the IAM policy from Phase 4, so instances can read it.
resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.project}/${var.environment}/db/password"
  description = "Database master password"
  type        = "SecureString"
  value       = random_password.db.result

  tags = {
    project     = var.project
    environment = var.environment
  }
}

# --- Store non-secret connection details too, so the app reads everything from SSM ---
resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.project}/${var.environment}/db/host"
  type  = "String"
  value = aws_db_instance.this.address

  tags = {
    project     = var.project
    environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.project}/${var.environment}/db/name"
  type  = "String"
  value = var.db_name

  tags = {
    project     = var.project
    environment = var.environment
  }
}

# --- DB subnet group: tells RDS which subnets it may live in ---
resource "aws_db_subnet_group" "this" {
  name       = "${local.name}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${local.name}-db-subnets"
    project     = var.project
    environment = var.environment
  }
}

# --- The RDS instance itself ---
resource "aws_db_instance" "this" {
  identifier     = "${local.name}-db"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result
  port     = var.db_port

  allocated_storage = var.allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.database_security_group_id]

  multi_az            = false # single-AZ for dev to save cost
  publicly_accessible = false # never reachable from the internet

  # Dev-friendly settings so teardown is clean and fast
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name        = "${local.name}-db"
    project     = var.project
    environment = var.environment
  }
}