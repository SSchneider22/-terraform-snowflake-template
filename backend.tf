terraform {
  backend "s3" {
    bucket         = "sagara-terraform-state-bucket"
    key            = "snowflake-state/snowflake.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "sagara-terraform-state-lock-table"
    encrypt        = true
  }
}