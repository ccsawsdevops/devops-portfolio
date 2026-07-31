variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_attachments" {
  type = map(object({
    vpc_id     = string
    subnet_ids = list(string)
  }))
}