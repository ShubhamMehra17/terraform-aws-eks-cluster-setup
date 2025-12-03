terraform-aws-eks-cluster-setup

This repository contains a production-ready Terraform setup for deploying an Amazon EKS (Elastic Kubernetes Service) cluster with a custom VPC, high-availability subnets, managed node groups, and all required AWS components.

The setup includes:

Custom VPC with public and private subnets

Internet Gateway + NAT Gateway (or use existing NAT GW)

Route tables + associations

EKS Control Plane

EKS Managed Node Group

IAM Roles & Policies

OIDC Provider for IAM Roles for Service Accounts (IRSA)

VPC Endpoints for SSM / EC2Messages / SSMMessages

Security Groups for cluster & worker nodes

Outputs for kubeconfig

CloudWatch Log Group (optional)

📌 Architecture Overview

This infrastructure provisions:

1. Custom VPC

CIDR block: 10.0.0.0/16

3 Public Subnets (for NAT Gateways or public ALBs)

3 Private Subnets (for node groups)

Route tables for public & private networks

Internet Gateway for outbound internet on public subnets

2. NAT Gateways

1 or 3 NAT gateways (depending on your configuration)

Allow private subnets to reach the internet for:

Package installation

Pulling container images

SSM connectivity

3. EKS Cluster

Latest stable Kubernetes version (1.30+)

Private + public endpoint access

Control plane security group

4. EKS Managed Node Group

EC2 worker nodes in private subnets

IAM role with required policies

Auto-scaling configuration

5. OIDC Provider

Enables fine-grained IAM permissions for Kubernetes service accounts (IRSA):

Used by external-dns, ALB controller, EBS CSI driver, etc.

6. Security Groups

EKS cluster SG

Node SG allowing:

443 communication to API server

Node-to-node traffic

Cluster-to-node communication

7. VPC Endpoints (Optional but recommended)

SSM & EC2Messages endpoints allow:

SSM agent communication without public internet

Access from private nodes

📁 Repository Structure
.
├── vpc.tf              # VPC, Subnets, IGW, NAT, route tables
├── eks.tf              # EKS cluster + node groups
├── iam.tf              # IAM roles and OIDC provider
├── sg.tf               # Security groups
├── variables.tf        # All variables
├── outputs.tf          # Cluster outputs like kubeconfig
├── providers.tf        # AWS provider configuration
└── README.md           # Documentation

🚀 Deployment Steps
1. Initialize Terraform
terraform init

2. Validate the configuration
terraform validate

3. Review the plan
terraform plan

4. Apply
terraform apply -auto-approve

📄 Generate Kubeconfig

After apply:

aws eks update-kubeconfig --name <cluster_name> --region <region>

📝 Requirements

Terraform v1.6+

AWS CLI configured

kubectl installed

IAM permissions for EKS/VPC/EC2/IAM

📦 Features

Fully automated VPC + EKS + NodeGroup setup

Highly available across 3 AZs

Can integrate with:

ALB Ingress Controller

ExternalDNS

Prometheus / Grafana

EBS CSI Driver

🤝 Contributions

Contributions, issues, and PRs are welcome!
