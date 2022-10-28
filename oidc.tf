#Already exists outside of Terraform

resource "aws_iam_openid_connect_provider" "circleci" {
  for_each = toset(var.circleci_org_ids_requiring_aws_oidc_provider)

  url = "https://oidc.circleci.com/org/${each.key}"

  client_id_list = [
    each.key
  ]

  thumbprint_list = []
}


data "aws_iam_openid_connect_provider" "circleci" {
  for_each = setsubtract(
    toset(var.circleci_org_ids),
    toset(var.circleci_org_ids_requiring_aws_oidc_provider)
  )

  url = "https://oidc.circleci.com/org/${each.key}"
}



resource "aws_iam_role" "circleci_org_access" {
  for_each = toset(distinct(concat(
    var.circleci_org_ids_requiring_aws_oidc_provider,
    var.circleci_org_ids
  )))

  name = "cci-org-${substr(each.key, 0, 7)}-oidc-access"

  assume_role_policy = templatefile(
    "${path.module}/templates/oidc_assume_role.json.tpl",
    {
      AWS_ACCOUNT_ID  = data.aws_caller_identity.current.id,
      CIRCLECI_ORG_ID = each.key
    }
  )
}



resource "aws_iam_role_policy_attachment" "circleci_org_access" {
  for_each = toset(distinct(concat(
    var.circleci_org_ids_requiring_aws_oidc_provider,
    var.circleci_org_ids
  )))

  role       = aws_iam_role.circleci_org_access[each.key].name
  policy_arn = data.aws_iam_policy.administrator_access.arn
}

# TODO: Replace this with a custom policy granting access only to EKS resources
data "aws_iam_policy" "administrator_access" {
  name = "AdministratorAccess"
}
