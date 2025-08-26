variable "region" {
  type = string
}

variable "name" {
  type        = string
  description = "Environment name (used as prefix)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs (one per AZ)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs (one per AZ)"
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default = {
    Environment = "dev"
    Project     = "web-platform"
  }
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}


