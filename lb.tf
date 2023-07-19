
resource "aws_lb_target_group" "gameshop_target_group" {
  name     = "gameshop-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.gameshop-vpc.id
  target_type = "ip"    

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "gameshop-alb-listener" {
  load_balancer_arn = aws_lb.gameshop_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gameshop_target_group.arn
  }
}


resource "aws_lb" "gameshop_load_balancer" {
  name               = "gameshop-load-balancer"
  internal           = false  # Set to true if you want an internal load balancer within a VPC
  load_balancer_type = "application"
#   count = length(var.gameshop-public-subnet-var)
  security_groups    = [aws_security_group.gameshop_lb_security_group.id]
  subnets            =  aws_subnet.public-subnet-A[*].id 

  tags = {
    Name = "gameshop-load-balancer"
  }
}

resource "aws_security_group" "gameshop_lb_security_group" {
  name        = "my-lb-security-group"
  description = "Security group for my load balancer"
  vpc_id = aws_vpc.gameshop-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-lb-security-group"
  }
}
