# データベースをaccess roleにgrantする
resource "snowflake_grant_privileges_to_database_role" "grant_database_to_access_role" {
  for_each = {
    for item in local.grant_database_to_access_db_role : "${item.grant_name}-${item.access_role}" => item
  }

  privileges         = each.value.parameter.all_privileges == true ? null : each.value.parameter.privileges
  database_role_name = "\"${each.value.parameter.database_name}\".\"${each.value.access_role}\""
  on_database        = each.value.parameter.database_name
  all_privileges     = each.value.parameter.all_privileges == true ? each.value.parameter.all_privileges : null

  depends_on = [snowflake_database_role.access_db_roles]
}

# スキーマをaccess roleにgrantする
resource "snowflake_grant_privileges_to_database_role" "grant_schema_to_access_role" {
  for_each = {
    for item in local.grant_schema_to_access_db_role : "${item.grant_name}-${item.access_role}" => item
  }

  privileges         = each.value.parameter.all_privileges == true ? null : each.value.parameter.privileges
  database_role_name = "\"${each.value.parameter.database_name}\".\"${each.value.access_role}\""
  on_schema {
    schema_name = "\"${each.value.parameter.database_name}\".\"${each.value.parameter.schema_name}\""
  }
  all_privileges = each.value.parameter.all_privileges == true ? each.value.parameter.all_privileges : null

  depends_on = [snowflake_database_role.access_db_roles]
}

# スキーマ内の全テーブルの権限をaccess roleにgrantする
resource "snowflake_grant_privileges_to_database_role" "grant_table_to_access_role_all" {
  for_each = {
    for item in local.grant_table_to_access_db_role : "${item.grant_name}-${item.access_role}" => item
  }

  privileges         = each.value.parameter.all_privileges == true ? null : each.value.parameter.privileges
  database_role_name = "\"${each.value.parameter.database_name}\".\"${each.value.access_role}\""
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "\"${each.value.parameter.database_name}\".\"${each.value.parameter.schema_name}\""
    }
  }
  all_privileges = each.value.parameter.all_privileges == true ? each.value.parameter.all_privileges : null

  depends_on = [snowflake_database_role.access_db_roles]
}

# スキーマ内今後追加されるテーブルの権限をaccess roleにgrantする
resource "snowflake_grant_privileges_to_database_role" "grant_table_to_access_role_future" {
  for_each = {
    for item in local.grant_table_to_access_db_role : "${item.grant_name}-${item.access_role}" => item
  }

  privileges         = each.value.parameter.all_privileges == true ? null : each.value.parameter.privileges
  database_role_name = "\"${each.value.parameter.database_name}\".\"${each.value.access_role}\""
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${each.value.parameter.database_name}\".\"${each.value.parameter.schema_name}\""
    }
  }
  all_privileges = each.value.parameter.all_privileges == true ? each.value.parameter.all_privileges : null

  depends_on = [snowflake_database_role.access_db_roles]
}


# ウェアハウスをaccess roleにgrantする
resource "snowflake_grant_privileges_to_account_role" "grant_warehouse_to_access_role" {
  for_each = {
    for item in local.grant_warehouse_to_access_role : "${item.grant_name}-${item.access_role}" => item
  }

  privileges        = each.value.parameter.privileges
  account_role_name = each.value.access_role
  on_account_object {
    object_type = each.value.type
    object_name = each.value.parameter.warehouse_name
  }

  depends_on = [snowflake_role.access_roles]
}