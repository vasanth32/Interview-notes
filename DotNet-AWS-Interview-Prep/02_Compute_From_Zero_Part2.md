# 02. Compute (From Zero) - Part 2

---

## Question 4: EC2 vs Elastic Beanstalk

### 1. Real-world Problem (Without AWS)

You deployed your ASP.NET Core API on EC2. Everything works, but you realize:

**Problems:**
- Every deployment: Connect via RDP, stop service, copy files, start service (manual, error-prone)
- Scaling: You manually launch new EC2 instances when traffic spikes
- Load balancer: You manually configure Application Load Balancer
- Health checks: You manually set up CloudWatch alarms
- SSL certificates: You manually install and renew certificates

**The Real Problem:** You're spending too much time on infrastructure, not on features.

### 2. Why AWS Created Elastic Beanstalk

AWS said: *"What if we automate all the infrastructure setup? You just upload your code, we handle deployment, scaling, load balancing, monitoring."*

**Elastic Beanstalk = Platform-as-a-Service (PaaS)**
- You focus on code
- AWS handles infrastructure automatically

### 3. Basic Explanation (Very Simple Words)

**EC2 = You manage everything**
- You launch server, install .NET, deploy code, configure load balancer, set up scaling
- Full control, but more work

**Elastic Beanstalk = AWS manages infrastructure, you manage code**
- You upload your .NET app (ZIP file or Docker image)
- AWS automatically: Launches EC2, installs .NET, deploys code, sets up load balancer, configures scaling
- Less control, but much easier

**Analogy:**
- **EC2 = Building a house from scratch** (you choose everything, do everything)
- **Elastic Beanstalk = Buying a pre-built house** (you choose furniture, but structure is ready)

### 4. Internal Working (High-Level)

**EC2 Manual Deployment:**
```
You → Launch EC2 → Install .NET → Deploy Code → Configure ALB → Set Auto Scaling
(5-10 manual steps, takes 30-60 minutes)
```

**Elastic Beanstalk Automated Deployment:**
```
You → Upload ZIP/Docker → Elastic Beanstalk
    ↓
Elastic Beanstalk Automatically:
    1. Launches EC2 instances
    2. Installs .NET Runtime
    3. Deploys your code
    4. Creates Application Load Balancer
    5. Sets up Auto Scaling Group
    6. Configures Health Checks
    7. Sets up CloudWatch Logging
(1 step, takes 5-10 minutes)
```

**Behind the Scenes:**
- Elastic Beanstalk uses EC2, ALB, Auto Scaling under the hood
- It's a wrapper that automates the setup
- You can still access underlying EC2 instances if needed

### 5. .NET Core / C# Real-Time Example

**EC2 Approach (Manual):**
```csharp
// Step 1: Build & Publish
dotnet publish -c Release -o ./publish

// Step 2: Launch EC2 (manual in Console)
// Step 3: Connect via RDP
// Step 4: Install .NET Runtime
// Step 5: Copy files
scp -r ./publish ec2-user@54.123.45.67:/app/

// Step 6: Run API
dotnet MyApi.dll

// Step 7: Configure Load Balancer (manual)
// Step 8: Set up Auto Scaling (manual)
// Step 9: Configure Health Checks (manual)
// Total time: 1-2 hours
```

**Elastic Beanstalk Approach (Automated):**
```csharp
// Step 1: Build & Publish
dotnet publish -c Release -o ./publish

// Step 2: Create ZIP
Compress-Archive -Path ./publish -DestinationPath api.zip

// Step 3: Deploy to Elastic Beanstalk
aws elasticbeanstalk create-application-version \
  --application-name my-api \
  --version-label v1.0.0 \
  --source-bundle S3Bucket=my-bucket,S3Key=api.zip

aws elasticbeanstalk update-environment \
  --environment-name my-api-prod \
  --version-label v1.0.0

// That's it! Elastic Beanstalk handles everything else
// Total time: 5 minutes
```

**Elastic Beanstalk Configuration (.ebextensions):**
```yaml
# .ebextensions/app.config
option_settings:
  aws:elasticbeanstalk:application:environment:
    ASPNETCORE_ENVIRONMENT: Production
    ConnectionStrings__DefaultConnection: "Server=mydb.rds.amazonaws.com;..."
  aws:autoscaling:asg:
    MinSize: 2
    MaxSize: 10
  aws:elasticbeanstalk:healthreporting:system:
    SystemType: enhanced
```

### 6. Production Usage Scenario

**Scenario:** E-commerce API with variable traffic

**EC2 Approach:**
- Manual deployment: 30 minutes per deployment
- Manual scaling: You monitor CloudWatch, manually add/remove instances
- Load balancer: Manually configure target groups, health checks
- SSL: Manually install certificate, renew every year
- **Total infrastructure management: 4-6 hours/month**

**Elastic Beanstalk Approach:**
- Automated deployment: 5 minutes per deployment
- Auto Scaling: Automatically scales based on traffic
- Load balancer: Automatically configured
- SSL: Automatically managed via AWS Certificate Manager
- **Total infrastructure management: 30 minutes/month**

**Cost:** Same (you pay for underlying EC2, ALB, etc.)
**Time Saved:** 90% less time on infrastructure

### 7. Common Mistakes by .NET Developers

❌ **Mistake 1:** Using EC2 when Elastic Beanstalk would be better
```csharp
// BAD: Manual EC2 deployment for simple web API
// You spend hours on infrastructure instead of features
```
```csharp
// GOOD: Use Elastic Beanstalk for standard web APIs
// Focus on code, let AWS handle infrastructure
```

❌ **Mistake 2:** Not understanding Elastic Beanstalk limitations
- **Elastic Beanstalk is great for:** Standard web apps, APIs, simple architectures
- **EC2 is better for:** Custom configurations, complex architectures, full control needed

❌ **Mistake 3:** Not using .ebextensions for configuration
```csharp
// BAD: Hardcoding configuration in code
var connectionString = "Server=localhost;Database=MyDB;";
```
```csharp
// GOOD: Use .ebextensions to set environment variables
// .ebextensions/app.config
option_settings:
  aws:elasticbeanstalk:application:environment:
    ConnectionStrings__DefaultConnection: "Server=mydb.rds.amazonaws.com;..."
```

### 8. Interview-Ready Answer

**"What's the difference between EC2 and Elastic Beanstalk?"**

**EC2 (Infrastructure-as-a-Service):**
- You have full control over the server
- You manually: Launch instances, install software, deploy code, configure load balancer, set up scaling
- **Use Case:** Custom configurations, complex architectures, need full control

**Elastic Beanstalk (Platform-as-a-Service):**
- AWS automates infrastructure setup
- You just upload your code (ZIP or Docker), AWS handles the rest
- AWS automatically: Launches EC2, installs runtime, deploys code, creates ALB, sets up Auto Scaling
- **Use Case:** Standard web applications, APIs, want to focus on code not infrastructure

**Key Differences:**
- **Control:** EC2 = Full control, Elastic Beanstalk = Less control (but can still access underlying EC2)
- **Effort:** EC2 = More manual work, Elastic Beanstalk = Automated
- **Flexibility:** EC2 = Highly flexible, Elastic Beanstalk = Standard patterns
- **Cost:** Same (you pay for underlying resources)

**For .NET Applications:** 
- **Elastic Beanstalk:** Perfect for standard ASP.NET Core APIs, web apps
- **EC2:** Better for custom Windows Services, complex architectures, need specific configurations

**Best Practice:** Start with Elastic Beanstalk for standard apps, use EC2 when you need custom control.

### 9. Tricky Follow-Up Question

**Q: "Can I customize Elastic Beanstalk environments?"**

**A:** Yes! You can:
- Use `.ebextensions` configuration files to customize environment
- Access underlying EC2 instances for advanced configurations
- Modify Auto Scaling settings, load balancer settings
- Install additional software via `.ebextensions` commands

**However:** If you need too much customization, EC2 might be a better fit.

**Q: "Does Elastic Beanstalk support .NET Framework or only .NET Core?"**

**A:** Elastic Beanstalk supports both:
- **.NET Core/.NET 5+:** Native support, runs on Linux or Windows
- **.NET Framework:** Runs on Windows Server (IIS)

### 10. One-Line Takeaway

**EC2 = Full control, manual setup; Elastic Beanstalk = Automated infrastructure, focus on code; choose based on how much control vs convenience you need.**

---

## Question 5: ECS & EKS (WHY & WHEN)

### 1. Real-world Problem (Without AWS)

You have multiple microservices:
- User Service (ASP.NET Core)
- Order Service (ASP.NET Core)
- Payment Service (ASP.NET Core)
- Notification Service (ASP.NET Core)

**Problems with EC2/Elastic Beanstalk:**
- Each service needs its own EC2 instance (or you run multiple on one, causing conflicts)
- Deployment: Stop all services, deploy one, start all (downtime)
- Scaling: Scale entire EC2 instance (can't scale individual services)
- Resource waste: One service uses 80% CPU, others idle

**The Real Problem:** You need to run multiple isolated applications efficiently, with independent scaling and deployment.

### 2. Why AWS Created ECS & EKS

AWS said: *"What if we use containers? Each service runs in its own isolated container. You can run multiple containers on one server, scale them independently, deploy them separately."*

**Containers = Lightweight packages that include your app + dependencies**
- Isolated from each other
- Can run multiple on one server
- Easy to deploy, scale, update

**ECS (Elastic Container Service) = AWS's container orchestration**
**EKS (Elastic Kubernetes Service) = Managed Kubernetes (industry standard)**

### 3. Basic Explanation (Very Simple Words)

**Containers vs Virtual Machines:**

**Virtual Machine (EC2):**
- Full OS (Windows Server or Linux)
- Heavy (several GB)
- One app per VM typically
- Slow to start (minutes)

**Container (Docker):**
- Shares host OS, only includes app + dependencies
- Lightweight (MB, not GB)
- Multiple containers on one server
- Fast to start (seconds)

**Analogy:**
- **VM = Entire apartment** (full kitchen, bathroom, bedroom)
- **Container = Room in shared apartment** (shares kitchen/bathroom, but your own room)

**ECS vs EKS:**
- **ECS:** AWS's own container orchestration (simpler, AWS-native)
- **EKS:** Managed Kubernetes (industry standard, more complex, more features)

### 4. Internal Working (High-Level)

**Traditional EC2 Approach:**
```
EC2 Instance 1 → User Service
EC2 Instance 2 → Order Service
EC2 Instance 3 → Payment Service
(3 servers, each running one service)
```

**Container Approach (ECS/EKS):**
```
EC2 Instance 1:
  - Container: User Service
  - Container: Order Service
  - Container: Payment Service
(1 server, running 3 services in isolated containers)
```

**ECS Architecture:**
```
Your Docker Image (stored in ECR - Elastic Container Registry)
    ↓
ECS Cluster (group of EC2 instances)
    ↓
ECS Service (runs your containers)
    ↓
Application Load Balancer (routes traffic to containers)
```

**EKS Architecture:**
```
Your Docker Image (stored in ECR)
    ↓
EKS Cluster (managed Kubernetes cluster)
    ↓
Kubernetes Pods (runs your containers)
    ↓
Kubernetes Service (load balances between pods)
```

### 5. .NET Core / C# Real-Time Example

**Step 1: Create Dockerfile for Your API**
```dockerfile
# Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["MyApi.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet build -c Release -o /app/build

FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

**Step 2: Build & Push to ECR**
```bash
# Create ECR repository
aws ecr create-repository --repository-name my-api

# Build Docker image
docker build -t my-api .

# Tag image
docker tag my-api:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/my-api:latest

# Push to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/my-api:latest
```

**Step 3: Deploy to ECS**
```json
// task-definition.json
{
  "family": "my-api",
  "networkMode": "awsvpc",
  "containerDefinitions": [
    {
      "name": "my-api",
      "image": "123456789.dkr.ecr.us-east-1.amazonaws.com/my-api:latest",
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
        }
      ]
    }
  ],
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512"
}
```

```bash
# Register task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Create ECS service
aws ecs create-service \
  --cluster my-cluster \
  --service-name my-api \
  --task-definition my-api \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345],securityGroups=[sg-12345],assignPublicIp=ENABLED}"
```

### 6. Production Usage Scenario

**Scenario:** Microservices architecture with 5 services

**EC2 Approach:**
- 5 EC2 instances (one per service) = $150/month
- Manual deployment per service
- Can't scale individual services independently
- Resource waste (each instance underutilized)

**ECS Approach:**
- 2 EC2 instances (or Fargate - serverless) running all 5 containers = $60/month
- Independent deployment per service (zero downtime)
- Independent scaling per service
- Better resource utilization
- **Cost savings: 60%**

**ECS Fargate (Serverless Containers):**
- No EC2 instances to manage
- Pay only for running containers
- Auto-scaling built-in
- **Even simpler, slightly more expensive than EC2-based ECS**

### 7. Common Mistakes by .NET Developers

❌ **Mistake 1:** Using EC2 for microservices
```csharp
// BAD: One EC2 per microservice
// Wasteful, hard to manage, can't scale independently
```
```csharp
// GOOD: Use ECS/EKS for microservices
// Efficient, independent scaling, easy deployment
```

❌ **Mistake 2:** Not understanding when to use ECS vs EKS
- **ECS:** Simpler, AWS-native, good for AWS-only deployments
- **EKS:** Industry standard (Kubernetes), good if you need portability or advanced K8s features

**For most .NET microservices:** ECS is simpler and sufficient.

❌ **Mistake 3:** Not optimizing Docker images
```dockerfile
# BAD: Large image (includes SDK in production)
FROM mcr.microsoft.com/dotnet/sdk:8.0
# Image size: ~800 MB
```
```dockerfile
# GOOD: Multi-stage build, only runtime in final image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
# Image size: ~200 MB (75% smaller)
```

### 8. Interview-Ready Answer

**"Explain ECS and EKS, when to use each"**

**Containers Overview:**
Containers package your application with its dependencies in an isolated environment. Unlike VMs, containers share the host OS, making them lightweight and fast to start.

**ECS (Elastic Container Service):**
- AWS's native container orchestration service
- Simpler than Kubernetes, AWS-integrated
- Supports both EC2 (you manage servers) and Fargate (serverless, no servers)
- **Use Case:** AWS-only deployments, want simplicity, standard container orchestration needs

**EKS (Elastic Kubernetes Service):**
- Managed Kubernetes service (industry standard)
- More complex, but more features and portability
- Can run on AWS, on-premise, or other clouds
- **Use Case:** Need Kubernetes features, multi-cloud strategy, team already knows Kubernetes

**When to Use Containers (ECS/EKS) vs EC2:**
- **Use Containers:** Microservices, need independent scaling, frequent deployments, multiple apps on one server
- **Use EC2:** Single monolithic app, need full OS control, legacy applications

**For .NET Applications:**
- **Microservices:** Use ECS (simpler) or EKS (if you need K8s)
- **Monolithic API:** EC2 or Elastic Beanstalk is fine
- **Modern .NET apps:** Containers are recommended (cloud-native, efficient)

**ECS vs EKS Choice:**
- **Choose ECS:** If you're AWS-only, want simplicity, standard orchestration needs
- **Choose EKS:** If you need Kubernetes features, multi-cloud, team knows K8s

### 9. Tricky Follow-Up Question

**Q: "What's the difference between ECS on EC2 and ECS Fargate?"**

**A:**
- **ECS on EC2:** You manage EC2 instances, install ECS agent, more control, cheaper for consistent workloads
- **ECS Fargate:** Serverless, AWS manages servers, pay only for running containers, simpler, slightly more expensive

**For most .NET apps:** Fargate is recommended (simpler, no server management).

**Q: "Can I run Windows containers on ECS/EKS?"**

**A:** 
- **ECS:** Yes, supports Windows containers (Windows Server Core base image)
- **EKS:** Yes, supports Windows nodes
- **Note:** Windows containers are larger and slower to start than Linux containers

**For .NET Core/.NET 5+:** Use Linux containers (smaller, faster, cheaper).
**For .NET Framework:** Must use Windows containers.

### 10. One-Line Takeaway

**ECS/EKS = Container orchestration for running multiple isolated apps efficiently; ECS for simplicity, EKS for Kubernetes features; use containers for microservices, independent scaling, frequent deployments.**

---

