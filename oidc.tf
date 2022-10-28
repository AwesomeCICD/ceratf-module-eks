#Already exists outside of Terraform
/*
resource "aws_iam_openid_connect_provider" "circleci" {
  url = "https://oidc.circleci.com/org/${var.circleci_org_id}"

  client_id_list = [
    var.circleci_org_id
  ]

  thumbprint_list = []
}
*/

data "aws_iam_openid_connect_provider" "circleci" {
  url = "https://oidc.circleci.com/org/${var.circleci_org_id}"
}




resource "aws_iam_role" "circleci_access" {
  name = local.circleci_org_friendly_name

  assume_role_policy = templatefile(
    "${path.module}/templates/oidc_assume_role.json.tpl",
    {
      AWS_ACCOUNT_ID  = data.aws_caller_identity.current.id,
      CIRCLECI_ORG_ID = var.circleci_org_id
    }
  )
}



resource "aws_iam_role_policy_attachment" "circleci_access" {
  role       = aws_iam_role.circleci_access.name
  policy_arn = data.aws_iam_policy.administrator_access.arn
}

data "aws_iam_policy" "administrator_access" {
  name = "AdministratorAccess"
}
