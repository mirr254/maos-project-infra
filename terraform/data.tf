data "aws_availability_zones" "available" {
    state = "available"
}

data "aws_ssm_parameter" "bastion_host_allowed_ssh_key" {
  name = "/${var.environment}/bastion/ssh_key/master"
}

data "aws_ssm_parameter" "mongodb_password" {
  name = "/${var.environment}/mongodb/mongodb_password/master"
}
data "aws_ssm_parameter" "mongodb_root_password" {
  name = "/${var.environment}/mongodb/mongodb_root_password/master"
}
data "aws_ssm_parameter" "mongodb_database" {
  name = "/${var.environment}/mongodb/mongodb_database/master"
}
data "aws_ssm_parameter" "mongodb_username" {
  name = "/${var.environment}/mongodb/mongodb_username/master"
}

data "aws_ssm_parameter" "redis_password" {
  name = "/${var.environment}/redis/redis_password/master"
}

data "aws_ssm_parameter" "redis_username" {
  name = "/${var.environment}/redis/redis_username/master"
}
