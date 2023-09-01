#!/bin/bash 


#VPC

        VPC_ID=$(aws ec2 create-vpc --cidr-block "10.0.0.0/16" --query 'Vpc.VpcId' --output text)
         export VPC_ID

 #echo $VPC_ID 

####assign a name to the VPC

 aws ec2 create-tags --resources "$VPC_ID" --tags Key=Name,Value=VPC-project




#subnetting
#0
    SUBNET_ID0=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block "10.0.0.0/24"  --availability-zone us-west-2a --query 'Subnet.SubnetId' --output text)
        export SUBNET_ID0
         aws ec2 create-tags --resources $SUBNET_ID0 --tags Key=Name,Value=Pub-Sub-0
#1
    SUBNET_ID1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block "10.0.1.0/24" --availability-zone us-west-2a --query 'Subnet.SubnetId' --output text)
        export SUBNET_ID1
         aws ec2 create-tags --resources $SUBNET_ID1 --tags Key=Name,Value=Pri-Sub-1
#2
    SUBNET_ID2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block "10.0.2.0/24" --availability-zone us-west-2b --query 'Subnet.SubnetId' --output text)
        export SUBNET_ID2
         aws ec2 create-tags --resources $SUBNET_ID2 --tags Key=Name,Value=Pub-Sub-2         
#3
    SUBNET_ID3=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block "10.0.3.0/24"  --availability-zone us-west-2b --query 'Subnet.SubnetId' --output text)
        export SUBNET_ID3
         aws ec2 create-tags --resources $SUBNET_ID3 --tags Key=Name,Value=Pri-Sub-3





####gateway


    INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
     export INTERNET_GATEWAY_ID

    #assign a name to the InternetGateway
     aws ec2 create-tags --resources $INTERNET_GATEWAY_ID --tags Key=Name,Value=GateWay

     #attach to vpc 
      aws ec2 attach-internet-gateway --internet-gateway-id $INTERNET_GATEWAY_ID --vpc-id $VPC_ID
    
###ELASTIC ip 
    ELASTIC_IP_ID=$(aws ec2 allocate-address --query 'AllocationId' --output text)
     export ELASTIC_IP_ID 
    ELASTIC_IP=$(aws ec2 describe-addresses --allocation-ids $ELASTIC_IP_ID --query 'Addresses[0].PublicIp' --output text)
     export Elastic_IP




#make Nate gateway
 NATGATEWAY=$(aws ec2 create-nat-gateway --subnet-id "$SUBNET_ID0" --allocation-id "$ELASTIC_IP_ID")




