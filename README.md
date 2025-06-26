# Azure Terraform Infrastructure for AKS

## 🚀 Overview
This project provisions a complete, production-ready Azure infrastructure for AKS (Azure Kubernetes Service) using Terraform. It includes automated CI/CD with GitHub Actions, security scanning, and cost optimization features.

## 🏗️ Infrastructure Components
- **AKS Cluster**: Kubernetes cluster with auto-scaling node pools
- **Azure Container Registry (ACR)**: Private container image registry
- **Azure Key Vault**: Secure secrets and certificate management
- **Virtual Network**: Isolated network with dedicated subnet for AKS
- **Security Features**: RBAC, managed identities, and security scanning

## 🗺️ Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                     Azure Subscription                      │
├─────────────────────────────────────────────────────────────┤
│  Resource Group: rg-aks-demo                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   Virtual Network│  │     AKS Cluster │  │  Azure ACR   │ │
│  │   (10.0.0.0/16) │  │   (demoaks)     │  │              │ │
│  │                 │  │                 │  │              │ │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │              │ │
│  │ │AKS Subnet   │ │  │ │ Node Pool   │ │  │              │ │
│  │ │10.0.1.0/24  │ │  │ │ 1-3 nodes   │ │  │              │ │
│  │ └─────────────┘ │  │ └─────────────┘ │  │              │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│                                                             │
│  ┌─────────────────┐                                       │
│  │   Azure Key     │                                       │
│  │   Vault         │                                       │
│  │   (demokv...)   │                                       │
│  └─────────────────┘                                       │
└─────────────────────────────────────────────────────────────┘
```

## 📂 Project Structure
```
azure-terraform-infra/
├── .github/workflows/          # GitHub Actions CI/CD pipelines
│   ├── terraform.yml          # Main infrastructure deployment
│   ├── security.yml           # Security scanning (TFSec, Checkov)
│   └── backend.yml            # Backend setup workflow
├── modules/                   # Reusable Terraform modules
│   ├── aks/                  # AKS cluster configuration
│   ├── acr/                  # Container registry
│   ├── keyvault/             # Key vault for secrets
│   └── network/              # VNet and subnet
├── docs/                     # Local documentation (gitignored)
├── backend.tf                # Remote state configuration
├── main.tf                   # Main infrastructure definition
├── variables.tf              # Variable definitions
├── terraform.tfvars.example  # Example configuration
└── LOCAL_SETUP_GUIDE.md      # Local development setup
```

## ⚠️ Prerequisites: Backend Setup (REQUIRED FIRST)

**CRITICAL**: Before using this repository, you must first set up the Terraform backend:

### 🗄️ Step 1: Set Up Backend Infrastructure
```bash
# Clone and set up the backend repository
git clone https://github.com/atzkyaw/azure-terraform-infra-bootstrap-backend.git
cd azure-terraform-infra-bootstrap-backend

# Follow the setup instructions in that repository
# This creates the Azure Storage Account for Terraform state
```

### ✅ Step 2: Verify Backend Ready
Ensure the backend Azure Storage Account is created and accessible before proceeding.

---

## 🚀 Deployment Options

### Option 1: GitHub Actions (Recommended)
Automated CI/CD deployment with security scanning and approval workflows.

#### Prerequisites
1. **Backend Setup**: Complete the backend setup above ⬆️
2. **Azure Service Principal**: Create service principal for GitHub Actions
3. **GitHub Secrets**: Configure repository secrets

#### Quick Start
1. **Create Service Principal**:
   ```bash
   az login
   SUBSCRIPTION_ID=$(az account show --query id --output tsv)
   
   az ad sp create-for-rbac --name "github-actions-terraform-aks" \
     --role="Contributor" \
     --scopes="/subscriptions/$SUBSCRIPTION_ID" \
     --sdk-auth
   ```

2. **Add GitHub Secret**:
   - Go to: [Repository Secrets](https://github.com/atzkyaw/azure-terraform-infra/settings/secrets/actions)
   - Create secret: `AZURE_CREDENTIALS`
   - Value: Paste the entire JSON output from step 1

3. **Deploy Infrastructure**:
   - Go to **Actions** → **Terraform Azure Infrastructure**
   - Click **Run workflow** → Select "apply" → **Run workflow**

4. **Verify Deployment**:
   - Check Azure Portal for created resources
   - Connect to AKS: `az aks get-credentials --resource-group rg-aks-demo --name demoaks`

#### GitHub Actions Features
- ✅ **Automated Planning**: Runs `terraform plan` on PRs
- ✅ **Security Scanning**: TFSec and Checkov on every change
- ✅ **Manual Approvals**: Production deployments require approval
- ✅ **Cost Control**: Auto-generated unique resource names
- ✅ **State Management**: Remote state with locking

### Option 2: Local Development
Direct Terraform execution on your local machine.

👉 **See detailed instructions**: [LOCAL_SETUP_GUIDE.md](LOCAL_SETUP_GUIDE.md)

#### Quick Local Setup
```bash
# Prerequisites: Azure CLI, Terraform, backend setup completed

git clone https://github.com/atzkyaw/azure-terraform-infra.git
cd azure-terraform-infra

# Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Set environment
export ARM_SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# Deploy
terraform init
terraform plan
terraform apply
```

---

## 🔄 GitHub Actions Workflows

### 1. 📋 Terraform Infrastructure (`terraform.yml`)
**Purpose**: Main CI/CD pipeline for infrastructure deployment

**Triggers**:
- Push to `main` branch (plan only)
- Pull requests (validation)
- Manual dispatch (plan/apply/destroy)

**Features**:
- Automatic planning on code changes
- Manual approval for apply operations
- Artifact upload for plan review
- Environment protection rules

### 2. 🔒 Security Scanning (`security.yml`)
**Purpose**: Continuous security and compliance monitoring

**Triggers**:
- Push to `main` branch
- Pull requests
- Weekly schedule (Monday 2 AM)

**Scanners**:
- **TFSec**: Terraform security analysis
- **Checkov**: Infrastructure compliance checking

### 3. 🗄️ Backend Setup (`backend.yml`)
**Purpose**: One-time backend infrastructure setup

**Triggers**:
- Manual dispatch only

**Note**: This workflow references the backend repository. Use the separate backend repository instead.

---

## 💰 Cost Analysis

### Estimated Monthly Costs (Southeast Asia)
| Resource | SKU/Size | Monthly Cost |
|----------|----------|--------------|
| AKS Cluster Management | Free Tier | $0.00 |
| Virtual Machines | 1x Standard_DS2_v2 | ~$73.00 |
| Azure Container Registry | Basic | ~$5.00 |
| Azure Key Vault | Standard | ~$1.00 |
| Virtual Network | Standard | ~$2.00 |
| Storage (State) | Standard LRS | ~$0.50 |
| **Total** | | **~$81.50/month** |

### Cost Optimization Features
- **Auto-scaling**: Node pool scales 1-3 nodes based on demand
- **Stop/Start AKS**: Use `az aks stop/start` for development
- **Resource Tagging**: All resources tagged for cost tracking
- **Terraform Destroy**: Easy cleanup for temporary environments

---

## 🔒 Security Features

### Built-in Security
- ✅ **Managed Identities**: No stored credentials
- ✅ **Network Isolation**: Dedicated VNet and subnet
- ✅ **RBAC Ready**: Azure AD integration configured
- ✅ **Secret Management**: Azure Key Vault integration
- ✅ **Container Security**: Private ACR with role-based access

### Continuous Security
- ✅ **Automated Scanning**: TFSec and Checkov on every change
- ✅ **Compliance Monitoring**: Weekly security audits
- ✅ **State Protection**: Remote state with access controls
- ✅ **Environment Controls**: Production deployment approvals

---

## 🛠️ Management & Operations

### Daily Operations
```bash
# Connect to AKS cluster
az aks get-credentials --resource-group rg-aks-demo --name demoaks

# Scale cluster
az aks nodepool scale --resource-group rg-aks-demo --cluster-name demoaks --name default --node-count 2

# Stop/Start cluster (cost savings)
az aks stop --resource-group rg-aks-demo --name demoaks
az aks start --resource-group rg-aks-demo --name demoaks

# Access ACR
az acr login --name demoacr1750914293

# Manage secrets
az keyvault secret set --vault-name demokv1750914293 --name "mysecret" --value "myvalue"
```

### Monitoring
- **Azure Portal**: Resource health and metrics
- **AKS Insights**: Kubernetes cluster monitoring
- **Cost Management**: Azure cost analysis and budgets
- **GitHub Actions**: Deployment history and logs

---

## 🚨 Troubleshooting

### Common Issues

#### 1. Backend Access Issues
```bash
# Verify backend setup
az storage account show --name tfstateaksdemo --resource-group rg-aks-demo

# Check permissions
az role assignment list --assignee $(az account show --query user.name --output tsv)
```

#### 2. Resource Name Conflicts
- **ACR names** must be globally unique
- **Key Vault names** must be globally unique
- Edit `terraform.tfvars` with unique names

#### 3. GitHub Actions Authentication
- Verify `AZURE_CREDENTIALS` secret format
- Ensure Service Principal has Contributor role
- Check subscription ID in the JSON

#### 4. AKS Access Issues
```bash
# Reset kubectl credentials
az aks get-credentials --resource-group rg-aks-demo --name demoaks --overwrite-existing

# Check cluster status
az aks show --resource-group rg-aks-demo --name demoaks --query "powerState"
```

### Getting Help
- 📋 **GitHub Actions Logs**: Check workflow execution details
- 🔍 **Terraform Logs**: Enable debug mode with `TF_LOG=DEBUG`
- 🌐 **Azure Portal**: Verify resource status and configuration
- 📚 **Documentation**: Consult Azure and Terraform documentation

---

## 📚 Additional Resources

### Documentation
- [LOCAL_SETUP_GUIDE.md](LOCAL_SETUP_GUIDE.md) - Detailed local development setup
- [Backend Repository](https://github.com/atzkyaw/azure-terraform-infra-bootstrap-backend) - Terraform state backend setup
- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

### Quick Reference
```bash
# Terraform Commands
terraform init      # Initialize working directory
terraform plan      # Show execution plan
terraform apply     # Apply changes
terraform destroy   # Destroy infrastructure

# Azure CLI Commands
az aks list          # List AKS clusters
az acr list          # List container registries
az keyvault list     # List key vaults
az resource list     # List all resources
```

---

## 🎯 Next Steps

After successful deployment:

1. **🚀 Deploy Applications**: Deploy workloads to your AKS cluster
2. **📦 Push Images**: Use ACR for container image storage
3. **🔐 Store Secrets**: Leverage Key Vault for application secrets
4. **📊 Set Up Monitoring**: Configure Azure Monitor and Log Analytics
5. **🔒 Implement RBAC**: Configure Azure AD integration and role assignments
6. **💰 Monitor Costs**: Set up budgets and cost alerts

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Run security scans: `tfsec .` and `checkov -d .`
5. Submit a pull request
6. GitHub Actions will validate changes automatically

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Your Azure infrastructure is ready for modern DevOps! 🚀**

For questions or issues, please open a GitHub issue or check the troubleshooting section above.
