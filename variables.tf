variable "cluster_version" {
  description = "Cluster version"
  default     = 1.22
}

variable "cluster_suffix" {
  description = "Name for eks cluster, prefix is 'cera-'"
}

variable "node_instance_type" {
  description = "Instance type that will be used in nodegroups."
  default     = "m5.large"
}

variable "nodegroup_desired_capacity" {
  description = "Desired capacity of each nodegroup."
  default     = 2
}

variable "eks_access_iam_role_name" {
  description = "IAM role to be used globally by SEs for cluster access. Will added to the system:masters group in the EKS cluster."
  default     = []
}


variable "additional_iam_role_names" {
  description = "Additional IAM roles to be added to the system:masters group in the EKS cluster."
  default     = []
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

variable "generate_kubeconfig" {
  description = "Set to true to generate a kubeconfig locally for debug/testing."
  default     = false
}

variable "aws_profile" {
  description = "Only required if generating a kubeconfig."
  default     = "default"
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  default     = false #TF default, not AWS default
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  default     = true #TF default, not AWS default
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = []
}
/*
  default = [
    {
      name    = "kube-proxy"
      version = "v1.27.1-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.10.1-eksbuild.1"
    },
    {
      name    = "vpc-cni"
      version = "v1.13.1-eksbuild.1"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.19.0-eksbuild.2"
    }
  ]
}
*/