locals {
  name = "${var.project}-${var.environment}"
}

# Find the latest Amazon Linux 2023 AMI so we don't hardcode an ID
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- Application Load Balancer (in the public subnets) ---
resource "aws_lb" "this" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name        = "${local.name}-alb"
    project     = var.project
    environment = var.environment
  }
}

# --- Target group (the pool of instances the ALB sends traffic to) ---
resource "aws_lb_target_group" "this" {
  name     = "${local.name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }

  tags = {
    Name        = "${local.name}-tg"
    project     = var.project
    environment = var.environment
  }
}

# --- Listener: forward port 80 traffic to the target group ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# --- Launch template: the blueprint for each instance ---
resource "aws_launch_template" "this" {
  name_prefix   = "${local.name}-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = [var.app_security_group_id]

  # Startup script: install a tiny web server that reports its hostname
  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y httpd
    sed -i 's/^Listen 80/Listen ${var.app_port}/' /etc/httpd/conf/httpd.conf
    echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
    systemctl enable httpd
    systemctl start httpd
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${local.name}-instance"
      project     = var.project
      environment = var.environment
    }
  }
}

# --- Auto Scaling Group (launches instances in the private subnets) ---
resource "aws_autoscaling_group" "this" {
  name                = "${local.name}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.this.arn]

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-asg"
    propagate_at_launch = true
  }
}

# --- Scaling policy: add/remove instances to hold CPU around 50% ---
resource "aws_autoscaling_policy" "cpu" {
  name                   = "${local.name}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}