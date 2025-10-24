module "create_ecs_task" {
  source = "./modules/lambda"

  lambda_function_name          = "create-ecs-task-lambda"
  lambda_code_path              = "${path.module}/code/create-ecs-task"
  lambda_timeout                = 30
  lambda_memory_size            = 128
  lambda_runtime                = "python3.10"
  lambda_install_requirements   = true
  lambda_requirements_file_name = "requirements.txt"

  lambda_handler = "lambda_function.lambda_handler"

  trigger_lambda_permissions = {
    "api_gw" = {
      source_arn = "${aws_api_gateway_rest_api.aod_api.execution_arn}/*/*"
      principal  = "apigateway.amazonaws.com"
    }
  }


  lambda_environment_variables = {
    ADO_AUTHENTICATION_PASSWORD = aws_secretsmanager_secret.authentication_password.arn
    ECS_CLUSTER_NAME            = module.ecs.cluster_name
    ECS_CLUSTER_ARN             = module.ecs.cluster_arn
    SUBNETS_IDS                 = join(",", var.subnet_ids)
    ADO_TOKEN_ARN               = aws_secretsmanager_secret.pat_token.arn
    ECS_SECURITY_GROUP_ID       = aws_security_group.aod_sg.id
    DYNAMODB_TABLE_NAME         = aws_dynamodb_table.agents_on_demand_table.name
    AGENT_TASK_DEFINITION_ARN   = aws_ecs_task_definition.aod_task_definition.arn
  }

  lambda_additional_policies_arns = {
    access_authentication_secret_policy = aws_iam_policy.access_authentication_secret_policy.arn
    list_task_definitions_policy        = aws_iam_policy.list_task_definitions_policy.arn
    lambda_run_ecs_task_policy          = aws_iam_policy.lambda_run_ecs_task_policy.arn
    lambda_get_ado_token_pat_policy     = aws_iam_policy.lambda_get_ado_token_pat_policy.arn
    lambda_write_dynamodb_policy        = aws_iam_policy.lambda_write_dynamodb_policy.arn
  }

}
