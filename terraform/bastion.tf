resource "aws_security_group" "bastion-sg" {
  name        = "devops-assessment-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name    = "devops-assessment-bastion"
    Project = var.PROJECT
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_bastion" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4          = "94.189.237.54/32"
  ip_protocol        = "tcp"
  from_port          = 22
  to_port            = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_bastion" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4          = "0.0.0.0/0"
  ip_protocol        = "-1"
}


resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.Ubuntu22ami.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.devops_key.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  associate_public_ip_address = true

  tags = {
    Name    = "${var.PROJECT}-bastion"
    Project = var.PROJECT
  }
}