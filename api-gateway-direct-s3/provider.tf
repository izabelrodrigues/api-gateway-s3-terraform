terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.34.0"
    }
  }
}

# provider "aws" {
#   shared_config_files      = ["%USERPROFILE%\\.aws\\config"]
#   shared_credentials_files = ["%USERPROFILE%\\.aws\\credentials"]
#   profile                  = "default"
# }
