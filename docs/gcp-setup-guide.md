# Google Cloud Platform Setup and Deployment Guide

Complete guide to setting up GCP and deploying resources using MyTerraform_Templates.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [GCP Account Setup](#gcp-account-setup)
3. [Google Cloud CLI Installation](#google-cloud-cli-installation)
4. [Service Account & Authentication](#service-account--authentication)
5. [Terraform Configuration](#terraform-configuration)
6. [First Deployment](#first-deployment)
7. [Verification](#verification)
8. [Cost Management](#cost-management)
9. [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting, ensure you have:

- **Google Account**: Any Gmail or Google Workspace account
- **Credit Card**: Required for $300 free credit verification
- **Terraform** >= 1.5.0: [Install Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **Google Cloud SDK**: For authentication and management

### Verify Prerequisites

```bash
# Check Terraform version
terraform version
# Output: Terraform v1.5.0+

# Check gcloud version
gcloud --version
# Output: Google Cloud SDK X.X.X

# Verify git is installed
git --version
```

## GCP Account Setup

### Step 1: Create GCP Account

1. Go to [cloud.google.com](https://cloud.google.com)
2. Click **Get Started for Free**
3. Sign in with your Google account
4. Enter **Organization name** and **Country**
5. Select **Account type**: Individual or Business
6. Enter credit card information (required, won't be charged initially)
7. Click **Start my free trial**

### Step 2: Activate Free Trial

After account creation:

1. You receive **$300 free credit** valid for 90 days
2. Sign in to [GCP Console](https://console.cloud.google.com)
3. Review billing account setup
4. Set up billing alerts

**Free Tier includes** (Always free, no expiration):
- ✅ 1 f1-micro instance per month (30 GB disk)
- ✅ 5GB Cloud Storage
- ✅ 100GB egress per month
- ✅ 1 App Engine small instance
- And more...

**Free Trial**:
- $300 credit for 90 days
- Access to all GCP services
- Auto-converts to pay-as-you-go after trial

### Step 3: Set Up Billing Alerts

```bash
# After authenticating with gcloud (see below)
gcloud beta billing budgets create \
  --billing-account=$(gcloud beta billing accounts list --format='value(name)' --limit=1) \
  --display-name='Free-Trial-Alert' \
  --budget-amount='10USD' \
  --threshold-percent='80,100' \
  --notifications-all-auth-users
```

Or in console:
1. Navigate to **Billing** → **Budgets & alerts**
2. Click **Create budget**
3. Set budget amount: $10
4. Configure thresholds: 80%, 100%
5. Add email notifications

## Google Cloud CLI Installation

### Linux (WSL/Ubuntu)

```bash
# Add Google Cloud SDK repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Install
sudo apt-get update && sudo apt-get install google-cloud-cli

# Verify
gcloud --version
```

### macOS

```bash
# Download installer
curl https://sdk.cloud.google.com | bash

# Or using Homebrew
brew install --cask google-cloud-sdk

# Restart shell
exec -l $SHELL

# Verify
gcloud --version
```

### Windows

```powershell
# Download MSI installer
# https://cloud.google.com/sdk/docs/install

# Or using winget
winget install Google.CloudSDK

# Open Cloud SDK Shell and run
gcloud init
```

## Service Account & Authentication

**Never use personal Google credentials** for Terraform. Create a service account instead.

### Step 1: Create Project

```bash
# Set project ID
export PROJECT_ID="my-terraform-project"

# Create project
gcloud projects create $PROJECT_ID --name="Terraform Project"

# Set as default project
gcloud config set project $PROJECT_ID

# Link billing account
gcloud beta billing projects link $PROJECT_ID \
  --billing-account=$(gcloud beta billing accounts list --format='value(name)' --limit=1)
```

### Step 2: Enable Required APIs

```bash
# Enable Compute Engine API
gcloud services enable compute.googleapis.com

# Enable Cloud Storage API
gcloud services enable storage-component.googleapis.com

# Enable IAM API
gcloud services enable iam.googleapis.com

# List enabled APIs
gcloud services list --enabled
```

### Step 3: Create Service Account

```bash
# Create service account
gcloud iam service-accounts create terraform-sa \
  --display-name="Terraform Service Account" \
  --description="Service account for Terraform deployments"

# Get service account email
export SA_EMAIL=$(gcloud iam service-accounts list \
  --filter="displayName:Terraform Service Account" \
  --format="value(email)")
```

### Step 4: Grant Permissions

For Terraform, grant **Editor** role (for production, use least privilege):

```bash
# Grant Editor role
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/editor"

# Also grant Service Account User for managing service accounts
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser"

# Grant Storage Admin for state management
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.admin"
```

**Editor role** includes:
- ✅ Create, modify, and delete most resources
- ✅ Cannot modify IAM permissions
- ✅ Safe for development/testing

**Production alternative**: Create custom roles with minimal permissions.

### Step 5: Create and Download Key

```bash
# Create key file
gcloud iam service-accounts keys create ~/terraform-key.json \
  --iam-account=$SA_EMAIL

# Verify
cat ~/terraform-key.json

# Secure the key file
chmod 600 ~/terraform-key.json

# Move to secure location (optional)
mkdir -p ~/.config/gcloud
mv ~/terraform-key.json ~/.config/gcloud/terraform-key.json
```

### Step 6: Authenticate with Terraform

**Option A: Environment Variable**

```bash
# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/terraform-key.json"

# Verify
echo $GOOGLE_APPLICATION_CREDENTIALS
```

**Option B: Terraform Provider Configuration**

```hcl
# In your stack main.tf
provider "google" {
  credentials = file("~/.config/gcloud/terraform-key.json")
  project     = "my-terraform-project"
  region      = "us-central1"
}
```

### Step 7: Verify Authentication

```bash
# Test authentication
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

# Verify access
gcloud projects list
gcloud iam service-accounts list
```

## Terraform Configuration

### Step 1: Clone Repository

```bash
git clone https://github.com/Canepro/MyTerraform_Templates.git
cd MyTerraform_Templates
```

### Step 2: Set Up Google Provider

GCP modules use the official HashiCorp Google provider:

```hcl
# In your stack main.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_path)
  project     = var.project_id
  region      = var.region
  
  # Optional: Specify default labels
  default_labels = {
    environment = "sandbox"
    managed_by  = "terraform"
  }
}
```

### Step 3: Choose Region

**Recommended regions** (cost-effective):

| Region | Code | Location |
|--------|------|----------|
| Iowa | us-central1 | Cheapest ✅ |
| South Carolina | us-east1 | ~5% more |
| Oregon | us-west1 | ~10% more |
| Belgium | europe-west1 | ~15% more |
| Singapore | asia-southeast1 | ~20% more |

**Set region**:
```bash
export GOOGLE_REGION=us-central1
# Or in terraform.tfvars
# region = "us-central1"
```

## First Deployment

Let's deploy a simple Cloud Storage bucket as your first deployment.

### Example: Deploy Storage Bucket Stack

1. **Create stack directory**:
```bash
mkdir -p stacks/gcp/sandbox
cd stacks/gcp/sandbox
```

2. **Create main.tf**:
```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_path)
  project     = var.project_id
  region      = var.region
}

# Storage bucket
module "storage_bucket" {
  source = "../../../modules/gcp/storage-bucket"
  
  name     = "${var.project_id}-${var.environment}"
  location = var.region
  
  # Security: encryption
  encryption = {
    default_kms_key_name = null
  }
  
  # Versioning
  versioning_enabled = true
  
  # Labels
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Outputs
output "bucket_name" {
  value = module.storage_bucket.name
}

output "bucket_url" {
  value = module.storage_bucket.url
}
```

3. **Create variables.tf**:
```hcl
variable "credentials_path" {
  description = "Path to GCP credentials JSON file"
  type        = string
  default     = "~/.config/gcloud/terraform-key.json"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "my-terraform-project"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sandbox"
}
```

4. **Initialize and deploy**:
```bash
# Initialize
terraform init

# Review plan
terraform plan

# Apply
terraform apply

# Type 'yes' when prompted
```

## Verification

### Check Deployed Resources

```bash
# List storage buckets
gsutil ls

# List compute instances
gcloud compute instances list

# List VPC networks
gcloud compute networks list

# List service accounts
gcloud iam service-accounts list

# List IAM roles
gcloud projects get-iam-policy $PROJECT_ID
```

### View Cloud Console

Navigate to [GCP Console](https://console.cloud.google.com) and:
1. Select your project
2. Browse resources in various services
3. View billing and cost information

### Terraform Outputs

```bash
# View all outputs
terraform output

# Specific output
terraform output bucket_name
```

## Cost Management

### Monitor Costs

1. **Cloud Billing Dashboard**:
   - Navigate to [Billing Dashboard](https://console.cloud.google.com/billing)
   - View cost breakdown by service
   - Check free trial credit usage

2. **Cloud Monitoring**:
```bash
# Create budget alert
gcloud billing budgets create \
  --billing-account=$(gcloud beta billing accounts list --format='value(name)' --limit=1) \
  --display-name='Sandbox-Budget' \
  --budget-amount='50USD' \
  --threshold-percent='80,100' \
  --notifications-rules='pubsubTopic=projects/$PROJECT_ID/topics/billing-alerts'
```

3. **Free Tier Alerts**:
   - Configure in Billing Dashboard
   - Get email when approaching limits

### Cost Optimization Tips

1. **Use Free Tier Resources**:
   - f1-micro instances
   - 5GB Cloud Storage
   - 100GB egress/month

2. **Use Preemptible Instances**:
   ```bash
   # 80% cheaper for fault-tolerant workloads
   gcloud compute instances create my-instance \
     --preemptible \
     --zone=us-central1-a
   ```

3. **Commitments for Sustained Use**:
   - Automatic discounts for 25%+ monthly usage
   - Additional discounts for 1-year commitments

4. **Enable Billing Exports**:
   ```bash
   # Export to BigQuery for analysis
   gcloud billing accounts get-iam-policy $(gcloud beta billing accounts list --format='value(name)' --limit=1) \
     --flatten="bindings[].members" \
     --filter="bindings.members:serviceAccount"
   ```

### Calculate Costs

Use [GCP Pricing Calculator](https://cloud.google.com/products/calculator) to estimate:
- f1-micro: $0.008/hour = ~$5.76/month
- n1-standard-1: $0.0475/hour = ~$34.20/month
- Cloud Storage: $0.020/GB/month for Standard

## Troubleshooting

### Issue: Permission Denied

**Error**: `Error 403: Permission denied on resource project my-project`

**Solution**: Check service account permissions
```bash
# Check service account roles
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:${SA_EMAIL}"

# Grant missing role
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/editor"
```

### Issue: API Not Enabled

**Error**: `Error 403: Cloud Resource Manager API has not been used`

**Solution**: Enable required APIs
```bash
# Enable all common APIs
gcloud services enable \
  compute.googleapis.com \
  storage-component.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  servicenetworking.googleapis.com
```

### Issue: Invalid Credentials

**Error**: `Error 401: Invalid authentication credentials`

**Solution**: Re-authenticate
```bash
# Set credentials file
export GOOGLE_APPLICATION_CREDENTIALS="path/to/key.json"

# Test authentication
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

# Verify
gcloud auth list
```

### Issue: Quota Exceeded

**Error**: `Error 403: Quota exceeded`

**Solution**: Check quotas and request increase
```bash
# View quotas
gcloud compute project-info describe --project=$PROJECT_ID

# Request quota increase
gcloud compute project-info describe --project=$PROJECT_ID \
  --format='table(quotas.metric, quotas.limit, quotas.usage)'
```

### Issue: Project Not Found

**Error**: `Error 404: Project not found`

**Solution**: Verify project exists and is linked
```bash
# List projects
gcloud projects list

# Set correct project
gcloud config set project $PROJECT_ID

# Verify billing is linked
gcloud beta billing projects describe $PROJECT_ID
```

### Issue: Terraform State Lock

**Error**: `Error acquiring the state lock`

**Solution**: Force unlock (use carefully!)
```bash
# View lock info
terraform force-unlock -force LOCK_ID

# Or use Google Cloud Storage for state locking
terraform {
  backend "gcs" {
    bucket  = "my-terraform-state"
    prefix  = "terraform/state"
  }
}
```

## Next Steps

1. **Explore Modules**: Check out Storage, VPC, and Service Account modules
2. **Create Stacks**: Build dev/prod environments
3. **CI/CD**: Set up GitHub Actions for automated deployments
4. **State Management**: Configure GCS backend for remote state
5. **Security**: Implement least privilege IAM policies

## Resources

### Official Documentation

- [GCP Documentation](https://cloud.google.com/docs)
- [GCP Well-Architected Framework](https://cloud.google.com/architecture/framework)
- [GCP Free Tier](https://cloud.google.com/free/docs/gcp-free-tier)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

### Tools

- [gcloud CLI Reference](https://cloud.google.com/sdk/gcloud/reference)
- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)
- [GCP Architecture Center](https://cloud.google.com/architecture)

### Learning

- [GCP Training](https://cloud.google.com/training)
- [Qwiklabs](https://www.qwiklabs.com/)
- [Coursera GCP Courses](https://www.coursera.org/googlecloud)

---

**Ready to deploy!** 🚀 See module READMEs in `modules/gcp/` for specific resource deployment examples.

**Need help?** Open an issue or start a discussion in the repository.

