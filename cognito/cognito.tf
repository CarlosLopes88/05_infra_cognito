# Data source para pegar a região atual
data "aws_region" "current" {}

# User Pool
resource "aws_cognito_user_pool" "order_system_pool" {
  name = "order-system-user-pool"

  # Políticas de senha
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # Atributo customizado CPF
  schema {
    name                = "cpf"
    attribute_data_type = "String"
    mutable            = true
    required           = false
    string_attribute_constraints {
      min_length = 11
      max_length = 11
    }
  }

  # Atributos padrão
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Configurações de recuperação de conta
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

# App Client
resource "aws_cognito_user_pool_client" "client" {
  name         = "order-system-client"
  user_pool_id = aws_cognito_user_pool.order_system_pool.id

  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]
}

# Domínio Cognito
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "order-system-auth-domain"
  user_pool_id = aws_cognito_user_pool.order_system_pool.id
}

# Outputs
output "cognito_pool_id" {
  value = aws_cognito_user_pool.order_system_pool.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "cognito_domain" {
  value = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}

# Output para o ARN do User Pool
output "cognito_user_pool_arn" {
  value = aws_cognito_user_pool.order_system_pool.arn
}