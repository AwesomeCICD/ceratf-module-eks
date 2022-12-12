output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = module.eks.cluster_arn
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = local.cluster_name
}

output "cluster_auth_token" {
  description = "EKS cluster authentication token."
  value       = data.aws_eks_cluster_auth.cluster.token
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA certificate (plain text PEM format)."
  value       = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

output "aws_region" {
  description = "AWS region in which the cluster is deployed."
  value       = data.aws_region.current.name
}

output "kubeconfig_update_command" {
  description = "Prints commands for updating your local kubeconfig file."
  value       = <<EOF
  To update your kubeconfig file, sign in to AWS SSO via CLI and then run the following commands:

      aws eks update-kubeconfig --name ${local.cluster_name} --region ${data.aws_region.current.name} --profile pipeline
      kubectl config rename-context ${module.eks.cluster_arn} ${local.cluster_name}
      kubectl config set-context ${local.cluster_name}
  
  To verify access to the cluster, try to list the namespaces:
      
      kubectl get ns

EOF
}



#output "cluster_primary_security_group_id" {
#  description = "ID of cluster security group that was created by Amazon EKS for the cluster."
#  value       = module.eks.cluster_primary_security_group_id
#}

output "cluster_security_group_id" {
  description = "ID of the cluster security group."
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "ID of the node security group."
  value       = module.eks.node_security_group_id
}