# Install AWS Load Balancer Controller using HELM

# Resource: Helm Release 
resource "helm_release" "loadbalancer_controller" {
  depends_on = [
    aws_iam_role.lbc_iam_role,
    aws_eks_node_group.private-nodes,
    aws_eks_addon.core-dns
  ]
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"

  # Value changes based on your Region (Below is for us-east-1)
  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
    # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lbc_iam_role.arn
  }

  set {
    name  = "vpcId"
    value = "vpc-051c7287e1fe52bd4"
  }

  set {
    name  = "region"
    value = "us-east-1"
  }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.cluster.name
  }

}