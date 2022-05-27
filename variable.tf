## API Gateway

variable "name" {
  type = string
  description = "Defualt Name for the Project"
  sensitive = false
}

# variable "AWS_ACCOUNT_NUMBER" {
#   type = string
#   description = "Account Number for AWS"
# }

variable "path_part" {
  default = "event_api"
  description = "aws_api_gateway_resource_path_part"
}

variable "stage_name" {
  default = "dev"
  description = "aws_api_gateway_stage_stage_name"
}