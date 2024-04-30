# ウェアハウスの作成
resource "snowflake_warehouse" "this" {
  name           = var.warehouse_name
  comment        = var.comment
  warehouse_size = var.warehouse_size

  auto_resume                         = var.auto_resume
  auto_suspend                        = var.auto_suspend
  enable_query_acceleration           = var.enable_query_acceleration
  initially_suspended                 = var.initially_suspended
  max_cluster_count                   = var.max_cluster_count
  max_concurrency_level               = var.max_concurrency_level
  min_cluster_count                   = var.min_cluster_count
  query_acceleration_max_scale_factor = var.query_acceleration_max_scale_factor
  resource_monitor                    = var.resource_monitor
  scaling_policy                      = var.scaling_policy
  statement_queued_timeout_in_seconds = var.statement_queued_timeout_in_seconds
  statement_timeout_in_seconds        = var.statement_timeout_in_seconds
  warehouse_type                      = var.warehouse_type
}

# 対象のウェアハウスに対するUSAGEのAccess Roleを作成
resource "snowflake_role" "usage_ar" {
  name    = "_WAREHOUSE_${snowflake_warehouse.this.name}_USAGE_AR"
  comment = "USAGE role of ${snowflake_warehouse.this.name}"

  depends_on = [snowflake_warehouse.this]
}

# USAGEのAccess Roleへの権限のgrant
resource "snowflake_grant_privileges_to_account_role" "grant_usage" {
  privileges        = ["USAGE", "MONITOR"]
  account_role_name = snowflake_role.usage_ar.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }

  depends_on = [snowflake_role.usage_ar]
}

# Functional RoleにUSAGEのAccess Roleをgrant
resource "snowflake_grant_account_role" "grant_usage_ar_to_fr" {
  for_each = var.grant_usage_ar_to_fr_set

  role_name        = snowflake_role.usage_ar.name
  parent_role_name = each.value

  depends_on = [snowflake_role.usage_ar]
}

# 対象のウェアハウスに対するADMINのAccess Roleを作成
resource "snowflake_role" "admin_ar" {
  name    = "_WAREHOUSE_${snowflake_warehouse.this.name}_ADMIN_AR"
  comment = "ADMIN role of ${snowflake_warehouse.this.name}"

  depends_on = [snowflake_warehouse.this]
}

# ADMINのAccess Roleへの権限のgrant
resource "snowflake_grant_privileges_to_account_role" "grant_admin" {
  all_privileges    = true
  account_role_name = snowflake_role.admin_ar.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }

  depends_on = [snowflake_role.admin_ar]
}

# Functional RoleにADMINのAccess Roleをgrant
resource "snowflake_grant_account_role" "grant_admin_ar_to_fr" {
  for_each = var.grant_admin_ar_to_fr_set

  role_name        = snowflake_role.admin_ar.name
  parent_role_name = each.value

  depends_on = [snowflake_role.admin_ar]
}

# SYSADMINにAccess Roleをgrant
resource "snowflake_grant_account_role" "grant_to_sysadmin" {
  for_each         = toset([snowflake_role.usage_ar.name, snowflake_role.admin_ar.name])
  role_name        = each.value
  parent_role_name = "SYSADMIN"

  depends_on = [snowflake_role.usage_ar, snowflake_role.admin_ar]
}

