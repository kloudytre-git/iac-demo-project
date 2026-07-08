module "networking" {
  source = "../../modules/networking"

  project     = var.project
  environment = var.environment

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "security" {
  source = "../../modules/security"

  project     = var.project
  environment = var.environment
  vpc_id      = module.networking.vpc_id

  app_port = 8080
  db_port  = 5432
}