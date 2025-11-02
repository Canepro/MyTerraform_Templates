# Cost Information: AWS EC2 Instance

## Cost Category: **Pay-as-you-go** ⚠️

EC2 instances have hourly costs - use free tier or stop when not in use!

## Free Tier (First 12 Months)

```
t2.micro (Linux):    750 hours/month FREE ✅
t3.micro (Linux):    Not in free tier
EBS Storage:         30 GB FREE (gp2 or gp3)
Data Transfer Out:   1 GB FREE
────────────────────────────────────────
Total: $0.00 (within free tier limits) ✅
```

## After Free Tier (us-east-1 pricing)

### t3.micro (Default)
```
Instance:            $0.0104/hour = ~$7.59/month
EBS gp3 (30GB):      $0.08/GB/month = ~$2.40/month
Data Transfer:       $0.09/GB (first 10TB)
────────────────────────────────────────
Total: ~$9.99/month ⚠️
```

### t4g.nano (Cheapest ARM)
```
Instance:            $0.0042/hour = ~$3.07/month
EBS gp3 (30GB):      $0.08/GB/month = ~$2.40/month
────────────────────────────────────────
Total: ~$5.47/month ⚠️
```

### t2.micro (Free Tier Eligible)
```
Instance:            $0.0116/hour = ~$8.47/month
EBS gp2 (30GB):      $0.10/GB/month = ~$3.00/month
────────────────────────────────────────
Total: ~$11.47/month ⚠️
```

**Note**: Amazon Linux 2023 requires minimum 30GB root volume (included in AWS free tier).

## Cost Optimization

1. **Use Free Tier**: t2.micro for first 12 months (750 hours/month)
2. **ARM Instances**: t4g.nano/micro are 20% cheaper (requires ARM-compatible AMI)
3. **Use gp3 volumes**: 20% cheaper than gp2, better performance
4. **Stop when idle**: No instance costs when stopped (only EBS storage)
5. **Spot Instances**: Up to 90% savings for fault-tolerant workloads
6. **Savings Plans**: 1-year commitment for ~30% savings

## Regional Pricing Differences

- **us-east-1** (N. Virginia): Cheapest
- **us-west-2** (Oregon): ~5% more
- **eu-west-1** (Ireland): ~10-15% more
- **ap-southeast-1** (Singapore): ~15-20% more

## Cost Comparison: EC2 vs Alternatives

- **AWS Lightsail**: $3.50/month (512MB RAM, 1vCPU, 20GB SSD) ✅
- **AWS Lambda**: Free tier 1M requests/month, then $0.20/1M ✅
- **ECS Fargate**: ~$14/month (0.25 vCPU, 0.5GB, always on) ⚠️

## Alternatives for Development

- ✅ **AWS Cloud9** - Free EC2 instance (auto-stops after 30 min idle)
- ✅ **AWS CloudShell** - Free browser-based shell
- ✅ **Local development** - Docker/Vagrant on your machine

## References

- [EC2 Pricing](https://aws.amazon.com/ec2/pricing/)
- [Free Tier](https://aws.amazon.com/free/)
- [AWS Pricing Calculator](https://calculator.aws/)

---

**Default Module Cost**: ~$8.23/month (t3.micro) ⚠️  
**Free Tier**: $0.00 (t2.micro, first 12 months) ✅  
**Recommendation**: Use t2.micro with auto-stop for dev/test
