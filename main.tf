module "timeoff_ec2" {
  source      = "./modules/timeoffec2"
  name        = "timeoffec2"
  environment = var.environment
  providers = {
    aws = aws.main_region
  }

  vpc = {
    cidr_block   = "10.0.0.0/16"
    dns_support  = true
    dns_hostname = true
  }
  subnets = [
    {
      name              = "subnet_1"
      availability_zone = "us-east-1a"
      cidr_block        = "10.0.1.0/24"
    },
    {
      name              = "subnet_2"
      availability_zone = "us-east-1b"
      cidr_block        = "10.0.2.0/24"
    }
  ]
  security_groups = [
    {
      name        = "sg_load_balancer_1"
      description = "Security group for load balancer"
      list_of_rules = [
        {
          name        = "ingress_rule_1"
          description = "Allow inbound trafic from anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "ingress"
        },
        {
          name        = "egress_rule_1"
          description = "Allow outbound trafic to anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "egress"
        }
      ]
    },
    {
      name        = "sg_asg_1"
      description = "Security group for instances"
      list_of_rules = [
        {
          name        = "ingress_rule_3"
          description = "Allow inbound trafic from anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "ingress"
        },
        {
          name        = "egress_rule_4"
          description = "Allow outbound trafic to anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "egress"
        }
      ]
    },
  ]
  load_balancer = {
    name               = "lb-1"
    internal           = false
    load_balancer_type = "application"
    subnets = [
      "subnet_1",
      "subnet_2"
    ]
    security_groups = [
      "sg_load_balancer_1"
    ]
    lb_target_group = {
      name     = "tg-1"
      port     = "3000"
      vpc_id   = "vpc_1"
      protocol = "HTTP"
      health_check = {
        enable   = true
        path     = "/"
        interval = 10
        port     = 3000
        protocol = "HTTP"
        matcher  = "200-299"
      }
    }
    lb_listener = [
      {
        name                = "lb_l_1"
        port                = "80"
        protocol            = "HTTP"
        default_action_type = "redirect"
        target_group_arn    = null
        ssl_policy          = null
        certificate_arn     = null
        redirect = [
          {
            status_code = "HTTP_301"
            port        = 443
            protocol    = "HTTPS"
          }
        ]
      },
      {
        name                = "lb_l_2"
        port                = "443"
        protocol            = "HTTPS"
        default_action_type = "forward"
        target_group_arn    = "tg-1"
        ssl_policy          = "ELBSecurityPolicy-2016-08"
        certificate_arn     = "acm_1"
        redirect            = []
      },

    ]
  }
  asg = {
    launch_template = {
      name            = "launch_template_1"
      instance_type   = "t3.medium"
      key_pair        = var.key_pair
      ami_name        = "amzn2-ami-hvm-*-x86_64-gp2"
      security_groups = ["sg_asg_1"]
      user_data       = "commands_scripts/commands_timeoff.sh"
    }
    autoscaling_group = {
      name                = "autoscaling_group_1"
      desired_capacity    = 2
      max_size            = 6
      min_size            = 1
      vpc_zone_identifier = ["subnet_1", "subnet_2"]
    }
  }
  acm_certificate = {
    name                   = "acm_1"
    dns_name               = "opstestings.me."
    validation_method      = "DNS"
    route53_record_type    = "A"
    ttl                    = 60
    evaluate_target_health = true
  }

  waf = {
    ip_set = {
      name = "ipset_1"
    }
    waf_rule = {
      name        = "wafrule1"
      metric_name = "wafrule1"
      negated     = false
      type        = "IPMatch"
    }
    waf_acl = {
      name           = "wafacl1"
      metric_name    = "wafacl1"
      default_action = "ALLOW"
      type           = "BLOCK"
      priority       = 1
    }
  }
  devops_name  = "Enrique"
  project_name = "timeoff_ec2"
}

module "timeofffargate" {
  source      = "./modules/timeofffargate"
  name        = "timeofffargate"
  environment = var.environment
  providers = {
    aws = aws.main_region
  }

  ecs_fargate = {
    ecs_cluster_name = "ecs_main_cluster_1"
    ecs_service = {
      name          = "ecs_service_1"
      desired_count = 2
      launch_type   = "FARGATE"
      network_configuration = {
        security_groups  = ["sg_fargate_2"]
        subnets          = ["subnet_3", "subnet_4"]
        assign_public_ip = true
      }
      load_balancer = {
        container_name = "node_app_1"
        container_port = "3000"
      }
    }
    task_definition = {
      name                     = "fargate_1"
      family                   = "node_app_1"
      network_mode             = "awsvpc"
      requires_compatibilities = ["FARGATE"]
      cpu                      = 1024
      memory                   = 4096
      container_definitions = {
        image       = "public.ecr.aws/w3w5l3i9/app-image:e9cae383"
        cpu         = 1024
        memory      = 4096
        name        = "node_app_1"
        networkMode = "awsvpc"
        portMappings = {
          containerPort = 3000
          hostPort      = 3000
        }
      }
    }
  }

  vpc = {
    cidr_block   = "10.1.0.0/16"
    dns_support  = true
    dns_hostname = true
  }
  subnets = [
    {
      name              = "subnet_3"
      availability_zone = "us-east-1a"
      cidr_block        = "10.1.1.0/24"
    },
    {
      name              = "subnet_4"
      availability_zone = "us-east-1b"
      cidr_block        = "10.1.2.0/24"
    }
  ]
  security_groups = [
    {
      name        = "sg_load_balancer_2"
      description = "Security group for load balancer"
      list_of_rules = [
        {
          name        = "ingress_rule_3"
          description = "Allow inbound trafic from anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "ingress"
        },
        {
          name        = "egress_rule_2"
          description = "Allow outbound trafic to anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "egress"
        }
      ]
    },
    {
      name        = "sg_fargate_2"
      description = "Security group for instances"
      list_of_rules = [
        {
          name        = "ingress_rule_4"
          description = "Allow inbound trafic from anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "ingress"
        },
        {
          name        = "egress_rule_3"
          description = "Allow outbound trafic to anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "egress"
        }
      ]
    },
  ]
  load_balancer = {
    name               = "lb-2"
    internal           = false
    load_balancer_type = "application"
    subnets = [
      "subnet_3",
      "subnet_4"
    ]
    security_groups = [
      "sg_load_balancer_2"
    ]
    lb_target_group = {
      name        = "tg-2"
      port        = "3000"
      vpc_id      = "vpc_2"
      protocol    = "HTTP"
      target_type = "ip"
      health_check = {
        enable   = true
        path     = "/"
        interval = 10
        port     = 3000
        protocol = "HTTP"
        matcher  = "200-299"
      }
    }
    lb_listener = [
      {
        name                = "lb_l_3"
        port                = "80"
        protocol            = "HTTP"
        default_action_type = "redirect"
        target_group_arn    = null
        ssl_policy          = null
        certificate_arn     = null
        redirect = [
          {
            status_code = "HTTP_301"
            port        = 443
            protocol    = "HTTPS"
          }
        ]
      },
      {
        name                = "lb_l_4"
        port                = "443"
        protocol            = "HTTPS"
        default_action_type = "forward"
        target_group_arn    = "tg-2"
        ssl_policy          = "ELBSecurityPolicy-2016-08"
        certificate_arn     = "acm_2"
        redirect            = []
      },

    ]
  }

  acm_certificate = {
    name                   = "acm_2"
    dns_name               = "opstestings.me."
    validation_method      = "DNS"
    route53_record_type    = "A"
    ttl                    = 60
    evaluate_target_health = true
  }

  waf = {
    ip_set = {
      name = "ipset_2"
    }
    waf_rule = {
      name        = "wafrule2"
      metric_name = "wafrule2"
      negated     = false
      type        = "IPMatch"
    }
    waf_acl = {
      name           = "wafacl2"
      metric_name    = "wafacl2"
      default_action = "ALLOW"
      type           = "BLOCK"
      priority       = 1
    }
  }
  devops_name  = "Enrique"
  project_name = "timeoff_fargate"
}

module "timeoffecs" {
  source      = "./modules/timeoffecs"
  name        = "timeoffecs"
  environment = var.environment
  providers = {
    aws = aws.main_region
  }

  vpc = {
    cidr_block   = "10.2.0.0/16"
    dns_support  = true
    dns_hostname = true
  }
  subnets = [
    {
      name              = "subnet_5"
      availability_zone = "us-east-1a"
      cidr_block        = "10.2.1.0/24"
    },
    {
      name              = "subnet_6"
      availability_zone = "us-east-1b"
      cidr_block        = "10.2.2.0/24"
    }
  ]
  security_groups = [
    {
      name        = "sg_load_balancer_5"
      description = "Security group for load balancer"
      list_of_rules = [
        {
          name        = "ingress_rule_5"
          description = "Allow inbound trafic from anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "ingress"
        },
        {
          name        = "egress_rule_4"
          description = "Allow outbound trafic to anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "egress"
        }
      ]
    },
    {
      name        = "sg_asg_6"
      description = "Security group for instances"
      list_of_rules = [
        {
          name        = "ingress_rule_6"
          description = "Allow inbound trafic from anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "ingress"
        },
        {
          name        = "egress_rule_5"
          description = "Allow outbound trafic to anywhere"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          type        = "egress"
        }
      ]
    },
  ]
  load_balancer = {
    name               = "lb-3"
    internal           = false
    load_balancer_type = "application"
    subnets = [
      "subnet_5",
      "subnet_6"
    ]
    security_groups = [
      "sg_load_balancer_5"
    ]
    lb_target_group = {
      name     = "tg-3"
      port     = "3000"
      vpc_id   = "vpc_3"
      protocol = "HTTP"
      health_check = {
        enable   = true
        path     = "/"
        interval = 10
        port     = 3000
        protocol = "HTTP"
        matcher  = "200-299"
      }
    }
    lb_listener = [
      {
        name                = "lb_l_5"
        port                = "80"
        protocol            = "HTTP"
        default_action_type = "redirect"
        target_group_arn    = null
        ssl_policy          = null
        certificate_arn     = null
        redirect = [
          {
            status_code = "HTTP_301"
            port        = 443
            protocol    = "HTTPS"
          }
        ]
      },
      {
        name                = "lb_l_6"
        port                = "443"
        protocol            = "HTTPS"
        default_action_type = "forward"
        target_group_arn    = "tg-3"
        ssl_policy          = "ELBSecurityPolicy-2016-08"
        certificate_arn     = "acm_certificate_1"
        redirect            = []
      },

    ]
  }
  asg = {
    launch_template = {
      name            = "launch_template_2"
      instance_type   = "t3.medium"
      key_pair        = var.key_pair
      ami_name        = "amzn2-ami-hvm-*-x86_64-gp2"
      security_groups = ["sg_asg_6"]
      user_data       = "commands_scripts/commands_timeoff.sh"
    }
    autoscaling_group = {
      name                    = "autoscaling_group_2"
      desired_capacity        = 2
      max_size                = 6
      min_size                = 1
      vpc_zone_identifier     = ["subnet_5", "subnet_6"]
      protected_from_scale_in = true
    }
  }
  acm_certificate = {
    name                   = "acm_3"
    dns_name               = "opstestings.me."
    validation_method      = "DNS"
    route53_record_type    = "A"
    ttl                    = 60
    evaluate_target_health = true
  }

  ecs = {
    cluster_name = "cluster_1"
    task_definition = {
      family = "ecs_1"
      container_definitions = {
        image     = "public.ecr.aws/w3w5l3i9/app-image:e9cae383"
        essential = true
        cpu       = 2
        memory    = 512
        name      = "node_app_2"
        portMappings = {
          containerPort = 3000
          hostPort      = 3000
        }
      }

    }

    ecs_service = {
      name          = "cluster_service_1"
      desired_count = 2
    }
  }

  waf = {
    ip_set = {
      name = "ipset_3"
    }
    waf_rule = {
      name        = "wafrule3"
      metric_name = "wafrule3"
      negated     = false
      type        = "IPMatch"
    }
    waf_acl = {
      name           = "wafacl3"
      metric_name    = "wafacl3"
      default_action = "ALLOW"
      type           = "BLOCK"
      priority       = 1
    }
  }
  devops_name  = "Enrique"
  project_name = "timeoff_ecs"

}

