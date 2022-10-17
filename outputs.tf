output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
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

output "k8s_namespaces" {
  description = "List of namespaces created in the new cluster."
  value = concat(
    kubernetes_namespace.user_main[*]
    #kubernetes_namespace.user_main.*.metadata[*][0].name,
    #kubernetes_namespace.user_alt.*.metadata[*][0].name
  )
}
