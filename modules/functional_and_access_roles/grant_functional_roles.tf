# Functional role を ユーザー に grant する
resource "snowflake_grant_account_role" "functional_role_to_user_grants" {
  for_each = {
    for item in local.grant_functional_roles_to_user : "${item.functional_role}-${item.user_name}" => item
  }

  role_name = each.value.functional_role
  user_name = each.value.user_name

}