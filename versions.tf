terraform {

  cloud {
    organization = "alanredfordhayes"

    workspaces {
      name = "slack-bot"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }

  required_version = ">= 0.14.0"
}