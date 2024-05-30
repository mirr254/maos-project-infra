output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "eks_cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "eks_cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
