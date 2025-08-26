variable "name" {
  description = "Prefix name for monitoring resources"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group to monitor"
  type        = string
}

variable "alert_email" {
  description = "Email address for SNS alerts"
  type        = string
}
