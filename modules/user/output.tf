output "name" {
  description = "Name of the user."
  value       = var.name # snowflake_user.this.nameだとsensitiveで他moduleに渡せないため
}