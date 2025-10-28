variable "bucket_name" {
  description = "Bucket name (globally unique)"
  type        = string
}

variable "location" {
  description = "Location (US, EU, ASIA, or specific region)"
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "Storage class (STANDARD, NEARLINE, COLDLINE, ARCHIVE)"
  type        = string
  default     = "STANDARD"
}

variable "enable_versioning" {
  description = "Enable versioning"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allow deletion with objects"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels"
  type        = map(string)
  default     = {}
}

