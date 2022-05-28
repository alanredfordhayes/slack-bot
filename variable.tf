## API Gateway

variable "name" {
  type = string
  description = "Defualt Name for the Project"
  sensitive = false
}

variable "AWS_ACCOUNT_NUMBER" {}
variable "SLACK_BOT_TOKEN" {}
variable "SLACK_SIGNING_SECRET" {}