
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
  source                    = "terraform-aws-modules/eks/aws"
  version                   = "18.30.2"
  cluster_name              = local.cluster_name
  cluster_version           = var.cluster_version
  subnet_ids                = module.vpc.private_subnets
  vpc_id                    = module.vpc.vpc_id
  aws_auth_roles            = var.cluster_access_iam_role_name != "" ? local.aws_auth_roles : []
  manage_aws_auth_configmap = true

  eks_managed_node_group_defaults = {
    root_volume_type                     = "gp2"
    instance_type                        = var.node_instance_type
    additional_userdata                  = "echo foo bar"
    asg_desired_capacity                 = var.nodegroup_desired_capacity
    metadata_http_put_response_hop_limit = 2 #enable IMDSv2
    tags = {
      owner = "solutions@circleci.com"
      team  = "Solutions Engineering"
    }

  }

  eks_managed_node_groups = [
    {
      name                            = "${local.cluster_name}-ng-1"
      launch_template_name            = "${local.cluster_name}-ng-1"
      additional_security_group_ids   = [aws_security_group.worker_group_mgmt_one.id]
      launch_template_use_name_prefix = false #workaround for bug in 18.30.2
      iam_role_use_name_prefix        = false #workaround for bug in 18.30.2
    },
    {
      name                          = "${local.cluster_name}-ng-2"
      launch_template_name          = "${local.cluster_name}-ng-2"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      iam_role_use_name_prefix      = false #workaround for bug in 18.30.2
    }
  ]
}

resource "null_resource" "kubeconfig" {

  triggers = {
    cluster_id = module.eks.cluster_id
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_id} --kubeconfig '${path.cwd}/${module.eks.cluster_id}_kubeconfig' --profile ${var.aws_profile} --region ${data.aws_region.current.name}"
  }
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
