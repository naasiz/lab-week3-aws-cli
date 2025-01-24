#!/usr/bin/env bash

set -eu

region="us-west-2"
vpc_cidr="10.0.0.0/16"
subnet_cidr="10.0.1.0/24"
key_name="bcitkey"

echo "Creating VPC..."
vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --query 'Vpc.VpcId' --output text --region $region)
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=MyVPC --region $region

echo "Enabling DNS hostnames..."
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-hostnames Value=true

echo "Creating Subnet..."
subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id \
  --cidr-block $subnet_cidr \
  --availability-zone ${region}a \
  --query 'Subnet.SubnetId' \
  --output text --region $region)

aws ec2 create-tags --resources $subnet_id --tags Key=Name,Value=PublicSubnet --region $region

echo "Creating Internet Gateway..."
igw_id=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' \
  --output text --region $region)

aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $igw_id --region $region

echo "Creating Route Table..."
route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id \
  --query 'RouteTable.RouteTableId' \
  --region $region \
  --output text)

aws ec2 associate-route-table --subnet-id $subnet_id --route-table-id $route_table_id --region $region

aws ec2 create-route --route-table-id $route_table_id \
  --destination-cidr-block 0.0.0.0/0 --gateway-id $igw_id --region $region

echo "Creating EC2 instance..."
ubuntu_ami="ami-0abcdef1234567890"  # Replace with actual AMI ID
security_group_id="sg-0123456789abcdef"
instance_id=$(aws ec2 run-instances --image-id $ubuntu_ami --count 1 --instance-type t2.micro \
  --key-name $key_name --security-group-ids $security_group_id --query 'Instances[0].InstanceId' --output text)

aws ec2 wait instance-running --instance-ids $instance_id

public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "EC2 Instance Public IP: $public_ip"
echo "vpc_id=${vpc_id}" > infrastructure_data
echo "subnet_id=${subnet_id}" >> infrastructure_data
echo "Public IP: $public_ip" > instance_data.txt
