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

# output "eks_cluster_endpoint" {
#   value = module.eks.cluster_endpoint
# }