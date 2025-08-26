variable "name" {
  description = "Prefix name for compute resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will run"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
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

variable "web_sg_id" {
  description = "Security group ID for web tier"
  type        = string
}

variable "tags" {
  description = "Common tags to apply"
  type        = map(string)
}

variable "alb_sg_id" {
  type        = string
  description = "Security group for the ALB"
}
