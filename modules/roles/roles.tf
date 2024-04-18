# Access Roleを作成。ユーザーがロール切替時に見えないように、Database roleで
resource "snowflake_role" "access_roles" {
  for_each = {
    for role in var.access_roles :
    role.name => role.comment
  }
  name    = each.key
  comment = each.value
}

# Functional Roleを作成。
resource "snowflake_role" "functional_roles" {
  for_each = {
    for role in var.functional_roles :
    role.name => role.comment
  }
  name    = each.key
  comment = each.value
}

# SYSADMINにAccess Roleをぶら下げる
resource "snowflake_grant_account_role" "role_grants_ar" {
  for_each         = toset([for role in snowflake_role.access_roles : role.name])
  role_name        = each.key
  parent_role_name = "SYSADMIN"
}

# SYSADMINにFunctional Roleをぶら下げる
resource "snowflake_grant_account_role" "role_grants_fr" {
  for_each         = toset([for role in snowflake_role.functional_roles : role.name])
  role_name        = each.key
  parent_role_name = "SYSADMIN"
}