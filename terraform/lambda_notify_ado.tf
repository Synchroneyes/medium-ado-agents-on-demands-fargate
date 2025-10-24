resource "aws_cloudwatch_log_subscription_filter" "subscription_listening_jobs" {

  name            = "subscription-listening-jobs"
  log_group_name  = aws_cloudwatch_log_group.ecs.name
  filter_pattern  = "Listening"
  destination_arn = module.notify_ado_ecs_task.lambda_function_arn
}


module "notify_ado_ecs_task" {
  source = "./modules/lambda"

  lambda_function_name = "notify-ado-ecs-task-lambda"

  lambda_code_path              = "${path.module}/code/notify-ado-ecs-task"
  lambda_timeout                = 30
  lambda_memory_size            = 128
  lambda_runtime                = "python3.10"
  lambda_install_requirements   = true
  lambda_requirements_file_name = "requirements.txt"

  lambda_handler = "lambda_function.lambda_handler"

  trigger_lambda_permissions = {
    "cloudwatch_logs" = {
      source_arn = "${aws_cloudwatch_log_group.ecs.arn}:*"
      principal  = "logs.${data.aws_region.current.name}.amazonaws.com"
    }
  }

  lambda_environment_variables = {
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.agents_on_demand_table.name
  }

  lambda_additional_policies_arns = {
    lambda_get_delete_dynamodb_policy = aws_iam_policy.lambda_get_delete_dynamodb.arn
  }

}
