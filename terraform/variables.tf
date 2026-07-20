variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "VPC_NAME" {
  default = "vprofile-VPC"
}

variable "VpcCIDR" {
  default = "172.21.0.0/16"
}
variable "PROJECT" {
  default = "DevOps assessment"
}
variable "Zone1" {
  default = "us-east-1a"
}
variable "Zone2" {
  default = "us-east-1b"
}
variable "Zone3" {
  default = "us-east-1c"
}
variable "PubSub1CIDR" {
  default = "172.21.1.0/24"
}
variable "PubSub2CIDR" {
  default = "172.21.2.0/24"
}
variable "PubSub3CIDR" {
  default = "172.21.3.0/24"
}

variable "PrivSub1CIDR" {
  default = "172.21.4.0/24"
}
variable "PrivSub2CIDR" {
  default = "172.21.5.0/24"
}
variable "PrivSub3CIDR" {
  default = "172.21.6.0/24"
}

variable "DbSub1CIDR" {
  default = "172.21.7.0/24"
}
variable "DbSub2CIDR" {
  default = "172.21.8.0/24"
}
variable "DbSub3CIDR" {
  default = "172.21.9.0/24"
}