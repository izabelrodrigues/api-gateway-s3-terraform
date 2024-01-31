resource "aws_api_gateway_rest_api" "api_gtw_upload_files" {
  name = "api_gtw_upload_files"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api_gtw_upload_files" {
  rest_api_id = aws_api_gateway_rest_api.api_gtw_upload_files.id
  parent_id   = aws_api_gateway_rest_api.api_gtw_upload_files.root_resource_id
  path_part   = "files"
}


resource "aws_api_gateway_method" "upload_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id   = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "upload_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gtw_upload_files.id
  resource_id             = aws_api_gateway_resource.api_gtw_upload_files.id
  http_method             = aws_api_gateway_method.upload_method.http_method
  type                    = "AWS"
  integration_http_method = "PUT"
  uri                     = aws_s3_bucket.upload-files-gw-s3.arn
}

