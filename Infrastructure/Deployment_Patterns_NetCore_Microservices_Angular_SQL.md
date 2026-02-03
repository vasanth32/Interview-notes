# Deployment Patterns & Best Options for .NET Core Microservices, Angular, and SQL Server

## Introduction

This guide covers deployment patterns and best practices for modern full-stack applications built with:
- **.NET Core Microservices** (Backend APIs)
- **Angular** (Frontend SPA)
- **SQL Server** (Database)

We'll explore real-world deployment options, patterns, and strategies used in production environments across Azure, AWS, and on-premise environments.

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

## Part 2: Azure Cloud Deployment Patterns

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

#### Deployment Flow

1. **Build Phase:**
   - Code is pushed to GitHub repository
   - GitHub Actions workflow triggers on push to main branch
   - Docker image is built using Dockerfile (multi-stage build)
   - Image is pushed to Azure Container Registry (ACR)

2. **Deploy Phase:**
   - Kubernetes deployment manifest is applied
   - Pods are created with specified replicas
   - Kubernetes Service (ClusterIP) exposes pods internally
   - Ingress controller routes external traffic to services
   - Health probes (liveness/readiness) monitor pod health

3. **Scaling Flow:**
   - Horizontal Pod Autoscaler (HPA) monitors CPU/memory metrics
   - When threshold exceeded, new pods are created
   - Load is distributed across pods via Service
   - When load decreases, pods are scaled down

4. **Update Flow:**
   - New image is pushed to ACR with new tag
   - Kubernetes performs rolling update (zero downtime)
   - Old pods are gradually replaced with new ones
   - If new version fails health checks, rollback occurs automatically

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-api-k8s.yml
name: Deploy .NET Core API to Kubernetes

on:
  push:
    branches: [main]
    paths:
      - 'UserService/**'

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Build and push Docker image
        run: |
          az acr build --registry ${{ secrets.ACR_NAME }} \
            --image user-service:${{ github.sha }} \
            --image user-service:latest \
            ./UserService
      
      - name: Deploy to Kubernetes
        uses: azure/k8s-deploy@v3
        with:
          manifests: |
            k8s/deployment.yaml
            k8s/service.yaml
            k8s/ingress.yaml
          images: |
            ${{ secrets.ACR_NAME }}.azurecr.io/user-service:${{ github.sha }}
          kubectl-version: 'latest'
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

#### Deployment Flow

1. **Initial Setup:**
   - App Service Plan is created (defines compute resources)
   - Web App is created and linked to the plan
   - Deployment slot (staging) is created for blue-green deployments
   - Application settings and connection strings are configured

2. **Deployment Flow:**
   - Code is pushed to GitHub
   - GitHub Actions workflow triggers
   - Application is built using .NET SDK
   - Built artifacts are deployed to staging slot
   - Health checks verify deployment success
   - Slot swap occurs (staging → production) for zero downtime

3. **Scaling Flow:**
   - Auto-scale rules monitor CPU, memory, or request metrics
   - When threshold exceeded, new instances are added
   - Load balancer distributes traffic across instances
   - Instances are removed when load decreases

4. **Update Flow:**
   - New code is deployed to staging slot
   - Smoke tests run on staging
   - Warm-up requests prepare the slot
   - Slot swap exchanges staging and production
   - Old production becomes staging for quick rollback

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-api-appservice.yml
name: Deploy .NET Core API to App Service

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
      
      - name: Build
        run: dotnet build --configuration Release
      
      - name: Publish
        run: dotnet publish -c Release -o ./publish
      
      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ secrets.AZURE_WEBAPP_NAME }}
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
          package: ./publish
      
      - name: Swap deployment slots
        uses: azure/CLI@v1
        with:
          inlineScript: |
            az webapp deployment slot swap \
              --resource-group ${{ secrets.AZURE_RESOURCE_GROUP }} \
              --name ${{ secrets.AZURE_WEBAPP_NAME }} \
              --slot staging \
              --target-slot production
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

#### Deployment Flow

1. **Environment Setup:**
   - Container Apps Environment is created (shared infrastructure)
   - Log Analytics workspace is linked for monitoring
   - Environment provides networking and scaling capabilities

2. **Deployment Flow:**
   - Container image is built and pushed to ACR
   - Container App is created or updated with new revision
   - Ingress is configured (internal or external)
   - Environment variables and secrets are injected
   - New revision becomes active (traffic splitting possible)

3. **Scaling Flow:**
   - Scale rules monitor HTTP requests, CPU, or memory
   - Containers scale from min-replicas to max-replicas
   - Can scale to zero when no traffic (cost savings)
   - Scaling happens automatically based on metrics

4. **Update Flow:**
   - New revision is created with updated image
   - Traffic can be split between revisions (A/B testing)
   - Gradual rollout: 10% → 50% → 100%
   - Old revision can be kept for quick rollback

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-api-containerapp.yml
name: Deploy to Azure Container Apps

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Build and push image
        run: |
          az acr build --registry ${{ secrets.ACR_NAME }} \
            --image user-service:${{ github.sha }} \
            ./UserService
      
      - name: Deploy to Container App
        run: |
          az containerapp update \
            --name user-service \
            --resource-group ${{ secrets.RESOURCE_GROUP }} \
            --image ${{ secrets.ACR_NAME }}.azurecr.io/user-service:${{ github.sha }}
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

#### Deployment Flow

1. **Cluster Setup:**
   - Service Fabric cluster is provisioned
   - Nodes are configured (primary node type, secondary node types)
   - Cluster security is configured (certificates, Azure AD)

2. **Application Deployment:**
   - Application package is created (contains service packages)
   - Package is uploaded to cluster image store
   - Application is registered in cluster
   - Application instance is created and started
   - Services are deployed across nodes

3. **Update Flow:**
   - New application version is packaged
   - Rolling upgrade is initiated
   - Upgrade domains are updated one at a time
   - Health checks ensure each domain is healthy before proceeding
   - Automatic rollback if health checks fail

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

#### Deployment Flow

1. **Initial Setup:**
   - Static Web App resource is created in Azure
   - GitHub repository is connected
   - Build configuration is set (Angular build commands)
   - Custom domain is configured (optional)
   - API backend URL is set as environment variable

2. **Build and Deploy Flow:**
   - Code is pushed to GitHub
   - GitHub Actions workflow automatically triggers
   - Node.js environment is set up
   - Dependencies are installed (npm ci)
   - Angular application is built (ng build --configuration production)
   - Built files are deployed to Azure CDN
   - Preview environments are created for pull requests

3. **Routing Flow:**
   - User requests a route (e.g., /dashboard)
   - Static Web App checks for file at that path
   - If not found, navigationFallback rewrites to /index.html
   - Angular router handles client-side routing
   - API calls are proxied to backend API

4. **Update Flow:**
   - New code is merged to main branch
   - Automatic build and deployment occurs
   - CDN cache is invalidated
   - New version is live within minutes

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-angular-staticwebapp.yml
name: Deploy Angular to Azure Static Web Apps

on:
  push:
    branches: [main]
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [main]

jobs:
  build_and_deploy:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true
          lfs: false
      
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
          API_URL: ${{ secrets.API_URL }}
      
      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/"
          output_location: "dist/my-app"
          api_location: ""
```

#### Option B: Azure Blob Storage + CDN

**Cost-Effective for High Traffic**

#### Deployment Flow

1. **Storage Setup:**
   - Storage account is created
   - Static website hosting is enabled
   - $web container is configured as website root
   - CDN profile and endpoint are created
   - Custom domain is configured with SSL

2. **Deployment Flow:**
   - Angular app is built locally or in CI/CD
   - Built files are uploaded to $web container
   - CDN cache is purged (optional)
   - Files are served via CDN edge locations globally

3. **Update Flow:**
   - New build replaces files in blob storage
   - CDN cache is invalidated
   - Users get new version from nearest edge location

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-angular-blob.yml
name: Deploy Angular to Blob Storage

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install and build
        run: |
          npm ci
          npm run build
      
      - name: Upload to Azure Blob
        uses: azure/CLI@v1
        with:
          inlineScript: |
            az storage blob upload-batch \
              --account-name ${{ secrets.STORAGE_ACCOUNT }} \
              --account-key ${{ secrets.STORAGE_KEY }} \
              --source ./dist/my-app \
              --destination '$web' \
              --overwrite
      
      - name: Purge CDN cache
        run: |
          az cdn endpoint purge \
            --resource-group ${{ secrets.RESOURCE_GROUP }} \
            --profile-name ${{ secrets.CDN_PROFILE }} \
            --name ${{ secrets.CDN_ENDPOINT }} \
            --content-paths '/*'
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

#### Deployment Flow

1. **Build Phase:**
   - Angular Universal app is built (server and client bundles)
   - Server bundle runs Node.js server
   - Client bundle is served as static files

2. **Deployment Options:**
   - **Azure App Service (Node.js):** Deploy server bundle, configure startup command
   - **Container:** Dockerize Node.js server, deploy to Container Apps/K8s
   - **Azure Functions:** Serverless SSR (limited use cases)

3. **Runtime Flow:**
   - Request comes to Node.js server
   - Server renders Angular app with data
   - HTML is sent to browser
   - Client bundle hydrates the app
   - Subsequent navigation is client-side

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-angular-ssr.yml
name: Deploy Angular Universal

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install and build
        run: |
          npm ci
          npm run build:ssr
      
      - name: Deploy to App Service
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ secrets.AZURE_WEBAPP_NAME }}
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
          package: ./dist
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

#### Deployment Flow

1. **Database Creation:**
   - SQL Server logical server is created
   - Database is created with selected service tier
   - Firewall rules are configured (allow Azure services, specific IPs)
   - Connection string is generated and stored in Key Vault

2. **High Availability Setup:**
   - Failover group is created
   - Secondary database is created in different region
   - Automatic failover policy is configured
   - Connection string points to failover group endpoint

3. **Scaling Flow:**
   - Database can be scaled up/down manually or automatically
   - DTU or vCore model can be changed
   - Scaling operation is online (minimal downtime)
   - Read replicas can be added for read-heavy workloads

4. **Backup Flow:**
   - Automatic backups run continuously
   - Point-in-time restore available (up to 35 days)
   - Long-term retention can be configured
   - Backups are geo-redundant by default

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

#### Deployment Flow

1. **Instance Creation:**
   - Virtual network and subnet are prepared
   - Managed Instance is created (takes 4-6 hours)
   - Instance is configured with compute and storage
   - Database migration occurs (using DMS or backup/restore)

2. **Features Available:**
   - SQL Server Agent for job scheduling
   - Database Mail for email notifications
   - Cross-database queries
   - Linked servers
   - CLR assemblies

#### Best For
- Need for SQL Server Agent
- Database Mail
- Cross-database queries
- Linked servers
- CLR assemblies

---

### Pattern 3: SQL Server on Azure VM

**Maximum Control and Compatibility**

#### Deployment Flow

1. **VM Creation:**
   - VM with SQL Server image is created
   - Storage is configured (premium SSD recommended)
   - Network security groups are configured
   - SQL Server is configured (authentication, ports)

2. **High Availability Setup:**
   - Always On Availability Groups can be configured
   - Multiple VMs in availability set
   - Load balancer for read traffic
   - Backup to Azure Blob Storage

#### Best For
- Need for full SQL Server features
- Custom configurations
- On-premises migration
- Cost optimization (bring your own license)

---

## Part 5: AWS Cloud Deployment Patterns

### Pattern 1: AWS ECS (Elastic Container Service)

**Container Orchestration - Most Common for Microservices**

#### Architecture
```
┌─────────────────────────────────────┐
│         Application Load Balancer   │
└──────────────┬─────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
    ▼                     ▼
┌─────────┐         ┌─────────┐
│ ECS     │         │ ECS     │
│ Service │         │ Service │
│ (Task)  │         │ (Task)  │
└─────────┘         └─────────┘
    │                     │
    └──────────┬──────────┘
               │
        ┌──────▼──────┐
        │   RDS       │
        │ SQL Server  │
        └─────────────┘
```

#### Deployment Flow

1. **Infrastructure Setup:**
   - ECS Cluster is created (Fargate or EC2)
   - Application Load Balancer (ALB) is created
   - Target groups are configured
   - Security groups allow traffic from ALB to tasks
   - ECR (Elastic Container Registry) repository is created

2. **Deployment Flow:**
   - Docker image is built and pushed to ECR
   - Task definition is created/updated (CPU, memory, environment variables)
   - ECS Service is created/updated with new task definition
   - Service maintains desired number of tasks
   - ALB health checks verify task health
   - Rolling deployment replaces tasks gradually

3. **Scaling Flow:**
   - Auto Scaling is configured based on CPU/memory/request count
   - CloudWatch alarms trigger scaling events
   - New tasks are launched when threshold exceeded
   - Tasks are terminated when load decreases
   - ALB distributes traffic across healthy tasks

4. **Update Flow:**
   - New task definition is created with updated image
   - ECS Service is updated with new task definition
   - Rolling update strategy replaces tasks one by one
   - Health checks ensure new tasks are healthy before old ones are stopped
   - Automatic rollback if deployment fails

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-aws-ecs.yml
name: Deploy to AWS ECS

on:
  push:
    branches: [main]

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: user-service
  ECS_SERVICE: user-service
  ECS_CLUSTER: production-cluster
  ECS_TASK_DEFINITION: user-service-task

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG ./UserService
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT
      
      - name: Fill in the new image ID in the Amazon ECS task definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: ${{ env.ECS_TASK_DEFINITION }}.json
          container-name: user-service
          image: ${{ steps.build-image.outputs.image }}
      
      - name: Deploy Amazon ECS task definition
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: ${{ steps.task-def.outputs.task-definition }}
          service: ${{ env.ECS_SERVICE }}
          cluster: ${{ env.ECS_CLUSTER }}
          wait-for-service-stability: true
```

#### Pros
- ✅ Fully managed container orchestration
- ✅ Auto-scaling capabilities
- ✅ Integration with ALB
- ✅ Rolling deployments
- ✅ Fargate option (serverless)

#### Cons
- ❌ Less flexible than EKS (Kubernetes)
- ❌ AWS-specific

#### Best For
- Microservices on AWS
- Teams familiar with AWS
- Need for managed container service

---

### Pattern 2: AWS EKS (Elastic Kubernetes Service)

**Kubernetes on AWS - Enterprise Scale**

#### Architecture
```
┌─────────────────────────────────────┐
│         AWS Load Balancer          │
└──────────────┬─────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
    ▼                     ▼
┌─────────┐         ┌─────────┐
│   Pod   │         │   Pod   │
│ (Node)  │         │ (Node)  │
└─────────┘         └─────────┘
    │                     │
    └──────────┬──────────┘
               │
        ┌──────▼──────┐
        │   RDS       │
        │ SQL Server  │
        └─────────────┘
```

#### Deployment Flow

1. **Cluster Setup:**
   - EKS cluster is created (managed control plane)
   - Worker nodes are added (EC2 instances or Fargate)
   - IAM roles are configured for cluster and nodes
   - kubectl is configured to connect to cluster

2. **Deployment Flow:**
   - Docker image is built and pushed to ECR
   - Kubernetes manifests are applied (Deployment, Service, Ingress)
   - AWS Load Balancer Controller creates ALB/NLB
   - Pods are scheduled on nodes
   - Service exposes pods internally
   - Ingress routes external traffic

3. **Scaling Flow:**
   - Cluster Autoscaler adds/removes nodes
   - Horizontal Pod Autoscaler scales pods
   - Metrics come from CloudWatch or Prometheus

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-aws-eks.yml
name: Deploy to AWS EKS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Login to Amazon ECR
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build and push image
        run: |
          docker build -t $ECR_REGISTRY/user-service:${{ github.sha }} ./UserService
          docker push $ECR_REGISTRY/user-service:${{ github.sha }}
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
      
      - name: Configure kubectl
        run: |
          aws eks update-kubeconfig --name production-cluster --region us-east-1
      
      - name: Deploy to EKS
        run: |
          kubectl set image deployment/user-service \
            user-service=$ECR_REGISTRY/user-service:${{ github.sha }} \
            -n production
          kubectl rollout status deployment/user-service -n production
```

#### Pros
- ✅ Standard Kubernetes (portable)
- ✅ Managed control plane
- ✅ Integrates with AWS services
- ✅ High scalability

#### Cons
- ❌ More complex than ECS
- ❌ Higher cost (control plane + nodes)

#### Best For
- Large-scale Kubernetes workloads
- Multi-cloud portability
- Complex microservices

---

### Pattern 3: AWS Elastic Beanstalk

**PaaS for .NET Core - Easiest Option**

#### Architecture
```
┌─────────────────────────────────────┐
│      Elastic Beanstalk Environment │
│  ┌──────────┐  ┌──────────┐        │
│  │   EC2    │  │   EC2    │        │
│  │ Instance │  │ Instance │        │
│  └──────────┘  └──────────┘        │
│       │              │              │
│       └──────┬───────┘              │
│              │                      │
│         ┌────▼────┐                 │
│         │  ELB    │                 │
│         └─────────┘                 │
└─────────────────────────────────────┘
```

#### Deployment Flow

1. **Environment Setup:**
   - Elastic Beanstalk application is created
   - Environment is created (.NET Core platform)
   - EC2 instances are launched automatically
   - Application Load Balancer is created
   - Auto Scaling group is configured

2. **Deployment Flow:**
   - Application is packaged (zip file with .NET Core app)
   - Package is uploaded to S3 or deployed via Git
   - Beanstalk extracts and deploys to EC2 instances
   - Health checks verify deployment
   - Traffic is switched to new version

3. **Update Flow:**
   - New version is uploaded
   - Rolling update replaces instances gradually
   - Health checks ensure new instances are healthy
   - Old instances are terminated after successful deployment

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-aws-beanstalk.yml
name: Deploy to AWS Elastic Beanstalk

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
      
      - name: Build and publish
        run: |
          dotnet publish -c Release -o ./publish
          cd publish
          zip -r ../app.zip .
      
      - name: Deploy to Elastic Beanstalk
        uses: einaregilsson/beanstalk-deploy@v20
        with:
          aws_access_key: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws_secret_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          application_name: my-api
          environment_name: production
          version_label: ${{ github.sha }}
          region: us-east-1
          deployment_package: app.zip
```

#### Pros
- ✅ Very easy setup
- ✅ Automatic scaling
- ✅ Built-in monitoring
- ✅ Multiple deployment strategies

#### Cons
- ❌ Less control than ECS/EKS
- ❌ Platform-specific

#### Best For
- Quick deployments
- Small to medium applications
- Teams new to AWS

---

### Pattern 4: AWS Lambda + API Gateway

**Serverless - For Event-Driven or Low Traffic**

#### Architecture
```
┌─────────────────────────────────────┐
│         API Gateway                 │
└──────────────┬─────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
    ▼                     ▼
┌─────────┐         ┌─────────┐
│ Lambda  │         │ Lambda  │
│Function │         │Function │
└─────────┘         └─────────┘
```

#### Deployment Flow

1. **Function Setup:**
   - Lambda function is created (.NET 8 runtime)
   - IAM role is configured (permissions)
   - Environment variables are set
   - VPC configuration (if accessing RDS)

2. **API Gateway Setup:**
   - REST API or HTTP API is created
   - Resources and methods are defined
   - Integration with Lambda is configured
   - CORS is enabled
   - Custom domain is configured (optional)

3. **Deployment Flow:**
   - .NET Core app is packaged as Lambda deployment package
   - Function code is updated
   - API Gateway stage is deployed
   - Traffic routes to Lambda functions

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-aws-lambda.yml
name: Deploy to AWS Lambda

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
      
      - name: Build Lambda package
        run: |
          dotnet publish -c Release -f net8.0
          cd bin/Release/net8.0/publish
          zip -r ../../../../lambda.zip .
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy to Lambda
        run: |
          aws lambda update-function-code \
            --function-name user-service \
            --zip-file fileb://lambda.zip
```

#### Pros
- ✅ Pay per request (cost-effective for low traffic)
- ✅ Auto-scaling
- ✅ No server management
- ✅ High availability

#### Cons
- ❌ Cold starts
- ❌ 15-minute execution limit
- ❌ Not ideal for long-running processes

#### Best For
- Event-driven architectures
- Low to moderate traffic
- Cost optimization
- Microservices with sporadic traffic

---

### Pattern 5: AWS RDS SQL Server

**Managed SQL Server Database**

#### Architecture
```
┌─────────────────────────────────────┐
│         RDS SQL Server               │
│  ┌──────────────────────────────┐   │
│  │   Primary Instance            │   │
│  │   (Multi-AZ)                 │   │
│  └──────────────────────────────┘   │
│              │                       │
│              ▼                       │
│  ┌──────────────────────────────┐   │
│  │   Standby Instance           │   │
│  │   (Synchronous Replication)   │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

#### Deployment Flow

1. **Database Creation:**
   - RDS instance is created (SQL Server engine)
   - Instance class is selected (db.t3.medium, db.r5.large, etc.)
   - Storage is configured (SSD, provisioned IOPS)
   - Multi-AZ deployment is enabled for high availability
   - Security group allows traffic from application

2. **High Availability:**
   - Multi-AZ creates standby replica in different AZ
   - Synchronous replication ensures data consistency
   - Automatic failover (< 60 seconds)
   - Backups are taken from standby (no performance impact)

3. **Scaling Flow:**
   - Instance can be scaled up (change instance class)
   - Storage can be increased (automatic or manual)
   - Read replicas can be added for read scaling
   - Scaling operation requires downtime (except storage increase)

4. **Backup Flow:**
   - Automated backups run daily (retention 1-35 days)
   - Point-in-time restore available
   - Snapshots can be taken manually
   - Backups are stored in S3

#### Pros
- ✅ Fully managed
- ✅ Automatic backups
- ✅ Multi-AZ high availability
- ✅ Read replicas for scaling
- ✅ Automated patching

#### Cons
- ❌ Cost can be high
- ❌ Less control than EC2 SQL Server
- ❌ Some SQL Server features may be limited

#### Best For
- Production databases
- Need for high availability
- Managed database service

---

### Pattern 6: Angular on AWS

#### Option A: S3 + CloudFront (Most Common)

**Static Website Hosting**

#### Deployment Flow

1. **S3 Setup:**
   - S3 bucket is created
   - Static website hosting is enabled
   - Bucket policy allows public read access
   - Index document is set (index.html)
   - Error document is set (index.html for SPA routing)

2. **CloudFront Setup:**
   - CloudFront distribution is created
   - S3 bucket is set as origin
   - Custom domain is configured
   - SSL certificate is attached (ACM)
   - Cache behaviors are configured

3. **Deployment Flow:**
   - Angular app is built
   - Files are uploaded to S3 bucket
   - CloudFront cache is invalidated
   - New version is live globally

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-angular-s3.yml
name: Deploy Angular to S3 + CloudFront

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install and build
        run: |
          npm ci
          npm run build
        env:
          API_URL: ${{ secrets.API_URL }}
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy to S3
        run: |
          aws s3 sync ./dist/my-app s3://${{ secrets.S3_BUCKET }} --delete
      
      - name: Invalidate CloudFront cache
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
            --paths "/*"
```

#### Option B: Amplify Hosting

**Full-Featured Hosting with CI/CD**

#### Deployment Flow

1. **Amplify Setup:**
   - Amplify app is created
   - GitHub repository is connected
   - Build settings are configured
   - Environment variables are set

2. **Automatic Deployment:**
   - Code is pushed to GitHub
   - Amplify automatically builds and deploys
   - Preview environments for pull requests
   - Production branch deploys to production

#### Pros
- ✅ Automatic CI/CD
- ✅ Preview environments
- ✅ Custom domains
- ✅ SSL certificates
- ✅ Global CDN

---

## Part 6: On-Premise IIS Deployment

### Pattern 1: Traditional IIS Deployment

**For On-Premise or Hybrid Environments**

#### Architecture
```
┌─────────────────────────────────────┐
│         Load Balancer /             │
│         Reverse Proxy               │
└──────────────┬─────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
    ▼                     ▼
┌─────────┐         ┌─────────┐
│   IIS   │         │   IIS   │
│ Server  │         │ Server  │
│   1     │         │   2     │
└─────────┘         └─────────┘
    │                     │
    └──────────┬──────────┘
               │
        ┌──────▼──────┐
        │ SQL Server  │
        │ (On-Prem)   │
        └─────────────┘
```

#### Deployment Flow

1. **IIS Setup:**
   - IIS is installed on Windows Server
   - ASP.NET Core Hosting Bundle is installed
   - Application pool is created (.NET CLR Version: No Managed Code)
   - Website is created and bound to port
   - Physical path is set to application folder

2. **Application Deployment:**
   - .NET Core app is published (dotnet publish)
   - Published files are copied to IIS folder
   - web.config is configured (processPath, arguments)
   - Application pool is recycled
   - Health checks verify deployment

3. **Update Flow:**
   - New version is published
   - Files are copied to staging folder
   - Application pool is stopped
   - Files are swapped
   - Application pool is started
   - Health checks verify new version

4. **High Availability Setup:**
   - Multiple IIS servers behind load balancer
   - Session affinity configured (if needed)
   - Health checks on load balancer
   - Failover to healthy servers

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-iis.yml
name: Deploy to IIS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
      
      - name: Build and publish
        run: |
          dotnet publish -c Release -o ./publish
      
      - name: Create deployment package
        run: |
          Compress-Archive -Path ./publish/* -DestinationPath ./deploy.zip
      
      - name: Deploy to IIS server
        uses: SamKirkland/FTP-Deploy-Action@v4
        with:
          server: ${{ secrets.IIS_SERVER }}
          username: ${{ secrets.IIS_USERNAME }}
          password: ${{ secrets.IIS_PASSWORD }}
          local-dir: ./publish/
          server-dir: /inetpub/wwwroot/myapi/
      
      - name: Restart IIS App Pool
        run: |
          $session = New-PSSession -ComputerName ${{ secrets.IIS_SERVER }} -Credential (New-Object System.Management.Automation.PSCredential(${{ secrets.IIS_USERNAME }}, (ConvertTo-SecureString ${{ secrets.IIS_PASSWORD }} -AsPlainText -Force)))
          Invoke-Command -Session $session -ScriptBlock {
            Import-Module WebAdministration
            Restart-WebAppPool -Name "MyApiAppPool"
          }
          Remove-PSSession $session
```

#### web.config Configuration

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="." inheritInChildApplications="false">
    <system.webServer>
      <handlers>
        <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
      </handlers>
      <aspNetCore processPath="dotnet"
                  arguments=".\MyApi.dll"
                  stdoutLogEnabled="false"
                  stdoutLogFile=".\logs\stdout"
                  hostingModel="inprocess">
        <environmentVariables>
          <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Production" />
        </environmentVariables>
      </aspNetCore>
    </system.webServer>
  </location>
</configuration>
```

#### Pros
- ✅ Full control over environment
- ✅ No cloud costs
- ✅ Compliance requirements
- ✅ Existing infrastructure

#### Cons
- ❌ Manual scaling
- ❌ Infrastructure management
- ❌ No auto-scaling
- ❌ Higher operational overhead

#### Best For
- On-premise requirements
- Compliance/regulatory needs
- Existing Windows infrastructure
- Hybrid cloud scenarios

---

### Pattern 2: IIS with Docker Containers

**Modern Approach for On-Premise**

#### Deployment Flow

1. **Container Setup:**
   - Windows Server with Containers is installed
   - Docker is installed and configured
   - Private container registry is set up (optional)

2. **Deployment Flow:**
   - Docker image is built with .NET Core app
   - Image is pushed to registry
   - Container is deployed on Windows Server
   - IIS or reverse proxy routes traffic to containers
   - Multiple containers can run for load distribution

3. **Orchestration (Optional):**
   - Docker Swarm or Kubernetes on Windows
   - Container orchestration for scaling
   - Health checks and auto-restart

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-iis-docker.yml
name: Deploy Docker to IIS Server

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker image
        run: |
          docker build -t myapi:${{ github.sha }} ./UserService
      
      - name: Save image
        run: docker save myapi:${{ github.sha }} | gzip > image.tar.gz
      
      - name: Deploy to IIS server
        uses: appleboy/scp-action@master
        with:
          host: ${{ secrets.IIS_SERVER }}
          username: ${{ secrets.IIS_USERNAME }}
          password: ${{ secrets.IIS_PASSWORD }}
          source: "image.tar.gz"
          target: "/tmp/"
      
      - name: Load and run container
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.IIS_SERVER }}
          username: ${{ secrets.IIS_USERNAME }}
          password: ${{ secrets.IIS_PASSWORD }}
          script: |
            docker load < /tmp/image.tar.gz
            docker stop myapi || true
            docker rm myapi || true
            docker run -d --name myapi -p 8080:80 myapi:${{ github.sha }}
```

#### Pros
- ✅ Containerization benefits
- ✅ Easier updates and rollbacks
- ✅ Consistent environments
- ✅ Can use orchestration tools

#### Cons
- ❌ Requires Windows containers knowledge
- ❌ Additional complexity
- ❌ Resource overhead

---

### Pattern 3: Angular on IIS

**Static File Hosting on Windows Server**

#### Deployment Flow

1. **IIS Setup:**
   - IIS is installed on Windows Server
   - Website is created
   - Physical path points to Angular dist folder
   - URL Rewrite module is installed
   - web.config is configured for SPA routing

2. **Deployment Flow:**
   - Angular app is built (ng build --configuration production)
   - Built files are copied to IIS folder
   - web.config ensures all routes serve index.html
   - IIS serves static files via HTTP/HTTPS

3. **Update Flow:**
   - New build replaces files
   - IIS cache is cleared (optional)
   - Users get new version on next request

#### web.config for Angular SPA

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="Angular Routes" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="/" />
        </rule>
      </rules>
    </rewrite>
    <staticContent>
      <mimeMap fileExtension=".json" mimeType="application/json" />
    </staticContent>
  </system.webServer>
</configuration>
```

#### GitHub Actions CI/CD Flow

```yaml
# .github/workflows/deploy-angular-iis.yml
name: Deploy Angular to IIS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install and build
        run: |
          npm ci
          npm run build
      
      - name: Deploy to IIS
        uses: SamKirkland/FTP-Deploy-Action@v4
        with:
          server: ${{ secrets.IIS_SERVER }}
          username: ${{ secrets.IIS_USERNAME }}
          password: ${{ secrets.IIS_PASSWORD }}
          local-dir: ./dist/my-app/
          server-dir: /inetpub/wwwroot/myapp/
```

---

## Part 7: Complete Deployment Architectures

### Architecture 1: Azure Small to Medium Scale

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

**Deployment Flow:**
1. Angular: GitHub Actions → Azure Static Web Apps (automatic)
2. APIs: GitHub Actions → Azure App Service (slot swap)
3. Database: Azure SQL Database (manual setup, then managed)
4. Front Door: Routes traffic globally with CDN

---

### Architecture 2: AWS Small to Medium Scale

```
┌─────────────────────────────────────────────────────────┐
│                    CloudFront CDN                       │
└──────────────┬──────────────────────┬───────────────────┘
               │                      │
       ┌───────▼───────┐      ┌───────▼───────┐
       │   Angular     │      │  API Gateway  │
       │  S3 + CF      │      │  (ALB)        │
       └───────────────┘      └───────┬───────┘
                              ┌───────┴───────┐
                              │               │
                        ┌─────▼─────┐   ┌─────▼─────┐
                        │   User    │   │  Order    │
                        │  Service  │   │  Service  │
                        │  (ECS)    │   │  (ECS)    │
                        └─────┬─────┘   └─────┬─────┘
                              │               │
                              └───────┬───────┘
                                      │
                              ┌───────▼───────┐
                              │  RDS SQL      │
                              │   Server      │
                              │  (Multi-AZ)   │
                              └───────────────┘
```

**Deployment Flow:**
1. Angular: GitHub Actions → S3 → CloudFront invalidation
2. APIs: GitHub Actions → ECR → ECS service update
3. Database: RDS SQL Server (Multi-AZ for HA)
4. CloudFront: Global CDN distribution

---

### Architecture 3: On-Premise Enterprise

```
┌─────────────────────────────────────────────────────────┐
│                    Load Balancer /                      │
│                    Reverse Proxy                        │
└──────────────┬──────────────────────┬───────────────────┘
               │                      │
       ┌───────▼───────┐      ┌───────▼───────┐
       │   Angular     │      │  API Gateway  │
       │  (IIS)        │      │  (IIS/NGINX)  │
       └───────────────┘      └───────┬───────┘
                              ┌───────┴───────┐
                              │               │
                        ┌─────▼─────┐   ┌─────▼─────┐
                        │   User    │   │  Order    │
                        │  Service  │   │  Service  │
                        │  (IIS)    │   │  (IIS)    │
                        └─────┬─────┘   └─────┬─────┘
                              │               │
                              └───────┬───────┘
                                      │
                              ┌───────▼───────┐
                              │ SQL Server    │
                              │ (Always On)   │
                              │  Availability │
                              │    Group      │
                              └───────────────┘
```

**Deployment Flow:**
1. Angular: GitHub Actions → FTP/SCP → IIS folder
2. APIs: GitHub Actions → FTP/SCP → IIS → App Pool restart
3. Database: SQL Server Always On Availability Group
4. Load Balancer: Distributes traffic across IIS servers

---

## Part 8: CI/CD Pipeline Comparison

### GitHub Actions Workflow Summary

**Common Patterns Across All Deployments:**

1. **Build Phase:**
   - Checkout code
   - Setup environment (Node.js, .NET SDK)
   - Install dependencies
   - Build application
   - Run tests (optional)

2. **Package Phase:**
   - Create deployment package
   - Build Docker image (if containerized)
   - Tag with version (git SHA, tag, or build number)

3. **Deploy Phase:**
   - Authenticate to cloud/on-premise
   - Push to registry (if containerized)
   - Deploy to target environment
   - Verify deployment
   - Run smoke tests (optional)

4. **Post-Deploy:**
   - Invalidate CDN cache (if applicable)
   - Restart services (if needed)
   - Notify team (Slack, email, etc.)

---

## Part 9: Best Practices and Recommendations

### Security Best Practices

**1. API Security**
- Use HTTPS everywhere
- Implement authentication (JWT, OAuth)
- Configure CORS properly
- Validate all inputs
- Use API keys/rate limiting
- Store secrets in Key Vault/Secrets Manager

**2. Database Security**
- Use encrypted connections
- Store connection strings securely
- Enable firewall rules
- Use least privilege access
- Enable auditing
- Regular security updates

**3. Angular Security**
- Use environment variables for API URLs
- Implement Content Security Policy
- Sanitize user inputs
- Use HTTPS only
- Implement proper authentication flow

### Performance Optimization

**1. API Performance**
- Implement response caching
- Use async/await properly
- Optimize database queries
- Implement pagination
- Use compression middleware
- Connection pooling

**2. Angular Performance**
- Enable production optimizations
- Implement lazy loading
- Use OnPush change detection
- Optimize bundle size
- Enable HTTP caching
- Use CDN for static assets

**3. Database Performance**
- Create proper indexes
- Use read replicas for read-heavy workloads
- Monitor query performance
- Use appropriate service tier
- Optimize connection pooling

### Monitoring and Logging

**1. Application Monitoring**
- Set up Application Insights (Azure) or CloudWatch (AWS)
- Track custom metrics
- Set up alerts for errors
- Monitor performance metrics
- Create dashboards

**2. Logging Best Practices**
- Use structured logging
- Log at appropriate levels
- Include correlation IDs
- Don't log sensitive data
- Centralize logs

**3. Health Checks**
- Implement /health endpoints
- Check dependencies (database, external APIs)
- Use readiness vs liveness probes
- Set up alerting on health check failures

---

## Part 10: Cost Optimization Strategies

### Azure Cost Optimization

1. **Right-Sizing:**
   - Start with lower tiers
   - Use auto-scaling
   - Scale down during off-hours
   - Use reserved instances for predictable workloads

2. **Service Selection:**
   - Static Web Apps for Angular (cheapest)
   - App Service for small APIs
   - Container Apps for variable traffic
   - Kubernetes for large scale

3. **Database Optimization:**
   - Use DTU-based for simple needs
   - Implement read replicas instead of scaling up
   - Archive old data to cheaper storage
   - Use elastic pools for multiple databases

### AWS Cost Optimization

1. **Right-Sizing:**
   - Use appropriate instance types
   - Enable auto-scaling
   - Use Spot instances for non-critical workloads
   - Reserved instances for predictable usage

2. **Service Selection:**
   - S3 + CloudFront for Angular (cheapest)
   - ECS Fargate for serverless containers
   - Lambda for event-driven workloads
   - RDS for managed databases

3. **Database Optimization:**
   - Use appropriate instance classes
   - Enable read replicas
   - Use provisioned IOPS only when needed
   - Archive to S3 Glacier

### On-Premise Cost Considerations

1. **Hardware:**
   - Right-size servers
   - Virtualization for efficiency
   - Load balancing for high availability

2. **Software:**
   - SQL Server licensing costs
   - Windows Server licensing
   - Monitoring tools

---

## Part 11: Disaster Recovery and High Availability

### High Availability Strategies

**1. Multi-Region Deployment:**
- Primary and secondary regions
- Database replication (geo-replication)
- Traffic manager for failover
- Regular failover testing

**2. Database High Availability:**
- **Azure:** Failover groups, Always On
- **AWS:** Multi-AZ, Read replicas
- **On-Premise:** Always On Availability Groups

**3. Application High Availability:**
- Multiple instances/containers
- Load balancer health checks
- Auto-scaling
- Graceful degradation

### Backup Strategies

**1. Database Backups:**
- Automated daily backups
- Point-in-time restore
- Long-term retention
- Test restore procedures

**2. Application Backups:**
- Source control (Git)
- Infrastructure as Code
- Configuration backups
- Deployment package archives

**3. Disaster Recovery Plan:**
- Document recovery procedures
- Define RTO (Recovery Time Objective)
- Define RPO (Recovery Point Objective)
- Regular DR drills

---

## Part 12: Real-World Deployment Scenarios

### Scenario 1: Startup / MVP (Low Cost)

**Azure Architecture:**
- Angular: Azure Static Web Apps (Free tier)
- APIs: Azure App Service (Basic tier - $13/month)
- Database: Azure SQL Database (Basic - $5/month)
- **Total: ~$18/month**

**AWS Architecture:**
- Angular: S3 + CloudFront (~$1/month)
- APIs: Elastic Beanstalk (t3.micro - $7/month)
- Database: RDS SQL Server (db.t3.micro - $15/month)
- **Total: ~$23/month**

---

### Scenario 2: Small Business (Moderate Scale)

**Azure Architecture:**
- Angular: Azure Static Web Apps (Standard - $9/month)
- APIs: Azure App Service (Standard S1 - 2 instances - $150/month)
- Database: Azure SQL Database (S2 - $150/month)
- CDN: Azure Front Door (Standard - $20/month)
- **Total: ~$329/month**

**AWS Architecture:**
- Angular: S3 + CloudFront (~$10/month)
- APIs: ECS Fargate (2 tasks - $60/month)
- Database: RDS SQL Server (db.t3.medium Multi-AZ - $200/month)
- ALB: Application Load Balancer (~$20/month)
- **Total: ~$290/month**

---

### Scenario 3: Enterprise (High Scale)

**Azure Architecture:**
- Angular: Blob Storage + CDN (~$50/month)
- APIs: Azure Kubernetes Service (~$500/month)
- Database: Azure SQL Database (Business Critical P2 - $2000/month)
- API Management: Standard tier (~$200/month)
- Monitoring: Application Insights (~$100/month)
- **Total: ~$2850/month**

**AWS Architecture:**
- Angular: S3 + CloudFront (~$50/month)
- APIs: EKS Cluster (~$600/month)
- Database: RDS SQL Server (db.r5.2xlarge Multi-AZ - $2500/month)
- API Gateway: (~$100/month)
- CloudWatch: (~$150/month)
- **Total: ~$3400/month**

---

## Part 13: Troubleshooting Common Issues

### Issue 1: CORS Errors

**Symptoms:** Browser console shows CORS errors when Angular calls API

**Solutions:**
- Configure CORS in API to allow Angular origin
- Check that credentials are handled correctly
- Verify preflight requests are handled
- Ensure API Gateway/Proxy allows CORS headers

### Issue 2: Database Connection Timeouts

**Symptoms:** API fails to connect to database

**Solutions:**
- Check firewall rules (allow application IPs)
- Verify connection string
- Increase connection timeout
- Check database service status
- Verify network connectivity

### Issue 3: Angular Routing Issues (404)

**Symptoms:** Direct URL access or refresh returns 404

**Solutions:**
- Configure URL rewrite rules (IIS web.config)
- Set navigationFallback (Azure Static Web Apps)
- Configure CloudFront error pages (AWS)
- Ensure all routes serve index.html

### Issue 4: API Performance Issues

**Symptoms:** Slow API responses

**Solutions:**
- Enable response caching
- Optimize database queries
- Add database indexes
- Use async/await properly
- Scale out horizontally
- Enable compression

### Issue 5: Deployment Failures

**Symptoms:** CI/CD pipeline fails

**Solutions:**
- Check authentication credentials
- Verify resource permissions
- Check build logs for errors
- Ensure environment variables are set
- Verify network connectivity
- Check resource quotas/limits

---

## Conclusion

### Recommended Patterns by Scale

**Small Scale (< 1000 users):**
- **Azure:** Static Web Apps + App Service + SQL Database Basic
- **AWS:** S3+CloudFront + Elastic Beanstalk + RDS db.t3.micro
- **On-Premise:** Single IIS server + SQL Server Standard

**Medium Scale (1000-10000 users):**
- **Azure:** Static Web Apps + App Service (multiple) + SQL Database Standard
- **AWS:** S3+CloudFront + ECS Fargate + RDS Multi-AZ
- **On-Premise:** Load balanced IIS + SQL Server Always On

**Large Scale (10000+ users):**
- **Azure:** Blob+CDN + Kubernetes/Container Apps + SQL Database Premium
- **AWS:** S3+CloudFront + EKS + RDS Large Multi-AZ
- **On-Premise:** Kubernetes on Windows + SQL Server Always On

### Key Takeaways

1. **Start Simple:** Begin with PaaS services, move to containers when needed
2. **Use Managed Services:** Prefer PaaS over IaaS for databases
3. **Implement CI/CD:** Automate deployments from day one with GitHub Actions
4. **Monitor Everything:** Set up monitoring and alerts early
5. **Plan for HA:** Design for high availability from the start
6. **Optimize Costs:** Right-size resources and use reserved instances
7. **Security First:** Implement security best practices from the beginning
8. **Document Everything:** Keep deployment procedures documented

### Decision Matrix

| Factor | Azure | AWS | On-Premise |
|--------|-------|-----|------------|
| **Ease of Setup** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Cost (Small)** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Cost (Large)** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Scalability** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| **Control** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **.NET Integration** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Compliance** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

### Next Steps

1. **Choose Your Platform:** Based on requirements, budget, and team expertise
2. **Set Up CI/CD:** Implement GitHub Actions workflows
3. **Configure Monitoring:** Set up Application Insights, CloudWatch, or on-premise monitoring
4. **Plan for HA:** Design high availability from the start
5. **Document Procedures:** Keep deployment and operational procedures documented
6. **Train Your Team:** Ensure team understands chosen deployment patterns
7. **Start Small, Scale Gradually:** Begin with simple architecture, evolve as needed

---

*"The best deployment pattern is the one that fits your team, scale, requirements, and budget. Start simple, automate everything, monitor continuously, and scale as needed."*

---

## Additional Resources

### Azure Resources
- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/)
- [Azure Static Web Apps](https://docs.microsoft.com/azure/static-web-apps/)
- [Azure SQL Database](https://docs.microsoft.com/azure/sql-database/)

### AWS Resources
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [AWS RDS SQL Server](https://docs.aws.amazon.com/rds/)
- [AWS Amplify](https://docs.amplify.aws/)

### On-Premise Resources
- [IIS Deployment Guide](https://docs.microsoft.com/aspnet/core/host-and-deploy/iis/)
- [SQL Server Always On](https://docs.microsoft.com/sql/database-engine/availability-groups/)

### CI/CD Resources
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Azure DevOps Pipelines](https://docs.microsoft.com/azure/devops/pipelines/)

---

*Last Updated: 2024*