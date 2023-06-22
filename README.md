# ceratf-module-eks
Terraform module for deploying regional SE EKS clusters.  Does the following:
- Deploys a VPC
- Deploys an EKS cluster in the VPC
- Update the aws-auth config map to grant `system:masters` access to the SE EKS role stored in the ceratf-deployment-global plan state as well as any additional IAM roles

## Requirements

- Terraform >= 1.0.9
- aws-cli >= 2.8.3
- Access to state file from ceratf-deployment-global plan

## How to Use

1. Drop the [example module declaration](#example-usage) shown below into a Terraform plan and fill in the variables.
2. Run the Terraform plan.


## Terraform Variables

#### Required

| Name | Default | Description|
|------|---------|------------|
|cluster_suffix| none | EKS name suffix.  Appeneded to "cera-"|


#### Optional

| Name | Default | Description|
|------|---------|------------|
|cluster_version | `1.22` | Desired EKS cluster version.|
|node_instance_type|`m5.large`|EC2 instance type to be used by nodegroups.|
|nodegroup_desired_capacity|`2`|Desired number of instances per nodegroup.|
|eks_access_iam_role_name|`""`|IAM role to be used globally by SEs for cluster access. Will added to the system:masters group in the EKS cluster.|
|additional_iam_role_names|`[]`|Additional IAM roles to be added to the system:masters group in the EKS cluster.|
|generate_kubeconfig| `false` | Whether or not to generate a local kubeconfig file for troubleshooting. |
|aws_profile| `default` | AWS profile used for generating kubeconfig. |

## Terraform Outputs

| Name | Description|
|------|-----------|
| cluster_name | EKS cluster name. |
| cluster_endpoint | Endpoint for EKS control plane. |
| cluster_arn | EKS cluster ARN. |
| cluster_name | EKS cluster name. |
| cluster_auth_token | EKS cluster authentication token. |
| cluster_ca_certificate | EKS cluster CA certificate (plain text PEM format). |
| cluster_security_group_id | Security group ids attached to the cluster control plane. |
| aws_region | AWS region in which the cluster is deployed. |
| kubeconfig_update_command | Prints commands for updating your local kubeconfig file. |


## Example usage

```hcl
module "se_eks_cluster" {
  source = "git@github.com:AwesomeCICD/ceratf-module-eks.git"

  cluster_suffix             = "foobar"
  cluster_version            = "1.22"
  node_instance_type         = "m5.large"
  nodegroup_desired_capacity = "2"
}
```

There is also an optional output that will print a command to update a user's kubeconfig file:

```hcl
output "kubeconfig_update_command" {
  value = module.se_eks_cluster.kubeconfig_update_command
}
```


## Resources Created by Terraform

- data.aws_availability_zones.available
- data.aws_caller_identity.current
- data.aws_eks_cluster.cluster
- data.aws_eks_cluster_auth.cluster
- data.aws_region.current
- aws_security_group.all_worker_mgmt
- aws_security_group.worker_group_mgmt_one
- aws_security_group.worker_group_mgmt_two
- null_resource.kubeconfig[0]
- random_string.suffix
- module.eks.data.aws_caller_identity.current
- module.eks.data.aws_default_tags.current
- module.eks.data.aws_iam_policy_document.assume_role_policy[0]
- module.eks.data.aws_partition.current
- module.eks.data.tls_certificate.this[0]
- module.eks.aws_cloudwatch_log_group.this[0]
- module.eks.aws_eks_cluster.this[0]
- module.eks.aws_iam_openid_connect_provider.oidc_provider[0]
- module.eks.aws_iam_role.this[0]
- module.eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
- module.eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]
- module.eks.aws_security_group.cluster[0]
- module.eks.aws_security_group.node[0]
- module.eks.aws_security_group_rule.cluster["egress_nodes_443"]
- module.eks.aws_security_group_rule.cluster["egress_nodes_kubelet"]
- module.eks.aws_security_group_rule.cluster["ingress_nodes_443"]
- module.eks.aws_security_group_rule.node["egress_cluster_443"]
- module.eks.aws_security_group_rule.node["egress_https"]
- module.eks.aws_security_group_rule.node["egress_ntp_tcp"]
- module.eks.aws_security_group_rule.node["egress_ntp_udp"]
- module.eks.aws_security_group_rule.node["egress_self_coredns_tcp"]
- module.eks.aws_security_group_rule.node["egress_self_coredns_udp"]
- module.eks.aws_security_group_rule.node["ingress_cluster_443"]
- module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"]
- module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]
- module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"]
- module.eks.kubernetes_config_map_v1_data.aws_auth[0]
- module.vpc.aws_eip.nat[0]
- module.vpc.aws_internet_gateway.this[0]
- module.vpc.aws_nat_gateway.this[0]
- module.vpc.aws_route.private_nat_gateway[0]
- module.vpc.aws_route.public_internet_gateway[0]
- module.vpc.aws_route_table.private[0]
- module.vpc.aws_route_table.public[0]
- module.vpc.aws_route_table_association.private[0]
- module.vpc.aws_route_table_association.private[1]
- module.vpc.aws_route_table_association.private[2]
- module.vpc.aws_route_table_association.public[0]
- module.vpc.aws_route_table_association.public[1]
- module.vpc.aws_route_table_association.public[2]
- module.vpc.aws_subnet.private[0]
- module.vpc.aws_subnet.private[1]
- module.vpc.aws_subnet.private[2]
- module.vpc.aws_subnet.public[0]
- module.vpc.aws_subnet.public[1]
- module.vpc.aws_subnet.public[2]
- module.vpc.aws_vpc.this[0]
- module.eks.module.eks_managed_node_group["0"].data.aws_caller_identity.current
- module.eks.module.eks_managed_node_group["0"].data.aws_iam_policy_document.assume_role_policy[0]
- module.eks.module.eks_managed_node_group["0"].data.aws_partition.current
- module.eks.module.eks_managed_node_group["0"].aws_eks_node_group.this[0]
- module.eks.module.eks_managed_node_group["0"].aws_iam_role.this[0]
- module.eks.module.eks_managed_node_group["0"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
- module.eks.module.eks_managed_node_group["0"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
- module.eks.module.eks_managed_node_group["0"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
- module.eks.module.eks_managed_node_group["0"].aws_launch_template.this[0]
- module.eks.module.eks_managed_node_group["0"].aws_security_group.this[0]
- module.eks.module.eks_managed_node_group["1"].data.aws_caller_identity.current
- module.eks.module.eks_managed_node_group["1"].data.aws_iam_policy_document.assume_role_policy[0]
- module.eks.module.eks_managed_node_group["1"].data.aws_partition.current
- module.eks.module.eks_managed_node_group["1"].aws_eks_node_group.this[0]
- module.eks.module.eks_managed_node_group["1"].aws_iam_role.this[0]
- module.eks.module.eks_managed_node_group["1"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
- module.eks.module.eks_managed_node_group["1"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
- module.eks.module.eks_managed_node_group["1"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
- module.eks.module.eks_managed_node_group["1"].aws_launch_template.this[0]
- module.eks.module.eks_managed_node_group["1"].aws_security_group.this[0]
- module.eks.module.kms.data.aws_caller_identity.current
- module.eks.module.kms.data.aws_partition.current