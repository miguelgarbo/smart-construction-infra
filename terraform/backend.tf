
#o backend do terraform signifca o lugar aonde vai ser armazenado o statefile

terraform {
  backend "s3" {
    bucket       = "smart-construction-tfstate-grupo13"
    key          = "smart-construction/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
