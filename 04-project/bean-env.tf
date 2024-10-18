resource "aws_elastic_beanstalk_environment" "vapp-env" {
  name                = "vapp-bean"
  application         = aws_elastic_beanstalk_application.vapp.name
  solution_stack_name = "64bit Amazon Linux 2 v4.7.2 running Tomcat 9 Corretto 11"
  cname_prefix        = "vapp-bean-test-domain"
  setting {
    name      = "VPCId"
    namespace = "aws:ec2:vpc"
    value     = module.vpc.vpc_id
  }

  setting {
    name      = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = aws_iam_role.elasticbeanstalk_ec2_role.name
  }

  setting {
    name      = "AssociatePublicIpAddress"
    namespace = "aws:ec2:vpc"
    value     = "false"
  }

  setting {
    name      = "Subnets"
    namespace = "aws:ec2:vpc"
    value     = join(",", [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]])
  }

  setting {
    name      = "ELBSubnets"
    namespace = "aws:ec2:vpc"
    value     = join(",", [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]])
  }

  setting {
    name      = "InstanceType"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "t2.micro"
  }

  setting {
    name      = "EC2KeyName"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = aws_key_pair.vappkey.key_name
  }

  setting {
    name      = "Availability Zones"
    namespace = "aws:autoscaling:asg"
    value     = "Any 3"
  }

  setting {
    name      = "MinSize"
    namespace = "aws:autoscaling:asg"
    value     = "1"
  }

  setting {
    name      = "MaxSize"
    namespace = "aws:autoscaling:asg"
    value     = "4"
  }

  setting {
    name      = "LOGGING_APPENDER"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "GRAYLOG"
  }

  setting {
    name      = "SystemType"
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    value     = "enhanced"
  }

  setting {
    name      = "RollingUpdateEnabled"
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    value     = "true"
  }

  setting {
    name      = "RollingUpdateType"
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    value     = "Health"
  }

  setting {
    name      = "MaxBatchSize"
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    value     = "1"
  }

  setting {
    name      = "CrossZone"
    namespace = "aws:elb:loadbalancer"
    value     = "true"
  }

  setting {
    name      = "StickinessEnabled"
    namespace = "aws:elasticbeanstalk:environment:process:default"
    value     = "true"
  }

  setting {
    name      = "BatchSizeType"
    namespace = "aws:elasticbeanstalk:command"
    value     = "Fixed"
  }

  setting {
    name      = "BatchSize"
    namespace = "aws:elasticbeanstalk:command"
    value     = "1"
  }

  setting {
    name      = "DeploymentPolicy"
    namespace = "aws:elasticbeanstalk:command"
    value     = "Rolling"
  }

  setting {
    name      = "SecurityGroups"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = aws_security_group.vapp-test-sg.id
  }

  setting {
    name      = "SecurityGroups"
    namespace = "aws:elbv2:loadbalancer"
    value     = aws_security_group.vapp-bean-elb-sg.id
  }

  depends_on = [aws_security_group.vapp-bean-elb-sg, aws_security_group.vapp-test-sg, aws_elastic_beanstalk_application.vapp]
}
