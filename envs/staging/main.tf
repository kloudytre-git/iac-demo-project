module "networking" {
  source = "../../modules/networking"

  project     = var.project
  environment = var.environment

  vpc_cidr             = "10.1.0.0/16"                    # <-- CHANGED (dev was 10.0.0.0/16)
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]   # <-- CHANGED
  private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"] # <-- CHANGED
}

module "security" {
  source = "../../modules/security"

  project     = var.project
  environment = var.environment
  vpc_id      = module.networking.vpc_id

  app_port = 8080
  db_port  = 5432
}

module "compute" {
  source = "../../modules/compute"

  project     = var.project
  environment = var.environment

  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  alb_security_group_id = module.security.alb_security_group_id
  app_security_group_id = module.security.app_security_group_id
  instance_profile_name = module.security.instance_profile_name

  app_port         = 8080
  instance_type    = "t3.micro"
  min_size         = 1 # <-- optional: staging smaller/cheaper
  max_size         = 2
  desired_capacity = 1
}

module "database" {
  source = "../../modules/database"

  project     = var.project
  environment = var.environment

  private_subnet_ids         = module.networking.private_subnet_ids
  database_security_group_id = module.security.database_security_group_id

  db_name     = "appdb"
  db_username = "appadmin"
  db_port     = 5432
}