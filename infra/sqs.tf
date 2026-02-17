# Filas Amazon SQS para messaging entre microsservicos

# Fila para requests de reducao de estoque (OrdemServico -> Estoque)
resource "aws_sqs_queue" "estoque_reducao_solicitacao" {
  name                       = var.sqs_estoque_reducao_solicitacao_name
  visibility_timeout_seconds = 120 # > timeout do consumer (1min)
  message_retention_seconds  = 60  # 60s para auto-expirar mensagens nao processadas (evita ghost deductions)
  receive_wait_time_seconds  = 20  # long polling

  tags = {
    Name              = var.sqs_estoque_reducao_solicitacao_name
    ProjectIdentifier = var.project_identifier
    Service           = "messaging"
    Environment       = var.environment
  }
}

# Fila para resultados da reducao de estoque (Estoque -> OrdemServico)
resource "aws_sqs_queue" "estoque_reducao_resultado" {
  name                       = var.sqs_estoque_reducao_resultado_name
  visibility_timeout_seconds = 120
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20

  tags = {
    Name              = var.sqs_estoque_reducao_resultado_name
    ProjectIdentifier = var.project_identifier
    Service           = "messaging"
    Environment       = var.environment
  }
}

# SNS Topics para pub/sub entre microsservicos (MassTransit)
resource "aws_sns_topic" "reducao_estoque_solicitacao" {
  name = "fase4-reducao-estoque-solicitacao"

  tags = {
    Name              = "fase4-reducao-estoque-solicitacao"
    ProjectIdentifier = var.project_identifier
    Service           = "messaging"
    Environment       = var.environment
  }
}

resource "aws_sns_topic" "reducao_estoque_resultado" {
  name = "fase4-reducao-estoque-resultado"

  tags = {
    Name              = "fase4-reducao-estoque-resultado"
    ProjectIdentifier = var.project_identifier
    Service           = "messaging"
    Environment       = var.environment
  }
}

# Subscriptions SNS -> SQS
resource "aws_sns_topic_subscription" "solicitacao_to_sqs" {
  topic_arn = aws_sns_topic.reducao_estoque_solicitacao.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.estoque_reducao_solicitacao.arn

  raw_message_delivery = true
}

resource "aws_sns_topic_subscription" "resultado_to_sqs" {
  topic_arn = aws_sns_topic.reducao_estoque_resultado.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.estoque_reducao_resultado.arn

  raw_message_delivery = true
}

# Policy na fila SQS para permitir que o SNS envie mensagens
resource "aws_sqs_queue_policy" "solicitacao_sns_policy" {
  queue_url = aws_sqs_queue.estoque_reducao_solicitacao.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.estoque_reducao_solicitacao.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.reducao_estoque_solicitacao.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "resultado_sns_policy" {
  queue_url = aws_sqs_queue.estoque_reducao_resultado.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.estoque_reducao_resultado.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.reducao_estoque_resultado.arn
          }
        }
      }
    ]
  })
}

# IAM Policy para acesso ao SQS e SNS pelos pods do EKS
resource "aws_iam_policy" "sqs_access" {
  name        = "${var.project_identifier}-sqs-access-policy"
  description = "Policy para permitir que pods do EKS acessem filas SQS e topicos SNS para messaging"

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
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = [
          aws_sqs_queue.estoque_reducao_solicitacao.arn,
          aws_sqs_queue.estoque_reducao_resultado.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sns:GetTopicAttributes",
          "sns:SetTopicAttributes",
          "sns:Subscribe",
          "sns:CreateTopic",
          "sns:ListSubscriptionsByTopic"
        ]
        Resource = [
          aws_sns_topic.reducao_estoque_solicitacao.arn,
          aws_sns_topic.reducao_estoque_resultado.arn
        ]
      }
    ]
  })

  tags = {
    Name              = "${var.project_identifier}-sqs-access-policy"
    ProjectIdentifier = var.project_identifier
    Service           = "messaging"
  }
}

# Anexar SQS policy a role dos nos do EKS
resource "aws_iam_role_policy_attachment" "eks_node_sqs_access" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.sqs_access.arn
}