# Edlio-like Online School Platform - Interview Q&A

## Question 1: What are the tasks you have done in your projects? Give a few examples, not all.

### Answer Structure

When answering this question, structure your response using the **STAR method** (Situation, Task, Action, Result) and focus on **technical depth** and **business impact**. Here's how to answer for the OSP project:

---

### **Overview Response (30 seconds)**

"I worked on the Edlio-like Online School Platform, a multi-tenant SaaS microservices architecture. My key contributions included implementing the Identity & Access Service with JWT authentication, developing the Student Enrollment Service with event-driven workflows, integrating payment processing with external gateways, and implementing notification services with email and SMS capabilities. I used SQS Queue for asynchronous message processing and event-driven communication between microservices. I also worked on API Gateway configuration, database design following the database-per-service pattern, and implementing monitoring and logging solutions."

---

### **Detailed Examples (Pick 3-4 to elaborate)**

---

## **Example 1: Identity & Access Service Implementation**

### **Situation:**
The platform needed a centralized authentication and authorization system to serve three different user portals (Student, School Admin, Edlio Admin) with role-based access control.

### **Task:**
- Design and implement a secure Identity & Access microservice
- Implement JWT-based authentication
- Create role-based authorization system
- Handle multi-tenant user isolation

### **Actions Taken:**

1. **JWT Token Implementation**
   - Implemented JWT token generation with claims (userId, role, tenantId, permissions)
   - Created token refresh mechanism for security
   - Implemented token validation middleware in API Gateway
   - Added token expiration and revocation logic

2. **Authentication Endpoints**
   - Built login endpoint with credential validation
   - Implemented password hashing using bcrypt (salt rounds: 12)
   - Added rate limiting (5 attempts per 15 minutes) to prevent brute force attacks
   - Created password reset flow with secure token generation

3. **Role-Based Access Control (RBAC)**
   - Designed role hierarchy: SuperAdmin → SchoolAdmin → Student
   - Implemented permission-based authorization
   - Created middleware to validate user permissions per endpoint
   - Ensured tenant isolation (school admins can only access their school data)

4. **Database Design**
   - Used ASP.NET Core Identity with built-in tables (AspNetUsers, AspNetRoles, AspNetUserRoles, AspNetUserClaims, AspNetRoleClaims)
   - Extended IdentityUser with custom properties (TenantId, FirstName, LastName)
   - Created custom RefreshToken table for token management
   - Added indexes on email, tenantId for performance

5. **Security Features**
   - Implemented password complexity requirements
   - Added account lockout after failed attempts
   - Created audit logs for all authentication events
   - Implemented HTTPS-only cookie storage for tokens

### **Technologies Used:**
- ASP.NET Core Web API
- JWT Bearer Authentication
- Entity Framework Core
- SQL Server
- Redis (for token blacklisting)
- bcrypt for password hashing

### **Result:**
- Successfully authenticated 10,000+ concurrent users
- Reduced authentication latency to < 50ms
- Zero security breaches in production
- Enabled seamless single sign-on across all portals
- Achieved 99.9% uptime for authentication service


## **Example 2: Notification Service with Multi-Channel Delivery**

### **Situation:**
The platform needed to send notifications (email, SMS, push) to users for various events (enrollments, payments, reminders) without blocking core business processes.

### **Task:**
- Build Notification microservice
- Implement multi-channel notification delivery
- Create notification templates
- Ensure reliable delivery with retry logic
- Track notification delivery status

### **Actions Taken:**

1. **Multi-Channel Implementation**
   - Integrated email service using SendGrid API
   - Integrated SMS service using Twilio API
   - Implemented push notification service using Firebase Cloud Messaging
   - Created abstraction layer (INotificationChannel) for different channels

2. **Notification Template System**
   - Created template engine using Razor templates
   - Implemented template variables (student name, amount, date, etc.)
   - Built template management API for school admins
   - Added support for HTML and plain text emails

3. **Asynchronous Processing**
   - Implemented message queue (RabbitMQ) for notification requests
   - Created background workers to process notifications
   - Implemented priority queue (urgent notifications processed first)
   - Added batch processing for bulk notifications

4. **Notification Types Implemented**
   - Enrollment confirmation emails
   - Payment confirmation (email + SMS)
   - Fee due reminders (scheduled notifications)
   - Payment failure notifications
   - Activity registration confirmations
   - Enrollment status updates

5. **Reliability Features**
   - Implemented retry logic (3 retries with exponential backoff)
   - Created dead letter queue for failed notifications
   - Added notification delivery status tracking
   - Implemented notification preferences (users can opt-out)

6. **Database Design**
   - Created Notifications table for tracking
   - Created NotificationTemplates table
   - Created NotificationPreferences table
   - Added indexes on status, recipient, date

7. **Integration**
   - Subscribed to events from all services:
     - `EnrollmentCreated` → Send enrollment confirmation
     - `PaymentCompleted` → Send payment confirmation
     - `FeeDueReminder` → Send fee reminder
   - Integrated with Identity Service (get user contact info)

8. **Monitoring & Analytics**
   - Tracked notification delivery rates
   - Monitored email bounce rates
   - Tracked SMS delivery status
   - Created notification analytics dashboard

### **Technologies Used:**
- ASP.NET Core Web API
- SendGrid API (email)
- Twilio API (SMS)
- Firebase Cloud Messaging (push)
- RabbitMQ (message queue)
- Hangfire (background jobs)
- Entity Framework Core
- SQL Server

### **Result:**
- Sent 1 million+ notifications successfully
- Achieved 98% email delivery rate
- Achieved 99.5% SMS delivery rate
- Reduced notification processing time to < 100ms
- Enabled real-time notifications without blocking core services
- Successfully handled notification spikes during enrollment periods

---


## **Example 3: Database Design - Database per Service Pattern**

### **Situation:**
Each microservice needed its own database to ensure data isolation, independent scaling, and technology flexibility.

### **Task:**
- Design database schema for each microservice
- Implement database per service pattern
- Ensure data consistency across services
- Optimize queries and add indexes

### **Actions Taken:**

1. **Identity Service Database**
   - Used ASP.NET Core Identity tables:
     - AspNetUsers (extended with TenantId, FirstName, LastName)
     - AspNetRoles
     - AspNetUserRoles
     - AspNetUserClaims (for permissions)
     - AspNetRoleClaims
     - AspNetUserLogins
     - AspNetUserTokens
   - Custom RefreshToken table for refresh token management
   - Added indexes on email, tenantId
   - Implemented soft delete pattern using Identity's LockoutEnabled
   - Created audit tables for security events

2. **Student Enrollment Service Database**
   - Designed Enrollments, EnrollmentHistory tables
   - Added composite indexes on (studentId, activityId, status)
   - Implemented enrollment state tracking
   - Created views for enrollment analytics

3. **Payment Service Database**
   - Designed Payments, PaymentTransactions tables
   - Implemented encryption for sensitive fields
   - Added indexes on payment status, date, studentId
   - Created payment reconciliation tables

4. **Data Consistency Strategy**
   - Implemented eventual consistency using events
   - Created saga pattern for distributed transactions
   - Implemented idempotency for event processing
   - Added data synchronization jobs for reporting

5. **Performance Optimization**
   - Added appropriate indexes on foreign keys
   - Implemented database connection pooling
   - Created read replicas for reporting queries
   - Optimized queries using execution plans

6. **Migration Strategy**
   - Used Entity Framework Core migrations
   - Created migration scripts for each service
   - Implemented database versioning
   - Created rollback procedures

### **Technologies Used:**
- SQL Server
- Entity Framework Core
- Dapper (for performance-critical queries)
- Redis (for caching)

### **Result:**
- Achieved data isolation between services
- Enabled independent database scaling
- Reduced query response time by 40%
- Successfully handled 100,000+ records per service
- Zero data leakage between services

---

## **Example 4: SQS Queue Implementation for Event-Driven Communication**

### **Situation:**
The microservices architecture required asynchronous, reliable communication between services to handle events like enrollment creation, payment completion, order placement, and fee calculations. Synchronous HTTP calls were causing performance bottlenecks and tight coupling between services, leading to cascading failures during peak loads.

### **Task:**
- Implement AWS SQS for asynchronous message queuing
- Design event-driven communication patterns between microservices
- Ensure message reliability and delivery guarantees
- Implement dead letter queues for failed message handling
- Create message producers and consumers for event processing
- Handle message visibility timeouts and retry mechanisms

### **Actions Taken:**

1. **SQS Queue Setup and Configuration**
   - Created multiple SQS queues for different event types:
     - `enrollment-created-events` - For enrollment notifications
     - `payment-completed-events` - For payment processing events
     - `order-placed-events` - For order placement notifications
     - `fee-calculated-events` - For fee calculation updates
   - Configured queue attributes (visibility timeout, message retention, delivery delay)
   - Set up dead letter queues (DLQ) for each main queue to handle failed messages
   - Configured queue policies for secure access using IAM roles

2. **Message Producer Implementation**
   - Created SQS message publisher service using AWS SDK for .NET
   - Implemented event publishing pattern for microservices:
     - Enrollment Service publishes `EnrollmentCreated` events
     - Payment Service publishes `PaymentCompleted` events
     - Order Service publishes `OrderPlaced` events for order placement notifications
     - Fee Service publishes `FeeCalculated` events
   - Added message serialization (JSON format) with versioning
   - Implemented idempotency keys to prevent duplicate processing
   - Added message attributes for routing and filtering

3. **Message Consumer Implementation**
   - Built background workers using Hangfire/BackgroundService to poll SQS queues
   - Implemented message processing handlers for each event type:
     - Notification Service consumes enrollment, payment, and order-placed events
     - Reporting Service consumes all events for analytics
     - Email Service consumes notification events including order confirmation notifications
   - Created message deserialization with error handling
   - Implemented message acknowledgment (DeleteMessage) after successful processing

4. **Reliability and Error Handling**
   - Configured visibility timeout (30 seconds) to prevent message loss during processing
   - Implemented exponential backoff retry mechanism (3 retries)
   - Set up dead letter queues with max receive count (3 attempts)
   - Added message deduplication using message deduplication IDs
   - Implemented poison message detection and handling
   - Created monitoring and alerting for DLQ message counts

5. **Message Processing Patterns**
   - Implemented long polling (20 seconds) to reduce empty responses and costs
   - Created batch message processing (up to 10 messages per batch)
   - Added message filtering using SQS message attributes
   - Implemented priority queues for urgent events (payment failures)
   - Created message ordering for critical workflows using FIFO queues where needed

6. **Integration with Microservices**
   - Enrollment Service: Publishes events when enrollments are created/updated
   - Payment Service: Publishes events on payment success/failure
   - Order Service: Publishes `OrderPlaced` events when orders are placed, triggering order confirmation notifications via SQS
   - Notification Service: Consumes events (enrollment, payment, order-placed) and triggers email/SMS notifications
   - Reporting Service: Consumes all events for real-time analytics
   - Fee Calculation Service: Publishes fee calculation events

7. **Security and Access Control**
   - Configured IAM roles with least privilege access
   - Used IAM policies to restrict queue access per service
   - Implemented encryption at rest using AWS KMS
   - Added encryption in transit using HTTPS
   - Created VPC endpoints for private queue access

8. **Monitoring and Observability**
   - Integrated CloudWatch metrics for queue depth, message age
   - Set up CloudWatch alarms for DLQ message thresholds
   - Added logging for message processing (success/failure)
   - Created dashboards for queue health monitoring
   - Tracked message processing latency and throughput

### **Technologies Used:**
- AWS SQS (Simple Queue Service)
- AWS SDK for .NET Core
- Hangfire / BackgroundService (for message consumers)
- JSON.NET (for message serialization)
- AWS CloudWatch (for monitoring)
- AWS IAM (for access control)
- AWS KMS (for encryption)

### **Result:**
- **Technical Impact:**
  - Reduced service coupling by 80% through asynchronous communication
  - Improved system resilience - services continue operating even if one service is down
  - Achieved 99.9% message delivery reliability
  - Reduced API response times by 60% (from 500ms to 200ms) by offloading async tasks
  - Successfully processed 50,000+ messages per day during peak enrollment periods
  - Zero message loss with proper DLQ handling

- **Business Impact:**
  - Enabled real-time notifications without blocking core enrollment/payment flows
  - Improved user experience with faster response times
  - Reduced infrastructure costs by 30% through efficient async processing
  - Enabled horizontal scaling of services independently
  - Improved system availability from 99.5% to 99.9% through decoupled architecture
  - Supported business growth by handling 10x traffic spikes during enrollment periods

---

## **Complete Implementation Guide: Order-Placed-Events with SQS**

This section provides a comprehensive, step-by-step implementation guide for the `order-placed-events` flow, covering everything from AWS cloud setup to API-side implementation.

---

### **Part 1: Cloud-Side Setup (AWS Infrastructure)**

#### **Step 1: Create SQS Queue**

**1.1 Create Main Queue**

```bash
# Create the main order-placed-events queue
aws sqs create-queue \
  --queue-name order-placed-events \
  --attributes '{
    "VisibilityTimeout": "30",
    "MessageRetentionPeriod": "345600",
    "ReceiveMessageWaitTimeSeconds": "20",
    "DelaySeconds": "0"
  }'
```

**Explanation:**
- **VisibilityTimeout (30 seconds)**: Time a message is hidden after being received. If processing takes longer, message becomes visible again.
- **MessageRetentionPeriod (345600 = 4 days)**: How long messages stay in queue if not processed.
- **ReceiveMessageWaitTimeSeconds (20 seconds)**: Long polling - reduces empty responses and costs.
- **DelaySeconds (0)**: Delay before message becomes available (0 = immediate).

**1.2 Create Dead Letter Queue (DLQ)**

```bash
# Create DLQ for failed messages
aws sqs create-queue \
  --queue-name order-placed-events-dlq \
  --attributes '{
    "MessageRetentionPeriod": "1209600"
  }'
```

**Explanation:**
- DLQ stores messages that fail processing after max retries.
- Retention period: 14 days (1209600 seconds) for investigation.

**1.3 Configure DLQ Redrive Policy**

```bash
# Get queue URLs
MAIN_QUEUE_URL=$(aws sqs get-queue-url --queue-name order-placed-events --query 'QueueUrl' --output text)
DLQ_URL=$(aws sqs get-queue-url --queue-name order-placed-events-dlq --query 'QueueUrl' --output text)
DLQ_ARN=$(aws sqs get-queue-attributes --queue-url $DLQ_URL --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)

# Set redrive policy on main queue
aws sqs set-queue-attributes \
  --queue-url $MAIN_QUEUE_URL \
  --attributes "{
    \"RedrivePolicy\": \"{\\\"deadLetterTargetArn\\\":\\\"$DLQ_ARN\\\",\\\"maxReceiveCount\\\":3}\"
  }"
```

**Explanation:**
**What it does:** Connects the main queue to the Dead Letter Queue (DLQ).

**How it works:**
1. **Get queue info** → Fetch URLs and ARN of both queues
2. **Link them** → Tell main queue: "If a message fails 3 times, send it to DLQ"
3. **maxReceiveCount = 3** → Message gets 3 chances, then moves to DLQ automatically

**Why it's needed:** Prevents infinite retry loops. Failed messages go to DLQ for investigation instead of clogging the main queue.

---

#### **Step 2: IAM Roles and Policies**

**2.1 Create IAM Policy for Order Service (Producer)**

```bash
# Create policy for Order Service to send messages
cat > order-service-sqs-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl"
      ],
      "Resource": "arn:aws:sqs:us-east-1:ACCOUNT_ID:order-placed-events"
    }
  ]
}
EOF

aws iam create-policy \
  --policy-name OrderServiceSQSPolicy \
  --policy-document file://order-service-sqs-policy.json
```

**2.2 Create IAM Policy for Notification Service (Consumer)**

```bash
# Create policy for Notification Service to receive and delete messages
cat > notification-service-sqs-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ChangeMessageVisibility"
      ],
      "Resource": "arn:aws:sqs:us-east-1:ACCOUNT_ID:order-placed-events"
    }
  ]
}
EOF

aws iam create-policy \
  --policy-name NotificationServiceSQSPolicy \
  --policy-document file://notification-service-sqs-policy.json
```

**2.3 Attach Policies to IAM Roles**

```bash
# Attach to Order Service role (EC2/ECS/Lambda role)
aws iam attach-role-policy \
  --role-name OrderServiceRole \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/OrderServiceSQSPolicy

# Attach to Notification Service role
aws iam attach-role-policy \
  --role-name NotificationServiceRole \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/NotificationServiceSQSPolicy
```

**How to Create (Quick Steps):**

1. **Create Policy JSON File** → Write permissions in JSON format (what actions allowed)
2. **Create Policy in AWS** → `aws iam create-policy` creates the policy from JSON file
3. **Attach to Role** → `aws iam attach-role-policy` links policy to your service's IAM role

**Do Each Service Need IAM Role? Yes!**

**What is IAM Role?**
- An IAM role is an identity that your service uses to access AWS resources (like SQS)
- Each service running on AWS (EC2, ECS, Lambda, etc.) needs an IAM role

**How It Works:**
1. **Order Service** runs on EC2/ECS → Has `OrderServiceRole` → Can send messages to SQS
2. **Notification Service** runs on EC2/ECS → Has `NotificationServiceRole` → Can receive/delete messages from SQS

**Create Roles First (if not exists):**
```bash
# Create role for Order Service
aws iam create-role \
  --role-name OrderServiceRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Create role for Notification Service
aws iam create-role \
  --role-name NotificationServiceRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'
```

**Then attach policies to these roles** (as shown in step 2.3 above).

**What Each Service Gets:**
- **Order Service (Producer)**: Can `SendMessage` only (publishes events)
- **Notification Service (Consumer)**: Can `ReceiveMessage`, `DeleteMessage`, `ChangeMessageVisibility` (processes events)

**Why:** Security best practice - each service gets only the permissions it needs (least privilege principle).

---

#### **Step 3: CloudWatch Monitoring Setup**

**3.1 Create SNS Topic for Notifications (First Step)**

**What is SNS?** Simple Notification Service - sends alerts via email, SMS, Slack, etc.

```bash
# Create SNS topic for alerts
aws sns create-topic --name sqs-alerts-topic

# Get topic ARN (you'll need this)
SNS_TOPIC_ARN=$(aws sns list-topics --query 'Topics[?contains(TopicArn, `sqs-alerts-topic`)].TopicArn' --output text)

# Subscribe email to topic (you'll receive confirmation email - click link to confirm)
aws sns subscribe \
  --topic-arn $SNS_TOPIC_ARN \
  --protocol email \
  --notification-endpoint your-email@example.com

# Or subscribe phone number for SMS
aws sns subscribe \
  --topic-arn $SNS_TOPIC_ARN \
  --protocol sms \
  --notification-endpoint +1234567890
```

**3.2 Create CloudWatch Alarms with Notifications**

```bash
# Alarm for queue depth (too many messages waiting)
aws cloudwatch put-metric-alarm \
  --alarm-name order-placed-events-queue-depth \
  --alarm-description "Alert when queue has too many messages" \
  --metric-name ApproximateNumberOfMessagesVisible \
  --namespace AWS/SQS \
  --statistic Average \
  --period 300 \
  --threshold 1000 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --dimensions Name=QueueName,Value=order-placed-events \
  --alarm-actions $SNS_TOPIC_ARN \
  --ok-actions $SNS_TOPIC_ARN

# Alarm for DLQ messages (failed processing)
aws cloudwatch put-metric-alarm \
  --alarm-name order-placed-events-dlq-messages \
  --alarm-description "Alert when messages are in DLQ" \
  --metric-name ApproximateNumberOfMessagesVisible \
  --namespace AWS/SQS \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --dimensions Name=QueueName,Value=order-placed-events-dlq \
  --alarm-actions $SNS_TOPIC_ARN \
  --ok-actions $SNS_TOPIC_ARN
```

**Explanation:**
- **Step 1**: Create SNS topic (channel for notifications)
- **Step 2**: Subscribe your email/phone to topic (where to send alerts)
- **Step 3**: Add `--alarm-actions $SNS_TOPIC_ARN` to alarms (sends alert when alarm triggers)
- **Step 4**: Add `--ok-actions $SNS_TOPIC_ARN` (sends notification when alarm recovers)

**What You'll Receive:**
- **Email/SMS** when queue depth > 1000 messages (slow processing)
- **Email/SMS** when any message in DLQ (processing failure)
- **Email/SMS** when issues resolve (alarm returns to OK state)

**3.3 Create CloudWatch Dashboard**

```bash
# Create dashboard JSON
cat > sqs-dashboard.json <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/SQS", "ApproximateNumberOfMessagesVisible", {"stat": "Average", "label": "Queue Depth"}],
          [".", "ApproximateNumberOfMessagesNotVisible", {"stat": "Average", "label": "In Flight"}],
          [".", "NumberOfMessagesSent", {"stat": "Sum", "label": "Messages Sent"}],
          [".", "NumberOfMessagesReceived", {"stat": "Sum", "label": "Messages Received"}]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Order Placed Events Queue Metrics"
      }
    }
  ]
}
EOF

aws cloudwatch put-dashboard \
  --dashboard-name OrderPlacedEventsQueue \
  --dashboard-body file://sqs-dashboard.json
```

**What's Happening Here:**

**What is a Dashboard?**
- A visual dashboard in AWS CloudWatch showing queue metrics in graphs/charts
- Like a monitoring screen you can view anytime

**What Metrics Are Tracked?**
1. **Queue Depth** → How many messages waiting in queue
2. **In Flight** → How many messages currently being processed
3. **Messages Sent** → Total messages published to queue
4. **Messages Received** → Total messages consumed from queue

**How to View:**
- Go to AWS Console → CloudWatch → Dashboards → "OrderPlacedEventsQueue"
- See real-time graphs of your queue performance

**Why It's Useful:**
- Monitor queue health at a glance
- Spot bottlenecks (high queue depth = slow processing)
- Track message flow (sent vs received)
- No need to check individual metrics - everything in one place

---

#### **Step 4: Enable Encryption (Optional but Recommended)**

```bash
# Create KMS key for SQS encryption
aws kms create-key \
  --description "SQS encryption key for order-placed-events" \
  --key-usage ENCRYPT_DECRYPT

# Get key ID
KMS_KEY_ID=$(aws kms list-keys --query 'Keys[0].KeyId' --output text)

# Enable encryption on queue
aws sqs set-queue-attributes \
  --queue-url $MAIN_QUEUE_URL \
  --attributes "{
    \"KmsMasterKeyId\": \"$KMS_KEY_ID\",
    \"KmsDataKeyReusePeriodSeconds\": \"300\"
  }"
```

**Explanation:**
- Encrypts messages at rest using AWS KMS.
- Protects sensitive order data.

---

### **Part 2: API-Side Implementation - Order Service (Producer)**

#### **Step 1: Install Required NuGet Packages**

```bash
# In Order Service project
dotnet add package AWSSDK.SQS
dotnet add package Newtonsoft.Json
dotnet add package Microsoft.Extensions.Configuration
dotnet add package Microsoft.Extensions.Configuration.AWS
```

#### **Step 2: Configure AWS SQS in appsettings.json**

```json
{
  "AWS": {
    "Region": "us-east-1",
    "SQS": {
      "OrderPlacedQueueUrl": "https://sqs.us-east-1.amazonaws.com/ACCOUNT_ID/order-placed-events"
    }
  }
}
```

#### **Step 3: Create Message Model**

```csharp
// Models/OrderPlacedEvent.cs
namespace OrderService.Models
{
    public class OrderPlacedEvent
    {
        public string OrderId { get; set; }
        public string StudentId { get; set; }
        public string SchoolId { get; set; }
        public decimal TotalAmount { get; set; }
        public string Currency { get; set; }
        public List<OrderItem> Items { get; set; }
        public DateTime PlacedAt { get; set; }
        public string EventVersion { get; set; } = "1.0";
        public string EventId { get; set; } // For idempotency
    }

    public class OrderItem
    {
        public string ItemId { get; set; }
        public string ItemName { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
    }
}
```

#### **Step 4: Create SQS Message Publisher Service**

```csharp
// Services/ISqsMessagePublisher.cs
using OrderService.Models;

namespace OrderService.Services
{
    public interface ISqsMessagePublisher
    {
        Task<bool> PublishOrderPlacedEventAsync(OrderPlacedEvent orderEvent);
    }
}

// Services/SqsMessagePublisher.cs
using Amazon.SQS;
using Amazon.SQS.Model;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using OrderService.Models;
using System;
using System.Threading.Tasks;

namespace OrderService.Services
{
    public class SqsMessagePublisher : ISqsMessagePublisher
    {
        private readonly IAmazonSQS _sqsClient;
        private readonly string _queueUrl;
        private readonly ILogger<SqsMessagePublisher> _logger;

        public SqsMessagePublisher(
            IAmazonSQS sqsClient,
            IConfiguration configuration,
            ILogger<SqsMessagePublisher> logger)
        {
            _sqsClient = sqsClient;
            _queueUrl = configuration["AWS:SQS:OrderPlacedQueueUrl"];
            _logger = logger;
        }

        public async Task<bool> PublishOrderPlacedEventAsync(OrderPlacedEvent orderEvent)
        {
            try
            {
                // Generate unique event ID for idempotency
                orderEvent.EventId = Guid.NewGuid().ToString();

                // Serialize message body
                var messageBody = JsonConvert.SerializeObject(orderEvent);

                // Create message attributes for filtering/routing
                var messageAttributes = new Dictionary<string, MessageAttributeValue>
                {
                    ["EventType"] = new MessageAttributeValue
                    {
                        DataType = "String",
                        StringValue = "OrderPlaced"
                    },
                    ["SchoolId"] = new MessageAttributeValue
                    {
                        DataType = "String",
                        StringValue = orderEvent.SchoolId
                    },
                    ["EventVersion"] = new MessageAttributeValue
                    {
                        DataType = "String",
                        StringValue = orderEvent.EventVersion
                    }
                };

                // Create send message request
                var request = new SendMessageRequest
                {
                    QueueUrl = _queueUrl,
                    MessageBody = messageBody,
                    MessageAttributes = messageAttributes,
                    MessageDeduplicationId = orderEvent.EventId, // For FIFO queues
                    MessageGroupId = orderEvent.SchoolId // For FIFO queues (group by school)
                };

                // Send message
                var response = await _sqsClient.SendMessageAsync(request);

                _logger.LogInformation(
                    "Order placed event published. OrderId: {OrderId}, MessageId: {MessageId}",
                    orderEvent.OrderId,
                    response.MessageId);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Failed to publish order placed event. OrderId: {OrderId}",
                    orderEvent.OrderId);
                return false;
            }
        }
    }
}
```

#### **Step 5: Register Services in Startup/Program.cs**

```csharp
// Program.cs or Startup.cs
using Amazon.SQS;
using OrderService.Services;

var builder = WebApplication.CreateBuilder(args);

// Add AWS SQS client
builder.Services.AddAWSService<IAmazonSQS>();

// Register message publisher
builder.Services.AddScoped<ISqsMessagePublisher, SqsMessagePublisher>();

// ... rest of configuration
```

#### **Step 6: Integrate in Order Controller/Service**

```csharp
// Controllers/OrdersController.cs
using Microsoft.AspNetCore.Mvc;
using OrderService.Models;
using OrderService.Services;

namespace OrderService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : ControllerBase
    {
        private readonly IOrderService _orderService;
        private readonly ISqsMessagePublisher _messagePublisher;
        private readonly ILogger<OrdersController> _logger;

        public OrdersController(
            IOrderService orderService,
            ISqsMessagePublisher messagePublisher,
            ILogger<OrdersController> logger)
        {
            _orderService = orderService;
            _messagePublisher = messagePublisher;
            _logger = logger;
        }

        [HttpPost]
        public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request)
        {
            try
            {
                // 1. Create order in database
                var order = await _orderService.CreateOrderAsync(request);

                // 2. Publish event to SQS (fire and forget - don't block response)
                _ = Task.Run(async () =>
                {
                    try
                    {
                        var orderEvent = new OrderPlacedEvent
                        {
                            OrderId = order.Id,
                            StudentId = order.StudentId,
                            SchoolId = order.SchoolId,
                            TotalAmount = order.TotalAmount,
                            Currency = order.Currency,
                            Items = order.Items.Select(i => new OrderItem
                            {
                                ItemId = i.Id,
                                ItemName = i.Name,
                                Quantity = i.Quantity,
                                Price = i.Price
                            }).ToList(),
                            PlacedAt = order.CreatedAt
                        };

                        await _messagePublisher.PublishOrderPlacedEventAsync(orderEvent);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to publish order placed event for OrderId: {OrderId}", order.Id);
                        // Consider storing in outbox pattern for retry
                    }
                });

                return Ok(new { OrderId = order.Id, Status = "Created" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create order");
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
```

**Explanation:**
- Order creation happens synchronously.
- Event publishing happens asynchronously (fire-and-forget) to not block the API response.
- If publishing fails, log error (consider outbox pattern for guaranteed delivery).

---

### **Part 3: API-Side Implementation - Notification Service (Consumer)**

#### **Step 1: Install Required Packages**

```bash
dotnet add package AWSSDK.SQS
dotnet add package Newtonsoft.Json
dotnet add package Microsoft.Extensions.Hosting
```

#### **Step 2: Create Background Worker Service**

```csharp
// Services/OrderPlacedEventConsumer.cs
using Amazon.SQS;
using Amazon.SQS.Model;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using NotificationService.Models;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace NotificationService.Services
{
    public class OrderPlacedEventConsumer : BackgroundService
    {
        private readonly IAmazonSQS _sqsClient;
        private readonly string _queueUrl;
        private readonly INotificationService _notificationService;
        private readonly ILogger<OrderPlacedEventConsumer> _logger;
        // AWS SQS supports long polling to reduce latency and costs.
        // "LongPollingWaitTime" specifies how many seconds the consumer waits on SQS for new messages before returning.
        // A value of 20 seconds (the maximum allowed) means the consumer will "block" up to 20 seconds per request,
        // reducing empty responses and minimizing unnecessary API calls.
        private const int LongPollingWaitTime = 20; // seconds
        // MaxMessagesPerBatch defines how many SQS messages are fetched in one batch-polling request.
        // AWS SQS allows up to 10 messages per call, which improves efficiency by reducing the number of requests made for high-throughput scenarios.
        private const int MaxMessagesPerBatch = 10;

        public OrderPlacedEventConsumer(
            IAmazonSQS sqsClient,
            IConfiguration configuration,
            INotificationService notificationService,
            ILogger<OrderPlacedEventConsumer> logger)
        {
            _sqsClient = sqsClient;
            _queueUrl = configuration["AWS:SQS:OrderPlacedQueueUrl"];
            _notificationService = notificationService;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("OrderPlacedEventConsumer started");

            // What is "stoppingToken"? 
            // It is a CancellationToken provided by the .NET Generic Host infrastructure to signal when the background service should gracefully stop (e.g., during application shutdown).
            // The loop continues running until "stoppingToken.IsCancellationRequested" becomes true, at which point the background service begins shutdown.
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessMessagesAsync(stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error in OrderPlacedEventConsumer");
                    // Wait before retrying
                    await Task.Delay(5000, stoppingToken);
                }
            }
        }

        private async Task ProcessMessagesAsync(CancellationToken cancellationToken)
        {
            // Receive messages with long polling
            var receiveRequest = new ReceiveMessageRequest
            {
                QueueUrl = _queueUrl,
                MaxNumberOfMessages = MaxMessagesPerBatch,
                WaitTimeSeconds = LongPollingWaitTime,
                MessageAttributeNames = new List<string> { "All" }
            };

            var response = await _sqsClient.ReceiveMessageAsync(receiveRequest, cancellationToken);

            if (response.Messages == null || response.Messages.Count == 0)
            {
                // No messages, continue polling
                return;
            }

            _logger.LogInformation("Received {Count} messages from queue", response.Messages.Count);

            // Process each message
            foreach (var message in response.Messages)
            {
                try
                {
                    await ProcessMessageAsync(message, cancellationToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex,
                        "Failed to process message. MessageId: {MessageId}, ReceiptHandle: {ReceiptHandle}",
                        message.MessageId,
                        message.ReceiptHandle);

                    // Message will become visible again after visibility timeout
                    // If it fails 3 times, it will go to DLQ
                }
            }
        }

        private async Task ProcessMessageAsync(Message message, CancellationToken cancellationToken)
        {
            try
            {
                // Deserialize message
                var orderEvent = JsonConvert.DeserializeObject<OrderPlacedEvent>(message.Body);

                if (orderEvent == null)
                {
                    _logger.LogWarning("Failed to deserialize message. MessageId: {MessageId}", message.MessageId);
                    // Delete invalid message to prevent reprocessing
                    await DeleteMessageAsync(message.ReceiptHandle);
                    return;
                }

                _logger.LogInformation(
                    "Processing order placed event. OrderId: {OrderId}, StudentId: {StudentId}",
                    orderEvent.OrderId,
                    orderEvent.StudentId);

                // Process the event - send notification
                await _notificationService.SendOrderConfirmationNotificationAsync(
                    orderEvent.StudentId,
                    orderEvent.OrderId,
                    orderEvent.TotalAmount,
                    orderEvent.Items);

                // Delete message after successful processing
                await DeleteMessageAsync(message.ReceiptHandle);

                _logger.LogInformation(
                    "Successfully processed order placed event. OrderId: {OrderId}",
                    orderEvent.OrderId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error processing message. MessageId: {MessageId}",
                    message.MessageId);

                // Don't delete message - let it become visible again for retry
                // After maxReceiveCount (3), it will go to DLQ
                throw;
            }
        }

        private async Task DeleteMessageAsync(string receiptHandle)
        {
            try
            {
                var deleteRequest = new DeleteMessageRequest
                {
                    QueueUrl = _queueUrl,
                    ReceiptHandle = receiptHandle
                };

                await _sqsClient.DeleteMessageAsync(deleteRequest);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to delete message. ReceiptHandle: {ReceiptHandle}", receiptHandle);
                throw;
            }
        }
    }
}
```

#### **Step 3: Create OrderPlacedEvent Model**

```csharp
// Models/OrderPlacedEvent.cs
namespace NotificationService.Models
{
    public class OrderPlacedEvent
    {
        public string OrderId { get; set; }
        public string StudentId { get; set; }
        public string SchoolId { get; set; }
        public decimal TotalAmount { get; set; }
        public string Currency { get; set; }
        public List<OrderItem> Items { get; set; }
        public DateTime PlacedAt { get; set; }
        public string EventVersion { get; set; }
        public string EventId { get; set; }
    }

    public class OrderItem
    {
        public string ItemId { get; set; }
        public string ItemName { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
    }
}
```

#### **Step 4: Implement Notification Service Method**

```csharp
// Services/INotificationService.cs (add method)
Task SendOrderConfirmationNotificationAsync(
    string studentId,
    string orderId,
    decimal totalAmount,
    List<OrderItem> items);

// Services/NotificationService.cs (implement method)
public async Task SendOrderConfirmationNotificationAsync(
    string studentId,
    string orderId,
    decimal totalAmount,
    List<OrderItem> items)
{
    // Get student email from Identity Service
    var student = await _identityService.GetStudentAsync(studentId);

    // Create email template
    var emailBody = $@"
        <h2>Order Confirmation</h2>
        <p>Dear {student.Name},</p>
        <p>Your order has been placed successfully!</p>
        <p><strong>Order ID:</strong> {orderId}</p>
        <p><strong>Total Amount:</strong> ${totalAmount}</p>
        <h3>Order Items:</h3>
        <ul>
            {string.Join("", items.Select(i => $"<li>{i.ItemName} x {i.Quantity} - ${i.Price * i.Quantity}</li>"))}
        </ul>
        <p>Thank you for your order!</p>
    ";

    // There are several ways to send email in .NET applications:
    // 1. SMTP: Using SmtpClient to send emails via an SMTP server (e.g., Gmail, Office365, SendGrid SMTP)
    // 2. Third-party email delivery services via APIs:
    //    - SendGrid (official SendGrid API client)
    //    - Amazon SES (using AWS SDK for .NET)
    //    - Mailgun (HTTP API clients)
    // 3. Email microservice: Centralize email sending logic in an internal or external microservice.
    // 4. Azure Communication Services or other cloud-native messaging.
    // 5. Using background jobs (e.g., Hangfire) to queue/schedule email delivery.
    //
    // In this application, email sending is abstracted behind IEmailService.
    // It can be implemented using any of the above techniques, e.g.:
    // Here we use SMTP via the .NET SmtpClient class to send the email.
    // In a production app, SmtpClient could be injected/configured as part of IEmailService,
    // but here's what the SMTP logic could look like explicitly:

    using (var smtpClient = new SmtpClient("smtp.yoursmtpserver.com")
    {
        Port = 587, // common SMTP port; adjust as needed
        Credentials = new NetworkCredential("your_username", "your_password"),
        EnableSsl = true
    })
    {
        var mailMessage = new MailMessage
        {
            From = new MailAddress("noreply@yourdomain.com"),
            Subject = $"Order Confirmation - {orderId}",
            Body = emailBody,
            IsBodyHtml = true
        };
        mailMessage.To.Add(student.Email);

        await smtpClient.SendMailAsync(mailMessage);
    }
}
```

#### **Step 5: Register Background Service**

```csharp
// Program.cs
using NotificationService.Services;

var builder = WebApplication.CreateBuilder(args);

// Add AWS SQS client
builder.Services.AddAWSService<IAmazonSQS>();

// Register background worker
builder.Services.AddHostedService<OrderPlacedEventConsumer>();

// Register notification service
builder.Services.AddScoped<INotificationService, NotificationService>();

// ... rest of configuration
```

---

### **Part 4: Error Handling and Resilience**

#### **4.1 Implement Idempotency**

```csharp
// In Notification Service - check if already processed
public async Task<bool> IsEventProcessedAsync(string eventId)
{
    // Check in database/cache if event already processed
    return await _eventRepository.ExistsAsync(eventId);
}

// Before processing
if (await IsEventProcessedAsync(orderEvent.EventId))
{
    _logger.LogWarning("Event already processed. EventId: {EventId}", orderEvent.EventId);
    await DeleteMessageAsync(message.ReceiptHandle);
    return;
}
```

#### **4.2 Handle Visibility Timeout Extension**

```csharp
// If processing takes longer than visibility timeout, extend it
if (processingTime > 30) // seconds
{
    var extendRequest = new ChangeMessageVisibilityRequest
    {
        QueueUrl = _queueUrl,
        ReceiptHandle = message.ReceiptHandle,
        VisibilityTimeout = 60 // Extend to 60 seconds
    };
    await _sqsClient.ChangeMessageVisibilityAsync(extendRequest);
}
```

#### **4.3 Monitor DLQ and Handle Failed Messages**

> 💡 **What a real-time dev team will do here:**
>
> - **Implement a background service** that continuously polls the Dead Letter Queue (DLQ) for failed messages.
> - When a message is found in the DLQ:
>     - Parse and log the error details (including stack trace and context).
>     - Push detailed error notifications/alerts to the monitoring system (e.g., Slack, PagerDuty, email).
>     - Store failed messages and processing metadata for root-cause analysis (often in a database or monitoring dashboard).
> - For certain recoverable failures, the team can provide a UI or script to retry failed messages after the issue is fixed.
> - Set up dashboards and automated runbooks for the support team to investigate and resolve recurring issues.
>
> *Example skeleton:*

```csharp
public class DlqMessageProcessor : BackgroundService
{
    private readonly IAmazonSQS _sqsClient;
    private readonly ILogger<DlqMessageProcessor> _logger;
    private readonly IAlertService _alertService;
    private readonly string _dlqUrl;

    public DlqMessageProcessor(IAmazonSQS sqsClient, ILogger<DlqMessageProcessor> logger, IAlertService alertService, IConfiguration config)
    {
        _sqsClient = sqsClient;
        _logger = logger;
        _alertService = alertService;
        _dlqUrl = config["AWS:SQS:DLQUrl"];
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var messages = await _sqsClient.ReceiveMessageAsync(new ReceiveMessageRequest
            {
                QueueUrl = _dlqUrl,
                MaxNumberOfMessages = 10,
                WaitTimeSeconds = 10
            }, stoppingToken);

            foreach (var message in messages.Messages)
            {
                try
                {
                    // Log message information
                    _logger.LogError("DLQ Message: {Body}", message.Body);

                    // Send alert to on-call/support/dev team
                    await _alertService.SendAlertAsync($"DLQ message detected: {message.Body}");

                    // Store/mark for later investigation (optionally implement a retry mechanism here)
                }
                catch (Exception ex)
                {
                    _logger.LogCritical(ex, "Error processing DLQ message");
                }
                finally
                {
                    // Remove message from DLQ to avoid reprocessing
                    await _sqsClient.DeleteMessageAsync(_dlqUrl, message.ReceiptHandle, stoppingToken);
                }
            }

            await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
        }
    }
}
```


---

### **Part 5: Testing**

#### **5.1 Unit Test - Message Publisher**

```csharp
[Fact]
public async Task PublishOrderPlacedEventAsync_ShouldSendMessageToSQS()
{
    // Arrange
    var mockSqs = new Mock<IAmazonSQS>();
    var mockConfig = new Mock<IConfiguration>();
    mockConfig.Setup(c => c["AWS:SQS:OrderPlacedQueueUrl"]).Returns("test-queue-url");

    var publisher = new SqsMessagePublisher(mockSqs.Object, mockConfig.Object, _logger);

    var orderEvent = new OrderPlacedEvent
    {
        OrderId = "123",
        StudentId = "student-1",
        TotalAmount = 100.00m
    };

    // Act
    var result = await publisher.PublishOrderPlacedEventAsync(orderEvent);

    // Assert
    Assert.True(result);
    mockSqs.Verify(s => s.SendMessageAsync(
        It.IsAny<SendMessageRequest>(),
        It.IsAny<CancellationToken>()), Times.Once);
}
```

#### **5.2 Integration Test - End-to-End Flow**

```csharp
[Fact]
public async Task OrderPlaced_ShouldTriggerNotification()
{
    // 1. Create order via API
    var orderResponse = await _client.PostAsync("/api/orders", orderJson);

    // 2. Wait for message processing
    await Task.Delay(5000);

    // 3. Verify notification sent
    _emailServiceMock.Verify(e => e.SendEmailAsync(
        It.IsAny<string>(),
        It.Is<string>(s => s.Contains("Order Confirmation")),
        It.IsAny<string>()), Times.Once);
}
```

---

### **Part 6: Monitoring and Observability**

#### **6.1 Add Logging**

```csharp
_logger.LogInformation(
    "Order placed event processed. OrderId: {OrderId}, ProcessingTime: {ProcessingTime}ms",
    orderEvent.OrderId,
    stopwatch.ElapsedMilliseconds);
```

#### **6.2 Add Metrics**

```csharp
// Track metrics
// These two lines collect metrics related to order processing events:
// 1. The first line increments a counter every time an order placed event is processed, allowing you to track the total number of such events handled by the system.
// 2. The second line records the time taken to process each order event (in milliseconds) in a histogram, which helps analyze the distribution of processing durations and identify performance trends or bottlenecks.

_metrics.IncrementCounter("order_placed_events_processed");
_metrics.RecordHistogram("order_processing_time", stopwatch.ElapsedMilliseconds);
```

#### **6.3 CloudWatch Logs Integration**

```csharp
// Configure Serilog or similar to send logs to CloudWatch
builder.Host.UseSerilog((context, config) =>
{
    config.WriteTo.Console()
          .WriteTo.AmazonCloudWatch(new CloudWatchSinkOptions
          {
              LogGroupName = "/aws/notification-service",
              LogStreamName = "order-placed-events"
          });
});
```

---

### **Summary: Complete Flow**

1. **Order Created** → Order Service creates order in database
2. **Event Published** → Order Service publishes `OrderPlacedEvent` to SQS queue
3. **Message Queued** → SQS stores message with attributes
4. **Consumer Polls** → Notification Service background worker polls queue (long polling)
5. **Message Received** → Notification Service receives message(s)
6. **Event Processed** → Notification Service deserializes and processes event
7. **Notification Sent** → Email/SMS sent to student
8. **Message Deleted** → Message deleted from queue after successful processing
9. **Failure Handling** → If processing fails, message becomes visible again (retry)
10. **DLQ Processing** → After 3 failures, message moves to DLQ for investigation

---

## **How to Present in Interview**

### **Opening (10-15 seconds):**
"I worked on an Edlio-like Online School Platform built with microservices architecture. Let me share a few key tasks I handled."

### **Pick 3-4 Examples:**
1. **Identity & Access Service** - Shows security expertise
2. **Student Enrollment with Events** - Shows event-driven architecture knowledge
3. **Payment Integration** - Shows external integration and compliance
4. **Notification Service** - Shows async processing and multi-channel delivery
5. **SQS Queue Implementation** - Shows AWS cloud services, event-driven architecture, and system decoupling

### **For Each Example, Cover:**
- **What** you did (technical implementation)
- **Why** you did it (business requirement/technical decision)
- **How** you did it (technologies, patterns, approach)
- **Result** (metrics, impact, success)

### **Closing (10 seconds):**
"These implementations helped us achieve high scalability, maintainability, and reliability. The system successfully handles thousands of concurrent users and processes millions of transactions."

---

## **Key Points to Emphasize**

1. **Microservices Patterns**: Database per service, API Gateway, Event-driven
2. **Security**: JWT, RBAC, PCI-DSS compliance, encryption
3. **Integration**: External APIs (Stripe, PayPal, SendGrid, Twilio)
4. **Resilience**: Retry logic, circuit breakers, fallback mechanisms
5. **Performance**: Caching, indexing, async processing
6. **Monitoring**: Logging, metrics, tracing
7. **Scalability**: Independent scaling, load balancing, message queues

---

## **Common Follow-up Questions**

After answering this question, be prepared for:

1. **"Can you explain the event-driven architecture in more detail?"**
   - Explain the message bus, event publishing, event subscriptions
   - Discuss eventual consistency
   - Mention saga pattern for distributed transactions

2. **"How did you handle data consistency across services?"**
   - Eventual consistency approach
   - Saga pattern for distributed transactions
   - Compensation logic for rollbacks

3. **"What challenges did you face and how did you overcome them?"**
   - Service communication failures → Circuit breaker pattern
   - Payment gateway downtime → Fallback mechanism
   - High notification volume → Async processing with queues

4. **"How did you ensure security in the payment service?"**
   - PCI-DSS compliance measures
   - Tokenization
   - Encryption at rest and in transit
   - Audit logging

5. **"How did you monitor and debug issues in production?"**
   - Application Insights / CloudWatch
   - Distributed tracing with correlation IDs
   - Centralized logging (ELK stack)
   - Custom metrics and dashboards

---

## **Tips for Answering**

1. **Be Specific**: Use actual numbers, technologies, and patterns
2. **Show Impact**: Mention metrics, performance improvements, business value
3. **Demonstrate Learning**: Mention challenges faced and how you solved them
4. **Stay Relevant**: Focus on tasks that match the job requirements
5. **Be Honest**: Don't exaggerate; be ready to dive deep into any example
6. **Time Management**: Keep each example to 1-2 minutes
7. **Show Collaboration**: Mention working with team members if relevant


---

## **Remember**

- **Quality over Quantity**: Better to explain 3-4 tasks in detail than list 10 tasks superficially
- **Technical Depth**: Show you understand the "why" behind decisions, not just the "what"
- **Business Impact**: Connect technical work to business outcomes
- **Be Ready to Deep Dive**: Interviewer may ask detailed questions about any task you mention

---

## Question 2: Explain JWT Token, Refresh Token, Authentication, and Authorization - Full Flow

### Overview

This section provides a comprehensive explanation of JWT-based authentication and authorization system using **ASP.NET Core Identity**, including the complete flow, implementation details, and common interview questions.

**Why ASP.NET Core Identity?**
- Built-in user and role management
- Password hashing and security features
- Account lockout protection
- Email confirmation support
- Two-factor authentication (2FA)
- External login providers support
- Token providers for password reset, email confirmation
- Reduces custom code and security vulnerabilities
- Industry-standard implementation

---

## Part 1: Full Flow Explanation

### Authentication & Authorization Flow Diagram

```
┌─────────────┐         ┌──────────────┐         ┌─────────────────┐
│   Client    │         │  API Gateway │         │ Identity Service│
│  (Portal)   │         │              │         │                 │
└──────┬──────┘         └──────┬───────┘         └────────┬────────┘
       │                        │                          │
       │  1. Login Request      │                          │
       │  (username, password)  │                          │
       │───────────────────────>│                          │
       │                        │                          │
       │                        │  2. Forward to           │
       │                        │     Identity Service     │
       │                        │─────────────────────────>│
       │                        │                          │
       │                        │                          │  3. Validate Credentials
       │                        │                          │     - Check username/password
       │                        │                          │     - Verify user status
       │                        │                          │     - Get user roles/permissions
       │                        │                          │
       │                        │  4. Return JWT Tokens    │
       │                        │     - Access Token       │
       │                        │     - Refresh Token      │
       │                        │<─────────────────────────│
       │                        │                          │
       │  5. Return Tokens      │                          │
       │     to Client          │                          │
       │<───────────────────────│                          │
       │                        │                          │
       │  6. Store Tokens       │                          │
       │     (httpOnly cookie   │                          │
       │      or localStorage)  │                          │
       │                        │                          │
       │                        │                          │
       │  7. API Request        │                          │
       │     + Access Token     │                          │
       │     (Bearer token)     │                          │
       │───────────────────────>│                          │
       │                        │                          │
       │                        │  8. Validate Token      │
       │                        │     - Check signature   │
       │                        │     - Check expiration  │
       │                        │     - Extract claims     │
       │                        │                          │
       │                        │  9. Check Authorization  │
       │                        │     - Verify role        │
       │                        │     - Check permissions  │
       │                        │     - Validate tenant   │
       │                        │                          │
       │                        │  10. Forward Request    │
       │                        │      to Microservice     │
       │                        │─────────────────────────>│
       │                        │                          │
       │                        │  11. Return Response     │
       │                        │<─────────────────────────│
       │                        │                          │
       │  12. Return Response   │                          │
       │<───────────────────────│                          │
       │                        │                          │
       │                        │                          │
       │  13. Access Token      │                          │
       │      Expired (401)     │                          │
       │<───────────────────────│                          │
       │                        │                          │
       │  14. Refresh Token     │                          │
       │      Request           │                          │
       │───────────────────────>│                          │
       │                        │                          │
       │                        │  15. Validate Refresh   │
       │                        │      Token               │
       │                        │─────────────────────────>│
       │                        │                          │
       │                        │  16. Generate New       │
       │                        │      Access Token        │
       │                        │<─────────────────────────│
       │                        │                          │
       │  17. New Access Token  │                          │
       │<───────────────────────│                          │
       │                        │                          │
```

---

### Step-by-Step Flow Explanation

#### **Phase 1: Initial Authentication (Login)**

**Step 1: User Login Request**
- Client sends login request with `username` and `password`
- Request goes through API Gateway
- API Gateway forwards to Identity & Access Service

**Step 2: Credential Validation**
- Identity Service receives credentials
- Validates username exists in database
- Hashes provided password and compares with stored hash (bcrypt)
- Checks user status (active, locked, suspended)
- Retrieves user roles and permissions from database

**Step 3: Token Generation**
- If credentials are valid:
  - Generate **Access Token** (JWT) - short-lived (15-30 minutes)
  - Generate **Refresh Token** - long-lived (7-30 days)
  - Store refresh token in database (for revocation)
  - Return both tokens to client

**Step 4: Token Storage**
- Client receives tokens
- **Access Token**: Stored in memory or localStorage (for SPA)
- **Refresh Token**: Stored in httpOnly cookie (more secure) or localStorage
- Access token included in Authorization header for subsequent requests

---

#### **Phase 2: Authenticated API Requests**

**Step 5: API Request with Access Token**
- Client makes API request to any microservice
- Includes Access Token in `Authorization: Bearer <token>` header
- Request goes through API Gateway

**Step 6: Token Validation (API Gateway)**
- API Gateway extracts token from Authorization header
- Validates token:
  - **Signature Verification**: Verifies token was signed by Identity Service
  - **Expiration Check**: Ensures token hasn't expired
  - **Token Structure**: Validates JWT format (header.payload.signature)
- If invalid → Return 401 Unauthorized

**Step 7: Claims Extraction**
- Extract claims from token payload:
  - `userId`: User identifier
  - `email`: User email
  - `role`: User role (Student, SchoolAdmin, SuperAdmin)
  - `tenantId`: School ID (for multi-tenancy)
  - `permissions`: Array of permissions
  - `iat`: Issued at timestamp
  - `exp`: Expiration timestamp

**Step 8: Authorization Check**
- Check if user has required role/permission for requested endpoint
- Validate tenant isolation (user can only access their tenant's data)
- If unauthorized → Return 403 Forbidden

**Step 9: Request Forwarding**
- If authorized, API Gateway forwards request to target microservice
- Includes user context (userId, tenantId, role) in headers
- Microservice processes request and returns response

---

#### **Phase 3: Token Refresh Flow**

**Step 10: Access Token Expiration**
- Access token expires (typically after 15-30 minutes)
- Client receives 401 Unauthorized response
- Client automatically initiates refresh flow

**Step 11: Refresh Token Request**
- Client sends refresh token to `/api/auth/refresh` endpoint
- Refresh token sent in cookie or request body
- Request goes through API Gateway to Identity Service

**Step 12: Refresh Token Validation**
- Identity Service validates refresh token:
  - Check token signature
  - Check token expiration
  - Verify token exists in database (not revoked)
  - Check if token is still valid (not blacklisted)

**Step 13: New Token Generation**
- If refresh token is valid:
  - Generate new Access Token
  - Optionally rotate refresh token (generate new one, invalidate old)
  - Update refresh token in database
  - Return new tokens to client

**Step 14: Continue with New Token**
- Client receives new access token
- Retries original request with new token
- Process continues seamlessly

---

### JWT Token Structure

#### **Access Token (JWT)**

```
Header:
{
  "alg": "HS256",        // Algorithm (HMAC SHA256)
  "typ": "JWT"           // Type
}

Payload:
{
  "userId": "12345",
  "email": "student@school.com",
  "role": "Student",
  "tenantId": "school-001",
  "permissions": ["enrollment.read", "payment.read"],
  "iat": 1699123456,     // Issued at
  "exp": 1699125256,      // Expires at (15 min later)
  "jti": "token-id-123"  // JWT ID (for revocation)
}

Signature:
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret-key
)
```

#### **Refresh Token**

```
{
  "userId": "12345",
  "tokenId": "refresh-token-uuid",
  "exp": 1701715456,      // Expires at (30 days later)
  "iat": 1699123456,
  "deviceId": "device-123" // Optional: for device tracking
}
```

---

### Key Concepts

#### **Authentication vs Authorization**

**Authentication (Who are you?):**
- Verifies user identity
- Answers: "Is this user who they claim to be?"
- Done through: Login, password verification, MFA
- Result: User identity confirmed, tokens issued

**Authorization (What can you do?):**
- Verifies user permissions
- Answers: "Does this user have permission to access this resource?"
- Done through: Role checks, permission validation, tenant isolation
- Result: Access granted or denied

#### **Access Token vs Refresh Token**

| Feature | Access Token | Refresh Token |
|---------|-------------|---------------|
| **Purpose** | Authenticate API requests | Obtain new access tokens |
| **Lifetime** | Short (15-30 minutes) | Long (7-30 days) |
| **Storage** | Memory/localStorage | httpOnly cookie (preferred) |
| **Sent With** | Every API request | Only refresh requests |
| **Revocation** | Not stored (stateless) | Stored in DB (can be revoked) |
| **Security Risk** | Higher (sent frequently) | Lower (sent rarely) |

---

## Part 2: Implementation Steps

### Step 1: Project Setup

#### **NuGet Packages Required**

```xml
<PackageReference Include="Microsoft.AspNetCore.Identity.EntityFrameworkCore" Version="8.0.0" />
<PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="8.0.0" />
<PackageReference Include="System.IdentityModel.Tokens.Jwt" Version="7.0.0" />
<PackageReference Include="Microsoft.EntityFrameworkCore" Version="8.0.0" />
<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />
<PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="8.0.0" />
```

---

### Step 2: Database Models

#### **Extended Identity User Model**

```csharp
using Microsoft.AspNetCore.Identity;

public class ApplicationUser : IdentityUser
{
    // Custom properties
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public int TenantId { get; set; } // School ID for multi-tenancy
    
    // Navigation properties
    public ICollection<RefreshToken> RefreshTokens { get; set; }
}
```

**Note:** ASP.NET Core Identity provides these built-in properties:
- `Id` (string) - User identifier
- `Email` - User email
- `UserName` - Username
- `PasswordHash` - Hashed password (managed by Identity)
- `LockoutEnabled` - Account lockout status
- `LockoutEnd` - Lockout expiration
- `AccessFailedCount` - Failed login attempts
- `EmailConfirmed` - Email verification status
- `TwoFactorEnabled` - MFA status
- And many more...

#### **Identity Role (Built-in)**

```csharp
// Identity provides IdentityRole class
// We can extend it if needed:

public class ApplicationRole : IdentityRole
{
    public string Description { get; set; }
}
```

**Note:** ASP.NET Core Identity provides:
- `Id` (string) - Role identifier
- `Name` - Role name (Student, SchoolAdmin, SuperAdmin)
- `NormalizedName` - Normalized role name

#### **Permission Model (Using Identity Claims)**

Instead of a separate Permission table, we use **Identity Claims**:
- **User Claims** (AspNetUserClaims): Store permissions directly on users
- **Role Claims** (AspNetRoleClaims): Store permissions on roles

```csharp
// Permissions are stored as claims:
// - Claim Type: "Permission"
// - Claim Value: "enrollment.read", "payment.write", etc.

   // Example: Adding permission to role
   await _roleManager.AddClaimAsync(role, new Claim("Permission", "enrollment.read"));
   
   // Example: Adding permission to user
   await _userManager.AddClaimAsync(user, new Claim("Permission", "enrollment.write"));
```

#### **Refresh Token Model (Custom)**

```csharp
public class RefreshToken
{
    public int Id { get; set; }
    public string UserId { get; set; } // Identity uses string for UserId
    public string Token { get; set; } // The actual refresh token
    public DateTime ExpiresAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public string CreatedByIp { get; set; }
    public DateTime? RevokedAt { get; set; }
    public string RevokedByIp { get; set; }
    public string ReplacedByToken { get; set; } // For token rotation
    public bool IsActive => RevokedAt == null && DateTime.UtcNow < ExpiresAt;
    
    // Navigation property
    public ApplicationUser User { get; set; }
}
```

#### **Identity Database Context**

```csharp
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

public class IdentityDbContext : IdentityDbContext<ApplicationUser, IdentityRole, string>
{
    public IdentityDbContext(DbContextOptions<IdentityDbContext> options)
        : base(options)
    {
    }

    public DbSet<RefreshToken> RefreshTokens { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // Configure RefreshToken
        builder.Entity<RefreshToken>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Token).IsUnique();
            entity.HasIndex(e => e.UserId);
            
            entity.HasOne(e => e.User)
                .WithMany(u => u.RefreshTokens)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ApplicationUser
        builder.Entity<ApplicationUser>(entity =>
        {
            entity.HasIndex(e => e.TenantId);
            entity.HasIndex(e => e.Email);
        });
    }
}
```

**ASP.NET Core Identity Tables Created:**
- `AspNetUsers` - User accounts
- `AspNetRoles` - Roles
- `AspNetUserRoles` - User-Role mapping
- `AspNetUserClaims` - User claims (permissions)
- `AspNetRoleClaims` - Role claims (permissions)
- `AspNetUserLogins` - External login providers
- `AspNetUserTokens` - External authentication tokens
- `RefreshTokens` - Custom table for refresh tokens

---

### Step 3: JWT Configuration (appsettings.json)

```json
{
  "JwtSettings": {
    "SecretKey": "your-super-secret-key-min-32-characters-long",
    "Issuer": "https://identity.osp.com",
    "Audience": "https://api.osp.com",
    "AccessTokenExpirationMinutes": 15,
    "RefreshTokenExpirationDays": 30
  },
  "ConnectionStrings": {
    "IdentityDb": "Server=localhost;Database=OSP_Identity;Trusted_Connection=true;"
  }
}
```

---

### Step 4: JWT Service Interface and Implementation

#### **IJwtService Interface**

```csharp
public interface IJwtService
{
    Task<string> GenerateAccessTokenAsync(ApplicationUser user);
    RefreshToken GenerateRefreshToken(string userId, string ipAddress);
    ClaimsPrincipal GetPrincipalFromExpiredToken(string token);
    bool ValidateToken(string token);
}
```

#### **JwtService Implementation**

```csharp
public class JwtService : IJwtService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<JwtService> _logger;
    private readonly UserManager<ApplicationUser> _userManager;

    public JwtService(
        IConfiguration configuration, 
        ILogger<JwtService> logger,
        UserManager<ApplicationUser> userManager)
    {
        _configuration = configuration;
        _logger = logger;
        _userManager = userManager;
    }

    public async Task<string> GenerateAccessTokenAsync(ApplicationUser user)
    {
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var secretKey = jwtSettings["SecretKey"];
        var issuer = jwtSettings["Issuer"];
        var audience = jwtSettings["Audience"];
        var expirationMinutes = int.Parse(jwtSettings["AccessTokenExpirationMinutes"]);

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        // Get user claims from Identity
        var userClaims = await _userManager.GetClaimsAsync(user);
        
        // Get user roles from Identity
        var userRoles = await _userManager.GetRolesAsync(user);
        
        // Get role claims
        var roleClaims = new List<Claim>();
        foreach (var role in userRoles)
        {
            roleClaims.Add(new Claim(ClaimTypes.Role, role));
            roleClaims.Add(new Claim("role", role));
        }

        // Build claims list
        var claims = new List<Claim>
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new Claim("userId", user.Id),
            new Claim("tenantId", user.TenantId.ToString())
        };

        // Add role claims
        claims.AddRange(roleClaims);
        
        // Add user claims (permissions)
        claims.AddRange(userClaims);

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expirationMinutes),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public RefreshToken GenerateRefreshToken(string userId, string ipAddress)
    {
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var expirationDays = int.Parse(jwtSettings["RefreshTokenExpirationDays"]);

        var refreshToken = new RefreshToken
        {
            UserId = userId,
            Token = GenerateRandomToken(),
            ExpiresAt = DateTime.UtcNow.AddDays(expirationDays),
            CreatedAt = DateTime.UtcNow,
            CreatedByIp = ipAddress
        };

        return refreshToken;
    }

    public ClaimsPrincipal GetPrincipalFromExpiredToken(string token)
    {
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var secretKey = jwtSettings["SecretKey"];

        var tokenValidationParameters = new TokenValidationParameters
        {
            ValidateAudience = false,
            ValidateIssuer = false,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
            ValidateLifetime = false // We want to get claims from expired token
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out SecurityToken securityToken);

        if (securityToken is not JwtSecurityToken jwtSecurityToken ||
            !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
        {
            throw new SecurityTokenException("Invalid token");
        }

        return principal;
    }

    public bool ValidateToken(string token)
    {
        try
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var secretKey = jwtSettings["SecretKey"];
            var issuer = jwtSettings["Issuer"];
            var audience = jwtSettings["Audience"];

            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(secretKey);

            tokenHandler.ValidateToken(token, new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(key),
                ValidateIssuer = true,
                ValidIssuer = issuer,
                ValidateAudience = true,
                ValidAudience = audience,
                ValidateLifetime = true,
                ClockSkew = TimeSpan.Zero
            }, out SecurityToken validatedToken);

            return true;
        }
        catch
        {
            return false;
        }
    }

    private string GenerateRandomToken()
    {
        var randomNumber = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomNumber);
        return Convert.ToBase64String(randomNumber);
    }
}
```

---

### Step 5: Authentication Service

```csharp
public interface IAuthService
{
    Task<AuthResponse> LoginAsync(LoginRequest request, string ipAddress);
    Task<AuthResponse> RefreshTokenAsync(string refreshToken, string ipAddress);
    Task<bool> RevokeTokenAsync(string refreshToken, string ipAddress);
    Task<bool> ValidateCredentialsAsync(string email, string password);
}

public class AuthService : IAuthService
{
    private readonly IdentityDbContext _context;
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly SignInManager<ApplicationUser> _signInManager;
    private readonly IJwtService _jwtService;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        IdentityDbContext context,
        UserManager<ApplicationUser> userManager,
        SignInManager<ApplicationUser> signInManager,
        IJwtService jwtService,
        ILogger<AuthService> logger)
    {
        _context = context;
        _userManager = userManager;
        _signInManager = signInManager;
        _jwtService = jwtService;
        _logger = logger;
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request, string ipAddress)
    {
        // Find user using Identity UserManager
        var user = await _userManager.FindByEmailAsync(request.Email);

        if (user == null)
        {
            throw new UnauthorizedException("Invalid credentials");
        }

        // Check if account is locked (Identity's built-in lockout)
        if (await _userManager.IsLockedOutAsync(user))
        {
            var lockoutEnd = await _userManager.GetLockoutEndDateAsync(user);
            throw new UnauthorizedException($"Account is locked until {lockoutEnd}. Please try again later.");
        }

        // Validate password using Identity SignInManager
        var signInResult = await _signInManager.CheckPasswordSignInAsync(user, request.Password, lockoutOnFailure: true);

        if (!signInResult.Succeeded)
        {
            if (signInResult.IsLockedOut)
            {
                throw new UnauthorizedException("Account is locked due to too many failed login attempts. Please try again later.");
            }
            if (signInResult.IsNotAllowed)
            {
                throw new UnauthorizedException("Account is not allowed to sign in. Please verify your email.");
            }
            throw new UnauthorizedException("Invalid credentials");
        }

        // Check if email is confirmed (if required)
        if (!user.EmailConfirmed)
        {
            throw new UnauthorizedException("Please confirm your email before signing in.");
        }

        // Generate tokens
        var accessToken = await _jwtService.GenerateAccessTokenAsync(user);
        var refreshToken = _jwtService.GenerateRefreshToken(user.Id, ipAddress);

        // Save refresh token to database
        _context.RefreshTokens.Add(refreshToken);
        await _context.SaveChangesAsync();

        // Get user roles
        var roles = await _userManager.GetRolesAsync(user);

        _logger.LogInformation("User {UserId} logged in successfully from {IpAddress}", user.Id, ipAddress);

        return new AuthResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken.Token,
            ExpiresIn = 900, // 15 minutes in seconds
            User = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Roles = roles.ToList()
            }
        };
    }

    public async Task<AuthResponse> RefreshTokenAsync(string refreshToken, string ipAddress)
    {
        var token = await _context.RefreshTokens
            .Include(rt => rt.User)
            .FirstOrDefaultAsync(rt => rt.Token == refreshToken);

        if (token == null || !token.IsActive)
        {
            throw new UnauthorizedException("Invalid refresh token");
        }

        // Check if user still exists and is active
        var user = await _userManager.FindByIdAsync(token.UserId);
        if (user == null || await _userManager.IsLockedOutAsync(user))
        {
            throw new UnauthorizedException("User account is not active");
        }

        // Revoke old token (token rotation)
        token.RevokedAt = DateTime.UtcNow;
        token.RevokedByIp = ipAddress;

        // Generate new tokens
        var newAccessToken = await _jwtService.GenerateAccessTokenAsync(user);
        var newRefreshToken = _jwtService.GenerateRefreshToken(user.Id, ipAddress);
        newRefreshToken.ReplacedByToken = refreshToken;

        // Save new refresh token
        _context.RefreshTokens.Add(newRefreshToken);
        await _context.SaveChangesAsync();

        return new AuthResponse
        {
            AccessToken = newAccessToken,
            RefreshToken = newRefreshToken.Token,
            ExpiresIn = 900
        };
    }

    public async Task<bool> RevokeTokenAsync(string refreshToken, string ipAddress)
    {
        var token = await _context.RefreshTokens
            .FirstOrDefaultAsync(rt => rt.Token == refreshToken);

        if (token == null || !token.IsActive)
        {
            return false;
        }

        token.RevokedAt = DateTime.UtcNow;
        token.RevokedByIp = ipAddress;
        await _context.SaveChangesAsync();

        return true;
    }

    public async Task<bool> ValidateCredentialsAsync(string email, string password)
    {
        var user = await _userManager.FindByEmailAsync(email);

        if (user == null)
        {
            return false;
        }

        // Check if user is locked out
        if (await _userManager.IsLockedOutAsync(user))
        {
            return false;
        }

        // Validate password using Identity
        var result = await _signInManager.CheckPasswordSignInAsync(user, password, lockoutOnFailure: false);
        return result.Succeeded;
    }
}
```

---

### Step 6: DTOs (Data Transfer Objects)

```csharp
public class LoginRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; }

    [Required]
    [MinLength(6)]
    public string Password { get; set; }
}

public class AuthResponse
{
    public string AccessToken { get; set; }
    public string RefreshToken { get; set; }
    public int ExpiresIn { get; set; }
    public UserDto User { get; set; }
}

public class RefreshTokenRequest
{
    [Required]
    public string RefreshToken { get; set; }
}

public class UserDto
{
    public int Id { get; set; }
    public string Email { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public List<string> Roles { get; set; }
}
```

---

### Step 7: Authentication Controller

```csharp
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(IAuthService authService, ILogger<AuthController> logger)
    {
        _authService = authService;
        _logger = logger;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        try
        {
            var ipAddress = GetIpAddress();
            var response = await _authService.LoginAsync(request, ipAddress);

            // Set refresh token in httpOnly cookie
            SetRefreshTokenCookie(response.RefreshToken);

            return Ok(new
            {
                accessToken = response.AccessToken,
                expiresIn = response.ExpiresIn,
                user = response.User
            });
        }
        catch (UnauthorizedException ex)
        {
            return Unauthorized(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during login");
            return StatusCode(500, new { message = "An error occurred during login" });
        }
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request)
    {
        try
        {
            var ipAddress = GetIpAddress();
            var response = await _authService.RefreshTokenAsync(request.RefreshToken, ipAddress);

            // Update refresh token cookie
            SetRefreshTokenCookie(response.RefreshToken);

            return Ok(new
            {
                accessToken = response.AccessToken,
                expiresIn = response.ExpiresIn
            });
        }
        catch (UnauthorizedException ex)
        {
            return Unauthorized(new { message = ex.Message });
        }
    }

    [HttpPost("revoke")]
    [Authorize]
    public async Task<IActionResult> RevokeToken([FromBody] RefreshTokenRequest request)
    {
        var ipAddress = GetIpAddress();
        var revoked = await _authService.RevokeTokenAsync(request.RefreshToken, ipAddress);

        if (revoked)
        {
            // Remove refresh token cookie
            Response.Cookies.Delete("refreshToken");
            return Ok(new { message = "Token revoked successfully" });
        }

        return BadRequest(new { message = "Token not found or already revoked" });
    }

    [HttpPost("logout")]
    [Authorize]
    public async Task<IActionResult> Logout([FromBody] RefreshTokenRequest request)
    {
        var ipAddress = GetIpAddress();
        await _authService.RevokeTokenAsync(request.RefreshToken, ipAddress);
        Response.Cookies.Delete("refreshToken");
        return Ok(new { message = "Logged out successfully" });
    }

    private void SetRefreshTokenCookie(string refreshToken)
    {
        var cookieOptions = new CookieOptions
        {
            HttpOnly = true,
            Secure = true, // HTTPS only
            SameSite = SameSiteMode.Strict,
            Expires = DateTime.UtcNow.AddDays(30)
        };

        Response.Cookies.Append("refreshToken", refreshToken, cookieOptions);
    }

    private string GetIpAddress()
    {
        if (Request.Headers.ContainsKey("X-Forwarded-For"))
        {
            return Request.Headers["X-Forwarded-For"].ToString().Split(',')[0].Trim();
        }
        return HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";
    }
}
```

---

### Step 8: Configure JWT Authentication (Program.cs / Startup.cs)

```csharp
// Program.cs (ASP.NET Core 6+)

var builder = WebApplication.CreateBuilder(args);

// Add Identity services
builder.Services.AddDbContext<IdentityDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("IdentityDb")));

// Configure Identity
builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    // Password settings
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireUppercase = true;
    options.Password.RequireNonAlphanumeric = true;
    options.Password.RequiredLength = 8;
    
    // Lockout settings
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.AllowedForNewUsers = true;
    
    // User settings
    options.User.RequireUniqueEmail = true;
    options.SignIn.RequireConfirmedEmail = false; // Set to true if email confirmation required
})
.AddEntityFrameworkStores<IdentityDbContext>()
.AddDefaultTokenProviders();

// Add custom services
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<IAuthService, AuthService>();

// Configure JWT Authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"];

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
        ValidateIssuer = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidateAudience = true,
        ValidAudience = jwtSettings["Audience"],
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero // Remove delay of token expiration
    };

    // Handle token validation events
    options.Events = new JwtBearerEvents
    {
        OnAuthenticationFailed = context =>
        {
            if (context.Exception.GetType() == typeof(SecurityTokenExpiredException))
            {
                context.Response.Headers.Add("Token-Expired", "true");
            }
            return Task.CompletedTask;
        },
        OnTokenValidated = context =>
        {
            // Additional validation can be done here
            return Task.CompletedTask;
        }
    };
});

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("StudentOnly", policy => policy.RequireRole("Student"));
    options.AddPolicy("SchoolAdminOnly", policy => policy.RequireRole("SchoolAdmin"));
    options.AddPolicy("SuperAdminOnly", policy => policy.RequireRole("SuperAdmin"));
});

var app = builder.Build();

// Configure pipeline
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
```

---

### Step 9: Authorization Middleware (Optional - Custom Authorization)

```csharp
public class PermissionAuthorizationHandler : AuthorizationHandler<PermissionRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        PermissionRequirement requirement)
    {
        var permissions = context.User.Claims
            .Where(c => c.Type == "permission")
            .Select(c => c.Value)
            .ToList();

        if (permissions.Contains(requirement.Permission))
        {
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}

public class PermissionRequirement : IAuthorizationRequirement
{
    public string Permission { get; }

    public PermissionRequirement(string permission)
    {
        Permission = permission;
    }
}

// Usage in controller
[Authorize(Policy = "RequireEnrollmentWrite")]
// or
[Authorize(Policy = "RequirePermission", Roles = "SchoolAdmin")]
```

---

### Step 10: API Gateway Token Validation

```csharp
// In API Gateway (Ocelot configuration)

{
  "Routes": [
    {
      "DownstreamPathTemplate": "/api/{everything}",
      "DownstreamScheme": "https",
      "DownstreamHostAndPorts": [
        {
          "Host": "enrollment-service",
          "Port": 443
        }
      ],
      "UpstreamPathTemplate": "/api/enrollment/{everything}",
      "UpstreamHttpMethod": [ "GET", "POST", "PUT", "DELETE" ],
      "AuthenticationOptions": {
        "AuthenticationProviderKey": "Bearer",
        "AllowedScopes": []
      },
      "AddHeadersToDownstream": {
        "X-User-Id": "{Claims[userId]}",
        "X-Tenant-Id": "{Claims[tenantId]}",
        "X-User-Role": "{Claims[role]}"
      }
    }
  ],
  "GlobalConfiguration": {
    "BaseUrl": "https://api.osp.com"
  }
}
```

---

## Part 3: Follow-Up Questions & Answers

### Q1: Why use JWT instead of session-based authentication?

**Answer:**

**JWT Advantages:**
1. **Stateless**: No server-side session storage needed
2. **Scalability**: Works across multiple servers without shared session store
3. **Microservices Friendly**: Token can be validated independently
4. **Mobile Support**: Better for mobile apps and SPAs
5. **Performance**: No database lookup for each request (after initial validation)

**Session-Based Disadvantages:**
- Requires shared session store (Redis, database)
- Doesn't scale well across multiple servers
- Requires sticky sessions or shared storage
- More complex in microservices architecture

**When to Use Sessions:**
- Need immediate token revocation
- Require server-side control over sessions
- Security-critical applications needing instant logout

---

### Q2: How do you handle token revocation with JWT?

**Answer:**

**Challenges:**
- JWT is stateless - can't be revoked like sessions
- Token valid until expiration

**Solutions Implemented:**

1. **Refresh Token Revocation** (Implemented):
   - Store refresh tokens in database
   - Can revoke refresh token immediately
   - Access token expires naturally (short-lived)

2. **Token Blacklist** (Redis):
   ```csharp
   // On logout/revoke
   var tokenId = GetTokenIdFromJwt(accessToken);
   await _redis.StringSetAsync($"blacklist:{tokenId}", "revoked", 
       TimeSpan.FromMinutes(15)); // Until token expires
   
   // On validation
   var isBlacklisted = await _redis.KeyExistsAsync($"blacklist:{tokenId}");
   if (isBlacklisted) throw new UnauthorizedException();
   ```

3. **Short Access Token Lifetime**:
   - Access token: 15 minutes
   - Refresh token: 30 days
   - Compromise window is limited

4. **Token Versioning**:
   - Add version to user record
   - Include version in JWT
   - On password change, increment version
   - Reject tokens with old version

---

### Q3: How do you prevent token theft and XSS attacks?

**Answer:**

**Security Measures:**

1. **HttpOnly Cookies for Refresh Token**:
   ```csharp
   // Refresh token in httpOnly cookie (not accessible via JavaScript)
   Response.Cookies.Append("refreshToken", token, new CookieOptions
   {
       HttpOnly = true,  // Prevents XSS access
       Secure = true,    // HTTPS only
       SameSite = SameSiteMode.Strict // CSRF protection
   });
   ```

2. **Access Token in Memory** (for SPA):
   - Store in JavaScript variable (not localStorage)
   - Cleared on page refresh
   - Less vulnerable to XSS than localStorage

3. **Content Security Policy (CSP)**:
   ```csharp
   app.Use(async (context, next) =>
   {
       context.Response.Headers.Add("Content-Security-Policy", 
           "default-src 'self'; script-src 'self'");
       await next();
   });
   ```

4. **HTTPS Only**:
   - All tokens transmitted over HTTPS
   - Secure flag on cookies

5. **Token Rotation**:
   - New refresh token on each refresh
   - Old token invalidated
   - Limits damage if token stolen

---

### Q4: How do you handle multi-tenancy in JWT tokens?

**Answer:**

**Implementation:**

1. **Include TenantId in Token**:
   ```csharp
   claims.Add(new Claim("tenantId", user.TenantId.ToString()));
   ```

2. **Tenant Validation Middleware**:
   ```csharp
   public class TenantAuthorizationMiddleware
   {
       public async Task InvokeAsync(HttpContext context, RequestDelegate next)
       {
           var tenantId = context.User.FindFirst("tenantId")?.Value;
           var requestedTenantId = context.Request.RouteValues["tenantId"]?.ToString();
           
           if (tenantId != requestedTenantId)
           {
               context.Response.StatusCode = 403;
               return;
           }
           
           await next(context);
       }
   }
   ```

3. **Database Query Filtering**:
   ```csharp
   // In repository
   var tenantId = int.Parse(_httpContext.User.FindFirst("tenantId").Value);
   var enrollments = await _context.Enrollments
       .Where(e => e.TenantId == tenantId)
       .ToListAsync();
   ```

4. **API Gateway Tenant Validation**:
   - Extract tenantId from token
   - Forward to microservice in header
   - Microservice validates tenant access

---

### Q5: What happens if refresh token is compromised?

**Answer:**

**Mitigation Strategies:**

1. **Token Rotation** (Implemented):
   - New refresh token issued on each refresh
   - Old token immediately revoked
   - Attacker can't reuse stolen token

2. **Device Tracking**:
   ```csharp
   public class RefreshToken
   {
       public string DeviceId { get; set; }
       public string DeviceName { get; set; }
       public string IpAddress { get; set; }
   }
   ```
   - Alert user if token used from different device/IP

3. **Refresh Token Limits**:
   - Limit number of active refresh tokens per user (e.g., 5 devices)
   - Revoke oldest token when limit reached

4. **Suspicious Activity Detection**:
   - Monitor refresh patterns
   - Alert on unusual activity
   - Auto-revoke on suspicious behavior

5. **User Notification**:
   - Email user when new device logs in
   - Allow user to revoke all tokens

---

### Q6: How do you handle token expiration on the client side?

**Answer:**

**Client-Side Implementation:**

1. **Automatic Token Refresh** (Axios Interceptor):
   ```javascript
   // Add token to requests
   axios.interceptors.request.use(config => {
       const token = localStorage.getItem('accessToken');
       if (token) {
           config.headers.Authorization = `Bearer ${token}`;
       }
       return config;
   });

   // Handle 401 and refresh token
   axios.interceptors.response.use(
       response => response,
       async error => {
           const originalRequest = error.config;
           
           if (error.response?.status === 401 && !originalRequest._retry) {
               originalRequest._retry = true;
               
               try {
                   const refreshToken = getCookie('refreshToken');
                   const response = await axios.post('/api/auth/refresh', {
                       refreshToken: refreshToken
                   });
                   
                   const { accessToken } = response.data;
                   localStorage.setItem('accessToken', accessToken);
                   
                   originalRequest.headers.Authorization = `Bearer ${accessToken}`;
                   return axios(originalRequest);
               } catch (refreshError) {
                   // Refresh failed - redirect to login
                   window.location.href = '/login';
               }
           }
           
           return Promise.reject(error);
       }
   );
   ```

2. **Proactive Token Refresh**:
   ```javascript
   // Refresh token before expiration
   setInterval(async () => {
       const token = getTokenFromStorage();
       const decoded = jwt_decode(token);
       const expirationTime = decoded.exp * 1000; // Convert to milliseconds
       const currentTime = Date.now();
       const timeUntilExpiry = expirationTime - currentTime;
       
       // Refresh if less than 5 minutes remaining
       if (timeUntilExpiry < 5 * 60 * 1000) {
           await refreshAccessToken();
       }
   }, 60000); // Check every minute
   ```

---

### Q7: How do you implement rate limiting for login attempts?

**Answer:**

**Implementation:**

1. **Database-Based Rate Limiting**:
   ```csharp
   // In LoginAsync method
   if (user.FailedLoginAttempts >= 5)
   {
       user.IsLocked = true;
       user.LockedUntil = DateTime.UtcNow.AddMinutes(15);
       await _context.SaveChangesAsync();
       throw new UnauthorizedException("Too many failed attempts. Account locked for 15 minutes.");
   }
   ```

2. **Redis-Based Rate Limiting** (More Scalable):
   ```csharp
   public class RateLimitingService
   {
       private readonly IDatabase _redis;
       
       public async Task<bool> IsAllowedAsync(string key, int maxAttempts, TimeSpan window)
       {
           var current = await _redis.StringIncrementAsync($"ratelimit:{key}");
           
           if (current == 1)
           {
               await _redis.KeyExpireAsync($"ratelimit:{key}", window);
           }
           
           return current <= maxAttempts;
       }
   }

   // Usage
   var ipAddress = GetIpAddress();
   var isAllowed = await _rateLimitingService.IsAllowedAsync(
       $"login:{ipAddress}", 
       maxAttempts: 5, 
       window: TimeSpan.FromMinutes(15));
   
   if (!isAllowed)
   {
       throw new UnauthorizedException("Too many login attempts. Please try again later.");
   }
   ```

3. **Middleware Approach**:
   ```csharp
   public class RateLimitMiddleware
   {
       public async Task InvokeAsync(HttpContext context, RequestDelegate next)
       {
           var endpoint = context.Request.Path;
           if (endpoint == "/api/auth/login")
           {
               var ipAddress = context.Connection.RemoteIpAddress.ToString();
               // Check rate limit
           }
           await next(context);
       }
   }
   ```

---

### Q8: How do you test JWT authentication?

**Answer:**

**Testing Strategies:**

1. **Unit Tests**:
   ```csharp
   [Fact]
   public async Task Login_ValidCredentials_ReturnsTokens()
   {
       // Arrange
       var user = new ApplicationUser 
       { 
           Email = "test@school.com",
           UserName = "test@school.com",
           TenantId = 1
       };
       await _userManager.CreateAsync(user, "Password123!");
       
       var request = new LoginRequest 
       { 
           Email = "test@school.com", 
           Password = "Password123!" 
       };
       
       // Act
       var result = await _authService.LoginAsync(request, "127.0.0.1");
       
       // Assert
       Assert.NotNull(result.AccessToken);
       Assert.NotNull(result.RefreshToken);
       Assert.True(_jwtService.ValidateToken(result.AccessToken));
   }
   ```

2. **Integration Tests**:
   ```csharp
   [Fact]
   public async Task ProtectedEndpoint_ValidToken_Returns200()
   {
       // Arrange
       var token = await GetAccessTokenAsync();
       var client = _factory.CreateClient();
       client.DefaultRequestHeaders.Authorization = 
           new AuthenticationHeaderValue("Bearer", token);
       
       // Act
       var response = await client.GetAsync("/api/enrollment");
       
       // Assert
       Assert.Equal(HttpStatusCode.OK, response.StatusCode);
   }
   ```

3. **Token Validation Tests**:
   ```csharp
   [Fact]
   public async Task GenerateToken_ContainsCorrectClaims()
   {
       var user = new ApplicationUser 
       { 
           Id = "user-123",
           Email = "test@school.com",
           TenantId = 1
       };
       await _userManager.CreateAsync(user, "Password123!");
       await _userManager.AddToRoleAsync(user, "Student");
       
       var token = await _jwtService.GenerateAccessTokenAsync(user);
       var handler = new JwtSecurityTokenHandler();
       var jsonToken = handler.ReadJwtToken(token);
       
       Assert.Equal(user.Id, jsonToken.Claims.First(c => c.Type == "userId").Value);
       Assert.Equal("Student", jsonToken.Claims.First(c => c.Type == "role").Value);
   }
   ```

---

### Q9: How do you handle password reset flow?

**Answer:**

**Implementation:**

1. **Password Reset Request**:
   ```csharp
   [HttpPost("forgot-password")]
   public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
   {
       var user = await _userManager.FindByEmailAsync(request.Email);
       if (user == null)
       {
           // Don't reveal if user exists (security)
           return Ok(new { message = "If email exists, reset link sent" });
       }
       
       // Generate password reset token using Identity
       var resetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
       
       // Send email with reset link
       await _emailService.SendPasswordResetEmail(user.Email, resetToken);
       
       return Ok(new { message = "Reset link sent to email" });
   }
   ```

2. **Password Reset**:
   ```csharp
   [HttpPost("reset-password")]
   public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
   {
       var user = await _userManager.FindByEmailAsync(request.Email);
       
       if (user == null)
       {
           return BadRequest(new { message = "Invalid user" });
       }
       
       // Reset password using Identity
       var result = await _userManager.ResetPasswordAsync(user, request.Token, request.NewPassword);
       
       if (!result.Succeeded)
       {
           return BadRequest(new { 
               message = "Invalid or expired token",
               errors = result.Errors.Select(e => e.Description)
           });
       }
       
       // Revoke all refresh tokens (security)
       await RevokeAllUserTokens(user.Id);
       
       return Ok(new { message = "Password reset successfully" });
   }
   ```

---

### Q10: How do you implement role-based and permission-based authorization?

**Answer:**

**Two-Level Authorization:**

1. **Role-Based (Coarse-grained)**:
   ```csharp
   [Authorize(Roles = "SchoolAdmin")]
   [HttpGet("schools/{id}/students")]
   public async Task<IActionResult> GetSchoolStudents(int id)
   {
       // Only SchoolAdmin can access
   }
   ```

2. **Permission-Based (Fine-grained)**:
   ```csharp
   [Authorize(Policy = "RequireEnrollmentWrite")]
   [HttpPost("enrollments")]
   public async Task<IActionResult> CreateEnrollment([FromBody] CreateEnrollmentRequest request)
   {
       // Requires specific permission
   }
   ```

3. **Custom Authorization Attribute**:
   ```csharp
   public class RequirePermissionAttribute : AuthorizeAttribute
   {
       public RequirePermissionAttribute(string permission)
       {
           Policy = $"RequirePermission:{permission}";
       }
   }

   // Usage
   [RequirePermission("enrollment.write")]
   [HttpPost("enrollments")]
   public async Task<IActionResult> CreateEnrollment(...)
   ```

4. **Resource-Based Authorization**:
   ```csharp
   [HttpPut("enrollments/{id}")]
   public async Task<IActionResult> UpdateEnrollment(int id, [FromBody] UpdateRequest request)
   {
       var enrollment = await _context.Enrollments.FindAsync(id);
       var userId = User.FindFirst("userId").Value; // Identity uses string for UserId
       
       // Check if user owns the resource
       if (enrollment.StudentId != userId && !User.IsInRole("SchoolAdmin"))
       {
           return Forbid();
       }
       
       // Update enrollment
   }
   ```

---

## Summary

This comprehensive guide covers:
- ✅ Complete authentication and authorization flow
- ✅ Step-by-step implementation with code examples
- ✅ JWT token structure and claims
- ✅ Refresh token mechanism
- ✅ Security best practices
- ✅ Common interview questions with detailed answers

**Key Takeaways:**
- Use ASP.NET Core Identity for user and role management (reduces custom code)
- Use short-lived access tokens (15-30 min) and long-lived refresh tokens (7-30 days)
- Store refresh tokens in httpOnly cookies for security
- Implement token rotation for better security
- Always validate tokens on API Gateway
- Include tenantId in tokens for multi-tenancy
- Leverage Identity's built-in account lockout and password policies
- Use Identity Claims for permissions (AspNetUserClaims, AspNetRoleClaims)
- Use both role-based and permission-based authorization
- Identity uses string for UserId (not int) - important for JWT claims

---

## Additional: ASP.NET Core Identity Benefits

### Built-in Features We Leveraged

1. **User Management**
   - `UserManager<ApplicationUser>` for user CRUD operations
   - Password hashing (PBKDF2 with HMAC-SHA256) - automatic
   - Email confirmation workflow
   - Phone number verification

2. **Role Management**
   - `RoleManager<IdentityRole>` for role management
   - Role-based authorization
   - Role hierarchy support

3. **Claims System**
   - User claims (AspNetUserClaims) for permissions
   - Role claims (AspNetRoleClaims) for role-level permissions
   - Dynamic claims loading in JWT tokens

4. **Security Features**
   - Account lockout after failed attempts (configurable)
   - Password complexity requirements
   - Password expiration (optional)
   - Two-factor authentication (2FA)
   - External login providers (Google, Facebook, etc.)

5. **Token Providers**
   - Password reset tokens (`GeneratePasswordResetTokenAsync`)
   - Email confirmation tokens (`GenerateEmailConfirmationTokenAsync`)
   - Phone number confirmation tokens
   - Two-factor authentication tokens

### Custom Extensions

1. **Extended ApplicationUser**
   ```csharp
   public class ApplicationUser : IdentityUser
   {
       public string FirstName { get; set; }
       public string LastName { get; set; }
       public int TenantId { get; set; } // Multi-tenancy
       public ICollection<RefreshToken> RefreshTokens { get; set; }
   }
   ```

2. **Custom RefreshToken Table**
   - Identity doesn't have built-in refresh tokens
   - Created custom table for refresh token management
   - Supports token rotation and revocation

3. **JWT Integration**
   - Custom JWT service that works with Identity
   - Extracts claims from Identity (roles, user claims)
   - Generates JWT tokens with Identity data

### Identity Tables Structure

```
AspNetUsers
├── Id (string, PK)
├── UserName
├── Email
├── EmailConfirmed
├── PasswordHash (managed by Identity)
├── LockoutEnabled
├── LockoutEnd
├── AccessFailedCount
├── TwoFactorEnabled
├── FirstName (custom)
├── LastName (custom)
└── TenantId (custom)

AspNetRoles
├── Id (string, PK)
└── Name

AspNetUserRoles
├── UserId (FK to AspNetUsers)
└── RoleId (FK to AspNetRoles)

AspNetUserClaims
├── Id (int, PK)
├── UserId (FK to AspNetUsers)
├── ClaimType
└── ClaimValue

AspNetRoleClaims
├── Id (int, PK)
├── RoleId (FK to AspNetRoles)
├── ClaimType
└── ClaimValue

RefreshTokens (Custom)
├── Id (int, PK)
├── UserId (FK to AspNetUsers)
├── Token
├── ExpiresAt
├── CreatedAt
├── RevokedAt
└── ...
```

### Advantages Over Custom Implementation

1. **Security**: Industry-tested password hashing and security practices
2. **Less Code**: No need to implement password hashing, lockout, etc.
3. **Maintainability**: Well-documented and widely used
4. **Extensibility**: Easy to extend with custom properties
5. **Integration**: Works seamlessly with Entity Framework Core
6. **Features**: Built-in 2FA, external logins, token providers
7. **Community**: Large community and extensive documentation

---

## Question 3: How did you deploy your .NET and Angular applications to AWS?

### Overview

Our OSP platform consists of:
- **Student Portal** (Angular) - SPA for students
- **Edlio Admin Portal** (Angular) - SPA for super administrators
- **School Admin Portal** (.NET Core MVC) - Server-side rendered application
- **Microservices APIs** (.NET Core Web API) - 9 microservices

### Deployment Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                                │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Route 53 (DNS)                              │  │
│  │  student.osp.com  |  admin.osp.com  |  school.osp.com    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         ↓                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              CloudFront (CDN)                              │  │
│  │  - SSL/TLS Termination                                    │  │
│  │  - Caching & Content Delivery                             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         ↓                                        │
│  ┌──────────────────────┐  ┌────────────────────────────────┐ │
│  │   S3 Buckets         │  │   Application Load Balancer     │ │
│  │  ┌────────────────┐  │  │  (ALB)                          │ │
│  │  │ Student Portal │  │  │  - SSL Termination              │ │
│  │  │ (Angular SPA) │  │  │  - Health Checks                │ │
│  │  └────────────────┘  │  │  - Path-based Routing         │ │
│  │  ┌────────────────┐  │  └────────────────────────────────┘ │
│  │  │ Edlio Admin    │  │              ↓                        │
│  │  │ (Angular SPA)  │  │  ┌────────────────────────────────┐ │
│  │  └────────────────┘  │  │   ECS Fargate / EC2             │ │
│  └──────────────────────┘  │   - School Portal (MVC)         │ │
│                             │   - Microservices APIs          │ │
│                             └────────────────────────────────┘ │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Supporting Services                           │  │
│  │  - RDS (SQL Server) - Databases                           │  │
│  │  - ElastiCache (Redis) - Caching                          │  │
│  │  - SQS - Message Queue                                    │  │
│  │  - CloudWatch - Monitoring & Logging                     │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Part 1: Angular Applications Deployment (Student Portal & Edlio Admin Portal)

### Architecture: S3 + CloudFront

**Why S3 + CloudFront?**
- **S3**: Static file hosting for Angular build artifacts
- **CloudFront**: Global CDN for fast content delivery, SSL/TLS termination
- **Cost-effective**: Pay only for storage and data transfer
- **Scalable**: Automatically handles traffic spikes
- **High Availability**: 99.99% uptime SLA

### Step-by-Step Deployment

#### **Step 1: Build Angular Applications**

```bash
# Build Student Portal
cd student-portal
ng build --configuration production --output-path=dist/student-portal

# Build Edlio Admin Portal
cd edlio-admin-portal
ng build --configuration production --output-path=dist/edlio-admin
```

**Environment Configuration:**

```typescript
// environment.prod.ts
export const environment = {
  production: true,
  apiUrl: 'https://api.osp.com',
  studentApiUrl: 'https://api.osp.com/api/student',
  adminApiUrl: 'https://api.osp.com/api/admin'
};
```

#### **Step 2: Create S3 Buckets**

```bash
# Create buckets via AWS CLI
aws s3 mb s3://osp-student-portal --region us-east-1
aws s3 mb s3://osp-edlio-admin-portal --region us-east-1

# Or via AWS Console:
# - Bucket name: osp-student-portal
# - Region: us-east-1
# - Block all public access: Disabled (for static website hosting)
# - Enable versioning: Yes (for rollback capability)
```

#### **Step 3: Configure S3 Bucket for Static Website Hosting**

```bash
# Enable static website hosting
aws s3 website s3://osp-student-portal \
  --index-document index.html \
  --error-document index.html

# Upload build files
aws s3 sync dist/student-portal s3://osp-student-portal \
  --delete \
  --cache-control "max-age=31536000" \
  --exclude "*.html" \
  --exclude "*.json"

# Upload HTML files with no-cache
aws s3 sync dist/student-portal s3://osp-student-portal \
  --delete \
  --cache-control "no-cache, no-store, must-revalidate" \
  --include "*.html" \
  --include "*.json"
```

**S3 Bucket Policy (for public read access):**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::osp-student-portal/*"
    }
  ]
}
```

#### **Step 4: Create CloudFront Distributions**

**CloudFront Configuration:**

```bash
# Create CloudFront distribution via AWS Console or CloudFormation
```

**Key Settings:**
- **Origin**: S3 bucket (osp-student-portal.s3.amazonaws.com)
- **Origin Access Control (OAC)**: Restrict S3 access to CloudFront only
- **Default Root Object**: index.html
- **Viewer Protocol Policy**: Redirect HTTP to HTTPS
- **SSL Certificate**: ACM certificate (for custom domain)
- **Alternate Domain Names (CNAMEs)**: student.osp.com
- **Default Cache Behavior**:
  - Allowed HTTP Methods: GET, HEAD, OPTIONS
  - Cache Policy: CachingOptimized
  - Origin Request Policy: None
  - Response Headers Policy: SecurityHeadersPolicy

**Custom Error Responses (for Angular Routing):**

```
HTTP Error Code: 403, 404
Response Page Path: /index.html
HTTP Response Code: 200
TTL: 300
```

This ensures Angular routes work correctly (SPA routing).

#### **Step 5: Configure Route 53 for Custom Domains**

```bash
# Create hosted zone
aws route53 create-hosted-zone --name osp.com --caller-reference $(date +%s)

# Create A record (Alias) pointing to CloudFront distribution
aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456789 \
  --change-batch '{
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "student.osp.com",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "d1234567890.cloudfront.net",
          "EvaluateTargetHealth": false,
          "HostedZoneId": "Z2FDTNDATAQYW2"
        }
      }
    }]
  }'
```

#### **Step 6: SSL Certificate (ACM)**

```bash
# Request certificate via AWS Certificate Manager
# - Domain: student.osp.com
# - Validation: DNS validation
# - Region: us-east-1 (required for CloudFront)
```

---

## Part 2: .NET Core MVC Application Deployment (School Admin Portal)

### Architecture: EC2 with Application Load Balancer

**Why EC2 for MVC?**
- Server-side rendering requires .NET runtime
- Full control over IIS/Kestrel configuration
- Better for applications requiring Windows-specific features
- Cost-effective for predictable workloads

### Step-by-Step Deployment

#### **Step 1: Build and Publish MVC Application**

```bash
# Publish MVC application
cd SchoolAdminPortal
dotnet publish -c Release -o ./publish

# Create deployment package
Compress-Archive -Path ./publish -DestinationPath school-portal.zip
```

#### **Step 2: Launch EC2 Instance**

**EC2 Configuration:**
- **AMI**: Windows Server 2022 Base
- **Instance Type**: t3.medium (2 vCPU, 4 GB RAM)
- **VPC**: Custom VPC with public and private subnets
- **Security Group**:
  - Inbound: HTTP (80), HTTPS (443) from ALB
  - Inbound: RDP (3389) from your IP only
  - Outbound: All traffic
- **IAM Role**: EC2 role with S3 read access (for deployment artifacts)

#### **Step 3: Configure EC2 Instance**

**Install .NET Runtime:**

```powershell
# Connect via RDP
# Download and install .NET 8 Hosting Bundle
# https://dotnet.microsoft.com/download/dotnet/8.0

# Install IIS (if using IIS)
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Install-WindowsFeature -name Web-Asp-Net45
```

**Deploy Application:**

```powershell
# Option 1: Copy files via RDP
# Copy publish folder to C:\inetpub\wwwroot\school-portal

# Option 2: Download from S3
aws s3 cp s3://osp-deployments/school-portal.zip C:\deployments\
Expand-Archive -Path C:\deployments\school-portal.zip -DestinationPath C:\inetpub\wwwroot\school-portal

# Configure IIS Application Pool
New-WebAppPool -Name "SchoolPortalAppPool"
Set-ItemProperty IIS:\AppPools\SchoolPortalAppPool -Name managedRuntimeVersion -Value ""
Set-ItemProperty IIS:\AppPools\SchoolPortalAppPool -Name enable32BitAppOnWin64 -Value $false

# Create IIS Website
New-Website -Name "SchoolPortal" `
  -PhysicalPath "C:\inetpub\wwwroot\school-portal" `
  -ApplicationPool "SchoolPortalAppPool" `
  -Port 80

# Configure web.config for ASP.NET Core
```

**web.config for ASP.NET Core:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="." inheritInChildApplications="false">
    <system.webServer>
      <handlers>
        <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
      </handlers>
      <aspNetCore processPath="dotnet" 
                  arguments=".\SchoolAdminPortal.dll" 
                  stdoutLogEnabled="false" 
                  stdoutLogFile=".\logs\stdout" 
                  hostingModel="inprocess" />
    </system.webServer>
  </location>
</configuration>
```

#### **Step 4: Configure Application Load Balancer (ALB)**

**ALB Configuration:**
- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Subnets**: Public subnets in multiple AZs
- **Security Group**: Allow HTTP (80), HTTPS (443) from internet
- **Listeners**:
  - HTTP (80): Redirect to HTTPS
  - HTTPS (443): Forward to target group
- **SSL Certificate**: ACM certificate for school.osp.com

**Target Group:**
- **Protocol**: HTTP
- **Port**: 80
- **Health Check Path**: /health
- **Health Check Protocol**: HTTP
- **Healthy Threshold**: 2
- **Unhealthy Threshold**: 2
- **Timeout**: 5 seconds
- **Interval**: 30 seconds

#### **Step 5: Auto Scaling Group**

**Auto Scaling Configuration:**
- **Launch Template**: Based on configured EC2 instance
- **Min Size**: 2 instances
- **Max Size**: 10 instances
- **Desired Capacity**: 2 instances
- **Target Tracking Policy**: 
  - Metric: Average CPU utilization
  - Target Value: 70%
- **Health Check Type**: ELB

---

## Part 3: .NET Core Web APIs Deployment (Microservices)

### Architecture: ECS Fargate with Application Load Balancer

**Why ECS Fargate?**
- **Containerized**: Each microservice in its own container
- **Serverless**: No EC2 management, AWS manages infrastructure
- **Auto-scaling**: Scale services independently
- **Cost-effective**: Pay only for running containers
- **Microservices-friendly**: Perfect for our 9 microservices

### Step-by-Step Deployment

#### **Step 1: Create Dockerfile for Each Microservice**

**Example: Identity Service Dockerfile**

```dockerfile
# Dockerfile for Identity Service
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["IdentityService/IdentityService.csproj", "IdentityService/"]
RUN dotnet restore "IdentityService/IdentityService.csproj"
COPY . .
WORKDIR "/src/IdentityService"
RUN dotnet build "IdentityService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "IdentityService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "IdentityService.dll"]
```

#### **Step 2: Build and Push Docker Images to ECR**

```bash
# Create ECR repositories
aws ecr create-repository --repository-name osp/identity-service --region us-east-1
aws ecr create-repository --repository-name osp/enrollment-service --region us-east-1
# ... repeat for all 9 microservices

# Get ECR login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Build and push Identity Service
cd IdentityService
docker build -t osp/identity-service .
docker tag osp/identity-service:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/osp/identity-service:latest
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/osp/identity-service:latest
```

#### **Step 3: Create ECS Cluster**

```bash
# Create ECS Cluster (Fargate)
aws ecs create-cluster --cluster-name osp-microservices-cluster

# Or via AWS Console:
# - Cluster name: osp-microservices-cluster
# - Infrastructure: AWS Fargate (Serverless)
```

#### **Step 4: Create Task Definitions**

**Task Definition for Identity Service:**

```json
{
  "family": "identity-service",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "identity-service",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/osp/identity-service:latest",
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
        },
        {
          "name": "ConnectionStrings__IdentityDb",
          "value": "Server=rds-endpoint;Database=OSP_Identity;..."
        }
      ],
      "secrets": [
        {
          "name": "JwtSettings__SecretKey",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789012:secret:osp/jwt-secret"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/identity-service",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ],
  "taskRoleArn": "arn:aws:iam::123456789012:role/ecsTaskRole",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
}
```

#### **Step 5: Create ECS Services**

```bash
# Create ECS Service for Identity Service
aws ecs create-service \
  --cluster osp-microservices-cluster \
  --service-name identity-service \
  --task-definition identity-service:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-123,subnet-456],securityGroups=[sg-123],assignPublicIp=DISABLED}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/identity-tg/123,containerName=identity-service,containerPort=80" \
  --enable-execute-command
```

**Service Configuration:**
- **Service Name**: identity-service
- **Task Definition**: identity-service:1
- **Desired Count**: 2 (for high availability)
- **Launch Type**: FARGATE
- **Network**: Private subnets, no public IP
- **Load Balancer**: Target group for identity service
- **Auto Scaling**: 
  - Min: 2 tasks
  - Max: 10 tasks
  - Target: 70% CPU utilization

#### **Step 6: Configure Application Load Balancer (ALB) for APIs**

**ALB Configuration:**
- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Subnets**: Public subnets in multiple AZs
- **Security Group**: Allow HTTP (80), HTTPS (443) from internet

**Listeners and Rules:**

```
Listener: HTTPS (443)
├── Rule 1: /api/identity/* → identity-service target group
├── Rule 2: /api/enrollment/* → enrollment-service target group
├── Rule 3: /api/payment/* → payment-service target group
├── Rule 4: /api/notification/* → notification-service target group
├── Rule 5: /api/school/* → school-management-service target group
├── Rule 6: /api/fee/* → fee-management-service target group
├── Rule 7: /api/activity/* → activity-service target group
├── Rule 8: /api/reporting/* → reporting-service target group
├── Rule 9: /api/admin/* → admin-service target group
└── Default: Return 404

Listener: HTTP (80)
└── Action: Redirect to HTTPS
```

**Target Groups (one per microservice):**
- identity-service-tg
- enrollment-service-tg
- payment-service-tg
- notification-service-tg
- school-management-service-tg
- fee-management-service-tg
- activity-service-tg
- reporting-service-tg
- admin-service-tg

#### **Step 7: Configure API Gateway (Optional - for Unified Entry Point)**

If using API Gateway in front of ALB:

```yaml
# API Gateway Configuration
API Gateway → ALB → ECS Services

Benefits:
- Rate limiting
- Request throttling
- API versioning
- Request/response transformation
- API analytics
```

---

## Part 4: Database and Supporting Services

### RDS SQL Server Configuration

```bash
# Create RDS Subnet Group
aws rds create-db-subnet-group \
  --db-subnet-group-name osp-db-subnet-group \
  --db-subnet-group-description "OSP Database Subnet Group" \
  --subnet-ids subnet-123 subnet-456

# Create RDS Instance
aws rds create-db-instance \
  --db-instance-identifier osp-identity-db \
  --db-instance-class db.t3.medium \
  --engine sqlserver-se \
  --engine-version 15.00.4236.7.v1 \
  --master-username admin \
  --master-user-password <password> \
  --allocated-storage 100 \
  --storage-type gp3 \
  --vpc-security-group-ids sg-123 \
  --db-subnet-group-name osp-db-subnet-group \
  --backup-retention-period 7 \
  --multi-az \
  --storage-encrypted
```

**RDS Configuration:**
- **Engine**: SQL Server Standard Edition
- **Instance Class**: db.t3.medium (2 vCPU, 4 GB RAM)
- **Multi-AZ**: Enabled for high availability
- **Backup Retention**: 7 days
- **Encryption**: Enabled at rest
- **Security Group**: Allow SQL Server (1433) from ECS tasks only

### ElastiCache Redis Configuration

```bash
# Create ElastiCache Subnet Group
aws elasticache create-cache-subnet-group \
  --cache-subnet-group-name osp-redis-subnet-group \
  --cache-subnet-group-description "OSP Redis Subnet Group" \
  --subnet-ids subnet-123 subnet-456

# Create Redis Cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id osp-redis-cluster \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1 \
  --cache-subnet-group-name osp-redis-subnet-group \
  --security-group-ids sg-123
```

### SQS Queue Configuration

```bash
# Create SQS Queues for event-driven communication
aws sqs create-queue --queue-name enrollment-created-events
aws sqs create-queue --queue-name payment-completed-events
aws sqs create-queue --queue-name order-placed-events
aws sqs create-queue --queue-name fee-calculated-events
```

---

## Part 5: CI/CD Pipeline

### GitHub Actions / Azure DevOps Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to AWS

on:
  push:
    branches: [main]

jobs:
  build-and-deploy-angular:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Build Student Portal
        run: |
          cd student-portal
          npm install
          npm run build -- --configuration production
      - name: Deploy to S3
        run: |
          aws s3 sync student-portal/dist s3://osp-student-portal --delete
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id E1234567890 \
            --paths "/*"

  build-and-deploy-api:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
      - name: Login to ECR
        run: |
          aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com
      - name: Build and Push Docker Image
        run: |
          cd IdentityService
          docker build -t identity-service .
          docker tag identity-service:latest ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/osp/identity-service:latest
          docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/osp/identity-service:latest
      - name: Update ECS Service
        run: |
          aws ecs update-service \
            --cluster osp-microservices-cluster \
            --service identity-service \
            --force-new-deployment
```

---

## Part 6: Monitoring and Logging

### CloudWatch Configuration

**CloudWatch Logs:**
- ECS tasks send logs to CloudWatch Log Groups
- Log retention: 30 days
- Log groups:
  - `/ecs/identity-service`
  - `/ecs/enrollment-service`
  - `/ecs/payment-service`
  - etc.

**CloudWatch Metrics:**
- ECS service metrics (CPU, memory, request count)
- ALB metrics (request count, response time, error rate)
- RDS metrics (CPU, connections, storage)
- Custom application metrics

**CloudWatch Alarms:**
- High CPU utilization (>80%)
- High error rate (>5%)
- Low healthy host count
- Database connection pool exhaustion

### Application Insights

```csharp
// In Program.cs
builder.Services.AddApplicationInsightsTelemetry();

// Configure in appsettings.json
{
  "ApplicationInsights": {
    "InstrumentationKey": "your-instrumentation-key"
  }
}
```

---

## Summary: Deployment Architecture

### Components Deployed

| Component | Technology | AWS Service | URL |
|-----------|-----------|-------------|-----|
| Student Portal | Angular | S3 + CloudFront | https://student.osp.com |
| Edlio Admin Portal | Angular | S3 + CloudFront | https://admin.osp.com |
| School Admin Portal | .NET Core MVC | EC2 + ALB | https://school.osp.com |
| Identity Service API | .NET Core Web API | ECS Fargate + ALB | https://api.osp.com/api/identity |
| Enrollment Service API | .NET Core Web API | ECS Fargate + ALB | https://api.osp.com/api/enrollment |
| Payment Service API | .NET Core Web API | ECS Fargate + ALB | https://api.osp.com/api/payment |
| Other Microservices | .NET Core Web API | ECS Fargate + ALB | https://api.osp.com/api/* |

### Key Benefits

1. **Scalability**: Auto-scaling for all components
2. **High Availability**: Multi-AZ deployment, load balancing
3. **Security**: VPC isolation, security groups, SSL/TLS
4. **Cost Optimization**: Pay only for what you use
5. **Monitoring**: CloudWatch for observability
6. **CI/CD**: Automated deployment pipeline

### Deployment Checklist

- [ ] S3 buckets created and configured
- [ ] CloudFront distributions created
- [ ] Route 53 DNS configured
- [ ] SSL certificates (ACM) provisioned
- [ ] EC2 instances launched and configured
- [ ] ECS cluster and services created
- [ ] Application Load Balancers configured
- [ ] RDS databases created
- [ ] ElastiCache Redis configured
- [ ] SQS queues created
- [ ] Security groups configured
- [ ] IAM roles and policies set up
- [ ] CloudWatch alarms configured
- [ ] CI/CD pipeline configured
- [ ] Health checks passing
- [ ] Monitoring dashboards created

