resource "aws_eks_access_entry" "eks_access_entry" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = data.aws_iam_user.iam_user_principal.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_access_policy_association" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_iam_user.iam_user_principal.arn

  access_scope {
    type = "cluster"
  }
}