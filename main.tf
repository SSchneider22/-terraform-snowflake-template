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
    snowflake = snowflake.terraform
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
    snowflake = snowflake.terraform
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
    snowflake = snowflake.terraform
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
    snowflake = snowflake.terraform
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
    snowflake = snowflake.terraform
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
    snowflake = snowflake.terraform
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
    snowflake = snowflake.terraform
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
    snowflake = snowflake.terraform
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
    snowflake = snowflake.terraform
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
    snowflake = snowflake.terraform
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
    snowflake = snowflake.terraform
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
    snowflake = snowflake.terraform
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

########################
# ウェアハウス
########################
module "aaa_analyse_wh" {
  source = "./modules/access_role_and_warehouse"
  providers = {
    snowflake = snowflake.terraform
  }

  warehouse_name = "AAA_ANALYSE_WH"
  warehouse_size = "XSMALL"
  comment        = "Warehouse for analysis of AAA projects"

  grant_usage_ar_to_fr_set = [
    module.aaa_analyst_fr.name
  ]
  grant_admin_ar_to_fr_set = [
    module.aaa_developer_fr.name
  ]
}

module "bbb_analyse_wh" {
  source = "./modules/access_role_and_warehouse"
  providers = {
    snowflake = snowflake.terraform
  }

  warehouse_name = "BBB_ANALYSE_WH"
  warehouse_size = "XSMALL"
  comment        = "Warehouse for analysis of BBB projects"

  grant_usage_ar_to_fr_set = [
    module.bbb_analyst_fr.name
  ]
  grant_admin_ar_to_fr_set = [
    module.bbb_developer_fr.name
  ]
}

module "aaa_develop_wh" {
  source = "./modules/access_role_and_warehouse"
  providers = {
    snowflake = snowflake.terraform
  }

  warehouse_name = "AAA_DEVELOP_WH"
  warehouse_size = "XSMALL"
  comment        = "Warehouse for develop of AAA projects"

  grant_admin_ar_to_fr_set = [
    module.aaa_developer_fr.name
  ]
}

module "bbb_develop_wh" {
  source = "./modules/access_role_and_warehouse"
  providers = {
    snowflake = snowflake.terraform
  }

  warehouse_name = "BBB_DEVELOP_WH"
  warehouse_size = "XSMALL"
  comment        = "Warehouse for develop of BBB projects"

  grant_admin_ar_to_fr_set = [
    module.bbb_developer_fr.name
  ]
}