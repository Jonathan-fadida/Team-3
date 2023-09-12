#!/bin/bash 

#####              Configure aws Keys                     ######

 paste="[default]
aws_access_key_id=ASIAYZ4IP6N3PHKDRPTJ
aws_secret_access_key=Q3JuLInlyf4/cv0wJNkAbyxXVVoVraZSg3Iw8xcz
aws_session_token=FwoGZXIvYXdzEI///////////wEaDNc/5Xp4028vagd4RCK/AaKWLjWB4PDplhHtvPPiziXuInoItawzs5BnyOKVtDJH3A7TwIYU7vMlGq0oS/dHiYJLSYja5BGikXGCYGgNj08zAysSSLbkxhExxVsrUqxdSupA1poPUIQqaOmH/op7F5uIn0Rk6UFHqNhay2rOdVVfnSh9yyIqeHdy3JAEbD5B3OMY3FU99BNU62zl7aSxNVNGa7TUOv+ou+AGeyEjVZM76xKJs0JpT5buATYeiK9mhx9BVHWecYd4gL7V17yPKJmE26cGMi3k8hopRKk8efmByBEK/LNxF1YL30rE0A1YAre7MYtnFNqIOBFGUdw3t2cnl/8="
 
 access_key_id=$(echo $paste | grep -oP 'aws_access_key_id=\K[^ ]+')
 secret_access_key=$(echo $paste | grep -oP 'aws_secret_access_key=\K[^ ]+')
 session_token=$(echo $paste | grep -oP 'aws_session_token=\K[^ ]+')

 aws configure set aws_access_key_id "$access_key_id"
 aws configure set aws_secret_access_key "$secret_access_key"
 aws configure set aws_session_token "$session_token"


#________________________________________________________________
#####                   VPC Variables                       ######
 vpc_cidr="10.0.10.0/16"
 vpc_name="MY-VPC"
#________________________________________________________________
#######                 SUBNET Variables                   ######
 subnet_0_cidr="10.0.0.0/24"
 subnet_0_name=pub-sub-0
 
 subnet_1_cidr="10.0.10.0/24"
 subnet_1_name=pri-sub-10

 subnet_2_cidr="10.0.20.0/24"
 subnet_2_name=pub-sub-20

 subnet_3_cidr="10.0.30.0/24"
 subnet_3_name=pri-sub-30

#________________________________________________________________
#######                Availability Zones                 ######
 availability_zone_A="us-west-2a"
 availability_zone_B="us-west-2b"
#################################################################
#################################################################
#################################################################
#################################################################

#######                    VPC                            ######

        VPC_ID=$(aws ec2 create-vpc --cidr-block  "$vpc_cidr"  --query 'Vpc.VpcId'  --output text)
         export VPC_ID

 #echo $VPC_ID 

 #assign a name to the VPC

 aws ec2 create-tags --resources "$VPC_ID" --tags Key=Name,Value="$vpc_name"



#________________________________________________________________
######                    SUBNETS                          ######
#0
    SUBNET_ID0=$(aws ec2 create-subnet \
        --vpc-id "$VPC_ID"    \
           --cidr-block "$subnet_0_cidr"  \
             --availability-zone "$availability_zone_A" \
              --query 'Subnet.SubnetId' \
               --output text)
     
     export SUBNET_ID0
         aws ec2 create-tags --resources "$SUBNET_ID0" --tags Key=Name,Value=$subnet_0_name
#1
    SUBNET_ID1=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
      --cidr-block "$subnet_1_cidr" \
       --availability-zone "$availability_zone_A" \
         --query 'Subnet.SubnetId' \
           --output text)

        export SUBNET_ID1
         aws ec2 create-tags --resources "$SUBNET_ID1" --tags Key=Name,Value=$subnet_1_name
#2
    SUBNET_ID2=$(aws ec2 create-subnet \
       --vpc-id "$VPC_ID" \
         --cidr-block "$subnet_2_cidr" \
            --availability-zone $availability_zone_B \
               --query 'Subnet.SubnetId' \
                --output text)

    export SUBNET_I2
         aws ec2 create-tags --resources "$SUBNET_ID2" --tags Key=Name,Value=$subnet_2_name        
#3
    SUBNET_ID3=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
      --cidr-block $subnet_3_cidr \
        --availability-zone $availability_zone_B \
          --query 'Subnet.SubnetId' \
            --output text)

     export SUBNET_ID3
         aws ec2 create-tags --resources "$SUBNET_ID3" --tags Key=Name,Value=$subnet_3_name




#________________________________________________________________
#####                      Gateway                        ######


    INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway \
     --query 'InternetGateway.InternetGatewayId' \
       --output text)
     
     export INTERNET_GATEWAY_ID

     #assign a name to the InternetGateway
     aws ec2 create-tags --resources "$INTERNET_GATEWAY_ID" --tags Key=Name,Value=GateWay

     #attach to vpc 
      aws ec2 attach-internet-gateway --internet-gateway-id "$INTERNET_GATEWAY_ID" --vpc-id "$VPC_ID"
#________________________________________________________________    
######             ELASTIC ip for the NatGateway          ######
    ELASTIC_IP_ID=$(aws ec2 allocate-address \
     --query 'AllocationId' \
      --output text)

     export ELASTIC_IP_ID 
    
    ELASTIC_IP=$(aws ec2 describe-addresses \
      --allocation-ids "$ELASTIC_IP_ID"  \
        --query 'Addresses[0].PublicIp' \
          --output text)
     
     export Elastic_IP
#________________________________________________________________
######                 Nate gateway                       #######
 NAT_GATEWAY_ID=$(aws ec2 create-nat-gateway \
   --subnet-id "$SUBNET_ID0" \
     --allocation-id "$ELASTIC_IP_ID"  \
     --query 'NatGateway.NatGatewayId'  \
     --output text) 

 export NAT_GATEWAY_ID  

#________________________________________________________________
#####                  create Route Tables 

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


#________________________________________________________________
#             ------------create routes--------------- 
####          route NAT Gateway <--> route table A

 aws ec2 create-route --route-table-id "$ROUTE_TABLE_ID_A" \
   --destination-cidr-block 0.0.0.0/0 \
     --gateway-id "$NAT_GATEWAY_ID"

####              route InternetGateway <--> route table B
  aws ec2 create-route --route-table-id "$ROUTE_TABLE_ID_B" \
    --destination-cidr-block 0.0.0.0/0 \
      --gateway-id "$INTERNET_GATEWAY_ID"


#            -----------------------------------------      
####               associate route table to subnet 
#routeA
 aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID_A" --subnet-id "$SUBNET_ID0"
 aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID_A" --subnet-id "$SUBNET_ID1"

#routeB
 aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID_B" --subnet-id "$SUBNET_ID2"
 aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID_B" --subnet-id "$SUBNET_ID3"


#________________________________________________________________
#                       Security groups                     #####

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




#________________________________________________________________
######                   create key pair                    #####
   if ! [[  -e "Key.pem" ]] ; then
        aws ec2 create-key-pair --key-name Key --query 'KeyMaterial' --output text > Key.pem

          chmod 400 Key.pem 
    fi
#________________________________________________________________
#####                     create instances                  #####
#I1
 INSTANCE1_ID=$(aws ec2 run-instances \
   --image-id ami-03f65b8614a860c29\
    --instance-type t2.micro \
     --key-name Key \
        --subnet-id "$SUBNET_ID2" \
          --security-group-ids "$SECURITY_GROUP1_ID" \
            --output text \
              --query 'Instances[0].InstanceId')

 export INSTANCE1_ID

 aws ec2 create-tags --resources "$INSTANCE1_ID" --tags Key=Name,Value=Web_ec2



  ELASTIC_IP_ID_1=$(aws ec2 allocate-address \
     --query 'AllocationId' \
      --output text)

     export ELASTIC_IP_ID_1 
   

#I2
 INSTANCE2_ID=$(aws ec2 run-instances \
   --image-id ami-03f65b8614a860c29\
    --instance-type t2.micro \
     --key-name Key \
        --subnet-id "$SUBNET_ID0" \
          --security-group-ids "$SECURITY_GROUP2_ID" \
            --output text \
              --query 'Instances[0].InstanceId')

 export INSTANCE2_ID

 aws ec2 create-tags --resources "$INSTANCE2_ID" --tags Key=Name,Value=DB_ec2




#attach Ip to Instance 

 ELASTIC_IP_ID_1=$(aws ec2 allocate-address \
     --query 'AllocationId' \
      --output text)

     export ELASTIC_IP_ID_1 


 while true ; do

 instance_state=$(aws ec2 describe-instances --instance-ids "$INSTANCE1_ID" --query 'Reservations[0].Instances[0].State.Name' --output text)
 
 if [[ $instance_state == "running" ]]; then

  aws ec2 associate-address --instance-id $INSTANCE1_ID --allocation-id $ELASTIC_IP_ID_1
  break
  else 
  sleep 10 
  
 fi

 done 

 echo "Your VPC Is Ready !!! "
