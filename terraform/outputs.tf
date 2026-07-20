output "alb_dns_name" {
  description = "DNS ime ALB-a preko kog se pristupa aplikaciji"
  value       = aws_lb.devops_assessment_alb.dns_name
}

output "ec2_private_ips" {
  description = "Privatne IP adrese EC2 instanci"
  value       = aws_instance.web[*].private_ip
}

output "ec2_instance_ids" {
  description = "ID-jevi EC2 instanci"
  value       = aws_instance.web[*].id
}

output "s3_bucket_name" {
  description = "Ime S3 bucket-a za statički sadržaj"
  value       = aws_s3_bucket.static_content.bucket
}

output "vpc_id" {
  description = "ID VPC-a"
  value       = module.vpc.vpc_id
}