# Filas Amazon SQS para messaging entre microsserviços

# Fila para requests de redução de estoque (OrdemServico -> Estoque)
resource "aws_sqs_queue" "estoque_reducao_solicitacao" {
  name                       = var.sqs_estoque_reducao_solicitacao_name
  visibility_timeout_seconds = 120  # > timeout do consumer (1min)
  message_retention_seconds  = 60  # 60s para auto-expirar mensagens não processadas (evita ghost deductions)
  receive_wait_time_seconds  = 20  # long polling
  
  tags = {
    Name                  = var.sqs_estoque_reducao_solicitacao_name
    ProjectIdentifier     = var.project_identifier
    Service               = "messaging"
    Environment           = var.environment
  }
}

# Fila para resultados da redução de estoque (Estoque -> OrdemServico)
resource "aws_sqs_queue" "estoque_reducao_resultado" {
  name                       = var.sqs_estoque_reducao_resultado_name
  visibility_timeout_seconds = 120
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20
  
  tags = {
    Name                  = var.sqs_estoque_reducao_resultado_name
    ProjectIdentifier     = var.project_identifier
    Service               = "messaging"
    Environment           = var.environment
  }
}

# IAM Policy para acesso ao SQS pelos pods do EKS
resource "aws_iam_policy" "sqs_access" {
  name        = "${var.project_identifier}-sqs-access-policy"
  description = "Policy para permitir que pods do EKS acessem filas SQS para messaging"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = [
          aws_sqs_queue.estoque_reducao_solicitacao.arn,
          aws_sqs_queue.estoque_reducao_resultado.arn
        ]
      }
    ]
  })
  
  tags = {
    Name                  = "${var.project_identifier}-sqs-access-policy"
    ProjectIdentifier     = var.project_identifier
    Service               = "messaging"
  }
}

# Anexar SQS policy à role dos nós do EKS
resource "aws_iam_role_policy_attachment" "eks_node_sqs_access" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.sqs_access.arn
}