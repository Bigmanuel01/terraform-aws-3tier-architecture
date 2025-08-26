variable "name" {
  description = "Prefix name for compute resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will run"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EC2/ASG"
  type        = list(string)
}

variable "tags" {
  description = "Common tags to apply"
  type        = map(string)
}

variable "db_sg_id" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}


variable "db_password" {
  type = string
}
