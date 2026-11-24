## Infraestrutura do Smart Construction - Terraform + Ansible + GitHub Actions

Projeto fonte: [https://github.com/LaercioMLB/smart-construction][repo_prof]

[repo_prof]: https://github.com/LaercioMLB/smart-construction




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

rascunho:

baixar docker de uma vez só no ubuntu

sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io