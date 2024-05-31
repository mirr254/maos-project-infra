variable "create_database_nat_gateway_route" {
  type        = bool
  default     = false
  description = "Controls if a nat gateway route should be created to give internet access to the database subnets"
}

variable "eks_node_instance_types" {
  type        = list(string)
  description = "The instance types to use for the EKS nodes"

}

variable "eks_node_capacity_type" {
  type        = string
  description = "The capacity type to use for the EKS nodes"

}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
}

variable "enable_vpn_gateway" {
  type        = bool
  default     = false
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
}

variable "region" {
  type        = string
  description = "Region to deploy AWS resources"
}

variable "tags" {
  type = map(string)

}

variable "environment" {
  type        = string
  description = "Options: development, staging, production"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "maosproject"

}
variable "bastion_ami" {
  type        = string
  description = "AMI used to launch bastion host"
  default     = "ami-038f1ca1bd58a5790"
}

variable "bastion_instance_type" {
  type        = string
  description = "bastion Node/machine type "
  default     = "t2.micro"
}
variable "bastion_sg_name" {
  type        = string
  description = "Bastion host security group name"
  default     = "bastion-22-ssh"
}

variable "postges_sg_name" {
  type        = string
  description = "Postgres RDS instance security group name"
  default     = "postgresql-security-group"
}

variable "eks_all_worker_mgmt_sg_cidr" {
  type        = string
  description = "Allowed cidr blocks to ssh into all eks worker nodes"
  #samuel's cidr. TODO: whitelist here with comma separated

}
#postgres RDS
variable "instance_class" {
  type        = string
  default     = "db.t3.large"
  description = "Postgres instance type or class"
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Postgres Storage size"
}

variable "max_allocated_storage" {
  type        = number
  default     = 100
  description = "Auto scaler. Max storage limit to scale to"
}
variable "maintenance_window" {
  type        = string
  description = "Time range/window to perform db maintenance"
  default     = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  type        = string
  description = "Daily time range in UTC during which daily backups are created"
  default     = "03:00-06:00"
}

variable "backup_retention_period" {
  type        = number
  description = "Time to retain backups in days"
  default     = 1

}

variable "postgres_rds_identifier" {
  type        = string
  description = "Name of the RDS instance to be created"
  default     = "postgres-rds"
}
variable "postgres_engine_version" {
  type        = string
  description = "postgres version"
  default     = "11.10"
}
variable "postgres_family" {
  type        = string
  description = "postgres family: DB parameter group"
  default     = "postgres11"
}
variable "postgres_major_engine_version" {
  type        = string
  description = "postgres family: DB option group"
  default     = "11"
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "list of log types to enable for exporting to cloudwatch"
  default     = ["postgresql", "upgrade"]
}

variable "performance_insights_retention_period" {
  type        = number
  description = "Time to retain performance insights in days"
  default     = 7

}

variable "performance_insights_enabled" {
  type        = bool
  description = "Enable DB performance insights"
  default     = true

}
variable "create_monitoring_role" {
  type        = bool
  description = "Enable DB performance insights"
  default     = false

}

# EKS

variable "eks_worker_instance_type" {
  type        = string
  description = "Instance types of the worker nodes"
  default     = "t3.medium"
}

variable "eks_asg_max_size" {
  type        = number
  description = "Auto scaling enabled: Max number of instance to scale to"
}

variable "eks_asg_min_size" {
  type        = number
  description = "Auto scaling enabled: Min number of instances to run"
}

variable "eks_asg_desired_capacity" {
  type        = number
  description = "Auto scaling enabled: Min number of running instances"
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::707173198656:user/alfredglover"
      username = "alfredglover"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::707173198656:user/circleci"
      username = "circleci"
      groups   = ["system:masters"]
    },
  ]
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster to create"
}

variable "pub_ssh_key" {
  type        = string
  description = "Will be used to ssh into the bastion host"

}

variable "grafana_password" {
  type        = string
  description = "Grafana Password"
}