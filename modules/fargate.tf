resource "aws_ecs_cluster" "main" {
  name = "${var.ecs_fargate.ecs_cluster_name}_${var.environment}"
  tags = {
    Name    = "${var.ecs_fargate.ecs_cluster_name}_${var.environment}"
    DevOps  = var.devops_name
    Project = var.project_name
  }
}

resource "aws_ecs_service" "ecs-service" {
  name            = "${var.ecs_fargate.ecs_service.name}_${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.tasks.arn
  desired_count   = var.ecs_fargate.ecs_service.desired_count
  launch_type     = var.ecs_fargate.ecs_service.launch_type

  network_configuration {
    security_groups  = local.security_group_list
    subnets          = local.load_balancer.subnets_list
    assign_public_ip = local.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app-lb-tg.id
    container_name   = "${var.ecs_fargate.ecs_service.load_balancer.container_name}_${var.environment}"
    container_port   = var.ecs_fargate.ecs_service.load_balancer.container_port
  }

  depends_on = [aws_lb_listener.lb-listener-http]

  tags = {
    Name    = "${var.ecs_fargate.ecs_service.name}_${var.environment}"
    DevOps  = var.devops_name
    Project = var.project_name
  }

}

resource "aws_ecs_task_definition" "tasks" {
  family                   = var.ecs_fargate.task_definition.family
  network_mode             = var.ecs_fargate.task_definition.network_mode
  requires_compatibilities = var.ecs_fargate.task_definition.requires_compatibilities
  cpu                      = var.ecs_fargate.task_definition.cpu
  memory                   = var.ecs_fargate.task_definition.memory
  container_definitions = jsonencode([
    {
      name        = "${var.ecs_fargate.task_definition.container_definitions.name}_${var.environment}"
      image       = var.ecs_fargate.task_definition.container_definitions.image
      cpu         = var.ecs_fargate.task_definition.container_definitions.cpu
      memory      = var.ecs_fargate.task_definition.container_definitions.memory
      networkMode = var.ecs_fargate.task_definition.container_definitions.networkMode
      portMappings = [
        {
          containerPort = var.ecs_fargate.task_definition.container_definitions.portMappings.containerPort
          hostPort      = var.ecs_fargate.task_definition.container_definitions.portMappings.hostPort
        }
      ]
    }
  ])

  tags = {
    Name    = "${var.ecs_fargate.task_definition.name}_${var.environment}"
    DevOps  = var.devops_name
    Project = var.project_name
  }
}
