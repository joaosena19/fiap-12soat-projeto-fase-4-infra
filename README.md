[![Deploy](https://github.com/joaosena19/fiap-12soat-projeto-fase-4-infra/actions/workflows/deploy.yaml/badge.svg)](https://github.com/joaosena19/fiap-12soat-projeto-fase-4-infra/actions/workflows/deploy.yaml)

# Identificação

Aluno: João Pedro Sena Dainese  
Registro FIAP: RM365182  

Turma 12SOAT - Software Architecture  
Grupo individual  
Grupo 13  

Discord: joaodainese  
Email: joaosenadainese@gmail.com  

## Sobre este Repositório

Este repositório contém apenas parte do projeto completo da Fase 4. Para visualizar a documentação completa, diagramas de arquitetura, e todos os componentes do projeto, acesse: [Documentação Completa - Fase 4](https://github.com/joaosena19/fiap-12soat-projeto-fase-4-documentacao)

## Descrição

Infraestrutura compartilhada da AWS usando Terraform: VPC, subnets, cluster EKS, Network Load Balancer, filas SQS, permissões IAM e integração com New Relic para monitoramento. Fornece a base de rede e compute para todos os microsserviços do projeto. O banco de dados de cada microsserviço é provisionado no próprio repositório do serviço.

## Tecnologias Utilizadas

- **Terraform** - Infraestrutura como código
- **AWS EKS** - Kubernetes gerenciado
- **AWS VPC** - Rede isolada
- **Network Load Balancer** - Balanceador de carga para comunicação entre serviços
- **Amazon SQS** - Filas para mensageria assíncrona (SAGA)
- **AWS IAM** - Permissões e roles
- **New Relic** - Monitoramento
- **AWS S3** - Backend do Terraform
