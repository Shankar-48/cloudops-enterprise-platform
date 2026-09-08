# -------------------------
# API Gateway HTTP API
# -------------------------

resource "aws_apigatewayv2_api" "cloudops_api" {
  name          = "cloudops-enterprise-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins = ["*"]
  }

  tags = {
    Project = "CloudOps Enterprise Platform"
  }
}

# -------------------------
# Lambda Integration
# -------------------------

resource "aws_apigatewayv2_integration" "cloudops_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.cloudops_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.cloudops_lambda.invoke_arn
  payload_format_version = "2.0"
}

# -------------------------
# API Routes
# -------------------------

resource "aws_apigatewayv2_route" "cloudops_default_route" {
  api_id    = aws_apigatewayv2_api.cloudops_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.cloudops_lambda_integration.id}"
}

# -------------------------
# API Stage
# -------------------------

resource "aws_apigatewayv2_stage" "cloudops_stage" {
  api_id      = aws_apigatewayv2_api.cloudops_api.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Project = "CloudOps Enterprise Platform"
  }
}

# -------------------------
# Lambda Permission
# -------------------------

resource "aws_lambda_permission" "cloudops_api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudops_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.cloudops_api.execution_arn}/*"
}

# -------------------------
# API URL Output
# -------------------------

output "api_gateway_url" {
  value = aws_apigatewayv2_api.cloudops_api.api_endpoint
}