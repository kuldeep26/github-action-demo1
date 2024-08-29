resource "helm_release" "knative_service" {
  name       = "knative-helm-chart"
  chart      = "./knative-helm-chart"
  namespace  = var.namespace
#  create_namespace = true

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

  set {
    name  = "knativeService.image"
    value = "590184049425.dkr.ecr.us-east-1.amazonaws.com/ngnix-knative:1.2.1"
  }

  depends_on = [
    helm_release.external_secret
  ]

}
