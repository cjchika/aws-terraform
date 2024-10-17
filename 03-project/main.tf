locals {
  common_tags = {
    ManagedBy = "Terraform"
    Project   = "MERNStack"
  }

  services = {
    backend_node = {
      name           = "backend-node"
      image          = "000000000000.dkr.ecr.us-east-1.amazonaws.com/backendnodeimg"
      container_port = 80
      task_family    = "MERN-Backend-Family"
      service_name   = "backend-node-svc"
      desired_count  = 1
      alb_name       = "backend-alb"
      tg_name        = "Node-TG"
      listener_name  = "node-listener"
      tags           = merge(local.common_tags, { Name = "ECS-NODE" })
    },
    frontend_react = {
      name           = "frontend-react"
      image          = "0000000000000.dkr.ecr.us-east-1.amazonaws.com/frontendreactimg"
      container_port = 80
      task_family    = "MERN-Frontend-Family"
      service_name   = "frontend-react-svc"
      desired_count  = 1
      alb_name       = "frontend-alb"
      tg_name        = "React-TG"
      listener_name  = "react-listener"
      tags           = merge(local.common_tags, { Name = "ECS-REACT" })
    }
  }
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_cluster" "mern_cluster" {
  name = "mern_cluster_stage"

  tags = merge(local.common_tags, {
    Name = "MERN-Cluster"
  })
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-security-group"
  description = "Allow inbound HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "ECS-SG"
  })
}

resource "aws_ecs_task_definition" "task_definitions" {
  for_each = local.services

  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  family                   = each.value.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([
    {
      name      = each.value.name
      image     = each.value.image
      essential = true
      portMappings = [
        {
          containerPort = each.value.container_port
          hostPort      = each.value.container_port
          protocol      = "tcp"
        }
      ]
    }
  ])
  tags = each.value.tags
}

resource "aws_lb" "alb" {
  for_each = local.services

  name               = each.value.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = var.subnet_ids

  tags = each.value.tags
}

resource "aws_lb_target_group" "tg" {
  for_each    = local.services
  name        = each.value.tg_name
  port        = each.value.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = each.key == "backend_node" ? "/api/v1/jobs" : "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = each.value.tags
}

resource "aws_lb_listener" "listener" {
  for_each = local.services

  load_balancer_arn = aws_lb.alb[each.key].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  tags = each.value.tags
}

resource "aws_ecs_service" "services" {
  for_each        = local.services
  name            = each.value.service_name
  cluster         = aws_ecs_cluster.mern_cluster.id
  task_definition = aws_ecs_task_definition.task_definitions[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.tg[each.key].arn
    container_name   = each.value.name
    container_port   = each.value.container_port
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  tags = each.value.tags
}
