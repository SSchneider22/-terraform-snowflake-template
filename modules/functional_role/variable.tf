variable "role_name" {
  description = "Name of the functional role"
  type        = string
  default     = null
}

variable "comment" {
  description = "Write description for the functional role"
  type        = string
  default     = null
}

variable "grant_user_set" {
  description = "Set of user for grant functional role"
  type        = set(string)
  default     = []
}