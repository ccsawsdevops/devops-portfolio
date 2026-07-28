# environments/dev/outputs.tf

output "website_endpoint" {
  description = "S3 website endpoint"
  value       = module.s3_website.website_endpoint
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}