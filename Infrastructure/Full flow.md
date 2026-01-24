# Azure Microservices POC — Step-by-Step Implementation Guide


> **For each POC**: Use Cursor AI prompts to generate code, then follow manual steps for Azure setup.


---


## 🎯 Prerequisites (Do Once)


### **Manual Steps:**
1. **Install Tools:**
   ```powershell
   # Install .NET 8 SDK
   winget install Microsoft.DotNet.SDK.8


   # Install Docker Desktop
   winget install Docker.DockerDesktop


   # Install Azure CLI
   winget install Microsoft.AzureCLI


   # Install kubectl
   winget install Kubernetes.kubectl


   # Install Terraform
   winget install Hashicorp.Terraform
   ```


2. **Azure Account Setup:**
   - Create Azure account (free tier available)
   - Install Azure CLI: `az login`
   - Create resource group: `az group create --name rg-microservices-poc --location eastus`


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
- Azure credentials
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


3. **Create Azure Container Registry:**
   ```powershell
   az acr create --resource-group rg-microservices-poc --name <your-acr-name> --sku Basic
   az acr login --name <your-acr-name>
   ```


4. **Tag and Push:**
   ```powershell
   docker tag productservice:latest <your-acr-name>.azurecr.io/productservice:v1.0.0
   docker tag orderservice:latest <your-acr-name>.azurecr.io/orderservice:v1.0.0
   docker tag notificationservice:latest <your-acr-name>.azurecr.io/notificationservice:v1.0.0


   docker push <your-acr-name>.azurecr.io/productservice:v1.0.0
   docker push <your-acr-name>.azurecr.io/orderservice:v1.0.0
   docker push <your-acr-name>.azurecr.io/notificationservice:v1.0.0
   ```


5. **Verify in Azure Portal:**
   - Go to Container Registry → Repositories
   - See all 3 images


---


## POC-4: Terraform for Microservices Infra


### **What You Build:**
- Terraform scripts for shared infrastructure
- AKS cluster
- ACR (if not created manually)
- Log Analytics Workspace
- Service Bus namespace
- Database resources (per service)


### **Cursor AI Prompts:**


#### **Prompt 1: Terraform Main Configuration**
```
Create Terraform configuration in /infra/terraform/main.tf:
- Azure provider configuration
- Resource group (rg-microservices-poc)
- Variables file for:
  - location (default: eastus)
  - environment (default: dev)
  - acr_name
  - aks_cluster_name
- Outputs for:
  - resource_group_name
  - aks_cluster_name
  - acr_login_server
```


#### **Prompt 2: AKS Cluster Module**
```
Create /infra/terraform/modules/aks/main.tf:
- Azure Kubernetes Service cluster
- Node pool (system pool: 1 node, user pool: 2-3 nodes)
- Enable RBAC
- Enable Azure Monitor
- Network plugin: azure
- Service principal or managed identity
- Output: kube_config, host, client_key, client_certificate
```


#### **Prompt 3: Service Bus Module**
```
Create /infra/terraform/modules/servicebus/main.tf:
- Service Bus namespace
- Queue for notifications (notification-queue)
- Output: connection_string, queue_name
```


#### **Prompt 4: Database Modules**
```
Create /infra/terraform/modules/databases/main.tf:
- Azure SQL Server (or PostgreSQL flexible server)
- ProductService database
- OrderService database
- Private endpoint configuration (optional for POC)
- Firewall rules (allow Azure services)
- Output: connection strings (store in Key Vault later)
```


#### **Prompt 5: Log Analytics Module**
```
Create /infra/terraform/modules/monitoring/main.tf:
- Log Analytics Workspace
- Application Insights (one per service or shared)
- Output: workspace_id, instrumentation_key
```


### **Manual Steps:**
1. **Initialize Terraform:**
   ```powershell
   cd infra/terraform
   terraform init
   ```


2. **Create terraform.tfvars:**
   ```hcl
   location = "eastus"
   environment = "dev"
   acr_name = "<your-acr-name>"
   aks_cluster_name = "aks-microservices-poc"
   ```


3. **Plan and Apply:**
   ```powershell
   terraform plan
   terraform apply
   # Type 'yes' to confirm
   ```


4. **Get AKS Credentials:**
   ```powershell
   az aks get-credentials --resource-group rg-microservices-poc --name aks-microservices-poc
   kubectl get nodes
   ```


5. **Verify Resources:**
   - Azure Portal → Resource Group
   - See: AKS, ACR, Service Bus, Databases, Log Analytics


---


## POC-5: AKS Deployment per Service


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
  - Image from ACR
  - Replicas: 2
  - Resource limits (CPU: 500m, Memory: 512Mi)
  - Environment variables from ConfigMap
  - Health probes (liveness, readiness)
  - Port: 8080
- service.yaml:
  - ClusterIP type
  - Port 80 → 8080
  - Selector matching deployment
- configmap.yaml:
  - App settings (non-sensitive)
- secret.yaml (template):
  - Database connection string (placeholder)
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
- Add labels for cost tracking
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
   docker build -t <acr-name>.azurecr.io/productservice:v1.1.0 .
   docker push <acr-name>.azurecr.io/productservice:v1.1.0


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
- NGINX Ingress Controller
- Ingress rules for routing
- TLS termination


### **Cursor AI Prompts:**


#### **Prompt 1: Ingress Controller Installation**
```
Create /infra/k8s/ingress/nginx-ingress.yaml:
- NGINX Ingress Controller deployment
- Service type: LoadBalancer
- Use official NGINX Ingress Controller image
- Add annotations for Azure integration
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
  - SSL redirect
  - Rate limiting (optional)
```


### **Manual Steps:**
1. **Install NGINX Ingress:**
   ```powershell
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
   ```


2. **Get External IP:**
   ```powershell
   kubectl get service ingress-nginx-controller -n ingress-nginx
   # Wait for EXTERNAL-IP (may take 2-3 minutes)
   ```


3. **Apply Ingress Rules:**
   ```powershell
   kubectl apply -f infra/k8s/ingress/ingress-rules.yaml -n microservices
   ```


4. **Test Routing:**
   ```powershell
   # Get external IP
   $EXTERNAL_IP = (kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')


   # Test routes
   curl http://$EXTERNAL_IP/products/health
   curl http://$EXTERNAL_IP/orders/health
   ```


5. **Configure DNS (Optional):**
   - Create A record pointing to EXTERNAL-IP
   - Update ingress rules with hostname


---


## POC-8: Secure Inter-Service Access


### **What You Build:**
- Azure Key Vault integration
- Managed Identity for AKS
- JWT authentication at gateway
- Secrets from Key Vault


### **Cursor AI Prompts:**


#### **Prompt 1: Key Vault Integration in Services**
```
Update each service to:
- Use Azure Key Vault provider for configuration
- Install: Azure.Extensions.AspNetCore.Configuration.Secrets
- In Program.cs, add Key Vault configuration source
- Read connection strings from Key Vault
- Use Managed Identity authentication
```


#### **Prompt 2: JWT Authentication Middleware**
```
Create shared authentication middleware:
- JWT token validation
- Extract claims (user ID, roles)
- Add to HttpContext.User
- Use Microsoft.AspNetCore.Authentication.JwtBearer
- Validate against Azure AD (or custom issuer)
```


#### **Prompt 3: Update Ingress with Auth**
```
Add authentication annotations to ingress:
- Use cert-manager for TLS (optional)
- Add rate limiting per route
- Add IP whitelisting (optional)
```


### **Manual Steps:**
1. **Create Key Vault:**
   ```powershell
   az keyvault create --name <your-kv-name> --resource-group rg-microservices-poc --location eastus
   ```


2. **Add Secrets:**
   ```powershell
   az keyvault secret set --vault-name <your-kv-name> --name "ProductService--ConnectionStrings--DefaultConnection" --value "your-connection-string"
   az keyvault secret set --vault-name <your-kv-name> --name "OrderService--ConnectionStrings--DefaultConnection" --value "your-connection-string"
   ```


3. **Enable Managed Identity for AKS:**
   ```powershell
   az aks update --resource-group rg-microservices-poc --name aks-microservices-poc --enable-managed-identity
   ```


4. **Grant Key Vault Access:**
   ```powershell
   # Get AKS managed identity
   $AKS_IDENTITY = (az aks show --resource-group rg-microservices-poc --name aks-microservices-poc --query identity.principalId -o tsv)
   
   # Grant access
   az keyvault set-policy --name <your-kv-name> --object-id $AKS_IDENTITY --secret-permissions get list
   ```


5. **Update Deployment Manifests:**
   - Add environment variable: `AZURE_CLIENT_ID` (managed identity)
   - Add Key Vault configuration


6. **Test:**
   ```powershell
   kubectl logs -n microservices deployment/productservice
   # Should see Key Vault connection successful
   ```


---


## POC-9: Database Isolation


### **What You Build:**
- Separate databases per service
- Entity Framework Core integration
- Private endpoint configuration
- Connection pooling


### **Cursor AI Prompts:**


#### **Prompt 1: ProductService Database Setup**
```
In ProductService:
- Add Entity Framework Core packages
- Create DbContext (ProductDbContext)
- Create Product entity with migrations
- Add connection string from Key Vault
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
   # Get SQL server name from Terraform output
   az sql db create --resource-group rg-microservices-poc --server <sql-server-name> --name ProductDb --service-objective Basic
   az sql db create --resource-group rg-microservices-poc --server <sql-server-name> --name OrderDb --service-objective Basic
   ```


2. **Configure Firewall:**
   ```powershell
   # Allow Azure services
   az sql server firewall-rule create --resource-group rg-microservices-poc --server <sql-server-name> --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
   ```


3. **Get Connection Strings:**
   ```powershell
   az sql db show-connection-string --server <sql-server-name> --name ProductDb --client ado.net
   # Add to Key Vault
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
- Application Insights per service
- Correlation IDs
- Distributed tracing
- Centralized dashboards


### **Cursor AI Prompts:**


#### **Prompt 1: Application Insights Integration**
```
In each service, add Application Insights:
- Install: Microsoft.ApplicationInsights.AspNetCore
- Add instrumentation key from configuration
- Enable dependency tracking
- Add custom telemetry (correlation IDs)
- Log all HTTP requests
- Track external calls (Service Bus, Database)
```


#### **Prompt 2: Correlation ID Middleware**
```
Create shared middleware for correlation IDs:
- Generate correlation ID if not present
- Add to HttpContext
- Add to all log messages
- Propagate to downstream services (HTTP headers)
- Add to Service Bus messages
```


#### **Prompt 3: Structured Logging**
```
Update all services to use:
- Serilog or Microsoft.Extensions.Logging
- Structured logging (JSON format)
- Include correlation ID in all logs
- Log to Application Insights
```


### **Manual Steps:**
1. **Get Instrumentation Keys:**
   - Azure Portal → Application Insights → Each service
   - Copy Instrumentation Key


2. **Add to Key Vault:**
   ```powershell
   az keyvault secret set --vault-name <your-kv-name> --name "ProductService--ApplicationInsights--InstrumentationKey" --value "<instrumentation-key>"
   ```


3. **Update Deployments:**
   - Add instrumentation key to ConfigMap or Key Vault


4. **Create Dashboard:**
   - Azure Portal → Application Insights → Workbooks
   - Create dashboard showing:
     - Request rates per service
     - Response times
     - Error rates
     - Dependency map


5. **Test Distributed Tracing:**
   - Make request: `/orders` → calls `/products`
   - Check Application Insights → Transaction Search
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
- Check external dependencies (database, Service Bus)
- Return unhealthy if circuit breaker is open
- Include dependency status in health response
```


#### **Prompt 3: Fallback Mechanisms**
```
Add fallback for ProductService calls:
- If circuit breaker open, return cached data
- Log fallback usage
- Alert when fallback is used
```


### **Manual Steps:**
1. **Test Circuit Breaker:**
   ```powershell
   # Kill ProductService pods
   kubectl scale deployment productservice --replicas=0 -n microservices
   
   # Make requests to OrderService
   # Should see circuit breaker open after failures
   ```


2. **Monitor in Application Insights:**
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
- Service Bus integration
- Event publishing from OrderService
- Event consumption in NotificationService
- Dead letter queue handling


### **Cursor AI Prompts:**


#### **Prompt 1: Service Bus Publisher**
```
In OrderService:
- Install: Azure.Messaging.ServiceBus
- Create ServiceBusClient
- Publish "OrderPlaced" event after order creation
- Include correlation ID in message
- Handle publish failures with retry
```


#### **Prompt 2: Service Bus Consumer**
```
In NotificationService:
- Create background service (IHostedService)
- Consume messages from Service Bus queue
- Process notifications (email/SMS mock)
- Complete message on success
- Dead letter on failure
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
1. **Get Service Bus Connection String:**
   ```powershell
   az servicebus namespace authorization-rule keys list --resource-group rg-microservices-poc --namespace-name <sb-namespace> --name RootManageSharedAccessKey --query primaryConnectionString -o tsv
   ```


2. **Add to Key Vault:**
   ```powershell
   az keyvault secret set --vault-name <your-kv-name> --name "ServiceBus--ConnectionString" --value "<connection-string>"
   ```


3. **Create Queue:**
   ```powershell
   az servicebus queue create --resource-group rg-microservices-poc --namespace-name <sb-namespace> --name notification-queue
   ```


4. **Test Flow:**
   ```powershell
   # Create order via API
   curl -X POST http://<ingress-ip>/orders -d '{"productId": 1, "quantity": 2, "customerEmail": "test@example.com"}'
   
   # Check NotificationService logs
   kubectl logs -n microservices deployment/notificationservice -f
   # Should see message processed
   ```


5. **Test Dead Letter:**
   - Simulate failure in NotificationService
   - Verify message goes to DLQ


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
   # Install hey or use Azure Load Testing
   # Generate load on OrderService
   hey -n 10000 -c 50 http://<ingress-ip>/orders
   ```


4. **Watch Scaling:**
   ```powershell
   kubectl get hpa -n microservices -w
   kubectl get pods -n microservices -w
   # Should see pods scaling up
   ```


5. **Verify Cost Impact:**
   - Azure Portal → Cost Management
   - See increased costs for scaled services only


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
- Use service mesh or ingress annotations for traffic splitting
- Add version labels
```


#### **Prompt 2: Ingress Traffic Splitting**
```
Update ingress rules to:
- Split traffic between stable and canary
- Use nginx.ingress.kubernetes.io/canary annotations
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
   kubectl annotate ingress microservices-ingress -n microservices nginx.ingress.kubernetes.io/canary=true
   kubectl annotate ingress microservices-ingress -n microservices nginx.ingress.kubernetes.io/canary-weight=10
   ```


3. **Monitor:**
   ```powershell
   # Check canary pod logs
   kubectl logs -n microservices -l version=canary -f
   
   # Check metrics
   # Application Insights → Compare stable vs canary
   ```


4. **Promote Canary:**
   ```powershell
   # Increase to 50%
   kubectl annotate ingress microservices-ingress -n microservices nginx.ingress.kubernetes.io/canary-weight=50 --overwrite
   
   # If successful, increase to 100% and remove canary
   kubectl annotate ingress microservices-ingress -n microservices nginx.ingress.kubernetes.io/canary=false --overwrite
   kubectl delete deployment productservice-canary -n microservices
   ```


---


## POC-15: Microservice Security Hardening


### **What You Build:**
- Azure Front Door or Application Gateway
- WAF rules
- Rate limiting per route
- DDoS protection


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
1. **Create Application Gateway (or Front Door):**
   ```powershell
   # Using Azure Portal or CLI
   az network application-gateway create --name agw-microservices --resource-group rg-microservices-poc --location eastus --capacity 2 --sku Standard_v2
   ```


2. **Configure WAF:**
   - Azure Portal → Application Gateway → Web Application Firewall
   - Enable WAF
   - Set to Prevention mode
   - Configure OWASP rules


3. **Add Backend Pools:**
   - Point to AKS Ingress IP
   - Configure health probes


4. **Configure Routing Rules:**
   - `/products/*` → ProductService
   - `/orders/*` → OrderService
   - Add rate limiting rules


5. **Test WAF:**
   ```powershell
   # Try SQL injection
   curl "http://<app-gateway-ip>/products?name=' OR '1'='1"
   # Should be blocked by WAF
   ```


6. **Enable DDoS Protection:**
   - Azure Portal → DDoS Protection Plans
   - Create plan and associate with VNet


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
   az consumption budget create --budget-name microservices-monthly --amount 100 --time-grain Monthly --start-date 2024-01-01 --resource-group rg-microservices-poc
   ```


3. **Configure Alerts:**
   - Azure Portal → Cost Management → Budgets
   - Set alert thresholds (50%, 80%, 100%)
   - Configure email notifications


4. **View Cost Analysis:**
   - Azure Portal → Cost Management → Cost Analysis
   - Group by Tag: Service
   - See cost per service


5. **Optimize:**
   - Identify expensive services
   - Right-size resources
   - Use reserved instances for stable workloads


---


## POC-17: Partial DR


### **What You Build:**
- Automated backups
- Per-service restore procedures
- RPO/RTO documentation


### **Manual Steps:**
1. **Configure Automated Backups:**
   ```powershell
   # Azure SQL backups are automatic
   # Verify backup retention
   az sql db show --resource-group rg-microservices-poc --server <sql-server> --name ProductDb --query backupLongTermRetentionPolicy
   ```


2. **Test Restore:**
   ```powershell
   # Restore ProductDb to point in time
   az sql db restore --resource-group rg-microservices-poc --server <sql-server> --name ProductDb --dest-name ProductDb-restored --time "2024-01-15T10:00:00Z"
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


5. **Configure Geo-Replication (Optional):**
   ```powershell
   az sql db replica create --resource-group rg-microservices-poc --server <sql-server> --name ProductDb --partner-server <secondary-server> --partner-resource-group rg-microservices-poc
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
   - Check Application Insights alerts
   - Verify other services still work
   - Check user-facing errors


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
   - Check all alerts fired
   - Verify dashboards updated
   - Test notification channels


---


## 📋 Final Checklist


After completing all POCs, verify:


- [ ] All 3 services deployed to AKS
- [ ] Independent CI/CD pipelines
- [ ] Health probes working
- [ ] Ingress routing functional
- [ ] Key Vault integration working
- [ ] Separate databases per service
- [ ] Application Insights showing distributed traces
- [ ] Service Bus async flow working
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
az login
az group create --name rg-microservices-poc --location eastus


# Build and push images
docker build -t <acr>.azurecr.io/productservice:v1.0.0 ./src/ProductService
docker push <acr>.azurecr.io/productservice:v1.0.0


# Deploy to AKS
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




