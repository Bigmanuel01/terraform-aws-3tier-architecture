variable "region" {
  type = string
}

variable "name" {
  type = string
}

# VPC
variable "vpc_cidr" {
  type = string
}

# 2 AZs in eu-north-1 → give 2 CIDRs each
variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "tags" {
  description = "Map of common tags to apply to resources"
  type        = map(string)
  default     = {}
}
