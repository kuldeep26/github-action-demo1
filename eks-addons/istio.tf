locals {
  istio_chart_url = "https://istio-release.storage.googleapis.com/charts"
  // Note: Before updating the version, check the compatibility matrix of Istio
  istio_version = "1.22.2"
}

resource "null_resource" "istio_installation" {

  provisioner "local-exec" {
    command = "istioctl install -y"
  }

  depends_on = [
    terraform_data.knative_serving,
  ]
}


/// knative istio intergration ///

resource "terraform_data" "knative-istio-integration" {
  triggers_replace = {
    knative_version           = var.knative_version,
    knative_istio_int_version = var.knative_istio_int_version
  }

  provisioner "local-exec" {
    command = <<EOF
            kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-${var.knative_istio_int_version}/net-istio.yaml
        EOF
  }

  depends_on = [
    null_resource.istio_installation
  ]
}

//Disabling for now
# resource "terraform_data" "peer_authentication" {
#   triggers_replace = {
#     knative_version = var.knative_version
#   }

#   provisioner "local-exec" {
#     command = "kubectl apply -f ${path.module}/manifest/peer_authentication.yaml"
#   }

#   depends_on = [
#     kubernetes_namespace.knative-serving,
#     helm_release.istio-ingressgateway,
#   terraform_data.knative-istio-integration]
# }

#the external ID and CNAME can also be extracted from the hekm_release.istio-ingressgateway resource
# data "kubernetes_service" "istio_ingressgateway" {
#   metadata {
#     name      = "istio-ingressgateway"
#     namespace = "istio-system"
#   }
# }