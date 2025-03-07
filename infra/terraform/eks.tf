module "eks_ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${local.name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  cluster_name                   = local.name
  cluster_version                = "1.31"
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns    = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true" # This allows the VPC CNI to assign IP addresses from the VPC CIDR block to pods increasing the number of available IP addresses for pods hence increasing the max pods per node.
        }
      })
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.eks_ebs_csi_irsa_role.iam_role_arn
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    main-pool = {
      subnet_ids                 = module.vpc.private_subnets
      use_custom_launch_template = false
      instance_types             = ["t3.large"]
      min_size                   = 1
      max_size                   = 1
      desired_size               = 1
      disk_size                  = 30
    }
  }
}

module "eks_auth" {
  providers = {
    kubernetes = kubernetes.eks_kubernetes
  }

  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true
  # Give access to users with the admin_auth_role_arn to the EKS cluster, to manage it with kubectl or other means
  aws_auth_roles = [
    {
      rolearn  = var.admin_auth_role_arn
      username = "admin"
      groups   = ["system:masters"]
    }
  ]
}