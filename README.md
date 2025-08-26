# Terraform Web Platform

This project provisions a highly available 3-tier web platform on AWS using Terraform.  
It is structured into modules for networking, compute, database, and monitoring.

## Project Structure

terraform-web-platform/
├── environments/
│ ├── dev/
│ │ ├── main.tf
│ │ ├── terraform.tfvars
│ │ └── vars.tf
│ └── prod/
│ ├── main.tf
│ ├── terraform.tfvars
│ └── vars.tf
├── modules/
│ ├── networking/
│ ├── compute/
│ ├── database/
│ ├── monitoring/
├── README.md
└── .gitignore

## What It Does

- **Networking**  
  Creates a VPC with public and private subnets, internet gateway, NAT gateway, and security groups.

- **Compute**  
  Launches an Auto Scaling Group (ASG) of EC2 instances behind an Application Load Balancer (ALB).  
  User data installs Apache (`httpd`) and serves a simple web page.  
  Instances scale out/in automatically based on CPU utilization.

- **Database**  
  Deploys an RDS MySQL instance in private subnets with automated backups and a parameter group.  
  Credentials are stored in `secret-<env>.auto.tfvars` files (not committed to Git).

- **Monitoring**  
  Sets up CloudWatch alarms to monitor EC2 CPU utilization and trigger ASG scaling.  
  Alarms can also send notifications through SNS.

## Usage

1. Clone the repository.
2. Navigate to the desired environment (e.g. `environments/dev`).
3. Initialize Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Stress Testing Auto Scaling

To test the Auto Scaling policy, SSH or SSM into an EC2 instance and run:
stress --cpu 4 --timeout 600

This will push CPU utilization above the CloudWatch threshold and trigger new instances to be launched by the ASG.

## Notes

Sensitive variables (db_username, db_password) are kept in secret-\*.auto.tfvars, which are ignored by Git.

The setup is modular, so you can extend or reuse pieces (e.g., add caching, more monitoring, etc.).
