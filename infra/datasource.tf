data "aws_iam_user" "iam_user_principal" {
  user_name = var.eks_iam_user_name
}

data "aws_caller_identity" "current" {}