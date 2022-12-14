data "template_file" "gitlab-values" {
  template = <<EOF

# Values for gitlab/gitlab chart on EKS
global:
  serviceAccount:
    enabled: true
    create: false
    name: aws-access
  platform:
    eksRoleArn: ${aws_iam_role.gitlab-access.arn}

  nodeSelector:
    eks.amazonaws.com/nodegroup: private

  shell:
    authToken:
      secret: ${kubernetes_secret.shell-secret.metadata.0.name}
      key: password

  edition: ce

  hosts:
    domain: ${var.public_dns_name}
    https: true
    gitlab:
      name: gitlab.${var.public_dns_name}
      https: true
    ssh: ~

  ## doc/charts/globals.md#configure-ingress-settings
  ingress:
    tls:
      enabled: false

  ## doc/charts/globals.md#configure-postgresql-settings
  psql:
    password:
       secret: ${kubernetes_secret.gitlab-postgres.metadata.0.name}
       key: psql-password
    host: ${aws_db_instance.gitlab-primary.address}
    port: ${var.rds_port}
    username: gitlab
    database: gitlabhq_production

  redis:
    password:
      enabled: false
    host: ${aws_elasticache_cluster.gitlab.cache_nodes[0].address}

  ## doc/charts/globals.md#configure-minio-settings
  minio:
    enabled: false

  ## doc/charts/globals.md#configure-appconfig-settings
  ## Rails based portions of this chart share many settings
  appConfig:
    ## doc/charts/globals.md#general-application-settings
    enableUsagePing: false

    ## doc/charts/globals.md#lfs-artifacts-uploads-packages
    backups:
      bucket: ${aws_s3_bucket.gitlab-backups.id}
    lfs:
      bucket: ${aws_s3_bucket.git-lfs.id}
      connection:
        secret: ${kubernetes_secret.s3-storage-credentials.metadata.0.name}
        key: connection
    artifacts:
      bucket: ${aws_s3_bucket.gitlab-artifacts.id}
      connection:
        secret: ${kubernetes_secret.s3-storage-credentials.metadata.0.name}
        key: connection
    uploads:
      bucket: ${aws_s3_bucket.gitlab-uploads.id}
      connection:
        secret: ${kubernetes_secret.s3-storage-credentials.metadata.0.name}
        key: connection
    packages:
      bucket: ${aws_s3_bucket.gitlab-packages.id}
      connection:
        secret: ${kubernetes_secret.s3-storage-credentials.metadata.0.name}
        key: connection
    ## doc/charts/globals.md#pseudonymizer-settings
    pseudonymizer:
      bucket: ${aws_s3_bucket.gitlab-pseudo.id}
      connection:
        secret: ${kubernetes_secret.s3-storage-credentials.metadata.0.name}
        key: connection
nginx-ingress:
  controller:
    config:
        use-forwarded-headers: "true" 
    service:
        annotations:
            service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
            service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "3600"
            service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${var.acm_gitlab_arn}
            service.beta.kubernetes.io/aws-load-balancer-ssl-ports: https
        targetPorts:
            https: http # the ELB will send HTTP to 443

certmanager-issuer:
  email: ${var.certmanager_issuer_email}

prometheus:
  install: false

redis:
  install: false


gitlab:
  gitaly:
    persistence:
      volumeName: ${kubernetes_persistent_volume_claim.gitaly.metadata.0.name}
    nodeSelector:
      topology.kubernetes.io/zone: ${var.az[0]}
  toolbox:
    backups:
      objectStorage:
        backend: s3
        config:
          secret: ${kubernetes_secret.s3-storage-credentials.metadata.0.name}
          key: connection
    annotations:
      eks.amazonaws.com/role-arn: ${aws_iam_role.gitlab-access.arn}
  webservice:
    annotations:
      eks.amazonaws.com/role-arn: ${aws_iam_role.gitlab-access.arn}
  sidekiq:
    annotations:
      eks.amazonaws.com/role-arn: ${aws_iam_role.gitlab-access.arn}
  migrations:
    # Migrations pod must point directly to PostgreSQL primary
    psql:
      password:
        secret: ${kubernetes_secret.gitlab-postgres.metadata.0.name}
        key: psql-password
      host: ${aws_db_instance.gitlab-primary.address}
      port: ${var.rds_port}

postgresql:
  install: false

gitlab-runner:
  install: true
  rbac:
    create: true
  runners:
    locked: false

registry:
  enabled: true
  annotations:
    eks.amazonaws.com/role-arn: aws_iam_role.gitlab-access.arn
  storage:
    secret: ${kubernetes_secret.s3-registry-storage-credentials.metadata.0.name}
    key: config

EOF
}

resource "helm_release" "gitlab" {
  name       = "gitlab"
  namespace  = "gitlab"
  timeout    = 600

  chart      = "gitlab/gitlab"
  version    = "6.1.0" #"4.11.3" 

  values     = [data.template_file.gitlab-values.rendered]

  depends_on = [
      # data.terraform_remote_state.eks.outputs.node_group_private,
      # data.terraform_remote_state.eks.outputs.node_group_public,
      aws_db_instance.gitlab-primary,
      # aws_db_instance.gitlab-replica,
      aws_elasticache_cluster.gitlab,
      aws_iam_role_policy.gitlab-access,
      kubernetes_namespace.gitlab,
      kubernetes_secret.gitlab-postgres,
      kubernetes_secret.s3-storage-credentials,
      kubernetes_secret.s3-registry-storage-credentials,
      kubernetes_persistent_volume_claim.gitaly
  ]
}

data "kubernetes_service" "gitlab-webservice" {
  metadata {
    name      = "gitlab-nginx-ingress-controller"
    namespace = "gitlab"
  }

  depends_on = [
    helm_release.gitlab
  ]
}

resource "aws_route53_record" "gitlab" {
 zone_id    = data.aws_route53_zone.public.zone_id
 name       = "gitlab.${var.public_dns_name}"
 type       = "CNAME"
 ttl        = "300"
 records    = [data.kubernetes_service.gitlab-webservice.status.0.load_balancer.0.ingress.0.hostname]

 depends_on = [
   helm_release.gitlab,
   data.kubernetes_service.gitlab-webservice
 ]
}