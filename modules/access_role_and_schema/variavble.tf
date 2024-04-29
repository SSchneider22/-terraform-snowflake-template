variable "schema_name" {
  description = "Name of the schema"
  type        = string
  default     = null
}

variable "database_name" {
  description = "Name of the database to which the Schema belongs"
  type        = string
  default     = null
}

variable "comment" {
  description = "Write description for the schema"
  type        = string
  default     = null
}

variable "data_retention_days" {
  description = "Time travelable period to be set for the entire schema."
  type        = number
  default     = null
}

variable "is_managed" {
  description = "Specifies a managed schema."
  type        = bool
  default     = false
}

variable "is_transient" {
  description = "Specifies a schema as transient."
  type        = bool
  default     = false
}

variable "grant_readonly_ar_to_fr_set" {
  description = "Set of functional role for grant read only access role"
  type        = set(string)
  default     = []
}

variable "grant_readwrite_ar_to_fr_set" {
  description = "Set of functional role for grant read/write access role"
  type        = set(string)
  default     = []
}
