variable "cluster_version" {
  description = "Cluster version"
  default     = 1.22
}

variable "cluster_suffix" {
  description = "Name for eks cluster, prefix is 'cera-'"
}

variable "user_list" {
  description = "List of users who will be using the cluster."
  default     = []
}

variable "aws_profile" {
  description = "AWS profile used for generating kubeconfig."
  default     = "default"
}

variable "node_instance_type" {
  description = "Instance type that will be used in nodegroups."
  default     = "m5.large"
}

variable "nodegroup_desired_capacity" {
  description = "Desired capacity of each nodegroup."
  default     = 2
}

variable "cluster_access_iam_role_name" {
  description = "IAM role that will be granted EKS cluster admin access."
  default     = ""
}


variable "circleci_org_id" {
  description = "IDs of CircleCI organizations to be granted access to EKS cluster."
  default     = ""
}

variable "circleci_org_friendly_name" {
  description = "Human readable name representing the CircleCI org, e.g. awesomecicd"
  default     = ""
}


variable "region_short_name_table" {
  description = "Region short name mappings. Current as of 2022-10-17."
  default = {
    af-south-1 : "afs1",
    ap-east-1 : "ape1",
    ap-northeast-1 : "apne1",
    ap-northeast-2 : "apne2",
    ap-northeast-3 : "apne3",
    ap-south-1 : "aps1",
    ap-southeast-1 : "apse1",
    ap-southeast-2 : "apse2",
    ap-southeast-3 : "apse3",
    ca-central-1 : "cac1",
    eu-central-1 : "euc1",
    eu-north-1 : "eun1",
    eu-south-1 : "eus1",
    eu-west-1 : "euw1",
    eu-west-2 : "euw2",
    eu-west-3 : "euw3",
    me-central-1 : "mec1",
    me-south-1 : "mes1",
    sa-east-1 : "sae1",
    us-east-1 : "use1",
    us-east-2 : "use2",
    us-west-1 : "usw1",
    us-west-2 : "usw2"
  }
}
