provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

data "aws_eks_cluster" "eks" {
  name = "demo"
}

data "aws_eks_cluster_auth" "eks" {
  name = data.aws_eks_cluster.eks.name
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        groups   = ["system:bootstrappers", "system:nodes"]
        rolearn  = aws_iam_role.nodes.arn
        username = "system:node:{{EC2PrivateDNSName}}"
      }
    #   {
    #     groups   = ["system:masters"]
    #     rolearn  = "arn:aws:iam::<your_account_id>:role/<new-iam-role>"
    #     username = "<your-role-username>"
    #   }
    ])
    # mapUsers = yamlencode([
    #   {
    #     userarn  = "arn:aws:iam::211125308281:user/test"
    #     username = "test"
    #     groups   = ["system:masters"]
    #   }
    # ])
  }
}