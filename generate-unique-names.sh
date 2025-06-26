#!/bin/bash
# generate-unique-names.sh
# Script to generate unique resource names for local development

# Check if terraform.tfvars exists
if [ -f terraform.tfvars ]; then
    echo "terraform.tfvars already exists. Please remove it first if you want to regenerate."
    exit 1
fi

echo "Creating terraform.tfvars from template with unique names..."

# Copy the template
cp terraform.tfvars.example terraform.tfvars

# Generate unique suffixes for globally unique resources
TIMESTAMP=$(date +%s)
RANDOM_SUFFIX=$(openssl rand -hex 4 2>/dev/null || echo $(printf "%08x" $RANDOM))
UNIQUE_SUFFIX="${TIMESTAMP}${RANDOM_SUFFIX}"

# Update ACR and Key Vault names to be unique
sed -i.bak "s/demoacr1234567890/demoacr${UNIQUE_SUFFIX}/g" terraform.tfvars
sed -i.bak "s/demokv1234567890/demokv${UNIQUE_SUFFIX}/g" terraform.tfvars

# Also update monitoring resource names for uniqueness
sed -i.bak "s/log_analytics_workspace_name = \"aks-demo-logs\"/log_analytics_workspace_name = \"aks-demo-logs-${UNIQUE_SUFFIX}\"/g" terraform.tfvars
sed -i.bak "s/application_insights_name = \"aks-demo-insights\"/application_insights_name = \"aks-demo-insights-${UNIQUE_SUFFIX}\"/g" terraform.tfvars

# Remove backup file
rm terraform.tfvars.bak 2>/dev/null || true

echo "Generated unique resource names with suffix: ${UNIQUE_SUFFIX}"
echo ""
echo "Updated terraform.tfvars with unique names:"
echo "  ACR Name: demoacr${UNIQUE_SUFFIX}"
echo "  Key Vault Name: demokv${UNIQUE_SUFFIX}"
echo "  Log Analytics: aks-demo-logs-${UNIQUE_SUFFIX}"
echo "  App Insights: aks-demo-insights-${UNIQUE_SUFFIX}"
echo ""
echo "You can now run: terraform plan"
