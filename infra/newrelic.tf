resource "helm_release" "newrelic_bundle" {
  name             = "newrelic-bundle"
  repository       = "https://helm-charts.newrelic.com"
  chart            = "nri-bundle"
  namespace        = "newrelic"
  create_namespace = true

  # Configurações globais
  set {
    name  = "global.licenseKey"
    value = var.new_relic_license_key
  }

  set {
    name  = "global.cluster"
    value = var.eks_cluster_name
  }

  # Habilita monitoramento de Infraestrutura (CPU, RAM dos Nodes)
  set {
    name  = "infrastructure.enabled"
    value = "true"
  }

  # Habilita Prometheus (para métricas avançadas do K8s)
  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  # Habilita Logs do Cluster (Log de sistema dos Pods)
  set {
    name  = "logging.enabled"
    value = "true"
  }
  
  # Garante que só instala depois que os Nodes estiverem prontos
  depends_on = [
    aws_eks_node_group.eks_node_group
  ]
}