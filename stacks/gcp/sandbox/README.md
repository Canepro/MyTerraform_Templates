# GCP Sandbox Stack

A complete Terraform stack demonstrating GCP modules in a safe, cost-conscious sandbox environment.

## 🎯 Perfect for Beginners!

This is your **first GCP deployment** - a safe, free way to learn Terraform and Google Cloud infrastructure!

**What you'll learn:**
- ✅ How to deploy GCP infrastructure with code
- ✅ How to use Terraform modules (VPC, Storage)
- ✅ How to manage cloud resources safely
- ✅ How to clean up when done

**Don't worry!** This guide assumes no prior knowledge. If you get stuck, check the [Getting Started Guide](../../../docs/GETTING_STARTED.md).

## Overview

This stack creates:
- ✅ **Virtual Private Cloud (VPC)** network (Always Free)
- ✅ **Cloud Storage Bucket** with encryption (Free tier: 5GB)
- ✅ **Firewall Rule** for SSH access (Always Free)
- ✅ **Internal Firewall** for VPC communication (Always Free)

**Estimated Cost**: $0.00/month (within free tier limits)

**Time to Deploy**: ~3 minutes  
**Difficulty**: ⭐ Easy

## Architecture

```
VPC Network
├── Subnet (10.0.1.0/24) in us-central1
├── Firewall: Allow internal VPC traffic
├── Firewall: Allow SSH from internet
└── Cloud Storage Bucket (encrypted)
```

## Prerequisites

**Don't have these installed?** Follow the [GCP Setup Guide](../../../docs/gcp-setup-guide.md) or [Getting Started Guide](../../../docs/GETTING_STARTED.md#gcp-beginner-guide) for step-by-step installation instructions.

### Required Tools

1. **Google Cloud SDK** installed and configured:
   ```bash
   gcloud --version
   # Should show: Google Cloud SDK X.X.X
   
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```
   **Need to install?** See [Cloud SDK Installation Guide](https://cloud.google.com/sdk/docs/install)

2. **Terraform** >= 1.5.0:
   ```bash
   terraform version
   ```
   **Need to install?** See [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)

3. **GCP Project** with billing enabled:
   - **Don't have one?** Sign up for free at [cloud.google.com](https://cloud.google.com) (get $300 free credit!)

## Quick Start

**Follow these steps in order!** Each step builds on the previous one.

### Step 1: Clone the Repository

First, get the code onto your computer:

```bash
# Clone the repository
git clone https://github.com/Canepro/MyTerraform_Templates.git

# Navigate into the project
cd MyTerraform_Templates/stacks/gcp/sandbox
```

### Step 2: Configure GCP Authentication

```bash
# Log in to GCP
gcloud auth login

# Set your project
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# Or use Application Default Credentials
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
```

**For detailed authentication setup**, see [GCP Setup Guide](../../../docs/gcp-setup-guide.md#service-account--authentication).

### Step 3: Configure Variables

Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

**Open `terraform.tfvars` in a text editor** and set your project ID:

**On Windows:**
```powershell
notepad terraform.tfvars
```

**On Mac/Linux:**
```bash
nano terraform.tfvars
```

Edit it to look like this:
```hcl
project_id   = "my-terraform-project"  # Your actual GCP project ID
prefix       = "myapp"                 # Change to something unique
environment  = "sandbox"
region       = "us-central1"
cost_center  = "learning"
```

**💡 Tip**: Use your name or project name for the prefix!

### Step 4: Initialize Terraform

This downloads the Terraform Google provider and prepares your directory.

```bash
terraform init
```

**Expected output:**
```
Initializing modules...
Initializing provider plugins...
Terraform has been successfully initialized!
```

**✅ If you see this, you're ready to proceed!**

### Step 5: Review the Plan

**Always run this before deploying!** It shows what Terraform will create without actually creating it.

```bash
terraform plan
```

**Expected output:**
```
Plan: 5 to add, 0 to change, 0 to destroy.
  + module.vpc (VPC network with subnets, firewalls)
  + module.storage_bucket (Cloud Storage bucket)
  + random_id.suffix
```

**💡 Review carefully**: Make sure it shows VPC network and storage bucket being created!

### Step 6: Deploy Your Infrastructure

**This creates real resources in GCP!** 

```bash
terraform apply
```

**Terraform will ask:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

**Type `yes` and press Enter.**

**Wait 2-3 minutes** - Terraform is creating your resources!

### Step 7: Verify Deployment

**Check that everything worked:**

```bash
# View Terraform outputs
terraform output

# Check resources in GCP
gcloud compute networks list
gcloud compute subnets list
gsutil ls
```

**🎉 Congratulations! You just deployed your first GCP infrastructure with Terraform!**

**Want to see it in the Cloud Console?**
1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Navigate to VPC Network or Cloud Storage
3. Look for resources with your prefix name

### Step 8: Clean Up (IMPORTANT!)

**Always destroy resources when you're done** to avoid charges and learn proper cleanup.

```bash
terraform destroy
```

**Terraform will show you what will be deleted:**
```
Plan: 0 to add, 0 to change, 5 to destroy.

Do you really want to destroy all resources?
  Enter a value:
```

**Type `yes` and press Enter.**

**✅ All resources deleted** - No charges incurred!

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| project_id | GCP Project ID | - | **Yes** |
| prefix | Resource name prefix | "demo" | No |
| environment | Environment (must be "sandbox") | "sandbox" | No |
| suffix | Optional suffix | "" | No |
| region | GCP region | "us-central1" | No |

### Customization Examples

**Different region**:
```hcl
region = "us-east1"  # South Carolina
```

**Multiple subnets**:
```hcl
subnets = [
  { name = "subnet-1", cidr = "10.0.1.0/24", region = "us-central1" },
  { name = "subnet-2", cidr = "10.0.2.0/24", region = "us-west1" }
]
```

## Cost Considerations

### Free Tier Usage

This stack stays within GCP free tier:
- ✅ VPC and networking: Always free
- ✅ Cloud Storage: Free for first 5GB
- ✅ Firewall rules: Always free
- ✅ Data transfer: 100GB/month free

### Free Trial

**New GCP accounts get $300 free credit for 90 days** - perfect for learning!

### Staying Free

To avoid charges:
1. **Storage**: Keep data under 5GB
2. **Data Transfer**: Stay under 100GB/month free tier
3. **No Compute**: This stack doesn't create VMs (no compute costs)

### Cost Alerts

Set up billing alerts in GCP:
```bash
# Create budget alert
gcloud billing budgets create \
  --billing-account=$(gcloud beta billing accounts list --format='value(name)' --limit=1) \
  --display-name='Sandbox-Budget' \
  --budget-amount='5USD' \
  --threshold-percent='80,100'
```

## Common Issues & Troubleshooting

**Getting stuck?** This section covers the most common problems beginners face.

### ❌ Issue: Project not found

**Error message:**
```
Error: project "my-project" not found
```

**Solutions:**
1. Verify project exists: `gcloud projects list`
2. Set correct project: `gcloud config set project YOUR_PROJECT_ID`
3. Check you have access to the project

### ❌ Issue: API not enabled

**Error message:**
```
Error 403: API has not been used in project
```

**Solutions:**
1. Enable required APIs:
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable storage-component.googleapis.com
   ```
2. Wait a few minutes for APIs to activate

### ❌ Issue: Not authenticated

**Error message:**
```
Error 401: Invalid authentication credentials
```

**Solutions:**
1. Log in: `gcloud auth login`
2. Set application credentials:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/key.json"
   ```
3. Test: `gcloud auth list`

### ✅ General Troubleshooting Steps

**If nothing above works:**

1. **Read the error message** carefully
2. **Check GCP auth**: Run `gcloud auth list`
3. **Verify project**: Run `gcloud config get-value project`
4. **Destroy and retry**:
   ```bash
   terraform destroy
   terraform apply
   ```
5. **Ask for help**: [Open an issue](../../../issues) with your error

### 📞 Still Need Help?

- [Check Getting Started Guide](../../../docs/GETTING_STARTED.md)
- [Read GCP Setup Guide](../../../docs/gcp-setup-guide.md)
- [Read Tutorials](../../../docs/TUTORIALS.md)
- [Open a GitHub Issue](../../../issues)
- [Start a Discussion](../../../discussions)

## Next Steps

Now that you've deployed basic infrastructure:

1. **Explore Modules**: Check out other GCP modules
2. **Create Compute Instance**: Deploy a VM
3. **Add More Subnets**: Extend your network
4. **Practice**: Deploy and destroy multiple times

## References

- [GCP Free Tier](https://cloud.google.com/free/docs/gcp-free-tier)
- [VPC Documentation](https://cloud.google.com/vpc/docs)
- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

---

**Happy Learning!** 🚀

For more examples, check out [GCP Setup Guide](../../../docs/gcp-setup-guide.md) or [Tutorials](../../../docs/TUTORIALS.md).

