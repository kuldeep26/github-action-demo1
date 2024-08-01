resource "terraform_data" "knative-istio-integration" {
  triggers_replace = {
    knatice_version = "v1.14.1"
  }

  provisioner "local-exec" {
    command = <<EOF
            kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.14.1/net-istio.yaml
        EOF
  }

  depends_on = [terraform_data.knative_serving, helm_release.istio-ingressgateway]
}

resource "terraform_data" "peer_authentication" {
  triggers_replace = {
    knative_version = "v1.14.1"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/manifest-files/peer_authentication.yaml"
  }

  depends_on = [
    kubernetes_namespace.knative-serving,
    helm_release.istio-ingressgateway,
  terraform_data.knative-istio-integration]
}

# the external ID and CNAME can also be extracted from the hekm_release.istio-ingressgateway resource
data "kubernetes_service" "istio_ingressgateway" {
  metadata {
    name      = "istio-ingressgateway"
    namespace = "istio-system"
  }
}