resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = var.namespace

  set {
    name  = "createNamespace"
    value = "true"
  }
}
