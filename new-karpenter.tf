resource "kubernetes_config_map" "karpenter_provisioner" {
  metadata {
    name      = "karpenter-provisioner"
    namespace = "karpenter"
  }

  data = {
    "a3m-provisioner.yaml" = yamlencode({
      apiVersion : "karpenter.sh/v1alpha5",
      kind : "Provisioner",
      metadata : {
        name : "a3m"
      },
      spec : {
        ttlSecondsAfterEmpty : 60,
        ttlSecondsUntilExpired : 604800,
        limits : {
          resources : {
            cpu : 20
          }
        },
        requirements : [
          {
            key : "karpenter.k8s.aws/instance-family",
            operator : "In",
            values : ["t2"]
          },
          {
            key : "karpenter.k8s.aws/instance-size",
            operator : "In",
            values : ["medium"]
          }
        ],
        providerRef : {
          name : "a3m-provider"
        },
        provider : {
          subnetSelector : {
            "kubernetes.io/cluster/demo" : "owned"
          },
          securityGroupSelector : {
            "kubernetes.io/cluster/demo" : "owned"
          },
          tags : {
            "kubernetes.io/cluster/demo" : "owned"
          }
        }
      }
    }),
    "schema-provisioner.yaml" = yamlencode({
      apiVersion : "karpenter.sh/v1alpha5",
      kind : "Provisioner",
      metadata : {
        name : "schema"
      },
      spec : {
        ttlSecondsAfterEmpty : 60,
        ttlSecondsUntilExpired : 604800,
        limits : {
          resources : {
            cpu : 20
          }
        },
        requirements : [
          {
            key : "karpenter.k8s.aws/instance-family",
            operator : "In",
            values : ["t3"]
          },
          {
            key : "karpenter.k8s.aws/instance-size",
            operator : "In",
            values : ["medium"]
          }
        ],
        providerRef : {
          name : "schema-provider"
        },
        provider : {
          subnetSelector : {
            "kubernetes.io/cluster/demo" : "owned"
          },
          securityGroupSelector : {
            "kubernetes.io/cluster/demo" : "owned"
          },
          tags : {
            "kubernetes.io/cluster/demo" : "owned"
          }
        }
      }
    })
  }
}
