# GCP Storage Bucket Module

## Cost
**Free tier: 5GB storage** ✅ See [COST.md](./COST.md)

## How to Use
```hcl
module "bucket" {
  source = "../../modules/gcp/storage-bucket"
  bucket_name = "my-app-bucket-12345"
  location = "US"
  labels = { environment = "dev" }
}
```

