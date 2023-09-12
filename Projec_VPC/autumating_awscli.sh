#!/bin/bash 


#VPC

        #VPC_ID=$(aws ec2 create-vpc --cidr-block <CIDR_BLOCK> --query 'Vpc.VpcId' --output text)
        # export VPC_ID

 #echo $VPC_ID 

####assign a name to the VPC

 #aws ec2 create-tags --resources "$VPC_ID" --tags Key=Name,Value=VPC-project


: '

#subnetting
#0
    SUBNET_ID0=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block "10.0.0.0/24" --query --availability-zone us-west-2a 'Subnet.SubnetId' --output text)
        export SUBNET_ID0
         aws ec2 create-tags --resources $SUBNET_ID0 --tags Key=Name,Value=Pub-Sub-0
#1
    SUBNET_ID1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block "10.0.1.0/24" --availability-zone us-west-2a --query 'Subnet.SubnetId' --output text)
        export SUBNET_ID1
         aws ec2 create-tags --resources $SUBNET_ID1 --tags Key=Name,Value=Pri-Sub-1
#2
    SUBNET_ID2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block "10.0.2.0/24" --query --availability-zone us-west-2b 'Subnet.SubnetId' --output text)
        export SUBNET_ID2
         aws ec2 create-tags --resources $SUBNET_ID2 --tags Key=Name,Value=Pub-Sub-2         
#3
    SUBNET_ID3=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block "10.0.3.0/24" --query --availability-zone us-west-2b 'Subnet.SubnetId' --output text)
        export SUBNET_ID0
         aws ec2 create-tags --resources $SUBNET_ID3 --tags Key=Name,Value=Pri-Sub-3

'


: '
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





aws ec2 associate-route-table --route-table-id rtb-08f8a5684bc4c5808 --subnet-id subnet-0cda43ff62f2c6c31
aws ec2 associate-route-table --route-table-id rtb-03e6da0f056106a96 --subnet-id subnet-041b2f8989f5bd781
aws ec2 associate-route-table --route-table-id rtb-03e6da0f056106a96 --subnet-id subnet-028510fba161bed91

'

#create key pair 
# aws ec2 create-key-pair --key-name Key_auto3 --query 'KeyMaterial' --output text > Key_auto3.pem

# chmod 400 Key_auto3.pem 


#create instances 

#aws ec2 run-instances --image-id ami-03f65b8614a860c29 --instance-type t2.micro --count 1 --subnet-id subnet-041b2f8989f5bd781 --security-group-ids sg-0ce6b2feacdb4d1ae --associate-public-ip-address --key-name Key_auto2

INSTANCE1_ID=$(aws ec2 run-instances \
   --image-id ami-03f65b8614a860c29\
    --instance-type t2.micro \
     --key-name Key_auto \
        --subnet-id subnet-041b2f8989f5bd781 \
          --security-group-ids sg-0ce6b2feacdb4d1ae \
            --output text \
              --query 'Instances[0].InstanceId')

export INSTANCE1_ID

aws ec2 create-tags --resources $INSTANCE1_ID --tags Key=Name,Value=Web_ec2


INSTANCE2_ID=$(aws ec2 run-instances \
   --image-id ami-03f65b8614a860c29\
    --instance-type t2.micro \
     --key-name Key_auto \
        --subnet-id subnet-0cda43ff62f2c6c31 \
          --security-group-ids sg-06cad129fca81df30 \
            --output text \
              --query 'Instances[0].InstanceId')

export INSTANCE2_ID

aws ec2 create-tags --resources $INSTANCE2_ID --tags Key=Name,Value=DB_ec2


