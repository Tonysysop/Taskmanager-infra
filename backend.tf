terraform {
  # required_version = ">= 1.11.1"
  backend "s3" {
    bucket         = "mrtonero-statefile"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}