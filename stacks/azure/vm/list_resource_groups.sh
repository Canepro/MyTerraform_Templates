#!/bin/bash
# Helper script to list available Azure resource groups
# Usage: ./list_resource_groups.sh

echo "============================================="
echo "Available Azure Resource Groups"
echo "============================================="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Error: Azure CLI is not installed"
    echo "Install it from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in
if ! az account show &> /dev/null; then
    echo "❌ Error: Not logged into Azure"
    echo "Please run: az login"
    exit 1
fi

echo "Current subscription:"
az account show --query "{Name:name, SubscriptionId:id}" --output table
echo ""

echo "Resource groups you have access to:"
echo ""
az group list --query "[].{Name:name, Location:location, Permissions:'READ/WRITE'}" --output table

echo ""
echo "============================================="
echo "📝 To use an existing resource group:"
echo "============================================="
echo ""
echo "1. Copy the resource group Name from above"
echo "2. In your terraform.tfvars, set:"
echo "   use_existing_resource_group  = true"
echo "   existing_resource_group_name = \"<Name>\""
echo "   location                     = \"<Location>\""
echo ""
echo "Example:"
echo "   use_existing_resource_group  = true"
echo "   existing_resource_group_name = \"1-f02f2411-playground-sandbox\""
echo "   location                     = \"westus\""
echo ""

