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

# data "kubernetes_ingress_v1" "alb_ingress_status" {
#   metadata {
#     name      = kubernetes_ingress_v1.alb_ingress.metadata[0].name
#     namespace = kubernetes_ingress_v1.alb_ingress.metadata[0].namespace
#   }
# }

# resource "null_resource" "wait_for_ingress" {
#   depends_on = [
#     kubernetes_ingress_v1.alb_ingress
#   ]
#   provisioner "local-exec" {
#     command = "sleep 60"  # Adjust the sleep time as necessary to wait for the ingress to be fully ready
#   }
# }

# Fetch the ALB details, including the hosted zone ID
# data "aws_lb" "alb" {
#   name = kubernetes_ingress_v1.alb_ingress.status.0.load_balancer.0.ingress.0.hostname
# }

# Create the Route 53 alias record pointing to the ALB
# resource "aws_route53_record" "alb_alias" {
#   zone_id = data.aws_route53_zone.domain.zone_id
#   name    = "*.593546282661.realhandsonlabs.net"
#   type    = "A"  # Alias records must use type "A" or "AAAA"

#   alias {
#     name                   = kubernetes_ingress_v1.alb_ingress.status.0.load_balancer.0.ingress.0.hostname
#     zone_id                = data.aws_route53_zone.domain.zone_id  # Use the ALB's hosted zone ID
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "alb_cname" {
#   zone_id = data.aws_route53_zone.domain.zone_id  # Your Route 53 hosted zone ID
#   name    = "*.593546282661.realhandsonlabs.net"                    # Your domain name
#   type    = "CNAME"
#   ttl     = 300                            # Time to live (TTL) for the record
#   records = [data.aws_lb.alb.dns_name]     # ALB DNS name
# }