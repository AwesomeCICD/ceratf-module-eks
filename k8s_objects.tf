#Create two namespaces for each user

resource "kubernetes_namespace" "user_main" {
  for_each = toset(var.user_list)
  metadata {
    name = "main-${each.key}"
  }
}

resource "kubernetes_namespace" "user_alt" {
  for_each = toset(var.user_list)
  metadata {
    name = "alt-${each.key}"
  }
}

# It looks like you must use IAM auth to access the k8s cluster; you can't just use regular k8s users.  
# Since these are sandbox cluster, we could just use the cluster creator kubeconfig file that gets generated.
# Leaving this stuff here but commented out in case we want to revisit it.

/*

#Source: https://github.com/rhythmictech/terraform-kubernetes-x509-auth-manager/blob/master/main.tf


# Create private keys

resource "tls_private_key" "user_key" {
  for_each = toset(var.user_list)

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "user_key" {
  for_each = toset(var.user_list)

  filename = "${path.cwd}/secrets/keys/${each.key}.pem"
  content  = tls_private_key.user_key["${each.key}"].private_key_pem
}


# Create CSRs and have k8s sign them 

resource "tls_cert_request" "user_csr" {
  for_each = toset(var.user_list)

  #private_key_pem = file("${local_file.user_key[each.key].filename}")
  private_key_pem = tls_private_key.user_key["${each.key}"].private_key_pem

  subject {
    common_name  = each.key
    organization = "cluster-admin"
  }

  depends_on = [
    local_file.user_key
  ]

}

resource "kubernetes_certificate_signing_request_v1" "user_csr" {
  for_each = toset(var.user_list)

  metadata {
    name = each.key
  }
  spec {
    usages      = ["server auth"]                      #Not sure what the correct value should be
    signer_name = "beta.eks.amazonaws.com/app-serving" #"kubernetes.io/kube-apiserver-client"
    request     = tls_cert_request.user_csr["${each.key}"].cert_request_pem
  }
  auto_approve = true
}


resource "kubernetes_secret" "user_cert" {
  for_each = toset(var.user_list)

  metadata {
    name = "cert-${each.key}"
  }
  data = {
    "tls.crt" = kubernetes_certificate_signing_request_v1.user_csr["${each.key}"].certificate
    "tls.key" = tls_private_key.user_key["${each.key}"].private_key_pem
  }
  type = "kubernetes.io/tls"
}

# Create kubeconfig files

resource "local_file" "user_kubeconfig" {
  for_each = toset(var.user_list)
  
  filename = "${path.cwd}/secrets/kubeconfigs/${each.key}_kubeconfig.yaml"
  content = templatefile(
    "${path.module}/templates/kubeconfig.yaml.tpl", {
      # CA, CRT, and KEY data need to be base64
      #  but are already encoded
      CA_DATA         = data.aws_eks_cluster.cluster.certificate_authority.0.data
      API_SERVER      = module.eks.cluster_endpoint,
      CLUSTER_NAME    = module.eks.cluster_arn,
      #namespace       = var.namespace,
      username        = "${each.key}",
      CLIENT_CRT_DATA = base64encode(kubernetes_certificate_signing_request_v1.user_csr["${each.key}"].certificate),
      CLIENT_KEY_DATA = base64encode(tls_private_key.user_key["${each.key}"].private_key_pem)
  })
}
*/