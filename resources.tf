# Resources
/*
resource "aws_default_vpc" "default" {

}
*/
/*
resource aws_vpc "NGINXVPC" {
    cidr_block = "10.0.0.0/16"

    tags = {
        name = "CZs_Autoscaled_Nginx"
    }
}
*/

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    name = "NGINX-VPC"

    cidr = "10.0.0.0/16"
    azs = data.aws_availability_zones.available.names
    public_subnets = data.template_file.public_cidrsubnet[*].rendered
    private_subnets = []

    tags = {
        name = "CZs_Autoscaled_Nginx"
    }
}


resource "aws_security_group" "allow_ssh" {
  name        = "nginxSSH"
  description = "Open SSH for EC2 instances, HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] # Locking down SSH to only my home IP
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "nginx-elb" {
  name = "CZ-NGINX-ELB"
  #availability_zones = data.aws_availability_zones.available.names
  security_groups = [aws_security_group.allow_ssh.id]
  subnets = module.vpc.public_subnets
  #instances = aws_autoscaling_group.CZs_Autoscaled_NGINX.instances.id

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  tags = {
      key = "Name"
      value = "CZs_Autoscaled_Nginx"
      propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "NGINXLaunchConfig" {
  name   = "NGINX"
  image_id      = data.aws_ami.aws-linux.id
  instance_type = "t2.micro"

  key_name = var.aws_keypair_name
  user_data = file("setup.sh")
  security_groups = [aws_security_group.allow_ssh.id]
  
}

resource "aws_autoscaling_group" "CZs_Autoscaled_NGINX" {
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2
  launch_configuration = aws_launch_configuration.NGINXLaunchConfig.id
  load_balancers = [aws_elb.nginx-elb.name]
  vpc_zone_identifier = module.vpc.public_subnets
  #tags = merge(local.tags, {propagate_at_launch = true})
  tag {
      key = "Name"
      value = "CZs_Autoscaled_Nginx"
      propagate_at_launch = true
  }
 
}