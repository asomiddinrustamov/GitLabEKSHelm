variable "region" {
  type = string
}

variable "az" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "eks_cluster_name" {
  type    = string
  default = "devops"
}

variable "public_dns_name" {
  type = string
}

variable "rds_port" {
  type    = number
  default = 5432
}

variable "acm_gitlab_arn" {
  type = string
}

variable "certmanager_issuer_email" {
  type = string
}

variable "cluster_security_group_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "openid_arn" {
  type        = string
  description = "aws_iam_openid_connect_provider.arn"
}

variable "openid_url" {
  type        = string
  description = "aws_iam_openid_connect_provider.url"
}

variable "eks_endpoint" {
  type = string
}

variable "kubeconfig_cert_auth_data" {
  type = string
}

variable "private_subnet_cidr_block" {
  type = list(string)
}
