## API Gateway

variable "name" {
  type = string
  description = "Defualt Name for the Project"
  sensitive = false
}

variable "AWS_ACCOUNT_NUMBER" {}
variable "SLACK_BOT_TOKEN" {}
variable "SLACK_SIGNING_SECRET" {}

# variable "path_part" {
#   default = 
#   description = "aws_api_gateway_resource_path_part"
# }

# variable "stage_name" {
#   default = 
#   description = "aws_api_gateway_stage_stage_name"
# }