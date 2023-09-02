#!/bin/bash

# Variables
security_group_id="sg-12345678"  # Replace with your security group ID
description="SSH Rule"
port=22
cidr_ip="0.0.0.0/0"  # Adjust to your desired IP range

# Create a security group ingress rule for SSH (port 22)
aws ec2 authorize-security-group-ingress \
    --group-id $security_group_id \
    --protocol tcp \
    --port $port \
    --cidr $cidr_ip \
    --description "$description"

# Output success message
echo "Security group rule for port $port (SSH) has been created."
