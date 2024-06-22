terraform {
  backend "s3" {
    bucket = "test"
    key = "services/eks/terraform.tfstate"
  }
}
