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

/*
resource "kubernetes_namespace" "user_alt" {
  count = length(var.user_list)
  metadata {
    name = "user-${var.user_list[count.index]}-alt"
  }
}
*/