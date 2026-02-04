# Azure Resource Deployment Script for POC
# This script creates all Azure resources needed for the POC deployment
# Run with: .\deploy-azure-resources.ps1

# Stop on errors
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure POC Resources Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
Write-Host "Checking Azure CLI..." -ForegroundColor Yellow
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Azure CLI is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Install from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# Check if logged in
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
$account = az account show 2>$null
if (-not $account) {
    Write-Host "Not logged in. Please run: az login" -ForegroundColor Yellow
    az login
}

Write-Host ""
Write-Host "Starting deployment..." -ForegroundColor Green
Write-Host ""

# Set variables
$RESOURCE_GROUP = "poc-deployment-rg"
$LOCATION = "eastus"
$TIMESTAMP = [int][double]::Parse((Get-Date -UFormat %s))
$SQL_SERVER = "poc-sql-server-$TIMESTAMP"
$SQL_DB = "poc-db"
$SQL_ADMIN = "sqladmin"
$SQL_PASSWORD = "P@ssw0rd123!"
$ACR_NAME = "pocacr$($TIMESTAMP.ToString().Substring(0,8))"
$APP_SERVICE_PLAN = "poc-app-plan"
$USER_SERVICE_NAME = "poc-user-service-$($TIMESTAMP.ToString().Substring(0,8))"
$PRODUCT_SERVICE_NAME = "poc-product-service-$($TIMESTAMP.ToString().Substring(0,8))"

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Resource Group: $RESOURCE_GROUP"
Write-Host "  Location: $LOCATION"
Write-Host "  SQL Server: $SQL_SERVER"
Write-Host "  User Service: $USER_SERVICE_NAME"
Write-Host "  Product Service: $PRODUCT_SERVICE_NAME"
Write-Host ""

# Create resource group
Write-Host "[1/10] Creating resource group..." -ForegroundColor Yellow
az group create --name $RESOURCE_GROUP --location $LOCATION | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create resource group" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Resource group created" -ForegroundColor Green

# Create SQL Server
Write-Host "[2/10] Creating SQL Server..." -ForegroundColor Yellow
az sql server create `
    --name $SQL_SERVER `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --admin-user $SQL_ADMIN `
    --admin-password $SQL_PASSWORD | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create SQL Server" -ForegroundColor Red
    exit 1
}
Write-Host "✓ SQL Server created" -ForegroundColor Green

# Create SQL Database
Write-Host "[3/10] Creating SQL Database..." -ForegroundColor Yellow
az sql db create `
    --resource-group $RESOURCE_GROUP `
    --server $SQL_SERVER `
    --name $SQL_DB `
    --service-objective Basic | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create SQL Database" -ForegroundColor Red
    exit 1
}
Write-Host "✓ SQL Database created" -ForegroundColor Green

# Configure firewall (allow Azure services)
Write-Host "[4/10] Configuring SQL Server firewall (Azure services)..." -ForegroundColor Yellow
az sql server firewall-rule create `
    --resource-group $RESOURCE_GROUP `
    --server $SQL_SERVER `
    --name AllowAzureServices `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0 | Out-Null
Write-Host "✓ Firewall rule for Azure services added" -ForegroundColor Green

# Get your public IP and add firewall rule
Write-Host "[5/10] Getting your public IP and adding firewall rule..." -ForegroundColor Yellow
try {
    $MY_IP = (Invoke-WebRequest -Uri "https://ifconfig.me" -UseBasicParsing).Content.Trim()
    az sql server firewall-rule create `
        --resource-group $RESOURCE_GROUP `
        --server $SQL_SERVER `
        --name AllowMyIP `
        --start-ip-address $MY_IP `
        --end-ip-address $MY_IP | Out-Null
    Write-Host "✓ Firewall rule for your IP ($MY_IP) added" -ForegroundColor Green
}
catch {
    Write-Host "WARNING: Could not get public IP. You may need to add it manually." -ForegroundColor Yellow
}

# Create Container Registry
Write-Host "[6/10] Creating Azure Container Registry..." -ForegroundColor Yellow
az acr create `
    --resource-group $RESOURCE_GROUP `
    --name $ACR_NAME `
    --sku Basic `
    --admin-enabled true | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create Container Registry" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Container Registry created" -ForegroundColor Green

# Create App Service Plan
Write-Host "[7/10] Creating App Service Plan..." -ForegroundColor Yellow
az appservice plan create `
    --name $APP_SERVICE_PLAN `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --sku B1 `
    --is-linux | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create App Service Plan" -ForegroundColor Red
    exit 1
}
Write-Host "✓ App Service Plan created" -ForegroundColor Green

# Create App Services
Write-Host "[8/10] Creating App Services..." -ForegroundColor Yellow
az webapp create `
    --resource-group $RESOURCE_GROUP `
    --plan $APP_SERVICE_PLAN `
    --name $USER_SERVICE_NAME `
    --runtime "DOTNETCORE:8.0" | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create User Service" -ForegroundColor Red
    exit 1
}

az webapp create `
    --resource-group $RESOURCE_GROUP `
    --plan $APP_SERVICE_PLAN `
    --name $PRODUCT_SERVICE_NAME `
    --runtime "DOTNETCORE:8.0" | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create Product Service" -ForegroundColor Red
    exit 1
}
Write-Host "✓ App Services created" -ForegroundColor Green

# Get connection string
Write-Host "[9/10] Configuring connection strings and app settings..." -ForegroundColor Yellow
$CONNECTION_STRING_RAW = az sql db show-connection-string `
    --server $SQL_SERVER `
    --name $SQL_DB `
    --client ado.net
$CONNECTION_STRING = $CONNECTION_STRING_RAW -replace '<username>', $SQL_ADMIN -replace '<password>', $SQL_PASSWORD

# Configure app settings
az webapp config appsettings set `
    --resource-group $RESOURCE_GROUP `
    --name $USER_SERVICE_NAME `
    --settings `
    ConnectionStrings__DefaultConnection="$CONNECTION_STRING" `
    ASPNETCORE_ENVIRONMENT=Production | Out-Null

az webapp config appsettings set `
    --resource-group $RESOURCE_GROUP `
    --name $PRODUCT_SERVICE_NAME `
    --settings `
    ConnectionStrings__DefaultConnection="$CONNECTION_STRING" `
    ASPNETCORE_ENVIRONMENT=Production | Out-Null
Write-Host "✓ App settings configured" -ForegroundColor Green

# Enable CORS
Write-Host "[10/10] Enabling CORS..." -ForegroundColor Yellow
az webapp cors add `
    --resource-group $RESOURCE_GROUP `
    --name $USER_SERVICE_NAME `
    --allowed-origins "*" | Out-Null

az webapp cors add `
    --resource-group $RESOURCE_GROUP `
    --name $PRODUCT_SERVICE_NAME `
    --allowed-origins "*" | Out-Null
Write-Host "✓ CORS enabled" -ForegroundColor Green

# Save variables to file
Write-Host ""
Write-Host "Saving variables to azure-vars.txt..." -ForegroundColor Yellow
@"
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
"@ | Out-File -FilePath "azure-vars.txt" -Encoding utf8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Resources created:" -ForegroundColor Yellow
Write-Host "  Resource Group: $RESOURCE_GROUP"
Write-Host "  SQL Server: $SQL_SERVER"
Write-Host "  SQL Database: $SQL_DB"
Write-Host "  Container Registry: $ACR_NAME"
Write-Host "  User Service: https://$USER_SERVICE_NAME.azurewebsites.net"
Write-Host "  Product Service: https://$PRODUCT_SERVICE_NAME.azurewebsites.net"
Write-Host ""
Write-Host "Variables saved to: azure-vars.txt" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Run database migrations"
Write-Host "  2. Deploy your APIs to App Services"
Write-Host "  3. Create Static Web App for Angular"
Write-Host ""

