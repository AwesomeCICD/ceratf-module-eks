
#-------------------------------------------------------------------------------
# EKS CLUSTER & VPC 
#-------------------------------------------------------------------------------


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                 = "${local.derived_cluster_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  manage_default_network_acl = false #added to avoid bug in v5.0.0

  tags = merge(var.default_fieldeng_tags, {
    "kubernetes.io/cluster/${local.derived_cluster_name}" = "shared"
  })

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.derived_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.derived_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                     = "1"
  }
}


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.15.3"
  cluster_name    = local.derived_cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = module.vpc.private_subnets
  # The OIDC provider for EKS cluster access via SSO is created in the global infra TF plan
  # enable_irsa creates a separate OIDC provider used solely for IRSA (IAM Roles for K8s Service Accounts)
  enable_irsa                     = true
  vpc_id                          = module.vpc.vpc_id
  aws_auth_roles                  = local.aws_auth_roles
  create_aws_auth_configmap       = false
  manage_aws_auth_configmap       = true
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  eks_managed_node_group_defaults = {
    root_volume_type                     = "gp2"
    instance_types                       = var.node_instance_types
    additional_userdata                  = "echo foo bar"
    desired_size                         = var.nodegroup_desired_capacity
    metadata_http_put_response_hop_limit = 2 #enable IMDSv2
    tags                                 = var.default_fieldeng_tags

  }

  eks_managed_node_groups = [
    {
      name                            = "${local.derived_cluster_name}-ng-1"
      launch_template_name            = "${local.derived_cluster_name}-ng-1"
      launch_template_use_name_prefix = false #workaround for bug in 18.30.2
      iam_role_use_name_prefix        = false #workaround for bug in 18.30.2
      instance_types                  = [var.node_instance_types[0]]
    }
  ]

  tags = var.default_fieldeng_tags
}


# For debug use

resource "null_resource" "kubeconfig" {
  count = var.generate_kubeconfig == true ? 1 : 0

  triggers = {
    cluster_name = module.eks.cluster_name
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --kubeconfig '${path.cwd}/${module.eks.cluster_name}_kubeconfig' --profile ${var.aws_profile} --region ${data.aws_region.current.name}"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}


