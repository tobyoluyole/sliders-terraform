terraform {
  backend "s3" {
    bucket         = "sliders-terraform-state-323708468663"
    key            = "env/production/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}