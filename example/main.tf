module "se_eks_cluster" {
  source          = "" #Add private git repo URL here
  cluster_version = var.cluster_version
  cluster_suffix  = var.cluster_suffix
  user_list       = var.user_list
  aws_profile     = var.aws_profile
}

