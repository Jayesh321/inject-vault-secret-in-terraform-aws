terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "2.17.0"

          }
  }
}
variable "region" { 
  default = "ap-south-1" 
}
variable "path" { 
  default = "../vault-admin-workspace/terraform.tfstate" 
}
variable "ttl" { 
  default = "1" 
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "admin" {
  backend = "local"

  config = {
    path = var.path
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = data.terraform_remote_state.admin.outputs.backend
  role    = data.terraform_remote_state.admin.outputs.role
}

provider "aws" {
  region = "${var.region}"
  access_key = "${data.vault_aws_access_credentials.creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.creds.secret_key}"
}


resource "aws_instance" "myinstance" {
  ami           = "ami-06a0b4e3b7eb7a300"
  instance_type = "t2.micro"
  key_name      = "jenkins"
  tags = {
    name = "Terraform-instance"
  }
}