# AWS Interview Q&A for .NET Developers - Part 1: Core AWS Services & Infrastructure

## 1. **Scenario: You need to deploy a .NET Core Web API to AWS. Walk me through the infrastructure components you would use and why.**

**Answer:**
For deploying a .NET Core Web API, I would use:

1. **EC2 or ECS/Fargate**: For hosting the application
   - EC2: Full control, good for legacy apps or specific requirements
   - ECS/Fargate: Containerized deployment, better for microservices, auto-scaling

2. **Application Load Balancer (ALB)**: 
   - Distributes traffic across multiple instances
   - SSL/TLS termination
   - Health checks and automatic failover
   - Path-based routing for microservices

3. **VPC (Virtual Private Cloud)**:
   - Isolated network environment
   - Public subnets for ALB
   - Private subnets for application servers
   - NAT Gateway for outbound internet access

4. **Security Groups & NACLs**:
   - Security Groups: Stateful firewall at instance level
   - NACLs: Stateless firewall at subnet level

5. **IAM Roles**: 
   - Grant permissions to EC2/ECS tasks to access other AWS services
   - No need to store credentials in code

6. **Route 53**: DNS management and health checks

7. **CloudWatch**: Monitoring, logging, and alarms

**Why this architecture?**
- High availability with multi-AZ deployment
- Scalability with auto-scaling groups
- Security with private subnets and IAM
- Observability with CloudWatch

---

## 2. **Explain the difference between EC2, ECS, and Lambda. When would you choose each for a .NET application?**

**Answer:**

**EC2 (Elastic Compute Cloud)**:
- Virtual servers with full OS control
- Best for: Long-running applications, legacy .NET Framework apps, applications requiring specific OS configurations
- You manage: OS patches, scaling, load balancing
- Example: Traditional ASP.NET MVC application

**ECS (Elastic Container Service)**:
- Container orchestration service
- Best for: Microservices, containerized .NET Core applications, CI/CD pipelines
- AWS manages: Container orchestration, scheduling
- You manage: Container images, application code
- Example: .NET Core API in Docker containers

**Lambda**:
- Serverless function execution
- Best for: Event-driven tasks, API endpoints, scheduled jobs, processing S3 uploads
- AWS manages: Everything (scaling, infrastructure, OS)
- You manage: Function code only
- Example: .NET 6+ minimal APIs, processing SQS messages, API Gateway integrations

**Decision Matrix:**
- **EC2**: Need full control, long-running processes, specific OS requirements
- **ECS**: Microservices architecture, containerization strategy, need orchestration
- **Lambda**: Event-driven, short-lived tasks, cost optimization for sporadic workloads

---

## 3. **Scenario: Your .NET application needs to store files uploaded by users. Compare S3, EBS, and EFS for this use case.**

**Answer:**

**S3 (Simple Storage Service)**:
- **Best for**: User uploads, static assets, backups, content delivery
- **Characteristics**:
  - Object storage (not file system)
  - Virtually unlimited storage
  - 99.999999999% (11 9's) durability
  - Access via REST API or SDK
  - Cost-effective for large volumes
  - Versioning and lifecycle policies
- **Use case**: Profile pictures, documents, media files
- **.NET Integration**: AWS SDK for .NET (`Amazon.S3`)

**EBS (Elastic Block Store)**:
- **Best for**: Database storage, application logs on single EC2 instance
- **Characteristics**:
  - Block storage attached to EC2
  - Limited to single instance
  - Not suitable for shared access
- **Use case**: Database volumes, application data on single server
- **Not recommended** for user uploads (scalability issues)

**EFS (Elastic File System)**:
- **Best for**: Shared file storage across multiple EC2 instances
- **Characteristics**:
  - Network file system (NFS)
  - Multiple instances can access simultaneously
  - More expensive than S3
  - Lower latency than S3
- **Use case**: Shared application files, content management systems
- **.NET Integration**: Mount as network drive, use standard .NET file I/O

**Recommendation for user uploads**: **S3** - scalable, cost-effective, designed for object storage, integrates well with CloudFront for CDN.

---

## 4. **How would you design a highly available .NET application architecture on AWS? Include disaster recovery considerations.**

**Answer:**

**High Availability Architecture:**

1. **Multi-AZ Deployment**:
   - Deploy application across at least 2 Availability Zones
   - Use Application Load Balancer with health checks
   - Auto Scaling Group spanning multiple AZs

2. **Database High Availability**:
   - RDS Multi-AZ for synchronous replication
   - Read replicas in different AZs for read scaling
   - Automated backups with point-in-time recovery

3. **Stateless Application Design**:
   - Store session state in ElastiCache (Redis) or DynamoDB
   - No local file storage (use S3)
   - Enable sticky sessions only if necessary

4. **Load Balancing**:
   - Application Load Balancer with health checks
   - Configure target group health checks
   - Automatic failover to healthy instances

5. **Auto Scaling**:
   - Configure based on CPU, memory, or custom metrics
   - Minimum 2 instances across 2 AZs
   - Scale out during peak, scale in during low traffic

**Disaster Recovery (DR) Strategy:**

1. **Backup Strategy**:
   - RDS automated backups (7-35 days retention)
   - S3 versioning and cross-region replication
   - AMI snapshots of EC2 instances

2. **Multi-Region Setup**:
   - Deploy to secondary region (warm standby)
   - Route 53 with health checks for failover
   - Cross-region replication for critical data

3. **Recovery Time Objectives (RTO)**:
   - **Active-Passive**: 15-30 minutes (warm standby)
   - **Active-Active**: Near-zero (both regions active)
   - **Backup & Restore**: 4-24 hours (cold standby)

4. **Data Replication**:
   - RDS cross-region read replicas
   - S3 cross-region replication
   - Database replication via DMS (Database Migration Service)

**Example Architecture:**
```
Route 53 → CloudFront → ALB (Multi-AZ) → EC2/ECS (Auto Scaling) → RDS Multi-AZ
                                                                    ↓
                                                              ElastiCache (Redis)
                                                                    ↓
                                                              S3 (User Files)
```

---

## 5. **Explain VPC, Subnets, Internet Gateway, NAT Gateway, and how they work together in a .NET application deployment.**

**Answer:**

**VPC (Virtual Private Cloud)**:
- Isolated virtual network in AWS
- You control: IP address ranges, subnets, routing tables, network gateways
- Default VPC: All subnets are public, instances get public IPs
- Custom VPC: Full control over network design

**Subnets**:
- Logical division of VPC IP address range
- **Public Subnet**: Has route to Internet Gateway (0.0.0.0/0 → IGW)
  - Used for: Load Balancers, Bastion hosts, NAT Gateways
- **Private Subnet**: No direct internet access
  - Used for: Application servers, databases, internal services
- **Best Practice**: Deploy across multiple AZs for high availability

**Internet Gateway (IGW)**:
- Allows communication between VPC and internet
- One per VPC
- Provides public IP addresses
- Attached to public subnets

**NAT Gateway**:
- Allows private subnet resources to access internet (outbound only)
- Deployed in public subnet
- One NAT Gateway per AZ (for high availability)
- Used for: Software updates, API calls to external services, downloading packages
- **Cost consideration**: ~$32/month + data transfer

**Complete Flow Example (.NET API in private subnet):**

1. **Inbound Traffic**:
   ```
   Internet → IGW → Public Subnet (ALB) → Private Subnet (.NET API on EC2)
   ```

2. **Outbound Traffic from Private Subnet**:
   ```
   .NET API (Private Subnet) → NAT Gateway (Public Subnet) → IGW → Internet
   ```

3. **Database Access**:
   ```
   .NET API (Private Subnet) → RDS (Private Subnet) [No internet needed]
   ```

**Security Benefits**:
- Application servers not directly exposed to internet
- Database in private subnet (no public access)
- Only ALB in public subnet (handles SSL termination)
- NAT Gateway allows updates without exposing instances

---

## 6. **Scenario: Your .NET application needs to authenticate users. How would you implement authentication using AWS Cognito?**

**Answer:**

**AWS Cognito Overview**:
- Managed authentication service
- Supports: User sign-up, sign-in, OAuth 2.0, SAML, MFA
- Two components: User Pools (authentication) and Identity Pools (authorization)

**Implementation Steps:**

1. **Create Cognito User Pool**:
   - Configure sign-in options (email, username, phone)
   - Set password policy
   - Enable MFA if required
   - Configure OAuth flows (Authorization Code, Implicit)

2. **Create App Client**:
   - Generate Client ID and Client Secret
   - Configure allowed OAuth flows
   - Set callback URLs

3. **.NET Integration**:

```csharp
// Install: AWSSDK.CognitoIdentityProvider

// Sign Up
var signUpRequest = new SignUpRequest
{
    ClientId = "your-client-id",
    Username = userEmail,
    Password = password,
    UserAttributes = new List<AttributeType>
    {
        new AttributeType { Name = "email", Value = userEmail }
    }
};
var response = await cognitoClient.SignUpAsync(signUpRequest);

// Sign In
var authRequest = new InitiateAuthRequest
{
    ClientId = "your-client-id",
    AuthFlow = AuthFlowType.USER_PASSWORD_AUTH,
    AuthParameters = new Dictionary<string, string>
    {
        { "USERNAME", userEmail },
        { "PASSWORD", password }
    }
};
var authResponse = await cognitoClient.InitiateAuthAsync(authRequest);

// Use ID Token for API calls
var idToken = authResponse.AuthenticationResult.IdToken;
```

4. **API Gateway Integration**:
   - Use Cognito User Pool Authorizer
   - Validate JWT tokens automatically
   - Extract user claims from token

5. **Identity Pool (for AWS Resource Access)**:
   - After authentication, exchange ID token for temporary AWS credentials
   - Access S3, DynamoDB, etc. with IAM permissions

**Benefits**:
- No need to manage user database
- Built-in MFA, password reset, email verification
- Scales automatically
- Integrates with social identity providers (Google, Facebook, etc.)

---

## 7. **What is IAM and how would you use it to secure your .NET application's access to AWS services?**

**Answer:**

**IAM (Identity and Access Management)**:
- Centralized access control for AWS services
- Manages: Users, Groups, Roles, Policies
- Principle of least privilege

**Key Components:**

1. **IAM Users**: For human access (developers, admins)
2. **IAM Groups**: Collection of users with shared permissions
3. **IAM Roles**: For AWS services and applications (assumed temporarily)
4. **IAM Policies**: JSON documents defining permissions

**Best Practices for .NET Applications:**

1. **Use IAM Roles, Not Access Keys**:
   ```csharp
   // Bad: Hardcoded credentials
   var credentials = new BasicAWSCredentials("access-key", "secret-key");
   
   // Good: Use IAM Role (automatic credential chain)
   var s3Client = new AmazonS3Client(); // Uses instance profile automatically
   ```

2. **Attach IAM Role to EC2/ECS**:
   - EC2: Instance Profile with IAM Role
   - ECS: Task Role for containerized applications
   - No credentials stored in code or environment variables

3. **Least Privilege Principle**:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "s3:GetObject",
           "s3:PutObject"
         ],
         "Resource": "arn:aws:s3:::my-bucket/uploads/*"
       }
     ]
   }
   ```

4. **Separate Roles for Different Services**:
   - API service: Read/Write to S3, publish to SQS
   - Background worker: Read from SQS, write to DynamoDB
   - Admin service: Full access to specific resources

**Example: .NET Application Accessing S3**:

```csharp
// IAM Role attached to EC2/ECS automatically provides credentials
var s3Client = new AmazonS3Client(RegionEndpoint.USEast1);

// Upload file
await s3Client.PutObjectAsync(new PutObjectRequest
{
    BucketName = "my-app-uploads",
    Key = $"users/{userId}/profile.jpg",
    FilePath = localFilePath,
    ContentType = "image/jpeg"
});
```

**Security Benefits**:
- No credential management in code
- Automatic credential rotation
- Centralized access control
- Audit trail via CloudTrail

---

## 8. **Explain the difference between Security Groups and NACLs. When would you use each?**

**Answer:**

**Security Groups**:
- **Stateful firewall** at instance/ENI level
- **Default**: Deny all inbound, allow all outbound
- **Rules**: Allow rules only (implicit deny)
- **Evaluation**: All rules evaluated before allowing traffic
- **Scope**: Instance-level (applied to EC2, RDS, ALB, etc.)
- **Return traffic**: Automatically allowed (stateful)

**NACLs (Network Access Control Lists)**:
- **Stateless firewall** at subnet level
- **Default**: Allow all traffic
- **Rules**: Both allow and deny rules
- **Evaluation**: Rules evaluated in order (lowest rule number first)
- **Scope**: Subnet-level (applied to all resources in subnet)
- **Return traffic**: Must be explicitly allowed (stateless)

**Comparison Table:**

| Feature | Security Groups | NACLs |
|---------|----------------|-------|
| Level | Instance/ENI | Subnet |
| Stateful | Yes | No |
| Default | Deny inbound, Allow outbound | Allow all |
| Rules | Allow only | Allow + Deny |
| Order | All evaluated | Numbered order |
| Return Traffic | Automatic | Must be explicit |

**When to Use Each:**

**Security Groups** (Primary Defense):
- Use for: Most security requirements
- Example: Allow HTTPS (443) from ALB to EC2
- Example: Allow MySQL (3306) from app servers to RDS

**NACLs** (Additional Layer):
- Use for: Subnet-level restrictions, compliance requirements
- Example: Block specific IP ranges at subnet level
- Example: Deny traffic from development subnet to production subnet
- Example: Compliance requirement for explicit deny rules

**Best Practice**:
- **Primary**: Use Security Groups (simpler, stateful, sufficient for most cases)
- **Secondary**: Use NACLs for additional subnet-level controls or compliance

**Example Scenario**:
```
Public Subnet (ALB):
  - Security Group: Allow 443 from 0.0.0.0/0
  - NACL: Allow 443 from 0.0.0.0/0, Deny specific malicious IPs

Private Subnet (.NET API):
  - Security Group: Allow 80 from ALB Security Group
  - NACL: Allow all (Security Group handles filtering)
```

---

## 9. **Scenario: You need to host a SQL Server database for your .NET application. Compare RDS SQL Server, EC2 with SQL Server, and Aurora Serverless.**

**Answer:**

**RDS SQL Server (Managed Service)**:
- **Best for**: Most production .NET applications
- **Characteristics**:
  - AWS manages: Backups, patching, monitoring, Multi-AZ setup
  - Supported versions: SQL Server 2012-2022 (Express, Web, Standard, Enterprise)
  - Automated backups with point-in-time recovery
  - Read replicas for scaling reads
  - Multi-AZ for high availability (synchronous replication)
- **Pros**:
  - Less operational overhead
  - Automated backups and patching
  - Easy scaling (instance size, storage)
  - Built-in monitoring
- **Cons**:
  - Limited SQL Server features (no SQL Server Agent, limited CLR)
  - Cannot RDP into instance
  - More expensive than EC2 (license included)
- **Cost**: ~$200-5000/month depending on instance size

**EC2 with SQL Server (Self-Managed)**:
- **Best for**: Full SQL Server feature access, specific configurations
- **Characteristics**:
  - Full control over SQL Server instance
  - Access via RDP
  - Can use SQL Server Agent, CLR, full feature set
  - You manage: Backups, patching, monitoring, high availability
- **Pros**:
  - Full SQL Server feature access
  - Can use existing SQL Server licenses (Bring Your Own License)
  - More control over configuration
  - Can install additional software
- **Cons**:
  - You manage everything (operational overhead)
  - Need to set up backups, monitoring, high availability
  - More complex disaster recovery
- **Cost**: EC2 cost + SQL Server license (or BYOL)

**Aurora Serverless (Not SQL Server)**:
- **Note**: Aurora is MySQL/PostgreSQL compatible, not SQL Server
- **Best for**: Variable workloads, cost optimization
- **Auto-scales**: Capacity adjusts automatically
- **Not applicable** for SQL Server workloads

**Recommendation for .NET with SQL Server**:
- **Production**: **RDS SQL Server** - managed service, less operational overhead
- **Development/Testing**: RDS SQL Server (smaller instance) or EC2
- **Legacy .NET Framework**: RDS SQL Server (supports older versions)
- **Need SQL Server Agent/CLR**: EC2 with SQL Server

**Migration Consideration**:
- If moving to cloud-native: Consider migrating to Aurora PostgreSQL or RDS PostgreSQL
- Use AWS DMS (Database Migration Service) for migration

---

## 10. **How does Auto Scaling work in AWS, and how would you configure it for a .NET application?**

**Answer:**

**Auto Scaling Components**:

1. **Launch Template/Configuration**: Defines what to launch (AMI, instance type, IAM role, user data)
2. **Auto Scaling Group (ASG)**: Defines where and how many instances
3. **Scaling Policies**: Define when to scale (based on metrics)

**Configuration Steps:**

1. **Create Launch Template**:
   - AMI with .NET application pre-installed (or use user data to install)
   - Instance type (t3.medium, t3.large, etc.)
   - IAM Role for AWS service access
   - Security Groups
   - User Data script (optional):
   ```bash
   #!/bin/bash
   yum update -y
   yum install -y dotnet-runtime-6.0
   systemctl start myapp.service
   ```

2. **Create Auto Scaling Group**:
   - VPC and subnets (multiple AZs for HA)
   - Target group (for ALB integration)
   - Min: 2 instances (for high availability)
   - Desired: 2-4 instances
   - Max: 10 instances
   - Health check: ELB health check (not just EC2 status)

3. **Configure Scaling Policies**:

**Target Tracking Scaling** (Recommended):
- Maintain target metric value
- Example: Keep CPU utilization at 50%
- ASG automatically adds/removes instances

**Step Scaling**:
- Scale based on CloudWatch alarms
- Example: Add 2 instances when CPU > 70%, remove 1 when CPU < 30%

**Simple Scaling**:
- Basic scale up/down based on single alarm

**Example Configuration**:
```json
{
  "AutoScalingGroupName": "dotnet-api-asg",
  "MinSize": 2,
  "MaxSize": 10,
  "DesiredCapacity": 2,
  "VPCZoneIdentifier": "subnet-123,subnet-456",
  "TargetGroupARNs": ["arn:aws:elasticloadbalancing:..."],
  "HealthCheckType": "ELB",
  "HealthCheckGracePeriod": 300
}
```

**Scaling Policies**:
```json
{
  "PolicyType": "TargetTrackingScaling",
  "TargetTrackingConfiguration": {
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "TargetValue": 50.0
  }
}
```

**Best Practices**:
- **Multi-AZ**: Deploy across at least 2 AZs
- **Health Checks**: Use ELB health checks (not just EC2)
- **Cooldown Periods**: Prevent rapid scaling oscillations
- **Custom Metrics**: Scale based on application-specific metrics (queue depth, request rate)
- **Scheduled Scaling**: Scale up before known traffic spikes

**.NET Application Considerations**:
- Ensure application is stateless (use external session store)
- Use health check endpoints (`/health`) for ALB
- Graceful shutdown handling (allow in-flight requests to complete)
- Consider using ECS with Fargate for containerized applications (simpler scaling)

---

## 11. **What is CloudFront and how would you use it with a .NET application?**

**Answer:**

**CloudFront Overview**:
- Global Content Delivery Network (CDN)
- Caches content at edge locations (closer to users)
- Reduces latency and bandwidth costs
- Supports: Static content, dynamic content, API acceleration, live streaming

**Use Cases with .NET Applications:**

1. **Static Asset Delivery**:
   - JavaScript, CSS, images
   - Reduces load on application servers
   - Example: Serve Angular/React bundles from CloudFront

2. **API Acceleration**:
   - Cache API responses (with appropriate TTL)
   - Reduce latency for global users
   - Use cache behaviors for different endpoints

3. **S3 Integration**:
   - Serve user-uploaded files (profile pictures, documents)
   - Custom domain with SSL certificate
   - Example: `cdn.myapp.com/uploads/*`

4. **Custom Origin (ALB/EC2)**:
   - CloudFront → ALB → .NET API
   - Cache static responses, pass through dynamic requests
   - DDoS protection (AWS Shield Standard included)

**Configuration Example**:

1. **Create Distribution**:
   - Origin: ALB or S3 bucket
   - Behaviors: Define caching rules per path pattern
   - SSL Certificate: ACM certificate for custom domain
   - Price Class: Optimize costs (US/Canada/Europe vs. All)

2. **Cache Behaviors**:
   ```
   /api/* → No caching (forward all headers, query strings)
   /static/* → Cache for 1 year (images, CSS, JS)
   /uploads/* → Cache for 1 hour (user content)
   ```

3. **.NET Application Integration**:
   ```csharp
   // Set cache headers in response
   Response.Headers.Add("Cache-Control", "public, max-age=3600");
   Response.Headers.Add("CDN-Cache-Control", "public, max-age=86400");
   ```

**Benefits**:
- **Performance**: Reduced latency (content served from edge locations)
- **Cost**: Reduced bandwidth costs (data transfer from CloudFront is cheaper)
- **Security**: DDoS protection, WAF integration
- **Scalability**: Offloads traffic from origin servers

**Best Practices**:
- Use cache invalidation for critical updates
- Set appropriate TTLs based on content type
- Use signed URLs for private content
- Enable compression (gzip/brotli)
- Monitor cache hit ratio in CloudWatch

---

## 12. **Explain Route 53 and how you would use it for a .NET application's DNS management.**

**Answer:**

**Route 53 Overview**:
- AWS managed DNS service
- Domain registration, DNS hosting, health checks, routing policies
- High availability and scalability

**Key Features:**

1. **DNS Hosting**:
   - Create hosted zone for your domain
   - Manage DNS records (A, AAAA, CNAME, MX, etc.)
   - Example: `api.myapp.com` → ALB DNS name

2. **Health Checks**:
   - Monitor endpoint health (HTTP/HTTPS, TCP)
   - Failover routing based on health
   - Example: Primary region unhealthy → failover to secondary region

3. **Routing Policies**:
   - **Simple**: Standard DNS (one record to one resource)
   - **Weighted**: Distribute traffic across multiple resources
   - **Latency-based**: Route to lowest latency region
   - **Failover**: Active-passive failover
   - **Geolocation**: Route based on user location
   - **Multivalue**: Multiple healthy IPs (simple load balancing)

**Common Use Cases for .NET Applications:**

1. **Domain Management**:
   ```
   myapp.com → CloudFront distribution
   api.myapp.com → ALB (Application Load Balancer)
   www.myapp.com → CloudFront (redirect to myapp.com)
   ```

2. **Multi-Region Failover**:
   ```
   Primary: api.myapp.com → US-East-1 ALB
   Secondary: api.myapp.com → US-West-2 ALB (failover)
   Health Check: Monitor /health endpoint
   ```

3. **Blue-Green Deployments**:
   ```
   api.myapp.com → Weighted routing
   90% → Blue environment (current)
   10% → Green environment (new version)
   ```

4. **Geographic Routing**:
   ```
   US users → US-East-1 ALB
   EU users → EU-West-1 ALB
   ```

**Example Configuration**:

```json
{
  "Name": "api.myapp.com",
  "Type": "A",
  "Alias": true,
  "AliasTarget": {
    "HostedZoneId": "Z35SXDOTRQ7X7K",
    "DNSName": "my-alb-123456789.us-east-1.elb.amazonaws.com",
    "EvaluateTargetHealth": true
  }
}
```

**Health Check Configuration**:
- Endpoint: `https://api.myapp.com/health`
- Interval: 30 seconds
- Failure threshold: 3 consecutive failures
- On failure: Route to secondary region

**Best Practices**:
- Use Alias records (not CNAME) for AWS resources (free, better performance)
- Enable health checks for critical endpoints
- Use failover routing for disaster recovery
- Set appropriate TTLs (60 seconds for dynamic, 3600 for static)
- Monitor Route 53 metrics in CloudWatch

---

## 13. **Scenario: Your .NET application needs to send emails. How would you implement this using AWS SES?**

**Answer:**

**Amazon SES (Simple Email Service)**:
- Scalable email sending service
- Supports: Transactional emails, marketing emails, bounce/complaint handling
- Cost-effective: $0.10 per 1,000 emails (after free tier)

**Implementation Steps:**

1. **Verify Domain/Email**:
   - Verify domain (add DNS records) or individual email
   - Required to send emails (sandbox mode: only verified emails)

2. **Request Production Access** (if needed):
   - Move out of sandbox mode
   - Can send to any email address

3. **.NET Integration**:

```csharp
// Install: AWSSDK.SimpleEmail

using Amazon.SimpleEmail;
using Amazon.SimpleEmail.Model;

var sesClient = new AmazonSimpleEmailServiceClient(RegionEndpoint.USEast1);

// Send email
var request = new SendEmailRequest
{
    Source = "noreply@myapp.com",
    Destination = new Destination
    {
        ToAddresses = new List<string> { "user@example.com" }
    },
    Message = new Message
    {
        Subject = new Content("Welcome to MyApp"),
        Body = new Body
        {
            Html = new Content("<h1>Welcome!</h1><p>Thank you for signing up.</p>"),
            Text = new Content("Welcome! Thank you for signing up.")
        }
    }
};

var response = await sesClient.SendEmailAsync(request);
```

4. **Using SES with Templates** (Recommended):

```csharp
// Create template in SES console or via API
var templateRequest = new SendTemplatedEmailRequest
{
    Source = "noreply@myapp.com",
    Destination = new Destination { ToAddresses = new List<string> { "user@example.com" } },
    Template = "WelcomeEmail",
    TemplateData = JsonSerializer.Serialize(new
    {
        name = "John",
        activationLink = "https://myapp.com/activate?token=abc123"
    })
};

await sesClient.SendTemplatedEmailAsync(templateRequest);
```

5. **Handle Bounces/Complaints**:
   - Configure SNS topics for bounces and complaints
   - Subscribe Lambda function or SQS queue
   - Update user status in database

**Best Practices**:
- **Use Templates**: Easier to manage, consistent formatting
- **Monitor Metrics**: Bounce rate, complaint rate, send statistics
- **Warm-up**: Gradually increase sending volume (new accounts have limits)
- **DKIM/SPF**: Configure DNS records for email authentication
- **Suppression List**: Automatically handle bounces/complaints
- **Rate Limiting**: Respect SES sending limits (start with 200 emails/day, request increase)

**Configuration Options**:
- **Configuration Sets**: Track opens, clicks, bounces
- **Event Publishing**: Send events to CloudWatch, SNS, Kinesis
- **Dedicated IPs**: For high-volume senders (better reputation)

---

## 14. **What is AWS Systems Manager (SSM) and how can it help manage .NET applications on EC2?**

**Answer:**

**AWS Systems Manager (SSM)**:
- Centralized management of AWS resources
- Features: Parameter Store, Session Manager, Patch Manager, Run Command, State Manager

**Key Features for .NET Applications:**

1. **Parameter Store**:
   - Secure storage for configuration values
   - Supports: Plain text, SecureString (encrypted), StringList
   - Hierarchical organization (`/myapp/database/connectionstring`)
   - Versioning and change tracking

```csharp
// Install: AWSSDK.SimpleSystemsManagement

var ssmClient = new AmazonSimpleSystemsManagementClient();
var request = new GetParameterRequest
{
    Name = "/myapp/database/connectionstring",
    WithDecryption = true // For SecureString
};
var response = await ssmClient.GetParameterAsync(request);
var connectionString = response.Parameter.Value;
```

2. **Session Manager**:
   - Secure access to EC2 instances (no SSH/RDP needed)
   - No need for bastion hosts or open ports
   - Session logging and auditing
   - Access via AWS Console or CLI

3. **Run Command**:
   - Execute commands on EC2 instances remotely
   - Example: Restart .NET service, run health checks
   - No SSH access required
   - Command execution logging

4. **Patch Manager**:
   - Automate OS and application patching
   - Schedule maintenance windows
   - Patch compliance reporting
   - Example: Patch Windows Server, update .NET runtime

5. **State Manager**:
   - Maintain consistent configuration across instances
   - Example: Ensure .NET runtime is installed, configure IIS
   - Automated compliance checking

**Use Cases:**

1. **Configuration Management**:
   - Store database connection strings, API keys
   - Environment-specific parameters (`/prod/db/connection`, `/dev/db/connection`)
   - Rotate secrets automatically

2. **Remote Access**:
   - Access EC2 instances without bastion hosts
   - Secure, audited access
   - No open ports (22, 3389)

3. **Automated Tasks**:
   - Run deployment scripts
   - Execute health checks
   - Collect logs

4. **Compliance**:
   - Ensure all instances have required software
   - Track configuration drift
   - Generate compliance reports

**Best Practices**:
- Use Parameter Store for sensitive configuration (instead of environment variables)
- Enable Session Manager logging for audit trails
- Use Patch Manager for automated security updates
- Organize parameters hierarchically
- Use SecureString for sensitive values (encrypted at rest)

---

## 15. **Explain the difference between AWS Regions, Availability Zones, and Edge Locations. Why does this matter for .NET applications?**

**Answer:**

**AWS Regions**:
- **Definition**: Geographic areas with multiple data centers
- **Examples**: us-east-1 (N. Virginia), eu-west-1 (Ireland), ap-south-1 (Mumbai)
- **Characteristics**:
  - Completely isolated (separate accounts, billing)
  - Most services are region-specific
  - Data residency and compliance (GDPR, etc.)
  - Latency considerations (choose closest to users)
- **Use Case**: Deploy application in region closest to users

**Availability Zones (AZs)**:
- **Definition**: One or more discrete data centers within a region
- **Characteristics**:
  - Physically separated (different power, network, facilities)
  - Low latency between AZs (< 10ms typically)
  - High availability (deploy across multiple AZs)
  - Independent failure domains
- **Example**: us-east-1 has 6 AZs (us-east-1a, us-east-1b, etc.)
- **Use Case**: Multi-AZ deployment for high availability

**Edge Locations**:
- **Definition**: Data centers for CloudFront (CDN) and Route 53
- **Characteristics**:
  - Located in major cities worldwide (100+ locations)
  - Cache content closer to users
  - Reduce latency for static/dynamic content
  - Not for hosting applications
- **Use Case**: Serve static assets, API caching via CloudFront

**Why This Matters for .NET Applications:**

1. **Region Selection**:
   - **Latency**: Choose region closest to users
   - **Compliance**: Data residency requirements (GDPR → EU regions)
   - **Cost**: Pricing varies by region
   - **Service Availability**: Some services not available in all regions
   - **Example**: US-based users → us-east-1, EU users → eu-west-1

2. **Multi-AZ Deployment**:
   - **High Availability**: Deploy across 2+ AZs
   - **Disaster Recovery**: AZ failure doesn't take down application
   - **Example**: 
     ```
     ALB → EC2 instances in us-east-1a and us-east-1b
     RDS Multi-AZ → Primary in us-east-1a, Standby in us-east-1b
     ```

3. **Edge Locations**:
   - **Performance**: Serve static content from edge locations
   - **Cost**: Reduced bandwidth costs
   - **Example**: CloudFront serves Angular bundles from edge locations

**Architecture Example**:
```
Users (Global)
    ↓
CloudFront (Edge Locations - 100+ locations)
    ↓
ALB (Region: us-east-1, Multi-AZ: 1a, 1b, 1c)
    ↓
EC2/ECS (Multi-AZ deployment)
    ↓
RDS (Multi-AZ: Primary in 1a, Standby in 1b)
```

**Best Practices**:
- Deploy application in region closest to majority of users
- Always deploy across multiple AZs for production
- Use CloudFront for global content delivery
- Consider multi-region for disaster recovery (if required)
- Monitor latency metrics (CloudWatch, X-Ray)

**Cost Consideration**:
- Data transfer between regions: Charged
- Data transfer between AZs: Charged (but low latency)
- Data transfer to internet: Charged
- CloudFront: Reduces origin data transfer costs

