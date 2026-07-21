# Self-signed sertifikat (generisan lokalno, uvezen u AWS)
resource "tls_private_key" "self_signed" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "self_signed" {
  private_key_pem = tls_private_key.self_signed.private_key_pem

  subject {
    common_name  = "devops-assessment.local"
    organization = var.PROJECT
  }

  validity_period_hours = 8760 # 1 godina

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "self_signed" {
  private_key      = tls_private_key.self_signed.private_key_pem
  certificate_body  = tls_self_signed_cert.self_signed.cert_pem
}

# Application Load Balancer
resource "aws_lb" "devops_assessment_alb" {
  name               = "${var.PROJECT}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.devops-assessment-alb-sg.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Name    = "${var.PROJECT}-alb"
    Project = var.PROJECT
  }
}

# Target Group
resource "aws_lb_target_group" "devops_assessment_tg" {
  name     = "${var.PROJECT}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name    = "${var.PROJECT}-tg"
    Project = var.PROJECT
  }
}

# Povezivanje svake EC2 instance sa target group-om
resource "aws_lb_target_group_attachment" "devops_assessment_tg_attach" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.devops_assessment_tg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# Listener na portu 80 - redirect ka 443
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.devops_assessment_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listener na portu 443 - prosleđuje ka target group
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.devops_assessment_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.self_signed.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devops_assessment_tg.arn
  }
}