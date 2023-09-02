#!/bin/bash

# Variables
security_group_name="MySecurityGroup"  # Replace with your desired security group name
description="My Security Group for SSH"
port=22
cidr_ip="0.0.0.0/0"  # Adjust to your desired IP range

# Create a new security group
security_group_id=$(aws ec2 create-security-group \
    --group-name "$security_group_name" \
    --description "$description" \
    --vpc-id "your-vpc-id"  # Replace with your VPC ID \
    --output text)

# Add an ingress rule to allow SSH traffic (port 22)
aws ec2 authorize-security-group-ingress \
    --group-id $security_group_id \
    --protocol tcp \
    --port $port \
    --cidr $cidr_ip \
    --description "SSH Rule"

# Output the created security group ID
echo "Security group $security_group_name (ID: $security_group_id) has been created with SSH rule."
