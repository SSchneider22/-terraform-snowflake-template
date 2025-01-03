terraform {
  required_providers {
    snowflake = {
      source  = "snowflake-labs/snowflake"
      version = "~> 0.88"
    }
  }
}

provider "snowflake" { # 事前にSYSADMINとSCURITYADMINをGRANTしたロール。
  alias = "terraform"
  role  = "TERRAFORM"
}

provider "snowflake" {
  alias = "sys_admin"
  role  = "SYSADMIN"
}

provider "snowflake" {
  alias = "security_admin"
  role  = "SECURITYADMIN"
}