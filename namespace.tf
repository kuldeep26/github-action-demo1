resource "kubernetes_namespace" "schema_namespace" {
  metadata {
    annotations = {
      name = "schema-annotation"
    }

    labels = {
      mylabel = "label-schema"
    }

    name = "schema-provider"
  }
}

resource "kubernetes_namespace" "a3m_namespace" {
  metadata {
    annotations = {
      name = "a3m-annotation"
    }

    labels = {
      mylabel = "label-a3m"
    }

    name = "a3m-provider"
  }
}