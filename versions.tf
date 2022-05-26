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
      version = "~> 4.15.1"
    }
  }

  required_version = ">= 0.14.0"
}