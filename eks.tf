resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.34"

  vpc_config {
    subnet_ids              = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  enabled_cluster_log_types = [
    "api",
    "authenticator",
    "controllerManager",
    "scheduler",
    "audit"
  ]


  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
    aws_cloudwatch_log_group.eks
  ]
}

# Create IAM OIDC provider for IRSA (recommended)
resource "aws_iam_openid_connect_provider" "oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_cert.certificates[0].sha1_fingerprint]
}

# helper data to get OIDC cert thumbprint
data "tls_certificate" "oidc_cert" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}


resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng-1"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private[*].id
  ami_type        = "AL2023_x86_64_STANDARD"

  scaling_config {
    desired_size = var.node_desired
    max_size     = var.node_max
    min_size     = var.node_min
  }

  instance_types = var.node_instance_types

  tags = {
    Name = "${var.cluster_name}-nodegroup-1"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_ec2_registry,
    aws_iam_role_policy_attachment.node_cni
  ]
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/cluster-prod"
  retention_in_days = 30
}
