resource "helm_release" "knative_service" {
  name       = "knative-service"
  chart      = "./knative-helm-chart"
  namespace  = var.namespace

  set {
    name  = "ingress.certificateArn"
    value = aws_acm_certificate.configurator_cert.arn
  }

  set {
    name  = "namespace"
    value = var.namespace
  }

  set {
    name  = "externalSecrets.rdsPasswordKey"
    value = data.aws_secretsmanager_secret.rds_password_secret.name
  }

  set {
    name  = "aws.region"
    value = var.aws_region
  }
}
