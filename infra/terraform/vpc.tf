# This creates a vpc with 3 private and 1 public subnet
module "vpc" {
  source                        = "terraform-aws-modules/vpc/aws"
  name                          = local.name
  manage_default_security_group = true
  cidr                          = local.vpc_cidr
  enable_ipv6                   = true

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnet_ipv6_prefixes = [3, 4, 5]
  private_subnets              = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(local.vpc_cidr, 4, k)]
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb": "1"
    "kubernetes.io/cluster/${local.name}": "shared"
  }

  # Make sure IPv6 ips are assigned when a resource in public subnet is created
  public_subnet_ipv6_prefixes                   = [0, 1, 2]
  public_subnet_assign_ipv6_address_on_creation = true
  public_subnets                                = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(local.vpc_cidr, 4, length(local.azs) + k)]
  public_subnet_tags = {
    "kubernetes.io/role/elb": "1"
    "kubernetes.io/cluster/${local.name}": "shared"
  }

  create_igw         = true
  enable_nat_gateway = true
  single_nat_gateway = true

  # Allow access from/to the internet, this is not a secure configuration and should be replaced in a real-world scenario
  default_security_group_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port        = 0
      to_port          = 0
      protocol         = -1
      ipv6_cidr_blocks = "::/0"
    }
  ]
  default_security_group_ingress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port        = 0
      to_port          = 0
      protocol         = -1
      ipv6_cidr_blocks = "::/0"
    }
  ]
}

# Vpc should be able to communicate with ec2 services so we add endpoints
module "vpc_endpoints_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-vpc-endpoints"
  description = "Security group for VPC endpoint access"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      description = "VPC CIDR HTTPS"
      cidr_blocks = join(",", module.vpc.private_subnets_cidr_blocks)
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      description = "All egress HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "core_vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 4.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc_endpoints_sg.security_group_id]

  endpoints = merge(
    { for service in toset(["ecr.api", "ecr.dkr", "ec2", "ec2messages", "elasticloadbalancing"]) :
      replace(service, ".", "_") =>
      {
        service             = service
        subnet_ids          = module.vpc.private_subnets
        private_dns_enabled = true
      }
    })
}
