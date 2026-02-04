#!/bin/bash
# Azure Resource Deployment Script for POC
# This script creates all Azure resources needed for the POC deployment
# Run with: bash deploy-azure-resources.sh

set -e  # Exit on error

echo "========================================"
echo "Azure POC Resources Deployment"
echo "========================================"
echo ""

# Check if Azure CLI is installed
echo "Checking Azure CLI..."
if ! command -v az &> /dev/null; then
    echo "ERROR: Azure CLI is not installed"
    echo "Install from: https://aka.ms/installazurecliwindows"
    exit 1
fi

AZ_VERSION=$(az version --query '"azure-cli"' -o tsv)
echo "Azure CLI version: $AZ_VERSION"
echo ""

# Check if logged in
echo "Checking Azure login status..."
if ! az account show &> /dev/null; then
    echo "Not logged in. Please run: az login"
    az login
fi

echo ""
echo "Starting deployment..."
echo ""

# Set variables
RESOURCE_GROUP="poc-deployment-rg"
LOCATION="eastus"
SQL_SERVER="poc-sql-server-$(date +%s)"
SQL_DB="poc-db"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="P@ssw0rd123!"
ACR_NAME="pocacr$(date +%s | cut -c1-8)"
APP_SERVICE_PLAN="poc-app-plan"
USER_SERVICE_NAME="poc-user-service-$(date +%s | cut -c1-8)"
PRODUCT_SERVICE_NAME="poc-product-service-$(date +%s | cut -c1-8)"

echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  SQL Server: $SQL_SERVER"
echo "  User Service: $USER_SERVICE_NAME"
echo "  Product Service: $PRODUCT_SERVICE_NAME"
echo ""

# Create resource group
echo "[1/10] Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION > /dev/null
echo "✓ Resource group created"

# Create SQL Server
echo "[2/10] Creating SQL Server..."
az sql server create \
  --name $SQL_SERVER \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --admin-user $SQL_ADMIN \
  --admin-password $SQL_PASSWORD > /dev/null
echo "✓ SQL Server created"

# Create SQL Database
echo "[3/10] Creating SQL Database..."
az sql db create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER \
  --name $SQL_DB \
  --service-objective Basic > /dev/null
echo "✓ SQL Database created"

# Configure firewall (allow Azure services)
echo "[4/10] Configuring SQL Server firewall (Azure services)..."
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 > /dev/null
echo "✓ Firewall rule for Azure services added"

# Get your public IP and add firewall rule
echo "[5/10] Getting your public IP and adding firewall rule..."
MY_IP=$(curl -s ifconfig.me)
if [ -n "$MY_IP" ]; then
    az sql server firewall-rule create \
      --resource-group $RESOURCE_GROUP \
      --server $SQL_SERVER \
      --name AllowMyIP \
      --start-ip-address $MY_IP \
      --end-ip-address $MY_IP > /dev/null
    echo "✓ Firewall rule for your IP ($MY_IP) added"
else
    echo "WARNING: Could not get public IP. You may need to add it manually."
fi

# Create Container Registry
echo "[6/10] Creating Azure Container Registry..."
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true > /dev/null
echo "✓ Container Registry created"

# Create App Service Plan
echo "[7/10] Creating App Service Plan..."
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku B1 \
  --is-linux > /dev/null
echo "✓ App Service Plan created"

# Create App Services
echo "[8/10] Creating App Services..."
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $USER_SERVICE_NAME \
  --runtime "DOTNETCORE:8.0" > /dev/null

az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $PRODUCT_SERVICE_NAME \
  --runtime "DOTNETCORE:8.0" > /dev/null
echo "✓ App Services created"

# Get connection string
echo "[9/10] Configuring connection strings and app settings..."
CONNECTION_STRING=$(az sql db show-connection-string \
  --server $SQL_SERVER \
  --name $SQL_DB \
  --client ado.net | sed "s/<username>/$SQL_ADMIN/g" | sed "s/<password>/$SQL_PASSWORD/g")

# Configure app settings
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $USER_SERVICE_NAME \
  --settings \
    ConnectionStrings__DefaultConnection="$CONNECTION_STRING" \
    ASPNETCORE_ENVIRONMENT=Production > /dev/null

az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $PRODUCT_SERVICE_NAME \
  --settings \
    ConnectionStrings__DefaultConnection="$CONNECTION_STRING" \
    ASPNETCORE_ENVIRONMENT=Production > /dev/null
echo "✓ App settings configured"

# Enable CORS
echo "[10/10] Enabling CORS..."
az webapp cors add \
  --resource-group $RESOURCE_GROUP \
  --name $USER_SERVICE_NAME \
  --allowed-origins "*" > /dev/null

az webapp cors add \
  --resource-group $RESOURCE_GROUP \
  --name $PRODUCT_SERVICE_NAME \
  --allowed-origins "*" > /dev/null
echo "✓ CORS enabled"

# Save variables to file
echo ""
echo "Saving variables to azure-vars.txt..."
cat > azure-vars.txt << EOF
RESOURCE_GROUP=$RESOURCE_GROUP
LOCATION=$LOCATION
SQL_SERVER=$SQL_SERVER
SQL_DB=$SQL_DB
SQL_ADMIN=$SQL_ADMIN
SQL_PASSWORD=$SQL_PASSWORD
ACR_NAME=$ACR_NAME
APP_SERVICE_PLAN=$APP_SERVICE_PLAN
USER_SERVICE_NAME=$USER_SERVICE_NAME
PRODUCT_SERVICE_NAME=$PRODUCT_SERVICE_NAME
CONNECTION_STRING=$CONNECTION_STRING
USER_SERVICE_URL=https://$USER_SERVICE_NAME.azurewebsites.net
PRODUCT_SERVICE_URL=https://$PRODUCT_SERVICE_NAME.azurewebsites.net
EOF

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""
echo "Resources created:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  SQL Server: $SQL_SERVER"
echo "  SQL Database: $SQL_DB"
echo "  Container Registry: $ACR_NAME"
echo "  User Service: https://$USER_SERVICE_NAME.azurewebsites.net"
echo "  Product Service: https://$PRODUCT_SERVICE_NAME.azurewebsites.net"
echo ""
echo "Variables saved to: azure-vars.txt"
echo ""
echo "Next steps:"
echo "  1. Run database migrations"
echo "  2. Deploy your APIs to App Services"
echo "  3. Create Static Web App for Angular"
echo ""

