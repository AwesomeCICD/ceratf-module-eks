module "se_eks_cluster" {
  source = "../" #Add private git repo URL here

  # Required
  cluster_suffix = "arrakis"
  user_list      = ["alia", "bijaz", "cheni", "duncan"]
  aws_profile    = "arakeen-dev"

  # Optional
  cluster_version            = "1.22"
  node_instance_type         = "m5.large"
  nodegroup_desired_capacity = "2"
}

