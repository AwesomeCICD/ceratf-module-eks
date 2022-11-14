#Create two namespaces for each user
/*
resource "kubernetes_namespace" "user_main" {
  for_each = toset(var.user_list)
  metadata {
    name = "user-${each.key}-main"
  }
}

resource "kubernetes_namespace" "user_alt" {
  for_each = toset(var.user_list)
  metadata {
    name = "user-${each.key}-alt"
  }
}
*/