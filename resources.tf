# Resources
resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "allow_ssh" {
  name        = "nginxSSH"
  description = "Open SSH for EC2 instances"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  name = "MyAutoScaledELB"
  availability_zones = data.aws_availability_zones.available.names

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
}

resource "aws_launch_configuration" "MyLaunchConfiguration" {
  name_prefix   = "Flan"
  image_id      = data.aws_ami.aws-linux.id
  instance_type = "t2.micro"

  key_name = var.aws_keypair_name
  user_data = file("setup.sh")
  security_groups = [aws_security_group.allow_ssh.id]
}

resource "aws_autoscaling_group" "MyAutoscaledGroup" {
  availability_zones = data.aws_availability_zones.available.names
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2
  launch_configuration = aws_launch_configuration.MyLaunchConfiguration.id
  load_balancers = [aws_elb.nginx-elb.name]

  tag {
      key = "Name"
      value = "MyAutoScaledGroup"
      propagate_at_launch = "true"
  }
 
}