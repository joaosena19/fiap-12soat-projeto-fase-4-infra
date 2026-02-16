resource "aws_eks_cluster" "eks_cluster" {
  version  = "1.33"
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids = aws_subnet.subnet_publica[*].id
  }

  tags = {
    Name              = "EKS Cluster ${var.project_name}"
    ProjectIdentifier = var.project_identifier
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy
  ]
}