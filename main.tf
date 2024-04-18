########################
# ロール
########################
# Functional roleとAccess roleを作成
module "functional_and_access_roles" {
  source = "./modules/roles"
  providers = {
    snowflake = snowflake.security_admin
  }

  access_roles                           = local.access_roles
  grant_on_object_to_access_role         = local.grant_on_object_to_access_role
  functional_roles                       = local.functional_roles
  grant_access_roles_to_functional_roles = local.grant_access_role_to_functional_role
  grant_functional_roles_to_user         = local.grant_functional_roles_to_user
}

########################
# ウェアハウス
########################

resource "snowflake_warehouse" "warehouse" {
  provider       = snowflake.sys_admin
  name           = "TF_DEMO"
  warehouse_size = "xsmall"
  auto_suspend   = 120
}

########################
# データベース
########################

resource "snowflake_database" "prd_db" {
  provider = snowflake.sys_admin
  name     = "PRD_DB"
}

########################
# スキーマ
########################

resource "snowflake_schema" "schema_a" {
  provider = snowflake.sys_admin
  database = "PRD_DB"
  name     = "SCHEMA_A"
}

resource "snowflake_schema" "schema_b" {
  provider = snowflake.sys_admin
  database = "PRD_DB"
  name     = "SCHEMA_B"
}

########################
# テーブル
########################

resource "snowflake_table" "table_a1" {
  database = snowflake_database.prd_db.name
  schema   = snowflake_schema.schema_a.name
  name     = "TABLE_A1"
  column {
    name = "ID"
    type = "INTEGER"
  }
  column {
    name = "NAME"
    type = "VARCHAR(255)"
  }
}

resource "snowflake_table" "table_b1" {
  database = snowflake_database.prd_db.name
  schema   = snowflake_schema.schema_b.name
  name     = "TABLE_B1"
  column {
    name = "ID"
    type = "INTEGER"
  }
  column {
    name = "NAME"
    type = "VARCHAR(255)"
  }
}
