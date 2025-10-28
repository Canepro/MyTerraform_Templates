# GCP VPC Module

## Cost
**Always Free** ✅ See [COST.md](./COST.md)

## How to Use
```hcl
module "vpc" {
  source = "../../modules/gcp/vpc"
  name = "my-vpc"
  subnets = [
    {
      name   = "subnet-1"
      cidr   = "10.0.1.0/24"
      region = "us-central1"
    }
  ]
}
```

