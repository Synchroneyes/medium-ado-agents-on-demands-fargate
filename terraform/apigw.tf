resource "aws_api_gateway_rest_api" "aod_api" {
  name        = "ado-on-demands-agents-api"
  description = "API Gateway for Agents On Demand"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "create_ecs_task" {
  rest_api_id = aws_api_gateway_rest_api.aod_api.id
  parent_id   = aws_api_gateway_rest_api.aod_api.root_resource_id
  path_part   = "create-ecs-task"
}

resource "aws_api_gateway_method" "post_create_ecs_task" {
  rest_api_id   = aws_api_gateway_rest_api.aod_api.id
  resource_id   = aws_api_gateway_resource.create_ecs_task.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.aod_api.id
  resource_id = aws_api_gateway_resource.create_ecs_task.id
  http_method = aws_api_gateway_method.post_create_ecs_task.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.create_ecs_task.lambda_function_invoke_arn
}

resource "aws_api_gateway_deployment" "aod_api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.aod_api.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "aod_api_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.aod_api.id
  deployment_id = aws_api_gateway_deployment.aod_api_deployment.id

  lifecycle {
    create_before_destroy = true
  }
}
