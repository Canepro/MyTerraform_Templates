# AWS IAM User Module

## Cost
**Always Free** ✅ See [COST.md](./COST.md)

## How to Use
```hcl
module "iam_user" {
  source = "../../modules/aws/iam-user"
  user_name = "app-user"
  policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}
```

