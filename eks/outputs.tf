output "eks-endpoint" {
  value = aws_eks_cluster.devops.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.devops.certificate_authority[0].data
}

output "eks_issuer_url" {
  value = aws_iam_openid_connect_provider.openid.url
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.devops.vpc_config[0].cluster_security_group_id
}

output "openid_arn" {
  value = aws_iam_openid_connect_provider.openid.arn
}

output "openid_url" {
  value = aws_iam_openid_connect_provider.openid.url
}

output "node_group_private" {
  value = aws_eks_node_group.private.id
}

output "node_group_public" {
  value = aws_eks_node_group.public.id
}