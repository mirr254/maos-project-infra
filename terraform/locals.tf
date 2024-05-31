locals {
  azs = [for az in data.aws_availability_zones.available.names : az if az != "us-east-1e"]
  name               = "mp-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = "1.29"
  vpc_cidr = "10.0.0.0/16"
}

