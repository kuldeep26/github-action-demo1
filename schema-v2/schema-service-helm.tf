resource "helm_release" "knative_service" {
  name      = "knative-helm-chart"
  chart     = "./knative-helm-chart"
  namespace = var.namespace
  version   = "1.2.3"
  #  create_namespace = true

  # set {
  #   name  = "ingress.certificateArn"
  #   value = aws_acm_certificate.configurator_cert.arn
  # }

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
    value = var.knative_service_image
  }

  depends_on = [
    helm_release.external_secret,
    aws_db_instance.mydb
  ]

}
