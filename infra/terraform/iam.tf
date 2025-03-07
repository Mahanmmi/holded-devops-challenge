module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["Mahanmmi/holded-devops-challenge"]
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

module "flux-system-ecr-credentials-sync-role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "flux-system-ecr-credentials-sync"
  role_policy_arns = {
    "AmazonEC2ContainerRegistryReadOnly" = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
  oidc_providers = {
    ex = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["flux-system:ecr-credentials-sync"]
    }
  }
}