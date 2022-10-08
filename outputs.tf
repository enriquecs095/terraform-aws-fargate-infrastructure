output "alb_dns_name_ec2" {
  description = "The DNS name of the application load balancer for the EC2 instances"
  value       = module.timeoff_ec2.alb_dns_name
}

output "url_ec2" {
  description = "The url of the dns server for the EC2 instances"
  value       =  module.timeoff_ec2.url
}

output "alb_dns_name_ecs_fargate" {
  description = "The DNS name of the application load balancer for the ECS Fargate tasks"
  value       = module.timeofffargate.alb_dns_name
}

output "url_ecs_fargate" {
  description = "The url of the dns server for the ECS Fargate tasks"
  value       =  module.timeofffargate.url
}

output "alb_dns_name_ecs" {
  description = "The DNS name of the application load balancer for the ECS instances"
  value       = module.timeoffecs.alb_dns_name
}

output "url_ecs" {
  description = "The url of the dns server for the ECS instances"
  value       =  module.timeoffecs.url
}