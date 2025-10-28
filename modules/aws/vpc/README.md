# AWS VPC Module

## Cost
**Always Free** ✅ See [COST.md](./COST.md)

## How to Use
```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  name = "my-vpc"
  cidr_block = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}
```

