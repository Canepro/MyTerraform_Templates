# Cost Information: Azure AKS Cluster

## Cost Category: **Pay-as-you-go** ⚠️⚠️

AKS has significant costs - NOT recommended for sandbox use!

## Minimum Cost (1 node, Standard_B2s)

```
AKS Control Plane: FREE ✅
Node VM (B2s): ~$30.37/month
OS Disk (30GB): ~$1.54/month
Load Balancer: ~$18.40/month
Public IP: ~$3.65/month
Bandwidth: ~$5-20/month
─────────────────────────────
Total: ~$60-75/month ⚠️⚠️
```

## Cost Optimization

1. **Use Standard_B2s nodes** (cheapest: ~$30/month)
2. **Start with 1 node** for dev/test
3. **Delete when not in use** - Shut down entire cluster
4. **Use auto-scaling** - Scale to 0 when idle (if supported)

## Alternatives

For development:
- ✅ **Minikube/Kind** - Free local K8s
- ✅ **Azure Container Apps** - ~$0-5/month with scale-to-zero
- ✅ **Docker Compose** - Free local development

## References

- [AKS Pricing](https://azure.microsoft.com/en-us/pricing/details/kubernetes-service/)

---

**Default Module Cost**: ~$73/month (1 node) ⚠️⚠️  
**Recommendation**: Use only for production, not sandbox

