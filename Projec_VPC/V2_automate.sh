#!/bin/bash 


# Create                VPC Variables
 vpc_cidr="10.0.10.0/16"
 vpc_name="WEEK-Project"
#________________________________________________________________
# Create                      SUBNET Variables
 subnet_1_cidr="10.0.0.0/24"
 subnet_1_name=pub-sub-0
 
 subnet_2_cidr="10.0.10.0/24"
 subnet_2_name=pri-sub-10

 subnet_3_cidr="10.0.20.0/24"
 subnet_3_name=pub-sub-20

 subnet_4_cidr="10.0.30.0/24"
 subnet_4_name=pri-sub-30

#________________________________________________________________
#                         Availability Zones
 availability_zone_A="us-west-2a"
 availability_zone_B="us-west-2b"




#VPC

        VPC_ID=$(aws ec2 create-vpc --cidr-block  "$vpc_cidr"  --query 'Vpc.VpcId'  --output text)
         export VPC_ID

 #echo $VPC_ID 

####assign a name to the VPC

 aws ec2 create-tags --resources "$VPC_ID" --tags Key=Name,Value="$vpc_name"




#subnetting
#0
    SUBNET_ID0=$(aws ec2 create-subnet \
        --vpc-id "$VPC_ID"    \
           --cidr-block "$subnet_1_cidr"  \
             --availability-zone "$availability_zone_A" \
              --query 'Subnet.SubnetId' \
               --output text)
     
     export SUBNET_ID0
         aws ec2 create-tags --resources "$SUBNET_ID0" --tags Key=Name,Value=$subnet_1_name
#1
    SUBNET_ID1=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
      --cidr-block "$subnet_2_cidr" \
       --availability-zone "$availability_zone_A" \
         --query 'Subnet.SubnetId' \
           --output text)

        export SUBNET_ID1
         aws ec2 create-tags --resources "$SUBNET_ID1" --tags Key=Name,Value=$subnet_2_name
#2
    SUBNET_ID2=$(aws ec2 create-subnet \
       --vpc-id "$VPC_ID" \
         --cidr-block "$subnet_3_cidr" \
            --availability-zone $availability_zone_B \
               --query 'Subnet.SubnetId' \
                --output text)

    export SUBNET_I2
         aws ec2 create-tags --resources "$SUBNET_ID2" --tags Key=Name,Value=$subnet_3_name        
#3
    SUBNET_ID3=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
      --cidr-block $subnet_4_cidr \
        --availability-zone $availability_zone_B \
          --query 'Subnet.SubnetId' \
            --output text)

     export SUBNET_ID3
         aws ec2 create-tags --resources "$SUBNET_ID3" --tags Key=Name,Value=$subnet_4_name





####gateway


    INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway \
     --query 'InternetGateway.InternetGatewayId' \
       --output text)
     
     export INTERNET_GATEWAY_ID

     #assign a name to the InternetGateway
     aws ec2 create-tags --resources "$INTERNET_GATEWAY_ID" --tags Key=Name,Value=GateWay

     #attach to vpc 
      aws ec2 attach-internet-gateway --internet-gateway-id "$INTERNET_GATEWAY_ID" --vpc-id "$VPC_ID"
    
###ELASTIC ip 
    ELASTIC_IP_ID=$(aws ec2 allocate-address \
     --query 'AllocationId' \
      --output text)

     export ELASTIC_IP_ID 
    
    ELASTIC_IP=$(aws ec2 describe-addresses \
      --allocation-ids "$ELASTIC_IP_ID"  \
        --query 'Addresses[0].PublicIp' \
          --output text)
     
     export Elastic_IP




#make Nate gateway
 NAT_GATEWAY_ID=$(aws ec2 create-nat-gateway \
   --subnet-id "$SUBNET_ID0" \
     --allocation-id "$ELASTIC_IP_ID"  \
     --query 'NatGateway.NatGatewayId'  \
     --output text) 

 export NAT_GATEWAY_ID    



################################################################
################################################################
################################################################
################################################################



#create Route Tables 

 ROUTE_TABLE_ID_A=$(aws ec2 create-route-table \
   --vpc-id "$VPC_ID" \
    --query 'RouteTable.RouteTableId' \
     --output text)
 export ROUTE_TABLE_ID_A
 aws ec2 create-tags --resources "$ROUTE_TABLE_ID_A" --tags Key=Name,Value=Route_table_A

 ROUTE_TABLE_ID_B=$(aws ec2 create-route-table \
   --vpc-id "$VPC_ID" \
     --query 'RouteTable.RouteTableId'  --output text)
 
 export ROUTE_TABLE_B
 aws ec2 create-tags --resources "$ROUTE_TABLE_ID_B" --tags Key=Name,Value=Route_table_B



#------------create routes--------------- 


#route NAT Gateway <--> route table A

 aws ec2 create-route --route-table-id "$ROUTE_TABLE_ID_A" \
   --destination-cidr-block 0.0.0.0/0 \
     --gateway-id "$NAT_GATEWAY_ID"

#route InternetGateway <--> route table B
  aws ec2 create-route --route-table-id "$ROUTE_TABLE_ID_B" \
    --destination-cidr-block 0.0.0.0/0 \
      --gateway-id "$INTERNET_GATEWAY_ID"



#associate route table to subnet 

#routeA
 aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID_A" --subnet-id "$SUBNET_ID0"
 aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID_A" --subnet-id "$SUBNET_ID1"

#routeB
 aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID_B" --subnet-id "$SUBNET_ID2"
 aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID_B" --subnet-id "$SUBNET_ID3"



#create security groups 

               SECURITY_GROUP1_ID=$(aws ec2 create-security-group \
                  --group-name "My-Web-Sec-Group" \
                    --description "My Web Security Group" \
                       --vpc-id "$VPC_ID" \
                           --query 'GroupId' \
                             --output text )
        export SECURITY_GROUP1_ID
      aws ec2 create-tags --resources "$SECURITY_GROUP1_ID" --tags Key=Name,Value=sec-grp-1 --output text


#authurize SSH
 aws ec2 authorize-security-group-ingress \
   --group-id  "$SECURITY_GROUP1_ID"  \
     --protocol tcp --port 22 --cidr 0.0.0.0/0



               SECURITY_GROUP2_ID=$(aws ec2 create-security-group \
                  --group-name "My-DB-Sec-Group" \
                    --description "My DB Security Group" \
                       --vpc-id "$VPC_ID" \
                         --query 'GroupId' \
                          --output text )
        export SECURITY_GROUP2_ID
         aws ec2 create-tags --resources "$SECURITY_GROUP2_ID" --tags Key=Name,Value=sec-grp-2 --output text


  #authurize SSH
    aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP2_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0





#create key pair 
aws ec2 create-key-pair --key-name Key_a --query 'KeyMaterial' --output text > Key_a.pem

chmod 400 Key_a.pem 


#create instances 

INSTANCE1_ID=$(aws ec2 run-instances \
   --image-id ami-03f65b8614a860c29\
    --instance-type t2.micro \
     --key-name Key_a \
        --subnet-id "$SUBNET_ID2" \
          --security-group-ids "$SECURITY_GROUP1_ID" \
            --output text \
              --query 'Instances[0].InstanceId')

export INSTANCE1_ID

aws ec2 create-tags --resources "$INSTANCE1_ID" --tags Key=Name,Value=Web_ec2


INSTANCE2_ID=$(aws ec2 run-instances \
   --image-id ami-03f65b8614a860c29\
    --instance-type t2.micro \
     --key-name Key_a \
        --subnet-id "$SUBNET_ID0" \
          --security-group-ids "$SECURITY_GROUP2_ID" \
            --output text \
              --query 'Instances[0].InstanceId')

export INSTANCE2_ID

aws ec2 create-tags --resources "$INSTANCE2_ID" --tags Key=Name,Value=DB_ec2