variable "vpc" {
  description = "VPC CIDR block"
  type = object({
    cidr_block   = string
    dns_support  = bool
    dns_hostname = bool
  })
}

variable "name" {
  description = "Name of the IAC"
  type        = string
}

variable "environment" {
  description = "Environment of the IAC"
  type        = string
}

variable "security_groups" {
  description = "Security groups of the IAC"
  type = list(object({
    name        = string
    description = string
    list_of_rules = list(object({
      name        = string
      description = string
      protocol    = string
      from_port   = number
      to_port     = number
      cidr_blocks = list(string)
      type        = string
    }))
  }))

}

variable "subnets" {
  description = "Subnets of the IAC"
  type = list(object({
    name              = string
    availability_zone = string
    cidr_block        = string
  }))
}


variable "load_balancer" {
  description = "Load balancer of the IAC"
  type = object({
    name               = string
    internal           = bool
    load_balancer_type = string
    subnets            = list(string)
    security_groups    = list(string)
    lb_target_group = object({
      name        = string
      port        = string
      vpc_id      = string
      protocol    = string
      target_type = string
      health_check = object({
        enable   = bool
        path     = string
        interval = number
        port     = number
        protocol = string
        matcher  = string
      })
    })
    lb_listener = list(object({
      name                = string
      port                = string
      protocol            = string
      default_action_type = string
      target_group_arn    = string
      ssl_policy          = string
      certificate_arn     = string
      redirect = list(object({
        status_code = string
        port        = number
        protocol    = string
      }))
    }))
  })
}

variable "acm_certificate" {
  description = "ACM of the IAC"
  type = object({
    name                   = string
    dns_name               = string
    validation_method      = string
    route53_record_type    = string
    ttl                    = number
    evaluate_target_health = bool
  })
}

variable "ecs_fargate" {
  description = "ECS Fargate of the IAC"
  type = object({
    ecs_cluster_name = string
    ecs_service = object({
      name          = string
      desired_count = number
      launch_type   = string
      network_configuration = object({
        security_groups  = list(string)
        subnets          = list(string)
        assign_public_ip = bool
      })
      load_balancer = object({
        container_name = string
        container_port = string
      })
    })
    task_definition = object({
      name                     = string
      family                   = string
      network_mode             = string
      requires_compatibilities = list(string)
      cpu                      = number
      memory                   = number
      container_definitions = object({
        image       = string
        cpu         = number
        memory      = number
        name        = string
        networkMode = string
        portMappings = object({
          containerPort = number
          hostPort      = number
        })
      })
      
    })
  })
}


variable "waf" {
  description = "WAF of the IAC"
  type = object({
    ip_set = object({
      name = string
    })
    waf_rule = object({
      name        = string
      metric_name = string
      negated     = bool
      type        = string
    })
    waf_acl = object({
      name           = string
      metric_name    = string
      default_action = string
      type           = string
      priority       = number
    })
  })
}

variable "devops_name" {
  description = "Name of the devops"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}
