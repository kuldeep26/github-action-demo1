# Knative istio controller Service Account
resource "kubernetes_service_account" "knative_istio_controller_sa" {
  metadata {
    name      = "controller"
    namespace = "knative-serving"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "knative-serving"
      "app.kubernetes.io/version"   = "v1.14.1"
    }
  }

}


resource "terraform_data" "knative_operator_manifest" {
  triggers_replace = {
    knative_version = "v1.14.1"
  }

  # the maifest at  https://github.com/knative/operator/releases/download/knative-${local.knative_version}/operator.yaml
  # contains multipe YAML manifests, which are sepreated by '---' terraform yamldecode can't process it so this is a workaround'
  provisioner "local-exec" {
    command = <<EOF
            kubectl apply -f https://github.com/knative/operator/releases/download/knative-v1.14.1/operator.yaml
        EOF
  }

  depends_on = [
    kubernetes_service_account.knative_istio_controller_sa
  ]
}

resource "kubernetes_namespace" "knative-serving" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }

    name = "knative-serving"
  }
}

resource "terraform_data" "knative_serving" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/manifest-files/knative_serving.yaml"
  }

  depends_on = [
    kubernetes_namespace.knative-serving,
  terraform_data.knative_operator_manifest]
}
