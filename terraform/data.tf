data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_name
# }

# data "aws_ami" "eks_default" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amazon-eks-node-${local.cluster_version}-v*"]
#   }
# }