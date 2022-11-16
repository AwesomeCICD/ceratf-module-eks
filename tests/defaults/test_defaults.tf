terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}


provider "aws" {
    region = "us-east-1"
}

provider "kubernetes" {
  config_path    = "./${module.se_eks_cluster.cluster_id}_kubeconfig"
  config_context = module.se_eks_cluster.cluster_arn
}

module "se_eks_cluster" {
  source = "../.."

  cluster_suffix = "test-${random_string.testing.result}"
  generate_kubeconfig = true
}

resource "random_string" "testing" {
  length           = 4
  special          = false
  upper            = false
}

data "kubernetes_namespace_v1" "kube-system" {
  metadata {
    name = "kube-system"
  }

  depends_on = [
    module.se_eks_cluster
  ]
}

resource "test_assertions" "get_namespace" {
  component = "get_namespace"

  check "can_retrieve_kube_system_namespace" {
    description = "can retrieve kube-system namespace"
    condition   = data.kubernetes_namespace_v1.kube-system.metadata[0].name == "kube-system"
  }
}