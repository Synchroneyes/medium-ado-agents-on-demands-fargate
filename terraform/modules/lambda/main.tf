resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_function_name
  filename      = data.archive_file.lambda_package_python[0].output_path
  role          = aws_iam_role.lambda_exec.arn
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size
  handler       = var.lambda_handler
  logging_config {
    log_group  = aws_cloudwatch_log_group.lambda_log_group.name
    log_format = "Text"
  }

  source_code_hash = data.archive_file.lambda_package_python[0].output_base64sha256

  environment {
    variables = var.lambda_environment_variables
  }

}


resource "aws_lambda_permission" "cwlogs" {
  for_each      = var.trigger_lambda_permissions
  function_name = aws_lambda_function.lambda_function.function_name
  action        = "lambda:InvokeFunction"
  principal     = each.value.principal

  source_arn = each.value.source_arn

}
