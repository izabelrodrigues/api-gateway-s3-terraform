## POLICY ##
resource "aws_iam_policy" "upload_files_apigw_into_s3" {
  name        = "upload_files_apigw_into_s3"
  path        = "/"
  description = "Add permision upload objects into S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
        ]
        Resource = "arn:aws:s3:::upload-files-gw-s3/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

## ROLE ##

data "aws_iam_policy_document" "apigw_assume_role_policy" {

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }

}

resource "aws_iam_role" "apigw_into_s3_role" {
  name               = "apigw_into_s3_role"
  assume_role_policy = data.aws_iam_policy_document.apigw_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "upload_attach" {
  role       = aws_iam_role.apigw_into_s3_role.name
  policy_arn = aws_iam_policy.upload_files_apigw_into_s3.arn
}
