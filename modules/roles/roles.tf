# Access Role(database roleのみ)を作成。
resource "snowflake_database_role" "access_db_roles" {
  provider = snowflake.sys_admin
  for_each = {
    for role in var.access_db_roles :
    role.name => role
  }
  database = each.value.database
  name     = each.value.name
  comment  = each.value.comment
}

# Access Role(database role以外)を作成。
resource "snowflake_role" "access_roles" {
  provider = snowflake.security_admin
  for_each = {
    for role in var.access_roles :
    role.name => role.comment
  }
  name    = each.key
  comment = each.value
}

# Functional Roleを作成。
resource "snowflake_role" "functional_roles" {
  provider = snowflake.security_admin
  for_each = {
    for role in var.functional_roles :
    role.name => role.comment
  }
  name    = each.key
  comment = each.value
}

# SYSADMINにAccess Role(database roleのみ)をぶら下げる
resource "snowflake_grant_database_role" "role_grants_db_ar" {
  provider           = snowflake.sys_admin
  for_each           = { for role in snowflake_database_role.access_db_roles : role.name => role }
  database_role_name = "\"${each.value.database}\".\"${each.value.name}\""
  parent_role_name   = "SYSADMIN"
}

# SYSADMINにAccess Role(database role以外)をぶら下げる
resource "snowflake_grant_account_role" "role_grants_ar" {
  provider         = snowflake.security_admin
  for_each         = toset([for role in snowflake_role.access_roles : role.name])
  role_name        = each.key
  parent_role_name = "SYSADMIN"
}

# SYSADMINにFunctional Roleをぶら下げる
resource "snowflake_grant_account_role" "role_grants_fr" {
  provider         = snowflake.security_admin
  for_each         = toset([for role in snowflake_role.functional_roles : role.name])
  role_name        = each.key
  parent_role_name = "SYSADMIN"
}