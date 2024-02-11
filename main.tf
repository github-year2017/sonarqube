provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      code = "aws-asg"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = "main-vpc"
  cidr = "10.0.0.0/16"

  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_configuration" "sonarqube" {
  name_prefix     = "code-terraform-aws-asg-"
  image_id        = data.aws_ami.amazon-linux.id
  instance_type   = "t2.small"
  user_data       = file("sonar-data.sh")
  security_groups = [aws_security_group.sonarqube_instance.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "sonarqube" {
  name                 = "sonarqube"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.sonarqube.name
  vpc_zone_identifier  = module.vpc.public_subnets

  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "code ASG - sonarqube"
    propagate_at_launch = true
  }
}

resource "aws_lb" "sonarqube" {
  name               = "code-asg-sonarqube-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sonarqube_lb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "sonarqube" {
  load_balancer_arn = aws_lb.sonarqube.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sonarqube.arn
  }
}

resource "aws_lb_target_group" "sonarqube" {
  name        = "code-asg-sonarqube"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
}


resource "aws_autoscaling_attachment" "sonarqube" {
  autoscaling_group_name = aws_autoscaling_group.sonarqube.id
  lb_target_group_arn    = aws_lb_target_group.sonarqube.arn
}

resource "aws_security_group" "sonarqube_instance" {
  name = "code-asg-sonarqube-instance"
  ingress {
    from_port       = 80
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.sonarqube_lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "sonarqube_lb" {
  name = "code-asg-sonarqube-lb"
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

  vpc_id = module.vpc.vpc_id
}
