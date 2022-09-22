provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host = var.eks_endpoint

  cluster_ca_certificate = base64decode(
    var.kubeconfig_cert_auth_data
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host = var.eks_endpoint

    cluster_ca_certificate = base64decode(
      var.kubeconfig_cert_auth_data
    )

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
      command     = "aws"
    }
  }
}
