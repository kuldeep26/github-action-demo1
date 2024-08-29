resource "helm_release" "external_secret" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true

}

data "aws_secretsmanager_secret" "rds_master_password" {
  depends_on = [aws_db_instance.mydb]
  arn = aws_db_instance.mydb.master_user_secret[0].secret_arn
}

data "aws_secretsmanager_secret_version" "rds_master_password_version" {
  depends_on = [aws_db_instance.mydb]
  secret_id = data.aws_secretsmanager_secret.rds_master_password.id
}

# resource "helm_release" "knative_helm_chart" {
#   name       = "knative-service"
#   chart      = "./knative-helm-chart"
#   namespace  = var.namespace

#   set {
#     name  = "externalSecrets.rdsPasswordKey"
#     value = data.aws_secretsmanager_secret.rds_password.name
#   }

#   set {
#     name  = "ingress.certificateArn"
#     value = aws_acm_certificate.configurator_cert.arn
#   }

#   set {
#     name  = "namespace"
#     value = var.namespace
#   }

#   set {
#     name  = "aws.region"
#     value = var.aws_region
#   }
# }
