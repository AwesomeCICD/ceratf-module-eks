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

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

/*
output "k8s_namespaces" {
  description = "List of namespaces created in the new cluster."
  value = concat(
    [for ns in kubernetes_namespace.user_main : ns.metadata[0].name],
    [for ns in kubernetes_namespace.user_alt : ns.metadata[0].name]
  )
}
*/

output "kubeconfig_update_command" {
  value = <<EOF
  To update your kubeconfig file, sign in to AWS SSO via CLI and then run the following commands:

      aws eks update-kubeconfig --name ${local.cluster_name} --region ${data.aws_region.current.name} --profile pipeline
      kubectl config rename-context ${module.eks.cluster_arn} ${local.cluster_name}
      kubectl config set-context ${local.cluster_name}
  
  To verify access to the cluster, try to list the namespaces:
      
      kubectl get ns

EOF
}

output "k8s_provider_host" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "k8s_provider_token" {
  value = data.aws_eks_cluster_auth.cluster.token
}

output "k8s_provider_cluster_ca_certificate" {
  value = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}