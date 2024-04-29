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

  access_db_roles                           = local.access_db_roles
  access_roles                              = local.access_roles
  grant_warehouse_to_access_role            = local.grant_warehouse_to_access_role
  grant_database_to_access_db_role          = local.grant_database_to_access_db_role
  grant_schema_to_access_db_role            = local.grant_schema_to_access_db_role
  grant_table_to_access_db_role             = local.grant_table_to_access_db_role
  functional_roles                          = local.functional_roles
  grant_access_roles_to_functional_roles    = local.grant_access_role_to_functional_role
  grant_access_db_roles_to_functional_roles = local.grant_access_db_role_to_functional_role
  grant_functional_roles_to_user            = local.grant_functional_roles_to_user
}



##################
##################
##################
##################
# ここから、新しいmoduleでの定義
##################
##################
##################
##################

########################
# ユーザー
########################

module "analyst_sagara" {
  source = "./modules/user"
  providers = {
    snowflake = snowflake.security_admin
  }

  name    = "ANALYST_SAGARA"
  comment = "Analyst sagara"
}

module "developer_sagara" {
  source = "./modules/user"
  providers = {
    snowflake = snowflake.security_admin
  }

  name    = "DEVELOPER_SAGARA"
  comment = "Developer sagara"
}

########################
# Functional Role
########################

module "aaa_analyst_fr" {
  source = "./modules/functional_role"
  providers = {
    snowflake = snowflake.security_admin
  }

  role_name = "AAA_ANALYST_FR"
  grant_user_set = [
    "ANALYST_SAGARA",
    "DEVELOPER_SAGARA"
  ]
  comment = "Functional Role for analysis in Project AAA"
}

module "aaa_developer_fr" {
  source = "./modules/functional_role"
  providers = {
    snowflake = snowflake.security_admin
  }

  role_name = "AAA_DEVELOPER_FR"
  grant_user_set = [
    "DEVELOPER_SAGARA"
  ]
  comment = "Functional Role for develop in Project AAA"
}

module "bbb_analyst_fr" {
  source = "./modules/functional_role"
  providers = {
    snowflake = snowflake.security_admin
  }

  role_name = "BBB_ANALYST_FR"
  grant_user_set = [
    "ANALYST_SAGARA",
    "DEVELOPER_SAGARA"
  ]
  comment = "Functional Role for analysis in Project BBB"
}

module "bbb_developer_fr" {
  source = "./modules/functional_role"
  providers = {
    snowflake = snowflake.security_admin
  }

  role_name = "BBB_DEVELOPER_FR"
  grant_user_set = [
    "DEVELOPER_SAGARA"
  ]
  comment = "Functional Role for develop in Project BBB"
}

########################
# データベース
########################
module "raw_data_db" {
  source = "./modules/access_role_and_database"
  providers = {
    snowflake = snowflake.sys_admin
  }

  database_name               = "RAW_DATA"
  comment                     = "Database to store loaded raw data"
  data_retention_time_in_days = 3
  grant_readwrite_ar_to_fr_set = [
    module.aaa_developer_fr.name,
    module.bbb_developer_fr.name
  ]
}

module "staging_db" {
  source = "./modules/access_role_and_database"
  providers = {
    snowflake = snowflake.sys_admin
  }

  database_name               = "STAGING"
  comment                     = "Database to store data with minimal transformation from raw data"
  data_retention_time_in_days = 1
  grant_readwrite_ar_to_fr_set = [
    module.aaa_developer_fr.name,
    module.bbb_developer_fr.name
  ]
}

module "dwh_db" {
  source = "./modules/access_role_and_database"
  providers = {
    snowflake = snowflake.sys_admin
  }

  database_name               = "DWH"
  comment                     = "Database to store data on which various modeling has been done"
  data_retention_time_in_days = 1
  grant_readonly_ar_to_fr_set = [
    module.aaa_analyst_fr.name,
    module.bbb_analyst_fr.name
  ]
  grant_readwrite_ar_to_fr_set = [
    module.aaa_developer_fr.name,
    module.bbb_developer_fr.name
  ]
}

module "mart_db" {
  source = "./modules/access_role_and_database"
  providers = {
    snowflake = snowflake.sys_admin
  }

  database_name               = "MART"
  comment                     = "Database that stores data used for reporting and linkage to another tool"
  data_retention_time_in_days = 1
  grant_readonly_ar_to_fr_set = [
    module.aaa_analyst_fr.name,
    module.bbb_analyst_fr.name
  ]
  grant_readwrite_ar_to_fr_set = [
    module.aaa_developer_fr.name,
    module.bbb_developer_fr.name
  ]
}

########################
# スキーマ
########################
module "raw_data_db_aaa_schema" {
  source = "./modules/access_role_and_schema"
  providers = {
    snowflake = snowflake.sys_admin
  }

  schema_name         = "AAA"
  database_name       = module.raw_data_db.name
  comment             = "Schema to store loaded raw data of AAA"
  data_retention_days = 3
  grant_readwrite_ar_to_fr_set = [
    module.aaa_developer_fr.name
  ]
}

module "raw_data_db_bbb_schema" {
  source = "./modules/access_role_and_schema"
  providers = {
    snowflake = snowflake.sys_admin
  }

  schema_name         = "BBB"
  database_name       = module.raw_data_db.name
  comment             = "Schema to store loaded raw data of BBB"
  data_retention_days = 3
  grant_readwrite_ar_to_fr_set = [
    module.bbb_developer_fr.name
  ]
}

module "staging_db_aaa_schema" {
  source = "./modules/access_role_and_schema"
  providers = {
    snowflake = snowflake.sys_admin
  }

  schema_name         = "AAA"
  database_name       = module.staging_db.name
  comment             = "Schema to store data with minimal transformation from raw data of AAA"
  data_retention_days = 1
  grant_readwrite_ar_to_fr_set = [
    module.aaa_developer_fr.name
  ]
}

module "staging_db_bbb_schema" {
  source = "./modules/access_role_and_schema"
  providers = {
    snowflake = snowflake.sys_admin
  }

  schema_name         = "BBB"
  database_name       = module.staging_db.name
  comment             = "Schema to store data with minimal transformation from raw data of BBB"
  data_retention_days = 1
  grant_readwrite_ar_to_fr_set = [
    module.bbb_developer_fr.name
  ]
}

module "dwh_db_aaa_schema" {
  source = "./modules/access_role_and_schema"
  providers = {
    snowflake = snowflake.sys_admin
  }

  schema_name         = "AAA"
  database_name       = module.dwh_db.name
  comment             = "Schema to store data on which various modeling has been done for AAA"
  data_retention_days = 1
  grant_readonly_ar_to_fr_set = [
    module.aaa_analyst_fr.name
  ]
  grant_readwrite_ar_to_fr_set = [
    module.aaa_developer_fr.name
  ]
}

module "dwh_db_bbb_schema" {
  source = "./modules/access_role_and_schema"
  providers = {
    snowflake = snowflake.sys_admin
  }

  schema_name         = "BBB"
  database_name       = module.dwh_db.name
  comment             = "Schema to store data on which various modeling has been done for BBB"
  data_retention_days = 1
  grant_readonly_ar_to_fr_set = [
    module.bbb_analyst_fr.name
  ]
  grant_readwrite_ar_to_fr_set = [
    module.bbb_developer_fr.name
  ]
}

module "mart_db_aaa_schema" {
  source = "./modules/access_role_and_schema"
  providers = {
    snowflake = snowflake.sys_admin
  }

  schema_name         = "AAA"
  database_name       = module.mart_db.name
  comment             = "Schema that stores data used for reporting and linkage to another tool for AAA"
  data_retention_days = 1
  grant_readonly_ar_to_fr_set = [
    module.aaa_analyst_fr.name
  ]
  grant_readwrite_ar_to_fr_set = [
    module.aaa_developer_fr.name
  ]
}

module "mart_db_bbb_schema" {
  source = "./modules/access_role_and_schema"
  providers = {
    snowflake = snowflake.sys_admin
  }

  schema_name         = "BBB"
  database_name       = module.mart_db.name
  comment             = "Schema that stores data used for reporting and linkage to another tool for BBB"
  data_retention_days = 1
  grant_readonly_ar_to_fr_set = [
    module.bbb_analyst_fr.name
  ]
  grant_readwrite_ar_to_fr_set = [
    module.bbb_developer_fr.name
  ]
}