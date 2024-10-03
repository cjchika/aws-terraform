locals {
  common_tags = {
    ManagedBy = "Terraform"
    Project   = "JobApp"
  }
}

data "aws_iam_role" "s3_full_access" {
  name = "jobapprole"
}

resource "aws_instance" "node_server" {
  ami           = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.node_sg.id]
  key_name               = var.key_name
  subnet_id              = var.subnet_id

  tags = merge(local.common_tags, {
    Name = "Nodejs-Server"
  })
}

resource "aws_instance" "nginx_server" {
  ami           = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  key_name               = var.key_name
  subnet_id              = var.subnet_id

  iam_instance_profile = data.aws_iam_role.s3_full_access.name

  tags = merge(local.common_tags, {
    Name = "Nginx-Server"
  })
}

resource "aws_security_group" "node_sg" {
  name   = "node-security-group"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["197.210.52.119/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "Nodejs-Security-Group"
  })
}

resource "aws_security_group" "nginx_sg" {
  name   = "nginx-security-group"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["197.210.52.119/32"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "Nginx-Security-Group"
  })
}

resource "aws_lb" "job_app_alb" {
  name               = "job-app-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.subnet_ids.subnet_a, var.subnet_ids.subnet_b, var.subnet_ids.subnet_c, var.subnet_ids.subnet_e, ]

  security_groups = [aws_security_group.nginx_sg.id]

  tags = merge(local.common_tags, {
    Name = "Nginx-jobapp-alb"
  })

}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.job_app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.job_app_tg.arn
  }
}

resource "aws_lb_target_group" "job_app_tg" {
  name     = "Nginx-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "lb_tg_attachement" {
  target_group_arn = aws_lb_target_group.job_app_tg.arn
  target_id        = aws_instance.nginx_server.id
  port             = 80
}

output "nginx_instance" {
  value = aws_instance.nginx_server.ami
}

output "nodejs_instance" {
  value = aws_instance.nginx_server.ami
}

