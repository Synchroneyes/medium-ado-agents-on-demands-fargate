output "authentication_secret_arn" {
  description = "The ARN of the secret containing the authentication password for the Lambda function."
  value       = aws_secretsmanager_secret.authentication_password.arn
}

output "get_secret_authentication_password_value" {
  description = "The value of the authentication password for the Lambda function."
  value       = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.authentication_password.id} --query SecretString --output text"
}

output "api_gw_invoke_url" {
  description = "The invoke URL of the API Gateway"
  value       = "${aws_api_gateway_stage.aod_api_stage.invoke_url}/${aws_api_gateway_resource.create_ecs_task.path_part}"
}
