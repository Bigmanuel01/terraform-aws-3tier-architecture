output "web_sg_id" {
  value = aws_security_group.web_sg.id
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.project_vpc.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}


