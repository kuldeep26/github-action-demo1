resource "helm_release" "knative_service" {
  name       = "knative-service"
  namespace  = "helloworld"
  chart      = "./knative-helm-chart"

  set {
    name  = "ingress.certificateArn"
    value = aws_acm_certificate.configurator_cert.arn
  }
}
