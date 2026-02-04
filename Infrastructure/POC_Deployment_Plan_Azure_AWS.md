# POC Deployment Plan: Angular + .NET Core Microservices to Azure & AWS

## Overview

This POC demonstrates deploying a simple full-stack application to both Azure and AWS in 2-3 hours. We'll use the same application codebase and deploy it to both clouds using CLI tools and Cursor AI assistance.

**Time Estimate:** 2-3 hours
- Setup & Application Creation: 30-45 minutes
- Azure Deployment: 45-60 minutes
- AWS Deployment: 45-60 minutes
- Testing & Verification: 15-30 minutes

---

## Application Structure

### Simple Application Stack

```
MyPOCApp/
├── Frontend/
│   └── AngularApp/          # Simple Angular app
├── Backend/
│   ├── UserService/        # .NET Core API - User management
│   ├── ProductService/     # .NET Core API - Product catalog
│   └── OrderService/       # .NET Core API - Order processing (optional)
└── Database/
    └── SQL Server          # Simple database schema
```

### Application Features (Minimal)

**Angular App:**
- Home page with API status
- User list page (calls UserService)
- Product list page (calls ProductService)
- Simple navigation

**UserService API:**
- GET /api/users - List users
- GET /api/users/{id} - Get user by ID
- POST /api/users - Create user

**ProductService API:**
- GET /api/products - List products
- GET /api/products/{id} - Get product by ID
- POST /api/products - Create product

---

## Prerequisites Setup

### Required Tools

```bash
# Install .NET 8 SDK
winget install Microsoft.DotNet.SDK.8

# Install Node.js 18+
winget install OpenJS.NodeJS.LTS

# Install Angular CLI
npm install -g @angular/cli

# Install Azure CLI
winget install Microsoft.AzureCLI

# Install AWS CLI
winget install Amazon.AWSCLI

# Install Docker Desktop (for containerization)
winget install Docker.DockerDesktop
```

### Account Setup

1. **Azure Account:**
   - Create free Azure account: https://azure.microsoft.com/free
   - Login: `az login`
   - Set subscription: `az account set --subscription "Your Subscription"`

2. **AWS Account:**
   - Create AWS account: https://aws.amazon.com/free
   - Configure: `aws configure`
   - Enter Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)

3. **GitHub Account:**
   - Create GitHub repository for the POC
   - We'll use GitHub Actions for CI/CD

---

## Phase 1: Create Application (30-45 minutes)

### Step 1.1: Create Angular Application

**Cursor AI Prompt:**
```
Create a simple Angular  application with:
- Angular Material UI components
- Routing with 3 pages: Home, Users, Products
- HTTP client service to call APIs
- Environment configuration for API URLs
- Simple navigation menu
- Error handling
- Loading indicators

Make it production-ready with proper structure.
```

**Manual Steps:**
```bash
# Create Angular app
ng new AngularApp --routing --style=css
cd AngularApp

# Install Angular Material
ng add @angular/material

# Create components
ng generate component home
ng generate component users
ng generate component products
ng generate service services/api
```

**Expected Output:**
- Angular app with routing
- 3 pages (Home, Users, Products)
- API service for HTTP calls
- Environment files (environment.ts, environment.prod.ts)

---

### Step 1.2: Create UserService API

**Cursor AI Prompt:**
```
Create a .NET 8 Web API project called UserService with:
- Entity Framework Core with SQL Server
- User entity with: Id (int), Name (string), Email (string), CreatedDate (DateTime)
- DbContext with Users DbSet
- UserController with endpoints:
  - GET /api/users - Get all users
  - GET /api/users/{id} - Get user by ID
  - POST /api/users - Create user
- CORS enabled for Angular app
- Swagger/OpenAPI enabled
- Health check endpoint
- Connection string in appsettings.json
- Dockerfile for containerization

Include migration scripts and seed data for 5 sample users.
```

**Manual Steps:**
```bash
# Create .NET Web API
dotnet new webapi -n UserService
cd UserService

# Add Entity Framework packages
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.EntityFrameworkCore.Design

# Add health checks
dotnet add package Microsoft.Extensions.Diagnostics.HealthChecks
```

**Expected Output:**
- UserService API project
- User entity and DbContext
- UserController with CRUD endpoints
- appsettings.json with connection string
- Dockerfile
- Migration files

---

### Step 1.3: Create ProductService API

**Cursor AI Prompt:**
```
Create a .NET 8 Web API project called ProductService with:
- Entity Framework Core with SQL Server
- Product entity with: Id (int), Name (string), Description (string), Price (decimal), Stock (int)
- DbContext with Products DbSet
- ProductController with endpoints:
  - GET /api/products - Get all products
  - GET /api/products/{id} - Get product by ID
  - POST /api/products - Create product
- CORS enabled for Angular app
- Swagger/OpenAPI enabled
- Health check endpoint
- Connection string in appsettings.json
- Dockerfile for containerization

Include migration scripts and seed data for 5 sample products.
```

**Manual Steps:**
```bash
# Create .NET Web API
dotnet new webapi -n ProductService
cd ProductService

# Add Entity Framework packages
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.EntityFrameworkCore.Design

# Add health checks
dotnet add package Microsoft.Extensions.Diagnostics.HealthChecks
```

**Expected Output:**
- ProductService API project
- Product entity and DbContext
- ProductController with CRUD endpoints
- appsettings.json with connection string
- Dockerfile
- Migration files

---

### Step 1.4: Update Angular App to Call APIs

**Cursor AI Prompt:**
```
Update the Angular app to:
- Call UserService API endpoints in the Users component
- Call ProductService API endpoints in the Products component
- Display data in tables using Angular Material
- Show loading states and error messages
- Update environment.prod.ts with placeholder API URLs
- Add proper error handling and retry logic
- Make the UI responsive and clean
```

**Expected Output:**
- Users component displays users from UserService
- Products component displays products from ProductService
- Proper error handling and loading states
- Environment configuration

---

### Step 1.5: Create Dockerfiles

**Cursor AI Prompt:**
```
Create optimized Dockerfiles for:
1. UserService - Multi-stage build for .NET 8 API
2. ProductService - Multi-stage build for .NET 8 API
3. AngularApp - Multi-stage build for Angular (static files)

All should be production-ready with proper caching and minimal image sizes.
```

**Expected Output:**
- Dockerfile for UserService
- Dockerfile for ProductService
- Dockerfile for AngularApp (or nginx config for static files)

---

## Phase 2: Azure Deployment (45-60 minutes)

### Step 2.1: Create Azure Resources

**Cursor AI Prompt:**
```
Generate Azure CLI commands to create:
1. Resource group: poc-deployment-rg
2. Azure SQL Server and Database (Basic tier)
3. Azure Container Registry (Basic tier)
4. Azure App Service Plan (Basic B1)
5. Two App Services for UserService and ProductService
6. Azure Static Web App for Angular
7. Configure firewall rules for SQL Server
8. Get connection strings and store in variables

All in East US region. Use variables for resource names.
```

**Easy Deployment Scripts:**

We've created ready-to-run scripts for you! Choose based on your platform:

**Option 1: PowerShell Script (Windows - Recommended)**
```powershell
# Navigate to scripts folder
cd Infrastructure/scripts

# Run the script
.\deploy-azure-resources.ps1
```

**Option 2: Bash Script (Linux/Mac/Git Bash/WSL)**
```bash
# Navigate to scripts folder
cd Infrastructure/scripts

# Make script executable (first time only)
chmod +x deploy-azure-resources.sh

# Run the script
./deploy-azure-resources.sh
```

**What the scripts do:**
- ✅ Check if Azure CLI is installed
- ✅ Verify you're logged in (prompts login if needed)
- ✅ Create all Azure resources automatically
- ✅ Configure all settings (connection strings, CORS, etc.)
- ✅ Save all variables to `azure-vars.txt` for later use
- ✅ Show progress and error handling
- ✅ Display summary of created resources

**Manual Commands (Alternative):**

If you prefer to run commands manually, here are the individual commands:

```bash
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

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create SQL Server
az sql server create \
  --name $SQL_SERVER \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --admin-user $SQL_ADMIN \
  --admin-password $SQL_PASSWORD

# Create SQL Database
az sql db create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER \
  --name $SQL_DB \
  --service-objective Basic

# Configure firewall (allow Azure services)
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Get your public IP
MY_IP=$(curl -s ifconfig.me)
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER \
  --name AllowMyIP \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP

# Create Container Registry
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# Create App Service Plan
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku B1 \
  --is-linux

# Create App Services
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $USER_SERVICE_NAME \
  --runtime "DOTNETCORE:8.0"

az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $PRODUCT_SERVICE_NAME \
  --runtime "DOTNETCORE:8.0"

# Get connection string
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
    ASPNETCORE_ENVIRONMENT=Production

az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $PRODUCT_SERVICE_NAME \
  --settings \
    ConnectionStrings__DefaultConnection="$CONNECTION_STRING" \
    ASPNETCORE_ENVIRONMENT=Production

# Enable CORS
az webapp cors add \
  --resource-group $RESOURCE_GROUP \
  --name $USER_SERVICE_NAME \
  --allowed-origins "*"

az webapp cors add \
  --resource-group $RESOURCE_GROUP \
  --name $PRODUCT_SERVICE_NAME \
  --allowed-origins "*"

# Save variables to file
echo "RESOURCE_GROUP=$RESOURCE_GROUP" > azure-vars.txt
echo "SQL_SERVER=$SQL_SERVER" >> azure-vars.txt
echo "SQL_DB=$SQL_DB" >> azure-vars.txt
echo "ACR_NAME=$ACR_NAME" >> azure-vars.txt
echo "USER_SERVICE_NAME=$USER_SERVICE_NAME" >> azure-vars.txt
echo "PRODUCT_SERVICE_NAME=$PRODUCT_SERVICE_NAME" >> azure-vars.txt
echo "CONNECTION_STRING=$CONNECTION_STRING" >> azure-vars.txt
```

---

### Step 2.2: Deploy APIs to Azure App Service

**Cursor AI Prompt:**
```
Create a GitHub Actions workflow to deploy UserService and ProductService to Azure App Service:
- Trigger on push to main branch
- Build .NET applications
- Run Entity Framework migrations
- Deploy to Azure App Service using publish profile
- Set connection strings from Azure
- Handle deployment slots for zero-downtime

Include steps to run migrations before deployment.
```

**GitHub Actions Workflow (.github/workflows/deploy-azure-apis.yml):**
```yaml
name: Deploy APIs to Azure

on:
  push:
    branches: [main]
    paths:
      - 'Backend/**'

jobs:
  deploy-user-service:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
      
      - name: Restore dependencies
        run: dotnet restore Backend/UserService/UserService.csproj
      
      - name: Build
        run: dotnet build Backend/UserService/UserService.csproj --configuration Release
      
      - name: Publish
        run: dotnet publish Backend/UserService/UserService.csproj -c Release -o ./publish
      
      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ secrets.AZURE_USER_SERVICE_NAME }}
          publish-profile: ${{ secrets.AZURE_USER_SERVICE_PUBLISH_PROFILE }}
          package: ./publish

  deploy-product-service:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
      
      - name: Restore dependencies
        run: dotnet restore Backend/ProductService/ProductService.csproj
      
      - name: Build
        run: dotnet build Backend/ProductService/ProductService.csproj --configuration Release
      
      - name: Publish
        run: dotnet publish Backend/ProductService/ProductService.csproj -c Release -o ./publish
      
      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ secrets.AZURE_PRODUCT_SERVICE_NAME }}
          publish-profile: ${{ secrets.AZURE_PRODUCT_SERVICE_PUBLISH_PROFILE }}
          package: ./publish
```

**Manual Steps:**
```bash
# Get publish profiles
az webapp deployment list-publishing-profiles \
  --name $USER_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --xml > user-service-publish-profile.xml

az webapp deployment list-publishing-profiles \
  --name $PRODUCT_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --xml > product-service-publish-profile.xml

# Add to GitHub Secrets:
# AZURE_USER_SERVICE_NAME
# AZURE_USER_SERVICE_PUBLISH_PROFILE (content of XML file)
# AZURE_PRODUCT_SERVICE_NAME
# AZURE_PRODUCT_SERVICE_PUBLISH_PROFILE (content of XML file)
```

---

### Step 2.3: Run Database Migrations

**Cursor AI Prompt:**
```
Create a script to run Entity Framework migrations on Azure SQL Database:
- Connect to Azure SQL using connection string
- Run migrations for both UserService and ProductService
- Seed initial data
- Handle errors gracefully
- Can be run locally or in GitHub Actions

Provide both PowerShell and Bash versions.
```

**Migration Script:**
```bash
# Run migrations locally
cd Backend/UserService
dotnet ef database update --connection "$CONNECTION_STRING"

cd ../ProductService
dotnet ef database update --connection "$CONNECTION_STRING"
```

---

### Step 2.4: Deploy Angular to Azure Static Web Apps

**Cursor AI Prompt:**
```
Create a GitHub Actions workflow to deploy Angular app to Azure Static Web Apps:
- Build Angular app with production configuration
- Set API URLs from environment variables
- Deploy to Azure Static Web Apps
- Configure navigation fallback for SPA routing
- Handle CORS and API proxy configuration

Include staticwebapp.config.json for routing.
```

**GitHub Actions Workflow (.github/workflows/deploy-azure-angular.yml):**
```yaml
name: Deploy Angular to Azure Static Web Apps

on:
  push:
    branches: [main]
    paths:
      - 'Frontend/**'

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
        working-directory: ./Frontend/AngularApp
      
      - name: Build
        run: npm run build -- --configuration production
        working-directory: ./Frontend/AngularApp
        env:
          API_USER_SERVICE_URL: ${{ secrets.AZURE_USER_SERVICE_URL }}
          API_PRODUCT_SERVICE_URL: ${{ secrets.AZURE_PRODUCT_SERVICE_URL }}
      
      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "Frontend/AngularApp"
          output_location: "dist/AngularApp"
```

**Create Static Web App:**
```bash
# Create Static Web App
az staticwebapp create \
  --name poc-angular-app \
  --resource-group $RESOURCE_GROUP \
  --location eastus2 \
  --sku Free

# Get deployment token
az staticwebapp secrets list \
  --name poc-angular-app \
  --resource-group $RESOURCE_GROUP

# Add to GitHub Secrets: AZURE_STATIC_WEB_APPS_API_TOKEN
```

**staticwebapp.config.json:**
```json
{
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/assets/*", "/*.{css,scss,js,png,gif,ico,jpg,svg}"]
  },
  "routes": [
    {
      "route": "/api/*",
      "allowedRoles": ["*"]
    }
  ],
  "responseOverrides": {
    "404": {
      "rewrite": "/index.html",
      "statusCode": 200
    }
  }
}
```

---

### Step 2.5: Update Angular Environment

**Cursor AI Prompt:**
```
Update Angular environment.prod.ts to use Azure API URLs:
- UserService API URL from Azure App Service
- ProductService API URL from Azure App Service
- Handle CORS and HTTPS
- Add error handling for API calls
```

**Update environment.prod.ts:**
```typescript
export const environment = {
  production: true,
  apiUserServiceUrl: 'https://poc-user-service-xxxxx.azurewebsites.net/api',
  apiProductServiceUrl: 'https://poc-product-service-xxxxx.azurewebsites.net/api'
};
```

---

### Step 2.6: Verify Azure Deployment

**Verification Steps:**
```bash
# Test UserService API
curl https://$USER_SERVICE_NAME.azurewebsites.net/api/users

# Test ProductService API
curl https://$PRODUCT_SERVICE_NAME.azurewebsites.net/api/products

# Test Angular app
# Open browser to Static Web App URL
```

---

## Phase 3: AWS Deployment (45-60 minutes)

### Step 3.1: Create AWS Resources

**Cursor AI Prompt:**
```
Generate AWS CLI commands to create:
1. RDS SQL Server instance (db.t3.micro for free tier)
2. ECR repositories for UserService and ProductService
3. ECS cluster (Fargate)
4. Application Load Balancer
5. Security groups
6. IAM roles for ECS tasks
7. S3 bucket for Angular app
8. CloudFront distribution

All in us-east-1 region. Use variables for resource names.
```

**AWS CLI Commands:**
```bash
# Set variables
REGION="us-east-1"
PROJECT_NAME="poc-deployment"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text --region $REGION)
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[0:2].SubnetId" --output text --region $REGION)
SUBNET1=$(echo $SUBNET_IDS | cut -d' ' -f1)
SUBNET2=$(echo $SUBNET_IDS | cut -d' ' -f2)

# Create RDS Subnet Group
aws rds create-db-subnet-group \
  --db-subnet-group-name ${PROJECT_NAME}-subnet-group \
  --db-subnet-group-description "Subnet group for POC" \
  --subnet-ids $SUBNET1 $SUBNET2 \
  --region $REGION

# Create RDS SQL Server instance
aws rds create-db-instance \
  --db-instance-identifier ${PROJECT_NAME}-sql-server \
  --db-instance-class db.t3.micro \
  --engine sqlserver-ex \
  --master-username admin \
  --master-user-password P@ssw0rd123! \
  --allocated-storage 20 \
  --db-subnet-group-name ${PROJECT_NAME}-subnet-group \
  --vpc-security-group-ids $(aws ec2 create-security-group \
    --group-name ${PROJECT_NAME}-rds-sg \
    --description "RDS Security Group" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text \
    --region $REGION) \
  --region $REGION

# Wait for RDS to be available (takes 10-15 minutes)
aws rds wait db-instance-available \
  --db-instance-identifier ${PROJECT_NAME}-sql-server \
  --region $REGION

# Create ECR repositories
aws ecr create-repository \
  --repository-name ${PROJECT_NAME}/user-service \
  --region $REGION

aws ecr create-repository \
  --repository-name ${PROJECT_NAME}/product-service \
  --region $REGION

# Get ECR login
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${REGION}.amazonaws.com

# Create ECS cluster
aws ecs create-cluster \
  --cluster-name ${PROJECT_NAME}-cluster \
  --region $REGION

# Create Application Load Balancer
ALB_SG=$(aws ec2 create-security-group \
  --group-name ${PROJECT_NAME}-alb-sg \
  --description "ALB Security Group" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text \
  --region $REGION)

# Allow HTTP/HTTPS
aws ec2 authorize-security-group-ingress \
  --group-id $ALB_SG \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --region $REGION

aws ec2 authorize-security-group-ingress \
  --group-id $ALB_SG \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0 \
  --region $REGION

# Create ALB
aws elbv2 create-load-balancer \
  --name ${PROJECT_NAME}-alb \
  --subnets $SUBNET1 $SUBNET2 \
  --security-groups $ALB_SG \
  --region $REGION

# Create S3 bucket for Angular
BUCKET_NAME="${PROJECT_NAME}-angular-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Enable static website hosting
aws s3 website s3://$BUCKET_NAME \
  --index-document index.html \
  --error-document index.html

# Save variables
echo "REGION=$REGION" > aws-vars.txt
echo "PROJECT_NAME=$PROJECT_NAME" >> aws-vars.txt
echo "BUCKET_NAME=$BUCKET_NAME" >> aws-vars.txt
echo "VPC_ID=$VPC_ID" >> aws-vars.txt
echo "SUBNET1=$SUBNET1" >> aws-vars.txt
echo "SUBNET2=$SUBNET2" >> aws-vars.txt
```

---

### Step 3.2: Build and Push Docker Images to ECR

**Cursor AI Prompt:**
```
Create a script to build and push Docker images to AWS ECR:
- Build UserService Docker image
- Build ProductService Docker image
- Tag images with latest and git SHA
- Push to ECR repositories
- Handle authentication
- Include error handling
```

**Build and Push Script:**
```bash
# Load variables
source aws-vars.txt

# Get ECR login
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${REGION}.amazonaws.com

ECR_REGISTRY=$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${REGION}.amazonaws.com

# Build and push UserService
cd Backend/UserService
docker build -t ${PROJECT_NAME}/user-service:latest .
docker tag ${PROJECT_NAME}/user-service:latest $ECR_REGISTRY/${PROJECT_NAME}/user-service:latest
docker push $ECR_REGISTRY/${PROJECT_NAME}/user-service:latest

# Build and push ProductService
cd ../ProductService
docker build -t ${PROJECT_NAME}/product-service:latest .
docker tag ${PROJECT_NAME}/product-service:latest $ECR_REGISTRY/${PROJECT_NAME}/product-service:latest
docker push $ECR_REGISTRY/${PROJECT_NAME}/product-service:latest
```

---

### Step 3.3: Create ECS Task Definitions

**Cursor AI Prompt:**
```
Create ECS task definitions for UserService and ProductService:
- Use Fargate launch type
- Configure CPU and memory (512 CPU, 1024 MB memory)
- Set environment variables for connection string
- Configure logging to CloudWatch
- Set health check
- Include IAM role for ECS tasks

Provide JSON task definition files.
```

**Task Definition (user-service-task.json):**
```json
{
  "family": "user-service-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "user-service",
      "image": "ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/poc-deployment/user-service:latest",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "ASPNETCORE_ENVIRONMENT",
          "value": "Production"
        },
        {
          "name": "ConnectionStrings__DefaultConnection",
          "value": "Server=RDS_ENDPOINT,1433;Database=poc-db;User Id=admin;Password=P@ssw0rd123!;TrustServerCertificate=True;"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/user-service",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:80/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ]
}
```

**Create Task Definitions:**
```bash
# Create CloudWatch log groups
aws logs create-log-group --log-group-name /ecs/user-service --region $REGION
aws logs create-log-group --log-group-name /ecs/product-service --region $REGION

# Register task definitions
aws ecs register-task-definition \
  --cli-input-json file://user-service-task.json \
  --region $REGION

aws ecs register-task-definition \
  --cli-input-json file://product-service-task.json \
  --region $REGION
```

---

### Step 3.4: Create ECS Services

**Cursor AI Prompt:**
```
Create ECS services for UserService and ProductService:
- Use Fargate launch type
- Connect to Application Load Balancer
- Configure target groups
- Set desired count to 1
- Configure health checks
- Set up auto-scaling (optional)

Provide AWS CLI commands.
```

**Create ECS Services:**
```bash
# Get ALB ARN
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --names ${PROJECT_NAME}-alb \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text \
  --region $REGION)

# Create target groups
USER_TG_ARN=$(aws elbv2 create-target-group \
  --name ${PROJECT_NAME}-user-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id $VPC_ID \
  --target-type ip \
  --health-check-path /health \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text \
  --region $REGION)

PRODUCT_TG_ARN=$(aws elbv2 create-target-group \
  --name ${PROJECT_NAME}-product-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id $VPC_ID \
  --target-type ip \
  --health-check-path /health \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text \
  --region $REGION)

# Create ECS services
aws ecs create-service \
  --cluster ${PROJECT_NAME}-cluster \
  --service-name user-service \
  --task-definition user-service-task \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET1,$SUBNET2],assignPublicIp=ENABLED,securityGroups=[$ALB_SG]}" \
  --load-balancers "targetGroupArn=$USER_TG_ARN,containerName=user-service,containerPort=80" \
  --region $REGION

aws ecs create-service \
  --cluster ${PROJECT_NAME}-cluster \
  --service-name product-service \
  --task-definition product-service-task \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET1,$SUBNET2],assignPublicIp=ENABLED,securityGroups=[$ALB_SG]}" \
  --load-balancers "targetGroupArn=$PRODUCT_TG_ARN,containerName=product-service,containerPort=80" \
  --region $REGION
```

---

### Step 3.5: Deploy Angular to S3 + CloudFront

**Cursor AI Prompt:**
```
Create a GitHub Actions workflow to deploy Angular app to S3 and CloudFront:
- Build Angular app with AWS API URLs
- Upload to S3 bucket
- Invalidate CloudFront cache
- Configure S3 bucket policy for public read
- Handle routing for SPA

Include steps to configure CloudFront distribution.
```

**GitHub Actions Workflow (.github/workflows/deploy-aws-angular.yml):**
```yaml
name: Deploy Angular to AWS S3 + CloudFront

on:
  push:
    branches: [main]
    paths:
      - 'Frontend/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
        working-directory: ./Frontend/AngularApp
      
      - name: Build
        run: npm run build -- --configuration production
        working-directory: ./Frontend/AngularApp
        env:
          API_USER_SERVICE_URL: ${{ secrets.AWS_USER_SERVICE_URL }}
          API_PRODUCT_SERVICE_URL: ${{ secrets.AWS_PRODUCT_SERVICE_URL }}
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy to S3
        run: |
          aws s3 sync ./Frontend/AngularApp/dist/AngularApp s3://${{ secrets.AWS_S3_BUCKET }} --delete
      
      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.AWS_CLOUDFRONT_DISTRIBUTION_ID }} \
            --paths "/*"
```

**Create CloudFront Distribution:**
```bash
# Create CloudFront distribution
aws cloudfront create-distribution \
  --distribution-config file://cloudfront-config.json \
  --region $REGION
```

**cloudfront-config.json:**
```json
{
  "CallerReference": "poc-angular-$(date +%s)",
  "Comment": "POC Angular App",
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-poc-angular",
        "DomainName": "${BUCKET_NAME}.s3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-poc-angular",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"]
    },
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    },
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000
  },
  "CustomErrorResponses": {
    "Quantity": 1,
    "Items": [
      {
        "ErrorCode": 404,
        "ResponsePagePath": "/index.html",
        "ResponseCode": "200",
        "ErrorCachingMinTTL": 300
      }
    ]
  },
  "Enabled": true
}
```

---

### Step 3.6: Update Angular Environment for AWS

**Cursor AI Prompt:**
```
Update Angular environment.prod.ts to use AWS API URLs:
- UserService API URL from ALB target group
- ProductService API URL from ALB target group
- Handle CORS and HTTPS
- Add error handling for API calls
```

**Update environment.prod.ts:**
```typescript
export const environment = {
  production: true,
  apiUserServiceUrl: 'https://ALB-DNS-NAME.elb.us-east-1.amazonaws.com/api',
  apiProductServiceUrl: 'https://ALB-DNS-NAME.elb.us-east-1.amazonaws.com/api'
};
```

---

### Step 3.7: Run Database Migrations on RDS

**Cursor AI Prompt:**
```
Create a script to run Entity Framework migrations on AWS RDS:
- Connect to RDS SQL Server using connection string
- Run migrations for both UserService and ProductService
- Seed initial data
- Handle connection timeouts
- Can be run locally with proper security group access
```

**Migration Script:**
```bash
# Get RDS endpoint
RDS_ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier ${PROJECT_NAME}-sql-server \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text \
  --region $REGION)

# Update security group to allow your IP
MY_IP=$(curl -s ifconfig.me)
RDS_SG=$(aws rds describe-db-instances \
  --db-instance-identifier ${PROJECT_NAME}-sql-server \
  --query 'DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId' \
  --output text \
  --region $REGION)

aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG \
  --protocol tcp \
  --port 1433 \
  --cidr ${MY_IP}/32 \
  --region $REGION

# Run migrations
CONNECTION_STRING="Server=${RDS_ENDPOINT},1433;Database=poc-db;User Id=admin;Password=P@ssw0rd123!;TrustServerCertificate=True;"

cd Backend/UserService
dotnet ef database update --connection "$CONNECTION_STRING"

cd ../ProductService
dotnet ef database update --connection "$CONNECTION_STRING"
```

---

### Step 3.8: Verify AWS Deployment

**Verification Steps:**
```bash
# Get ALB DNS name
ALB_DNS=$(aws elbv2 describe-load-balancers \
  --names ${PROJECT_NAME}-alb \
  --query 'LoadBalancers[0].DNSName' \
  --output text \
  --region $REGION)

# Test APIs
curl http://$ALB_DNS/api/users
curl http://$ALB_DNS/api/products

# Test Angular app
# Open CloudFront distribution URL in browser
```

---

## Phase 4: Testing & Verification (15-30 minutes)

### Step 4.1: Test Azure Deployment

**Test Checklist:**
- [ ] Angular app loads at Static Web App URL
- [ ] Users page displays data from UserService
- [ ] Products page displays data from ProductService
- [ ] API endpoints return data
- [ ] Health checks work
- [ ] CORS is configured correctly

### Step 4.2: Test AWS Deployment

**Test Checklist:**
- [ ] Angular app loads at CloudFront URL
- [ ] Users page displays data from UserService
- [ ] Products page displays data from ProductService
- [ ] API endpoints return data
- [ ] Health checks work
- [ ] CORS is configured correctly

### Step 4.3: Compare Performance

**Compare:**
- Response times
- Load times
- API latency
- Overall user experience

---

## Quick Reference: Cursor AI Prompts

### For Creating Applications

1. **"Create a simple Angular 18 application with routing, Material UI, and HTTP client service"**
2. **"Create a .NET 8 Web API with Entity Framework Core, SQL Server, CRUD endpoints, and Dockerfile"**
3. **"Create GitHub Actions workflows for deploying to Azure App Service and AWS ECS"**
4. **"Create Dockerfiles for .NET 8 APIs and Angular static files"**

### For Deployment

1. **"Generate Azure CLI commands to create App Services, SQL Database, and Static Web App"**
2. **"Generate AWS CLI commands to create ECS cluster, RDS, S3, and CloudFront"**
3. **"Create scripts to run Entity Framework migrations on Azure SQL and AWS RDS"**
4. **"Create GitHub Actions workflows for CI/CD to Azure and AWS"**

### For Troubleshooting

1. **"Why is my API returning CORS errors? How to fix?"**
2. **"How to configure connection strings for Azure SQL Database?"**
3. **"How to set up health checks for ECS tasks?"**
4. **"How to configure Angular routing for SPA on S3/Static Web Apps?"**

---

## Time Breakdown

| Phase | Task | Time |
|-------|------|------|
| **Phase 1** | Create Applications | 30-45 min |
| **Phase 2** | Azure Deployment | 45-60 min |
| **Phase 3** | AWS Deployment | 45-60 min |
| **Phase 4** | Testing | 15-30 min |
| **Total** | | **2-3 hours** |

---

## Cleanup Commands

### Azure Cleanup
```bash
# Delete resource group (deletes everything)
az group delete --name poc-deployment-rg --yes --no-wait
```

### AWS Cleanup
```bash
# Delete ECS services
aws ecs update-service --cluster poc-deployment-cluster --service user-service --desired-count 0
aws ecs update-service --cluster poc-deployment-cluster --service product-service --desired-count 0

# Delete ECS cluster
aws ecs delete-cluster --cluster poc-deployment-cluster

# Delete RDS instance
aws rds delete-db-instance --db-instance-identifier poc-deployment-sql-server --skip-final-snapshot

# Delete S3 bucket
aws s3 rb s3://BUCKET_NAME --force

# Delete CloudFront distribution
aws cloudfront delete-distribution --id DISTRIBUTION_ID --if-match ETAG

# Delete ALB
aws elbv2 delete-load-balancer --load-balancer-arn ALB_ARN
```

---

## Tips for Success

1. **Use Cursor AI extensively** - It will save you hours of coding
2. **Test locally first** - Make sure apps work before deploying
3. **Use variables** - Store resource names in variables for reuse
4. **Check logs** - Use Azure Portal and CloudWatch for debugging
5. **Start simple** - Get basic deployment working, then add features
6. **Document as you go** - Note any issues or customizations

---

## Common Issues & Solutions

### Issue: CORS Errors
**Solution:** Configure CORS in API startup to allow Angular origin

### Issue: Database Connection Timeouts
**Solution:** Check firewall rules and security groups

### Issue: Deployment Failures
**Solution:** Check GitHub Actions logs, verify secrets are set

### Issue: Angular Routing 404
**Solution:** Configure URL rewrite/navigation fallback

---

## Next Steps After POC

1. **Add Authentication** - Implement JWT/OAuth
2. **Add Monitoring** - Application Insights, CloudWatch
3. **Add CI/CD** - Full automated pipelines
4. **Add Scaling** - Auto-scaling configuration
5. **Add Security** - WAF, DDoS protection
6. **Add Backup** - Automated backup strategies

---

*Good luck with your POC! Use Cursor AI to speed up development and deployment.*
