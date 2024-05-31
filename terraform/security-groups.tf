module "remote_access" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "ssh"
  description = "Security group for my application"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}