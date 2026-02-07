# AWS API Gateway POC - Complete Deployment Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Quick Start](#quick-start)
5. [Detailed Deployment Flow](#detailed-deployment-flow)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)
8. [Cleanup](#cleanup)
9. [Next Steps](#next-steps)

---

## 🎯 Overview

This project demonstrates a complete microservices architecture on AWS using:

- **3 .NET 8 Microservices**: UserService, ProductService, OrderService
- **AWS ECS Fargate**: Container orchestration (serverless containers)
- **Application Load Balancer (ALB)**: Routes traffic to services
- **AWS API Gateway**: Single entry point for all services
- **Docker**: Containerization for consistent deployments

### What This Project Does

1. **Local Development**: Run 3 microservices locally on different ports
2. **Containerization**: Package services as Docker images
3. **AWS Deployment**: Deploy containers to ECS Fargate
4. **Load Balancing**: Use ALB to route traffic to services
5. **API Gateway**: Expose services through a single API endpoint

---

## 🏗️ Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Client/Browser                        │
└────────────────────────────┬──────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  API Gateway     │  (Single Entry Point)
                    │  REST API        │  https://xxx.execute-api...
                    └────────┬─────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Application     │  (Routes to services)
                    │  Load Balancer   │  http://xxx.elb.amazonaws.com
                    └──────┬───────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  ECS Fargate │   │  ECS Fargate │   │  ECS Fargate │
│ UserService  │   │ProductService│   │OrderService  │
│  (Container) │   │  (Container) │   │  (Container) │
└──────────────┘   └──────────────┘   └──────────────┘
```

### Request Flow

1. **Client** → Sends request to API Gateway endpoint
2. **API Gateway** → Routes to Application Load Balancer
3. **ALB** → Routes to appropriate ECS service based on path
4. **ECS Task** → .NET service processes request
5. **Response** → Flows back through ALB → API Gateway → Client

### Path-Based Routing

- `/api/user*` → UserService
- `/api/product*` → ProductService  
- `/api/order*` → OrderService

---

## ✅ Prerequisites

### Required Software

1. **.NET 8 SDK** - [Download](https://dotnet.microsoft.com/download)
2. **Docker Desktop** - [Download](https://www.docker.com/products/docker-desktop)
3. **AWS CLI** - [Download](https://aws.amazon.com/cli/)
4. **PowerShell 5.1+** (Windows) or PowerShell Core (Mac/Linux)
5. **Git** - [Download](https://git-scm.com/downloads)

### AWS Account Setup

1. **AWS Account** with appropriate permissions
2. **AWS CLI Configured**:
   ```powershell
   aws configure
   ```
   Enter:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region (e.g., `us-east-1`)
   - Default output format: `json`

3. **Required IAM Permissions**:
   - ECS (Full access)
   - ECR (Full access)
   - EC2 (VPC, Security Groups, Load Balancers)
   - IAM (Role creation)
   - CloudWatch Logs
   - API Gateway (for Step 8)

   See `AWS-PERMISSIONS-REQUIRED.md` for detailed permissions.

### Verify Prerequisites

```powershell
# Check .NET
dotnet --version

# Check Docker
docker --version

# Check AWS CLI
aws --version

# Check AWS credentials
aws sts get-caller-identity
```

---

## 🚀 Quick Start

### 1. Clone and Setup

```powershell
# Navigate to project directory
cd AwsApiGateway

# Verify all services exist
ls UserService, ProductService, OrderService
```

### 2. Test Locally (Optional)

```powershell
# Test services locally
.\test-services-local.ps1
```

### 3. Deploy to AWS

```powershell
# Deploy everything to AWS ECS
.\deploy-to-ecs.ps1
```

**This script will:**
- ✅ Create ECR repositories
- ✅ Build and push Docker images
- ✅ Create ECS cluster and services
- ✅ Set up load balancer and networking
- ✅ Configure target groups and listeners

**Time Required:** 15-20 minutes

### 4. Test Deployment

```powershell
# Run automated tests
.\test-ecs-services.ps1
```

---

## 📖 Detailed Deployment Flow

### Step 1: Local Development

**What it does:**
- Creates 3 .NET microservices
- Each service runs on different ports (5001, 5002, 5003)
- Services have Swagger UI for testing

**Files:**
- `UserService/` - User management API
- `ProductService/` - Product catalog API
- `OrderService/` - Order management API

**Test locally:**
```powershell
# Run all services
.\test-services-local.ps1

# Or run individually
cd UserService
dotnet run
# Service runs on https://localhost:5001
```

---

### Step 2: Docker Containerization

**What it does:**
- Packages each service as a Docker container
- Ensures consistent deployment across environments

**Files:**
- `UserService/Dockerfile`
- `ProductService/Dockerfile`
- `OrderService/Dockerfile`

**Build locally:**
```powershell
cd UserService
docker build -t userservice:latest .
docker run -p 8080:8080 userservice:latest
```

---

### Step 3: AWS ECS Deployment

**What `deploy-to-ecs.ps1` does:**

#### 3.1 Verify AWS Configuration
- Checks AWS CLI credentials
- Verifies account ID and region

#### 3.2 Create ECR Repositories
- Creates 3 repositories in Amazon ECR:
  - `userservice`
  - `productservice`
  - `orderservice`

#### 3.3 Build and Push Docker Images
- Builds Docker images for each service
- Tags images with ECR registry URL
- Pushes images to ECR

#### 3.4 Create CloudWatch Log Groups
- Creates log groups for each service:
  - `/ecs/userservice`
  - `/ecs/productservice`
  - `/ecs/orderservice`

#### 3.5 Create ECS Cluster
- Creates cluster: `microservices-cluster`
- Uses Fargate launch type (serverless)

#### 3.6 Create IAM Roles
- Creates `ecsTaskExecutionRole` for ECS tasks
- Attaches required policies for ECR, CloudWatch, etc.

#### 3.7 Register Task Definitions
- Registers task definitions for each service
- Configures CPU (256), Memory (512MB), networking
- Sets up log configuration

#### 3.8 Network Configuration
- Gets or creates VPC and subnets
- Creates security group with port 8080 open
- Configures public IP assignment

#### 3.9 Create Application Load Balancer
- Creates ALB: `microservices-alb`
- Configures as internet-facing
- Waits for ALB to become active

#### 3.10 Create Target Groups and Listeners
- Creates target groups for each service
- Creates default listener on port 80
- Sets up path-based routing rules:
  - `/api/user*` → userservice-tg
  - `/api/product*` → productservice-tg
  - `/api/order*` → orderservice-tg

#### 3.11 Create ECS Services
- Creates ECS services for each microservice
- Links services to target groups
- Sets desired count to 1 task per service

**Script Parameters:**
```powershell
.\deploy-to-ecs.ps1 `
    -Region "us-east-1" `
    -ClusterName "microservices-cluster" `
    -VpcId "vpc-xxx" `              # Optional: auto-detects default VPC
    -SubnetId1 "subnet-xxx" `       # Optional: auto-detects subnets
    -SubnetId2 "subnet-yyy" `      # Optional: auto-detects subnets
    -SecurityGroupId "sg-xxx"       # Optional: auto-creates if needed
```

---

### Step 4: Testing (Current Step)

**What to test:**
1. Service health
2. API endpoints
3. Target group health
4. Service logs

**Automated Testing:**
```powershell
.\test-ecs-services.ps1
```

**Manual Testing:**

1. **Check Service Status:**
   ```powershell
   aws ecs describe-services `
       --cluster microservices-cluster `
       --services userservice productservice orderservice `
       --region us-east-1
   ```

2. **Test Health Endpoints:**
   ```powershell
   # Replace with your ALB DNS
   $albDns = "microservices-alb-1606965521.us-east-1.elb.amazonaws.com"
   
   Invoke-WebRequest -Uri "http://$albDns/api/user/health"
   Invoke-WebRequest -Uri "http://$albDns/api/product/health"
   Invoke-WebRequest -Uri "http://$albDns/api/order/health"
   ```

3. **Test API Endpoints:**
   ```powershell
   Invoke-WebRequest -Uri "http://$albDns/api/user"
   Invoke-WebRequest -Uri "http://$albDns/api/product"
   Invoke-WebRequest -Uri "http://$albDns/api/order"
   ```

4. **View Logs:**
   ```powershell
   aws logs tail /ecs/userservice --follow --region us-east-1
   ```

---

### Step 5: API Gateway Integration (Next Step)

**What it will do:**
- Create REST API in API Gateway
- Configure routes to ALB
- Set up CORS
- Deploy API

**Script:**
```powershell
.\setup-api-gateway.ps1
```

**This will:**
1. Create REST API
2. Create resources (`/users`, `/products`, `/orders`)
3. Configure HTTP methods (GET, POST, etc.)
4. Set up HTTP_PROXY integration to ALB
5. Enable CORS
6. Deploy API to stage
7. Provide API Gateway URL

---

## 🧪 Testing

### Local Testing

```powershell
# Test all services locally
.\test-services-local.ps1

# Test individual service
cd UserService
dotnet run
# Open browser: https://localhost:5001/swagger
```

### AWS Deployment Testing

```powershell
# Automated comprehensive test
.\test-ecs-services.ps1

# Manual endpoint testing
$albDns = "microservices-alb-1606965521.us-east-1.elb.amazonaws.com"
Invoke-WebRequest -Uri "http://$albDns/api/user"
```

### API Gateway Testing (After Step 5)

```powershell
.\test-api-gateway.ps1
```

---

## 🔧 Troubleshooting

### Common Issues

#### 1. AWS CLI Not Configured

**Error:** `AWS CLI not configured or credentials invalid`

**Solution:**
```powershell
aws configure
# Enter your AWS credentials
```

#### 2. Insufficient Permissions

**Error:** `AccessDenied` or permission errors

**Solution:**
- Check `AWS-PERMISSIONS-REQUIRED.md`
- Run `.\check-aws-permissions.ps1`
- Have admin run `.\attach-policies-admin.ps1`

#### 3. Docker Not Running

**Error:** `Cannot connect to Docker daemon`

**Solution:**
- Start Docker Desktop
- Verify: `docker ps`

#### 4. Services Not Healthy

**Error:** Services show as unhealthy in ECS

**Solution:**
```powershell
# Check service logs
aws logs tail /ecs/userservice --follow --region us-east-1

# Check target health
aws elbv2 describe-target-health `
    --target-group-arn <target-group-arn> `
    --region us-east-1

# Check service status
aws ecs describe-services `
    --cluster microservices-cluster `
    --services userservice `
    --region us-east-1
```

#### 5. Subnet Issues

**Error:** `Need at least 2 public subnets`

**Solution:**
- Specify subnets manually:
  ```powershell
  .\deploy-to-ecs.ps1 -SubnetId1 "subnet-xxx" -SubnetId2 "subnet-yyy"
  ```
- Or create subnets in different availability zones

#### 6. Port Already in Use (Local)

**Error:** `Address already in use`

**Solution:**
```powershell
# Find and kill process
netstat -ano | findstr :5001
taskkill /PID <pid> /F
```

### Getting Help

1. **Check Logs:**
   ```powershell
   aws logs tail /ecs/userservice --follow --region us-east-1
   ```

2. **Check Service Status:**
   ```powershell
   aws ecs describe-services `
       --cluster microservices-cluster `
       --services userservice `
       --region us-east-1
   ```

3. **Check Task Status:**
   ```powershell
   aws ecs list-tasks --cluster microservices-cluster --region us-east-1
   ```

---

## 🧹 Cleanup

### Stop Services (Keep Resources)

```powershell
# Stop ECS services (keeps resources, stops billing for tasks)
# Note: This script doesn't exist yet, but you can manually:
aws ecs update-service `
    --cluster microservices-cluster `
    --service userservice `
    --desired-count 0 `
    --region us-east-1
```

### Complete Cleanup (Delete Everything)

**⚠️ WARNING: This deletes all resources!**

```powershell
.\stop-billable-services.ps1
```

**This will delete:**
- ECS services
- ECS cluster
- Application Load Balancer
- Target groups
- Security groups
- ECR repositories (and images)
- CloudWatch log groups

**What it keeps:**
- VPC and subnets (shared resources)
- IAM roles (may be used by other services)

**Manual Cleanup:**
See `CLEANUP-GUIDE.md` for step-by-step instructions.

---

## 📝 Next Steps

### Immediate Next Steps

1. **✅ Complete ECS Deployment** (Current)
   - Run `.\deploy-to-ecs.ps1`
   - Verify services are running
   - Test endpoints

2. **⏳ API Gateway Integration** (Next)
   - Run `.\setup-api-gateway.ps1`
   - Configure routes to ALB
   - Test API Gateway endpoints

3. **⏳ CORS Configuration**
   - Configure CORS on API Gateway
   - Test from browser

4. **⏳ End-to-End Testing**
   - Test complete flow
   - Document API endpoints

### Future Enhancements

- [ ] Add authentication (API Keys, Cognito)
- [ ] Add rate limiting
- [ ] Set up auto-scaling
- [ ] Add monitoring and alerts
- [ ] Implement CI/CD pipeline
- [ ] Add database integration
- [ ] Implement service discovery

---

## 📚 Additional Resources

### Documentation Files

- `PROGRESS.md` - Detailed progress tracker
- `AWS-PERMISSIONS-REQUIRED.md` - IAM permissions needed
- `ECS-DEPLOYMENT-GUIDE.md` - Detailed ECS deployment guide
- `AWS-API-Gateway-POC-Guide.md` - API Gateway setup guide
- `CLEANUP-GUIDE.md` - Resource cleanup instructions
- `TESTING-GUIDE.md` - Testing procedures

### Scripts

- `deploy-to-ecs.ps1` - Main deployment script
- `test-ecs-services.ps1` - Test deployed services
- `setup-api-gateway.ps1` - API Gateway setup
- `test-api-gateway.ps1` - Test API Gateway
- `stop-billable-services.ps1` - Cleanup script
- `check-aws-permissions.ps1` - Verify permissions

### AWS Resources Created

- **ECR Repositories:** 3 (userservice, productservice, orderservice)
- **ECS Cluster:** microservices-cluster
- **ECS Services:** 3 (one per microservice)
- **Application Load Balancer:** microservices-alb
- **Target Groups:** 3 (one per service)
- **Security Group:** ecs-microservices-sg
- **IAM Role:** ecsTaskExecutionRole
- **CloudWatch Log Groups:** 3

---

## 🎓 Learning Resources

### AWS Concepts

- **ECS (Elastic Container Service)**: Container orchestration service
- **Fargate**: Serverless compute for containers
- **ECR (Elastic Container Registry)**: Docker image registry
- **ALB (Application Load Balancer)**: Layer 7 load balancer
- **API Gateway**: Managed API service
- **VPC (Virtual Private Cloud)**: Isolated network environment
- **Target Groups**: Route traffic to registered targets

### Key Commands

```powershell
# Check AWS identity
aws sts get-caller-identity

# List ECS clusters
aws ecs list-clusters --region us-east-1

# Describe services
aws ecs describe-services --cluster microservices-cluster --services userservice --region us-east-1

# View logs
aws logs tail /ecs/userservice --follow --region us-east-1

# List load balancers
aws elbv2 describe-load-balancers --region us-east-1
```

---

## 📞 Support

### Getting Help

1. **Check Logs First:**
   ```powershell
   aws logs tail /ecs/userservice --follow --region us-east-1
   ```

2. **Verify Service Status:**
   ```powershell
   aws ecs describe-services --cluster microservices-cluster --services userservice --region us-east-1
   ```

3. **Check Documentation:**
   - Review relevant `.md` files
   - Check AWS documentation

4. **Common Solutions:**
   - Restart Docker Desktop
   - Re-run deployment script (idempotent)
   - Check AWS service quotas

---

## 📄 License

This is a proof-of-concept project for learning purposes.

---

## 🙏 Acknowledgments

This project demonstrates:
- Microservices architecture
- Container orchestration
- AWS cloud services
- Infrastructure as Code (IaC) concepts
- DevOps practices

---

**Last Updated:** After Step 7 (ECS Deployment Complete)  
**Status:** ✅ ECS Services Deployed | ⏳ API Gateway Integration Next

