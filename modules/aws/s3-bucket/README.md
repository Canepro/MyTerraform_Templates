# AWS S3 Bucket Module

## Cost
**Free tier: 5GB storage** ✅ See [COST.md](./COST.md)

## How to Use
```hcl
module "s3" {
  source = "../../modules/aws/s3-bucket"
  bucket_name = "my-app-bucket-12345"
  tags = { environment = "dev" }
}
```

