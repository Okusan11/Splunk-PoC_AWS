#--------------------------------------
# SecurityGroup
#--------------------------------------

# https://www.terraform.io/docs/providers/aws/r/security_group.html

resource "aws_security_group" "alb_sg" {
  name        = "miratsuku-alb"
  description = "miratsuku-alb"
  vpc_id      = aws_vpc.miratsuku_vpc_1.id

  # セキュリティグループ内のリソースからインターネットへのアクセスを許可する
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "miratsuku-alb-sg"
  }
}

#--------------------------------------
# SecurityGroup Rule
# ingress http
#--------------------------------------

# https://www.terraform.io/docs/providers/aws/r/security_group.html

resource "aws_security_group_rule" "ingress_http" {
  security_group_id = aws_security_group.alb_sg.id

  # セキュリティグループ内のリソースへインターネットからのアクセスを許可する
  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  cidr_blocks = [local.allowed-cidr]
}

#--------------------------------------
# SecurityGroup Rule
# ingress https
#--------------------------------------

# https://www.terraform.io/docs/providers/aws/r/security_group.html



resource "aws_security_group_rule" "ingress_https" {
  security_group_id = aws_security_group.alb_sg.id

  # セキュリティグループ内のリソースへインターネットからのアクセスを許可する
  type = "ingress"

  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks = [local.allowed-cidr]
}

#--------------------------------------
# ALB
#--------------------------------------

# https://www.terraform.io/docs/providers/aws/d/lb.html

resource "aws_lb" "alb" {
  load_balancer_type = "application"
  name               = "miratsuku-alb"
  security_groups    = ["${aws_security_group.alb_sg.id}"]
  #subnets         = ["${aws_subnet.public_subnet_1a.id}", "${aws_subnet.public_subnet_1c.id}", "${aws_subnet.public_subnet_1d.id}", "${aws_subnet.public_subnet_splunk_1d.id}"]
  subnets            = ["${aws_subnet.public_subnet_splunk_1c.id}", "${aws_subnet.public_subnet_splunk_1d.id}"]
  tags               = {
    Name             = "miratsuku-alb"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "miratsuku-alb-tg"
  port     = 8000
  protocol = "HTTP"
  # vpc_id   = [aws_vpc.pisc_vpc_1.id, aws_vpc.miratsuku_vpc_1.id]
  vpc_id = aws_vpc.miratsuku_vpc_1.id

  health_check {
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.splunk-ec2.id
  port             = 8000
}

resource "aws_lb_listener" "alb-http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = aws_acm_certificate.miratsuku-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
  # depends_on = [ 
  #   aws_acm_certificate_validation.example
  #  ]
}
