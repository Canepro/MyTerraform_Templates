# Azure App Service Module

Terraform module for Azure App Service (Linux) with F1 free tier support.

## Cost

**F1 Free Tier Available** ✅ - Up to 10 free apps!

See [COST.md](./COST.md) for details.

## How to Use

```hcl
module "app_service" {
  source = "../../modules/azure/app-service"

  name                = "app-myapp-dev"
  resource_group_name = "rg-myapp-dev"
  location            = "eastus"
  
  sku_name = "F1"  # Free tier
  
  application_stack = {
    node_version = "18-lts"
  }
  
  app_settings = {
    "NODE_ENV" = "production"
  }
  
  tags = {
    environment = "dev"
  }
}
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| name | App name (globally unique) | required |
| resource_group_name | Resource group | required |
| sku_name | F1, B1, S1, etc | F1 |
| application_stack | Runtime (node, python, etc) | null |
| app_settings | Environment variables | {} |

## Outputs

| Name | Description |
|------|-------------|
| default_hostname | App URL |
| outbound_ip_addresses | Outbound IPs |

See full documentation for all options.

