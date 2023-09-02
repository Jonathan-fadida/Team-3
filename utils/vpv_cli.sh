#!/bin/bash

# Variables
vpc_cidr_block="10.0.0.0/16"
public_subnet_cidr_blocks=("10.0.1.0/24" "10.0.2.0/24")
private_subnet_cidr_blocks=("10.0.3.0/24" "10.0.4.0/24")

# Create VPC
vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr_block --query 'Vpc.VpcId' --output text)

# Enable DNS resolution and hostname support for the VPC
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-support "{\"Value\":true}"
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-hostnames "{\"Value\":true}"

# Create Public Subnets and configure route tables
for ((i=0; i<${#public_subnet_cidr_blocks[@]}; i++)); do
    subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block ${public_subnet_cidr_blocks[i]} --query 'Subnet.SubnetId' --output text)
    
    # Create a public route table
    public_route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --query 'RouteTable.RouteTableId' --output text)
    
    # Add a route to the Internet Gateway for public subnets
    internet_gateway_id=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
    aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $internet_gateway_id
    aws ec2 create-route --route-table-id $public_route_table_id --destination-cidr-block "0.0.0.0/0" --gateway-id $internet_gateway_id
    
    # Associate the public route table with the public subnet
    aws ec2 associate-route-table --subnet-id $subnet_id --route-table-id $public_route_table_id
    
    # Store the public subnet ID in a variable
    if [ $i -eq 0 ]; then
        public_subnet_id1=$subnet_id
    else
        public_subnet_id2=$subnet_id
    fi
done

# Create Private Subnets and configure route tables with NAT Gateway
for ((i=0; i<${#private_subnet_cidr_blocks[@]}; i++)); do
    subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block ${private_subnet_cidr_blocks[i]} --query 'Subnet.SubnetId' --output text)
    
    # Create a private route table
    private_route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --query 'RouteTable.RouteTableId' --output text)
    
    # Create an Elastic IP (EIP) for the NAT Gateway
    eip_allocation_id=$(aws ec2 allocate-address --query 'AllocationId' --output text)
    
    # Create the NAT Gateway in one of the public subnets
    if [ $i -eq 0 ]; then
        nat_gateway_id=$(aws ec2 create-nat-gateway --subnet-id $public_subnet_id1 --allocation-id $eip_allocation_id --query 'NatGateway.NatGatewayId' --output text)
    else
        nat_gateway_id=$(aws ec2 create-nat-gateway --subnet-id $public_subnet_id2 --allocation-id $eip_allocation_id --query 'NatGateway.NatGatewayId' --output text)
    fi
    
    # Add a route to the NAT Gateway for private subnets
    aws ec2 create-route --route-table-id $private_route_table_id --destination-cidr-block "0.0.0.0/0" --gateway-id $nat_gateway_id
    
    # Associate the private route table with the private subnet
    aws ec2 associate-route-table --subnet-id $subnet_id --route-table-id $private_route_table_id
done

# Output VPC and Subnet IDs
echo "VPC ID: $vpc_id"
echo "Public Subnet ID 1: $public_subnet_id1"
echo "Public Subnet ID 2: $public_subnet_id2"
