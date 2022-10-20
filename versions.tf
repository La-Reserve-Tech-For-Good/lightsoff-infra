terraform {
  backend "s3" {
    key = "terraform.tfstate"
  }

  # https://github.com/hashicorp/terraform/releases
  required_version = "= 1.3.3"

  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/latest
      source  = "hashicorp/aws"
      version = "4.35.0"
    }
  }
}
