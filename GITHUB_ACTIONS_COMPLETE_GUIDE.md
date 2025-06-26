# GitHub Actions Complete Setup Guide

## 🚀 Overview
This repository includes GitHub Actions workflows for automated deployment of Azure infrastructure using Terraform. This guide covers everything you need to know to set up and use the CI/CD pipeline.


---

## 📋 Prerequisites & Background

### ⚠️ Required: Backend Setup (FIRST)
**IMPORTANT**: Before using GitHub Actions, you must first set up the Terraform backend using the bootstrap repository:

1. **Set up the backend infrastructure**:
   ```bash
   git clone https://github.com/atzkyaw/azure-terraform-infra-bootstrap-backend.git
   cd azure-terraform-infra-bootstrap-backend
   # Follow the setup instructions in that repository
   ```

2. **Verify backend is ready**: Ensure the Azure Storage Account for Terraform state is created

### Azure Service Principal Setup (REQUIRED)
You need to create your own Azure Service Principal for GitHub Actions authentication:

```bash
# 1. Login to Azure CLI
az login

# 2. Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"

# 3. Create a service principal
az ad sp create-for-rbac --name "github-actions-terraform-aks" \
  --role="Contributor" \
  --scopes="/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth

# 4. Copy the entire JSON output for GitHub secrets
```

**⚠️ IMPORTANT**: Save the JSON output securely - you'll need it for GitHub secrets!

### GitHub Environment Setup (Optional but Recommended)
1. Go to **Settings** → **Environments**
2. Create a new environment called `production`
3. Add protection rules:
   - Required reviewers (recommended for production)
   - Wait timer (optional)
   - Deployment branches (restrict to main branch)

---

## 🚨 Quick Start Checklist

### ✅ Step 1: Complete Prerequisites Above
- [ ] Backend infrastructure is set up using [azure-terraform-infra-bootstrap-backend](https://github.com/atzkyaw/azure-terraform-infra-bootstrap-backend)
- [ ] Azure Service Principal is created
- [ ] Service Principal JSON output is saved

### ✅ Step 2: Add GitHub Secret (REQUIRED)
1. Go to: https://github.com/atzkyaw/azure-terraform-infra/settings/secrets/actions
2. Click **"New repository secret"**
3. Name: `AZURE_CREDENTIALS`
4. Value: Copy the entire JSON block from your Service Principal creation:
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```
5. Click **"Add secret"**

### ✅ Step 3: Deploy Main Infrastructure
- [ ] Run **"Terraform Azure Infrastructure"** workflow
  - [ ] Click **"Run workflow"**
  - [ ] Select action: **"apply"**
  - [ ] Click **"Run workflow"**
  - [ ] Wait for completion ✅

### ✅ Step 4: Verify Deployment
- [ ] Check Azure Portal for created resources
- [ ] Verify AKS cluster is running
- [ ] Test kubectl access: `az aks get-credentials --resource-group rg-aks-demo --name demoaks`

---

## 🔄 GitHub Actions Workflows Explained

### 1. 📋 `terraform.yml` - Main Infrastructure Deployment

**Purpose**: Primary CI/CD pipeline for deploying Azure infrastructure (AKS, ACR, Key Vault, etc.)

**When it runs**:
- ✅ **On Push**: Changes to `main` branch affecting `.tf` or `.tfvars` files
- ✅ **On Pull Request**: Validates changes before merging
- ✅ **Manual Trigger**: Run manually via GitHub Actions UI

**What it does**:
```yaml
Workflow stages:
1. 🔍 Code Checkout
2. 🛠️  Setup Terraform (v1.6.0)
3. 🔐 Azure Authentication (using Service Principal)
4. 🏗️  Terraform Init (connect to remote state)
5. ✅ Terraform Validate (check syntax)
6. 📋 Terraform Plan (show what will be created/changed)
7. 🚀 Terraform Apply (deploy infrastructure - manual trigger only)
8. 📊 Upload Plan Artifacts (for review)
```

**Safety Features**:
- Only runs `plan` automatically
- Requires manual approval for `apply`
- Environment protection rules
- Artifact storage for plan review

---


### 2. 🔒 `security.yml` - Security & Compliance Scanning

**Purpose**: Continuously scans Terraform code for security vulnerabilities

**When it runs**:
- ✅ **On Push**: Every push to `main` branch
- ✅ **On Pull Request**: Before merging changes
- ✅ **Weekly Schedule**: Every Monday at 2 AM (automated audit)

**What it does**:
```yaml
Two parallel security scans:

Job 1 - TFSec Scan:
1. 🔍 Checkout Code
2. 🛡️  Run TFSec Security Scanner
3. 📊 Report Security Issues

Job 2 - Checkov Scan:
1. 🔍 Checkout Code  
2. 🔐 Run Checkov Compliance Scanner
3. 📋 Generate SARIF Security Report
```

**Security Checks Include**:
- 🔓 **Encryption**: Data encryption at rest/transit
- 🌐 **Network Security**: Firewall rules validation
- 🔑 **Access Control**: IAM permissions review
- 📝 **Compliance**: Security standards adherence
- 🚨 **Vulnerabilities**: Potential security risks

---

## 🔄 Workflow Execution Order

### Initial Setup (One-time):
```bash
1. 🔐 Add AZURE_CREDENTIALS secret to GitHub
2. 🗄️  Set up backend using bootstrap repository
3. 🔒 `security.yml` runs automatically - Scans for security issues  
4. 📋 Run `terraform.yml` (action: plan) - Review infrastructure plan
5. 🚀 Run `terraform.yml` (action: apply) - Deploy infrastructure
```

### Daily Development Workflow:
```bash
1. 👨‍💻 Make changes to .tf files
2. 📤 Push to feature branch
3. 🔒 `security.yml` runs automatically on PR
4. 📋 `terraform.yml` runs plan automatically on PR
5. 🔍 Review plan output and security scan results
6. ✅ Merge PR to main
7. 🚀 Manually trigger `terraform.yml` (action: apply) if needed
```

### Maintenance:
```bash
Weekly: 🔒 `security.yml` runs automatically for security audit
As needed: Backend maintenance via bootstrap repository
```

---

## 📖 Detailed Usage Instructions

### First-Time Setup
1. **Setup Backend** (prerequisite - must be done first):
   - Clone and set up: https://github.com/atzkyaw/azure-terraform-infra-bootstrap-backend
   - Follow the setup instructions in that repository
   - Verify the backend storage account is created

2. **Create Azure Service Principal**:
   - Follow the Azure Service Principal setup in Prerequisites section above
   - Save the JSON output for GitHub secrets

3. **Configure GitHub Secrets**:
   - Add `AZURE_CREDENTIALS` secret with Service Principal JSON
   - Go to repository Settings → Secrets and variables → Actions

4. **Deploy Infrastructure**:
   - Use **Actions** → **Terraform Azure Infrastructure** → **Run workflow** → "apply"

### Development Workflow
1. Create a feature branch
2. Make changes to Terraform files
3. Push branch and create Pull Request
4. GitHub Actions will run `terraform plan` and comment on PR
5. Review the plan in the PR comments
6. Merge PR to main branch
7. GitHub Actions will automatically run `terraform apply` (if configured)

### Manual Operations
- **Plan Only**: Actions → Terraform Azure Infrastructure → Run workflow → "plan"
- **Apply**: Actions → Terraform Azure Infrastructure → Run workflow → "apply"
- **Destroy**: Actions → Terraform Azure Infrastructure → Run workflow → "destroy"

---

## 🔒 Security Features

1. **Environment Protection**: Production environment requires manual approval
2. **Security Scanning**: Automated security scans on every PR
3. **Secrets Management**: Azure credentials stored as GitHub secrets
4. **State Locking**: Terraform state is locked during operations
5. **Unique Naming**: Resource names are automatically generated to be unique
6. **Non-Breaking Scans**: Security scans use `soft_fail` to avoid breaking builds
7. **Dual Scanning**: Both TFSec and Checkov for comprehensive coverage

---

## 🎉 You're Done!

Once you complete the checklist above, your GitHub Actions CI/CD pipeline is ready!

### What You Get:
- ✅ Automated infrastructure deployment
- ✅ Security scanning on every change
- ✅ Pull request validation
- ✅ Manual deployment controls
- ✅ Terraform state management
- ✅ Cost-effective resource naming

### Next Steps:
- Deploy applications to your AKS cluster
- Push images to your ACR 
- Use Key Vault for secrets
- Monitor costs in Azure Portal

### Daily Usage:
- **Push code changes** → Automatic planning and security scans
- **Create PRs** → Automatic validation and plan review
- **Manual deployments** → Use Actions tab for apply/destroy operations

---

## 🛠️ Troubleshooting

### Common Issues:
1. **Authentication Failed**: 
   - Check `AZURE_CREDENTIALS` secret format
   - Verify the JSON is complete and valid
   - Ensure Service Principal has proper permissions
   
2. **"Authenticating using Azure CLI only supported as User"**: 
   - This is fixed in the latest workflow versions
   - The workflow extracts Service Principal credentials automatically
   
3. **Resource Already Exists**: 
   - Resource names must be globally unique
   - ACR and Key Vault names are auto-generated with timestamps
   
3. **Insufficient Permissions**: 
   - Service Principal needs Contributor role
   - Check role assignment in Azure Portal
   
4. **Backend Not Found**: 
   - Run the backend setup workflow first
   - Verify backend storage account exists

### Debug Steps:
1. Check workflow logs in GitHub Actions
2. Verify Azure CLI authentication: `az account show`
3. Test Terraform locally with same configuration
4. Check Azure resource group and resources in portal

### Getting Help:
- Review workflow logs in GitHub Actions tab
- Check Terraform plan output in PR comments
- Verify Azure resource status in Azure Portal
- Consult Azure documentation for service-specific issues

---

## 💰 Cost Management

### Daily Costs (Southeast Asia):
- **AKS Cluster**: ~$2.30/day (1x Standard_DS2_v2 node)
- **ACR Basic**: ~$0.167/day
- **Key Vault**: ~$0.01/day
- **Storage**: ~$0.001/day
- **Total**: ~$2.48/day (~$74/month)

### Cost Optimization:
- Use `terraform destroy` when not needed
- Scale AKS nodes to 0 during non-use periods
- Monitor usage in Azure Cost Management

---

Your infrastructure is now ready for modern DevOps! 🚀
