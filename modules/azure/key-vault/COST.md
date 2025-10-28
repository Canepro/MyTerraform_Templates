# Cost Information: Azure Key Vault

## Cost Category: **Free Tier Available** ⚠️

Azure Key Vault has a generous free tier suitable for development and moderate production use.

## Free Tier

✅ **First 10,000 operations/month per vault** (always free, not just 12-month trial)

Operations include:
- Secret get/set/delete
- Key encrypt/decrypt/sign
- Certificate operations

## Cost Breakdown

### Standard SKU (Default)

| Operation | Free Tier | After Free Tier |
|-----------|-----------|-----------------|
| Secret operations | 10,000/month | $0.03 per 10,000 ops |
| Key operations | 10,000/month | $0.03 per 10,000 ops |
| Certificate operations | 10,000/month | $0.03 per 10,000 ops |
| Advanced secret operations | 10,000/month | $0.03 per 10,000 ops |

**Vault Creation**: Free (no cost for the vault itself)

### Premium SKU

Adds HSM-backed key support:
- **HSM-protected keys**: ~$1.00 per key per month
- All other costs same as Standard

## Cost Optimization Strategies

### For Sandbox/Development

✅ **Recommended Configuration**:
```hcl
sku_name                 = "standard"  # Default, cheapest
soft_delete_retention_days = 7          # Minimum retention
purge_protection_enabled = false       # Not needed for dev
```

**Estimated Cost**: $0.00/month (if <10K operations)

### For Production

**Small Production (100K ops/month)**:
```
Vault: $0.00
Operations: 90K paid × $0.03/10K = $0.27
--------------------------------
Total: ~$0.30/month
```

**Medium Production (1M ops/month)**:
```
Vault: $0.00
Operations: 990K paid × $0.03/10K = $2.97
--------------------------------
Total: ~$3.00/month
```

**With HSM Keys (Premium)**:
```
Vault: $0.00
Operations: ~$3.00
3 HSM keys: 3 × $1.00 = $3.00
--------------------------------
Total: ~$6.00/month
```

### Cost Reduction Tips

1. **Cache secrets** - Don't retrieve on every request
2. **Batch operations** - Group related operations
3. **Use Standard SKU** - Unless you need HSM compliance
4. **Delete unused vaults** - Even empty vaults count operations
5. **Monitor usage** - Set up cost alerts

## Cost Safety for Sandbox

✅ **Safe for Sandbox** - As long as you:
- Keep operations under 10,000/month
- Use Standard SKU (not Premium)
- Don't enable managed HSM

**Typical sandbox usage**: 100-500 operations/month (well within free tier)

⚠️ **Potential Cost Risks**:
- High-frequency secret retrievals (cache instead)
- Premium SKU with HSM keys (~$1+/month per key)
- Managed HSM (separate service, ~$1.45/hour = ~$1,050/month)

## What Counts as an Operation?

**Secret operations** (each counts as 1):
- Get/Set/List/Delete a secret
- Get secret versions
- Backup/Restore a secret

**Key operations** (each counts as 1):
- Encrypt/Decrypt data
- Sign/Verify signatures
- Wrap/Unwrap keys
- Get/Create/Update/Delete keys

**Certificate operations** (each counts as 1):
- Import/Get/List/Delete certificates
- Certificate requests
- Merge certificate

**NOT counted**:
- Vault creation
- Permission assignments
- Network rule updates

## Monitoring Costs

View operations in Azure Portal:
```bash
# Check recent operations
az monitor metrics list \
  --resource <vault-id> \
  --metric "ServiceApiHit" \
  --start-time 2025-10-01 \
  --end-time 2025-10-31

# Set up cost alert
az monitor metrics alert create \
  --name kv-cost-alert \
  --resource-group rg-myapp \
  --scopes <vault-id> \
  --condition "total ServiceApiHit > 10000" \
  --window-size 1h
```

## Comparison: Standard vs Premium

| Feature | Standard | Premium |
|---------|----------|---------|
| Software-protected keys | ✅ Free tier | ✅ Free tier |
| HSM-protected keys | ❌ Not available | ✅ ~$1/key/month |
| Operations cost | $0.03/10K | $0.03/10K |
| Use case | Most workloads | Regulatory compliance |

## Hidden Costs to Avoid

1. **Managed HSM** - Separate service, ~$1,050/month (don't use unless required)
2. **Premium SKU** - Only if you need HSM-backed keys
3. **High-frequency polling** - Cache secrets instead
4. **Unused vaults** - Delete vaults you're not using

## Cost-Effective Best Practices

1. **Use Standard SKU** - Premium only for compliance needs
2. **Enable caching** - Reduce secret retrieval frequency
3. **Set retention to 7 days** - Minimum soft delete retention
4. **Delete test vaults** - Clean up after testing
5. **Monitor operations** - Set alerts at 8,000 ops/month

## Free Tier vs Paid Examples

**Scenario 1: Small App (Sandbox)**
- 500 secret retrievals/month
- Cost: **$0.00** ✅ (within free tier)

**Scenario 2: Medium App (Production)**
- 50,000 operations/month
- Cost: 40,000 paid × $0.03/10,000 = **$0.12/month** ✅

**Scenario 3: High-Volume App**
- 500,000 operations/month
- Cost: 490,000 paid × $0.03/10,000 = **$1.47/month** ✅

**Scenario 4: With HSM (Compliance)**
- 50,000 operations/month: $0.12
- 5 HSM keys: 5 × $1.00 = $5.00
- Total: **$5.12/month** ⚠️

## References

- [Key Vault Pricing](https://azure.microsoft.com/en-us/pricing/details/key-vault/)
- [Managed HSM Pricing](https://azure.microsoft.com/en-us/pricing/details/azure-key-vault/)
- [Cost Management](https://learn.microsoft.com/en-us/azure/key-vault/general/cost-management)

---

**Last Updated**: 2025-10-28  
**Default Module Cost**: $0.00/month (within 10K free operations) ✅  
**Production Cost**: Starting at ~$0.30/month for 100K operations

