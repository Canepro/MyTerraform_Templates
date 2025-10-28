# Azure AKS Cluster Module

Terraform module for Azure Kubernetes Service (AKS) with cost-optimized defaults.

## Cost

**~$73/month minimum** for 1-node cluster with Standard_B2s ⚠️

See [COST.md](./COST.md) for details.

## How to Use

```hcl
module "aks" {
  source = "../../modules/azure/aks-cluster"

  name                = "aks-myapp-dev"
  resource_group_name = "rg-myapp-dev"
  location            = "eastus"
  vnet_subnet_id      = azurerm_subnet.aks.id
  
  node_count  = 1
  node_vm_size = "Standard_B2s"
  
  tags = {
    environment = "dev"
  }
}
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| name | AKS cluster name | required |
| resource_group_name | Resource group | required |
| vnet_subnet_id | Subnet ID | required |
| node_count | Number of nodes | 1 |
| node_vm_size | VM size | Standard_B2s |
| kubernetes_version | K8s version | latest stable |

## Outputs

| Name | Description |
|------|-------------|
| id | AKS cluster ID |
| fqdn | Cluster FQDN |
| kube_config | kubeconfig (sensitive) |

See [README](./README.md) for full documentation.

