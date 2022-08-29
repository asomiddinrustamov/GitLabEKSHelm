output "eks-endpoint" {
    value = aws_eks_cluster.devops.endpoint
}

output "kubeconfig-certificate-authority-data" {
    value = aws_eks_cluster.devops.certificate_authority[0].data
}

output "eks_issuer_url" {
    value = aws_iam_openid_connect_provider.openid.url
}