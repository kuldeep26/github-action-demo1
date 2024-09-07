resource "aws_acm_certificate" "configurator_cert" {
  domain_name       = "*.975049981142.realhandsonlabs.net"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "configurator_cert_validate" {
  certificate_arn = aws_acm_certificate.configurator_cert.arn

  validation_record_fqdns = [
    for record in aws_route53_record.configurator_cert_validation : record.fqdn
  ]
}

resource "aws_route53_record" "configurator_cert_validation" {
  for_each = {
    for cert in aws_acm_certificate.configurator_cert.domain_validation_options : cert.domain_name => {
      name   = cert.resource_record_name
      record = cert.resource_record_value
      type   = cert.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain.zone_id
}

data "aws_route53_zone" "domain" {
  name         = "975049981142.realhandsonlabs.net"
  private_zone = false
}
