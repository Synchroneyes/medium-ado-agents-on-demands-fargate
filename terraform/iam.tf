resource "aws_iam_policy" "access_authentication_secret_policy" {
  name        = "ado-on-demand-access-auth-secret"
  description = "Policy to allow access to the authentication secret"
  policy      = data.aws_iam_policy_document.access_secrets.json
}

resource "aws_iam_policy" "list_task_definitions_policy" {
  name        = "ado-on-demand-list-task-definitions"
  description = "Policy to allow listing and describing ECS task definitions"
  policy      = data.aws_iam_policy_document.list_task_definitions.json
}

resource "aws_iam_policy" "lambda_run_ecs_task_policy" {
  name        = "ado-on-demand-lambda-run-ecs-task"
  description = "Policy to allow Lambda to run ECS tasks"
  policy      = data.aws_iam_policy_document.lambda_run_ecs_task.json
}

resource "aws_iam_policy" "lambda_get_ado_token_pat_policy" {
  name        = "ado-on-demand-lambda-get-ado-token-pat"
  description = "Policy to allow Lambda to get Azure DevOps token from Secrets Manager"
  policy      = data.aws_iam_policy_document.lambda_get_ado_token_pat.json

}

resource "aws_iam_policy" "lambda_write_dynamodb_policy" {
  name        = "ado-on-demand-lambda-write-dynamodb"
  description = "Policy to allow Lambda to write to DynamoDB"
  policy      = data.aws_iam_policy_document.lambda_write_dynamodb.json
}

resource "aws_iam_policy" "lambda_get_delete_dynamodb" {
  name        = "ado-on-demand-lambda-get-delete-dynamodb"
  description = "Policy to allow Lambda to get and delete items in DynamoDB"
  policy      = data.aws_iam_policy_document.lambda_get_delete_dynamodb.json
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ado-on-demand-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ado-on-demand-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_task_policy" {
  name        = "ado-on-demand-ecs-task-policy"
  description = "Policy to allow ECS tasks to write logs"
  policy      = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

