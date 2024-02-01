resource "aws_api_gateway_rest_api" "api_gtw_upload_files" {
  name = "api_gtw_upload_files"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  binary_media_types = ["image/png"]

}

resource "aws_api_gateway_resource" "api_gtw_upload_bucket" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  parent_id   = aws_api_gateway_rest_api.api_gtw_upload_files.root_resource_id
  path_part   = "{bucket}"
}

resource "aws_api_gateway_resource" "api_gtw_upload_files" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  parent_id   = aws_api_gateway_resource.api_gtw_upload_bucket.id
  path_part   = "{filename}"
}


resource "aws_api_gateway_method" "upload_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id   = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    #   "method.request.header.Accept"              = false
    #   "method.request.header.Content-Type"        = false
    #   "method.request.header.x-amz-meta-fileinfo" = false
    "method.request.path.bucket"   = true
    "method.request.path.filename" = true
  }
}

resource "aws_api_gateway_integration" "upload_integration_request" {
  rest_api_id             = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id             = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method             = aws_api_gateway_method.upload_method.http_method
  type                    = "AWS"
  integration_http_method = "PUT"
  uri                     = "arn:aws:apigateway:us-east-1:s3:action/PutObject"
  credentials             = aws_iam_role.apigw_into_s3_role.arn
  request_parameters = {
    "integration.request.path.bucket" = "method.request.path.bucket"
    "integration.request.path.key"    = "method.request.path.filename"
  }
  depends_on = [aws_api_gateway_method.upload_method]
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method = aws_api_gateway_method.upload_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [aws_api_gateway_method.upload_method]
}

resource "aws_api_gateway_integration_response" "upload_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method = aws_api_gateway_method.upload_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

resource "aws_api_gateway_deployment" "upload_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  stage_name  = "dev"
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_integration.upload_integration_request, aws_api_gateway_integration_response.upload_integration_response]
}

resource "aws_api_gateway_method_settings" "api_settings" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  stage_name  = "dev"
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }

  depends_on = [aws_api_gateway_deployment.upload_deployment]

}










