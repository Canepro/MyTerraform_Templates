# ============================================
# VPC Outputs
# ============================================
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

# ============================================
# Subnet Outputs
# ============================================
output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

# ============================================
# NAT Gateway Outputs
# ============================================
output "nat_gateway_ids" {
  description = "IDs of NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "Public IPs of NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

# ============================================
# Route Table Outputs
# ============================================
output "public_route_table_id" {
  description = "ID of public route table"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_ids" {
  description = "IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

# ============================================
# Quick Reference
# ============================================
output "deployment_info" {
  description = "Quick reference for your VPC deployment"
  value = {
    vpc_id              = module.vpc.vpc_id
    region              = var.aws_region
    environment         = var.environment
    public_subnets      = length(module.vpc.public_subnet_ids)
    private_subnets     = length(module.vpc.private_subnet_ids)
    nat_gateways        = length(module.vpc.nat_gateway_ids)
    flow_logs_enabled   = var.enable_flow_logs
    s3_endpoint_enabled = var.enable_s3_endpoint
  }
}

