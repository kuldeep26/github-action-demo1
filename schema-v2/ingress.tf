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

data "kubernetes_ingress_v1" "alb_ingress_status" {
  metadata {
    name      = kubernetes_ingress_v1.alb_ingress.metadata[0].name
    namespace = kubernetes_ingress_v1.alb_ingress.metadata[0].namespace
  }
}

# Fetch the ALB details, including the hosted zone ID
data "aws_lb" "alb" {
  dns_name = data.kubernetes_ingress_v1.alb_ingress_status.status[0].load_balancer.ingress[0].hostname
}

# Create the Route 53 alias record pointing to the ALB
resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "*.593546282661.realhandsonlabs.net"
  type    = "A"  # Alias records must use type "A" or "AAAA"

  alias {
    name                   = data.kubernetes_ingress_v1.alb_ingress_status.status[0].load_balancer.ingress[0].hostname
    zone_id                = data.aws_lb.alb.zone_id  # Use the ALB's hosted zone ID
    evaluate_target_health = false
  }
}