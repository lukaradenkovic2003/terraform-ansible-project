data "aws_ami" "Ubuntu22ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.Ubuntu22ami.id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.private_subnets[count.index]
  count                  = var.instance_count
  vpc_security_group_ids = [aws_security_group.devops-assessment-ec2-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_s3_profile.name

  tags = {
    Name    = "${var.PROJECT}-ec2-${count.index + 1}"
    Project = var.PROJECT
  }
}