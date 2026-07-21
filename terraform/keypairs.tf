resource "aws_key_pair" "devops_key" {
  key_name   = "${var.PROJECT}-key"
  public_key = file("./devops-key.pub")
}