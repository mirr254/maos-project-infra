output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = module.vpc.private_subnets
}

output "repository_url" {
  description = "The URL of the ECR repository."
  value       = aws_ecr_repository.maosproject.repository_url
}

output "lambda_function_name" {
  description = "The name of the Lambda function."
  value       = aws_lambda_function.maosproject_function.function_name
}

output "api_gateway_url" {
  description = "The URL of the API Gateway."
  value       = aws_api_gateway_deployment.api.invoke_url
}