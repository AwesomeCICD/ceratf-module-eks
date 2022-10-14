module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "${var.cluster_version}"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "m5.large"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
      metadata_http_put_response_hop_limit = 2 #enable IMDSv2
      tags  = [
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
      name                          = "worker-group-2"
      instance_type                 = "m5.large"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 2
      metadata_http_put_response_hop_limit = 2 #enable IMDSv2
      tags  = [
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

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
