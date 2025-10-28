# Cost Information: Azure Virtual Network

## Cost Category: **Always Free** ✅

Azure Virtual Networks (VNets) are free to create and use. There is no charge for the VNet itself or for subnets.

## Cost Breakdown

| Component | Cost |
|-----------|------|
| Virtual Network | $0.00 |
| Subnets | $0.00 |
| Service Endpoints | $0.00 |
| Network Security Groups (NSGs) | $0.00 |
| Route Tables | $0.00 |
| VNet Peering (data transfer) | $0.01/GB (inter-region) |

## Free Components ✅

1. **Virtual Network**: No cost for creation or maintenance
2. **Subnets**: Create as many as needed (up to 1000 per VNet)
3. **Service Endpoints**: Free direct routes to Azure PaaS services
4. **Network Security Groups**: Free firewall rules
5. **Route Tables**: Free custom routing
6. **DNS Resolution**: Azure-provided DNS is free

## Optional Paid Add-ons ⚠️

These are **NOT included** in the base module and incur costs if added separately:

### VPN Gateway
- **Basic**: ~$27/month
- **VpnGw1**: ~$146/month
- **VpnGw2**: ~$365/month
- Use case: Site-to-site VPN, point-to-site VPN

### NAT Gateway
- **Gateway**: ~$33/month (per gateway)
- **Data processed**: $0.045/GB
- Use case: Outbound internet connectivity with static IP

### Private Endpoints
- **Per endpoint**: ~$7.30/month
- **Data processed**: $0.01/GB
- Use case: Private connectivity to Azure PaaS services

### VNet Peering
- **Intra-region**: Free ingress, $0.01/GB egress
- **Inter-region**: $0.01/GB both directions
- Use case: Connect multiple VNets

### Azure Firewall
- **Standard**: ~$1.25/hour (~$913/month) + $0.016/GB processed
- **Premium**: ~$1.75/hour (~$1,277/month) + $0.016/GB processed
- Use case: Centralized network security

### Application Gateway
- **Standard**: ~$0.125/hour (~$91/month) + data processing fees
- **WAF**: ~$0.34/hour (~$248/month) + data processing fees
- Use case: Application load balancing, WAF

## Cost Safety for Sandbox/Development

✅ **100% Safe** - As long as you:
- Use VNets and subnets only (no gateways)
- Use service endpoints instead of private endpoints
- Don't add VPN/NAT/Firewall gateways
- Avoid VNet peering between regions (or minimize data transfer)

**This module uses only free components by default.**

## Data Transfer Costs

### Within Same VNet
- **Within same subnet**: Free ✅
- **Between subnets**: Free ✅
- **Between availability zones**: $0.01/GB (minimal for most workloads)

### Between VNets (Peering)
- **Same region**: $0.01/GB
- **Different regions**: $0.01/GB both directions

### Internet Egress
- **Outbound to internet**: $0.087/GB (first 5GB free)
- **Inbound from internet**: Free ✅

## Cost Optimization Strategies

### For Sandbox/Development

✅ **Recommended**:
```hcl
module "vnet" {
  source = "../../modules/azure/virtual-network"
  
  # Default free configuration
  address_space = ["10.0.0.0/16"]
  subnets = [
    { name = "default", address_prefixes = ["10.0.1.0/24"] }
  ]
  # No gateways, no private endpoints
}
```

**Estimated Monthly Cost**: $0.00 ✅

### For Production

**Small Production (with service endpoints)**:
```
VNet: $0.00
Subnets: $0.00
Service Endpoints: $0.00
Intra-VNet traffic: $0.00
---------------------------------
Total: $0.00
```

**Medium Production (with private endpoints)**:
```
VNet: $0.00
3 Private Endpoints: 3 × $7.30 = $21.90
Data processed (10GB): 10 × $0.01 = $0.10
---------------------------------
Total: ~$22/month
```

### Cost Reduction Tips

1. **Use service endpoints instead of private endpoints**: Save ~$7/month per service
2. **Consolidate subnets**: No cost benefit, but easier to manage
3. **Avoid cross-region peering**: Use same region when possible
4. **Minimize internet egress**: Keep data within Azure

## When Costs May Occur

⚠️ You will incur costs if you:
- Add a VPN Gateway (~$27-$146/month)
- Add a NAT Gateway (~$33/month)
- Create private endpoints (~$7/month each)
- Transfer large amounts of data between regions
- Add Azure Firewall (~$913/month)

## Monitoring Costs

VNet usage appears in Azure Cost Management under:
- **Service name**: Virtual Network
- **Meter category**: Networking
- **Meter subcategory**: VPN, NAT Gateway, Private Link, etc.

Set up alerts:
```bash
az monitor metrics alert create \
  --name vnet-cost-alert \
  --resource-group rg-myapp \
  --condition "total cost > 50"
```

## Cost Comparison: Service Endpoints vs Private Endpoints

| Feature | Service Endpoint | Private Endpoint |
|---------|-----------------|------------------|
| Cost | Free | ~$7.30/month |
| Data processing | Free | $0.01/GB |
| Network isolation | Public IPs, service-level | Private IP, resource-level |
| DNS | No changes | Requires private DNS |
| Use case | Cost-conscious, service-wide | Maximum security, specific resource |

**Recommendation**: Use service endpoints for sandbox/dev, consider private endpoints for production if security requires.

## References

- [VNet Pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-network/)
- [Bandwidth Pricing](https://azure.microsoft.com/en-us/pricing/details/bandwidth/)
- [Private Link Pricing](https://azure.microsoft.com/en-us/pricing/details/private-link/)
- [VPN Gateway Pricing](https://azure.microsoft.com/en-us/pricing/details/vpn-gateway/)

---

**Last Updated**: 2025-10-28  
**Module Default Cost**: $0.00 (always free) ✅  
**Optional Add-ons**: VPN Gateway ($27+), NAT Gateway ($33+), Private Endpoints ($7+ each)

