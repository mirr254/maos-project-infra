resource "aws_security_group" "janus_gtw_lb_sg" {
  description = "Allow connection between ALB and target"
  vpc_id      = module.vpc.vpc_id
}


########### STUN ALB #########################
resource "aws_security_group" "stun_lb_sg" {
  description = "Allow connection between STUN ALB and target"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "stun_ingress" {
  security_group_id = aws_security_group.stun_lb_sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

module "bastion-sg" {

  source      = "terraform-aws-modules/security-group/aws"
  version     = "3.18.0"
  name        = "${var.environment}-${var.bastion_sg_name}"
  vpc_id      = module.vpc.vpc_id
  
  ingress_with_cidr_blocks = [
      {
        from_port       = 22
        to_port         = 22
        cidr_blocks     = "0.0.0.0/0"
        protocol        = "tcp"
      },
    ]

  egress_with_cidr_blocks = [
      {
        from_port       = 22
        to_port         = 22
        cidr_blocks     = "0.0.0.0/0"
        protocol        = "tcp"
      },
    ]

    tags   = var.tags
}

module "stun-sg" {

  source      = "terraform-aws-modules/security-group/aws"
  version     = "3.18.0"
  name        = "${var.environment}-stun-sg"
  vpc_id      = module.vpc.vpc_id
  
  ingress_with_cidr_blocks = [
      {
        from_port       = 80
        to_port         = 80
        cidr_blocks     = "0.0.0.0/0"
        protocol        = "tcp"
      },
      {
        from_port       = 22
        to_port         = 22
        cidr_blocks     = "0.0.0.0/0"
        protocol        = "tcp"
      },
    ]

    egress_with_cidr_blocks = [
      {
        from_port       = 0
        to_port         = 0
        cidr_blocks     = "0.0.0.0/0"
        protocol        = "-1"
      },
    ]

    tags   = var.tags
}

module "janus-gtw" {

  source      = "terraform-aws-modules/security-group/aws"
  version     = "3.18.0"
  name        = "${var.environment}-janus-gtwy-sentinel-sg"
  vpc_id      = module.vpc.vpc_id
  
  ingress_with_cidr_blocks = [
      {
        from_port       = 22
        to_port         = 22
        cidr_blocks     = "0.0.0.0/0" #TODO restrict to certain cidr_blocks
        protocol        = "tcp"
      },

      # {
      #   from_port       = 1
      #   to_port         = 1
      #   protocol        = "ICMP"
      #   cidr_blocks     = "0.0.0.0/0"
      # },
      # {
      #   from_port       = 80
      #   to_port         = 80
      #   cidr_blocks  = "0.0.0.0/0"
      #   protocol        = "http"
      # },
      {
        from_port       = 8100
        to_port         = 8100
        cidr_blocks  = "0.0.0.0/0"
        protocol        = "tcp"
      },
      {
        from_port       = 8088
        to_port         = 8088
        cidr_blocks  = "0.0.0.0/0"
        protocol        = "tcp"
      },
      {
        from_port       = 8200
        to_port         = 8200
        cidr_blocks  = "0.0.0.0/0"
        protocol        = "tcp"
      },
      {
        from_port        = 0
        to_port          = 0
        protocol         = -1
        cidr_blocks      = "0.0.0.0/0"
      },
    ]

    tags   = var.tags
}

module "postgres-security_group" {
  source = "terraform-aws-modules/security-group/aws"
  name   = "${var.environment}-${var.postges_sg_name}"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port      = 5432
      to_port        = 5432
      cidr_blocks    = module.vpc.vpc_cidr_block
      protocol       = "tcp"
      description    = "Postgres Access from within the VPC"
    },
  ]

  tags   = var.tags
}

module "all_worker_mgmt_sg" {

  source = "terraform-aws-modules/security-group/aws"
  name   = "${var.environment}-all_worker_management_sg"
  vpc_id = module.vpc.vpc_id
  
  ingress_with_cidr_blocks = [
    {
      from_port    = 22
      to_port      = 22
      cidr_blocks  = var.eks_all_worker_mgmt_sg_cidr
      protocol     = "tcp"
    },
  ]
  
}
  
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.environment}-janus ec2 security"
  description = "Security group for Janus EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}
