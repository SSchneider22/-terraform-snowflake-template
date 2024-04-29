# Functional Roleの作成
resource "snowflake_role" "this" {
  name    = var.role_name
  comment = var.comment
}

# Functional Roleをユーザーにgrant
resource "snowflake_grant_account_role" "grant_to_user" {
  for_each = var.grant_user_set

  role_name = var.role_name
  user_name = each.value

  depends_on = [snowflake_role.this]
}

# SYSADMINにFunctional Roleをgrant
resource "snowflake_grant_account_role" "grant_to_sysadmin" {
  role_name        = var.role_name
  parent_role_name = "SYSADMIN"

  depends_on = [snowflake_role.this]
}