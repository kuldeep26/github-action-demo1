provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

# This data source can only be used in the us-east-1 region.
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

# Define the CRD installation as a local-exec provisioner
# resource "null_resource" "install_karpenter_crds" {
#   provisioner "local-exec" {
#     command = <<EOT
#     kubectl apply -f https://raw.githubusercontent.com/aws/karpenter/main/pkg/apis/crds/karpenter.sh_nodepools.yaml
#     kubectl apply -f https://raw.githubusercontent.com/aws/karpenter/main/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml
#     EOT
#   }
# }

# Install Karpenter Helm chart
resource "helm_release" "karpenter" {
  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "0.37.0"
  wait                = true

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.nodes.arn
  }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.cluster.id
  }

  set {
    name  = "clusterEndpoint"
    value = aws_eks_cluster.cluster.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }

  depends_on = [aws_eks_node_group.private-nodes]
}

locals {
  karpenter_provisioner_manifest = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: default
  labels:
    app.kubernetes.io/app: Karpenter
spec:
  template:
    spec:
      nodeClassRef:
        name: default
      requirements:
        - key: "karpenter.k8s.aws/instance-family"
          operator: In
          values:  ["t2", "t3"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["2"]
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values: ["nitro"]
  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenEmpty
    consolidateAfter: 30s
YAML

  karpenter_node_class_manifest = <<YAML
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default
  labels:
    app.kubernetes.io/app: Karpenter
spec:
  amiFamily: AL2
  role: ${aws_iam_role.nodes.arn}
  subnetSelectorTerms:
    - tags:
       kubernetes.io/role/internal-elb: 1
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
  tags:
    karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
YAML
}

# resource "kubernetes_manifest" "karpenter_provisioner" {
#   manifest   = yamldecode(local.karpenter_provisioner_manifest)
#   depends_on = [helm_release.karpenter]
# }

# resource "kubernetes_manifest" "karpenter_node_class" {
#   manifest   = yamldecode(local.karpenter_node_class_manifest)
#   depends_on = [helm_release.karpenter]
# }
