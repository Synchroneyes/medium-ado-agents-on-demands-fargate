data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "access_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      aws_secretsmanager_secret.authentication_password.arn
    ]
  }
}

data "aws_iam_policy_document" "list_task_definitions" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "lambda_run_ecs_task" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:RunTask",
      "ecs:StopTask",
      "iam:PassRole"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "lambda_get_ado_token_pat" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [aws_secretsmanager_secret.authentication_password.arn, aws_secretsmanager_secret.pat_token.arn]
  }
}

data "aws_iam_policy_document" "lambda_write_dynamodb" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
    ]
    resources = [
      aws_dynamodb_table.agents_on_demand_table.arn
    ]
  }
}

data "aws_iam_policy_document" "lambda_get_delete_dynamodb" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
    ]
    resources = [
      aws_dynamodb_table.agents_on_demand_table.arn
    ]
  }
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}
