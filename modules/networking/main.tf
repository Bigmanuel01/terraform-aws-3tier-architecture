data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}


resource "aws_vpc" "project_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.name}-vpc" })
}

# Availability Zone 1: One public subnet AND one private subnet.

# Availability Zone 2: One public subnet AND one private subnet.

# Public subnets (2 AZs)
resource "aws_subnet" "public" {
  for_each = {
    for idx, cidr in var.public_subnet_cidrs : idx => {
      cidr = cidr
      az   = data.aws_availability_zones.available.names[idx]
    }
  }

  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name}-public-subnet-${each.key}"
  })
}

# Private subnets (2 AZs)
resource "aws_subnet" "private" {
  for_each = {
    for idx, cidr in var.private_subnet_cidrs : idx => {
      cidr = cidr
      az   = data.aws_availability_zones.available.names[idx]
    }
  }

  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = "${var.name}-private-subnet-${each.key}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  for_each = { for k, v in aws_subnet.public : k => v }

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name}-nat-eip-${each.key}"
  })
}

# NAT Gateways (aligned with public subnets)
resource "aws_nat_gateway" "project_nat" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = merge(var.tags, {
    Name = "${var.name}-nat-${each.key}"
  })

  depends_on = [aws_internet_gateway.project_igw]
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.project_vpc.id

  tags = merge(var.tags, {
    Name = "${var.name}-public-rt"
  })
}

# Default route in public RT
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.project_igw.id
}

# Associate public subnets
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route table for private subnets
# Private Route Tables (each AZ gets its own NAT)
resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.project_nat[each.key].id
  }

  tags = merge(var.tags, {
    Name = "${var.name}-private-rt-${each.key}"
  })
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# ALB SG
resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb-sg"
  description = "Allow inbound HTTP/HTTPS from internet"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-alb-sg"
  })
}


# Web Security Group (for ALB/EC2)
resource "aws_security_group" "web_sg" {
  name        = "${var.name}-web-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # only ALB can talk to EC2
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-web-sg"
  })
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "${var.name}-db-sg"
  description = "Allow MySQL from web tier"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    description     = "MySQL from web SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-db-sg"
  })
}
