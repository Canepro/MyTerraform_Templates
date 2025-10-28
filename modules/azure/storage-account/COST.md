# Cost Information: Azure Storage Account

## Cost Category: **Pay-as-you-go with Free Tier** ⚠️

Azure Storage Accounts have usage-based costs but include a generous free tier suitable for sandbox and light development use.

## Free Tier (Monthly)

✅ **Always Available** (not just 12-month free trial):

| Component | Free Allowance |
|-----------|---------------|
| LRS Blob Storage (Hot) | First 5 GB |
| Data Egress | First 5 GB |
| Write Operations | First 10,000 |
| List Operations | First 10,000 |
| Read Operations | First 10,000 |

## Cost Breakdown (Pay-as-you-go)

### Storage Costs (per GB/month)

**Hot Tier** (Frequently accessed data):
| Replication | First 50 TB | 50-500 TB | 500+ TB |
|-------------|-------------|-----------|---------|
| LRS | $0.0184 | $0.0177 | $0.0170 |
| ZRS | $0.023 | $0.022 | $0.021 |
| GRS | $0.0368 | $0.0354 | $0.0340 |
| GZRS | $0.046 | $0.044 | $0.042 |

**Cool Tier** (Infrequently accessed, 30-day minimum):
| Replication | Cost per GB/month |
|-------------|-------------------|
| LRS | $0.01 |
| GRS | $0.02 |

**Archive Tier** (Rarely accessed, 180-day minimum):
- LRS: $0.002/GB per month (cheapest, but high retrieval cost and delay)

### Transaction Costs (per 10,000 operations)

| Operation Type | Hot LRS | Cool LRS |
|----------------|---------|----------|
| Write | $0.055 | $0.10 |
| Read | $0.0044 | $0.01 |
| Other | $0.0044 | $0.01 |

### Data Transfer (Egress)

| Amount | Cost |
|--------|------|
| First 5 GB/month | Free |
| 5 GB - 10 TB | $0.087/GB |
| 10 - 50 TB | $0.083/GB |
| 50+ TB | $0.070/GB |

**Ingress (uploading data)**: Always free ✅

## Cost Optimization Strategies

### For Sandbox/Development (Stay Free)

✅ **Recommended Configuration**:
```hcl
account_tier             = "Standard"  # Default
account_replication_type = "LRS"       # Default, cheapest
access_tier              = "Hot"       # Default
```

**Stay under free limits**:
- Keep total storage under 5 GB
- Limit data downloads to 5 GB/month
- Use for testing, CI/CD artifacts, small datasets

**Estimated Monthly Cost**: $0.00 (if within limits)

### For Production (Cost-Conscious)

**Small Production Workload (10 GB data, 100K operations)**:
```
Storage: 10 GB × $0.0184 = $0.184
Operations: 100K / 10K × $0.0044 = $0.044
Egress: ~1 GB × $0.087 = $0.087
------------------------------------------
Total: ~$0.32/month
```

**Medium Production (100 GB data, 1M operations)**:
```
Storage: 100 GB × $0.0184 = $1.84
Operations: 1M / 10K × $0.0044 = $0.44
Egress: ~10 GB × $0.087 = $0.87
------------------------------------------
Total: ~$3.15/month
```

### Cost Reduction Tips

1. **Use Cool tier for backups**: ~50% cheaper storage ($0.01 vs $0.0184)
2. **Enable lifecycle management**: Auto-move old data to Cool/Archive
3. **Stick with LRS**: Unless you need geo-redundancy (GRS is 2x cost)
4. **Monitor egress**: Download only when needed
5. **Delete unused data**: Storage costs are ongoing

## Cost Safety for Sandbox

✅ **Safe for Sandbox** - As long as you:
- Keep storage under 5 GB
- Limit external data transfers to 5 GB/month
- Don't enable expensive features (versioning increases storage)

⚠️ **Potential Cost Risks**:
- Uploading large files (>5GB) and keeping them
- High egress (downloading data repeatedly)
- Enabling geo-redundancy (GRS/GZRS)
- Archive tier has high retrieval costs

## Monitoring and Alerts

Set up Azure Cost Management alerts:
```bash
# Alert if storage account costs exceed $1/month
az monitor metrics alert create \
  --name storage-cost-alert \
  --resource-group rg-myapp-sandbox \
  --condition "total cost > 1"
```

## References

- [Azure Storage Pricing](https://azure.microsoft.com/en-us/pricing/details/storage/blobs/)
- [Azure Free Account](https://azure.microsoft.com/en-us/free/)
- [Storage Cost Optimization](https://learn.microsoft.com/en-us/azure/storage/common/storage-plan-manage-costs)

---

**Last Updated**: 2025-10-28  
**Default Module Cost**: $0.00 (within free tier) ✅  
**Production Cost**: Starting at ~$0.32/month for 10GB

