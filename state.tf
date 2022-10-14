terraform {
  backend "s3" {
    bucket = "se-cluster-tf"
    region = "us-west-2"
    dynamodb_table = "cera-tf-lock"
  }
}