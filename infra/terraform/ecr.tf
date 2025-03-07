module "app_ecr" {
  source = "terraform-aws-modules/ecr/aws"
  repository_name = "app"
  // give access to the EKS managed node groups and github to push/pull images
  repository_read_write_access_arns = concat([for ng in module.eks.eks_managed_node_groups : ng.iam_role_arn], [module.ecr_write_role.arn])
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus   = "tagged",
          tagPatternList = ["*"],
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}