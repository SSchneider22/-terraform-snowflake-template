locals {

  ########################
  # ロール
  ########################

  # 設定ファイルをロード
  access_roles_yml = yamldecode(
    file("${path.root}/yaml/roles/access_roles.yml")
  )

  functional_roles_yml = yamldecode(
    file("${path.root}/yaml/roles/functional_roles.yml")
  )

  access_roles_to_functional_roles_yml = yamldecode(
    file("${path.root}/yaml/roles/access_roles_to_functional_roles.yml")
  )

  # Access role(database role以外) のリスト
  # access_roles = flatten(local.access_roles_yml["access_roles"])
  access_roles = local.access_roles_yml.access_roles

  # Access role(database roleのみ) のリスト
  access_db_roles = local.access_roles_yml.access_db_roles

  # grant ... on objects to Access role のリスト
  grant_on_object_to_access_role = flatten(local.access_roles_yml["grant_on_object_to_access_role"])

  # Functional roleのリスト
  # functional_roles = local.functional_roles_yml["functional_roles"]
  functional_roles = local.functional_roles_yml.functional_roles

  # grant Functional role to ユーザーのリスト
  grant_functional_roles_to_user = flatten(local.functional_roles_yml["grant_functional_roles_to_user"])

  # grant Access role to Functional role のリスト
  grant_access_role_to_functional_role = flatten(local.access_roles_to_functional_roles_yml["grant_access_roles_to_functional_roles"])
}