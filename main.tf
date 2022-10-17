
#-------------------------------------------------------------------------------
# EKS CLUSTER & VPC 
#-------------------------------------------------------------------------------


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "${local.cluster_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                                 = "worker-group-1"
      instance_type                        = "m5.large"
      additional_userdata                  = "echo foo bar"
      additional_security_group_ids        = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity                 = 2
      metadata_http_put_response_hop_limit = 2 #enable IMDSv2
      tags = [
        {
          key                 = "owner"
          value               = "solutions@circleci.com"
          propagate_at_launch = true
        },
        {
          key                 = "team"
          value               = "Solutions Engineering"
          propagate_at_launch = true
        }
      ]
    },
    {
      name                                 = "worker-group-2"
      instance_type                        = "m5.large"
      additional_userdata                  = "echo foo bar"
      additional_security_group_ids        = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity                 = 2
      metadata_http_put_response_hop_limit = 2 #enable IMDSv2
      tags = [
        {
          key                 = "owner"
          value               = "solutions@circleci.com"
          propagate_at_launch = true
        },
        {
          key                 = "team"
          value               = "Solutions Engineering"
          propagate_at_launch = true
        }
      ]

    },
  ]
}



resource "random_string" "suffix" {
  length  = 8
  special = false
}



#-------------------------------------------------------------------------------
# SECURITY GROUPS FOR EKS CLUSTER
#-------------------------------------------------------------------------------


resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}
