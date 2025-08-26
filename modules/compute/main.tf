# --- Load Balancer ---
resource "aws_lb" "app_lb" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_sg_id]

  tags = merge(var.tags, {
    Name = "${var.name}-alb"
  })
}

# --- Target Group ---
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-tg"
  })
}

# --- Listener ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# --- Launch Template ---
resource "aws_launch_template" "app_lt" {
  name_prefix            = "${var.name}-lt"
  image_id               = var.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [var.web_sg_id] # web SG for EC2s

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "Welcome to my EC2 behind ALB" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name}-ec2"
    })
  }
}

# --- Auto Scaling Group ---
resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.name}-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-ec2"
    propagate_at_launch = true
  }
}

# scaling policy
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}
