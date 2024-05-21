locals {
    cidr_c_private_subnets  = 1
    cidr_c_isolated_subnets = 11
    cidr_c_public_subnets   = 64

    max_isolated_subnets    = 2
    max_private_subnets     = 2
    max_public_subnets      = 2
}

locals {
  availability_zones = data.aws_availability_zones.available.names
}

locals {
    private_subnets = [
        for az in local.availability_zones : 
            "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_private_subnets + index(local.availability_zones, az)}.0/24"
            if index(local.availability_zones, az) < local.max_private_subnets
        ]
    isolated_subnets = [
        for az in local.availability_zones : 
            "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_isolated_subnets + index(local.availability_zones, az)}.0/24"
            if index(local.availability_zones, az) < local.max_isolated_subnets
        ]
    public_subnets = [
        for az in local.availability_zones : 
            "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_public_subnets + index(local.availability_zones, az)}.0/24"
            if index(local.availability_zones, az) < local.max_public_subnets
        ]
}

