#terraform import kubernetes_config_map.aws_auth kube-system/aws-auth
#for error related to config-map already present
provider "kubernetes" {
  host                   = aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

##Commenting as below block needed when cluster already running
# data "aws_eks_cluster" "eks" {
#   name = "demo"
# }

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.cluster.name
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
    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::211125308281:user/test"
        username = "test"
        groups   = ["read-only"]
      }
    ])
  }
}

##### Group and Roles to read and admin access ###

resource "kubernetes_cluster_role" "read_only" {
  metadata {
    name      = "read-only"
#    namespace = "default"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "deployments"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "read_only_binding" {
  metadata {
    name = "read-only-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.read_only.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "read-only"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role" "admin" {
  metadata {
    name = "admin-role"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "admin_binding" {
  metadata {
    name = "admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.admin.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }

}

resource "kubernetes_cluster_role" "dev" {
  metadata {
    name = "dev"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "deployments"]
    verbs      = ["create", "update", "patch", "delete"]
  }
}

resource "kubernetes_cluster_role_binding" "dev_binding" {
  metadata {
    name = "dev-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.dev.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "dev"
    api_group = "rbac.authorization.k8s.io"
  }
}
