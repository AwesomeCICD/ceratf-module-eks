resource "kubernetes_namespace" "user_main" {
  count = length(var.user_list)
  metadata {
    name = "user-${var.user_list[count.index]}"
  }
}

resource "kubernetes_namespace" "user_alt" {
  count = length(var.user_list)
  metadata {
    name = "user-${var.user_list[count.index]}-alt"
  }
}

