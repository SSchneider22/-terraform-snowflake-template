# variables.tf の各 variable に渡されたロール情報を展開して、ロールを作ったり権限を付与したりしていきます。
variable "functional_roles" {
  type        = list(any)
  description = "Functional roleリスト。[ {name: <role_name>, comment: <comment>},... ]"
}

variable "access_db_roles" {
  type        = list(any)
  description = "Access roleリスト。database roleのみ。[ {name: <role_name>, comment: <comment>},... ]"
}

variable "access_roles" {
  type        = list(any)
  description = "Access roleリスト。database role以外。[ {name: <role_name>, comment: <comment>},... ]"
}

variable "grant_database_to_access_db_role" {
  type        = list(any)
  description = "grant on ○○ を付与する Access role(database roleのみ) のリスト。[ {name: <name>, roles: [<role_name>], type: SCHEMA/FUTURE_TABLE/WAREHOUSE/etc., parameter: <parameter>},... ]"
}

variable "grant_schema_to_access_db_role" {
  type        = list(any)
  description = "grant on ○○ を付与する Access role(database roleのみ) のリスト。[ {name: <name>, roles: [<role_name>], type: SCHEMA/FUTURE_TABLE/WAREHOUSE/etc., parameter: <parameter>},... ]"
}

variable "grant_warehouse_to_access_role" {
  type        = list(any)
  description = "grant on ○○ を付与する Access role(database role以外) のリスト。[ {name: <name>, roles: [<role_name>], type: SCHEMA/FUTURE_TABLE/WAREHOUSE/etc., parameter: <parameter>},... ]"
}

variable "grant_access_roles_to_functional_roles" {
  type        = list(any)
  description = "Access role(database role以外) を付与する Functional role のリスト。[ {functional_roles: [<role_a>, <role_b>, ...], access_role: <role_name>},... ]"
}

variable "grant_access_db_roles_to_functional_roles" {
  type        = list(any)
  description = "Access role(database roleのみ) を付与する Functional role のリスト。[ {functional_roles: [<role_a>, <role_b>, ...], access_role: <role_name>},... ]"
}

variable "grant_functional_roles_to_user" {
  type        = list(any)
  description = "Functional role を付与するユーザーのリスト。[ {users: [<user_1>, <user_2, ...], role_name: <role_name>},... ]"
}