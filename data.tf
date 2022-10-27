data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  /*
   * Needs to be trimmed due to AWS 'roleSessionName' throwing a constraint error if OIDC token + cluster name exceeds
   * 64 characters. Trimmed length of 32=37-5(for 'cera-' prefix)
   */
  cluster_name = "cera-${lookup(var.region_short_name_table, data.aws_region.current.name)}-${format("%.32s", var.cluster_suffix)}"

  # Currently just maps an SSO role to a group with system:masters permission
  aws_auth_roles = [
    {
      "groups" : [
        "system:masters"
      ],
      "rolearn" : "arn:aws:iam::${data.aws_caller_identity.current.id}:role/${data.aws_iam_role.cluster_access.name}", # We have to strip the path since IAM role paths aren't supported.  See https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting_iam.html#security-iam-troubleshoot-ConfigMap
      "username" : "aws-sso-user"
    }
  ]
}

data "aws_iam_role" "cluster_access" {
  name = var.cluster_access_iam_role_name
}