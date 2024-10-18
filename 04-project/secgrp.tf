resource "aws_security_group" "vapp-bean-elb-sg" {
  name        = "vapp-bean-elb-sg"
  description = "Security group for bean-elb"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vapp-bation-sg" {
  name        = "vapp-bation-sg"
  description = "Security group for bation ec2 instance"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [var.MYIP]
  }
}

resource "aws_security_group" "vapp-test-sg" {
  name        = "vapp-test-sg"
  description = "Security group for beanstalk ec2 instance"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    protocol        = "tcp"
    to_port         = 22
    security_groups = [aws_security_group.vapp-bation-sg.id]
  }
}

resource "aws_security_group" "vapp-backend-sg" {
  name        = "vapp-backend-sg"
  description = "Security group for RDS, active mq, elastic cache"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    protocol        = "tcp"
    to_port         = 22
    security_groups = [aws_security_group.vapp-test-sg.id]
  }

  ingress {
    from_port       = 3306
    protocol        = "tcp"
    to_port         = 3306
    security_groups = [aws_security_group.vapp-bation-sg.id]
  }
}

resource "aws_security_group_rule" "sec_group_allow_itself" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vapp-backend-sg.id
  source_security_group_id = aws_security_group.vapp-backend-sg.id
}
