data "aws_iam_policy_document" "ecr-cni-policy-document" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:PutImage"
    ]
    effect = "Allow"
    resources = ["*"]
    sid       = "ECRauth"
  }

  version = "2012-10-17"
}



resource "aws_iam_policy" "ecr-secrets-store-cni-policy" {
  policy = data.aws_iam_policy_document.ecr-cni-policy-document.json
  name   = "ecr-secrets-store-cni-policy"
}


resource "aws_iam_role_policy_attachment" "ecr-secrets-store-cni-policy-attachment" {
  role       = aws_iam_role.ecr-schema-registry-role.name
  policy_arn = aws_iam_policy.ecr-secrets-store-cni-policy.arn
}

resource "aws_iam_role" "ecr-schema-registry-role" {
  assume_role_policy = data.aws_iam_policy_document.ecr-cni-policy-document.json
  name               = "ecr-registry-role"
}

resource "kubernetes_service_account" "ecr-schema_registry_sa" {
  metadata {
    name      = "ecr-registry-service-account"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"     = "${aws_iam_role.ecr-schema-registry-role.arn}"
      "meta.helm.sh/release-name"      = "ecr-secrets-store-CSI-driver"
      "meta.helm.sh/release-namespace" = local.namespace
    }
  }

  depends_on = [kubernetes_namespace.csr-namespace]
}

data "aws_iam_policy_document" "ecr-secrets-store-cni-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub"
      values   = ["system:serviceaccount:${local.namespace}:ecr-registry-service-account"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}