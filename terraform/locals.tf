locals {
  cidr_c_private_subnets = 1
  cidr_c_intra_subnets   = 11
  cidr_c_public_subnets  = 64

  max_intra_subnets   = 2
  max_private_subnets = 2
  max_public_subnets  = 2
}

locals {
  azs = data.aws_availability_zones.available.names
  name               = "mp-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = "1.29"
  vpc_cidr = "10.0.0.0/16"
}
