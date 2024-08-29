locals {
  namespace = "hello-world"
}

data "aws_iam_policy_document" "secrets-store-cni-policy-document" {
  statement {

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    effect = "Allow"
    // TODO: Fine tune the configuration
    resources = ["*"]
    sid       = "secretsStoreCNI"
  }

  version = "2012-10-17"
}

// attach KMS key policy to access the encription key for the secrets
data "aws_iam_policy_document" "kms-key-policy-document" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]
    effect = "Allow"
    # fine tune the configuration
    resources = ["*"]
    sid       = "kmsKeyPolicy"
  }

  version = "2012-10-17"
}


resource "aws_iam_policy" "secrets-store-cni-policy" {
  policy = data.aws_iam_policy_document.secrets-store-cni-policy-document.json
  name   = "secrets-store-cni-policy"
}

resource "aws_iam_policy" "kms-key-policy" {
  policy = data.aws_iam_policy_document.kms-key-policy-document.json
  name   = "kms-key-policy"
}

resource "aws_iam_role_policy_attachment" "secrets-store-cni-policy-attachment" {
  role       = aws_iam_role.schema-registry-role.name
  policy_arn = aws_iam_policy.secrets-store-cni-policy.arn
}

resource "aws_iam_role_policy_attachment" "kms-key-policy-attachment" {
  role       = aws_iam_role.schema-registry-role.name
  policy_arn = aws_iam_policy.kms-key-policy.arn
}

resource "aws_iam_role" "schema-registry-role" {
  assume_role_policy = data.aws_iam_policy_document.secrets-store-cni-policy.json
  name               = "schema-registry-role"
}

resource "kubernetes_namespace" "csr-namespace" {
  metadata {
    annotations = {
      "app.kubernetes.io/managed-by" = "kubernetes-provider"
    }

    name = local.namespace
  }
}

resource "kubernetes_service_account" "schema_registry_sa" {
  metadata {
    name      = "schema-registry-service-account"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"     = "${aws_iam_role.schema-registry-role.arn}"
      "meta.helm.sh/release-name"      = "secrets-store-CSI-driver"
      "meta.helm.sh/release-namespace" = "kube-system"
    }
  }

  depends_on = [kubernetes_namespace.csr-namespace]
}

data "aws_iam_policy_document" "secrets-store-cni-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub"
      values   = ["system:serviceaccount:${local.namespace}:schema-registry-service-account"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}