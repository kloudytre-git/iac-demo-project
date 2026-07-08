data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  name = "${var.project}-${var.environment}"
}

# --- ALB security group: the public front door ---
resource "aws_security_group" "alb" {
  name        = "${local.name}-alb-sg"
  description = "Allow HTTP/HTTPS from the internet to the load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.name}-alb-sg"
    project     = var.project
    environment = var.environment
  }
}

# --- App security group: only reachable FROM the ALB ---
resource "aws_security_group" "app" {
  name        = "${local.name}-app-sg"
  description = "Allow traffic only from the ALB on the app port"
  vpc_id      = var.vpc_id

  ingress {
    description     = "App traffic from the ALB only"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # <-- source is the ALB's SG, not an IP
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.name}-app-sg"
    project     = var.project
    environment = var.environment
  }
}

# --- Database security group: only reachable FROM the app ---
resource "aws_security_group" "database" {
  name        = "${local.name}-db-sg"
  description = "Allow traffic only from the app tier on the DB port"
  vpc_id      = var.vpc_id

  ingress {
    description     = "DB traffic from the app tier only"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id] # <-- source is the app's SG
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.name}-db-sg"
    project     = var.project
    environment = var.environment
  }
}

# --- IAM role the EC2 instances will assume ---
resource "aws_iam_role" "instance" {
  name = "${local.name}-instance-role"

  # This says "EC2 instances are allowed to assume this role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    project     = var.project
    environment = var.environment
  }
}

# --- Scoped, least-privilege policy for that role ---
resource "aws_iam_role_policy" "instance" {
  name = "${local.name}-instance-policy"
  role = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "WriteAppLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/${var.project}/${var.environment}/*"
      },
      {
        Sid    = "ReadAppSecrets"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/${var.environment}/*"
      }
    ]
  })
}

# --- Instance profile: the wrapper that attaches the role to an EC2 instance ---
resource "aws_iam_instance_profile" "instance" {
  name = "${local.name}-instance-profile"
  role = aws_iam_role.instance.name
}