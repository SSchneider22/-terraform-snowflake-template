# Access role(database role以外) を Functional role に grant する
resource "snowflake_grant_account_role" "access_role_to_functional_role_grants" {
  for_each = { for item in var.grant_access_roles_to_functional_roles : "${item.access_role}-${item.functional_role}" => item }

  role_name        = each.value.access_role
  parent_role_name = each.value.functional_role

}

# Access role(database roleのみ) を Functional role に grant する
resource "snowflake_grant_database_role" "access_role_to_functional_role_grants" {
  for_each = { for item in var.grant_access_db_roles_to_functional_roles : "${item.access_role}-${item.functional_role}" => item }

  database_role_name = "\"${each.value.database}\".\"${each.value.access_role}\""
  parent_role_name   = each.value.functional_role

}