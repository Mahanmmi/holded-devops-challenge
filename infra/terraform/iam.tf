module "ecr_write_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"

  name = "github-ecr-access"
  subjects = [
    "repo:mahanmmi/holded-devops-challenge",
  ]
}