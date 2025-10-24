ephemeral "random_password" "authentication_password" {
  length           = 32
  special          = true
  upper            = true
  lower            = true
  override_special = "!#$%^*"
}

resource "aws_secretsmanager_secret" "authentication_password" {
  name                    = "ado/on_demands/authentication"
  description             = "Authentication secret use for on demands agent used between AzureDevOps and ApiGW"
  recovery_window_in_days = 7
}


resource "aws_secretsmanager_secret_version" "authentication_password" {
  secret_id = aws_secretsmanager_secret.authentication_password.id
  secret_string_wo = jsonencode({
    password = ephemeral.random_password.authentication_password.result
  })

  secret_string_wo_version = 2
}

resource "aws_secretsmanager_secret" "pat_token" {
  name                    = "ado/on_demands/pat_token"
  description             = "Personal Access Token for Azure DevOps"
  recovery_window_in_days = 7
}
