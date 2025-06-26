# Terraform Project to Provision Azure Infrastructure for AKS

## 📌 Overview
This project provisions a complete Azure infrastructure for AKS using Terraform, including networking, ACR, and security resources.

## 🏗️ Tech Stack
- Terraform v1.5+
- Azure CLI
- Azure AD (for AKS RBAC)
- AKS, ACR, VNet, Key Vault

## 🗺️ Architecture
![Architecture Diagram](docs/architecture-diagram.png)

## 📂 Project Structure
- `modules/`: Reusable Terraform modules
- `environments/`: Dev and Prod environments with variable overrides
- `backend.tf`: Remote state backend using Azure Storage

## 🔧 Setup Instructions

### Option 1: GitHub Actions Deployment (Recommended)
For automated CI/CD deployment, see: **[GitHub Actions Complete Guide](GITHUB_ACTIONS_COMPLETE_GUIDE.md)**

### Option 2: Local Deployment

#### Prerequisites
1. **Azure CLI**: Install and login to Azure
   ```bash
   az login
   az account set --subscription "your-subscription-name"
   ```

2. **Terraform**: Install Terraform >= 1.0

#### Deployment Steps

1. **Clone and navigate to the project**
   ```bash
   git clone https://github.com/atzkyaw/azure-terraform-infra.git
   cd azure-terraform-infra
   ```

2. **Set up the backend infrastructure** (one-time setup)
   ```bash
   cd ../azure-terraform-infra-bootstrap-backend
   export ARM_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
   terraform init
   terraform plan
   terraform apply
   cd ../azure-terraform-infra
   ```

3. **Configure variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   # Make sure ACR and Key Vault names are globally unique
   ```

4. **Set up Azure environment variables**
   ```bash
   export ARM_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
   ```

5. **Initialize and deploy Terraform**
   ```bash
   terraform init
   ```

4. **Review and customize variables**
   - Edit `terraform.tfvar` if needed
   - Optionally set Azure AD group for AKS admin access

5. **Deploy the infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

6. **Connect to your AKS cluster**
   ```bash
   az aks get-credentials --resource-group rg-aks-demo --name demoaks
   kubectl get nodes
   ```

## 🚀 Quick Start with GitHub Actions

### Required Setup (One-time):
1. **Add GitHub Secret**: 
   - Go to [Repository Secrets](https://github.com/atzkyaw/azure-terraform-infra/settings/secrets/actions)
   - Add secret named `AZURE_CREDENTIALS` with the service principal JSON
   - See **[GitHub Actions Complete Guide](GITHUB_ACTIONS_COMPLETE_GUIDE.md)** for complete details

2. **Deploy Backend** (one-time):
   - Go to **Actions** → **Setup Terraform Backend** → **Run workflow** → Select "apply"

3. **Deploy Infrastructure**:
   - Go to **Actions** → **Terraform Azure Infrastructure** → **Run workflow** → Select "apply"

### Daily Development:
- Push changes to `main` branch for automatic deployment
- Create PRs to see Terraform plans before deployment
- Use **Actions** tab for manual deployments

## 📹 Demo
<Insert link or gif>

## 📚 References
- [Terraform on Azure Docs](https://learn.microsoft.com/en-us/azure/developer/terraform/)
- [Azure AKS Terraform Module](https://registry.terraform.io/modules/Azure/aks/azurerm/)
