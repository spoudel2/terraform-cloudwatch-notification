terraform {
  backend "s3" {
    bucket = "s3idol"
    key    = "cloudwatch-demo/terraform.tfstate"
    region = "us-east-1"
  }
}
