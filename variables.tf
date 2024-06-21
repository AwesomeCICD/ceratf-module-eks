variable "cluster_version" {
  type        = string
  description = "Cluster version"
  default     = "1.30"
}

variable "cluster_suffix" {
  type        = string
  description = "Name for eks cluster, prefix is 'cera-'"
}

# Refer to the AWS EC2 On-Demand Pricing page for more details:
# https://aws.amazon.com/ec2/pricing/on-demand/
# We have selected m5a and t3a instance types because they are 10% cheaper 
# than their standard counterparts and are better suited for our use case.
variable "node_instance_types" {
  type        = list(string)
  description = "Instance types to be used in node groups."
  default     = ["m5a.xlarge", "t3a.medium"]
}

variable "nodegroup_desired_capacity" {
  description = "Desired capacity of each nodegroup."
  default     = 2
  type        = number
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
  type        = boolean
}

variable "aws_profile" {
  description = "Only required if generating a kubeconfig."
  default     = "default"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  default     = false #TF default, not AWS default
  type        = boolean
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  default     = true #TF default, not AWS default
  type        = boolean
}


# Tags are set based on the definitions defined in the Confluence link below
# https://circleci.atlassian.net/wiki/spaces/CE1/pages/6968705224/Infrastructure+Tags+and+Labels
variable "default_fieldeng_tags" {
  type = map(string)
  default = {
    "cost_center"    = "mixed"
    "owner"          = "field@circleci.com"
    "team"           = "Field Engineering"
    "iac"            = "true"
    "opt_in"         = "true"
    "critical_until" = "critical-until-2024-07-31"
    "purpose"        = "CERA is a customer facing demo architecture used by Solutions Engineering team."
  }
}