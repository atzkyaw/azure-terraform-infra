#!/bin/bash
# setup-env.sh
# Script to set up Azure environment variables for Terraform

echo "Setting up Azure environment variables for Terraform..."

# Get current Azure subscription details
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
TENANT_ID=$(az account show --query tenantId --output tsv)

if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "❌ Error: No active Azure subscription found. Please run 'az login' first."
    exit 1
fi

# Export environment variables
export ARM_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export ARM_TENANT_ID="$TENANT_ID"
export ARM_USE_CLI=true

echo "✅ Environment variables set:"
echo "   ARM_SUBSCRIPTION_ID: $ARM_SUBSCRIPTION_ID"
echo "   ARM_TENANT_ID: $ARM_TENANT_ID"
echo "   ARM_USE_CLI: $ARM_USE_CLI"
echo ""
echo "You can now run Terraform commands:"
echo "   terraform plan"
echo "   terraform apply"
echo ""
echo "To make these permanent, add them to your ~/.bashrc or ~/.zshrc:"
echo "   echo 'export ARM_SUBSCRIPTION_ID=\"$ARM_SUBSCRIPTION_ID\"' >> ~/.bashrc"
echo "   echo 'export ARM_TENANT_ID=\"$ARM_TENANT_ID\"' >> ~/.bashrc"
echo "   echo 'export ARM_USE_CLI=true' >> ~/.bashrc"
