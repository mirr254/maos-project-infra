eks_node_instance_types  = ["t3.small"]
eks_node_capacity_type  = "SPOT"
region                  = "us-east-1"
eks_asg_desired_capacity = 1
eks_asg_min_size        = 1
eks_asg_max_size        = 5
tags                    = {
                            environment = "staging"
                            Managed_by   = "Terraform"
                        }
eks_all_worker_mgmt_sg_cidr = "41.80.0.0/16"
environment                 = "staging"
cluster_name                = "maosproject"
