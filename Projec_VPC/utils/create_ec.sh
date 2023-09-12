#!/bin/bash

# Variables
instance_name="MyEC2Instance"
ami_id="ami-12345678"  # Replace with your desired AMI ID
instance_type="t2.micro"  # Replace with your desired instance type
key_name="your-key-pair-name"  # Replace with your SSH key pair name
subnet_id="subnet-12345678"  # Replace with the ID of the subnet you want to launch the instance in
security_group_ids=("sg-12345678")  # Replace with the security group IDs you want to associate

# Create EC2 instance
instance_id=$(aws ec2 run-instances \
    --image-id $ami_id \
    --instance-type $instance_type \
    --key-name $key_name \
    --subnet-id $subnet_id \
    --security-group-ids ${security_group_ids[@]} \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

# Wait for the instance to reach the "running" state (optional)
aws ec2 wait instance-running --instance-ids $instance_id

# Output the instance ID
echo "EC2 instance ID: $instance_id"
