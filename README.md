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

## 📝 Comandos Úteis

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