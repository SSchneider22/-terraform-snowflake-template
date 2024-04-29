# スキーマの作成
resource "snowflake_schema" "this" {
  database            = var.database_name
  name                = var.schema_name
  comment             = var.comment
  data_retention_days = var.data_retention_days

  is_managed   = var.is_managed
  is_transient = var.is_transient
}

# 対象のスキーマに対するRead OnlyのAccess Roleを作成
resource "snowflake_database_role" "read_only_ar" {
  database = snowflake_schema.this.database
  name     = "_SCHEMA_${snowflake_schema.this.name}_RO_AR"
  comment  = "Read only role of ${snowflake_schema.this.name} schema"

  depends_on = [snowflake_schema.this]
}

# Read OnlyのAccess Roleへのスキーマ権限のgrant
resource "snowflake_grant_privileges_to_database_role" "grant_read_only_schema" {
  privileges         = ["USAGE", "MONITOR"]
  database_role_name = "\"${snowflake_schema.this.database}\".\"${snowflake_database_role.read_only_ar.name}\""
  on_schema {
    schema_name = "\"${snowflake_schema.this.database}\".\"${snowflake_schema.this.name}\""
  }

  depends_on = [snowflake_database_role.read_only_ar]
}

# Read OnlyのAccess Roleへのスキーマ内すべてのテーブル権限のgrant
resource "snowflake_grant_privileges_to_database_role" "grant_read_only_all_tables" {
  privileges         = ["SELECT"]
  database_role_name = "\"${snowflake_schema.this.database}\".\"${snowflake_database_role.read_only_ar.name}\""
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_schema.this.database}\".\"${snowflake_schema.this.name}\""
    }
  }

  depends_on = [snowflake_database_role.read_only_ar]
}

# Read OnlyのAccess Roleへのスキーマ内すべてのテーブル権限のfuture grant
resource "snowflake_grant_privileges_to_database_role" "grant_read_only_future_tables" {
  privileges         = ["SELECT"]
  database_role_name = "\"${snowflake_schema.this.database}\".\"${snowflake_database_role.read_only_ar.name}\""
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_schema.this.database}\".\"${snowflake_schema.this.name}\""
    }
  }

  depends_on = [snowflake_database_role.read_only_ar]
}


# Functional RoleにRead OnlyのAccess Roleをgrant
resource "snowflake_grant_database_role" "grant_readonly_ar_to_fr" {
  for_each = var.grant_readonly_ar_to_fr_set

  database_role_name = "\"${snowflake_schema.this.database}\".\"${snowflake_database_role.read_only_ar.name}\""
  parent_role_name   = each.value

  depends_on = [snowflake_database_role.read_only_ar]
}

# 対象のデータベースに対するRead/WriteのAccess Roleを作成
resource "snowflake_database_role" "read_write_ar" {
  database = snowflake_schema.this.database
  name     = "_SCHEMA_${snowflake_schema.this.name}_RW_AR"
  comment  = "Read/Write role of ${snowflake_schema.this.name} schema"

  depends_on = [snowflake_schema.this]
}

# Read WriteのAccess Roleへのスキーマ権限のgrant
resource "snowflake_grant_privileges_to_database_role" "grant_read_write_schema" {
  all_privileges     = true
  database_role_name = "\"${snowflake_schema.this.database}\".\"${snowflake_database_role.read_write_ar.name}\""
  on_schema {
    schema_name = "\"${snowflake_schema.this.database}\".\"${snowflake_schema.this.name}\""
  }

  depends_on = [snowflake_database_role.read_write_ar]
}

# Read WriteのAccess Roleへのスキーマ内すべてのテーブル権限のgrant
resource "snowflake_grant_privileges_to_database_role" "grant_read_write_all_tables" {
  all_privileges     = true
  database_role_name = "\"${snowflake_schema.this.database}\".\"${snowflake_database_role.read_write_ar.name}\""
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_schema.this.database}\".\"${snowflake_schema.this.name}\""
    }
  }

  depends_on = [snowflake_database_role.read_write_ar]
}

# Read WriteのAccess Roleへのスキーマ内すべてのテーブル権限のfuture grant
resource "snowflake_grant_privileges_to_database_role" "grant_read_write_future_tables" {
  all_privileges     = true
  database_role_name = "\"${snowflake_schema.this.database}\".\"${snowflake_database_role.read_write_ar.name}\""
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_schema.this.database}\".\"${snowflake_schema.this.name}\""
    }
  }

  depends_on = [snowflake_database_role.read_write_ar]
}

# Functional RoleにRead/WriteのAccess Roleをgrant
resource "snowflake_grant_database_role" "grant_readwrite_ar_to_fr" {
  for_each = var.grant_readwrite_ar_to_fr_set

  database_role_name = "\"${snowflake_schema.this.database}\".\"${snowflake_database_role.read_write_ar.name}\""
  parent_role_name   = each.value

  depends_on = [snowflake_database_role.read_write_ar]
}

# SYSADMINにAccess Roleをgrant
resource "snowflake_grant_database_role" "grant_to_sysadmin" {
  for_each           = toset([snowflake_database_role.read_only_ar.name, snowflake_database_role.read_write_ar.name])
  database_role_name = "\"${snowflake_schema.this.database}\".\"${each.value}\""
  parent_role_name   = "SYSADMIN"

  depends_on = [snowflake_database_role.read_only_ar, snowflake_database_role.read_write_ar]
}