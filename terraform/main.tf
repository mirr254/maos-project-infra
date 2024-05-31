terraform {
  backend "s3" {}
}
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

module "eks" {

  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~>20.0"
  cluster_version                = local.cluster_version
  cluster_name                   = "${var.cluster_name}-${var.environment}"
  cluster_endpoint_public_access = true

  subnet_ids               = module.vpc.private_subnets
  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.intra_subnets

  # IPV6
  # cluster_ip_family          = "ipv6"
  # create_cni_ipv6_iam_policy = true

  enable_cluster_creator_admin_permissions = true

  tags = var.tags

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }


  eks_managed_node_groups = {

    # Default node group - as provided by AWS EKS
    default_node_group = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      disk_size = 50

      # Remote access cannot be specified with a launch template
      remote_access = {
        ec2_ssh_key               = module.key_pair.key_pair_name
        source_security_group_ids = [module.remote_access.security_group_id]
      }
    }

    # AL2023 node group utilizing new user data format which utilizes nodeadm
    # to join nodes to the cluster (instead of /etc/eks/bootstrap.sh)
    al2023_nodeadm = {
      ami_type = "AL2023_x86_64_STANDARD"

      use_latest_ami_release_version = true

      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  shutdownGracePeriod: 30s
                  featureGates:
                    DisableKubeletCloudCredentialProviders: true
          EOT
        }
      ]
    }

    complete = {
      name            = "complete-eks-mng"
      use_name_prefix = true

      subnet_ids = module.vpc.private_subnets

      min_size     = var.eks_asg_min_size
      max_size     = var.eks_asg_max_size
      desired_size = var.eks_asg_desired_capacity

      ami_id                     = data.aws_ami.eks_default.image_id
      enable_bootstrap_user_data = true

      pre_bootstrap_user_data = <<-EOT
        export FOO=bar
      EOT

      post_bootstrap_user_data = <<-EOT
        echo "you are free little kubelet!"
      EOT

      capacity_type        = var.eks_node_capacity_type
      force_update_version = true
      instance_types       = var.eks_node_instance_types
      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      taints = [
        {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      ]

      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      description = "EKS managed node group example launch template"

      ebs_optimized           = true
      disable_api_termination = false
      enable_monitoring       = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 75
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            kms_key_id            = module.ebs_kms_key.key_arn
            delete_on_termination = true
          }
        }
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      create_iam_role          = true
      iam_role_name            = "eks-managed-node-group-complete-example"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group complete example role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        additional                         = aws_iam_policy.node_additional.arn
      }

      launch_template_tags = {
        # enable discovery of autoscaling groups by cluster-autoscaler
        "k8s.io/cluster-autoscaler/enabled" : true,
        "k8s.io/cluster-autoscaler/${local.name}" : "owned",
      }

      tags = {
        ExtraTag = "EKS managed node group complete example"
      }
    }
  }


}

resource "aws_iam_policy" "node_additional" {
  name        = "${local.name}-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = var.tags
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

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0.3"

  key_name_prefix    = local.name
  create_private_key = true

  tags = var.tags
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.0.0"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    # Required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # Required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]

  # Aliases
  aliases = ["eks/${var.cluster_name}/ebs"]

  tags = var.tags
}
