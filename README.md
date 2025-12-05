**⭐ Terraform AWS EKS Cluster Setup**

A fully production-ready Amazon EKS cluster deployed using Terraform with a custom VPC, private/public subnets, NAT gateways, node groups, IAM roles, and industry-standard security practices.

**📘 Table of Contents**

1. Overview

2. Architecture

3. Features

4. Terraform Module Structure

5. Prerequisites

6. How to Use

7. Components Explained

8. New Relic Kubernetes Observability


**1️⃣ Overview**

This repository contains Terraform code to build a production-grade Amazon EKS cluster with:

Fully custom VPC

Secure private subnets

NAT Gateways

IAM roles & IRSA

EKS-managed node groups

Best-practice Kubernetes networking

The implementation follows AWS-recommended architectural standards.


**2️⃣ Architecture**



**3️⃣ Features**


✔ Custom VPC with 3 AZ support

✔ Private subnets for worker nodes

✔ Public subnets hosting NAT Gateways

✔ IAM roles for EKS control plane & nodes

✔ IRSA enabled for pod-level IAM permissions

✔ Auto-scaling node groups

✔ VPC endpoints for SSM (optional)

✔ NAT gateways with EIP

✔ kubeconfig output

✔ Fully modular and production-ready


**4️⃣ Terraform Module Structure**


The project is organized into clear, modular Terraform files that separate networking, IAM, EKS, and provider configuration for better readability and maintainability.


<img width="717" height="495" alt="image" src="https://github.com/user-attachments/assets/a9eb8ccf-7963-44f3-a1de-c0619fae4b9b" />



**5️⃣ Prerequisites**

Before deploying:


Terraform ≥ 1.5

AWS CLI configured:


aws configure


kubectl installed


IAM permissions to create VPC, IAM, and EKS resources

**6️⃣ How to Use**

1. Initialize Terraform : 

terraform init

2. Validate :

terraform validate

3. Preview Infrastructure :

terraform plan

4. Apply Infrastructure : 

terraform apply -auto-approve

5. Update kubeconfig : 

aws eks update-kubeconfig --name <cluster_name> --region <region>

**7️⃣ Components Explained**


🔹 VPC

Provides isolated networking for EKS, including CIDRs for nodes, pods, and control plane communication.


🔹 Public Subnets

Used for NAT Gateways enabling outbound internet access for private nodes.


🔹 Private Subnets


Securely host worker nodes; no direct inbound internet access.


🔹 NAT Gateways


Ensure nodes can pull container images, install patches, and bootstrap EKS components.


🔹 IAM Roles


Cluster Role: Allows EKS control plane to manage AWS infrastructure

Node Role: Allows worker nodes to interact with AWS services

IRSA Roles: Secure pod-level AWS permission model


🔹 OIDC Provider


Configured via Terraform to support IRSA-enabled Kubernetes workloads.


🔹 Security Groups


Restrict traffic between nodes & control plane. Key ports include:

Control Plane → Nodes: TCP 443

Nodes → Control Plane: TCP 10250


🔹 ENIs


Elastic network interfaces used for nodes, pods (AWS CNI), and NAT Gateways.


🔹 EIPs


Attached to NAT Gateways for stable outbound connectivity.


**🟣 8️⃣ New Relic Kubernetes Observability**


Enhance your EKS cluster with full-stack observability using New Relic.


**📦 Prerequisites for New Relic Integration**

**✔ New Relic Account**

**
Create an account at:
**
https://one.newrelic.com


✔ New Relic License Key


**Found under:**

Account Settings → API Keys → License Key


**Add this inside newrelic-values.yaml:**


global:
  licenseKey: "<YOUR_LICENSE_KEY>"


**✔ IRSA Role Created via Terraform**


This project already configures:


EKS OIDC Provider

IAM Role for New Relic Infrastructure Agent

ServiceAccount annotation


IRSA annotation inside newrelic-values.yaml:


serviceAccount:
  create: false
  name: newrelic-infrastructure
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/newrelic-infra-role
    

**✔ Helm Installed**

helm version


**🛠️ Installation Steps**
1. Add New Relic Helm Repo : 

helm repo add newrelic https://helm-charts.newrelic.com


2. Update Repo Index : 

helm repo update

3. Create Namespace : 

kubectl create namespace newrelic 

4. Install New Relic Bundle : 

helm upgrade --install newrelic-bundle newrelic/nri-bundle \
  --namespace newrelic \
  --values newrelic-values.yaml \
  --timeout 10m


**This deploys:**

Infrastructure Agent

Prometheus (OpenMetrics) Scraper

Metadata Injection Webhook

Kubernetes Events Collector

FluentBit Logging Integration


**💡 Note:**

Modern New Relic does not use legacy KSM.
Prometheus (nri-prometheus) provides all workload & state metrics.


**🔍 Verify Installation**

kubectl get pods -n newrelic


**Expected Running Pods:**


newrelic-infra-*

newrelic-nri-prometheus-*

newrelic-nri-kube-events-*

newrelic-nri-metadata-injection-*

newrelic-newrelic-logging-*


**Your cluster will appear under:**


New Relic → Infrastructure → Kubernetes

