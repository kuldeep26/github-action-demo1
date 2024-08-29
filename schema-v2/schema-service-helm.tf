resource "helm_release" "knative_service" {
  name      = "knative-helm-chart"
  chart     = "./knative-helm-chart"
  namespace = var.namespace
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
    value = local.rds_secret_name
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
    null_resource.create_ecr_registry_secret
  ]

}
