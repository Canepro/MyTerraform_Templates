variable "name" {
  description = "VPC name"
  type        = string
}

variable "subnets" {
  description = "Subnets to create"
  type = list(object({
    name   = string
    cidr   = string
    region = string
  }))
  default = []
}

