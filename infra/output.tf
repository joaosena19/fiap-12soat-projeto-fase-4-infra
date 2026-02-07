output "vpc_principal_cidr" {
  description = "Bloco CIDR da VPC principal"
  value       = aws_vpc.vpc_principal.cidr_block
}

output "vpc_principal_id" {
  description = "ID da VPC principal"
  value       = aws_vpc.vpc_principal.id
}

output "subnet_publica_cidrs" {
  description = "Blocos CIDR das subnets públicas"
  value       = aws_subnet.subnet_publica[*].cidr_block
}

output "subnet_publica_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.subnet_publica[*].id
}

output "eks_cluster_name" {
  description = "Nome do cluster EKS"
  value       = aws_eks_cluster.eks_cluster.name
}

# NLB outputs
output "nlb_dns_name" {
  description = "DNS do Network Load Balancer"
  value       = aws_lb.eks_nlb.dns_name
}

output "nlb_arn" {
  description = "ARN do Network Load Balancer"
  value       = aws_lb.eks_nlb.arn
}

output "nlb_listener_arn" {
  description = "ARN do listener do Network Load Balancer"
  value       = aws_lb_listener.eks_listener.arn
}

# Target Group outputs for microservices
output "cadastro_target_group_arn" {
  description = "ARN do Target Group do Cadastro Service"
  value       = aws_lb_target_group.cadastro_tg.arn
}

output "estoque_target_group_arn" {
  description = "ARN do Target Group do Estoque Service"
  value       = aws_lb_target_group.estoque_tg.arn
}

output "ordemservico_target_group_arn" {
  description = "ARN do Target Group do Ordem de Serviço Service"
  value       = aws_lb_target_group.ordemservico_tg.arn
}

# SQS Queue outputs
output "sqs_estoque_reducao_solicitacao_url" {
  description = "URL da fila SQS de solicitação de redução de estoque"
  value       = aws_sqs_queue.estoque_reducao_solicitacao.url
}

output "sqs_estoque_reducao_solicitacao_arn" {
  description = "ARN da fila SQS de solicitação de redução de estoque"
  value       = aws_sqs_queue.estoque_reducao_solicitacao.arn
}

output "sqs_estoque_reducao_resultado_url" {
  description = "URL da fila SQS de resultado de redução de estoque"
  value       = aws_sqs_queue.estoque_reducao_resultado.url
}

output "sqs_estoque_reducao_resultado_arn" {
  description = "ARN da fila SQS de resultado de redução de estoque"
  value       = aws_sqs_queue.estoque_reducao_resultado.arn
}
