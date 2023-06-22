data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

locals {
  /*
   * Needs to be trimmed due to AWS 'roleSessionName' throwing a constraint error if OIDC token + cluster name exceeds
   * 64 characters. Trimmed length of 32=37-5(for 'cera-' prefix)
   */
  derived_cluster_name = "cera-${lookup(var.region_short_name_table, data.aws_region.current.name)}-${format("%.32s", var.cluster_suffix)}"

  # Maps the SSO role plus any additional specified roles to the system:masters group
  aws_auth_roles = concat(
    [
      for name in concat(var.additional_iam_role_names, [var.eks_access_iam_role_name]) : {

        "groups" : [
          "system:masters"
        ],
        "rolearn" : "arn:aws:iam::${data.aws_caller_identity.current.id}:role/${name}", # We have to strip the path since IAM role paths aren't supported.  See https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting_iam.html#security-iam-troubleshoot-ConfigMap
        "username" : "aws-sso-user"
      }
    ]
  )
}

