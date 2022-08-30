data "terraform_remote_state" "network" {
  backend = "s3"
  workspace = "default"

  config = {
    bucket         = "nebula-tf-state"
    region         = "us-east-1"
    key            = "nebula-tf-state-network"
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  workspace = "default"

  config = {
    bucket         = "nebula-tf-state"
    region         = "us-east-1"
    key            = "nebula-tf-state-eks"
  }
}
