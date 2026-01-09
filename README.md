# Kong Gateway

🚀 Deploy do Kong Gateway na AWS usando uma arquitetura modular com Terraform.

## 📁 Estrutura do Projeto

```
infra-gw-terraform/
├── .github/
│   ├── workflows/
│   │   ├── terraform.yml           # 🔄 CI/CD principal
│   │   ├── terraform-destroy.yml   # 💥 Destroy manual
│   │   └── README.md               # Documentação dos workflows
│   └── SETUP.md                    # Guia de configuração
├── modules/
│   ├── network/               # 🌐 VPC, Security Groups, Networking
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/                   # 🗄️ PostgreSQL Database
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecs/                   # 🐳 ECS Cluster, Tasks, Service
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecr/                   # � ECR Repository
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── secret-manager/        # 🔐 Secrets Manager
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/                   # ⚖️ Application Load Balancer
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/                   # 🔐 IAM Roles e Políticas
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── main.tf                    # 🎯 Configuração principal
├── variables.tf               # 📥 Variáveis de entrada
├── outputs.tf                 # 📤 Outputs do projeto
├── terraform.tfvars.example   # 📋 Exemplo de configuração
└── README.md
```

## 🧩 Módulos

### 1. **Network Module** (`modules/network/`)

- **Responsabilidade**: Configuração de rede
- **Recursos**:
  - Data sources para VPC e subnets default
  - Security Groups (Kong, ALB, Default rules)
  - Configuração de acesso entre componentes

### 2. **RDS Module** (`modules/rds/`)

- **Responsabilidade**: Banco de dados PostgreSQL
- **Recursos**:
  - RDS PostgreSQL instance
  - DB Subnet Group
  - Security Group específico para RDS
  - AWS Secrets Manager para credenciais
  - Random password generation

### 3. **IAM Module** (`modules/iam/`)

- **Responsabilidade**: Roles e permissões
- **Recursos**:
  - Data source para LabRole (AWS Academy)

### 4. **ALB Module** (`modules/alb/`)

- **Responsabilidade**: Load Balancing
- **Recursos**:
  - Application Load Balancer
  - Target Groups (Proxy, Admin, Manager)
  - Listeners para diferentes portas
  - Health checks configurados

### 5. **ECS Module** (`modules/ecs/`)

- **Responsabilidade**: Containers Kong
- **Recursos**:
  - ECS Cluster
  - Task Definitions (Kong + Migrations)
  - ECS Service
  - CloudWatch Log Groups

### 6. **ECR Module** (`modules/ecr/`)

- **Responsabilidade**: Container Registry
- **Recursos**:
  - ECR Repository para microservices-snack-bar (usado por todos os microserviços)
  - Lifecycle policy (mantém últimas 10 imagens)
  - Image scanning on push habilitado
  - Push automático via GitHub Actions CI/CD

### 7. **Secret Manager Module** (`modules/secret-manager/`)

- **Responsabilidade**: Gerenciamento de secrets
- **Recursos**:
  - JWT Secret para autenticação entre serviços
  - Random password generation (64 caracteres)
  - Secrets Manager integration
  - Acesso controlado via IAM

## 🚀 Como Usar

### Opção 1: Deploy via CI/CD (Recomendado)

Este projeto está configurado com GitHub Actions para automação completa.
**Fluxo básico:**

1. Configure os secrets no GitHub (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION)
2. Crie uma branch e faça suas alterações
3. Abra um Pull Request - o workflow validará e mostrará o plano
4. Após merge em `main`, aprove o deploy manualmente no GitHub Actions

### Opção 2: Deploy Local

### 1. **Configurar credenciais AWS**

```bash
# Configurar AWS CLI com suas credenciais da AWS Academy
aws configure
# Ou exportar variáveis de ambiente:
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_SESSION_TOKEN="your-session-token"
export AWS_DEFAULT_REGION="us-east-1"
```

### 2. **Configurar variáveis (opcional)**

```bash
# Copiar o exemplo e editar com seus valores
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars com seus valores
```

### 3. **Inicializar e aplicar**

```bash
# Inicializar Terraform (baixar providers e módulos)
terraform init

# Verificar o plano de execução
terraform plan

# Aplicar a infraestrutura
terraform apply
```

### 4. **Acessar o Kong**

Após o deploy, você receberá as URLs de acesso:

- **Kong Proxy**: `http://<alb-dns>` (porta 80)
- **Kong Admin API**: `http://<alb-dns>:8001`
- **Kong Manager**: `http://<alb-dns>:8002`

## � Integração com Microserviços

Este gateway fornece a infraestrutura central para todos os microserviços:

### ECR Repository

- **Nome**: `microservices-snack-bar`
- **Uso**: Todos os microserviços fazem push de suas imagens Docker para este repositório
- **Acesso**: Via GitHub Actions CI/CD de cada microserviço
- **Política**: Mantém as últimas 10 versões de imagens

### JWT Secret

- **Uso**: Autenticação entre serviços e com o gateway
- **Gerenciamento**: AWS Secrets Manager
- **Acesso**: Microserviços recuperam via IAM roles

### Outputs Disponíveis

Após deploy, os seguintes outputs estarão disponíveis:

```bash
# Ver outputs
terraform output

# Outputs incluem:
# - alb_dns_name: DNS do Load Balancer
# - ecr_repository_url: URL do repositório ECR
# - jwt_secret_arn: ARN do JWT secret
# - kong_cluster_name: Nome do cluster ECS
# - rds_endpoint: Endpoint do banco Kong
```

## �📝 Comandos Úteis

```bash
# Validar configuração
terraform validate

# Formatar código
terraform fmt -recursive

# Ver plano de execução
terraform plan

# Aplicar mudanças
terraform apply

# Destruir infraestrutura
terraform destroy

# Testar módulo específico
terraform plan -target=module.network
terraform apply -target=module.rds

# Ver estado atual
terraform show
terraform state list
```

## 🗄️ Backend Configuration

Este projeto utiliza **S3 backend** para armazenamento remoto do state do Terraform:

```hcl
bucket  = "terraform-state-fiap-kong-gw"
key     = "infra-gw/terraform.tfstate"
region  = "us-east-1"
encrypt = true
```

**Benefícios**:

- ✅ State compartilhado entre equipe
- ✅ Locking para prevenir conflitos
- ✅ Criptografia habilitada
- ✅ Versionamento de state

**Nota**: O bucket S3 deve ser criado manualmente antes do primeiro `terraform init`.

## 🔗 Microserviços Conectados

Os seguintes microserviços utilizam esta infraestrutura:

| Microserviço                      | Uso ECR | Uso JWT Secret | Status   |
| --------------------------------- | ------- | -------------- | -------- |
| **microservice-customer-payment** | ✅      | ✅             | 🟢 Ativo |
| **microservice-products**         | ✅      | ✅             | 🟢 Ativo |
| **microservice-store**            | ✅      | ✅             | 🟢 Ativo |
| **microservice-notification**     | ✅      | ✅             | 🟢 Ativo |

### Fluxo de Deploy dos Microserviços:

1. Microserviço faz build da imagem Docker
2. Push para ECR repository (`microservices-snack-bar`)
3. ECS Task atualizada com nova imagem
4. Kong Gateway roteia tráfego para o serviço

### Rotas do Kong Gateway:

```bash
# Exemplo de configuração de rotas (via Kong Admin API)
# Customer-Payment Service
/api/v1/customers/*  → customer-payment-service:3000
/api/v1/payment/*    → customer-payment-service:3000

# Products Service
/api/v1/products/*   → products-service:3000
/api/v1/categories/* → products-service:3000
/api/v1/orders/*     → products-service:3000

# Store Service
/api/v1/stores/*     → store-service:3000

# Notification Service
/api/v1/notifications/* → notification-service:3000
```

## 📊 Monitoramento

### CloudWatch Logs

Todos os logs são enviados para CloudWatch:

- **Kong Gateway**: `/ecs/kong-gateway`
- **Microserviços**: `/ecs/<service-name>`

### Métricas Disponíveis

- Request count por rota
- Response time (latência)
- Error rates
- ECS task health
- ALB target health

## 🔐 Segurança

### Security Groups

- **ALB**: Apenas portas 80, 8001, 8002 abertas
- **Kong ECS**: Apenas acesso via ALB
- **RDS**: Apenas acesso do Kong ECS
- **Microserviços**: Comunicação interna via VPC

### IAM Roles

- **ECS Task Role**: Acesso a Secrets Manager, CloudWatch
- **ECS Execution Role**: Pull de imagens do ECR

### Secrets Management

- Credenciais do RDS no Secrets Manager
- JWT Secret no Secrets Manager
- Rotação automática de senhas (opcional)

## 🚀 CI/CD

### GitHub Actions Workflows

#### `terraform.yml` - Deploy Pipeline

**Triggers**:

- Pull Request para `main`
- Push para `main`

**Jobs**:

1. **terraform-plan**: Valida e mostra plano
2. **terraform-apply**: Aplica mudanças (manual approval em `main`)

#### `terraform-destroy.yml` - Destroy Pipeline

**Triggers**: Manual (workflow_dispatch)

**Uso**: Para destruir toda a infraestrutura quando necessário

### Secrets Necessários

Configure no GitHub (Settings → Secrets):

```bash
AWS_ACCESS_KEY_ID       # Credencial AWS
AWS_SECRET_ACCESS_KEY   # Credencial AWS
AWS_SESSION_TOKEN       # Token de sessão (AWS Academy)
AWS_REGION              # Região (us-east-1)
```

## 📈 Escalabilidade

### Auto Scaling do Kong

- **Min**: 1 task
- **Max**: 3 tasks
- **Trigger**: CPU > 70%

### Database

- **Instance**: db.t3.micro (configurável)
- **Storage**: Auto-scaling (20GB-100GB)
- **Backups**: 7 dias de retenção

## 🆘 Troubleshooting

### Kong Gateway não inicia

```bash
# Verificar logs
aws logs tail /ecs/kong-gateway --follow

# Verificar tasks do ECS
aws ecs list-tasks --cluster kong-gateway-cluster
```

### Problemas de conectividade

```bash
# Verificar security groups
terraform state show module.network.aws_security_group.kong_sg

# Verificar target health do ALB
aws elbv2 describe-target-health --target-group-arn <arn>
```

### State lock

```bash
# Se o state ficar travado
terraform force-unlock <lock-id>
```

## 🔄 Atualizações

### Atualizar Kong Gateway

1. Modificar `kong_image` em `terraform.tfvars`
2. Executar `terraform apply`
3. ECS fará rolling update automaticamente

### Adicionar novo microserviço

1. Microserviço usa o ECR existente: `microservices-snack-bar`
2. Configurar rota no Kong via Admin API
3. Deploy do microserviço em seu próprio ECS cluster

## 📚 Referências

- [Kong Gateway Documentation](https://docs.konghq.com/gateway/latest/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Kong on AWS](https://docs.konghq.com/gateway/latest/install/kubernetes/aws/)

## 📝 License

This project is part of the FIAP Tech Challenge program.
