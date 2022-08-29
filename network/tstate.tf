terraform {
  backend "s3" {
    bucket         = "nebula-tf-state"
    region         = "us-east-1"
    key            = "nebula-tf-state-network"
    #dynamodb_table = "nebula-tf-state-gov-east-1-state-lock"
  }
}