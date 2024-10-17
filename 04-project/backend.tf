terraform {
  backend "s3" {
    bucket = "terraform-vapp-state-01"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}
