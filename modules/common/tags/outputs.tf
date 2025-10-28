output "tags" {
  description = "Merged map of standard and custom tags"
  value       = local.merged_tags
}

output "standard_tags" {
  description = "Standard tags only (before merging with custom tags)"
  value       = local.standard_tags
}

