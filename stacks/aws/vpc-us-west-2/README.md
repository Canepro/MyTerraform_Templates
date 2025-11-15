# AWS VPC - US West 2 Region

VPC deployment for **us-west-2** region.

## 🚀 Quick Deploy

```bash
# Navigate to this directory
cd stacks/aws/vpc-us-west-2

# Copy example config
cp terraform.tfvars.example terraform.tfvars

# Initialize and deploy
terraform init
terraform plan
terraform apply
```

## 📋 Configuration

This VPC uses a **different CIDR range** than us-east-1 to allow VPC peering if needed:

- **us-east-1**: `10.0.0.0/16`
- **us-west-2**: `10.1.0.0/16` ✅

## 🌐 Multi-Region Setup

If you're deploying in multiple regions, you can reference both VPCs:

```hcl
# In another Terraform config
data "terraform_remote_state" "vpc_east" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc_west" {
  backend = "local"
  config = {
    path = "../vpc-us-west-2/terraform.tfstate"
  }
}
```

## 🔗 VPC Peering (Optional)

To connect your us-east-1 and us-west-2 VPCs:

```hcl
resource "aws_vpc_peering_connection" "east_to_west" {
  vpc_id      = data.terraform_remote_state.vpc_east.outputs.vpc_id
  peer_vpc_id = data.terraform_remote_state.vpc_west.outputs.vpc_id
  peer_region = "us-west-2"
  auto_accept = false

  tags = {
    Name = "east-to-west-peering"
  }
}
```

## 💰 Cost

Same as single region: ~$35-40/month for dev, ~$70-80/month for prod.

## 📖 Full Documentation

See main VPC module documentation: `../vpc/README.md`

