# Variables

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_keypair_name" {}
variable "region" {
    default = "us-east-2"
}

# Providers

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.region
}



# Output
# Output Site IP/DNS Name Here