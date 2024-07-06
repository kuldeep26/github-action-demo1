resource "kubernetes_config_map" "karpenter_nodepool" {
  metadata {
    name      = "karpenter-nodepool"
    namespace = "karpenter"
  }

  data = {
    "a3m-nodepool.yaml" = yamlencode({
      apiVersion: "karpenter.sh/v1alpha5",
      kind: "NodePool",
      metadata: {
        name: "a3m"
      },
      spec: {
        ttlSecondsAfterEmpty: 60,
        ttlSecondsUntilExpired: 604800,
        limits: {
          resources: {
            cpu: 20
          }
        },
        requirements: [
          {
            key: "karpenter.k8s.aws/instance-family",
            operator: "In",
            values: ["t2"]
          },
          {
            key : "karpenter.k8s.aws/instance-size",
            operator : "In",
            values : ["medium"]
          }
        ],
        provider: {
          apiVersion: "karpenter.k8s.aws/v1alpha1",
          kind: "EC2NodePool",
          name: "a3m-provider"
        },
        providerRef: {
          name: "a3m-provider"
        }
      }
    }),
    "schema-nodepool.yaml" = yamlencode({
      apiVersion: "karpenter.sh/v1alpha5",
      kind: "NodePool",
      metadata: {
        name: "schema"
      },
      spec: {
        ttlSecondsAfterEmpty: 60,
        ttlSecondsUntilExpired: 604800,
        limits: {
          resources: {
            cpu: 20
          }
        },
        requirements: [
          {
            key: "karpenter.k8s.aws/instance-family",
            operator: "In",
            values: ["t3"]
          },
          {
            key : "karpenter.k8s.aws/instance-size",
            operator : "In",
            values : ["medium"]
          }
        ],
        provider: {
          apiVersion: "karpenter.k8s.aws/v1alpha1",
          kind: "EC2NodePool",
          name: "schema-provider"
        },
        providerRef: {
          name: "schema-provider"
        }
      }
    })
  }
}

resource "kubernetes_config_map" "karpenter_ec2nodepool" {
  metadata {
    name      = "karpenter-ec2nodepool"
    namespace = "karpenter"
  }

  data = {
    "a3m-provider.yaml" = yamlencode({
      apiVersion: "karpenter.k8s.aws/v1alpha1",
      kind: "EC2NodePool",
      metadata: {
        name: "a3m-provider"
      },
      spec: {
        subnetSelector: {
          "karpenter.sh/discovery" : "${aws_eks_cluster.cluster.name}"
        },
        securityGroupSelector: {
          "karpenter.sh/discovery" : "${aws_eks_cluster.cluster.name}"
        },
        tags: {
          "karpenter.sh/discovery" : "${aws_eks_cluster.cluster.name}"
        }
      }
    }),
    "schema-provider.yaml" = yamlencode({
      apiVersion: "karpenter.k8s.aws/v1alpha1",
      kind: "EC2NodePool",
      metadata: {
        name: "schema-provider"
      },
      spec: {
        subnetSelector: {
          "karpenter.sh/discovery" : "${aws_eks_cluster.cluster.name}"
        },
        securityGroupSelector: {
          "karpenter.sh/discovery" : "${aws_eks_cluster.cluster.name}"
        },
        tags: {
          "karpenter.sh/discovery" : "${aws_eks_cluster.cluster.name}"
        }
      }
    })
  }
}
