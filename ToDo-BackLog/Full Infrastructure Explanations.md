# AWS Microservices POC — Step-by-Step Implementation Guide

## 📖 Introduction

### Purpose

This comprehensive guide provides a **hands-on, step-by-step approach** to building a production-ready microservices architecture on AWS using .NET 8. Each Proof of Concept (POC) builds upon the previous one, gradually introducing AWS services, Kubernetes (EKS), and microservices best practices.

### What You'll Learn

- **Microservices Architecture**: Building and deploying independent services
- **AWS Infrastructure**: EKS, ECR, RDS, SQS, CloudWatch, Secrets Manager, and more
- **Kubernetes**: Deployments, Services, Ingress, HPA, and canary deployments
- **DevOps Practices**: CI/CD pipelines, infrastructure as code (Terraform), and monitoring
- **Production Patterns**: Resilience, security, observability, and cost optimization

### How to Use This Guide

1. **Start with POC-0** - Build the baseline microservices
2. **Follow sequentially** - Each POC builds on previous concepts
3. **Use Cursor AI** - Copy prompts into Cursor AI to generate code quickly
4. **Manual AWS Setup** - Follow manual steps for AWS infrastructure configuration
5. **Test Each POC** - Verify functionality before moving to the next

### Prerequisites Overview

- .NET 8 SDK
- Docker Desktop
- AWS CLI configured
- Kubernetes (kubectl)
- Terraform
- GitHub account
- AWS account (free tier works for most POCs)

### Architecture Overview

The guide builds a **3-service microservices platform**:
- **ProductService**: Product catalog management
- **OrderService**: Order processing
- **NotificationService**: Async notifications (email/SMS)

All services run on **Amazon EKS (Kubernetes)** with:
- Independent databases (RDS PostgreSQL)
- Async messaging (SQS)
- Centralized logging (CloudWatch)
- Distributed tracing (X-Ray)
- Security (Secrets Manager, WAF)
- Auto-scaling (HPA)
- Canary deployments

---

## 📑 Index

### Foundation POCs (Start Here)

- **[POC-0: Microservices Baseline](#poc-0-microservices-baseline)** - Create 3 basic .NET 8 Web APIs
- **[POC-1: Multi-Service Git Strategy](#poc-1-multi-service-git-strategy)** - Mono-repo structure and branching
- **[POC-2: CI per Microservice](#poc-2-ci-per-microservice)** - GitHub Actions with path-based triggers

### Containerization & Infrastructure

- **[POC-3: Service-Scoped Docker Images](#poc-3-service-scoped-docker-images)** - Dockerfiles and ECR setup
- **[POC-4: Terraform for Microservices Infra](#poc-4-terraform-for-microservices-infra)** - Infrastructure as code (EKS, RDS, SQS, CloudWatch)

### Kubernetes Deployment

- **[POC-5: EKS Deployment per Service](#poc-5-eks-deployment-per-service)** - Kubernetes manifests and deployments
- **[POC-6: Rolling Updates with Health Probes](#poc-6-rolling-updates-with-health-probes)** - Health checks and zero-downtime deployments
- **[POC-7: Microservice Routing (Ingress)](#poc-7-microservice-routing-ingress)** - ALB and Ingress configuration

### Security & Configuration

- **[POC-8: Secure Inter-Service Access](#poc-8-secure-inter-service-access)** - Secrets Manager and IRSA
- **[POC-9: Database Isolation](#poc-9-database-isolation)** - Database per service with EF Core

### Observability & Resilience

- **[POC-10: Distributed Observability](#poc-10-distributed-observability)** - X-Ray, CloudWatch Logs, correlation IDs
- **[POC-11: Service Failure Handling](#poc-11-service-failure-handling)** - Circuit breaker, retry, fallback (Polly)

### Async Communication

- **[POC-12: Async Notification Flow](#poc-12-async-notification-flow)** - SQS integration and event-driven architecture

### Scaling & Deployment Strategies

- **[POC-13: Scale Hot Services Only](#poc-13-scale-hot-services-only)** - HPA (Horizontal Pod Autoscaler)
- **[POC-14: Canary per Service](#poc-14-canary-per-service)** - Canary deployments with traffic splitting

### Production Hardening

- **[POC-15: Microservice Security Hardening](#poc-15-microservice-security-hardening)** - WAF, security headers, DDoS protection
- **[POC-16: Cost Visibility](#poc-16-cost-visibility)** - Resource tagging, budgets, cost analysis
- **[POC-17: Partial DR](#poc-17-partial-dr)** - Backup and disaster recovery procedures
- **[POC-18: Service Incident Simulation](#poc-18-service-incident-simulation)** - Chaos engineering and incident response

### Quick Reference

- **[Final Checklist](#-final-checklist)** - Verification checklist
- **[Quick Start Commands](#-quick-start-commands)** - Common commands reference

---

> **For each POC**: Use Cursor AI prompts to generate code, then follow manual steps for AWS setup.


---


## 🎯 Prerequisites (Do Once)


### **Manual Steps:**
1. **Install Tools:**
   ```powershell
   # Install .NET 8 SDK
   winget install Microsoft.DotNet.SDK.8


   # Install Docker Desktop
   winget install Docker.DockerDesktop


   # Install AWS CLI
   winget install Amazon.AWSCLI


   # Install kubectl
   winget install Kubernetes.kubectl


   # Install Terraform
   winget install Hashicorp.Terraform
   
   
   # Install eksctl (optional, for easier EKS management)
   winget install Weaveworks.eksctl
   ```


2. **AWS Account Setup:**
   - Create AWS account (free tier available)
   - Configure AWS CLI: `aws configure`
   - Set default region: `aws configure set region us-east-1`
   - Create IAM user with appropriate permissions (or use root for POC)
   - Verify access: `aws sts get-caller-identity`


3. **GitHub Setup:**
   - Create GitHub repository (public or private)
   - Clone locally


---


## POC-0: Microservices Baseline


### **What You Build:**
- 3 separate .NET 8 Web APIs (ProductService, OrderService, NotificationService)
- Each with `/health` endpoint
- Each with Swagger
- Each with its own database schema (SQLite for local dev)


### **Cursor AI Prompts:**


#### **Prompt 1: Create Solution Structure**
```
Create a .NET solution with 3 microservices:
1. ProductService - Web API for product CRUD operations
2. OrderService - Web API for order management
3. NotificationService - Web API for notifications (email/SMS mock)


Structure:
- /src/ProductService (ASP.NET Core Web API)
- /src/OrderService (ASP.NET Core Web API)
- /src/NotificationService (ASP.NET Core Web API)
- /src/Shared (class library for shared models)


Each service should:
- Use .NET 8
- Have Swagger/OpenAPI enabled
- Have a /health endpoint that returns 200 OK
- Have appsettings.json for configuration
- Use minimal APIs or controllers (your choice)
```


#### **Prompt 2: ProductService Implementation**
```
In ProductService, create:
- Product model (Id, Name, Price, Description, Stock)
- GET /api/products - list all products
- GET /api/products/{id} - get product by id
- POST /api/products - create product
- PUT /api/products/{id} - update product
- DELETE /api/products/{id} - delete product


Use in-memory list for now (no database yet).
Add proper error handling and validation.
```


#### **Prompt 3: OrderService Implementation**
```
In OrderService, create:
- Order model (Id, ProductId, Quantity, CustomerEmail, Status, CreatedAt)
- GET /api/orders - list all orders
- GET /api/orders/{id} - get order by id
- POST /api/orders - create order (validate product exists)
- PUT /api/orders/{id}/status - update order status


Use in-memory list for now.
Add proper error handling.
```


#### **Prompt 4: NotificationService Implementation**
```
In NotificationService, create:
- Notification model (Id, Type, Recipient, Message, Status, CreatedAt)
- POST /api/notifications/send - send notification (mock implementation)
  - Simulate email sending (2-3 second delay)
  - Simulate SMS sending (1-2 second delay)
- GET /api/notifications - list all notifications


Use in-memory list for now.
Log each notification attempt.
```


#### **Prompt 5: Health Endpoints**
```
Add health check endpoints to all 3 services:
- GET /health - returns 200 OK with {"status": "healthy", "service": "ProductService"}
- Use Microsoft.Extensions.Diagnostics.HealthChecks


Register health checks in Program.cs for each service.
```


### **Manual Steps:**
1. **Test Locally:**
   ```powershell
   cd src/ProductService
   dotnet run
   # Test: http://localhost:5000/swagger
   # Test: http://localhost:5000/health


   # Repeat for OrderService (port 5001) and NotificationService (port 5002)
   ```


2. **Verify:**
   - [ ] All 3 services run independently
   - [ ] Swagger works for each
   - [ ] Health endpoints return 200
   - [ ] Services can be started/stopped independently


---


## POC-1: Multi-Service Git Strategy


### **What You Build:**
- Mono-repo structure
- Branch protection rules
- PR workflow


### **Cursor AI Prompts:**


#### **Prompt 1: Create .gitignore**
```
Create a comprehensive .gitignore for:
- .NET projects (bin/, obj/, *.user, etc.)
- Docker files
- Terraform state files (.terraform/, *.tfstate)
- IDE files (VS Code, Visual Studio)
- Environment files (appsettings.Development.json with secrets)
- AWS credentials (.aws/, credentials, config)
```


#### **Prompt 2: Create README Structure**
```
Create a README.md with:
- Project overview (3 microservices)
- Architecture diagram (ASCII art)
- Prerequisites
- How to run each service locally
- Development workflow (branching strategy)
```


### **Manual Steps:**
1. **GitHub Repository Setup:**
   - Create repository on GitHub
   - Push initial code:
     ```powershell
     git init
     git add .
     git commit -m "Initial commit: POC-0 baseline"
     git remote add origin <your-repo-url>
     git push -u origin main
     ```


2. **Branch Protection (GitHub):**
   - Go to Settings → Branches
   - Add rule for `main` branch:
     - ✅ Require pull request reviews
     - ✅ Require status checks to pass
     - ✅ Require branches to be up to date


3. **Create Develop Branch:**
   ```powershell
   git checkout -b develop
   git push -u origin develop
   ```


4. **Test PR Workflow:**
   ```powershell
   git checkout -b feature/product-service-enhancement
   # Make a small change
   git commit -m "Add feature"
   git push -u origin feature/product-service-enhancement
   ```
   - Create PR on GitHub from `feature/*` to `develop`
   - Verify PR checks (if configured)


---


## POC-2: CI per Microservice


### **What You Build:**
- GitHub Actions workflows
- Separate CI jobs per service
- Only build changed services


### **Cursor AI Prompts:**


#### **Prompt 1: Create GitHub Actions Workflow**
```
Create GitHub Actions workflow at .github/workflows/ci.yml that:
- Triggers on push to main/develop and on pull requests
- Detects which services changed (using path filters)
- Runs separate jobs for each service:
  - ProductService: restore, build, test
  - OrderService: restore, build, test
  - NotificationService: restore, build, test
- Only runs jobs for changed services
- Uses matrix strategy for .NET version (8.0.x)
- Publishes test results
```


#### **Prompt 2: Path-Based Triggering**
```
Modify the CI workflow to use path filters:
- ProductService job only runs if files in src/ProductService/ changed
- OrderService job only runs if files in src/OrderService/ changed
- NotificationService job only runs if files in src/NotificationService/ changed
- Use paths-ignore and paths filters
```


### **Manual Steps:**
1. **Create Test Projects:**
   ```powershell
   # In each service folder
   dotnet new xunit -n ProductService.Tests
   dotnet add ProductService.Tests/ProductService.Tests.csproj reference ProductService/ProductService.csproj
   ```


2. **Add Simple Test:**
   ```csharp
   // In ProductService.Tests/ProductServiceTests.cs
   public class ProductServiceTests
   {
       [Fact]
       public void Test1()
       {
           Assert.True(true);
       }
   }
   ```


3. **Push to GitHub:**
   ```powershell
   git add .
   git commit -m "Add CI pipeline"
   git push
   ```


4. **Verify:**
   - Go to GitHub → Actions tab
   - See workflows running
   - Make a change to only ProductService
   - Verify only ProductService job runs


---


## POC-3: Service-Scoped Docker Images


### **What You Build:**
- Dockerfile per service
- Multi-stage builds
- Health checks
- Non-root user


### **Cursor AI Prompts:**


#### **Prompt 1: ProductService Dockerfile**
```
Create a multi-stage Dockerfile for ProductService:
- Stage 1: Build (use mcr.microsoft.com/dotnet/sdk:8.0)
  - Copy .csproj and restore
  - Copy all files and build
  - Publish to /app/publish
- Stage 2: Runtime (use mcr.microsoft.com/dotnet/aspnet:8.0)
  - Create non-root user (appuser)
  - Copy published files
  - Set working directory
  - Expose port 8080
  - Add HEALTHCHECK (curl http://localhost:8080/health)
  - Run as non-root user
- Use .dockerignore to exclude unnecessary files
```


#### **Prompt 2: OrderService & NotificationService Dockerfiles**
```
Create similar Dockerfiles for OrderService and NotificationService.
Each should:
- Use different ports (8081, 8082)
- Have service-specific health checks
- Follow same multi-stage pattern
```


#### **Prompt 3: Docker Compose for Local Testing**
```
Create docker-compose.yml for local development:
- ProductService (port 5000:8080)
- OrderService (port 5001:8081)
- NotificationService (port 5002:8082)
- Each service builds from its Dockerfile
- Add health checks
- Add restart policies
```


### **Manual Steps:**
1. **Build Images Locally:**
   ```powershell
   cd src/ProductService
   docker build -t productservice:latest .
   
   cd ../OrderService
   docker build -t orderservice:latest .
   
   cd ../NotificationService
   docker build -t notificationservice:latest .
   ```


2. **Test Locally:**
   ```powershell
   docker run -p 5000:8080 productservice:latest
   # Test: http://localhost:5000/health
   ```


3. **Create Amazon ECR Repository:**
   ```powershell
   # Create ECR repositories
   aws ecr create-repository --repository-name productservice --region us-east-1
   aws ecr create-repository --repository-name orderservice --region us-east-1
   aws ecr create-repository --repository-name notificationservice --region us-east-1
   
   # Get login token
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   ```


4. **Tag and Push:**
   ```powershell
   # Get ECR registry URL
   $ECR_REGISTRY = "<account-id>.dkr.ecr.us-east-1.amazonaws.com"
   
   docker tag productservice:latest $ECR_REGISTRY/productservice:v1.0.0
   docker tag orderservice:latest $ECR_REGISTRY/orderservice:v1.0.0
   docker tag notificationservice:latest $ECR_REGISTRY/notificationservice:v1.0.0


   docker push $ECR_REGISTRY/productservice:v1.0.0
   docker push $ECR_REGISTRY/orderservice:v1.0.0
   docker push $ECR_REGISTRY/notificationservice:v1.0.0
   ```


5. **Verify in AWS Console:**
   - Go to ECR → Repositories
   - See all 3 repositories with images


---


## POC-4: Terraform for Microservices Infra


### **What You Build:**
- Terraform scripts for shared infrastructure
- EKS cluster
- ECR (if not created manually)
- CloudWatch Log Groups
- SQS queues
- RDS databases (per service)


### **Cursor AI Prompts:**


#### **Prompt 1: Terraform Main Configuration**
```
Create Terraform configuration in /infra/terraform/main.tf:
- AWS provider configuration
- Variables file for:
  - region (default: us-east-1)
  - environment (default: dev)
  - ecr_repository_prefix
  - eks_cluster_name
  - vpc_cidr
- Outputs for:
  - eks_cluster_name
  - eks_cluster_endpoint
  - vpc_id
  - ecr_repository_urls
```


#### **Prompt 2: EKS Cluster Module**
```
Create /infra/terraform/modules/eks/main.tf:
- Amazon EKS cluster
- Managed node group (2-3 nodes, t3.medium)
- Enable cluster logging (API, audit, authenticator, controllerManager, scheduler)
- Enable OIDC provider for IRSA
- Network configuration (VPC, subnets, security groups)
- Output: cluster_endpoint, cluster_ca_certificate, cluster_name, oidc_provider_arn
```


#### **Prompt 3: SQS Module**
```
Create /infra/terraform/modules/sqs/main.tf:
- SQS queue for notifications (notification-queue)
- Dead letter queue configuration
- Visibility timeout and message retention
- Output: queue_url, queue_arn, dead_letter_queue_url
```


#### **Prompt 4: Database Modules**
```
Create /infra/terraform/modules/databases/main.tf:
- RDS PostgreSQL (or MySQL) instance
- ProductService database (separate DB on same instance or separate instance)
- OrderService database
- Security groups (allow EKS access)
- Subnet group configuration
- Output: connection strings (store in Secrets Manager later)
```


#### **Prompt 5: CloudWatch Module**
```
Create /infra/terraform/modules/monitoring/main.tf:
- CloudWatch Log Groups (one per service)
- CloudWatch Alarms (CPU, memory, error rate)
- X-Ray daemon configuration
- Output: log_group_names, alarm_arns
```


### **Manual Steps:**
1. **Initialize Terraform:**
   ```powershell
   cd infra/terraform
   terraform init
   ```


2. **Create terraform.tfvars:**
   ```hcl
   region = "us-east-1"
   environment = "dev"
   ecr_repository_prefix = "microservices-poc"
   eks_cluster_name = "eks-microservices-poc"
   vpc_cidr = "10.0.0.0/16"
   ```


3. **Plan and Apply:**
   ```powershell
   terraform plan
   terraform apply
   # Type 'yes' to confirm
   ```


4. **Get EKS Credentials:**
   ```powershell
   aws eks update-kubeconfig --region us-east-1 --name eks-microservices-poc
   kubectl get nodes
   ```


5. **Verify Resources:**
   - AWS Console → CloudFormation (or check each service)
   - See: EKS, ECR, SQS, RDS, CloudWatch


---


## POC-5: EKS Deployment per Service


### **What You Build:**
- Kubernetes manifests per service
- Separate Deployments
- Separate Services
- Separate ConfigMaps
- Separate Secrets


### **Cursor AI Prompts:**


#### **Prompt 1: ProductService Kubernetes Manifests**
```
Create /infra/k8s/productservice/ directory with:
- deployment.yaml:
  - Image from ECR
  - Replicas: 2
  - Resource limits (CPU: 500m, Memory: 512Mi)
  - Environment variables from ConfigMap
  - Health probes (liveness, readiness)
  - Port: 8080
  - IAM role annotation for IRSA (if using Secrets Manager)
- service.yaml:
  - ClusterIP type
  - Port 80 → 8080
  - Selector matching deployment
- configmap.yaml:
  - App settings (non-sensitive)
- secret.yaml (template):
  - Database connection string (placeholder, use Secrets Manager)
```


#### **Prompt 2: OrderService & NotificationService Manifests**
```
Create similar Kubernetes manifests for OrderService and NotificationService:
- /infra/k8s/orderservice/ (deployment, service, configmap, secret)
- /infra/k8s/notificationservice/ (deployment, service, configmap, secret)
- Each with unique ports and selectors
```


#### **Prompt 3: Namespace Configuration**
```
Create /infra/k8s/namespaces.yaml:
- microservices namespace
- Add labels for cost tracking (Environment, Service)
```


### **Manual Steps:**
1. **Create Namespace:**
   ```powershell
   kubectl create namespace microservices
   ```


2. **Apply Manifests:**
   ```powershell
   kubectl apply -f infra/k8s/namespaces.yaml
   kubectl apply -f infra/k8s/productservice/ -n microservices
   kubectl apply -f infra/k8s/orderservice/ -n microservices
   kubectl apply -f infra/k8s/notificationservice/ -n microservices
   ```


3. **Verify:**
   ```powershell
   kubectl get pods -n microservices
   kubectl get services -n microservices
   kubectl get configmaps -n microservices
   ```


4. **Port Forward to Test:**
   ```powershell
   kubectl port-forward -n microservices svc/productservice 5000:80
   # Test: http://localhost:5000/health
   ```


---


## POC-6: Rolling Updates with Health Probes


### **What You Build:**
- Enhanced health probes
- Rolling update strategy
- Rollback capability


### **Cursor AI Prompts:**


#### **Prompt 1: Enhanced Health Checks**
```
Update each service's Program.cs to add:
- Detailed health checks:
  - Liveness: basic service alive check
  - Readiness: check database connectivity, external dependencies
- Use Microsoft.Extensions.Diagnostics.HealthChecks
- Return detailed health status
```


#### **Prompt 2: Update Deployment Manifests**
```
Update all deployment.yaml files to include:
- livenessProbe:
  - httpGet: /health/live
  - initialDelaySeconds: 30
  - periodSeconds: 10
  - timeoutSeconds: 5
  - failureThreshold: 3
- readinessProbe:
  - httpGet: /health/ready
  - initialDelaySeconds: 10
  - periodSeconds: 5
  - timeoutSeconds: 3
  - failureThreshold: 3
- strategy:
  - type: RollingUpdate
  - rollingUpdate:
    - maxSurge: 1
    - maxUnavailable: 0
```


### **Manual Steps:**
1. **Update and Apply:**
   ```powershell
   # Build new image version
   docker build -t <ecr-registry>/productservice:v1.1.0 .
   docker push <ecr-registry>/productservice:v1.1.0


   # Update deployment.yaml image tag
   kubectl apply -f infra/k8s/productservice/deployment.yaml -n microservices
   ```


2. **Watch Rolling Update:**
   ```powershell
   kubectl rollout status deployment/productservice -n microservices
   kubectl get pods -n microservices -w
   ```


3. **Test Rollback:**
   ```powershell
   kubectl rollout undo deployment/productservice -n microservices
   kubectl rollout history deployment/productservice -n microservices
   ```


---


## POC-7: Microservice Routing (Ingress)


### **What You Build:**
- AWS Load Balancer Controller
- Ingress rules for routing
- TLS termination (optional with ACM)


### **Cursor AI Prompts:**


#### **Prompt 1: AWS Load Balancer Controller Installation**
```
Create /infra/k8s/ingress/alb-controller.yaml:
- AWS Load Balancer Controller deployment
- Service account with IAM role (IRSA)
- Install using Helm or manifest
- Configure for Application Load Balancer
```


#### **Prompt 2: Ingress Rules**
```
Create /infra/k8s/ingress/ingress-rules.yaml:
- Ingress resource for microservices namespace
- Rules:
  - /products/* → productservice:80
  - /orders/* → orderservice:80
  - /notifications/* → notificationservice:80
- Add annotations for:
  - ALB type (internet-facing or internal)
  - SSL redirect
  - Health check path
  - Target group attributes
```


### **Manual Steps:**
1. **Install AWS Load Balancer Controller:**
   ```powershell
   # Using Helm
   helm repo add eks https://aws.github.io/eks-charts
   helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=eks-microservices-poc
   ```


2. **Apply Ingress Rules:**
   ```powershell
   kubectl apply -f infra/k8s/ingress/ingress-rules.yaml -n microservices
   ```


3. **Get ALB URL:**
   ```powershell
   # Wait for ALB to be created (may take 2-3 minutes)
   kubectl get ingress -n microservices
   # Get ADDRESS from output
   ```


4. **Test Routing:**
   ```powershell
   # Get ALB URL
   $ALB_URL = (kubectl get ingress microservices-ingress -n microservices -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
   
   # Test routes
   curl http://$ALB_URL/products/health
   curl http://$ALB_URL/orders/health
   ```


5. **Configure DNS (Optional):**
   - Create Route 53 hosted zone
   - Create A record (alias) pointing to ALB
   - Update ingress rules with hostname


---


## POC-8: Secure Inter-Service Access


### **What You Build:**
- AWS Secrets Manager integration
- IAM Roles for Service Accounts (IRSA)
- JWT authentication at gateway
- Secrets from Secrets Manager


### **Cursor AI Prompts:**


#### **Prompt 1: Secrets Manager Integration in Services**
```
Update each service to:
- Use AWS Secrets Manager provider for configuration
- Install: AWSSDK.SecretsManager
- In Program.cs, add Secrets Manager configuration source
- Read connection strings from Secrets Manager
- Use IAM role authentication (IRSA)
```


#### **Prompt 2: JWT Authentication Middleware**
```
Create shared authentication middleware:
- JWT token validation
- Extract claims (user ID, roles)
- Add to HttpContext.User
- Use Microsoft.AspNetCore.Authentication.JwtBearer
- Validate against AWS Cognito (or custom issuer)
```


#### **Prompt 3: Update Ingress with Auth**
```
Add authentication annotations to ingress:
- Use AWS Cognito for authentication (optional)
- Add rate limiting per route
- Add IP whitelisting (optional)
```


### **Manual Steps:**
1. **Create Secrets in Secrets Manager:**
   ```powershell
   aws secretsmanager create-secret --name microservices-poc/ProductService/ConnectionString --secret-string "your-connection-string" --region us-east-1
   aws secretsmanager create-secret --name microservices-poc/OrderService/ConnectionString --secret-string "your-connection-string" --region us-east-1
   ```


2. **Create IAM Policy for Secrets Manager:**
   ```powershell
   # Create policy document
   # Allow GetSecretValue for microservices-poc/* secrets
   aws iam create-policy --policy-name MicroservicesSecretsManagerPolicy --policy-document file://secrets-policy.json
   ```


3. **Create IAM Role for Service Account (IRSA):**
   ```powershell
   # Get OIDC provider URL
   $OIDC_URL = (aws eks describe-cluster --name eks-microservices-poc --query "cluster.identity.oidc.issuer" --output text)
   
   # Create IAM role with trust policy for IRSA
   # Associate with Kubernetes service account
   eksctl create iamserviceaccount --name productservice-sa --namespace microservices --cluster eks-microservices-poc --attach-policy-arn arn:aws:iam::<account-id>:policy/MicroservicesSecretsManagerPolicy --approve
   ```


4. **Update Deployment Manifests:**
   - Add serviceAccountName to deployments
   - Add environment variable: `AWS_REGION=us-east-1`
   - Add Secrets Manager configuration


5. **Test:**
   ```powershell
   kubectl logs -n microservices deployment/productservice
   # Should see Secrets Manager connection successful
   ```


---


## POC-9: Database Isolation


### **What You Build:**
- Separate databases per service
- Entity Framework Core integration
- VPC endpoint configuration (optional)
- Connection pooling


### **Cursor AI Prompts:**


#### **Prompt 1: ProductService Database Setup**
```
In ProductService:
- Add Entity Framework Core packages
- Create DbContext (ProductDbContext)
- Create Product entity with migrations
- Add connection string from Secrets Manager
- Implement repository pattern
- Update controllers to use DbContext
```


#### **Prompt 2: OrderService Database Setup**
```
In OrderService:
- Similar setup with OrderDbContext
- Order entity with migrations
- Separate database connection
```


#### **Prompt 3: Database Migrations**
```
Create migration scripts:
- ProductService: InitialCreate migration
- OrderService: InitialCreate migration
- Add migration commands to Dockerfile or startup
```


### **Manual Steps:**
1. **Create Databases (if not via Terraform):**
   ```powershell
   # Connect to RDS instance
   # Create databases
   psql -h <rds-endpoint> -U postgres -c "CREATE DATABASE productdb;"
   psql -h <rds-endpoint> -U postgres -c "CREATE DATABASE orderdb;"
   ```


2. **Configure Security Groups:**
   ```powershell
   # Allow EKS node group security group to access RDS
   # Update RDS security group inbound rules
   aws ec2 authorize-security-group-ingress --group-id <rds-sg-id> --protocol tcp --port 5432 --source-group <eks-node-sg-id>
   ```


3. **Get Connection Strings:**
   ```powershell
   # Format: Host=<rds-endpoint>;Port=5432;Database=productdb;Username=postgres;Password=<password>
   # Add to Secrets Manager
   aws secretsmanager update-secret --secret-id microservices-poc/ProductService/ConnectionString --secret-string "Host=..." --region us-east-1
   ```


4. **Run Migrations:**
   ```powershell
   # In ProductService container or locally
   dotnet ef database update --project ProductService
   ```


5. **Test:**
   - Create product via API
   - Verify in database
   - Verify OrderService cannot access ProductDb


---


## POC-10: Distributed Observability


### **What You Build:**
- AWS X-Ray per service
- CloudWatch Logs integration
- Correlation IDs
- Distributed tracing
- Centralized dashboards


### **Cursor AI Prompts:**


#### **Prompt 1: X-Ray Integration**
```
In each service, add AWS X-Ray:
- Install: AWSXRayRecorder.Handlers.AspNetCore
- Add X-Ray middleware
- Enable automatic tracing
- Add custom segments for database calls
- Track external calls (SQS, RDS)
```


#### **Prompt 2: Correlation ID Middleware**
```
Create shared middleware for correlation IDs:
- Generate correlation ID if not present
- Add to HttpContext
- Add to all log messages
- Propagate to downstream services (HTTP headers)
- Add to SQS message attributes
```


#### **Prompt 3: Structured Logging**
```
Update all services to use:
- Serilog or Microsoft.Extensions.Logging
- Structured logging (JSON format)
- Include correlation ID in all logs
- Log to CloudWatch Logs
- Use AWS.Logger.AspNetCore
```


### **Manual Steps:**
1. **Enable X-Ray in EKS:**
   ```powershell
   # X-Ray daemon should be running as DaemonSet (via Terraform or manually)
   kubectl get daemonset -n kube-system | grep xray
   ```


2. **Add X-Ray IAM Permissions:**
   ```powershell
   # Create IAM policy for X-Ray
   # Attach to service account via IRSA
   ```


3. **Update Deployments:**
   - Add X-Ray environment variables
   - Add CloudWatch Logs configuration
   - Add correlation ID middleware


4. **Create CloudWatch Dashboard:**
   - AWS Console → CloudWatch → Dashboards
   - Create dashboard showing:
     - Request rates per service
     - Response times
     - Error rates
     - X-Ray service map


5. **Test Distributed Tracing:**
   - Make request: `/orders` → calls `/products`
   - Check X-Ray → Service Map
   - See end-to-end trace


---


## POC-11: Service Failure Handling


### **What You Build:**
- Polly retry policies
- Circuit breaker
- Timeout handling
- Fallback mechanisms


### **Cursor AI Prompts:**


#### **Prompt 1: Polly Resilience Policies**
```
In OrderService, add Polly policies for calling ProductService:
- Retry policy: 3 retries with exponential backoff
- Circuit breaker: open after 5 failures, half-open after 30 seconds
- Timeout policy: 5 seconds
- Wrap policies together
- Add to HttpClient calls
```


#### **Prompt 2: Health Check Integration**
```
Update health checks to:
- Check external dependencies (database, SQS)
- Return unhealthy if circuit breaker is open
- Include dependency status in health response
```


#### **Prompt 3: Fallback Mechanisms**
```
Add fallback for ProductService calls:
- If circuit breaker open, return cached data
- Log fallback usage
- Alert when fallback is used (CloudWatch alarm)
```


### **Manual Steps:**
1. **Test Circuit Breaker:**
   ```powershell
   # Kill ProductService pods
   kubectl scale deployment productservice --replicas=0 -n microservices
   
   # Make requests to OrderService
   # Should see circuit breaker open after failures
   ```


2. **Monitor in CloudWatch/X-Ray:**
   - Check dependency failures
   - See circuit breaker events
   - Verify retry attempts


3. **Restore Service:**
   ```powershell
   kubectl scale deployment productservice --replicas=2 -n microservices
   # Circuit breaker should close after successful calls
   ```


---


## POC-12: Async Notification Flow


### **What You Build:**
- SQS integration
- Event publishing from OrderService
- Event consumption in NotificationService
- Dead letter queue handling


### **Cursor AI Prompts:**


#### **Prompt 1: SQS Publisher**
```
In OrderService:
- Install: AWSSDK.SQS
- Create SQS client
- Publish "OrderPlaced" event after order creation
- Include correlation ID in message attributes
- Handle publish failures with retry
```


#### **Prompt 2: SQS Consumer**
```
In NotificationService:
- Create background service (IHostedService)
- Consume messages from SQS queue
- Process notifications (email/SMS mock)
- Delete message on success
- Send to DLQ on failure
- Use correlation ID for logging
```


#### **Prompt 3: Event Models**
```
Create shared event models:
- OrderPlacedEvent (OrderId, CustomerEmail, ProductId, Quantity)
- Use JSON serialization
- Version events for future compatibility
```


### **Manual Steps:**
1. **Get SQS Queue URL:**
   ```powershell
   aws sqs get-queue-url --queue-name notification-queue --region us-east-1
   ```


2. **Add to Secrets Manager:**
   ```powershell
   aws secretsmanager create-secret --name microservices-poc/SQS/NotificationQueueUrl --secret-string "<queue-url>" --region us-east-1
   ```


3. **Create Queue (if not via Terraform):**
   ```powershell
   aws sqs create-queue --queue-name notification-queue --region us-east-1
   aws sqs create-queue --queue-name notification-queue-dlq --region us-east-1
   ```


4. **Test Flow:**
   ```powershell
   # Create order via API
   curl -X POST http://<alb-url>/orders -d '{"productId": 1, "quantity": 2, "customerEmail": "test@example.com"}'
   
   # Check NotificationService logs
   kubectl logs -n microservices deployment/notificationservice -f
   # Should see message processed
   ```


5. **Test Dead Letter:**
   - Simulate failure in NotificationService
   - Verify message goes to DLQ
   - Check DLQ in AWS Console


---


## POC-13: Scale Hot Services Only


### **What You Build:**
- HPA per service
- CPU/request-based scaling
- Load testing


### **Cursor AI Prompts:**


#### **Prompt 1: HPA Configuration**
```
Create HPA manifests for each service:
- ProductService HPA:
  - Min replicas: 2
  - Max replicas: 10
  - Target CPU: 70%
  - Target memory: 80%
- OrderService HPA (higher scale):
  - Min replicas: 3
  - Max replicas: 20
  - Target CPU: 70%
- NotificationService HPA:
  - Min replicas: 2
  - Max replicas: 5
```


### **Manual Steps:**
1. **Install Metrics Server (if not present):**
   ```powershell
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```


2. **Apply HPA:**
   ```powershell
   kubectl apply -f infra/k8s/hpa/productservice-hpa.yaml -n microservices
   kubectl apply -f infra/k8s/hpa/orderservice-hpa.yaml -n microservices
   ```


3. **Generate Load:**
   ```powershell
   # Install hey or use AWS Load Testing
   # Generate load on OrderService
   hey -n 10000 -c 50 http://<alb-url>/orders
   ```


4. **Watch Scaling:**
   ```powershell
   kubectl get hpa -n microservices -w
   kubectl get pods -n microservices -w
   # Should see pods scaling up
   ```


5. **Verify Cost Impact:**
   - AWS Console → Cost Explorer
   - See increased costs for scaled services only
   - Filter by tags (Service)


---


## POC-14: Canary per Service


### **What You Build:**
- Canary deployment for ProductService
- Traffic splitting
- Gradual rollout


### **Cursor AI Prompts:**


#### **Prompt 1: Canary Deployment Strategy**
```
Create canary deployment manifests:
- productservice-canary deployment (10% traffic)
- productservice-stable deployment (90% traffic)
- Use ALB target group annotations for traffic splitting
- Add version labels
```


#### **Prompt 2: ALB Traffic Splitting**
```
Update ingress rules to:
- Split traffic between stable and canary target groups
- Use alb.ingress.kubernetes.io/actions annotations
- Gradually increase canary traffic (10% → 50% → 100%)
```


### **Manual Steps:**
1. **Deploy Canary:**
   ```powershell
   # Deploy canary version
   kubectl apply -f infra/k8s/productservice/productservice-canary.yaml -n microservices
   ```


2. **Configure Traffic Split:**
   ```powershell
   # Update ingress with canary annotations
   kubectl annotate ingress microservices-ingress -n microservices alb.ingress.kubernetes.io/actions.canary='{"Type":"forward","ForwardConfig":{"TargetGroups":[{"ServiceName":"productservice-stable","Weight":90},{"ServiceName":"productservice-canary","Weight":10}]}}' --overwrite
   ```


3. **Monitor:**
   ```powershell
   # Check canary pod logs
   kubectl logs -n microservices -l version=canary -f
   
   # Check metrics
   # CloudWatch → Compare stable vs canary metrics
   ```


4. **Promote Canary:**
   ```powershell
   # Increase to 50%
   kubectl annotate ingress microservices-ingress -n microservices alb.ingress.kubernetes.io/actions.canary='{"Type":"forward","ForwardConfig":{"TargetGroups":[{"ServiceName":"productservice-stable","Weight":50},{"ServiceName":"productservice-canary","Weight":50}]}}' --overwrite
   
   # If successful, increase to 100% and remove canary
   kubectl annotate ingress microservices-ingress -n microservices alb.ingress.kubernetes.io/actions.canary='{"Type":"forward","ForwardConfig":{"TargetGroups":[{"ServiceName":"productservice-canary","Weight":100}]}}' --overwrite
   kubectl delete deployment productservice-canary -n microservices
   ```


---


## POC-15: Microservice Security Hardening


### **What You Build:**
- AWS WAF on ALB
- Security headers middleware
- Rate limiting per route
- DDoS protection (AWS Shield)


### **Cursor AI Prompts:**


#### **Prompt 1: Security Headers Middleware**
```
Add security headers to all services:
- HSTS
- X-Content-Type-Options
- X-Frame-Options
- Content-Security-Policy
- Remove server headers
```


### **Manual Steps:**
1. **Create WAF Web ACL:**
   ```powershell
   # Create WAF web ACL
   aws wafv2 create-web-acl --name microservices-waf --scope REGIONAL --default-action Allow={} --region us-east-1
   ```


2. **Configure WAF Rules:**
   - AWS Console → WAF & Shield → Web ACLs
   - Add managed rule groups:
     - AWSManagedRulesCommonRuleSet
     - AWSManagedRulesKnownBadInputsRuleSet
     - AWSManagedRulesSQLiRuleSet
   - Set to Block action


3. **Associate WAF with ALB:**
   ```powershell
   # Get ALB ARN
   $ALB_ARN = (aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(LoadBalancerName, 'k8s-microservices')].LoadBalancerArn" --output text)
   
   # Associate WAF
   aws wafv2 associate-web-acl --web-acl-arn <waf-arn> --resource-arn $ALB_ARN --region us-east-1
   ```


4. **Configure Rate Limiting:**
   - Add rate-based rule to WAF
   - Set limit (e.g., 2000 requests per 5 minutes per IP)


5. **Test WAF:**
   ```powershell
   # Try SQL injection
   curl "http://<alb-url>/products?name=' OR '1'='1"
   # Should be blocked by WAF (403 Forbidden)
   ```


6. **Enable AWS Shield:**
   - AWS Console → Shield
   - Enable AWS Shield Standard (free, automatic)
   - Or upgrade to Shield Advanced (paid)


---


## POC-16: Cost Visibility


### **What You Build:**
- Resource tagging strategy
- Budget alerts
- Cost analysis by service


### **Cursor AI Prompts:**


#### **Prompt 1: Tagging Strategy**
```
Update Terraform to add tags to all resources:
- Environment (dev/staging/prod)
- Service (product/order/notification/shared)
- CostCenter
- Owner
- Project
```


### **Manual Steps:**
1. **Update Terraform:**
   - Add tags to all resource definitions
   - Apply changes


2. **Create Budget:**
   ```powershell
   aws budgets create-budget --account-id <account-id> --budget file://budget.json --notifications-with-subscribers file://notifications.json
   ```


3. **Configure Alerts:**
   - AWS Console → Cost Management → Budgets
   - Set alert thresholds (50%, 80%, 100%)
   - Configure email/SNS notifications


4. **View Cost Analysis:**
   - AWS Console → Cost Explorer
   - Group by Tag: Service
   - See cost per service
   - Create custom reports


5. **Optimize:**
   - Identify expensive services
   - Right-size EKS nodes
   - Use Reserved Instances for stable workloads
   - Use Spot Instances for non-critical workloads


---


## POC-17: Partial DR


### **What You Build:**
- Automated backups
- Per-service restore procedures
- RPO/RTO documentation


### **Manual Steps:**
1. **Configure Automated Backups:**
   ```powershell
   # RDS automated backups are enabled by default
   # Verify backup retention
   aws rds describe-db-instances --db-instance-identifier <rds-instance> --query "DBInstances[0].BackupRetentionPeriod"
   ```


2. **Test Restore:**
   ```powershell
   # Restore RDS to point in time
   aws rds restore-db-instance-to-point-in-time --source-db-instance-identifier <source-instance> --target-db-instance-identifier productdb-restored --restore-time 2024-01-15T10:00:00Z
   ```


3. **Document RPO/RTO:**
   - Create DR runbook
   - Document per-service:
     - RPO (Recovery Point Objective)
     - RTO (Recovery Time Objective)
     - Restore procedures


4. **Test Service-Specific Restore:**
   - Restore only ProductDb
   - Verify ProductService works
   - Verify other services unaffected


5. **Configure Multi-AZ (Optional):**
   ```powershell
   # Enable Multi-AZ for RDS
   aws rds modify-db-instance --db-instance-identifier <rds-instance> --multi-az --apply-immediately
   ```


6. **Configure Cross-Region Backup (Optional):**
   ```powershell
   # Copy RDS snapshot to another region
   aws rds copy-db-snapshot --source-db-snapshot-identifier <snapshot-id> --target-db-snapshot-identifier productdb-snapshot-dr --region us-west-2
   ```


---


## POC-18: Service Incident Simulation


### **What You Build:**
- Chaos engineering test
- Incident response playbook
- RCA template


### **Manual Steps:**
1. **Simulate Failure:**
   ```powershell
   # Kill OrderService pods
   kubectl scale deployment orderservice --replicas=0 -n microservices
   ```


2. **Observe Impact:**
   - Check CloudWatch alarms
   - Verify other services still work
   - Check user-facing errors
   - Check X-Ray traces


3. **Auto-Recovery Test:**
   ```powershell
   # HPA should try to scale up
   # Or manual recovery
   kubectl scale deployment orderservice --replicas=2 -n microservices
   ```


4. **Document Incident:**
   - Create RCA document:
     - What happened
     - Impact
     - Root cause
     - Resolution
     - Prevention steps


5. **Test Rollback:**
   ```powershell
   # Rollback to previous version
   kubectl rollout undo deployment orderservice -n microservices
   ```


6. **Verify Monitoring:**
   - Check all alarms fired
   - Verify dashboards updated
   - Test SNS notification channels


---


## 📋 Final Checklist


After completing all POCs, verify:


- [ ] All 3 services deployed to EKS
- [ ] Independent CI/CD pipelines
- [ ] Health probes working
- [ ] ALB ingress routing functional
- [ ] Secrets Manager integration working
- [ ] Separate databases per service
- [ ] X-Ray showing distributed traces
- [ ] SQS async flow working
- [ ] HPA scaling services
- [ ] Canary deployment tested
- [ ] WAF protecting services
- [ ] Cost visibility by service
- [ ] DR procedures documented
- [ ] Incident response tested


---


## 🚀 Quick Start Commands


```powershell
# Setup
aws configure
aws eks update-kubeconfig --region us-east-1 --name eks-microservices-poc


# Build and push images
$ECR_REGISTRY = "<account-id>.dkr.ecr.us-east-1.amazonaws.com"
docker build -t $ECR_REGISTRY/productservice:v1.0.0 ./src/ProductService
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY
docker push $ECR_REGISTRY/productservice:v1.0.0


# Deploy to EKS
kubectl apply -f infra/k8s/ -n microservices


# Check status
kubectl get all -n microservices


# View logs
kubectl logs -n microservices deployment/productservice -f


# Scale
kubectl scale deployment productservice --replicas=3 -n microservices
```


---


**Next**: Start with POC-0 and work through sequentially. Each POC builds on the previous one!

