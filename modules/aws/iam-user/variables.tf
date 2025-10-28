variable "user_name" {
  description = "IAM user name"
  type        = string
}

variable "path" {
  description = "IAM path"
  type        = string
  default     = "/"
}

variable "policy_arns" {
  description = "Policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "create_access_key" {
  description = "Create access key"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

