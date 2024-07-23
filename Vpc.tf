# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Surya-main-vpc"
  }
}

# Create subnets
resource "aws_subnet" "eks_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Surya-eks-subnet-a"
  }
}

resource "aws_subnet" "eks_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Surya-eks-subnet-b"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Surya-eks-igw"
  }
}

# Create Route Table
resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "Surya-eks-route-table"
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "eks_route_table_association" {
  subnet_id      = aws_subnet.eks_subnet_a.id
  route_table_id = aws_route_table.eks_route_table.id
}

resource "aws_route_table_association" "eks_route_table_association_b" {
  subnet_id      = aws_subnet.eks_subnet_b.id
  route_table_id = aws_route_table.eks_route_table.id
}
