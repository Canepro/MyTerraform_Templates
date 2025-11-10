# Cost Information: Azure Linux Virtual Machine

## Cost Category: **Pay-as-you-go** ⚠️

Azure Virtual Machines incur hourly costs. Always enable auto-shutdown for dev/test environments!

## Cost Breakdown

### Compute (per month, always-on)

| VM Size | vCPU | RAM | Cost (East US) | Use Case |
|---------|------|-----|----------------|----------|
| **Standard_B1s** | 1 | 1 GB | **~$7.59** | Dev/test, minimal workloads (dev profile) |
| Standard_B1ms | 1 | 2 GB | ~$15.18 | Light workloads |
| Standard_B2ms | 2 | 8 GB | ~$60.74 | Memory-intensive (training profile) |
| Standard_D2s_v3 | 2 | 8 GB | ~$96.36 | Production workloads (prod profile) |

**Environment Defaults**
- `dev`: Standard_B1s (~$7.59/month)
- `training`: Standard_B2ms (~$60.74/month)
- `prod`: Standard_D2s_v3 (~$96.36/month)

### Storage (per month)

| Disk Type | Size | Cost | Performance |
|-----------|------|------|-------------|
| **Standard HDD** (LRS) | 30 GB | **~$1.54** | 500 IOPS |
| Standard HDD (LRS) | 50 GB | ~$2.56 | 500 IOPS |
| Standard HDD (LRS) | 100 GB | ~$5.12 | 500 IOPS |
| Standard SSD (LRS) | 30 GB | ~$4.81 | 500 IOPS |
| Premium SSD (LRS) | 32 GB | ~$4.93 | 120 IOPS |

**Environment Defaults**
- `dev`: Standard HDD 30 GB (~$1.54/month)
- `training`: Standard HDD 50 GB (~$2.56/month)
- `prod`: Standard HDD 100 GB (~$5.12/month)

### Network

| Component | Cost |
|-----------|------|
| Private IP | Free ✅ |
| Public IP (Standard) | ~$3.65/month |
| Inbound data transfer | Free ✅ |
| Outbound data transfer | First 5 GB free, then $0.087/GB |

**Default Module Setting**: Standard public IP attached (disable with `enable_public_ip = false`)

## Total Monthly Costs

### Default Training Profile (Always-On)
```
VM: Standard_B2ms        $60.74
Storage: 50 GB HDD        $2.56
Public IP: Standard       $3.65
─────────────────────────────
Total:                  ~$66.95/month
```

### Dev Profile (Always-On)
```
VM: Standard_B1s         $7.59
Storage: 30 GB HDD       $1.54
Public IP: Standard      $3.65
─────────────────────────────
Total:                  ~$12.78/month
```

### Prod Profile (Always-On)
```
VM: Standard_D2s_v3      $96.36
Storage: 100 GB HDD       $5.12
Public IP: Standard       $3.65
─────────────────────────────
Total:                 ~$105.13/month
```

## Cost Optimization Strategies

### 1. Enable Auto-Shutdown ⭐ (Biggest Savings)

**Scenario**: Dev VM runs 8 hours/day, shutdown 16 hours
- **Standard_B1s**: $7.59/month → **$2.53/month** (67% savings!)
- **Standard_B2ms**: $60.74/month → **$20.25/month** (67% savings!)

```hcl
enable_auto_shutdown = true
auto_shutdown_hours  = 4  # shuts down about 4 hours after apply
```

### 2. Use B-Series VMs

B-series VMs are **burstable** and cost far less than D-series:
- Standard_B2ms: $60.74/month
- Standard_D2s_v3: $96.36/month
- **Savings**: ~$35/month (36% cheaper)

### 3. Use Standard HDD Storage

For non-production workloads:
- Standard HDD: $1.54/month
- Standard SSD: $4.81/month
- **Savings**: $3.27/month (68% cheaper)

### 4. Azure Hybrid Benefit

If you have Windows Server licenses, get up to 40% discount.

### 5. Reserved Instances (1-3 years)

Commit to 1 or 3 years for up to 72% savings:
- Standard_B1s (1 year): $7.59 → $4.94/month (35% off)
- Standard_B1s (3 years): $7.59 → $3.22/month (58% off)

### 6. Spot VMs (90% discount!)

For interruptible workloads:
- Standard_B2ms: $60.74 → ~$6/month (90% off)
- ⚠️ Can be evicted with 30-second notice

## Cost Safety for Sandbox

⚠️ **NOT SAFE** for always-on sandbox use (training defaults ≈ $67/month)

✅ **Cost-Safe Strategies**:

1. **Manual start/stop**: Only run when needed
   ```bash
   # Start VM
   az vm start --resource-group rg-myapp --name vm-myapp
   
   # Stop VM (deallocate to stop charges)
   az vm deallocate --resource-group rg-myapp --name vm-myapp
   ```

2. **Auto-shutdown**: Enable for automatic shutdown
```hcl
enable_auto_shutdown = true
auto_shutdown_hours  = 6
auto_shutdown_timezone = "Eastern Standard Time"
```

3. **Destroy after use**: For true sandbox testing
   ```bash
   terraform destroy
   ```

## Actual Cost Examples

### Scenario 1: Development VM (8 hours/day)
```
VM (B1s, 8h/day × 20 days):  $2.53
Storage (30 GB HDD):         $1.54
─────────────────────────────────
Total:                      ~$4/month ✅
```

### Scenario 2: Always-On Jump Box
```
VM (B1s, 24/7):             $7.59
Storage (30 GB HDD):        $1.54
Public IP:                  $3.65
─────────────────────────────────
Total:                    ~$12.78/month ⚠️
```

### Scenario 3: Production App Server
```
VM (B2ms, 24/7):           $60.74
Storage (64 GB Premium):    $9.86
Public IP:                  $3.65
Load Balancer:              $18.40
─────────────────────────────────
Total:                    ~$92.65/month ⚠️⚠️
```

## Hidden Costs to Avoid

1. **Forgot to deallocate** - Stopped VMs still incur compute costs!
   - Use `az vm deallocate`, not just `az vm stop`

2. **Orphaned disks** - Deleting VM doesn't delete disk
   - Delete associated disks manually

3. **Public IPs** - Add $3.65/month even if unused
   - Only enable when needed

4. **Outbound bandwidth** - First 5 GB free, then $0.087/GB
   - Monitor data transfer

5. **Snapshots** - $0.05/GB/month
   - Delete old snapshots

## Monitoring Costs

Set up cost alerts:

```bash
# Check current VM cost
az consumption usage list \
  --start-date 2025-10-01 \
  --end-date 2025-10-31

# Set up cost alert
az monitor metrics alert create \
  --name vm-cost-alert \
  --resource-group rg-myapp \
  --condition "total Percentage CPU > 80"
```

## Free Alternatives

❌ **No free tier for VMs**

Alternatives:
- ✅ **Azure App Service** - F1 tier free (10 apps)
- ✅ **Azure Container Apps** - 180,000 vCPU-seconds free/month
- ✅ **Azure Functions** - 1M executions free/month
- ✅ **GitHub Codespaces** - 60 hours free/month for personal use

## Cost Comparison: VMs vs Alternatives

| Service | Cost | Use Case |
|---------|------|----------|
| VM (B2ms, always-on) | ~$67/month | Full control, SSH access |
| App Service (F1) | $0/month | Web apps only |
| Container Apps | ~$0-5/month | Containers, scale-to-zero |
| Azure Functions | ~$0/month | Event-driven, serverless |

## Best Practices for Cost Control

1. ✅ **Enable auto-shutdown** for dev/test
2. ✅ **Deallocate** VMs when not in use
3. ✅ **Use B-series** for burstable workloads
4. ✅ **Start small** (B1s) and scale up if needed
5. ✅ **Delete unused resources** (disks, NICs, public IPs)
6. ✅ **Set up cost alerts** in Azure Cost Management
7. ✅ **Consider alternatives** (App Service, Container Apps)

## References

- [VM Pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/)
- [Reserved Instances](https://azure.microsoft.com/en-us/pricing/reserved-vm-instances/)
- [Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/)

---

**Last Updated**: 2025-11-10  
**Training Profile Cost (always-on)**: ~$66.95/month ⚠️  
**Dev Profile with Auto-Shutdown (8h/day)**: ~$7.72/month ✅  
**Recommendation**: Keep auto-shutdown enabled or deallocate when idle

