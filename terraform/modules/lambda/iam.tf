resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_function_name}_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_additional_policies_arns" {
  for_each   = var.lambda_additional_policies_arns
  role       = aws_iam_role.lambda_exec.name
  policy_arn = each.value
}
