# BongoBongo - Interview Questions & Answers

## Question 1: What are the Azure services you have used in this project and what are the scenarios? Provide high-level explanation.

### Answer:

In the BongoBongo project, we leveraged multiple Azure services to build a scalable, secure, and high-performing online gaming platform. Here's a comprehensive breakdown of each Azure service, its purpose, and specific scenarios where we used them:

---

### 1. **Azure App Service**

**Purpose**: Platform-as-a-Service (PaaS) for hosting web applications and APIs

**Scenarios Used**:
- **Hosting Microservices**: Each of our .NET Core microservices (User Service, Sports Betting Service, Casino Service, Payment Service, Game Provider Service) was deployed as separate Azure App Service instances
- **Auto-scaling**: Configured auto-scaling rules to handle traffic spikes during major sports events (e.g., World Cup matches) or promotional campaigns
- **Deployment Slots**: Used staging and production slots for zero-downtime deployments and blue-green deployment strategy
- **Custom Domains & SSL**: Configured custom domains with SSL certificates for secure HTTPS communication
- **Application Settings**: Managed environment-specific configuration (connection strings, API keys) through App Service Configuration

**High-Level Explanation**:
Azure App Service eliminated the need for VM management while providing built-in load balancing, auto-scaling, and monitoring. We deployed each microservice independently, allowing us to scale services based on their individual load patterns. For example, during peak betting hours, the Sports Betting Service would scale out to 5-10 instances, while the User Service might only need 2-3 instances.

---

### 2. **Azure SQL Database**

**Purpose**: Fully managed relational database service based on SQL Server

**Scenarios Used**:
- **Primary Data Store**: Stored all transactional data including:
  - User accounts, profiles, and authentication data
  - Wallet balances and transaction history
  - Sports events, bets, and odds
  - Casino games, game sessions, and game history
  - Game provider configurations
- **Geo-Replication**: Configured active geo-replication for disaster recovery and read scalability
- **Elastic Pools**: Used elastic pools to manage multiple databases cost-effectively, sharing resources across different microservices' databases
- **Automated Backups**: Leveraged automated backups with point-in-time restore capability (up to 35 days retention)
- **Performance Tuning**: Used Query Performance Insights to identify slow queries and optimize database performance
- **Read Replicas**: Created read replicas for reporting queries and analytics to offload read traffic from the primary database

**High-Level Explanation**:
Azure SQL Database provided a fully managed database solution with built-in high availability (99.99% SLA). We used separate databases for each microservice to maintain data isolation and independent scaling. The geo-replication feature ensured business continuity in case of regional failures. Elastic pools helped us optimize costs by sharing resources across multiple databases that had varying usage patterns.

---

### 3. **Azure Service Bus**

**Purpose**: Enterprise message broker for asynchronous communication between services

**Scenarios Used**:
- **Bet Settlement Processing**: When a sports event completes, the Sports Betting Service publishes a message to a Service Bus queue. A background worker service processes these messages asynchronously to settle bets, calculate winnings, and update user wallets
- **Notification Queue**: When a user places a bet or makes a deposit, the respective service publishes a notification message. The Notification Service consumes these messages and sends emails/SMS asynchronously without blocking the main transaction
- **Payment Processing**: For withdrawal requests, the Payment Service publishes messages to a queue. A separate worker processes withdrawals, integrates with payment gateways, and updates transaction status
- **Game Session Events**: When a casino game session ends, the Casino Service publishes game result messages. The Payment Service consumes these to update user balances based on wins/losses
- **Event-Driven Architecture**: Used Service Bus Topics and Subscriptions for pub/sub scenarios where multiple services needed to react to the same event (e.g., user account verification completion)

**High-Level Explanation**:
Azure Service Bus enabled decoupled, asynchronous communication between microservices. This was crucial for maintaining system responsiveness during high-traffic periods. For example, when thousands of users place bets simultaneously, the system doesn't wait for email notifications to be sent before responding to the user. Instead, it publishes a message and continues processing, while notifications are handled asynchronously. This pattern improved system throughput and resilience.

---

### 4. **Azure Blob Storage**

**Purpose**: Object storage service for unstructured data

**Scenarios Used**:
- **Static Assets**: Stored Angular application build files, images, CSS, JavaScript bundles
- **Game Assets**: Stored game provider assets, game thumbnails, promotional banners, and casino game media files
- **User Uploads**: Stored user profile pictures, KYC documents (ID cards, proof of address), and verification documents
- **Backup Storage**: Stored database backup files and application logs for long-term retention
- **Content Delivery**: Integrated with Azure CDN to serve static content globally with low latency

**High-Level Explanation**:
Azure Blob Storage provided cost-effective storage for large amounts of unstructured data. We used different access tiers (Hot, Cool, Archive) based on access patterns. Frequently accessed game assets were stored in Hot tier, while older user documents were moved to Cool tier for cost optimization. The integration with CDN ensured fast content delivery to users across different geographic regions.

---

### 5. **Azure Application Insights**

**Purpose**: Application Performance Monitoring (APM) and observability platform

**Scenarios Used**:
- **Performance Monitoring**: Tracked response times, request rates, and dependencies for all API endpoints across microservices
- **Error Tracking**: Captured exceptions, stack traces, and error rates. Set up alerts for critical errors (e.g., payment processing failures)
- **Custom Telemetry**: Tracked business metrics such as:
  - Number of bets placed per hour
  - Average bet amount
  - Deposit/withdrawal transaction volumes
  - Active game sessions
- **Dependency Tracking**: Monitored calls to external services (game provider APIs, payment gateways) to identify bottlenecks
- **User Analytics**: Tracked user flows, page views, and user behavior patterns in the Angular application
- **Live Metrics**: Real-time monitoring dashboard for production incidents
- **Smart Alerts**: Configured proactive alerts for performance degradation, high error rates, and availability issues

**High-Level Explanation**:
Application Insights provided comprehensive observability into our distributed system. When a user reported an issue with bet placement, we could trace the entire request flow across multiple services, identify the exact failure point, and view correlated logs and exceptions. This significantly reduced mean time to resolution (MTTR) for production issues. The custom metrics helped business stakeholders understand platform usage patterns and make data-driven decisions.

---

### 6. **Azure Key Vault**

**Purpose**: Secure storage and management of secrets, keys, and certificates

**Scenarios Used**:
- **API Keys Storage**: Securely stored API keys for external game providers (Pragmatic Play, 1X2 Gaming, etc.)
- **Database Connection Strings**: Stored SQL Server connection strings with sensitive credentials
- **JWT Secret Keys**: Stored secret keys used for JWT token signing and validation
- **Payment Gateway Credentials**: Securely stored API keys and merchant IDs for payment gateway integrations
- **Service Bus Connection Strings**: Stored Service Bus connection strings for secure message queuing
- **SSL Certificates**: Managed SSL/TLS certificates for custom domains
- **Access Policies**: Configured role-based access to secrets, ensuring only authorized services and developers could access sensitive data

**High-Level Explanation**:
Azure Key Vault centralized secret management and eliminated the need to hardcode sensitive information in application code or configuration files. Our microservices retrieved secrets at runtime using managed identities, ensuring credentials never appeared in logs or code repositories. This approach met compliance requirements and significantly improved security posture. When we needed to rotate API keys (e.g., for a game provider), we updated the secret in Key Vault, and services automatically picked up the new value without code changes or redeployment.

---

### 7. **Azure CDN (Content Delivery Network)**

**Purpose**: Global content delivery network for fast content distribution

**Scenarios Used**:
- **Static Asset Delivery**: Served Angular application static files (HTML, CSS, JavaScript) from edge locations closest to users
- **Game Assets**: Delivered game thumbnails, promotional images, and casino game media files with low latency
- **Image Optimization**: Used CDN features to optimize and resize images on-the-fly for different device types
- **Caching Strategy**: Configured cache rules for different content types:
  - Static assets: Long cache duration (1 year)
  - Dynamic API responses: No caching
  - Images: Medium cache duration (1 week)
- **HTTPS Enforcement**: Ensured all content was served over HTTPS for security

**High-Level Explanation**:
Azure CDN dramatically improved user experience by reducing latency for users in Uganda and surrounding regions. Instead of fetching static assets from a single Azure region, content was cached at edge locations worldwide. This reduced page load times from several seconds to under a second, especially important for mobile users with slower connections. The CDN also reduced bandwidth costs by serving cached content instead of hitting origin servers repeatedly.

---

### 8. **Azure Active Directory B2C** (Optional)

**Purpose**: Identity and access management for customer-facing applications

**Scenarios Used**:
- **User Authentication**: Managed user registration, login, password reset, and account recovery flows
- **Social Identity Providers**: Integrated with social login options (Google, Facebook) for easier user onboarding
- **Multi-Factor Authentication (MFA)**: Enabled MFA for enhanced security, especially for high-value transactions
- **Custom Policies**: Configured custom authentication flows for KYC verification requirements
- **Token Management**: Issued JWT tokens for API authentication after user login

**High-Level Explanation**:
While we primarily used custom JWT-based authentication, Azure AD B2C could be integrated for a more robust identity management solution. It would handle complex scenarios like password complexity requirements, account lockout policies, and compliance with data protection regulations. The social login integration would reduce friction during user registration, potentially increasing user acquisition rates.

---

### 9. **Azure Redis Cache**

**Purpose**: In-memory data store for fast data access

**Scenarios Used**:
- **Session Storage**: Stored user session data and authentication tokens for fast retrieval
- **Odds Caching**: Cached frequently accessed sports odds data to reduce database load during high-traffic periods
- **Game Catalog Caching**: Cached casino game catalog and game provider information to avoid repeated database queries
- **Rate Limiting**: Implemented rate limiting using Redis to prevent API abuse and DDoS attacks
- **Real-time Data**: Stored real-time betting statistics, live scores, and active game session data
- **Distributed Locking**: Used Redis for distributed locks during critical operations (e.g., preventing duplicate bet placements, wallet balance updates)

**High-Level Explanation**:
Azure Redis Cache significantly improved application performance by reducing database load. For example, sports odds data that was queried thousands of times per minute was cached in Redis with a 30-second TTL. This reduced database queries by over 80% during peak hours. Redis also enabled real-time features like live betting odds updates, where multiple users see synchronized data without hitting the database for each request. The distributed locking feature ensured data consistency in our microservices architecture, preventing race conditions during concurrent operations.

---

### 10. **Azure Application Gateway** (Implied in Architecture)

**Purpose**: Web traffic load balancer and application delivery controller

**Scenarios Used**:
- **API Gateway**: Acted as a single entry point for all client requests, routing to appropriate microservices
- **SSL Termination**: Handled SSL/TLS encryption at the gateway level, reducing load on backend services
- **Load Balancing**: Distributed incoming requests across multiple instances of each microservice
- **Health Probes**: Monitored backend service health and automatically routed traffic away from unhealthy instances
- **URL-based Routing**: Routed requests to specific microservices based on URL patterns (e.g., `/api/users/*` → User Service, `/api/sports/*` → Sports Betting Service)
- **WAF (Web Application Firewall)**: Protected against common web vulnerabilities (SQL injection, XSS attacks)
- **Request/Response Rewriting**: Modified headers and URLs as needed for service communication

**High-Level Explanation**:
Azure Application Gateway served as the API Gateway for our microservices architecture. It provided a single, consistent entry point for the Angular frontend, abstracting the complexity of the backend service topology. The gateway handled cross-cutting concerns like SSL termination, request routing, and security, allowing microservices to focus on business logic. Health probes ensured high availability by automatically detecting and bypassing failed service instances.

---

### 11. **Azure Load Balancer** (For Internal Load Balancing)

**Purpose**: Network load balancer for distributing traffic

**Scenarios Used**:
- **Internal Service Communication**: Load balanced traffic between microservices for internal API calls
- **Database Connection Distribution**: Distributed database connections across multiple SQL Database instances (if using read replicas)
- **High Availability**: Ensured services remained available even if individual instances failed

**High-Level Explanation**:
Azure Load Balancer complemented Application Gateway by handling internal load balancing. While Application Gateway handled external traffic, Load Balancer managed traffic between microservices and other internal Azure resources. This two-tier load balancing approach provided both external and internal resilience.

---

### 12. **Azure DNS**

**Purpose**: DNS hosting and domain name management

**Scenarios Used**:
- **Domain Management**: Managed DNS records for `bongobongo.ug` domain
- **Custom Domain Configuration**: Configured A records and CNAME records for Azure App Services and CDN
- **Subdomain Routing**: Set up subdomains for different environments (e.g., `api.bongobongo.ug`, `staging.bongobongo.ug`)

**High-Level Explanation**:
Azure DNS provided reliable, low-latency DNS resolution for our domain. It integrated seamlessly with other Azure services, making it easy to configure custom domains for App Services and CDN endpoints. The service provided high availability and fast DNS propagation globally.

---

### Additional Azure Services (Potentially Used)

#### **Azure Communication Services**
- **Scenario**: For sending SMS notifications, email notifications, and push notifications to users
- **Use Case**: Transaction confirmations, bet settlement notifications, promotional messages

#### **Azure Monitor**
- **Scenario**: Comprehensive monitoring and alerting across all Azure resources
- **Use Case**: Infrastructure monitoring, log aggregation, metric collection, and alerting

#### **Azure Backup**
- **Scenario**: Backup and recovery for critical data and configurations
- **Use Case**: Database backups, application configuration backups, disaster recovery planning

#### **Azure Virtual Network (VNet)**
- **Scenario**: Network isolation and secure communication between Azure resources
- **Use Case**: Private endpoints for SQL Database, Service Bus, and other services to enhance security

---

## Summary

The BongoBongo platform leveraged a comprehensive Azure ecosystem to deliver a scalable, secure, and high-performing online gaming experience. Each Azure service addressed specific architectural needs:

- **Compute**: Azure App Service for hosting microservices
- **Data**: Azure SQL Database for transactional data, Redis Cache for performance
- **Messaging**: Azure Service Bus for asynchronous communication
- **Storage**: Azure Blob Storage for static assets and user uploads
- **Networking**: Application Gateway, Load Balancer, CDN for traffic management
- **Security**: Key Vault for secrets management
- **Monitoring**: Application Insights for observability
- **DNS**: Azure DNS for domain management

This architecture ensured high availability (99.95%+ SLA), scalability to handle traffic spikes, security compliance, and cost optimization through right-sized resources and efficient caching strategies.

