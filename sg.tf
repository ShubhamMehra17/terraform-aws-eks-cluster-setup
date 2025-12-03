# Cluster (control plane) SG (you pass this SG ID into aws_eks_cluster.vpc_config)
resource "aws_security_group" "eks_cluster_sg" {
  name   = "${var.cluster_name}-cluster-sg"
  vpc_id = aws_vpc.this.id
  description = "EKS control-plane security group"

  # Admin (kubectl) from admin CIDR to API (443)
  ingress {
    description = "kubectl/admin access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.cluster_name}-cluster-sg" }
}

# Node group SG
resource "aws_security_group" "eks_node_sg" {
  name   = "${var.cluster_name}-node-sg"
  vpc_id = aws_vpc.this.id
  description = "Security group for EKS worker nodes"

  # Node-to-node (self)
  ingress {
    description = "node-to-node"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Egress all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { "kubernetes.io/cluster/${var.cluster_name}" = "owned" }
}

# Cross-group rules (expressed on target SGs to avoid ambiguity)

# Nodes -> Cluster API (443) - create as ingress on cluster SG with source node SG
resource "aws_security_group_rule" "nodes_to_cluster_api" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_node_sg.id
  description              = "Allow worker nodes to call EKS API"
}

# Cluster -> Nodes kubelet (10250)
resource "aws_security_group_rule" "cluster_to_nodes_kubelet" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  description              = "Allow control plane to reach kubelets"
}

# Cluster -> Nodes ephemeral ports (1025-65535)
resource "aws_security_group_rule" "cluster_to_nodes_ephemeral" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  description              = "Allow control plane to reach node ephemeral ports"
}

# NodePort range (optional) if you will expose NodePort services (30000-32767)
resource "aws_security_group_rule" "nodeport" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_node_sg.id
  cidr_blocks       = [aws_vpc.this.cidr_block]
  description       = "Allow NodePort traffic within VPC"
}

# CoreDNS (53 TCP/UDP) is covered by self=true, but explicit if desired:
resource "aws_security_group_rule" "coredns_tcp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.eks_node_sg.id
}
resource "aws_security_group_rule" "coredns_udp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.eks_node_sg.id
}

# Optional SSH from admin CIDR to nodes
resource "aws_security_group_rule" "ssh_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_node_sg.id
  cidr_blocks       = [var.admin_cidr]
  description       = "SSH access from admin CIDR"
}
