6. Estrutura sugerida do repositório
pm04-infrastructure/
.github/workflows/deploy.yml
terraform/
main.tf variables.tf outputs.tf
providers.tf backend.tf
ansible/
inventory/ playbook.yml group_vars/
roles/os_updates/
roles/docker/
roles/containers/
README.md
evidencias/