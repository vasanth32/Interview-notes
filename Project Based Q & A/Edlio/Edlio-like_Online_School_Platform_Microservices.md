# Edlio-like Online School Platform - Microservices Architecture

## Overview

This document explains the microservices architecture for an Edlio-like online school platform. The system is designed as a multi-tenant SaaS platform that enables schools to manage their operations, students, fees, activities, and enrollments through separate portals for students, school administrators, and Edlio super administrators.

## Architecture Principles

- **Domain-Driven Design (DDD)**: Each microservice represents a distinct business domain
- **Database per Service**: Each service maintains its own database
- **API Gateway Pattern**: Unified entry point for all client requests
- **Event-Driven Communication**: Services communicate via message bus and REST events
- **Independent Deployment**: Services can be deployed and scaled independently
- **Security-First**: Identity and access management is isolated as a critical service

---

## System Architecture

### User Portals

The platform serves three distinct user types:

1. **Student Portal** - Students can view school information, enroll in activities, and make payments
2. **School Admin Portal** - School administrators manage their school profile, students, fees, and activities
3. **Edlio Admin Portal** - Super administrators manage all schools (tenants), subscriptions, and platform-wide operations

### API Gateway

All portals connect through a **unified API Gateway** that:
- Routes requests to appropriate microservices
- Handles authentication and authorization
- Provides rate limiting and request throttling
- Aggregates responses from multiple services
- Manages API versioning

---

## Microservices Breakdown

### 1️⃣ Identity & Access Service

**Purpose:**
- User authentication (login/logout)
- Authorization and role-based access control (RBAC)
- User management across all portals

**Users:**
- School admins
- Students
- Edlio super admins

**Why Separate?**
- **Security Critical**: Centralized security management reduces attack surface
- **Used by All Portals**: Single source of truth for authentication across the entire platform
- **Compliance**: Easier to implement security standards (OAuth 2.0, JWT, MFA)
- **Independent Scaling**: Authentication traffic can be scaled independently

**Key Responsibilities:**
- User registration and login (using ASP.NET Core Identity)
- Token generation and validation (JWT)
- Role and permission management (using Identity's RoleManager and Claims)
- Session management
- Password reset and account recovery (using Identity's token providers)
- Multi-factor authentication (MFA) - Identity supports 2FA
- Account lockout (built-in Identity feature)
- Password complexity requirements (configurable in Identity)

**Technology Considerations:**
- ASP.NET Core Identity (for user and role management)
- JWT tokens (for API authentication)
- OAuth 2.0 / OpenID Connect
- Identity providers (Azure AD, Auth0, or custom)
- Rate limiting for login attempts

**Database Tables (ASP.NET Core Identity):**
- `AspNetUsers` - User accounts (extended with TenantId, FirstName, LastName)
- `AspNetRoles` - Roles (Student, SchoolAdmin, SuperAdmin)
- `AspNetUserRoles` - User-Role mapping
- `AspNetUserClaims` - User claims/permissions
- `AspNetRoleClaims` - Role claims/permissions
- `AspNetUserLogins` - External login providers
- `AspNetUserTokens` - External authentication tokens
- `RefreshTokens` - Custom table for refresh token management

---

### 2️⃣ School Management Service

**Purpose:**
- School profile management
- School registration and onboarding
- School configuration and settings
- School information display

**Used By:**
- School admin portal (full CRUD operations)
- Student portal (read-only access)
- Edlio admin portal (tenant management)

**Why Separate?**
- **Core Domain**: School is a primary entity in the system
- **Multi-Tenancy**: Each school is a separate tenant with isolated data
- **Configuration Management**: School-specific settings and preferences
- **Scalability**: Can be scaled independently based on school count

**Key Responsibilities:**
- School profile creation and updates
- School registration workflow
- School configuration (academic year, terms, policies)
- School branding and customization
- School contact information
- School status management (active/inactive)

**Data Model:**
- School ID (tenant identifier)
- School name, address, contact details
- School configuration (academic calendar, fee structure templates)
- School branding (logo, colors, themes)

---

### 3️⃣ Fee Management Service

**Purpose:**
- Tuition fee management
- Additional activity fees
- Transport fees
- Laboratory fees
- Miscellaneous fees
- Fee structure configuration

**Why Separate?**
- **Core Financial Domain**: Critical business logic for revenue
- **Changes Frequently**: Fee structures change per academic year, promotions, discounts
- **High Business Impact**: Directly affects revenue and financial reporting
- **Complex Business Rules**: Different fee types, payment plans, discounts, scholarships
- **Compliance**: Financial data requires strict audit trails

**Key Responsibilities:**
- Fee structure definition (per grade, per activity, per service)
- Fee calculation and pricing rules
- Fee categories (tuition, activity, transport, lab, misc)
- Fee schedules (one-time, recurring, installment plans)
- Discount and scholarship management
- Fee history and audit trails

**Integration Points:**
- **Payment Service**: Triggers payment processing
- **Notification Service**: Sends fee due reminders
- **Reporting Service**: Provides fee analytics

---

### 4️⃣ Activity / Program Service

**Purpose:**
- Extra-curricular activity management
- Sports programs
- Clubs and societies
- Workshops and events
- Activity fee mapping
- Activity enrollment capacity

**Why Separate?**
- **Distinct Domain**: Activities have their own lifecycle and rules
- **Independent Scaling**: Activity-related traffic can spike during enrollment periods
- **Complex Relationships**: Activities link to fees, students, and schedules
- **Business Logic**: Capacity management, waitlists, prerequisites

**Key Responsibilities:**
- Activity creation and management
- Activity categories (sports, arts, academics, clubs)
- Activity schedules and timings
- Capacity management (max participants, waitlists)
- Activity fee mapping (links to Fee Management Service)
- Activity prerequisites and eligibility rules
- Activity status (active, inactive, full, cancelled)

**Integration Points:**
- **Fee Management Service**: Maps activities to fees
- **Student Enrollment Service**: Handles activity enrollments
- **Notification Service**: Sends activity-related notifications

---

### 5️⃣ Student Enrollment Service

**Purpose:**
- Student school selection
- Student enrollment in activities
- Enrollment status tracking
- Enrollment history

**Why Separate?**
- **Core Business Process**: Enrollment is a critical workflow
- **Complex State Management**: Multiple enrollment states (pending, approved, rejected, completed)
- **High Transaction Volume**: Peak enrollment periods require independent scaling
- **Business Rules**: Enrollment eligibility, prerequisites, capacity checks

**Key Responsibilities:**
- Student enrollment in schools
- Activity enrollment management
- Enrollment application workflow
- Enrollment status tracking (pending, approved, waitlisted, rejected)
- Enrollment history and audit logs
- Enrollment cancellation and withdrawal
- Bulk enrollment operations

**Integration Points:**
- **Identity & Access Service**: Validates student identity
- **School Management Service**: Validates school availability
- **Activity Service**: Checks activity capacity and prerequisites
- **Fee Management Service**: Calculates fees based on enrollments
- **Notification Service**: Sends enrollment confirmations

**Data Model:**
- Enrollment ID
- Student ID
- School ID / Activity ID
- Enrollment status
- Enrollment date
- Enrollment period (academic year, term)

---

### 6️⃣ Payment Service

**Purpose:**
- Fee payment processing
- Payment status tracking
- Payment history
- Refund processing (optional)
- Payment gateway integration

**Why Separate?**
- **Integrates with External Gateways**: Stripe, PayPal, Square, bank gateways
- **High Reliability Required**: Financial transactions must be highly available
- **Compliance Reasons**: PCI-DSS compliance, financial regulations
- **Independent Scaling**: Payment processing can have different load patterns
- **Security Isolation**: Payment data requires additional security measures
- **Failure Isolation**: Payment service failures shouldn't affect other services

**Key Responsibilities:**
- Payment processing (credit card, debit card, bank transfer, e-wallet)
- Payment gateway integration
- Payment status management (pending, processing, completed, failed, refunded)
- Payment retry logic for failed transactions
- Refund processing and management
- Payment receipts and invoices
- Payment reconciliation
- Fraud detection and prevention

**Integration Points:**
- **Fee Management Service**: Receives fee payment requests
- **Notification Service**: Sends payment confirmations
- **Reporting Service**: Provides payment analytics
- **External Payment Gateways**: Stripe, PayPal, etc.

**Security Considerations:**
- PCI-DSS compliance
- Tokenization of payment data
- Encryption at rest and in transit
- Audit logging for all transactions

---

### 7️⃣ Notification Service

**Purpose:**
- Email notifications
- SMS notifications
- Push notifications (mobile apps)
- Notification templates
- Notification delivery tracking

**Why Separate?**
- **Cross-Cutting Concern**: Used by multiple services
- **Different Delivery Channels**: Email, SMS, push require different infrastructure
- **Scalability**: Notification volume can spike independently
- **Reliability**: Notification failures shouldn't block core business processes
- **Template Management**: Centralized notification templates and branding

**Key Responsibilities:**
- Email sending (transactional and marketing)
- SMS sending
- Push notifications
- Notification template management
- Notification scheduling (delayed notifications)
- Delivery status tracking
- Notification preferences management
- Notification history and logs

**Notification Examples:**
- Fee due reminders
- Payment confirmation
- Enrollment confirmation
- Activity registration confirmation
- Payment failure notifications
- Enrollment status updates
- School announcements

**Integration Points:**
- **All Services**: Receives notification requests from any service
- **External Services**: Email providers (SendGrid, AWS SES), SMS providers (Twilio, AWS SNS)

**Technology Considerations:**
- Message queue for async processing
- Retry logic for failed notifications
- Rate limiting for external providers
- Template engine (Razor, Handlebars)

---

### 8️⃣ Reporting & Analytics Service

**Purpose:**
- Fee reports
- School-wise metrics
- Student enrollment analytics
- Payment analytics
- Admin dashboards
- Custom report generation

**Used By:**
- Edlio admin portal (platform-wide analytics)
- School admin portal (school-specific reports)
- Student portal (personal reports)

**Why Separate?**
- **Read-Heavy Workload**: Analytics queries can be resource-intensive
- **Data Aggregation**: Combines data from multiple services
- **Independent Scaling**: Reporting can be scaled separately from transactional services
- **Caching Requirements**: Reports can be cached for performance
- **Data Warehouse Integration**: May integrate with data warehouses for complex analytics

**Key Responsibilities:**
- Fee collection reports
- Enrollment statistics
- Payment analytics
- School performance metrics
- Student activity reports
- Financial reports
- Custom report generation
- Dashboard data aggregation
- Export functionality (PDF, Excel, CSV)

**Integration Points:**
- **All Services**: Reads data from all services (via events or direct queries)
- **Data Warehouse**: May sync data to data warehouse for complex analytics

**Technology Considerations:**
- Read replicas for reporting queries
- Caching layer (Redis)
- Data aggregation pipelines
- Scheduled report generation

---

### 9️⃣ Admin / Tenant Management Service (Edlio Admin)

**Purpose:**
- Multi-tenant management
- School (tenant) enable/disable
- Subscription plan management
- Platform configuration
- System-wide settings

**Why Separate?**
- **Tenant Isolation**: Critical for multi-tenant SaaS architecture
- **Billing Integration**: Manages subscriptions and billing
- **Platform Operations**: System-wide configuration and management
- **Security**: Controls access to platform administration features
- **Compliance**: Manages tenant data isolation and compliance

**Key Responsibilities:**
- Tenant (school) lifecycle management
- Tenant provisioning and deprovisioning
- Subscription plan management (tiers, features, limits)
- Tenant enable/disable operations
- Platform-wide configuration
- Feature flags management
- System health monitoring
- Tenant usage tracking
- Billing and subscription management

**Integration Points:**
- **Identity & Access Service**: Manages admin user access
- **School Management Service**: Provisions new schools
- **All Services**: Can perform administrative operations across services

**Data Model:**
- Tenant ID
- Subscription plan
- Feature flags
- Usage limits
- Billing information
- Tenant status (active, suspended, cancelled)

---

## Service Communication Patterns

### Synchronous Communication (REST/HTTP)
- **When**: Real-time operations requiring immediate response
- **Examples**: 
  - User login (Identity Service → API Gateway)
  - Payment processing (Payment Service → Fee Management Service)
  - Enrollment status check (Student Enrollment Service → Activity Service)

### Asynchronous Communication (Message Bus/Events)
- **When**: Operations that can be processed eventually
- **Examples**:
  - Payment confirmation notification
  - Enrollment status updates
  - Fee calculation triggers
  - Report generation requests

### Event-Driven Architecture
- Services publish events when state changes
- Other services subscribe to relevant events
- Enables loose coupling and scalability

**Example Event Flow:**
1. Student enrolls in activity → **Student Enrollment Service** publishes `EnrollmentCreated` event
2. **Fee Management Service** subscribes → Calculates fees → Publishes `FeeCalculated` event
3. **Notification Service** subscribes → Sends enrollment confirmation email
4. **Reporting Service** subscribes → Updates enrollment statistics

---

## Data Management Strategy

### Database per Service Pattern
Each microservice maintains its own database:
- **Identity Service**: ASP.NET Core Identity database (AspNetUsers, AspNetRoles, AspNetUserRoles, AspNetUserClaims, AspNetRoleClaims, AspNetUserLogins, AspNetUserTokens) + custom RefreshTokens table
- **School Management Service**: School database
- **Fee Management Service**: Fee database
- **Payment Service**: Payment database
- **Student Enrollment Service**: Enrollment database
- **Activity Service**: Activity database
- **Notification Service**: Notification logs database
- **Reporting Service**: Aggregated data / data warehouse
- **Admin Service**: Tenant management database

### Benefits:
- **Data Isolation**: Services don't share databases
- **Independent Scaling**: Each database can be scaled independently
- **Technology Flexibility**: Different services can use different database types
- **Failure Isolation**: Database failures are contained to one service

### Challenges:
- **Data Consistency**: Requires eventual consistency patterns
- **Cross-Service Queries**: Requires API calls or event sourcing
- **Transaction Management**: Distributed transactions are complex

---

## Security Considerations

### Authentication Flow
1. User logs in through **Identity & Access Service**
2. Service uses ASP.NET Core Identity's `SignInManager` to validate credentials
3. Identity handles password hashing, account lockout, and email confirmation
4. Service generates JWT access token and refresh token
5. Token includes user ID (string), roles, claims (permissions), and tenant ID
6. All subsequent requests include token in Authorization header
7. API Gateway validates token before routing requests
8. Refresh tokens stored in custom RefreshTokens table for revocation

### Authorization
- Role-based access control (RBAC)
- Tenant isolation (school admins can only access their school data)
- Resource-level permissions

### Data Security
- Encryption at rest (database encryption)
- Encryption in transit (HTTPS/TLS)
- Payment data tokenization (PCI-DSS compliance)
- Audit logging for sensitive operations

---

## Scalability Considerations

### Independent Scaling
Each service can be scaled independently based on:
- **Identity Service**: Login traffic patterns
- **Payment Service**: Payment processing load
- **Notification Service**: Notification volume
- **Reporting Service**: Report generation requests

### Caching Strategy
- **API Gateway**: Response caching for read-heavy operations
- **Reporting Service**: Cached reports and dashboards
- **School Management Service**: Cached school profiles
- **Activity Service**: Cached activity listings

### Load Patterns
- **Peak Enrollment Periods**: Student Enrollment Service, Activity Service
- **Payment Deadlines**: Payment Service, Notification Service
- **Report Generation**: Reporting Service (scheduled jobs)

---

## Deployment Architecture

### Infrastructure Components
- **Independent Microservices**: Each service deployed as separate container/service
- **Own Databases**: Each service has its own database instance
- **Message Bus**: Centralized event bus (RabbitMQ, Kafka, AWS SQS, Azure Service Bus)
- **API Gateway**: Centralized routing and request handling
- **Service Discovery**: Service registry for dynamic service location
- **Load Balancers**: Distribute traffic across service instances

### Deployment Options
- **Container Orchestration**: Kubernetes, Docker Swarm
- **Cloud Platforms**: AWS, Azure, GCP
- **Serverless**: AWS Lambda, Azure Functions (for event processing)
- **Hybrid**: Mix of containers and serverless

---

## Monitoring and Observability

### Key Metrics
- **Service Health**: Uptime, response times, error rates
- **Business Metrics**: Enrollment counts, payment success rates, notification delivery rates
- **Infrastructure Metrics**: CPU, memory, database connections

### Logging
- Centralized logging (ELK stack, CloudWatch, Application Insights)
- Structured logging with correlation IDs
- Audit logs for financial operations

### Tracing
- Distributed tracing (Jaeger, Zipkin, AWS X-Ray)
- Request correlation across services
- Performance bottleneck identification

---

## Best Practices Implemented

1. **Single Responsibility**: Each service has a clear, single purpose
2. **Loose Coupling**: Services communicate via APIs and events
3. **High Cohesion**: Related functionality is grouped within services
4. **Database per Service**: Data isolation and independence
5. **API Gateway**: Unified entry point and cross-cutting concerns
6. **Event-Driven**: Asynchronous communication for scalability
7. **Security-First**: Isolated identity and access management
8. **Observability**: Comprehensive logging, monitoring, and tracing

---

## Common Scenarios

### Scenario 1: Student Enrolls in Activity
1. Student selects activity through Student Portal
2. API Gateway routes to **Student Enrollment Service**
3. **Student Enrollment Service** validates:
   - Student identity (via **Identity Service**)
   - Activity availability (via **Activity Service**)
   - Capacity checks (via **Activity Service**)
4. Enrollment created → Publishes `EnrollmentCreated` event
5. **Fee Management Service** receives event → Calculates fees
6. **Notification Service** receives event → Sends confirmation email
7. **Reporting Service** receives event → Updates statistics

### Scenario 2: Fee Payment
1. Student initiates payment through Student Portal
2. API Gateway routes to **Payment Service**
3. **Payment Service**:
   - Validates payment amount (via **Fee Management Service**)
   - Processes payment through external gateway
   - Updates payment status
4. Publishes `PaymentCompleted` event
5. **Notification Service** → Sends payment confirmation
6. **Reporting Service** → Updates payment analytics
7. **Fee Management Service** → Updates fee status

### Scenario 3: School Admin Views Dashboard
1. School admin accesses dashboard through School Admin Portal
2. API Gateway validates authentication (via **Identity Service**)
3. **Reporting Service** aggregates data from:
   - **Student Enrollment Service** (enrollment counts)
   - **Payment Service** (payment statistics)
   - **Activity Service** (activity participation)
4. Returns aggregated dashboard data
5. Response cached for subsequent requests

---

## Technology Stack Recommendations

### API Gateway
- AWS API Gateway, Azure API Management, Kong, Ocelot

### Message Bus
- RabbitMQ, Apache Kafka, AWS SQS, Azure Service Bus

### Databases
- **Identity Service**: SQL Server with ASP.NET Core Identity tables (AspNetUsers, AspNetRoles, etc.) + custom RefreshTokens table
- **Payment Service**: PostgreSQL (with encryption), SQL Server
- **Reporting Service**: PostgreSQL, SQL Server, or data warehouse (Snowflake, Redshift)
- **Others**: PostgreSQL, SQL Server, MongoDB (for flexible schemas)

### Caching
- Redis, Memcached, AWS ElastiCache

### Monitoring
- Prometheus + Grafana, CloudWatch, Application Insights

### Logging
- ELK Stack (Elasticsearch, Logstash, Kibana), CloudWatch Logs, Application Insights

---

## Conclusion

This microservices architecture provides:
- **Scalability**: Independent scaling of services
- **Maintainability**: Clear service boundaries and responsibilities
- **Reliability**: Failure isolation and resilience
- **Security**: Centralized authentication and authorization
- **Flexibility**: Technology choices per service
- **Business Agility**: Independent deployment and feature development

The architecture follows domain-driven design principles, ensuring each service represents a distinct business capability while maintaining loose coupling and high cohesion.

