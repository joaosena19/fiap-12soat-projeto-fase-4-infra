# Data source para pegar CIDR da VPC
data "aws_vpc" "main" {
  id = aws_vpc.vpc_principal.id
}

# Security Group para o NLB
resource "aws_security_group" "nlb_sg" {
  name        = "${var.project_identifier}-nlb-sg"
  description = "Security group para Network Load Balancer"
  vpc_id      = aws_vpc.vpc_principal.id

  ingress {
    description = "HTTP de qualquer lugar"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS de qualquer lugar"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Permitir todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_identifier}-nlb-sg"
  }
}

# Network Load Balancer para o EKS
resource "aws_lb" "eks_nlb" {
  name               = "${var.project_identifier}-eks-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.subnet_publica[*].id

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_identifier}-eks-nlb"
  }
}

# Target Group para Cadastro (porta 30081)
resource "aws_lb_target_group" "cadastro_tg" {
  name        = "${var.project_identifier}-cadastro-tg"
  port        = 30081
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc_principal.id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    protocol            = "TCP"
    port                = "30081"
  }

  tags = {
    Name = "${var.project_identifier}-cadastro-tg"
  }
}

# Target Group para Estoque (porta 30082)
resource "aws_lb_target_group" "estoque_tg" {
  name        = "${var.project_identifier}-estoque-tg"
  port        = 30082
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc_principal.id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    protocol            = "TCP"
    port                = "30082"
  }

  tags = {
    Name = "${var.project_identifier}-estoque-tg"
  }
}

# Target Group para OrdemServico (porta 30083)
resource "aws_lb_target_group" "ordemservico_tg" {
  name        = "${var.project_identifier}-ordem-svc-tg"
  port        = 30083
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc_principal.id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    protocol            = "TCP"
    port                = "30083"
  }

  tags = {
    Name = "${var.project_identifier}-ordem-svc-tg"
  }
}

# Listener do NLB para Cadastro (porta 81)
resource "aws_lb_listener" "cadastro_listener" {
  load_balancer_arn = aws_lb.eks_nlb.arn
  port              = "81"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cadastro_tg.arn
  }
}

# Listener do NLB para Estoque (porta 82)
resource "aws_lb_listener" "estoque_listener" {
  load_balancer_arn = aws_lb.eks_nlb.arn
  port              = "82"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.estoque_tg.arn
  }
}

# Listener do NLB para OrdemServico (porta 83)
resource "aws_lb_listener" "ordemservico_listener" {
  load_balancer_arn = aws_lb.eks_nlb.arn
  port              = "83"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ordemservico_tg.arn
  }
}

# ASG attachment para Cadastro
resource "aws_autoscaling_attachment" "cadastro_asg_attachment" {
  autoscaling_group_name = aws_eks_node_group.eks_node_group.resources[0].autoscaling_groups[0].name
  lb_target_group_arn    = aws_lb_target_group.cadastro_tg.arn
  
  depends_on = [aws_eks_node_group.eks_node_group]
}

# ASG attachment para Estoque
resource "aws_autoscaling_attachment" "estoque_asg_attachment" {
  autoscaling_group_name = aws_eks_node_group.eks_node_group.resources[0].autoscaling_groups[0].name
  lb_target_group_arn    = aws_lb_target_group.estoque_tg.arn
  
  depends_on = [aws_eks_node_group.eks_node_group]
}

# ASG attachment para OrdemServico
resource "aws_autoscaling_attachment" "ordemservico_asg_attachment" {
  autoscaling_group_name = aws_eks_node_group.eks_node_group.resources[0].autoscaling_groups[0].name
  lb_target_group_arn    = aws_lb_target_group.ordemservico_tg.arn
  
  depends_on = [aws_eks_node_group.eks_node_group]
}

# Regra para permitir que o NLB acesse os nós do EKS nas portas dos NodePorts
resource "aws_security_group_rule" "allow_nlb_to_eks_nodes" {
  type        = "ingress"
  description = "Permitir trafego do NLB para os nos do EKS nas portas 30081-30083"
  from_port   = 30081
  to_port     = 30083
  protocol    = "tcp"

  # A origem é o Security Group do NLB
  source_security_group_id = aws_security_group.nlb_sg.id

  # O destino é o Security Group automático do Cluster EKS (onde os nós estão)
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id

  depends_on = [aws_eks_cluster.eks_cluster]
}

# Regra adicional para permitir que toda a VPC acesse NodePorts nos nós EKS
resource "aws_security_group_rule" "allow_vpc_to_cluster_nodeport" {
  type              = "ingress"
  from_port         = 30081
  to_port           = 30083
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.main.cidr_block]
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  description       = "Allow VPC traffic to reach nodePort 30081-30083 on EKS cluster nodes"
  
  depends_on = [aws_eks_cluster.eks_cluster]
}