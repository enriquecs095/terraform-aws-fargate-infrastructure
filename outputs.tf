output "alb_dns_name_ecs_fargate" {
  description = "The DNS name of the application load balancer"
  value       = module.fargate.alb_dns_name
}

output "url_ecs_fargate" {
  description = "The url of the dns server for the ECS Fargate tasks"
  value       =  module.fargate.url
}
