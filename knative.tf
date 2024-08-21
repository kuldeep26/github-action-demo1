# resource "terraform_data" "verify_knative_source_images" {
#   provisioner "local-exec" {
#     command = <<EOF
#        curl -sSL https://github.com/knative/serving/releases/download/knative-${var.knative_cosign_image_check}/serving-core.yaml \
#          | grep 'gcr.io/' | awk '{print $2}' | sort | uniq \
#          | xargs -n 1 \
#            cosign verify -o text \
#              --certificate-identity=signer@knative-releases.iam.gserviceaccount.com \
#              --certificate-oidc-issuer=https://accounts.google.com
#        EOF
#   }

#   depends_on = [
#     helm_release.karpenter
#     ]
# }

# Knative istio controller Service Account
resource "kubernetes_service_account" "knative_istio_controller_sa" {
  depends_on = [
    kubernetes_namespace.knative-serving
  ]
  metadata {
    name      = "controller"
    namespace = "knative-serving"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "knative-serving"
      "app.kubernetes.io/version"   = var.knative_version
    }
  }

}


resource "terraform_data" "knative_operator_manifest" {
  triggers_replace = {
    knative_version = var.knative_version
  }

  # the maifest at  https://github.com/knative/operator/releases/download/knative-${local.knative_version}/operator.yaml
  # contains multipe YAML manifests, which are sepreated by '---' terraform yamldecode can't process it so this is a workaround'
  provisioner "local-exec" {
    command = <<EOF
            kubectl apply -f https://github.com/knative/operator/releases/download/knative-${var.knative_version}/operator.yaml
        EOF
  }

  depends_on = [
    #    terraform_data.verify_knative_source_images,
    kubernetes_service_account.knative_istio_controller_sa
  ]
}

resource "kubernetes_namespace" "knative-serving" {
  depends_on = [
    terraform_data.knative_serving,
    terraform_data.knative-istio-integration,
  ]
  metadata {
    name = "knative-serving"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "terraform_data" "knative_serving" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/manifest-files/knative_serving.yaml"
  }

  depends_on = [
  terraform_data.knative_operator_manifest]
}