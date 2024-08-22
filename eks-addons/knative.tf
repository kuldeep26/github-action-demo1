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
}

resource "null_resource" "knative-istio-label" {

  provisioner "local-exec" {
    command = "kubectl label namespace knative-serving istio-injection=enabled"
  }

  depends_on = [
    terraform_data.knative_serving,
  ]
}

resource "terraform_data" "knative_serving" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/manifest-files/knative_serving.yaml"
  }

  depends_on = [
  terraform_data.knative_operator_manifest]
}