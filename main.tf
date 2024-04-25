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
  provider   = snowflake.sys_admin
  database   = "PRD_DB"
  name       = "SCHEMA_A"
  depends_on = [snowflake_database.prd_db]
}

resource "snowflake_schema" "schema_b" {
  provider   = snowflake.sys_admin
  database   = "PRD_DB"
  name       = "SCHEMA_B"
  depends_on = [snowflake_database.prd_db]
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
    type = "NUMBER(38,0)"
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
    type = "NUMBER(38,0)"
  }
  column {
    name = "NAME"
    type = "VARCHAR(255)"
  }
}


########################
# ロール
########################
# Functional roleとAccess roleを作成
module "functional_and_access_roles" {
  source = "./modules/functional_and_access_roles"
  providers = {
    snowflake = snowflake.security_admin
  }
}