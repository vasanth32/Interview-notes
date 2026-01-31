# Edlio-like Online School Platform - Full Lifecycle POC Roadmap

## Overview

This document provides a comprehensive roadmap to build a complete Proof of Concept (POC) of the Edlio-like Online School Platform. This POC will help you understand the full software lifecycle, infrastructure, deployment processes, microservices architecture, and everything a technical architect should know.

## Learning Objectives

By the end of this POC, you will understand:

1. ✅ **Microservices Architecture** - Service design, communication patterns, data management
2. ✅ **Frontend Development** - Angular SPA with API integration
3. ✅ **Backend Development** - .NET Core Web APIs with best practices
4. ✅ **Containerization** - Docker images and multi-stage builds
5. ✅ **Orchestration** - Kubernetes deployment and management
6. ✅ **CI/CD Pipelines** - GitHub Actions for automated deployment
7. ✅ **Infrastructure as Code** - Terraform for AWS infrastructure
8. ✅ **Cloud Services** - AWS services integration (RDS, S3, CloudFront, EKS, etc.)
9. ✅ **Monitoring & Observability** - Logging, metrics, tracing
10. ✅ **Security** - Authentication, authorization, secrets management
11. ✅ **Database Design** - Database per service pattern
12. ✅ **Event-Driven Architecture** - Message queues and event handling
13. ✅ **API Gateway** - Request routing and aggregation
14. ✅ **DevOps Practices** - Deployment strategies, rollbacks, blue-green deployments

---

## POC Scope: Simplified Architecture

For the POC, we'll simplify to **4 core microservices**:

1. **Identity & Access Service** - Authentication, authorization, user management
2. **School Management Service** - School profiles, configuration
3. **Student Enrollment Service** - Student enrollments, activity management
4. **Payment Service** - Fee management, payment processing

**Frontend Applications:**
- **Student Portal** (Angular) - Student-facing SPA
- **Admin Portal** (Angular) - Admin-facing SPA

**Supporting Infrastructure:**
- API Gateway (Kong or AWS API Gateway)
- Message Queue (RabbitMQ or AWS SQS)
- Database (PostgreSQL or SQL Server)
- Cache (Redis)
- Monitoring (Prometheus + Grafana)

---

## Phase 1: Project Setup and Local Development Environment

### 1.1 Initialize Project Structure

**Prompt for Cursor AI:**

```
Create a project structure for a microservices-based Edlio-like Online School Platform with the following structure:

Root directory: OSP-POC
├── frontend/
│   ├── student-portal/ (Angular)
│   └── admin-portal/ (Angular)
├── backend/
│   ├── IdentityService/ (.NET Core Web API)
│   ├── SchoolManagementService/ (.NET Core Web API)
│   ├── EnrollmentService/ (.NET Core Web API)
│   └── PaymentService/ (.NET Core Web API)
├── infrastructure/
│   ├── terraform/ (Infrastructure as Code)
│   ├── kubernetes/ (K8s manifests)
│   └── docker/ (Dockerfiles)
├── ci-cd/
│   └── .github/workflows/ (GitHub Actions)
├── docs/ (Documentation)
└── docker-compose.yml (Local development)

Each service should have its own folder with proper .NET Core project structure.
Include .gitignore, README.md, and basic configuration files.
```

### 1.2 Set Up Local Development Environment

**Prompt for Cursor AI:**

```
Create a docker-compose.yml file for local development that includes:

1. PostgreSQL database for Identity Service
2. PostgreSQL database for School Management Service
3. PostgreSQL database for Enrollment Service
4. PostgreSQL database for Payment Service
5. RabbitMQ for message queue
6. Redis for caching
7. Kong API Gateway (optional for local)

Configure:
- Proper networking between services
- Environment variables
- Volume mounts for data persistence
- Health checks
- Port mappings

Also create a .env.example file with all required environment variables.
```

### 1.3 Create Base .NET Core API Template

**Prompt for Cursor AI:**

```
Create a base .NET Core 8 Web API project template with the following:

1. Project structure:
   - Controllers/
   - Services/
   - Models/
   - Data/ (DbContext)
   - DTOs/
   - Middleware/
   - Extensions/

2. Configuration:
   - appsettings.json with structured settings
   - appsettings.Development.json
   - Program.cs with proper service registration

3. Features:
   - Swagger/OpenAPI documentation
   - Health check endpoints (/health, /health/ready, /health/live)
   - CORS configuration
   - Logging (Serilog)
   - Exception handling middleware
   - Request/Response logging middleware
   - Correlation ID middleware

4. Dependencies:
   - Entity Framework Core
   - Swashbuckle (Swagger)
   - Serilog
   - HealthChecks

5. Include a sample controller with CRUD operations
6. Include a sample service and repository pattern
7. Include database context with migrations support

Save this as a template that can be copied for each microservice.
```

---

## Phase 2: Identity & Access Service Implementation

### 2.1 Set Up ASP.NET Core Identity

**Prompt for Cursor AI:**

```
Create the Identity & Access Service with ASP.NET Core Identity:

1. Extend IdentityUser with custom properties:
   - FirstName
   - LastName
   - TenantId (for multi-tenancy)

2. Configure Identity in Program.cs:
   - Add Identity with Entity Framework stores
   - Configure password requirements
   - Configure lockout settings
   - Add JWT Bearer authentication

3. Create DbContext:
   - IdentityDbContext<ApplicationUser>
   - Custom RefreshToken entity
   - Proper entity configurations

4. Create database migrations

5. Implement:
   - User registration endpoint
   - Login endpoint (returns JWT access token + refresh token)
   - Refresh token endpoint
   - Logout endpoint
   - Get current user endpoint

6. JWT Service:
   - Generate access tokens with claims (userId, email, roles, tenantId, permissions)
   - Validate tokens
   - Extract claims from expired tokens (for refresh)

7. Include proper error handling and validation
8. Add Swagger documentation with authentication
9. Include unit tests for authentication logic
```

### 2.2 Implement Role-Based Access Control

**Prompt for Cursor AI:**

```
Extend the Identity Service with RBAC:

1. Create roles:
   - Student
   - SchoolAdmin
   - SuperAdmin

2. Create permissions (as claims):
   - enrollment.read, enrollment.write
   - payment.read, payment.write
   - school.read, school.write
   - admin.read, admin.write

3. Implement:
   - Assign roles to users
   - Assign permissions to roles
   - Assign permissions directly to users
   - Get user roles and permissions endpoint

4. Create authorization policies:
   - RequireRole policy
   - RequirePermission policy
   - Custom authorization handlers

5. Add authorization attributes to controllers
6. Include authorization tests
```

### 2.3 Create Dockerfile for Identity Service

**Prompt for Cursor AI:**

```
Create a multi-stage Dockerfile for the Identity Service:

1. Build stage:
   - Use .NET 8 SDK
   - Copy csproj files and restore dependencies
   - Copy source code and build
   - Publish application

2. Runtime stage:
   - Use .NET 8 ASP.NET runtime
   - Copy published files
   - Expose port 80
   - Set environment variables
   - Configure health checks
   - Set entrypoint

3. Optimize for:
   - Small image size
   - Security (non-root user)
   - Build caching
   - Production readiness

4. Include .dockerignore file
```

---

## Phase 3: School Management Service Implementation

### 3.1 Create School Management Service

**Prompt for Cursor AI:**

```
Create the School Management Service with the following:

1. Models:
   - School (Id, Name, Address, ContactInfo, TenantId, IsActive, CreatedAt, UpdatedAt)
   - SchoolConfiguration (AcademicYear, Terms, Policies)

2. DbContext:
   - SchoolDbContext
   - Entity configurations
   - Seed data for testing

3. Controllers:
   - GET /api/schools - Get all schools (with pagination, filtering)
   - GET /api/schools/{id} - Get school by ID
   - POST /api/schools - Create school (authorized: SuperAdmin)
   - PUT /api/schools/{id} - Update school (authorized: SchoolAdmin or SuperAdmin)
   - DELETE /api/schools/{id} - Delete school (authorized: SuperAdmin)
   - GET /api/schools/{id}/configuration - Get school configuration

4. Services:
   - ISchoolService with business logic
   - SchoolService implementation
   - Include validation and error handling

5. DTOs:
   - CreateSchoolRequest
   - UpdateSchoolRequest
   - SchoolResponse
   - SchoolListResponse (with pagination)

6. Middleware:
   - Tenant isolation middleware (extract tenantId from JWT, filter queries)

7. Include unit tests and integration tests
8. Add Swagger documentation
```

### 3.2 Implement Multi-Tenancy

**Prompt for Cursor AI:**

```
Implement multi-tenancy in the School Management Service:

1. Create TenantFilterMiddleware:
   - Extract tenantId from JWT token claims
   - Add tenantId to HttpContext.Items
   - Validate tenant access

2. Create TenantQueryFilter:
   - Automatically filter queries by tenantId
   - Apply to all DbContext queries
   - Ensure data isolation

3. Update SchoolService:
   - All operations scoped to user's tenant
   - SuperAdmin can access all tenants
   - SchoolAdmin can only access their tenant

4. Add tenant validation:
   - Verify user has access to requested tenant
   - Return 403 Forbidden if unauthorized

5. Include tests for tenant isolation
```

---

## Phase 4: Student Enrollment Service Implementation

### 4.1 Create Enrollment Service

**Prompt for Cursor AI:**

```
Create the Student Enrollment Service with the following:

1. Models:
   - Enrollment (Id, StudentId, SchoolId, ActivityId, Status, EnrollmentDate, CreatedAt)
   - EnrollmentStatus enum (Pending, Approved, Rejected, Completed, Cancelled)

2. DbContext:
   - EnrollmentDbContext
   - Relationships with Identity Service (StudentId reference)

3. Controllers:
   - GET /api/enrollments - Get enrollments (filtered by student/school)
   - GET /api/enrollments/{id} - Get enrollment by ID
   - POST /api/enrollments - Create enrollment
   - PUT /api/enrollments/{id}/status - Update enrollment status
   - DELETE /api/enrollments/{id} - Cancel enrollment

4. Services:
   - IEnrollmentService
   - EnrollmentService with business logic:
     * Validate student exists (call Identity Service)
     * Validate school exists (call School Management Service)
     * Check enrollment eligibility
     * Handle enrollment state transitions

5. Integration:
   - HTTP client for calling Identity Service
   - HTTP client for calling School Management Service
   - Use Polly for resilience (retry, circuit breaker)

6. Event Publishing:
   - Publish EnrollmentCreated event to RabbitMQ
   - Publish EnrollmentStatusChanged event

7. Include comprehensive error handling and validation
8. Add unit and integration tests
```

### 4.2 Implement Event-Driven Communication

**Prompt for Cursor AI:**

```
Implement event-driven communication in Enrollment Service:

1. Create event models:
   - EnrollmentCreatedEvent (EnrollmentId, StudentId, SchoolId, ActivityId, CreatedAt)
   - EnrollmentStatusChangedEvent (EnrollmentId, OldStatus, NewStatus, ChangedAt)

2. Create IEventPublisher interface:
   - PublishAsync<T>(T event) method

3. Implement RabbitMQ Event Publisher:
   - Connect to RabbitMQ
   - Create exchanges and queues
   - Publish events with proper routing
   - Handle connection failures and retries

4. Create event consumers (for other services):
   - EnrollmentCreatedEventConsumer
   - Handle events asynchronously
   - Include error handling and dead letter queue

5. Configure RabbitMQ:
   - Connection string in appsettings
   - Exchange names
   - Queue names
   - Routing keys

6. Add event publishing to EnrollmentService methods
7. Include tests for event publishing
```

---

## Phase 5: Payment Service Implementation

### 5.1 Create Payment Service

**Prompt for Cursor AI:**

```
Create the Payment Service with the following:

1. Models:
   - Payment (Id, StudentId, EnrollmentId, Amount, Currency, Status, PaymentMethod, TransactionId, CreatedAt, UpdatedAt)
   - PaymentStatus enum (Pending, Processing, Completed, Failed, Refunded)
   - PaymentMethod enum (CreditCard, DebitCard, BankTransfer, Wallet)

2. DbContext:
   - PaymentDbContext
   - Payment history table for audit

3. Controllers:
   - GET /api/payments - Get payments (with filtering)
   - GET /api/payments/{id} - Get payment by ID
   - POST /api/payments - Initiate payment
   - POST /api/payments/{id}/process - Process payment (simulate payment gateway)
   - POST /api/payments/{id}/refund - Process refund
   - GET /api/payments/student/{studentId} - Get student payments

4. Services:
   - IPaymentService
   - PaymentService with business logic:
     * Validate payment amount
     * Simulate payment gateway integration
     * Handle payment status updates
     * Process refunds

5. Event Handling:
   - Subscribe to EnrollmentCreatedEvent
   - Automatically create payment record when enrollment is created
   - Publish PaymentCompletedEvent

6. Integration:
   - Call Enrollment Service to validate enrollment
   - Publish events to RabbitMQ

7. Include payment validation and fraud detection logic (basic)
8. Add comprehensive logging for audit trail
9. Include unit and integration tests
```

### 5.2 Implement Payment Processing Simulation

**Prompt for Cursor AI:**

```
Create a payment gateway simulation in Payment Service:

1. Create IPaymentGateway interface:
   - ProcessPaymentAsync(PaymentRequest) -> PaymentResponse
   - ProcessRefundAsync(RefundRequest) -> RefundResponse

2. Implement MockPaymentGateway:
   - Simulate payment processing (random success/failure)
   - Simulate processing delays
   - Return payment gateway response with transaction ID
   - Include retry logic for failed payments

3. Payment Processing Flow:
   - Validate payment request
   - Call payment gateway
   - Update payment status
   - Publish PaymentCompletedEvent or PaymentFailedEvent
   - Handle webhooks (simulated)

4. Include payment reconciliation logic
5. Add payment retry mechanism for failed payments
6. Include comprehensive error handling
```

---

## Phase 6: Frontend Development (Angular)

### 6.1 Create Student Portal (Angular)

**Prompt for Cursor AI:**

```
Create an Angular 18 application for Student Portal with:

1. Project structure:
   - src/app/
     - core/ (services, guards, interceptors)
     - features/ (enrollment, payment, profile)
     - shared/ (components, pipes, directives)
     - layout/ (header, footer, sidebar)

2. Features:
   - Authentication module (login, register, logout)
   - Enrollment module (view enrollments, create enrollment)
   - Payment module (view payments, make payment)
   - Profile module (view/edit profile)

3. Services:
   - AuthService (JWT token management)
   - ApiService (HTTP client wrapper)
   - EnrollmentService
   - PaymentService

4. Guards:
   - AuthGuard (protect routes)
   - RoleGuard (check user roles)

5. Interceptors:
   - AuthInterceptor (add JWT token to requests)
   - ErrorInterceptor (handle API errors)
   - LoadingInterceptor (show loading spinner)

6. Components:
   - Login component
   - Dashboard component
   - Enrollment list component
   - Enrollment form component
   - Payment list component
   - Payment form component

7. Routing:
   - Lazy loading for feature modules
   - Route guards
   - Route data for authorization

8. State Management:
   - Use Angular services or NgRx (optional)

9. Styling:
   - Use Angular Material or Bootstrap
   - Responsive design
   - Dark mode support (optional)

10. Environment configuration:
    - environment.ts (development)
    - environment.prod.ts (production)
    - API URLs configuration
```

### 6.2 Create Admin Portal (Angular)

**Prompt for Cursor AI:**

```
Create an Angular 18 application for Admin Portal with:

1. Similar structure to Student Portal but with admin-specific features:
   - School management (CRUD operations)
   - User management
   - Enrollment management (approve/reject)
   - Payment management
   - Dashboard with analytics

2. Additional features:
   - Multi-tenant support (switch between schools)
   - Role-based UI (show/hide features based on role)
   - Bulk operations
   - Export functionality (CSV, PDF)

3. Components:
   - School list and form
   - User management
   - Enrollment approval workflow
   - Payment dashboard
   - Analytics dashboard

4. Include data tables with:
   - Sorting
   - Filtering
   - Pagination
   - Export

5. Add real-time updates (WebSocket or polling)
6. Include comprehensive error handling and user feedback
```

### 6.3 Create Dockerfiles for Angular Apps

**Prompt for Cursor AI:**

```
Create multi-stage Dockerfiles for Angular applications:

1. Build stage:
   - Use Node.js 18
   - Copy package files and install dependencies
   - Copy source code
   - Build application with production configuration

2. Runtime stage:
   - Use nginx:alpine
   - Copy built files to nginx html directory
   - Configure nginx for SPA routing
   - Include nginx configuration file

3. Nginx configuration:
   - Serve static files
   - Handle Angular routing (try_files)
   - Configure CORS
   - Enable gzip compression
   - Set cache headers

4. Optimize for:
   - Small image size
   - Security
   - Performance

5. Include .dockerignore files
```

---

## Phase 7: API Gateway Implementation

### 7.1 Set Up Kong API Gateway

**Prompt for Cursor AI:**

```
Create Kong API Gateway configuration for the microservices:

1. Create kong.yml configuration file with:
   - Services definitions (identity, school, enrollment, payment)
   - Routes for each service
   - Plugins:
     * CORS plugin
     * Rate limiting plugin
     * Request/Response logging plugin
     * JWT authentication plugin

2. Configure:
   - Upstream services (service URLs)
   - Path-based routing
   - Health checks
   - Load balancing

3. Create Docker Compose service for Kong:
   - Kong container
   - PostgreSQL for Kong database
   - Konga (Kong admin UI) - optional

4. Create Kong plugins:
   - JWT validation plugin configuration
   - Extract tenantId from JWT and add to headers

5. Include documentation on:
   - How to add new services
   - How to configure plugins
   - How to manage routes
```

### 7.2 Alternative: AWS API Gateway Configuration

**Prompt for Cursor AI:**

```
Create Terraform configuration for AWS API Gateway:

1. Create API Gateway REST API
2. Create resources and methods for each microservice
3. Configure integration with EKS services
4. Set up CORS
5. Configure rate limiting
6. Set up API keys and usage plans
7. Configure custom domain
8. Set up SSL certificate
9. Include documentation on API Gateway setup
```

---

## Phase 8: Containerization and Docker

### 8.1 Create Docker Compose for Local Development

**Prompt for Cursor AI:**

```
Create a comprehensive docker-compose.yml for local development:

1. Services:
   - identity-service (ASP.NET Core)
   - school-service (ASP.NET Core)
   - enrollment-service (ASP.NET Core)
   - payment-service (ASP.NET Core)
   - student-portal (Angular + nginx)
   - admin-portal (Angular + nginx)
   - postgres-identity (PostgreSQL)
   - postgres-school (PostgreSQL)
   - postgres-enrollment (PostgreSQL)
   - postgres-payment (PostgreSQL)
   - rabbitmq (Message queue)
   - redis (Cache)
   - kong (API Gateway)
   - prometheus (Monitoring)
   - grafana (Monitoring UI)

2. Configure:
   - Networks (frontend, backend, database)
   - Volumes for data persistence
   - Environment variables
   - Health checks
   - Depends_on relationships
   - Port mappings

3. Include docker-compose.override.yml for development overrides
4. Create scripts for:
   - Starting services
   - Stopping services
   - Viewing logs
   - Running migrations
```

### 8.2 Optimize Docker Images

**Prompt for Cursor AI:**

```
Optimize all Dockerfiles for production:

1. For .NET Core services:
   - Use multi-stage builds
   - Use .NET 8 runtime (not SDK) for final stage
   - Minimize layers
   - Use .dockerignore
   - Run as non-root user
   - Set proper health checks

2. For Angular apps:
   - Use nginx:alpine
   - Minimize image size
   - Configure proper caching

3. Create a script to build all images
4. Create a script to push images to container registry
5. Include image scanning for vulnerabilities
6. Document best practices
```

---

## Phase 9: Kubernetes Deployment

### 9.1 Create Kubernetes Manifests

**Prompt for Cursor AI:**

```
Create Kubernetes manifests for all services:

1. Namespace: osp-poc

2. For each microservice, create:
   - Deployment (with resource limits, health checks, readiness/liveness probes)
   - Service (ClusterIP for internal communication)
   - ConfigMap (for non-sensitive configuration)
   - Secret (for sensitive data - use placeholders)
   - HorizontalPodAutoscaler (HPA) for auto-scaling

3. For frontend apps:
   - Deployment
   - Service (NodePort or LoadBalancer)
   - Ingress (for external access)

4. For infrastructure:
   - PostgreSQL StatefulSets (or use managed service)
   - RabbitMQ StatefulSet
   - Redis Deployment
   - Prometheus Deployment
   - Grafana Deployment

5. Include:
   - Resource requests and limits
   - Affinity/anti-affinity rules
   - Pod disruption budgets
   - Network policies (optional)

6. Create a kustomization.yaml for environment-specific overrides
7. Document deployment process
```

### 9.2 Create Kubernetes Ingress

**Prompt for Cursor AI:**

```
Create Kubernetes Ingress configuration:

1. Ingress resource for:
   - student.osp.local -> student-portal service
   - admin.osp.local -> admin-portal service
   - api.osp.local -> API Gateway service

2. Configure:
   - SSL/TLS (self-signed certs for local)
   - Path-based routing
   - CORS headers
   - Rate limiting annotations

3. Include instructions for:
   - Setting up ingress controller (nginx or traefik)
   - Configuring DNS (hosts file for local)
   - SSL certificate management
```

### 9.3 Create Helm Charts (Optional)

**Prompt for Cursor AI:**

```
Create Helm charts for the application:

1. Create a parent chart (osp-poc) with:
   - Chart.yaml
   - values.yaml (with all configurable values)
   - templates/ directory

2. Create subcharts for:
   - Each microservice
   - Frontend applications
   - Infrastructure components

3. Include:
   - Default values
   - Environment-specific value files (dev, staging, prod)
   - Template helpers
   - Documentation

4. Create deployment scripts using Helm
5. Document Helm usage
```

---

## Phase 10: CI/CD with GitHub Actions

### 10.1 Create GitHub Actions Workflows

**Prompt for Cursor AI:**

```
Create GitHub Actions workflows for CI/CD:

1. CI Workflow (on pull request):
   - Checkout code
   - Set up .NET SDK
   - Set up Node.js
   - Run unit tests for backend services
   - Run linting for frontend
   - Build all services
   - Build Docker images
   - Run integration tests
   - Generate test coverage reports
   - Comment PR with test results

2. CD Workflow (on merge to main):
   - Build and test (same as CI)
   - Build Docker images
   - Tag images with version (git tag or commit SHA)
   - Push images to container registry (Docker Hub or ECR)
   - Update Kubernetes manifests with new image tags
   - Deploy to development environment
   - Run smoke tests
   - Deploy to staging (if tests pass)
   - Deploy to production (manual approval required)

3. Create separate workflows for:
   - Backend services
   - Frontend applications
   - Infrastructure (Terraform)

4. Include:
   - Secrets management
   - Environment-specific deployments
   - Rollback capability
   - Deployment notifications (Slack/Email)

5. Create workflow templates for reusability
```

### 10.2 Create Deployment Scripts

**Prompt for Cursor AI:**

```
Create deployment scripts:

1. deploy.sh script:
   - Build Docker images
   - Push to registry
   - Update Kubernetes manifests
   - Apply Kubernetes resources
   - Wait for deployment
   - Run health checks
   - Rollback on failure

2. rollback.sh script:
   - Get previous deployment version
   - Update Kubernetes manifests
   - Apply rollback
   - Verify deployment

3. Create scripts for:
   - Database migrations
   - Cache warming
   - Health check verification
   - Performance testing

4. Include error handling and logging
5. Make scripts idempotent
```

---

## Phase 11: Infrastructure as Code with Terraform

### 11.1 Create Terraform Configuration for AWS

**Prompt for Cursor AI:**

```
Create Terraform configuration for AWS infrastructure:

1. Project structure:
   terraform/
   ├── main.tf (provider configuration)
   ├── variables.tf (input variables)
   ├── outputs.tf (output values)
   ├── modules/
   │   ├── vpc/ (VPC, subnets, internet gateway, NAT gateway)
   │   ├── eks/ (EKS cluster)
   │   ├── rds/ (RDS instances)
   │   ├── s3/ (S3 buckets)
   │   ├── cloudfront/ (CloudFront distributions)
   │   └── iam/ (IAM roles and policies)
   ├── environments/
   │   ├── dev/
   │   ├── staging/
   │   └── prod/

2. VPC Module:
   - VPC with CIDR block
   - Public and private subnets (multi-AZ)
   - Internet Gateway
   - NAT Gateway
   - Route tables
   - Security groups

3. EKS Module:
   - EKS cluster
   - Node groups (managed or self-managed)
   - IAM roles for nodes
   - Cluster autoscaler
   - ALB ingress controller

4. RDS Module:
   - RDS PostgreSQL instances (one per service)
   - Subnet groups
   - Security groups
   - Parameter groups
   - Backup configuration

5. S3 Module:
   - Buckets for frontend apps
   - Bucket policies
   - Versioning
   - Lifecycle policies

6. CloudFront Module:
   - Distributions for Angular apps
   - Origins (S3)
   - Cache behaviors
   - SSL certificates

7. Include:
   - Remote state backend (S3)
   - State locking (DynamoDB)
   - Environment-specific configurations
   - Output values for other resources
```

### 11.2 Create Terraform Modules

**Prompt for Cursor AI:**

```
Create reusable Terraform modules:

1. VPC Module:
   - Inputs: cidr_block, availability_zones, environment
   - Outputs: vpc_id, public_subnet_ids, private_subnet_ids, nat_gateway_ips

2. EKS Module:
   - Inputs: cluster_name, node_instance_types, desired_capacity, vpc_id, subnets
   - Outputs: cluster_id, cluster_endpoint, cluster_security_group_id

3. RDS Module:
   - Inputs: db_name, engine_version, instance_class, vpc_id, subnets, security_groups
   - Outputs: db_endpoint, db_port, db_name

4. S3 Module:
   - Inputs: bucket_name, enable_versioning, lifecycle_rules
   - Outputs: bucket_id, bucket_arn

5. CloudFront Module:
   - Inputs: origin_domain, aliases, certificate_arn
   - Outputs: distribution_id, distribution_domain_name

6. Include:
   - Proper variable validation
   - Default values
   - Documentation
   - Examples
```

### 11.3 Create Terraform Workflows

**Prompt for Cursor AI:**

```
Create Terraform workflows:

1. GitHub Actions workflow for Terraform:
   - Terraform plan on pull request
   - Terraform apply on merge to main (with approval)
   - Terraform destroy for cleanup (optional)

2. Create scripts:
   - terraform-init.sh (initialize backend)
   - terraform-plan.sh (plan changes)
   - terraform-apply.sh (apply changes)
   - terraform-destroy.sh (destroy resources)

3. Include:
   - State file management
   - Workspace management
   - Environment-specific deployments
   - Cost estimation
   - Security scanning

4. Document:
   - How to set up Terraform
   - How to use modules
   - How to manage state
   - Best practices
```

---

## Phase 12: Monitoring and Observability

### 12.1 Set Up Prometheus and Grafana

**Prompt for Cursor AI:**

```
Set up monitoring with Prometheus and Grafana:

1. Prometheus Configuration:
   - prometheus.yml with scrape configs for all services
   - Service discovery for Kubernetes
   - Alert rules (high CPU, high memory, high error rate)
   - Recording rules for common queries

2. Grafana Configuration:
   - Data source (Prometheus)
   - Dashboards for:
     * Service health (uptime, response time, error rate)
     * Resource usage (CPU, memory, network)
     * Business metrics (enrollments, payments)
     * Database metrics
     * Message queue metrics

3. Create Kubernetes manifests:
   - Prometheus Deployment and Service
   - Grafana Deployment and Service
   - ServiceMonitor CRDs for service discovery
   - PrometheusRule CRDs for alerting

4. Instrument .NET Core services:
   - Add Prometheus metrics exporter
   - Expose /metrics endpoint
   - Add custom business metrics

5. Create alerting rules:
   - High error rate
   - High latency
   - Service down
   - Database connection issues

6. Include documentation on:
   - How to add new metrics
   - How to create dashboards
   - How to set up alerts
```

### 12.2 Set Up Logging

**Prompt for Cursor AI:**

```
Set up centralized logging:

1. Configure Serilog in .NET Core services:
   - Console sink (for development)
   - File sink (for local)
   - Elasticsearch sink (for production)
   - Structured logging with correlation IDs

2. Create logging middleware:
   - Request/response logging
   - Error logging
   - Performance logging

3. Set up ELK Stack or CloudWatch Logs:
   - Elasticsearch for log storage
   - Logstash for log processing
   - Kibana for log visualization
   - Or use AWS CloudWatch Logs

4. Create log aggregation:
   - Collect logs from all services
   - Parse structured logs
   - Create log indexes
   - Set up log retention

5. Include:
   - Log levels configuration
   - Log filtering
   - Log sampling for high-volume services
   - Log correlation across services

6. Document logging best practices
```

### 12.3 Set Up Distributed Tracing

**Prompt for Cursor AI:**

```
Set up distributed tracing:

1. Configure OpenTelemetry in .NET Core services:
   - Add OpenTelemetry packages
   - Configure trace exporter (Jaeger or AWS X-Ray)
   - Add instrumentation for HTTP, Entity Framework, RabbitMQ

2. Create tracing middleware:
   - Start trace for each request
   - Propagate trace context
   - Add custom spans for business operations

3. Set up Jaeger or AWS X-Ray:
   - Jaeger all-in-one for local
   - AWS X-Ray for production
   - Configure sampling rates

4. Create trace visualization:
   - Service dependency graph
   - Request flow visualization
   - Performance analysis

5. Include:
   - Trace correlation IDs
   - Custom span attributes
   - Error tracking in traces

6. Document how to use tracing for debugging
```

---

## Phase 13: Security Implementation

### 13.1 Implement Security Best Practices

**Prompt for Cursor AI:**

```
Implement security best practices:

1. Secrets Management:
   - Use AWS Secrets Manager or HashiCorp Vault
   - Create Kubernetes secrets from external sources
   - Rotate secrets regularly
   - Never commit secrets to git

2. Network Security:
   - Kubernetes network policies
   - Security groups in AWS
   - Private subnets for databases
   - VPC endpoints for AWS services

3. Application Security:
   - Input validation
   - SQL injection prevention (parameterized queries)
   - XSS prevention
   - CSRF protection
   - Rate limiting
   - Request size limits

4. Container Security:
   - Scan Docker images for vulnerabilities
   - Use minimal base images
   - Run as non-root user
   - Read-only file systems where possible

5. API Security:
   - JWT token validation
   - Token expiration
   - Refresh token rotation
   - API rate limiting
   - CORS configuration

6. Database Security:
   - Encrypted connections (SSL/TLS)
   - Encrypted at rest
   - Database user with least privileges
   - Regular backups

7. Create security documentation
```

### 13.2 Set Up Security Scanning

**Prompt for Cursor AI:**

```
Set up security scanning:

1. Add security scanning to CI/CD:
   - Docker image scanning (Trivy, Snyk)
   - Dependency scanning (OWASP, Snyk)
   - SAST (Static Application Security Testing)
   - Infrastructure scanning (Checkov for Terraform)

2. Create GitHub Actions workflow:
   - Run security scans on every PR
   - Fail build on critical vulnerabilities
   - Generate security reports

3. Configure:
   - Trivy for container scanning
   - OWASP Dependency Check
   - SonarQube (optional)
   - Checkov for Terraform

4. Include:
   - Security policy
   - Vulnerability reporting process
   - Remediation guidelines

5. Document security practices
```

---

## Phase 14: Testing Strategy

### 14.1 Create Test Suite

**Prompt for Cursor AI:**

```
Create comprehensive test suite:

1. Unit Tests:
   - Service layer tests (mock dependencies)
   - Repository tests (in-memory database)
   - Controller tests
   - Utility function tests
   - Use xUnit, Moq, FluentAssertions

2. Integration Tests:
   - API endpoint tests (TestServer)
   - Database integration tests
   - Message queue integration tests
   - Cross-service integration tests

3. End-to-End Tests:
   - Playwright or Cypress for frontend
   - API E2E tests
   - Full user journey tests

4. Performance Tests:
   - Load testing (k6 or JMeter)
   - Stress testing
   - Endurance testing

5. Test Infrastructure:
   - Test containers for databases
   - Mock services
   - Test data factories
   - Test fixtures

6. Create test documentation:
   - How to run tests
   - Test coverage goals
   - Test data management
```

### 14.2 Set Up Test Automation

**Prompt for Cursor AI:**

```
Set up test automation:

1. GitHub Actions workflow for tests:
   - Run unit tests on every commit
   - Run integration tests on PR
   - Run E2E tests on merge to main
   - Generate test coverage reports
   - Upload coverage to Codecov

2. Create test scripts:
   - run-tests.sh (all tests)
   - run-unit-tests.sh
   - run-integration-tests.sh
   - run-e2e-tests.sh

3. Configure:
   - Test coverage thresholds
   - Test reporting
   - Test parallelization
   - Test retries for flaky tests

4. Include:
   - Test data setup/teardown
   - Test isolation
   - Test performance optimization

5. Document testing strategy
```

---

## Phase 15: Documentation

### 15.1 Create Technical Documentation

**Prompt for Cursor AI:**

```
Create comprehensive technical documentation:

1. Architecture Documentation:
   - System architecture diagram
   - Service architecture
   - Data flow diagrams
   - Sequence diagrams for key flows
   - Deployment architecture

2. API Documentation:
   - OpenAPI/Swagger specifications
   - API endpoint documentation
   - Request/response examples
   - Authentication guide
   - Error codes and handling

3. Development Guide:
   - Setup instructions
   - Development workflow
   - Coding standards
   - Git workflow
   - Code review process

4. Deployment Guide:
   - Deployment process
   - Environment configuration
   - Rollback procedures
   - Troubleshooting guide

5. Operations Guide:
   - Monitoring and alerting
   - Logging
   - Performance tuning
   - Disaster recovery
   - Backup and restore

6. Create README files for:
   - Root project
   - Each microservice
   - Frontend applications
   - Infrastructure
   - CI/CD

7. Include diagrams using Mermaid or PlantUML
```

### 15.2 Create Runbooks

**Prompt for Cursor AI:**

```
Create operational runbooks:

1. Deployment Runbook:
   - Pre-deployment checklist
   - Deployment steps
   - Post-deployment verification
   - Rollback procedures

2. Incident Response Runbook:
   - Common issues and solutions
   - Escalation procedures
   - Communication templates
   - Post-incident review process

3. Maintenance Runbook:
   - Database migration procedures
   - Cache clearing procedures
   - Service restart procedures
   - Backup procedures

4. Troubleshooting Guide:
   - Common errors and solutions
   - Log analysis guide
   - Performance troubleshooting
   - Network troubleshooting

5. Include:
   - Step-by-step instructions
   - Screenshots where helpful
   - Command examples
   - Verification steps
```

---

## Phase 16: Advanced Topics

### 16.1 Implement Advanced Patterns

**Prompt for Cursor AI:**

```
Implement advanced microservices patterns:

1. Circuit Breaker Pattern:
   - Use Polly in .NET Core
   - Configure circuit breaker for external service calls
   - Implement fallback mechanisms
   - Add monitoring and alerts

2. Saga Pattern:
   - Implement distributed transaction handling
   - Create saga orchestrator
   - Handle compensation logic
   - Add saga state management

3. CQRS Pattern:
   - Separate read and write models
   - Create command handlers
   - Create query handlers
   - Implement event sourcing (optional)

4. API Gateway Pattern:
   - Request aggregation
   - Response caching
   - Request/response transformation
   - API versioning

5. Service Mesh (Optional):
   - Set up Istio or Linkerd
   - Configure service-to-service communication
   - Implement mTLS
   - Add observability

6. Include documentation and examples
```

### 16.2 Performance Optimization

**Prompt for Cursor AI:**

```
Implement performance optimizations:

1. Caching Strategy:
   - Redis caching for frequently accessed data
   - Response caching in API Gateway
   - Browser caching for frontend
   - CDN caching for static assets

2. Database Optimization:
   - Index optimization
   - Query optimization
   - Connection pooling
   - Read replicas for reporting

3. API Optimization:
   - Pagination
   - Field filtering
   - Response compression
   - HTTP/2 support

4. Frontend Optimization:
   - Lazy loading
   - Code splitting
   - Image optimization
   - Bundle size optimization

5. Monitoring:
   - Performance metrics
   - Slow query logging
   - APM (Application Performance Monitoring)

6. Document optimization strategies
```

---

## Phase 17: Production Readiness

### 17.1 Production Checklist

**Prompt for Cursor AI:**

```
Create production readiness checklist:

1. Security:
   - [ ] All secrets in secrets manager
   - [ ] SSL/TLS enabled everywhere
   - [ ] Security groups configured
   - [ ] Network policies in place
   - [ ] Regular security scans
   - [ ] Penetration testing completed

2. Monitoring:
   - [ ] All services instrumented
   - [ ] Dashboards created
   - [ ] Alerts configured
   - [ ] Log aggregation working
   - [ ] Distributed tracing enabled

3. Reliability:
   - [ ] Health checks configured
   - [ ] Auto-scaling configured
   - [ ] Load balancing configured
   - [ ] Multi-AZ deployment
   - [ ] Backup and restore tested
   - [ ] Disaster recovery plan

4. Performance:
   - [ ] Load testing completed
   - [ ] Performance benchmarks met
   - [ ] Caching strategy implemented
   - [ ] Database optimized

5. Documentation:
   - [ ] Architecture documented
   - [ ] API documented
   - [ ] Runbooks created
   - [ ] Troubleshooting guides ready

6. Create production deployment guide
```

### 17.2 Create Production Deployment Plan

**Prompt for Cursor AI:**

```
Create production deployment plan:

1. Pre-deployment:
   - Backup current production
   - Notify stakeholders
   - Prepare rollback plan
   - Review change log

2. Deployment:
   - Deploy to staging first
   - Run smoke tests
   - Deploy to production (blue-green or canary)
   - Monitor metrics
   - Verify functionality

3. Post-deployment:
   - Monitor for 24 hours
   - Check error rates
   - Verify performance
   - Collect feedback

4. Rollback Plan:
   - Automated rollback triggers
   - Manual rollback procedures
   - Data rollback procedures

5. Include:
   - Deployment schedule
   - Communication plan
   - Risk assessment
   - Success criteria
```

---

## Phase 18: Final Integration and Testing

### 18.1 End-to-End Testing

**Prompt for Cursor AI:**

```
Create end-to-end test scenarios:

1. User Registration Flow:
   - Register new student
   - Verify email (simulated)
   - Login
   - Access student portal

2. Enrollment Flow:
   - Student enrolls in activity
   - Verify enrollment created
   - Verify payment record created
   - Verify notification sent
   - Verify reporting updated

3. Payment Flow:
   - Initiate payment
   - Process payment
   - Verify payment status
   - Verify notification sent
   - Verify reporting updated

4. Admin Flow:
   - Admin logs in
   - View school dashboard
   - Approve enrollment
   - View reports

5. Create automated E2E tests
6. Document test scenarios
```

### 18.2 Load Testing

**Prompt for Cursor AI:**

```
Create load testing scenarios:

1. Use k6 or JMeter:
   - Create test scripts for:
     * User registration
     * User login
     * Enrollment creation
     * Payment processing
     * Dashboard loading

2. Test Scenarios:
   - Normal load (expected traffic)
   - Peak load (2x expected traffic)
   - Stress test (5x expected traffic)
   - Spike test (sudden traffic increase)

3. Metrics to Monitor:
   - Response time (p50, p95, p99)
   - Error rate
   - Throughput
   - Resource utilization

4. Create load testing scripts
5. Document results and recommendations
```

---

## Quick Reference: Cursor AI Prompts by Category

### Architecture & Design
- "Create microservices architecture diagram for Edlio-like school platform"
- "Design database schema for multi-tenant school management system"
- "Create API design for student enrollment service"

### Backend Development
- "Create .NET Core Web API with ASP.NET Core Identity and JWT authentication"
- "Implement event-driven communication using RabbitMQ in .NET Core"
- "Create repository pattern with Entity Framework Core"

### Frontend Development
- "Create Angular application with authentication and routing"
- "Implement JWT token management in Angular service"
- "Create responsive dashboard with Angular Material"

### DevOps
- "Create Dockerfile for .NET Core application with multi-stage build"
- "Create Kubernetes deployment manifests for microservices"
- "Create GitHub Actions workflow for CI/CD pipeline"

### Infrastructure
- "Create Terraform configuration for AWS EKS cluster"
- "Set up VPC with public and private subnets using Terraform"
- "Create RDS PostgreSQL instance with Terraform"

### Monitoring
- "Set up Prometheus and Grafana for microservices monitoring"
- "Configure Serilog for structured logging in .NET Core"
- "Implement distributed tracing with OpenTelemetry"

---

## Learning Path Summary

### Week 1-2: Foundation
- Set up development environment
- Create project structure
- Implement Identity Service
- Set up Docker for local development

### Week 3-4: Core Services
- Implement School Management Service
- Implement Enrollment Service
- Implement Payment Service
- Set up message queue

### Week 5-6: Frontend
- Create Student Portal (Angular)
- Create Admin Portal (Angular)
- Integrate with APIs
- Set up authentication

### Week 7-8: Containerization & Orchestration
- Create production Dockerfiles
- Set up Kubernetes cluster
- Deploy services to Kubernetes
- Configure ingress and services

### Week 9-10: CI/CD & Infrastructure
- Set up GitHub Actions
- Create Terraform configurations
- Deploy to AWS
- Set up monitoring

### Week 11-12: Advanced Topics & Production
- Implement advanced patterns
- Performance optimization
- Security hardening
- Production deployment
- Documentation

---

## Resources and References

### Documentation
- [.NET Core Documentation](https://docs.microsoft.com/dotnet/core/)
- [Angular Documentation](https://angular.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Documentation](https://docs.docker.com/)

### Tools
- **IDE**: Visual Studio / VS Code / Cursor
- **Container Registry**: Docker Hub / AWS ECR
- **CI/CD**: GitHub Actions
- **Infrastructure**: Terraform
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack / CloudWatch
- **Tracing**: Jaeger / AWS X-Ray

### Best Practices
- Follow 12-Factor App methodology
- Implement microservices best practices
- Use infrastructure as code
- Automate everything
- Monitor everything
- Document everything

---

## Success Criteria

By the end of this POC, you should be able to:

✅ **Understand** the complete software development lifecycle
✅ **Design** microservices architecture
✅ **Implement** scalable and maintainable services
✅ **Deploy** applications using modern DevOps practices
✅ **Monitor** and troubleshoot production systems
✅ **Optimize** performance and costs
✅ **Secure** applications and infrastructure
✅ **Document** technical decisions and processes
✅ **Lead** technical architecture discussions
✅ **Mentor** junior developers

---

## Next Steps

1. **Start with Phase 1** - Set up your development environment
2. **Follow phases sequentially** - Each phase builds on the previous
3. **Customize as needed** - Adjust based on your learning goals
4. **Document your journey** - Keep notes on challenges and solutions
5. **Share your learnings** - Contribute back to the community

**Remember**: The goal is not just to build a working system, but to deeply understand every component, decision, and trade-off. Take your time, experiment, and don't hesitate to dive deeper into areas that interest you.

Good luck with your POC journey! 🚀

