## Infraestrutura do Smart Construction - Terraform + Ansible + GitHub Actions

Projeto fonte:




## Passo a Passo para o Deploy Completo

### Criação da Infraestrutura na Nuvem (AWS)

```bash
#autenticação da conta na aws
aws configure

# entrar na pasta que contem os arquivos .tf
cd terraform

# baixar provider da aws e conectar com o bucket s3 para conectar com o statefile
terraform init

# verificação do que vai ser criado
terraform plan

# criação efetiva 
terraform apply
```

### Gerar um arquivo json com os Outputs Configurados do Terraform

esse arquivo vai ser necessário para o ansible consumir os ips atuais das vms
```bash
terraform output -json > terraform_outputs.json
```

### Parte do ansible..