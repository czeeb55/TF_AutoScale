# Variables

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_keypair_name" {}
variable "my_ip" {}
variable "region" {
    default = "us-east-2"
}

# Providers

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.region
}

# Locals
/*
locals{
    tags = {
        Application = "CZs_Autoscaled_Nginx"
        propagate_at_launch = true
    }
}
*/

# Output
# Output Site IP/DNS Name Here
output "aws_elb_public_dns" {
    value = aws_elb.nginx-elb.dns_name
  }