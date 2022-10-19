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
    usages      = ["server auth"] #Not sure what the correct value should be
    signer_name = "beta.eks.amazonaws.com/app-serving" #"kubernetes.io/kube-apiserver-client"
    request = tls_cert_request.user_csr["${each.key}"].cert_request_pem
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