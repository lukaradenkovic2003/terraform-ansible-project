module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.VPC_NAME
  cidr = var.VpcCIDR

  azs             = [var.Zone1, var.Zone2, var.Zone3]
  private_subnets = [var.PrivSub1CIDR, var.PrivSub2CIDR, var.PrivSub3CIDR]
  public_subnets  = [var.PubSub1CIDR, var.PubSub2CIDR, var.PubSub3CIDR]
database_subnets = [var.DbSub1CIDR, var.DbSub2CIDR, var.DbSub3CIDR]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
create_database_subnet_route_table = true

  tags = {
    Name    = var.VPC_NAME
    Project = var.PROJECT
  }
}