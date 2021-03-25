terraform {
  backend "s3" {
    bucket = "terraform-bucket-sp-southeast-2"
    key    = "terraform_state"
    region = "ap-southeast-2"
    profile = "default"
    role_arn = "arn:aws:iam::123456789012:role/TerraformBuilderRole"
  }
}