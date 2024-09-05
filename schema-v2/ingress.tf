  resource "kubernetes_ingress_v1" "alb_ingress" {
  depends_on = [
    helm_release.knative_service
  ]
  metadata {
    name      = "test-alb-2"
    namespace = "istio-system"
    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/certificate-arn" = aws_acm_certificate.configurator_cert.arn
      "alb.ingress.kubernetes.io/target-type"     = "ip"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "istio-ingressgateway"
              port {
                number = 80
              }
            }
          }
          path = "/"
          path_type = "Prefix"
        }
      }
    }
  }
}

data "aws_lb" "alb" {
  name = kubernetes_ingress_v1.alb_ingress.metadata[0].name
}

resource "aws_route53_record" "dns_record" {
  depends_on = [
    kubernetes_ingress_v1.alb_ingress
  ]
  zone_id         = data.aws_route53_zone.domain.zone_id
  name            = "*.593546282661.realhandsonlabs.net"
  type            = "A"
  allow_overwrite = false

  alias {
    name                   = data.aws_lb.alb.dns_name
    zone_id                = data.aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}