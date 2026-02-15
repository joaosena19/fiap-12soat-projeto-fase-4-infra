# Obrigatórias
variable "bucket_name" {
  description = "O nome único para o bucket S3. Deve ser globalmente único."
  type        = string
}

variable "eks_iam_user_name" {
  description = "Nome do usuário IAM que controlará o EKS e será associado às políticas de acesso do cluster."
  type        = string
}

variable "eks_cluster_name" {
  description = "Nome do cluster EKS. Exemplo: fiap-12soat-fase2-joaodainese"
  type        = string
}

# Opcionais
variable "aws_region" {
  description = "A região da AWS onde os recursos serão criados."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "O ambiente ao qual o recurso pertence (ex: Dev, Staging, Prod)."
  type        = string
  default     = "Dev"
}

variable "project_name" {
  description = "Nome do projeto para ser usado em tags."
  type        = string
  default     = "FIAP 12SOAT Fase 4"
}

variable "project_identifier" {
  description = "Identificador único do projeto para ser usado em tags."
  type        = string
  default     = "fiap-12soat-fase4"
}

variable "cidr_vpc" {
  description = "O bloco CIDR para a VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Lista de zonas de disponibilidade na região escolhida onde as subnets serão criadas (deve combinar com aws_region)."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "eks_node_instance_types" {
  description = "Lista de tipos de instância para os nós do EKS."
  type        = list(string)
  default     = ["t3.small"]
}

variable "eks_node_disk_size" {
  description = "Tamanho do disco em GB a ser anexado a cada nó do EKS."
  type        = number
  default     = 20
}

variable "eks_node_scaling_desired_size" {
  description = "Número desejado de nós no grupo do EKS."
  type        = number
  default     = 2
}

variable "eks_node_scaling_max_size" {
  description = "Número máximo de nós no grupo do EKS."
  type        = number
  default     = 3
}
# Variáveis para API Gateway e Lambda
variable "lambda_terraform_state_bucket" {
  description = "Nome do bucket S3 onde está o tfstate da Lambda"
  type        = string
  default     = "fiap-12soat-fase4-joao-dainese"
}

variable "lambda_terraform_state_key" {
  description = "Chave do tfstate da Lambda no bucket S3"
  type        = string
  default     = "lambda-auth/terraform.tfstate"
}

variable "jwt_issuer" {
  description = "Emissor do token JWT (deve ser igual ao configurado na Lambda)"
  type        = string
  default     = "OficinaMecanicaApi"
}

variable "jwt_audience" {
  description = "Audiência do token JWT (deve ser igual ao configurado na Lambda)"
  type        = string
  default     = "AuthorizedServices"
}
variable "eks_node_scaling_min_size" {
  description = "Número mínimo de nós no grupo do EKS."
  type        = number
  default     = 1
}

variable "new_relic_license_key" {
  description = "Chave de licença do New Relic para monitoramento do cluster"
  type        = string
  sensitive   = true
}

variable "sqs_estoque_reducao_solicitacao_name" {
  description = "Nome da fila SQS de solicitação de redução de estoque"
  type        = string
  default     = "fase4-estoque-reducao-estoque-solicitacao"
}

variable "sqs_estoque_reducao_resultado_name" {
  description = "Nome da fila SQS de resultado de redução de estoque"
  type        = string
  default     = "fase4-estoque-reducao-estoque-resultado"
}