# DevOps Assessment – ​​Terraform & Ansible

Infrastructure-as-Code solution for AWS, developed in response to a DevOps assessment task.
Terraform creates the network and compute infrastructure, Ansible installs and configures nginx.

## Task

Design a system that contains:
- 1 VPC with 3 frontend, 3 backend and 3 database subnets (one of each type in 3 AZs)
- 3 route tables: frontend → IGW, backend → NAT, database → blackhole (no outbound route)
- 3 EC2 instances (Ubuntu 22.04 LTS) in different availability zones
- S3 bucket from which EC2 instances download static content for nginx
- Internet-facing ALB listening on 80/443, with 80 → 443 redirect
- Target group connected to EC2 instances on port 80
- (Stretch) Ansible playbook that installs nginx and injects configuration

## Architecture

```text
Internet → IGW → ALB (80/443, HTTPS redirect)
                   │
                   ▼
         Target Group (port 80)
                   │
     ┌─────────────┼─────────────┐
     ▼             ▼             ▼
  EC2 (AZ1)    EC2 (AZ2)     EC2 (AZ3)  ← backend subnets, NAT for egress
   (nginx)      (nginx)       (nginx)
     │
     ▼
S3 bucket (static content, retrieved via IAM role)
```

* **Database subnets:** Exist with blackhole route, no associated resource.
* **Bastion host:** Located in frontend subnet, used only for SSH access for Ansible.

## Project Structure

terraform/ – Terraform code (VPC, EC2, ALB, S3, IAM, bastion, security groups)
ansible/ – Ansible playbook, inventory, and nginx configuration

## Design Notes

- **Self-signed SSL certificate** – ALB 443 listener requires a certificate; since the task does not
specify a domain, the certificate is generated locally via the Terraform `tls` provider and imported
into ACM. Browsers will display an untrusted certificate warning – this is expected.
- **Bastion host** – Not explicitly required in the spec, but is required so that
Ansible (or anyone) can SSH into EC2 instances that are intentionally in a private
(backend) subnet, without direct exposure to the internet.
- **EC2 instances are in a backend (private) subnet** – the frontend subnet would expose them
directly to the internet (bypassing the ALB), and the database subnet has no outbound route (they would not
be able to download packages/S3 content).
- **IAM role** – EC2 instances have instance profiles with `s3:GetObject`/`s3:ListBucket`
permissions, limited to that one bucket only (least privilege).

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI, configured (`aws configure`)
- Ansible (recommended through WSL on Windows, as Ansible does not work natively on Windows)
- SSH key pair (generated manually, see step 2)

## Getting Started

### 1. Generate SSH key pair (once)

```bash
cd terraform
ssh-keygen -t rsa -b 2048 -f ./devops-key
```

### 2. Set your variables

Create `terraform/terraform.tfvars` (not in the repo, create locally):

```hcl
my_ip = "YOUR_PUBLIC_IP/32"
```

(you can find the public IP via `curl ifconfig.me`)

### 3. Create infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 4. Deploy static content to S3

```bash
aws s3 cp index.html s3://<bucket-name-from-output>/index.html
```

### 5. Run Ansible playbook

Update `ansible/inventory.ini` with the private IP addresses and public IP address of the bastion from
`terraform output`, then:

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

### 6. Test

Open `https://<alb_dns_name>` (from `terraform output`) in a browser. Accept the warning about
a self-signed certificate.

### 7. Destroy the infrastructure

```bash
aws s3 rm s3://<bucket-name> --recursive
cd terraform
terraform destroy
```

## Easy to adjust

All key values ​​are parameterized through `variables.tf`:
- `instance_type` – EC2 instance type
- `instance_count` – number of EC2 instances
- `VpcCIDR` and individual subnet CIDRs
- `aws_region`, `Zone1/2/3` – region and availability zone
