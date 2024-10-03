# OPTIMIZED TERRAFORM CODE USING FOR EACH TO REDUCE CODE DUPLICATION

locals {
  common_tags = {
    ManagedBy = "Terraform"
    Project   = "MERNStack"
  }

  services = {
    backend_node = {
      name           = "backend-node"
      image          = "cjchika/backend-node"
      container_port = 80
      task_family    = "MERN-Backend-Family"
      service_name   = "backend-node-svc"
      desired_count  = 2
      alb_name       = "backend-alb"
      tg_name        = "Node-TG"
      listener_name  = "node-listener"
      tags           = merge(local.common_tags, { Name = "ECS-NODE" })
    },
    frontend_react = {
      name           = "frontend-react"
      image          = "cjchika/frontend-react"
      container_port = 80
      task_family    = "MERN-Frontend-Family"
      service_name   = "frontend-react-svc"
      desired_count  = 2
      alb_name       = "frontend-alb"
      tg_name        = "React-TG"
      listener_name  = "react-listener"
      tags           = merge(local.common_tags, { Name = "ECS-REACT" })
    }
  }
}

resource "aws_ecs_cluster" "mern_cluster" {
  name = "mern_cluster"

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


# UNOPTIMIZED TERRAFORM CODE

# locals {
#   common_tags = {
#     ManagedBy = "Terraform"
#     Project   = "MERNStack"
#   }
# }

# resource "aws_ecs_cluster" "mern_cluster" {
#   name = "mern_cluster"

#   tags = merge(local.common_tags, {
#     Name = "MERN-Cluster"
#   })
# }

# resource "aws_security_group" "ecs_sg" {
#   name        = "ecs-security-group"
#   description = "Allow inbound HTTP traffic"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(local.common_tags, {
#     Name = "ECS-SG"
#   })
# }

# resource "aws_ecs_task_definition" "backend_node_task" {
#   family                   = "MERN-Family"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   # execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
#   cpu    = "256"
#   memory = "512"
#   container_definitions = jsonencode([{
#     name      = "backend-node"
#     image     = "cjchika/backend-node"
#     essential = true
#     portMappings = [{
#       containerPort = 80
#       hostPort      = 80
#       protocol      = "HTTP"
#     }]
#   }])

#   tags = merge(local.common_tags, {
#     Name = "ECS-NODE-TASK"
#   })
# }

# resource "aws_ecs_task_definition" "frontend_react_task" {
#   family                   = "MERN-Family"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   # execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
#   cpu    = "256"
#   memory = "512"
#   container_definitions = jsonencode([{
#     name      = "frontend-react"
#     image     = "cjchika/frontend-react"
#     essential = true
#     portMappings = [{
#       containerPort = 80
#       hostPort      = 80
#       protocol      = "HTTP"
#     }]
#   }])

#   tags = merge(local.common_tags, {
#     Name = "ECS-REACT-TASK"
#   })
# }

# resource "aws_ecs_service" "backend_node_svc" {
#   name            = "backend-node-svc"
#   cluster         = aws_ecs_cluster.mern_cluster.id
#   task_definition = aws_ecs_task_definition.backend_node_task.arn
#   desired_count   = 2
#   launch_type     = "FARGATE"

#   load_balancer {
#     target_group_arn = aws_lb_target_group.backend_tg.arn
#     container_name   = "backend-node"
#     container_port   = 80
#   }

#   network_configuration {
#     subnets          = var.subnet_ids
#     security_groups  = [aws_security_group.ecs_sg.id]
#     assign_public_ip = true
#   }

#   tags = merge(local.common_tags, {
#     Name = "ECS-NODE-SVC"
#   })
# }


# resource "aws_ecs_service" "frontend_react_svc" {
#   name            = "frontend-react-svc"
#   cluster         = aws_ecs_cluster.mern_cluster.id
#   task_definition = aws_ecs_task_definition.frontend_react_task.arn
#   desired_count   = 2
#   launch_type     = "FARGATE"

#   load_balancer {
#     target_group_arn = aws_lb_target_group.frontend_tg.arn
#     container_name   = "frontend-react"
#     container_port   = 80
#   }

#   network_configuration {
#     subnets          = var.subnet_ids
#     security_groups  = [aws_security_group.ecs_sg.id]
#     assign_public_ip = true
#   }

#   tags = merge(local.common_tags, {
#     Name = "ECS-REACT-SVC"
#   })
# }

# resource "aws_lb" "backend_alb" {
#   name               = "backend-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.ecs_sg.id]
#   subnets            = var.subnet_ids

#   tags = merge(local.common_tags, {
#     Name = "ECS-NODE-ALB"
#   })
# }

# resource "aws_lb" "frontend_alb" {
#   name               = "frontend-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.ecs_sg.id]
#   subnets            = var.subnet_ids

#   tags = merge(local.common_tags, {
#     Name = "ECS-REACT-ALB"
#   })
# }

# resource "aws_lb_target_group" "backend_tg" {
#   name        = "Node-TG"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = var.vpc_id
#   target_type = "ip"

#   tags = merge(local.common_tags, {
#     Name = "ECS-NODE-TG"
#   })
# }

# resource "aws_lb_target_group" "frontend_tg" {
#   name        = "React-TG"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = var.vpc_id
#   target_type = "ip"

#   tags = merge(local.common_tags, {
#     Name = "ECS-REACT-TG"
#   })
# }

# resource "aws_lb_listener" "node_listener" {
#   load_balancer_arn = aws_lb.backend_alb.arn
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.backend_tg.arn
#   }
# }

# resource "aws_lb_listener" "react_listener" {
#   load_balancer_arn = aws_lb.frontend_alb.arn
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.frontend_tg.arn
#   }
# }


