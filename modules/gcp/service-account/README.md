# GCP Service Account Module

## Cost
**Always Free** ✅ See [COST.md](./COST.md)

## How to Use
```hcl
module "sa" {
  source = "../../modules/gcp/service-account"
  account_id = "my-app-sa"
  display_name = "My App Service Account"
  project_id = "my-project"
  project_roles = ["roles/storage.objectViewer"]
}
```

