provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.eks-endpoint

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.eks.outputs.kubeconfig-certificate-authority-data
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.eks-endpoint

    cluster_ca_certificate = base64decode(
        data.terraform_remote_state.eks.outputs.kubeconfig-certificate-authority-data
    )

    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
        command     = "aws"
    }
  }
}