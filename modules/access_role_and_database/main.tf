# データベースの作成
resource "snowflake_database" "this" {
  name                        = var.database_name
  comment                     = var.comment
  data_retention_time_in_days = var.data_retention_time_in_days

  # replicationやshare周りのoptionは割愛
}

# 対象のデータベースに対するRead OnlyのAccess Roleを作成
resource "snowflake_database_role" "read_only_ar" {
  database = snowflake_database.this.name
  name     = "_DATABASE_${snowflake_database.this.name}_RO_AR"
  comment  = "Read only role of ${snowflake_database.this.name}"

  depends_on = [snowflake_database.this]
}

# Read OnlyのAccess Roleへの権限のgrant
resource "snowflake_grant_privileges_to_database_role" "grant_read_only" {
  privileges         = ["USAGE", "MONITOR"]
  database_role_name = "\"${snowflake_database.this.name}\".\"${snowflake_database_role.read_only_ar.name}\""
  on_database        = snowflake_database.this.name

  depends_on = [snowflake_database_role.read_only_ar]
}

# Functional RoleにRead OnlyのAccess Roleをgrant
resource "snowflake_grant_database_role" "grant_readonly_ar_to_fr" {
  for_each = var.grant_readonly_ar_to_fr_set

  database_role_name = "\"${snowflake_database.this.name}\".\"${snowflake_database_role.read_only_ar.name}\""
  parent_role_name   = each.value

  depends_on = [snowflake_database_role.read_only_ar]
}

# 対象のデータベースに対するRead/WriteのAccess Roleを作成
resource "snowflake_database_role" "read_write_ar" {
  database = snowflake_database.this.name
  name     = "_DATABASE_${snowflake_database.this.name}_RW_AR"
  comment  = "Read/Write role of ${snowflake_database.this.name}"

  depends_on = [snowflake_database.this]
}

# Read WriteのAccess Roleへの権限のgrant
resource "snowflake_grant_privileges_to_database_role" "grant_read_write" {
  all_privileges     = true
  database_role_name = "\"${snowflake_database.this.name}\".\"${snowflake_database_role.read_write_ar.name}\""
  on_database        = snowflake_database.this.name

  depends_on = [snowflake_database_role.read_write_ar]
}

# Functional RoleにRead/WriteのAccess Roleをgrant
resource "snowflake_grant_database_role" "grant_readwrite_ar_to_fr" {
  for_each = var.grant_readwrite_ar_to_fr_set

  database_role_name = "\"${snowflake_database.this.name}\".\"${snowflake_database_role.read_write_ar.name}\""
  parent_role_name   = each.value

  depends_on = [snowflake_database_role.read_write_ar]
}

# SYSADMINにAccess Roleをgrant
resource "snowflake_grant_database_role" "grant_to_sysadmin" {
  for_each           = toset([snowflake_database_role.read_only_ar.name, snowflake_database_role.read_write_ar.name])
  database_role_name = "\"${snowflake_database.this.name}\".\"${each.value}\""
  parent_role_name   = "SYSADMIN"

  depends_on = [snowflake_database_role.read_only_ar, snowflake_database_role.read_write_ar]
}