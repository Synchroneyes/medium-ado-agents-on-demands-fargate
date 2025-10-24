module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ado-on-demands-cluster"

  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
  }
}

resource "aws_ecs_task_definition" "aod_task_definition" {
  family                   = "ado-on-demands-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name = "ado-on-demands-task"
      environment = [
        {
          name  = "AZP_POOL"
          value = var.azure_devops_agent_pool
        }
      ]
      image     = "${aws_ecr_repository.on_demands_repository.repository_url}:latest"
      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/ado-on-demands-task"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }

  ])


}

resource "aws_security_group" "aod_sg" {
  name_prefix = "ado-on-demands-sg"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "aod_egress" {
  security_group_id = aws_security_group.aod_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/ado-on-demands-task"
  retention_in_days = 7
}
