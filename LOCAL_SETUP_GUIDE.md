# Local Development Setup Guide

## 🚀 Overview
This guide covers how to set up and run the Terraform infrastructure locally on your development machine, without using GitHub Actions.

---

## 📋 Prerequisites

### ⚠️ Required: Backend Setup (FIRST)
**IMPORTANT**: Before running Terraform locally, you must first set up the Terraform backend using the bootstrap repository:

1. **Set up the backend infrastructure**:
   ```bash
   git clone https://github.com/atzkyaw/azure-terraform-infra-bootstrap-backend.git
   cd azure-terraform-infra-bootstrap-backend
   # Follow the setup instructions in that repository
   ```

2. **Verify backend is ready**: Ensure the Azure Storage Account for Terraform state is created

### Required Tools
1. **Azure CLI**: Install and configure Azure CLI
   ```bash
   # Install Azure CLI (varies by OS)
   # macOS: brew install azure-cli
   # Windows: winget install Microsoft.AzureCLI
   # Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   
   # Login to Azure
   az login
   az account set --subscription "your-subscription-name"
   ```

2. **Terraform**: Install Terraform >= 1.5
   ```bash
   # Download from https://terraform.io/downloads
   # Or use package manager:
   # macOS: brew install terraform
   # Windows: winget install Hashicorp.Terraform
   # Linux: Use HashiCorp's repository
   
   # Verify installation
   terraform version
   ```

3. **kubectl** (optional - for AKS management):
   ```bash
   # Install kubectl
   # macOS: brew install kubectl
   # Windows: winget install Kubernetes.kubectl
   # Linux: curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   ```

---

## 🔧 Local Setup Steps

### Step 1: Clone and Navigate to Project
```bash
git clone https://github.com/atzkyaw/azure-terraform-infra.git
cd azure-terraform-infra
```

### Step 2: Verify Backend Configuration
Check that `backend.tf` matches your backend setup from the bootstrap repository:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-aks-demo"           # Should match your backend setup
    storage_account_name = "tfstateaksdemo"        # Should match your backend setup
    container_name       = "tfstate"               # Should match your backend setup
    key                  = "aks.terraform.tfstate" # Should match your backend setup
  }
}
```

### Step 3: Configure Variables
```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your specific values
nano terraform.tfvars  # or use your preferred editor
```

**Important variables to customize**:
```hcl
# Basic Configuration
location = "southeastasia"              # Change if needed
resource_group = "rg-aks-demo"         # Change if needed

# Network Configuration
vnet_name = "aks-vnet"                  # Change if needed
vnet_cidr = "10.0.0.0/16"              # Change if needed

# AKS Configuration
aks_name = "demoaks"                    # Change if needed
dns_prefix = "demoaks"                  # Change if needed

# Azure Container Registry (must be globally unique)
acr_name = "demoacr1234567890"          # CHANGE THIS - must be globally unique

# Key Vault (must be globally unique)
kv_name = "demokv1234567890"            # CHANGE THIS - must be globally unique

# Azure Active Directory Configuration (optional)
# aad_group_object_id = "your-aad-group-object-id"
# tenant_id = "your-tenant-id"
```

### Step 4: Set Environment Variables
```bash
# Set your Azure subscription ID
export ARM_SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# Optional: Set other ARM environment variables if needed
# export ARM_CLIENT_ID="your-service-principal-client-id"
# export ARM_CLIENT_SECRET="your-service-principal-secret"
# export ARM_TENANT_ID="your-tenant-id"
```

---

## 🚀 Deployment Steps

### Step 1: Initialize Terraform
```bash
terraform init
```

Expected output:
```
Initializing the backend...
Successfully configured the backend "azurerm"!
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Step 2: Validate Configuration
```bash
terraform validate
```

### Step 3: Plan Deployment
```bash
terraform plan
```

Review the planned changes carefully. This will show you:
- What resources will be created
- Estimated costs
- Any potential issues

### Step 4: Apply Configuration
```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### Step 5: Verify Deployment
```bash
# Check if resources were created
az resource list --resource-group rg-aks-demo --output table

# Get AKS credentials
az aks get-credentials --resource-group rg-aks-demo --name demoaks

# Test kubectl access
kubectl get nodes
```

---

## 🔄 Daily Development Workflow

### Making Changes
1. **Edit Terraform files** as needed
2. **Plan changes**:
   ```bash
   terraform plan
   ```
3. **Apply changes**:
   ```bash
   terraform apply
   ```

### Testing Changes
```bash
# Check specific resources
az aks show --resource-group rg-aks-demo --name demoaks
az acr list --resource-group rg-aks-demo --output table
az keyvault list --resource-group rg-aks-demo --output table
```

### Updating AKS Configuration
```bash
# After AKS changes, update kubectl config
az aks get-credentials --resource-group rg-aks-demo --name demoaks --overwrite-existing
```

---

## 🧹 Cleanup

### Destroy Infrastructure
```bash
# Review what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy
```

Type `yes` when prompted to confirm destruction.

### Verify Cleanup
```bash
# Check that resources are gone
az resource list --resource-group rg-aks-demo --output table
```

---

## 🛠️ Troubleshooting

### Common Issues

#### 1. Backend Access Issues
```bash
# Error: Failed to get existing workspaces
# Solution: Check your Azure login and permissions
az login
az account show
```

#### 2. Resource Name Conflicts
```bash
# Error: storage account name is already taken
# Solution: Change ACR and Key Vault names in terraform.tfvars
# They must be globally unique across all Azure
```

#### 3. Insufficient Permissions
```bash
# Error: authorization failed
# Solution: Ensure your Azure account has Contributor role
az role assignment list --assignee $(az account show --query user.name --output tsv)
```

#### 4. Terraform State Lock
```bash
# Error: state lock
# Solution: Check if another process is running, or force unlock
terraform force-unlock LOCK_ID  # Use lock ID from error message
```

### Debug Commands
```bash
# Check Terraform version
terraform version

# Check Azure CLI version and login status
az version
az account show

# Check current subscription
az account list --output table

# Validate Terraform syntax
terraform validate

# Get detailed plan output
terraform plan -detailed-exitcode

# Check provider configuration
terraform providers
```

### Logging and Debugging
```bash
# Enable detailed Terraform logging
export TF_LOG=DEBUG
terraform apply

# Enable Azure CLI debug logging
az configure --defaults debug=true
```

---

## 💰 Cost Management

### Monitor Costs Locally
```bash
# Check current resource costs
az consumption usage list --output table

# List all resources and their SKUs
az resource list --resource-group rg-aks-demo --query "[].{Name:name, Type:type, Location:location}" --output table
```

### Cost-Saving Tips
1. **Stop AKS when not in use**:
   ```bash
   az aks stop --resource-group rg-aks-demo --name demoaks
   az aks start --resource-group rg-aks-demo --name demoaks
   ```

2. **Scale down node count**:
   ```bash
   az aks nodepool scale --resource-group rg-aks-demo --cluster-name demoaks --name default --node-count 0
   ```

3. **Use terraform destroy** for extended breaks:
   ```bash
   terraform destroy  # Removes all resources
   ```

---

## 📚 Additional Resources

### Terraform Commands Reference
```bash
terraform init          # Initialize working directory
terraform validate      # Validate configuration syntax
terraform plan          # Show execution plan
terraform apply         # Apply changes
terraform destroy       # Destroy infrastructure
terraform show          # Show current state
terraform output        # Show output values
terraform refresh       # Update state from real infrastructure
terraform import        # Import existing resources
terraform taint         # Mark resource for recreation
```

### Azure CLI Commands Reference
```bash
az login                 # Login to Azure
az account list          # List subscriptions
az account set           # Set active subscription
az group list            # List resource groups
az resource list         # List resources
az aks list              # List AKS clusters
az acr list             # List container registries
az keyvault list        # List key vaults
```

### Useful Local Development Commands
```bash
# Format Terraform code
terraform fmt

# Check for security issues (if tfsec installed)
tfsec .

# Generate documentation (if terraform-docs installed)
terraform-docs markdown . > TERRAFORM_DOCS.md

# Validate with checkov (if installed)
checkov -d .
```

---

## 🎯 Next Steps

After successful local setup:

1. **Deploy applications** to your AKS cluster
2. **Push container images** to your ACR
3. **Store secrets** in Key Vault
4. **Set up monitoring** and logging
5. **Configure CI/CD** with GitHub Actions
6. **Implement RBAC** and security policies

---

Your local development environment is now ready for Azure infrastructure development! 🚀
