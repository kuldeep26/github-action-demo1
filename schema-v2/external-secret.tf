resource "helm_release" "external_secret" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true

}

resource "null_resource" "wait_for_rds_secret" {
  depends_on = [aws_db_instance.mydb]

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

data "aws_secretsmanager_secret" "rds_master_password" {
  depends_on = [null_resource.wait_for_rds_secret]
  arn = aws_db_instance.mydb.master_user_secret[0].secret_arn
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
