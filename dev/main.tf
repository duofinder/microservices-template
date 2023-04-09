provider "aws" {
    region = "sa-east-1"
}

// zip file
data "archive_file" "zip" {
    type = "zip"
    source_file = "../zip/bin"
    output_path = "../zip/bin.zip"
}

// the lambda definition
resource "aws_lambda_function" "RENAME_lambda" {
    function_name = "RENAME"
    handler = "bin"
    runtime = "go1.x"
    source_code_hash = filebase64sha256("../zip/bin.zip")
    role = aws_iam_role.RENAME_role.arn
    filename = data.archive_file.zip.output_path
    memory_size = 128
    timeout = 10
}

resource "aws_iam_role" "RENAME_role" {
    name = "RENAME_role"
    assume_role_policy = jsonencode({
        Version: "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
}

// lambda permission
resource "aws_lambda_permission" "allow_api" {
    statement_id = "AllowAPIGatewayInvokation"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.RENAME_lambda.function_name
    principal = "apigateway.amazonaws.com"
}

// API Gateway
resource "aws_api_gateway_rest_api" "duofinder_gateway" {
    name = "duofinder_gateway"
    endpoint_configuration {
      types = [ "REGIONAL" ]
    }
}

resource "aws_api_gateway_resource" "RENAME_resource" {
    rest_api_id = aws_api_gateway_rest_api.duofinder_gateway.id
    parent_id   = aws_api_gateway_rest_api.duofinder_gateway.root_resource_id
    path_part = "RENAME"
}

module "cors" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.duofinder_gateway.id
  api_resource_id = aws_api_gateway_resource.RENAME_resource.id
}

resource "aws_api_gateway_method" "RENAME_method" {
  rest_api_id   = aws_api_gateway_rest_api.duofinder_gateway.id
  resource_id   = aws_api_gateway_resource.RENAME_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "RENAME_integration" {
    rest_api_id = aws_api_gateway_rest_api.duofinder_gateway.id
    resource_id = aws_api_gateway_resource.RENAME_resource.id
    http_method             = aws_api_gateway_method.RENAME_method.http_method
    integration_http_method = "POST"
    type    = "AWS_PROXY"
    uri     = aws_lambda_function.RENAME_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "deploy_gateway_in_dev" {
    rest_api_id = aws_api_gateway_rest_api.duofinder_gateway.id
    stage_name  = "dev"

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.duofinder_gateway.body))
  }

  depends_on = [aws_api_gateway_integration.RENAME_integration]
  lifecycle {
    create_before_destroy = true
  }
}