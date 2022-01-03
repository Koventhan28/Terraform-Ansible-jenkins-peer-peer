# VPC in North Virginia Region
resource "aws_vpc" "vpc_master" {
  provider         = aws.region-master
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  # Making Hardware stick to one customer like Intel or AMD
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "master-vpc-jenkins"
  }
}
# VPC in Oregon Region
resource "aws_vpc" "vpc_master_oregon" {
  provider             = aws.region-worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  # Making Hardware stick to one customer like Intel or AMD
  tags = {
    Name = "worker-vpc-jenkins"
  }
}

# Internet Gateway for North Virginia region
resource "aws_internet_gateway" "igw" {
  vpc_id   = aws_vpc.vpc_master.id
  provider = aws.region-master
}

# Internet Gateway for Oregon region
resource "aws_internet_gateway" "igw-oregon" {
  vpc_id   = aws_vpc.vpc_master_oregon.id
  provider = aws.region-worker
}
# All Available AZ in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}

# Subnet #1 in us-east-1
resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.vpc_master.id
  provider          = aws.region-master
  cidr_block        = "10.0.1.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
}
# Subnet #2 in us-east-1
resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.2.0/24"
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
}

#Subnet #1 in us-west-2
resource "aws_subnet" "subnet_1_oregon" {
  vpc_id     = aws_vpc.vpc_master_oregon.id
  cidr_block = "192.168.1.0/24"
  provider   = aws.region-worker
  //availability_zone = element(data.aws_availability_zones.azs.names,)
}

# Multi Region VPC peering connection and route table
# Initiate Peering Connection request from us-east-1
resource "aws_vpc_peering_connection" "useast1-uswest2" {
  provider    = aws.region-master
  vpc_id      = aws_vpc.vpc_master.id
  peer_vpc_id = aws_vpc.vpc_master_oregon.id
  peer_region = var.region-worker

}
# Accepting VPC peering request in us-east-2 from us-east-1
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  auto_accept               = true

}

# Rotuing Table in us-east-1
resource "aws_route_table" "internet_route" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }
  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Master-Region-RT"
  }
}

# Overwrite Default route table fo VPC(Master) with our route table entries
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id

}
# Rotuing Table in us-east-1
resource "aws_route_table" "internet_route_oregon" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_master_oregon.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-oregon.id

  }
  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id

  }
  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "Worker-Region-RT"
  }
}
# # Overwrite Default route table fo VPC(Worker) with our route table entries
resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  provider       = aws.region-worker
  route_table_id = aws_route_table.internet_route_oregon.id
  vpc_id         = aws_vpc.vpc_master_oregon.id

}