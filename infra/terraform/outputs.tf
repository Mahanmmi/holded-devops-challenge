output "github_oidc_role_arn" {
  value = module.github-oidc.oidc_role
}

output "flux_system_ecr_credentials_sync_role_arn" {
  value = module.flux-system-ecr-credentials-sync-role.iam_role_arn
}