⭐ Terraform AWS EKS Cluster Setup

A fully production-ready Amazon EKS cluster deployed using Terraform with custom VPC, private/public subnets, NAT gateways, node groups, IAM roles, and security best-practices.

📘 Table of Contents

Overview

Architecture

Features

Terraform Module Structure

Prerequisites

How to Use

Components Explained

Outputs

License

📌 Overview

This repository contains Terraform code to build a production-grade Amazon EKS cluster with a fully custom VPC, networking, IAM roles, security groups, and node groups.
It follows AWS-recommended best practices, including private worker nodes and public/private endpoint control.


🚀 Features

✔ Custom VPC with 3 AZ setup
✔ Private subnets for worker nodes
✔ Public subnets for NAT Gateways
✔ IAM roles for EKS cluster & node groups
✔ Auto-scaling node groups
✔ EKS OIDC provider for IRSA
✔ Secure security groups (cluster & nodes)
✔ VPC Endpoints for SSM (optional)
✔ EIP-attached NAT gateways
✔ kubectl config output
✔ Fully modular and production-ready

📦 Prerequisites

Before deploying:

Terraform ≥ 1.5

AWS CLI configured

kubectl installed

IAM permissions to create EKS, VPC, and IAM roles

Login to AWS:

aws configure

⚙️ How to Use
1️⃣ Initialize Terraform
terraform init

2️⃣ Validate
terraform validate

3️⃣ Preview changes
terraform plan

4️⃣ Apply
terraform apply -auto-approve

5️⃣ Get kubeconfig
aws eks update-kubeconfig --name <cluster_name> --region <region>

🧠 Components Explained
🔹 VPC

Isolates the Kubernetes environment

Custom CIDR for pods, nodes, and control plane communication

🔹 Public Subnets

Host NAT Gateways

Allow outbound internet access for private nodes via NAT

🔹 Private Subnets

Host worker nodes

No direct inbound internet exposure

🔹 NAT Gateways

Allow nodes in private subnets to download:

worker AMIs

container images

security patches

EKS bootstrap scripts

🔹 IAM Roles

Cluster Role: allows EKS control plane to manage resources

Node Role: allows nodes to pull container images, join cluster

🔹 EKS OIDC Provider

Enables IRSA (IAM Roles for Service Accounts) so pods can get IAM permissions without using node role.

Example:

AWS Load Balancer Controller

External DNS

EBS CSI Driver

🔹 Security Groups

Restrict traffic between nodes and control plane

Critical required port:

Control plane → nodes: TCP 443

Nodes → Control plane: TCP 10250

🔹 ENIs (Elastic Network Interfaces)

Created for:

Worker nodes

Pods using secondary ENI (AWS CNI)

NAT gateways

Each ENI attaches to a subnet and routes traffic

🔹 EIPs (Elastic IPs)

Used by NAT gateways

Provide stable internet-reachable address

📤 Outputs

After deployment, Terraform shows:

Output	Description
cluster_name	EKS cluster name
node_group_name	Worker node group name
kubeconfig_path	Path for kubectl configuration
