locals {
  # Standard tags that should be applied to all resources
  standard_tags = {
    environment  = var.environment
    managed_by   = var.managed_by
    cost_center  = var.cost_center
    created_date = formatdate("YYYY-MM-DD", timestamp())
  }

  # Merge standard tags with any custom tags provided
  # Custom tags take precedence in case of conflicts
  merged_tags = merge(local.standard_tags, var.custom_tags)
}

