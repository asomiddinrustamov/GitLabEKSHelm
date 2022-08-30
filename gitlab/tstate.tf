terraform {
  backend "s3" {
    bucket         = "nebula-tf-state"
    region         = "us-east-1"
    key            = "nebula-tf-state-gitlab"
  }
}