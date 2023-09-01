#!/bin/bash 


VPC(){

 #________________________________________________________________
 #CREATE NEW VPC 

 aws ec2 create-vpc --cidr-block X.X.X.X/X --query Vpc.VpcId --output text

 #assign a name to the VPC 

 aws ec2 create-tags --resources vpc-06b9154be75f45ff8 --tags Key=Name,Value=VPC-project

 #SHOW VPC LIST                      #

 aws ec2 describe-vpcs --query 'Vpcs[*].{VPCId:VpcId, Name:Tags[?Key==`Name`].Value | [0], CIDRBlock:CidrBlock}' --output table


}


Subnets(){

 #Create Subnet 

 aws ec2 create-subnet --vpc-id vpc-06b9154be75f45ff8 --cidr-block 10.0.0.0/24 --availability-zone us-west-2a --query Subnet.SubnetId --output text
 aws ec2 create-subnet --vpc-id vpc-06b9154be75f45ff8 --cidr-block 10.0.1.0/24 --availability-zone us-west-2a --query Subnet.SubnetId --output text
 aws ec2 create-subnet --vpc-id vpc-06b9154be75f45ff8 --cidr-block 10.0.2.0/24 --availability-zone us-west-2b --query Subnet.SubnetId --output text
 aws ec2 create-subnet --vpc-id vpc-06b9154be75f45ff8 --cidr-block 10.0.3.0/24 --availability-zone us-west-2b --query Subnet.SubnetId --output text


 #________________________________________________________________
 #Name and tag subnet 
 aws ec2 create-tags --resources subnet-022d6def97500144f --tags Key=Name,Value=Pub-Sub-0
 aws ec2 create-tags --resources subnet-035c9f6f9bf51255b  --tags Key=Name,Value=Priv-Sub-1
 aws ec2 create-tags --resources subnet-00969dcb2bd7c3f82 --tags Key=Name,Value=Pub-Sub-2
 aws ec2 create-tags --resources subnet-0df59df7e8d0bac18 --tags Key=Name,Value=Priv-Sub-3

 #SHOW SUBNETS and filter by specific VPC

 aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-06b9154be75f45ff8" --query 'Subnets[*].{ID:SubnetId, Name:Tags[?Key==`Name`].Value | [0], CIDR:CidrBlock, AvailabilityZone:AvailabilityZone}' --output table


}

RouteTables(){
    
    #create route table
    aws ec2 create-route-table --vpc-id vpc-06b9154be75f45ff8
    
    #route 1 public    rtb-09d17cb7c4317cd5d
    #route 2 private    rtb-013dfeaa3f1a03385
    #assign a name to route table 
    aws ec2 create-tags --resources rtb-09d17cb7c4317cd5d --tags Key=Name,Value=Route-Public
    
    #create route    (public<->internet-gateway)
    aws ec2 create-route --route-table-id rtb-09d17cb7c4317cd5d --destination-cidr-block 0.0.0.0/0 --gateway-id igw-0c89bcc1bbe0ce9cd

    #create route (private<->nat-gateway) 
        aws ec2 create-route --route-table-id rtb-013dfeaa3f1a03385 --destination-cidr-block 0.0.0.0/0 --gateway-id nat-05c899ee9d155cc83

    #associate route taple (public<->subnets .2 .3 with InternetGate ) 

    aws ec2 associate-route-table --route-table-id rtb-09d17cb7c4317cd5d --subnet-id subnet-00969dcb2bd7c3f82

    aws ec2 associate-route-table --route-table-id rtb-09d17cb7c4317cd5d --subnet-id subnet-0df59df7e8d0bac18

    #associate route table (private<-> .1 .0 with NatGate )

        aws ec2 associate-route-table --route-table-id rtb-013dfeaa3f1a03385 --subnet-id subnet-035c9f6f9bf51255b
        aws ec2 associate-route-table --route-table-id rtb-013dfeaa3f1a03385 --subnet-id subnet-022d6def97500144f




    

}

InternetGateways(){
 #________________________________________________________________
 #Create Gateways 

 aws ec2 create-internet-gateway

 #name gateway 

 aws ec2 create-tags --resources igw-0c89bcc1bbe0ce9cd --tags Key=Name,Value=GateWay

 #attatch gateway to VPC 
 aws ec2 attach-internet-gateway --internet-gateway-id igw-0c89bcc1bbe0ce9cd --vpc-id vpc-06b9154be75f45f
 f8

 #show gateways 

 aws ec2 describe-internet-gateways --query 'InternetGateways[*].{ID:InternetGatewayId, Name:Tags[?Key==`Name`].Value | [0]}' --output table




}


NatGateway(){
 #________________________________________________________________
 #elastic ip address 
 aws ec2 allocate-address --domain vpc
 #52.32.84.167

 
 aws ec2 create-nat-gateway --subnet-id subnet-022d6def97500144f --allocation-id eipalloc-0e653f70d0d9e672d
 
}

SecurityGroup(){

    aws ec2 create-security-group --group-name Security-Group-Web --description security_group-web --vpc-id vpc-06b9154be75f45ff8
    #sg-06ef357ea7e4b5439

    #assign a name to the security group 
    aws ec2 create-tags --resources sg-06ef357ea7e4b5439 --tags Key=Name,Value=security_group

    #allow inpound protocol

    aws ec2 authorize-security-group-ingress --group-id sg-06ef357ea7e4b5439 --protocol tcp --port 22 --cidr 0.0.0.0/0


}

#make a key 
 aws ec2 create-key-pair --key-name cli-keyPair --query 'KeyMaterial' --output text > cli-keyPair.pem

#run ect ubuntu instance 
 aws ec2 run-instances --image-id ami-03f65b8614a860c29 --instance-type t2.micro --count 1 --subnet-id subnet-00969dcb2bd7c3f82 --security-group-ids sg-06ef357ea7e4b5439 --associate-public-ip-address --key-name cli-keyPair

#assign a name to the instance

aws ec2 create-tags --resources i-0b0b4ade1bd767c32 --tags Key=Name,Value=my-web-server-1



