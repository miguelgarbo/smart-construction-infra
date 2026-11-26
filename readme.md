# Infraestrutura do Smart Construction
### Terraform + Ansible + AWS + GitHub Actions

**Repositório da aplicação:** https://github.com/LaercioMLB/smart-construction

## 1. Visão geral da infraestrutura

A infraestrutura do Smart Construction é provisionada e configurada automaticamente por meio de um pipeline CI/CD no GitHub Actions.

O processo é dividido em duas etapas principais:

- **Terraform:** responsável por provisionar os recursos de infraestrutura na AWS, como instâncias EC2, rede, grupos de segurança, IAM e banco de dados.
- **Ansible:** responsável por configurar os servidores, instalar dependências, preparar o ambiente Docker e realizar o deploy da aplicação.

O GitHub Actions coordena essas duas etapas, garantindo que o Ansible seja executado somente após a conclusão do Terraform.

### Fluxo de execução

1. O desenvolvedor envia alterações para a branch `main`.
2. O GitHub Actions inicia o workflow.
3. O job Terraform inicializa o projeto, valida os arquivos e executa o planejamento da infraestrutura.
4. Após a aprovação do planejamento, o Terraform provisiona os recursos na AWS.
5. Os IPs das instâncias são extraídos dos outputs do Terraform.
6. O job Ansible recebe esses IPs e configura as instâncias EC2.
7. A aplicação é construída e iniciada com Docker Compose.
8. São executados os comandos de inicialização necessários, incluindo a criação do administrador e a aplicação das profissões.
9. O Ansible realiza testes de disponibilidade e valida o deploy.

---

## 2. Configuração inicial do GitHub Actions

Antes de executar o pipeline, é necessário configurar as credenciais utilizadas pelo workflow.

Acesse o repositório no GitHub:

**Settings → Secrets and variables → Actions → New repository secret**

Cadastre os seguintes secrets:

| Secret | Descrição |
|---|---|
| `AWS_ACCESS_KEY_ID` | Access Key do usuário IAM utilizado pelo Terraform. |
| `AWS_SECRET_ACCESS_KEY` | Secret Access Key do usuário IAM. |
| `SSH_PRIVATE_KEY` | Chave privada utilizada para acessar as instâncias EC2. |
| `ADMIN_PASSWORD` | Senha utilizada na criação do administrador inicial da aplicação. |

---

## 3. Execução automática do pipeline

O workflow está localizado em:

```text
.github/workflows/deploy.yml
```

Ele possui três formas de execução:

### 3.1. Push na branch main

Quando alterações são enviadas para a branch `main`, o workflow é iniciado automaticamente.

São monitoradas alterações nos seguintes diretórios:

```text
terraform/**
ansible/**
.github/workflows/deploy.yml
```

Nesse cenário, o pipeline executa:

1. Provisionamento ou atualização da infraestrutura com Terraform.
2. Exportação dos IPs das instâncias.
3. Configuração dos servidores com Ansible.
4. Deploy da aplicação.
5. Testes de disponibilidade.

### 3.2. Pull Request para main

Quando um Pull Request é aberto ou atualizado para a branch `main`, o workflow executa uma validação da infraestrutura.

Nessa situação:

- O Terraform executa `init`, `fmt`, `validate` e `plan`.
- Não executa `terraform apply`.
- O Ansible não é executado.

Isso permite verificar as alterações propostas na infraestrutura antes de integrá-las à branch principal.

### 3.3. Execução manual pelo GitHub Actions

Também é possível iniciar o workflow manualmente, sem precisar realizar um novo commit.

Para isso:

1. Acesse o repositório no GitHub.
2. Entre na aba **Actions**.
3. Selecione o workflow **Deploy Smart Construction**.
4. Clique em **Run workflow**.
5. Selecione a branch `main`.
6. Escolha a ação desejada:

| Ação | Descrição |
|---|---|
| `apply` | Provisiona ou atualiza a infraestrutura e executa o deploy com Ansible. |
| `destroy` | Remove os recursos gerenciados pelo Terraform. |

7. Clique em **Run workflow** para iniciar a execução.

**Atenção:** a opção `destroy` executa somente o Terraform Destroy. O job Ansible não é executado nessa operação.

---

## 4. Etapa 1: Provisionamento com Terraform

O primeiro job do pipeline é responsável pela infraestrutura na AWS.

O GitHub Actions utiliza o runner `ubuntu-latest` e executa as seguintes etapas:

| Etapa | Responsabilidade |
|---|---|
| Checkout | Obtém os arquivos do repositório. |
| AWS Credentials | Configura as credenciais para acessar a AWS. |
| Setup Terraform | Instala e configura a versão do Terraform. |
| Init | Inicializa o Terraform e configura os providers e o backend. |
| Format | Verifica a formatação dos arquivos `.tf`. |
| Validate | Valida a configuração do Terraform. |
| Plan | Identifica as alterações necessárias na infraestrutura. |
| Apply | Aplica as alterações na AWS. |
| Export Outputs | Extrai os IPs das instâncias provisionadas. |

### Exportação dos outputs

Após o `terraform apply`, os IPs das instâncias são extraídos:

```bash
echo "app_public_ip=$(terraform output -raw public_ip_access)" >> "$GITHUB_OUTPUT"

echo "app_private_ip=$(terraform output -raw private_ip_app)" >> "$GITHUB_OUTPUT"

echo "db_private_ip=$(terraform output -raw private_ip_database)" >> "$GITHUB_OUTPUT"
```

Esses valores são disponibilizados como outputs do job Terraform.

---

## 5. Etapa 2: Configuração e deploy com Ansible

Após a conclusão do job Terraform, o GitHub Actions inicia o job Ansible.

A dependência é definida por:

```yaml
needs: terraform
```

O Ansible recebe os IPs extraídos anteriormente por meio dos outputs do Terraform.

### Preparação do ambiente

O runner executa:

1. Checkout do repositório.
2. Configuração do Python 3.12.
3. Instalação do Ansible Core.
4. Instalação das collections necessárias.
5. Configuração da chave privada SSH.

Exemplo de instalação:

```bash
pip install "ansible-core>=2.16,<2.18"
ansible-galaxy collection install -r requirements.yml
```

### Configuração do SSH

A chave privada é obtida do GitHub Secrets e armazenada temporariamente no runner:

```bash
mkdir -p ~/.ssh

printf '%s\n' "$SSH_PRIVATE_KEY" > ~/.ssh/smart-construction-key.pem

chmod 600 ~/.ssh/smart-construction-key.pem
```

O Ansible utiliza essa chave para estabelecer as conexões SSH com as instâncias EC2.

### Execução do playbook

Após preparar o ambiente, o workflow executa:

```bash
ansible-playbook main.yml \
  -e "app_public_ip=$APP_PUBLIC_IP" \
  -e "app_private_ip=$APP_PRIVATE_IP" \
  -e "db_private_ip=$DB_PRIVATE_IP" \
  -e "admin_password=$ADMIN_PASSWORD"
```

As variáveis são passadas dinamicamente para o Ansible, permitindo que o playbook utilize os IPs atuais das instâncias e a senha do administrador sem armazenar esses valores diretamente nos arquivos de configuração.

---

## 6. Configuração das instâncias EC2

O Ansible é responsável por preparar os servidores e executar o deploy.

As principais atividades são:

### Instância Database

- Atualização dos pacotes do sistema.
- Instalação das dependências necessárias.
- Configuração do Docker.
- Configuração e inicialização do PostgreSQL por Docker Compose.
- Configuração dos scripts de backup do banco de dados.
- Envio dos backups para o Amazon S3.

### Instância App

- Atualização dos pacotes do sistema.
- Instalação das dependências necessárias.
- Configuração do Docker e Docker Compose.
- Clonagem ou atualização do repositório da aplicação.
- Geração dos arquivos de configuração do NGINX.
- Geração do override do Docker Compose.
- Inicialização dos serviços da aplicação.
- Configuração do SeaweedFS.
- Configuração dos scripts de backup para o Amazon S3.
- Criação do usuário administrador inicial.
- Execução dos comandos de inicialização das profissões.

