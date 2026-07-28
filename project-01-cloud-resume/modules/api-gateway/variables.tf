variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "resource_path" {
  description = "API resource path"
  type        = string
  default     = "visits"
}

variable "http_method" {
  description = "HTTP method"
  type        = string
  default     = "GET"
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}