resource "aws_security_group" "devops-assessment-alb-sg" {
  name        = "devops-assessment-alb-sg"
  description = "Security group for alb"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name      = "devops-assessment-alb"
    ManagedBy = "Terraform"
    Project   = "DevOps assessment"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_forALB" {
  security_group_id = aws_security_group.devops-assessment-alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80

}
resource "aws_vpc_security_group_ingress_rule" "allow_https_forALB" {
  security_group_id = aws_security_group.devops-assessment-alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_fromALB" {
  security_group_id = aws_security_group.devops-assessment-alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

