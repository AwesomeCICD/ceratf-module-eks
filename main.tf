
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
  version         = "~> 20.0"
  cluster_name    = local.derived_cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = module.vpc.private_subnets
  # The OIDC provider for EKS cluster access via SSO is created in the global infra TF plan
  # enable_irsa creates a separate OIDC provider used solely for IRSA (IAM Roles for K8s Service Accounts)
  enable_irsa                     = true
  vpc_id                          = module.vpc.vpc_id
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    instance_types = var.node_instance_types
    tags           = var.default_fieldeng_tags
  }

  eks_managed_node_groups = [
    {
      name                 = "${local.derived_cluster_name}-ng-1"
      launch_template_name = "${local.derived_cluster_name}-launch-template"
      desired_size         = var.nodegroup_desired_capacity
      instance_types       = [var.node_instance_types[0]]
      force_update_version = true
      # The role created by the Terraform module already has the cluster-specific attributes
      # Setting this to false ensures that the name_prefix conforms to the limits set by AWS
      iam_role_use_name_prefix = false
      # Add additional EBS CSI Driver Policy to the Nodegroup IAM role
      # https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonEBSCSIDriverPolicy.html
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = "50"
            volume_type           = "gp2"
            encrypted             = false
            delete_on_termination = true
          }
        }
      }

      ## Explicitly set Instance Metadata Options for Nodegroup EC2 instances
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "enabled"
      }


    }
  ]

  access_entries = {

    fieldeng_eks_access = {
      principal_arn = "arn:aws:iam::992382483259:role/FieldEngineeringEKS"
      policy_associations = {
        admin_policy = {
          ### https://docs.aws.amazon.com/eks/latest/userguide/access-policies.html
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
        namespace_policy = {
          ### https://docs.aws.amazon.com/eks/latest/userguide/access-policies.html
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type       = "namespace"
            namespaces = ["default", "kube-system", "*"]
          }
        }
      }
    }
  }

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


