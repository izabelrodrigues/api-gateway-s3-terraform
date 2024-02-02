#upload-files-demo

resource "aws_s3_bucket" "upload-files-gw-s3" {
  bucket = "upload-files-gw-s3"

  tags = {
    Name = "My bucket - files"
  }
}
