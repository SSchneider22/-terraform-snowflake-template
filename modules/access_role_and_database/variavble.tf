variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = null
}

variable "comment" {
  description = "Write description for the database"
  type        = string
  default     = null
}

variable "data_retention_time_in_days" {
  description = "Time travelable period to be set for the entire database."
  type        = number
  default     = null
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
