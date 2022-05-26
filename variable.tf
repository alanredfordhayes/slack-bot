## API Gateway

variable "name" {
  type = string
  description = "Defualt Name for the Progject"
  sensitive = false
}

variable "path_part" {
  default = "event_api"
  description = "aws_api_gateway_resource_path_part"
}

variable "stage_name" {
  default = "dev"
  description = "aws_api_gateway_stage_stage_name"
}