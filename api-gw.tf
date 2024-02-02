################################## Api Gateway ##################################
resource "aws_api_gateway_rest_api" "api_gtw_upload_files" {
  name               = "api_gtw_upload_files"
  binary_media_types = var.supported_binary_media_types
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "s3-proxy-api-deployment-example" {
  depends_on = [
    aws_api_gateway_integration.put_method_integration,
    aws_api_gateway_integration.get_method_integration,
    aws_api_gateway_integration.options_method_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id

  stage_name = "dev"
}

################################## Resources ##################################
resource "aws_api_gateway_resource" "api_gtw_upload_bucket" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  parent_id   = aws_api_gateway_rest_api.api_gtw_upload_files.root_resource_id
  path_part   = "{bucket}"
}

resource "aws_api_gateway_resource" "api_gtw_folder" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  parent_id   = aws_api_gateway_resource.api_gtw_upload_bucket.id
  path_part   = "{folder}"
}

resource "aws_api_gateway_resource" "api_gtw_upload_files" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  parent_id   = aws_api_gateway_resource.api_gtw_folder.id
  path_part   = "{filename}"
}

################################## Methods ##################################
resource "aws_api_gateway_method" "put_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id   = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method   = "PUT"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.Accept"              = false
    "method.request.header.Content-Type"        = false
    "method.request.header.x-amz-meta-fileinfo" = false

    "method.request.path.bucket"   = true
    "method.request.path.folder"   = true
    "method.request.path.filename" = true
  }
}

resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id   = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.x-amz-meta-fileinfo" = false
  }
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id   = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.bucket"   = true
    "method.request.path.folder"   = true
    "method.request.path.filename" = true
  }
}

################################## Methods Response ##################################

resource "aws_api_gateway_method_response" "put_200_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method = aws_api_gateway_method.put_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  depends_on = [aws_api_gateway_method.put_method]
}


resource "aws_api_gateway_method_response" "options_200_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_method_response" "get_200_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  depends_on = [aws_api_gateway_method.get_method]
}

################################## Integrations ##################################

resource "aws_api_gateway_integration" "put_method_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method = aws_api_gateway_method.put_method.http_method

  type                    = "AWS"
  integration_http_method = "PUT"
  credentials             = aws_iam_role.apigw_into_s3_role.arn
  uri                     = "arn:aws:apigateway:${var.region}:s3:path/{bucket}/{folder}/{filename}"

  request_parameters = {
    "integration.request.header.x-amz-meta-fileinfo" = "method.request.header.x-amz-meta-fileinfo"
    "integration.request.header.Accept"              = "method.request.header.Accept"
    "integration.request.header.Content-Type"        = "method.request.header.Content-Type"
    "integration.request.path.filename"              = "method.request.path.filename"
    "integration.request.path.folder"                = "method.request.path.folder"
    "integration.request.path.bucket"                = "method.request.path.bucket"
  }
}

resource "aws_api_gateway_integration" "get_method_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method = aws_api_gateway_method.get_method.http_method

  type                    = "AWS"
  integration_http_method = "GET"
  credentials             = aws_iam_role.apigw_into_s3_role.arn
  uri                     = "arn:aws:apigateway:${var.region}:s3:path/{bucket}/{folder}/{item}"

  request_parameters = {
    "integration.request.path.filename" = "method.request.path.filename"
    "integration.request.path.folder"   = "method.request.path.folder"
    "integration.request.path.bucket"   = "method.request.path.bucket"
  }
}

resource "aws_api_gateway_integration" "options_method_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"
  depends_on  = [aws_api_gateway_method.options_method]

  request_templates = {
    "application/json" = <<EOF
        {
        "statusCode" : 200
        }
    EOF
  }
}

################################## Integrations REsponses ##################################

resource "aws_api_gateway_integration_response" "put_method_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method = aws_api_gateway_method.put_method.http_method

  status_code = aws_api_gateway_method_response.put_200_response.status_code

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "get_method_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method = aws_api_gateway_method.get_method.http_method

  status_code = aws_api_gateway_method_response.get_200_response.status_code

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "options_method_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,x-amz-meta-fileinfo'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_method_response.options_200_response, aws_api_gateway_integration.options_method_integration]
}

######################################################################################################
