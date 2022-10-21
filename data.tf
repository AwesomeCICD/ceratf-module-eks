data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}


locals {
  /*
   * Needs to be trimmed due to AWS 'roleSessionName' throwing a constraint error if OIDC token + cluster name exceeds
   * 64 characters. Trimmed length of 32=37-5(for 'cera-' prefix)
   */
  cluster_name = "cera-${lookup(var.region_short_name_table, data.aws_region.current.name)}-${format("%.32s", var.cluster_suffix)}"
}