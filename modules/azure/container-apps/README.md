# Azure Container Apps Module

Serverless containers with scale-to-zero capability.

## Cost

**Free Tier** ✅ - 180,000 vCPU-seconds + 360,000 GiB-seconds per month!

See [COST.md](./COST.md) for details.

## How to Use

```hcl
module "container_app" {
  source = "../../modules/azure/container-apps"

  name                = "app-myapp-dev"
  resource_group_name = "rg-myapp-dev"
  location            = "eastus"
  
  container_image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
  cpu             = 0.25
  memory          = "0.5Gi"
  
  min_replicas = 0  # Scale to zero
  max_replicas = 1
  
  tags = {
    environment = "dev"
  }
}
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| name | App name | required |
| container_image | Container image | required |
| cpu | CPU (0.25-4.0) | 0.25 |
| memory | Memory (0.5Gi-8Gi) | 0.5Gi |
| min_replicas | Min (0=scale-to-zero) | 0 |
| max_replicas | Max replicas | 1 |

## Outputs

| Name | Description |
|------|-------------|
| fqdn | App URL (if ingress enabled) |

See full documentation.

