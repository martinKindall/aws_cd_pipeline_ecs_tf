
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnets" "mySubnets" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

resource "aws_lb_target_group" "my_Tg" {
  name        = "tf-example-lb-tg"
  port        = "80"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_lb_target_group" "my_Tg_2" {
  name        = "tf-example-lb-tg-2"
  port        = "80"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_lb" "myAlb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.spring_app.id]
  subnets            = data.aws_subnets.mySubnets.ids
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.myAlb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_Tg.arn
  }
}