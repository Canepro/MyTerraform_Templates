variable "account_id" {
  description = "Service account ID"
  type        = string
}

variable "display_name" {
  description = "Display name"
  type        = string
  default     = ""
}

variable "description" {
  description = "Description"
  type        = string
  default     = ""
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "project_roles" {
  description = "IAM roles to assign"
  type        = list(string)
  default     = []
}

variable "create_key" {
  description = "Create service account key"
  type        = bool
  default     = false
}

