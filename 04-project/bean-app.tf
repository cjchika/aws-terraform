resource "aws_elastic_beanstalk_application" "vapp" {
  name = "vapp"
}

resource "aws_iam_role" "elasticbeanstalk_ec2_role" {
  name = "elasticbeanstalk_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_web_tier" {
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_worker_tier" {
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "rds_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
}

resource "aws_iam_instance_profile" "elasticbeanstalk_ec2_instance_profile" {
  name = "elasticbeanstalk_ec2_instance_profile"
  role = aws_iam_role.elasticbeanstalk_ec2_role.name
}