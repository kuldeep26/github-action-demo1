locals {
  istio_chart_url = "https://istio-release.storage.googleapis.com/charts"
  // Note: Before updating the version, check the compatibility matrix of Istio
  istio_version = "1.22.0"
}

resource "helm_release" "istio-base" {
  repository       = local.istio_chart_url
  chart            = "base"
  name             = "istio-base"
  namespace        = "istio-system"
  version          = local.istio_version
  create_namespace = true

  depends_on = [aws_eks_addon.core-dns]
}

resource "helm_release" "istiod" {
  repository = local.istio_chart_url
  chart      = "istiod"
  name       = "istiod"
  namespace  = "istio-system"
  version    = local.istio_version
  wait       = true

  depends_on = [helm_release.istio-base]
}

# TODO: make istio-ingressgateway a nodeport service to link it to AWS ALB
resource "helm_release" "istio-ingressgateway" {
  repository = local.istio_chart_url
  chart      = "gateway"
  name       = "istio-ingressgateway"
  # TODO: verify this value
  namespace = kubernetes_namespace.istio_ingress.metadata[0].name
  version   = local.istio_version

  depends_on = [helm_release.istiod]
}

resource "kubernetes_namespace" "istio_ingress" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }

    name = "istio-ingress"
  }

  depends_on = [helm_release.istiod]
}
