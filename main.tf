module "fargate" {
  source      = "./modules"
  name        = var.name
  environment = var.environment
  ecs_fargate = var.ecs_fargate
  vpc = var.vpc
  subnets = var.subnets
  security_groups = var.security_groups
  load_balancer = var.load_balancer
  acm_certificate = var.acm_certificate
  waf = var.waf
  devops_name  = var.devops_name
  project_name = var.project_name
}
