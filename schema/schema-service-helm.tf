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
}

