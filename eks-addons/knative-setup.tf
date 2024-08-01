// For Production usescase it is recommended to use cosign to verify the images
resource "terraform_data" "verify_knative_source_images" {
  provisioner "local-exec" {
    command = <<EOF
       curl -sSL https://github.com/knative/serving/releases/download/knative-v1.14.1/serving-core.yaml \
         | grep 'gcr.io/' | awk '{print $2}' | sort | uniq \
         | xargs -n 1 \
           cosign verify -o text \
             --certificate-identity=signer@knative-releases.iam.gserviceaccount.com \
             --certificate-oidc-issuer=https://accounts.google.com
       EOF
  }

  depends_on = [
    helm_release.karpenter,
    terraform_data.execute_karpenter_nodepool_manifest,
  terraform_data.execute_karpenter_node_class_manifest]
}

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
    knative_version = var.knative_version
  }

  # the maifest at  https://github.com/knative/operator/releases/download/knative-${local.knative_version}/operator.yaml
  # contains multipe YAML manifests, which are sepreated by '---' terraform yamldecode can't process it so this is a workaround'
  provisioner "local-exec" {
    command = <<EOF
            kubectl apply -f https://github.com/knative/operator/releases/download/knative-v1.14.1/operator.yaml
        EOF
  }

  depends_on = [
    terraform_data.verify_knative_source_images,
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
