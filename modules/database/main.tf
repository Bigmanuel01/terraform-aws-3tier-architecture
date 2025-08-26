# DB Subnet Group (use private subnets only)
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-db-subnet-group"
  })
}

# DB Parameter Group (optional tuning for MySQL)
resource "aws_db_parameter_group" "mysql_params" {
  name        = "${var.name}-mysql-params"
  family      = "mysql8.0"
  description = "Custom parameter group for MySQL"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  tags = var.tags
}

resource "aws_db_instance" "mysql" {
  identifier            = "${var.name}-mysql-db"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.mysql_params.name
  vpc_security_group_ids = [var.db_sg_id]

  multi_az = true

  # Automated backups
  backup_retention_period = 7             # keep backups for 7 days
  backup_window           = "02:00-04:00" # UTC time range for backups

  # Maintenance window
  maintenance_window = "sun:05:00-sun:06:00" # UTC weekly window

  skip_final_snapshot = true
  deletion_protection = false

  tags = merge(var.tags, {
    Name = "${var.name}-mysql-db"
  })
}
