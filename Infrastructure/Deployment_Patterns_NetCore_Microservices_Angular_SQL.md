# Deployment Patterns & Best Options for .NET Core Microservices, Angular, and SQL Server

## Introduction

This guide covers deployment patterns and best practices for modern full-stack applications built with:
- **.NET Core Microservices** (Backend APIs)
- **Angular** (Frontend SPA)
- **SQL Server** (Database)

We'll explore real-world deployment options, patterns, and strategies used in production environments.

---

## Part 1: Understanding Deployment Architecture

### Application Stack Overview

```
┌─────────────────┐
│   Angular SPA   │  (Frontend - Static Files)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  API Gateway /  │
│  Load Balancer  │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌──────┐  ┌──────┐
│ API  │  │ API  │  (.NET Core Microservices)
│  1   │  │  2   │
└──┬───┘  └──┬───┘
   │         │
   └────┬────┘
        │
        ▼
┌─────────────────┐
│   SQL Server    │  (Database)
└─────────────────┘
```

### Key Deployment Considerations

1. **Scalability** - Handle varying loads
2. **High Availability** - Minimize downtime
3. **Security** - Protect data and APIs
4. **Performance** - Optimize response times
5. **Cost Efficiency** - Balance performance and cost
6. **Maintainability** - Easy updates and rollbacks

---

## Part 2: Deployment Patterns for .NET Core Microservices

### Pattern 1: Container-Based Deployment (Docker + Kubernetes)

**Most Common in Production**

#### Architecture
```
┌─────────────────────────────────────┐
│         Kubernetes Cluster          │
│  ┌──────────┐  ┌──────────┐        │
│  │   API    │  │   API    │        │
│  │ Service  │  │ Service  │        │
│  │  (Pod)   │  │  (Pod)   │        │
│  └──────────┘  └──────────┘        │
│       │              │              │
│       └──────┬───────┘              │
│              │                      │
│         ┌────▼────┐                 │
│         │ Service │                 │
│         │  (SVC)  │                 │
│         └─────────┘                 │
└─────────────────────────────────────┘
```

#### Implementation Steps

**1. Containerize .NET Core API**
```dockerfile
# Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["UserService/UserService.csproj", "UserService/"]
RUN dotnet restore "UserService/UserService.csproj"
COPY . .
WORKDIR "/src/UserService"
RUN dotnet build "UserService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "UserService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "UserService.dll"]
```

**2. Kubernetes Deployment Manifest**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: your-registry.azurecr.io/user-service:latest
        ports:
        - containerPort: 80
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ConnectionStrings__DefaultConnection
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: connection-string
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: production
spec:
  type: ClusterIP
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
```

**3. Kubernetes Ingress (External Access)**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: production
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - api.yourdomain.com
    secretName: api-tls
  rules:
  - host: api.yourdomain.com
    http:
      paths:
      - path: /api/users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 80
```

#### Pros
- ✅ High scalability (auto-scaling)
- ✅ Self-healing (automatic restarts)
- ✅ Rolling updates (zero downtime)
- ✅ Resource efficiency
- ✅ Industry standard

#### Cons
- ❌ Complex setup initially
- ❌ Requires Kubernetes knowledge
- ❌ Higher operational overhead

#### Best For
- Large-scale applications
- Multiple microservices
- Need for auto-scaling
- Cloud-native environments

---

### Pattern 2: Azure App Service (PaaS)

**Easiest for .NET Core - Most Common for Small to Medium Scale**

#### Architecture
```
┌─────────────────────────────────────┐
│      Azure App Service Plan         │
│  ┌──────────┐  ┌──────────┐        │
│  │   API    │  │   API    │        │
│  │ Service  │  │ Service  │        │
│  │  (Slot)  │  │  (Slot)  │        │
│  └──────────┘  └──────────┘        │
│       │              │              │
│       └──────┬───────┘              │
│              │                      │
│         ┌────▼────┐                 │
│         │  App    │                 │
│         │ Gateway │                 │
│         └─────────┘                 │
└─────────────────────────────────────┘
```

#### Implementation Steps

**1. Deploy via Azure CLI**
```bash
# Create App Service Plan
az appservice plan create \
  --name myAppServicePlan \
  --resource-group myResourceGroup \
  --sku B1 \
  --is-linux

# Create Web App
az webapp create \
  --resource-group myResourceGroup \
  --plan myAppServicePlan \
  --name myuserapi \
  --runtime "DOTNETCORE:8.0"

# Configure app settings
az webapp config appsettings set \
  --resource-group myResourceGroup \
  --name myuserapi \
  --settings \
    ASPNETCORE_ENVIRONMENT=Production \
    ConnectionStrings__DefaultConnection="Server=..."

# Deploy from Git
az webapp deployment source config \
  --name myuserapi \
  --resource-group myResourceGroup \
  --repo-url https://github.com/yourrepo/api.git \
  --branch main \
  --manual-integration
```

**2. Deployment Slots (Blue-Green Deployment)**
```bash
# Create staging slot
az webapp deployment slot create \
  --resource-group myResourceGroup \
  --name myuserapi \
  --slot staging

# Deploy to staging
az webapp deployment source config \
  --name myuserapi \
  --resource-group myResourceGroup \
  --slot staging \
  --repo-url https://github.com/yourrepo/api.git

# Swap slots (zero downtime)
az webapp deployment slot swap \
  --resource-group myResourceGroup \
  --name myuserapi \
  --slot staging \
  --target-slot production
```

**3. Auto-Scaling Configuration**
```bash
# Enable auto-scale
az monitor autoscale create \
  --resource-group myResourceGroup \
  --resource /subscriptions/{sub-id}/resourceGroups/myResourceGroup/providers/Microsoft.Web/serverfarms/myAppServicePlan \
  --name myAutoscaleSettings \
  --min-count 2 \
  --max-count 10 \
  --count 2

# Add scale-out rule
az monitor autoscale rule create \
  --resource-group myResourceGroup \
  --autoscale-name myAutoscaleSettings \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 1
```

#### Pros
- ✅ Easy setup and management
- ✅ Built-in CI/CD integration
- ✅ Automatic scaling
- ✅ Deployment slots (zero downtime)
- ✅ Built-in monitoring
- ✅ SSL certificates included

#### Cons
- ❌ Less control than containers
- ❌ Vendor lock-in (Azure)
- ❌ Can be expensive at scale

#### Best For
- Small to medium applications
- Quick deployment needs
- Teams new to DevOps
- Azure-native applications

---

### Pattern 3: Azure Container Apps

**Modern Serverless Containers - Growing in Popularity**

#### Architecture
```
┌─────────────────────────────────────┐
│    Azure Container Apps Environment │
│  ┌──────────┐  ┌──────────┐        │
│  │   API    │  │   API    │        │
│  │ Service  │  │ Service  │        │
│  │(Revision)│  │(Revision)│        │
│  └──────────┘  └──────────┘        │
│       │              │              │
│       └──────┬───────┘              │
│              │                      │
│         ┌────▼────┐                 │
│         │  Ingress│                 │
│         └─────────┘                 │
└─────────────────────────────────────┘
```

#### Implementation Steps

**1. Create Container App Environment**
```bash
# Create environment
az containerapp env create \
  --name mycontainerappenv \
  --resource-group myResourceGroup \
  --location eastus

# Create container app
az containerapp create \
  --name user-service \
  --resource-group myResourceGroup \
  --environment mycontainerappenv \
  --image your-registry.azurecr.io/user-service:latest \
  --target-port 80 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 10 \
  --cpu 0.5 \
  --memory 1.0Gi \
  --env-vars \
    ASPNETCORE_ENVIRONMENT=Production \
    ConnectionStrings__DefaultConnection="Server=..."
```

**2. Update Container App**
```bash
# Update image
az containerapp update \
  --name user-service \
  --resource-group myResourceGroup \
  --image your-registry.azurecr.io/user-service:v2

# Scale manually
az containerapp update \
  --name user-service \
  --resource-group myResourceGroup \
  --min-replicas 3 \
  --max-replicas 20
```

#### Pros
- ✅ Serverless (pay per use)
- ✅ Auto-scaling to zero
- ✅ Easy container deployment
- ✅ Built-in ingress
- ✅ Revision management

#### Cons
- ❌ Newer service (less mature)
- ❌ Some limitations vs full Kubernetes

#### Best For
- Microservices architectures
- Variable traffic patterns
- Cost optimization
- Modern cloud-native apps

---

### Pattern 4: Azure Service Fabric

**Enterprise-Grade - For Complex Microservices**

#### Architecture
```
┌─────────────────────────────────────┐
│      Service Fabric Cluster         │
│  ┌──────────┐  ┌──────────┐        │
│  │   API    │  │   API    │        │
│  │ Service  │  │ Service  │        │
│  │(Stateless)│ │(Stateless)│        │
│  └──────────┘  └──────────┘        │
│       │              │              │
│       └──────┬───────┘              │
│              │                      │
│         ┌────▼────┐                 │
│         │Reverse  │                 │
│         │ Proxy   │                 │
│         └─────────┘                 │
└─────────────────────────────────────┘
```

#### Best For
- Large enterprise applications
- Stateful services
- Complex microservices
- High reliability requirements

---

## Part 3: Deployment Patterns for Angular Applications

### Pattern 1: Static Website Hosting (Most Common)

#### Option A: Azure Static Web Apps (Recommended)

**Best for Angular + API Integration**

```bash
# Create Static Web App
az staticwebapp create \
  --name myangularapp \
  --resource-group myResourceGroup \
  --location eastus2 \
  --sku Standard

# Deploy from GitHub
az staticwebapp appsettings set \
  --name myangularapp \
  --resource-group myResourceGroup \
  --setting-names \
    API_URL=https://api.yourdomain.com
```

**Configuration (staticwebapp.config.json)**
```json
{
  "routes": [
    {
      "route": "/api/*",
      "allowedRoles": ["authenticated"]
    }
  ],
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/images/*.{png,jpg,gif}", "/css/*"]
  },
  "responseOverrides": {
    "404": {
      "rewrite": "/index.html",
      "statusCode": 200
    }
  },
  "globalHeaders": {
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "X-XSS-Protection": "1; mode=block"
  }
}
```

**Build Configuration (angular.json)**
```json
{
  "projects": {
    "my-app": {
      "architect": {
        "build": {
          "options": {
            "outputPath": "dist/my-app",
            "baseHref": "/",
            "deployUrl": "/"
          },
          "configurations": {
            "production": {
              "optimization": true,
              "outputHashing": "all",
              "sourceMap": false,
              "namedChunks": false,
              "aot": true,
              "extractLicenses": true,
              "vendorChunk": false,
              "buildOptimizer": true,
              "fileReplacements": [
                {
                  "replace": "src/environments/environment.ts",
                  "with": "src/environments/environment.prod.ts"
                }
              ]
            }
          }
        }
      }
    }
  }
}
```

#### Option B: Azure Blob Storage + CDN

**Cost-Effective for High Traffic**

```bash
# Create storage account
az storage account create \
  --name myangularstorage \
  --resource-group myResourceGroup \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2

# Enable static website
az storage blob service-properties update \
  --account-name myangularstorage \
  --static-website \
  --404-document error.html \
  --index-document index.html

# Upload files
az storage blob upload-batch \
  --account-name myangularstorage \
  --source ./dist/my-app \
  --destination '$web' \
  --overwrite

# Create CDN profile
az cdn profile create \
  --name mycdnprofile \
  --resource-group myResourceGroup \
  --sku Standard_Microsoft

# Create CDN endpoint
az cdn endpoint create \
  --name myangularcdn \
  --profile-name mycdnprofile \
  --resource-group myResourceGroup \
  --origin myangularstorage.blob.core.windows.net \
  --origin-host-header myangularstorage.blob.core.windows.net
```

#### Option C: Azure App Service (Static Files)

**When You Need More Control**

```bash
# Create App Service
az webapp create \
  --resource-group myResourceGroup \
  --plan myAppServicePlan \
  --name myangularapp

# Configure for static files
az webapp config set \
  --resource-group myResourceGroup \
  --name myangularapp \
  --always-on true

# Deploy files
az webapp deployment source config-zip \
  --resource-group myResourceGroup \
  --name myangularapp \
  --src ./dist/my-app.zip
```

#### Pros of Static Hosting
- ✅ Fast loading (CDN)
- ✅ Low cost
- ✅ Easy deployment
- ✅ High scalability
- ✅ Security (no server to hack)

#### Cons
- ❌ No server-side rendering (use Angular Universal if needed)
- ❌ API must be separate

---

### Pattern 2: Angular Universal (SSR) Deployment

**For SEO and Performance**

#### Azure App Service with Node.js

```bash
# Create App Service with Node.js runtime
az webapp create \
  --resource-group myResourceGroup \
  --plan myAppServicePlan \
  --name myangularssr \
  --runtime "NODE:18-lts"

# Configure startup command
az webapp config set \
  --resource-group myResourceGroup \
  --name myangularssr \
  --startup-file "node dist/server.js"
```

**Dockerfile for Angular Universal**
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build:ssr

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm ci --production
EXPOSE 4000
CMD ["node", "dist/server.js"]
```

---

## Part 4: SQL Server Deployment Patterns

### Pattern 1: Azure SQL Database (PaaS) - Most Common

**Fully Managed - Recommended for Most Cases**

#### Architecture
```
┌─────────────────────────────────────┐
│      Azure SQL Database             │
│  ┌──────────────────────────────┐   │
│  │   Primary Database           │   │
│  │   (Active Geo-Replication)   │   │
│  └──────────────────────────────┘   │
│              │                       │
│              ▼                       │
│  ┌──────────────────────────────┐   │
│  │   Secondary Database         │   │
│  │   (Failover Group)           │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

#### Implementation Steps

**1. Create SQL Server and Database**
```bash
# Create SQL Server
az sql server create \
  --name mysqlserver \
  --resource-group myResourceGroup \
  --location eastus \
  --admin-user sqladmin \
  --admin-password YourStrong@Passw0rd

# Create Database
az sql db create \
  --resource-group myResourceGroup \
  --server mysqlserver \
  --name mydatabase \
  --service-objective S2 \
  --backup-storage-redundancy Geo

# Configure firewall
az sql server firewall-rule create \
  --resource-group myResourceGroup \
  --server mysqlserver \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

**2. Connection String Format**
```
Server=tcp:mysqlserver.database.windows.net,1433;Initial Catalog=mydatabase;Persist Security Info=False;User ID=sqladmin;Password=YourStrong@Passw0rd;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
```

**3. Enable Geo-Replication (High Availability)**
```bash
# Create failover group
az sql failover-group create \
  --name myFailoverGroup \
  --resource-group myResourceGroup \
  --server mysqlserver \
  --partner-server mysecondaryserver \
  --partner-resource-group myResourceGroup \
  --database mydatabase \
  --failover-policy Automatic
```

**4. Configure Auto-Scaling**
```bash
# Update database tier
az sql db update \
  --resource-group myResourceGroup \
  --server mysqlserver \
  --name mydatabase \
  --service-objective S3
```

#### Service Tiers

**DTU-Based (Simple)**
- **Basic**: $5/month - Dev/Test
- **Standard**: $15-465/month - Production
- **Premium**: $465-4650/month - High Performance

**vCore-Based (Flexible)**
- **General Purpose**: Balanced compute/storage
- **Business Critical**: High availability, fast failover
- **Hyperscale**: Auto-scales to 100TB+

#### Pros
- ✅ Fully managed (no maintenance)
- ✅ Automatic backups
- ✅ Built-in high availability
- ✅ Auto-scaling
- ✅ Security features (encryption, auditing)
- ✅ Point-in-time restore

#### Cons
- ❌ Cost can be high at scale
- ❌ Less control than VM-based SQL

---

### Pattern 2: Azure SQL Managed Instance

**For Lift-and-Shift or Advanced Features**

#### Best For
- Need for SQL Server Agent
- Database Mail
- Cross-database queries
- Linked servers
- CLR assemblies

#### Implementation
```bash
# Create Managed Instance
az sql mi create \
  --name mymanagedinstance \
  --resource-group myResourceGroup \
  --location eastus \
  --admin-user sqladmin \
  --admin-password YourStrong@Passw0rd \
  --subnet /subscriptions/{sub-id}/resourceGroups/myResourceGroup/providers/Microsoft.Network/virtualNetworks/myVnet/subnets/default \
  --vnet-name myVnet \
  --sku-name GP_Gen5 \
  --storage-size 32GB
```

---

### Pattern 3: SQL Server on Azure VM

**Maximum Control and Compatibility**

#### Best For
- Need for full SQL Server features
- Custom configurations
- On-premises migration
- Cost optimization (bring your own license)

#### Implementation
```bash
# Create VM with SQL Server
az vm create \
  --resource-group myResourceGroup \
  --name mysqlvm \
  --image MicrosoftSQLServer:SQL2019-WS2019:Enterprise:latest \
  --admin-username azureuser \
  --admin-password YourStrong@Passw0rd \
  --size Standard_DS2_v2

# Configure SQL Server
az sql vm create \
  --name mysqlvm \
  --resource-group myResourceGroup \
  --location eastus \
  --license-type PAYG
```

---

## Part 5: Complete Deployment Architectures

### Architecture 1: Small to Medium Scale (Most Common)

```
┌─────────────────────────────────────────────────────────┐
│                    Azure Front Door / CDN                │
│                    (SSL Termination)                     │
└──────────────┬──────────────────────┬───────────────────┘
               │                      │
       ┌───────▼───────┐      ┌───────▼───────┐
       │   Angular     │      │  API Gateway  │
       │ Static Web App│      │  (App Service)│
       │   (CDN)       │      └───────┬───────┘
       └───────────────┘              │
                              ┌───────┴───────┐
                              │               │
                        ┌─────▼─────┐   ┌─────▼─────┐
                        │   User    │   │  Order    │
                        │  Service  │   │  Service  │
                        │(App Service)│ │(App Service)│
                        └─────┬─────┘   └─────┬─────┘
                              │               │
                              └───────┬───────┘
                                      │
                              ┌───────▼───────┐
                              │  Azure SQL    │
                              │   Database    │
                              │  (PaaS)       │
                              └───────────────┘
```

**Deployment Steps:**
1. Deploy Angular to Azure Static Web Apps
2. Deploy APIs to Azure App Service (multiple instances)
3. Create Azure SQL Database
4. Configure API Gateway (Azure API Management optional)
5. Set up Azure Front Door for global distribution

---

### Architecture 2: Large Scale / Enterprise

```
┌─────────────────────────────────────────────────────────┐
│              Azure Front Door (Global CDN)               │
└──────────────┬──────────────────────┬───────────────────┘
               │                      │
       ┌───────▼───────┐      ┌───────▼───────┐
       │   Angular     │      │  API Management│
       │  (Blob+CDN)   │      │   (Gateway)    │
       └───────────────┘      └───────┬───────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
            ┌───────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
            │   User       │   │   Order     │   │  Payment    │
            │  Service     │   │  Service    │   │  Service    │
            │ (K8s/ACA)    │   │ (K8s/ACA)   │   │ (K8s/ACA)   │
            └──────┬───────┘   └──────┬──────┘   └──────┬──────┘
                   │                 │                 │
                   └─────────────────┼─────────────────┘
                                     │
                        ┌────────────▼────────────┐
                        │   Azure SQL Database    │
                        │   (Failover Group)      │
                        │   + Read Replicas       │
                        └─────────────────────────┘
```

**Deployment Steps:**
1. Deploy Angular to Blob Storage + CDN
2. Deploy APIs to Kubernetes or Container Apps
3. Set up API Management for routing and policies
4. Configure Azure SQL with failover groups
5. Implement Azure Front Door for global load balancing

---

### Architecture 3: Microservices with Event-Driven Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Azure Front Door                      │
└──────────────┬──────────────────────┬───────────────────┘
               │                      │
       ┌───────▼───────┐      ┌───────▼───────┐
       │   Angular     │      │  API Gateway   │
       │  (Static)     │      │  (App Service) │
       └───────────────┘      └───────┬───────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
            ┌───────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
            │   User       │   │   Order     │   │  Inventory  │
            │  Service     │   │  Service    │   │  Service    │
            │ (Container)  │   │ (Container) │   │ (Container) │
            └──────┬───────┘   └──────┬──────┘   └──────┬──────┘
                   │                 │                 │
                   └─────────┬───────┴─────────────────┘
                             │
                    ┌────────▼────────┐
                    │  Service Bus /  │
                    │  Event Grid     │
                    │  (Messaging)    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Azure SQL DB   │
                    │  (Per Service)  │
                    └─────────────────┘
```

---

## Part 6: CI/CD Deployment Pipelines

### Azure DevOps Pipeline for .NET Core API

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
    - main
    - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'
  dockerRegistryServiceConnection: 'AzureContainerRegistry'
  imageRepository: 'userservice'
  containerRegistry: 'yourregistry.azurecr.io'
  dockerfilePath: '$(Build.SourcesDirectory)/UserService/Dockerfile'
  tag: '$(Build.BuildId)'

stages:
- stage: Build
  displayName: Build and Push Docker Image
  jobs:
  - job: Build
    displayName: Build
    steps:
    - task: Docker@2
      displayName: Build and push image
      inputs:
        command: buildAndPush
        repository: $(imageRepository)
        dockerfile: $(dockerfilePath)
        containerRegistry: $(dockerRegistryServiceConnection)
        tags: |
          $(tag)
          latest

- stage: Deploy
  displayName: Deploy to Kubernetes
  dependsOn: Build
  condition: succeeded()
  jobs:
  - deployment: Deploy
    displayName: Deploy
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: Kubernetes@1
            displayName: Deploy to Kubernetes
            inputs:
              connectionType: 'Kubernetes Service Connection'
              kubernetesServiceEndpoint: 'K8s-Connection'
              namespace: 'production'
              command: 'apply'
              arguments: '-f $(Pipeline.Workspace)/k8s/deployment.yaml'
```

### GitHub Actions for Angular

```yaml
# .github/workflows/deploy.yml
name: Deploy Angular to Azure Static Web Apps

on:
  push:
    branches:
      - main

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
      
      - name: Build
        run: npm run build --if-present
        env:
          NODE_ENV: production
      
      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/"
          output_location: "dist/my-app"
```

---

## Part 7: Best Practices and Recommendations

### Security Best Practices

**1. API Security**
```csharp
// Program.cs - .NET Core API
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = "https://login.microsoftonline.com/{tenant-id}";
        options.Audience = "{client-id}";
    });

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAngular",
        policy =>
        {
            policy.WithOrigins("https://yourangularapp.azurestaticapps.net")
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        });
});
```

**2. Database Security**
- Use Azure Key Vault for connection strings
- Enable Always Encrypted for sensitive data
- Use Managed Identity when possible
- Enable SQL Database auditing
- Configure firewall rules properly

**3. Angular Security**
- Use environment variables for API URLs
- Implement proper CORS policies
- Use HTTPS only
- Implement Content Security Policy (CSP)
- Sanitize user inputs

### Performance Optimization

**1. API Performance**
- Implement response caching
- Use async/await properly
- Optimize database queries
- Implement pagination
- Use compression middleware

**2. Angular Performance**
- Enable production builds with optimizations
- Implement lazy loading
- Use OnPush change detection
- Optimize bundle size
- Enable HTTP caching

**3. Database Performance**
- Create proper indexes
- Use connection pooling
- Implement read replicas for read-heavy workloads
- Monitor query performance
- Use appropriate service tier

### Monitoring and Logging

**1. Application Insights**
```csharp
// .NET Core API
builder.Services.AddApplicationInsightsTelemetry();

// Logging
logger.LogInformation("User {UserId} accessed endpoint {Endpoint}", 
    userId, endpoint);
```

**2. Azure Monitor**
- Set up alerts for errors
- Monitor performance metrics
- Track custom events
- Create dashboards

**3. Angular Monitoring**
```typescript
// Track errors
import { ErrorHandler } from '@angular/core';

export class AppErrorHandler implements ErrorHandler {
  handleError(error: any): void {
    // Send to Application Insights
    console.error('Error:', error);
  }
}
```

---

## Part 8: Cost Optimization Strategies

### 1. Right-Sizing Resources
- Start with lower tiers, scale up as needed
- Use auto-scaling to handle peaks
- Scale down during off-hours
- Use reserved instances for predictable workloads

### 2. Choose Appropriate Services
- Static hosting for Angular (cheapest)
- App Service for small APIs (moderate cost)
- Container Apps for variable traffic (pay per use)
- Kubernetes for large scale (higher cost but flexible)

### 3. Database Optimization
- Use DTU-based for simple needs
- Use vCore for better control
- Implement read replicas instead of scaling up
- Archive old data to cheaper storage

### 4. CDN and Caching
- Use CDN for static assets
- Implement API response caching
- Use Redis Cache for frequently accessed data

---

## Part 9: Disaster Recovery and High Availability

### High Availability Setup

**1. Multi-Region Deployment**
```
Primary Region (East US)
├── Angular (Static Web App)
├── APIs (App Service - 3 instances)
└── SQL Database (Primary)

Secondary Region (West US)
├── Angular (Static Web App - replicated)
├── APIs (App Service - standby)
└── SQL Database (Secondary - Geo-Replication)
```

**2. Failover Configuration**
- Azure SQL Failover Groups (automatic failover)
- Traffic Manager for DNS failover
- Azure Front Door for global load balancing

**3. Backup Strategy**
- SQL Database: Automatic backups (7-35 days retention)
- Application: Source control + CI/CD
- Configuration: Azure Key Vault backups

---

## Part 10: Real-World Deployment Scenarios

### Scenario 1: Startup / MVP (Low Cost)

**Architecture:**
- Angular: Azure Static Web Apps (Free tier)
- APIs: Azure App Service (Basic tier - $13/month)
- Database: Azure SQL Database (Basic - $5/month)

**Total: ~$18/month**

### Scenario 2: Small Business (Moderate Scale)

**Architecture:**
- Angular: Azure Static Web Apps (Standard - $9/month)
- APIs: Azure App Service (Standard S1 - 2 instances - $150/month)
- Database: Azure SQL Database (S2 - $150/month)
- CDN: Azure Front Door (Standard - $20/month)

**Total: ~$329/month**

### Scenario 3: Enterprise (High Scale)

**Architecture:**
- Angular: Blob Storage + CDN (~$50/month)
- APIs: Azure Kubernetes Service (~$500/month)
- Database: Azure SQL Database (Business Critical P2 - $2000/month)
- API Management: Standard tier (~$200/month)
- Monitoring: Application Insights (~$100/month)

**Total: ~$2850/month**

---

## Part 11: Migration Strategies

### On-Premises to Azure

**1. Lift and Shift**
- Move VMs to Azure VMs
- Migrate SQL Server to Azure VM
- Keep same architecture

**2. Modernize**
- Containerize applications
- Move to PaaS services
- Implement cloud-native patterns

**3. Hybrid Approach**
- Keep some on-premises
- Move new services to cloud
- Gradually migrate

---

## Part 12: Troubleshooting Common Issues

### Issue 1: CORS Errors

**Solution:**
```csharp
// API - Allow specific origin
services.AddCors(options =>
{
    options.AddPolicy("AllowAngular",
        builder => builder
            .WithOrigins("https://yourapp.azurestaticapps.net")
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials());
});
```

### Issue 2: Database Connection Timeouts

**Solution:**
- Increase connection timeout
- Use connection pooling
- Check firewall rules
- Verify connection string

### Issue 3: Angular Routing Issues (404)

**Solution:**
```json
// staticwebapp.config.json
{
  "navigationFallback": {
    "rewrite": "/index.html"
  }
}
```

### Issue 4: API Performance Issues

**Solution:**
- Enable response caching
- Optimize database queries
- Use async/await properly
- Scale out horizontally

---

## Conclusion

### Recommended Patterns by Scale

**Small Scale (< 1000 users):**
- Angular: Azure Static Web Apps
- APIs: Azure App Service
- Database: Azure SQL Database (Basic/Standard)

**Medium Scale (1000-10000 users):**
- Angular: Azure Static Web Apps + CDN
- APIs: Azure App Service (multiple instances)
- Database: Azure SQL Database (Standard/Premium)

**Large Scale (10000+ users):**
- Angular: Blob Storage + CDN
- APIs: Azure Kubernetes Service or Container Apps
- Database: Azure SQL Database (Premium/Business Critical)

### Key Takeaways

1. **Start Simple**: Begin with PaaS services (App Service, Static Web Apps)
2. **Scale Gradually**: Move to containers/Kubernetes when needed
3. **Use Managed Services**: Prefer PaaS over IaaS for databases
4. **Implement CI/CD**: Automate deployments from day one
5. **Monitor Everything**: Set up Application Insights early
6. **Plan for HA**: Design for high availability from the start
7. **Optimize Costs**: Right-size resources and use reserved instances

### Next Steps

1. Choose architecture based on your scale
2. Set up CI/CD pipelines
3. Implement monitoring and alerts
4. Plan for disaster recovery
5. Document your deployment process
6. Train your team on the chosen patterns

---

*"The best deployment pattern is the one that fits your team, scale, and requirements. Start simple, scale as needed."*
