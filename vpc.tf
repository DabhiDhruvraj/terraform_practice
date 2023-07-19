provider "aws" {
    region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "gameshop-vpc" {
  cidr_block = "10.0.0.0/16"
  
  # Enabling automatic hostname assigning
  enable_dns_hostnames = true
  tags = {
    Name = "gameshop-vpc"
  }
}
# Create public Subnet
resource "aws_subnet" "public-subnet-A" {
  depends_on = [
    aws_vpc.gameshop-vpc
  ]
  count = length(var.gameshop-public-subnet-var)
  vpc_id = aws_vpc.gameshop-vpc.id
  cidr_block = var.gameshop-public-subnet-var[count.index]
  availability_zone = "us-east-1${element(["a","b","c"], count.index)}"
  tags = {
    Name = "gameshop-public-subnet-${element(["A","B","C"], count.index)}"
  }
}
# Creating Private subnet!
resource "aws_subnet" "private-subnet-A" {
  depends_on = [
    aws_vpc.gameshop-vpc,   
  ]
  count = length(var.gameshop-private-subnet-var)
  vpc_id = aws_vpc.gameshop-vpc.id
  cidr_block = var.gameshop-private-subnet-var[count.index]
  availability_zone = "us-east-1${element(["a","b","c"], count.index)}"
  tags = {
    Name = "gameshop-private-subnet-${element(["A","B","C"], count.index)}"
  }
}
# Creating DataBase Private subnet!
resource "aws_subnet" "Db-private-subnet-A" {
  depends_on = [
    aws_vpc.gameshop-vpc,   
  ]
  count = length(var.gameshop-db-private-subnet-var)
  vpc_id = aws_vpc.gameshop-vpc.id
  cidr_block = var.gameshop-db-private-subnet-var[count.index]
  availability_zone = "us-east-1${element(["a","b","c"], count.index)}"
  tags = {
    Name = "gameshop-Db-private subnet-${element(["A","B","C"], count.index)}"
  }
}
#Create Internet Gateway
resource "aws_internet_gateway" "gameshop-Internet_Gateway" {
  depends_on = [
    aws_vpc.gameshop-vpc,
    aws_subnet.public-subnet-A,
  ]
  
  vpc_id = aws_vpc.gameshop-vpc.id

  tags = {
    Name = "gameshop-Internet-Gateway"
  }
}
# Creating an Route Table for the public subnet!
resource "aws_route_table" "Public-Subnet-RT" {
  depends_on = [
    aws_vpc.gameshop-vpc,
    aws_internet_gateway.gameshop-Internet_Gateway
  ]
  vpc_id = aws_vpc.gameshop-vpc.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gameshop-Internet_Gateway.id
  }

  tags = {
    Name = "public-route-table"
  }
}
# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "gameshop-Nat-Gateway-EIP" {
  
  vpc = true
}
# Creating a NAT Gateway!
resource "aws_nat_gateway" "gameshop-NAT_GATEWAY" {
  depends_on = [
    aws_eip.gameshop-Nat-Gateway-EIP
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.gameshop-Nat-Gateway-EIP.id
  
  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.public-subnet-A[0].id
  tags = {
    Name = "gameshop-Nat-Gateway"
  }
}

# Creating an Route Table for the private subnet!
resource "aws_route_table" "Private-Subnet-RT" {
  depends_on = [
    aws_nat_gateway.gameshop-NAT_GATEWAY,
  ]
  vpc_id = aws_vpc.gameshop-vpc.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gameshop-NAT_GATEWAY.id
  }

  tags = {
    Name = "private-route-table"
  }
}
# Creating a resource for the public Route Table Association!
resource "aws_route_table_association" "Public-Subnet-RT-AS" {

  depends_on = [
    aws_route_table.Public-Subnet-RT
  ]
  count = length(aws_subnet.public-subnet-A)
  route_table_id = aws_route_table.Public-Subnet-RT.id
    subnet_id      = aws_subnet.public-subnet-A[count.index].id
}
# Creating a resource for the Private Route Table Association!
resource "aws_route_table_association" "Private-Subnet-RT-AS" {

  depends_on = [
    aws_route_table.Private-Subnet-RT
  ]
  count = length(aws_subnet.private-subnet-A)
  route_table_id = aws_route_table.Private-Subnet-RT.id
    subnet_id = aws_subnet.private-subnet-A[count.index].id
}

resource "aws_route_table_association" "Private-Subnet-RT-AS1" {

  depends_on = [
    aws_route_table.Private-Subnet-RT
  ]
  count = length(aws_subnet.Db-private-subnet-A)
  route_table_id = aws_route_table.Private-Subnet-RT.id
    subnet_id = aws_subnet.Db-private-subnet-A[count.index].id
}