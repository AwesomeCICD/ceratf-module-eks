variable "cluster_version" {
  description = "Cluster version" 
  default     = 1.22
}

variable "region" {
  default     = "us-west-2"
  description = "AWS region"
}
variable "cluster_suffix" {
  description = "Name for eks cluster, prefix is 'cera-'"
}

