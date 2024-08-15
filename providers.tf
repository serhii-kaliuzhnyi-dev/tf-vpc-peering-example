terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.62.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias                   = "root"
  region                  = var.region
  profile                 = "my_tf"
}

provider "aws" {
  alias                   = "peer"
  region                  = var.region
  profile                 = "sigma_tf"
}
