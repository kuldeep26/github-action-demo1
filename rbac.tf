resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        groups   = ["system:bootstrappers", "system:nodes"]
        rolearn  = "arn:aws:iam::211125308281:role/eks-node-group-eks"
        username = "system:node:{{EC2PrivateDNSName}}"
      }
    #   {
    #     groups   = ["system:masters"]
    #     rolearn  = "arn:aws:iam::<your_account_id>:role/<new-iam-role>"
    #     username = "<your-role-username>"
    #   }
    ])
    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::211125308281:user/test"
        username = "test"
        groups   = ["system:masters"]
      }
    ])
  }
}