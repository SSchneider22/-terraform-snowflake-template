resource "snowflake_user" "this" {
  name         = var.name
  login_name   = var.login_name
  comment      = var.comment
  password     = var.password
  disabled     = var.disabled
  display_name = var.display_name
  email        = var.email
  first_name   = var.first_name
  last_name    = var.last_name

  default_warehouse       = var.default_warehouse
  default_secondary_roles = var.default_secondary_roles
  default_role            = var.default_role

  rsa_public_key   = var.rsa_public_key
  rsa_public_key_2 = var.rsa_public_key_2

  must_change_password = var.must_change_password
}