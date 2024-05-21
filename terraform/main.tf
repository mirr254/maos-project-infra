module "vpc" {

  source               = "terraform-aws-modules/vpc/aws"
  version              = "2.77.0"

  name                 = "${var.environment}-vpc"
  cidr                 = "${lookup(var.cidr_ab, var.environment)}.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy    = "default"

  public_subnets       = local.public_subnets
  private_subnets      = local.private_subnets
  # database_subnets     = local.isolated_subnets

  azs                  = local.availability_zones

  create_database_nat_gateway_route = var.create_database_nat_gateway_route
  enable_nat_gateway                = var.enable_nat_gateway
  enable_vpn_gateway                = var.enable_vpn_gateway
  nat_gateway_tags                  = var.tags
  single_nat_gateway                = true
  one_nat_gateway_per_az            = false

  private_subnet_tags    = {
    "kubernetes.io/role/internal-elb" = "1"
  }
  public_subnet_tags     = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = merge (
     var.tags,
     {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    },
  ) 
  
}

# Bastion host
resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  associate_public_ip_address = true
  instance_type               = var.bastion_instance_type
  subnet_id                   = module.vpc.public_subnets[0] # will deploy bastion to first subnet group
  vpc_security_group_ids      = [module.bastion-sg.this_security_group_id]
  key_name                    = aws_key_pair.samuel_key_pair.key_name

  tags = {
    Name = "bastion-${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "samuel_key_pair" {
  key_name   = "${var.environment}-samuel-key-pair"
  public_key = tls_private_key.pk.public_key_openssh 

  provisioner "local-exec" { # Create a "tfKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./${var.environment}-samuel-key-pair.pem"
  }

}

module "eks" {

  source            = "terraform-aws-modules/eks/aws"
  cluster_name      = var.cluster_name
  cluster_version   = "1.19"

  subnets           = module.vpc.private_subnets
  vpc_id            = module.vpc.vpc_id

  tags   = var.tags


  node_groups = {
    dev = { 
      desired_capacity = var.eks_asg_desired_capacity
      max_capacity     = var.eks_asg_max_size
      min_capacity     = var.eks_asg_min_size

      instance_type = var.eks_node_instance_type
      capacity_type  = var.eks_node_capacity_type

      k8s_labels = var.tags
      # additional_tags = {
      #   ExtraTag = "example"
      # }
    }
  }
  
  # worker_additional_security_group_ids = [module.all_worker_mgmt_sg.this_security_group_id]
  map_users                            = var.map_users
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  # load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }

}

