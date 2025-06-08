#Configure VPC resource
resource "aws_vpc" "dsa_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-vpc"
 })
}

#Configure IGW resource 
resource "aws_internet_gateway" "dsa_igw" {
  vpc_id = aws_vpc.dsa_vpc.id

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}

#Configure Subnets (Public/Private)
resource "aws_subnet" "dsa_public_subnet_az_1a" {
  vpc_id     = aws_vpc.dsa_vpc.id
  cidr_block = var.public_cidr_block[0]
  availability_zone = var.availability_zone[0]

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1a"
  })
}

resource "aws_subnet" "dsa_public_subnet_az_1b" {
  vpc_id     = aws_vpc.dsa_vpc.id
  cidr_block = var.public_cidr_block[1]
  availability_zone = var.availability_zone[1]

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1b"
  })
}

resource "aws_subnet" "dsa_private_subnet_az_1a" {
  vpc_id     = aws_vpc.dsa_vpc.id
  cidr_block = var.private_cidr_block[0]
  availability_zone = var.availability_zone[0]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1a"
  })
}

resource "aws_subnet" "dsa_private_subnet_az_1b" {
  vpc_id     = aws_vpc.dsa_vpc.id
  cidr_block = var.private_cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1b"
  })
}

resource "aws_subnet" "dsa_backend_subnet_az_1a" {
  vpc_id     = aws_vpc.dsa_vpc.id
  cidr_block = var.private_cidr_block[2]
  availability_zone = var.availability_zone[0]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-backend-subnet-az-1a"
  })
}

resource "aws_subnet" "dsa_backend_subnet_az_1b" {
  vpc_id     = aws_vpc.dsa_vpc.id
  cidr_block = var.private_cidr_block[3]
  availability_zone = var.availability_zone[1]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-backend-subnet-az-1b"
  })
}

#Configure Route table resource: Public Rt
resource "aws_route_table" "dsa_public_rt" {
  vpc_id = aws_vpc.dsa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dsa_igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
  })
}

#Configure Route table resource association: Public Rt
resource "aws_route_table_association" "dsa_public_subnet_az_1a_associate" {
  subnet_id      = aws_subnet.dsa_public_subnet_az_1a.id
  route_table_id = aws_route_table.dsa_public_rt.id
}

resource "aws_route_table_association" "apci_public_subnet_az_1b_associate" {
  subnet_id      = aws_subnet.dsa_public_subnet_az_1b.id
  route_table_id = aws_route_table.dsa_public_rt.id
}

#==================================================================================================================================================
# Configurations for Resources in AZ-1A

#Configure Elastic IP for Nat-Gateway in AZ-1a
resource "aws_eip" "dsa_eip_az_1a" {
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-1a"
  })
}

#Configure Nat-Gateway in a public subnet in AZ-1a
resource "aws_nat_gateway" "dsa_nat_gw_az_1a" {
  allocation_id = aws_eip.dsa_eip_az_1a.id
  subnet_id     = aws_subnet.dsa_public_subnet_az_1a.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-1a"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.dsa_igw]
}

#Configure Route table resources: Private Route table - AZ-1a
resource "aws_route_table" "dsa_private_rt_az_1a" {
  vpc_id = aws_vpc.dsa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dsa_nat_gw_az_1a.id
  }
  
   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt-az-1a"
  })
}

#Configure Route Table Association: Private Subnets in AZ-1a 
resource "aws_route_table_association" "dsa_private_subnet_az_1a_associate" {
  subnet_id      = aws_subnet.dsa_private_subnet_az_1a.id
  route_table_id = aws_route_table.dsa_private_rt_az_1a.id
}

resource "aws_route_table_association" "dsa_backend_subnet_az_1a_associate" {
  subnet_id      = aws_subnet.dsa_backend_subnet_az_1a.id
  route_table_id = aws_route_table.dsa_private_rt_az_1a.id
}

#==================================================================================================================================================
#Configurations for Resources in AZ-1B

#Configure Elastic IP for Nat-Gateway in AZ-1b
resource "aws_eip" "dsa_eip_az_1b" {
  domain   = "vpc"
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-1b"
  })
}

#Configure Nat-Gateway in a public subnet in AZ-1b
resource "aws_nat_gateway" "dsa_nat_gw_az_1b" {
  allocation_id = aws_eip.dsa_eip_az_1b.id
  subnet_id     = aws_subnet.dsa_public_subnet_az_1b.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-1b"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.dsa_igw]
}

#Configure Route table resources: Private Route table - AZ-1b
resource "aws_route_table" "dsa_private_rt_az_1b" {
  vpc_id = aws_vpc.dsa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dsa_nat_gw_az_1b.id
  }
  
   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt-az-1b"
  })
}

#Configure Route Table Association: Private Subnets in AZ-1ab
resource "aws_route_table_association" "dsa_private_subnet_az_1b_associate" {
  subnet_id      = aws_subnet.dsa_private_subnet_az_1b.id
  route_table_id = aws_route_table.dsa_private_rt_az_1b.id
}

resource "aws_route_table_association" "dsa_backend_subnet_az_1b_associate" {
  subnet_id      = aws_subnet.dsa_backend_subnet_az_1b.id
  route_table_id = aws_route_table.dsa_private_rt_az_1b.id
}

