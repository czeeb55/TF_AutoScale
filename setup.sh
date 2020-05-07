#!/bin/bash -v
# Performs initial setup on EC2 instances when provisioned
# Update
sudo yum -y update
# Install nginx
sudo yum install -y nginx
# Start nginx
sudo nginx