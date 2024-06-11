module "vpc" {

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name                 = "${var.environment}-vpc"
  cidr                 = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  azs             = local.azs
  private_subnets = [for k in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, 8, k + length(local.azs))]
  intra_subnets   = [for k in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, 8, k + 2 * length(local.azs))]



  enable_nat_gateway = var.enable_nat_gateway
  nat_gateway_tags   = var.tags
  single_nat_gateway = true

  enable_ipv6 = false
  # public_subnet_assign_ipv6_address_on_creation  = true
  # private_subnet_assign_ipv6_address_on_creation = true
  # intra_subnet_assign_ipv6_address_on_creation   = true
  # public_subnet_ipv6_prefixes                    = range(0, length(local.azs))
  # private_subnet_ipv6_prefixes                   = range(length(local.azs) * 1, length(local.azs) * 2)
  # intra_subnet_ipv6_prefixes                     = range(length(local.azs) * 2, length(local.azs) * 3)

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    },
  )

}