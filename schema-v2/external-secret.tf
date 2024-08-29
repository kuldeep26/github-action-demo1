resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = var.namespace

}

data "aws_secretsmanager_secret" "rds_password" {
  name = "rds-password" # Adjust the name according to your setup
}

resource "helm_release" "knative_helm_chart" {
  name       = "knative-service"
  chart      = "./knative-helm-chart"
  namespace  = var.namespace

  set {
    name  = "externalSecrets.rdsPasswordKey"
    value = data.aws_secretsmanager_secret.rds_password.name
  }

  set {
    name  = "ingress.certificateArn"
    value = aws_acm_certificate.configurator_cert.arn
  }

  set {
    name  = "namespace"
    value = var.namespace
  }

  set {
    name  = "aws.region"
    value = var.aws_region
  }
}
