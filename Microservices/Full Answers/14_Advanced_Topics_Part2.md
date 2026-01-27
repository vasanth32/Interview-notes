# Microservices Interview Answers - Advanced Topics Part 2 (Questions 271-280)

## 271. How do you implement microservices using Google Cloud?

**Google Cloud Microservices:**

1. **GKE (Google Kubernetes Engine)**
   - Managed Kubernetes
   - Container orchestration
   - Auto-scaling

2. **Cloud Functions**
   - Serverless
   - Event-driven
   - Pay per use

3. **Cloud Run**
   - Serverless containers
   - Auto-scaling
   - Pay per use

4. **Cloud Endpoints**
   - API Gateway
   - API management
   - External APIs

**Implementation:**
- Use GKE for containers
- Cloud Functions for serverless
- Cloud Run for serverless containers
- Cloud Endpoints for APIs
- Cloud Monitoring for observability

**Best Practices:**
- Use GKE for containers
- Cloud Functions for event-driven
- Cloud Run for serverless containers
- Cloud Endpoints for APIs
- Cloud Monitoring for observability

---

## 272. What is the difference between GKE and Cloud Run?

**GKE (Google Kubernetes Engine):**
- **Type**: Managed Kubernetes
- **Control**: Full Kubernetes control
- **Scaling**: Manual/auto
- **Cost**: Pay for nodes
- **Use Case**: Complex workloads

**Cloud Run:**
- **Type**: Serverless containers
- **Control**: Limited
- **Scaling**: Automatic to zero
- **Cost**: Pay per request
- **Use Case**: Simple workloads

**Comparison:**

| Aspect | GKE | Cloud Run |
|--------|-----|-----------|
| **Type** | Kubernetes | Serverless |
| **Control** | Full | Limited |
| **Scaling** | Manual/auto | Auto to zero |
| **Cost** | Nodes | Per request |

**Best Practices:**
- GKE for complex workloads
- Cloud Run for simple workloads
- Choose based on needs
- Different use cases

---

## 273. How do you handle microservices using cloud-native databases?

**Cloud-Native Databases:**

1. **Managed Databases**
   - RDS, Azure SQL, Cloud SQL
   - Managed service
   - Auto-scaling, backups

2. **NoSQL Databases**
   - DynamoDB, Cosmos DB, Firestore
   - Serverless
   - Auto-scaling

3. **Database Per Service**
   - Each service has own database
   - Independent scaling
   - Technology choice

**Best Practices:**
- Use managed databases
- Database per service
- Choose based on needs
- Monitor performance
- Backup and recovery

**Example:**
- Order Service → PostgreSQL
- User Service → MongoDB
- Cache Service → Redis
- Each service chooses best fit

---

## 274. What is the difference between managed and self-hosted databases?

**Managed Databases:**
- **Management**: Cloud provider
- **Operations**: Automated
- **Scaling**: Auto-scaling
- **Backups**: Automated
- **Cost**: Higher

**Self-Hosted Databases:**
- **Management**: Self
- **Operations**: Manual
- **Scaling**: Manual
- **Backups**: Manual
- **Cost**: Lower

**Comparison:**

| Aspect | Managed | Self-Hosted |
|--------|---------|-------------|
| **Management** | Provider | Self |
| **Operations** | Automated | Manual |
| **Scaling** | Auto | Manual |
| **Cost** | Higher | Lower |

**Best Practices:**
- Prefer managed for production
- Self-hosted for cost savings
- Consider operational overhead
- Choose based on needs

---

## 275. How do you implement microservices using cloud-native messaging?

**Cloud-Native Messaging:**

1. **Managed Message Brokers**
   - AWS SQS/SNS
   - Azure Service Bus
   - GCP Pub/Sub
   - Managed service

2. **Event Streaming**
   - AWS Kinesis
   - Azure Event Hubs
   - GCP Pub/Sub
   - Event streaming

3. **Message Queues**
   - SQS
   - Service Bus
   - Pub/Sub
   - Queuing

**Best Practices:**
- Use managed messaging
- Choose based on needs
- SQS for queuing
- Kinesis for streaming
- Monitor messaging

**Example:**
- Order Service → SQS → Payment Service
- Event streaming → Kinesis → Analytics
- Pub/Sub for event-driven

---

## 276. What is the difference between managed and self-hosted message brokers?

**Managed Message Brokers:**
- **Management**: Cloud provider
- **Operations**: Automated
- **Scaling**: Auto-scaling
- **Cost**: Pay per use
- **Features**: Limited to provider

**Self-Hosted Message Brokers:**
- **Management**: Self
- **Operations**: Manual
- **Scaling**: Manual
- **Cost**: Infrastructure
- **Features**: Full control

**Comparison:**

| Aspect | Managed | Self-Hosted |
|--------|---------|-------------|
| **Management** | Provider | Self |
| **Operations** | Automated | Manual |
| **Scaling** | Auto | Manual |
| **Cost** | Per use | Infrastructure |

**Best Practices:**
- Prefer managed for production
- Self-hosted for control
- Consider operational overhead
- Choose based on needs

---

## 277. How do you handle microservices using cloud-native monitoring?

**Cloud-Native Monitoring:**

1. **Managed Monitoring**
   - CloudWatch (AWS)
   - Azure Monitor
   - Cloud Monitoring (GCP)
   - Managed service

2. **Observability Stack**
   - Prometheus + Grafana
   - Distributed tracing
   - Log aggregation

3. **APM Tools**
   - New Relic
   - Datadog
   - Application insights

**Best Practices:**
- Use managed monitoring
- Prometheus for metrics
- Distributed tracing
- Centralized logging
- Alerting

**Example:**
- CloudWatch for AWS services
- Prometheus for custom metrics
- Jaeger for tracing
- ELK for logging

---

## 278. What is the difference between cloud-native and traditional monitoring?

**Cloud-Native Monitoring:**
- **Approach**: Distributed
- **Tools**: Prometheus, Grafana
- **Metrics**: Time-series
- **Tracing**: Distributed tracing
- **Scale**: Cloud scale

**Traditional Monitoring:**
- **Approach**: Centralized
- **Tools**: Nagios, Zabbix
- **Metrics**: SNMP, agents
- **Tracing**: Limited
- **Scale**: Limited

**Comparison:**

| Aspect | Cloud-Native | Traditional |
|--------|--------------|-------------|
| **Approach** | Distributed | Centralized |
| **Tools** | Prometheus, Grafana | Nagios, Zabbix |
| **Scale** | Cloud scale | Limited |
| **Tracing** | Distributed | Limited |

**Best Practices:**
- Use cloud-native monitoring
- Prometheus + Grafana
- Distributed tracing
- Modern observability
- Cloud scale

---

## 279. How do you implement microservices using cloud-native security?

**Cloud-Native Security:**

1. **Identity and Access**
   - IAM
   - Service accounts
   - Role-based access

2. **Network Security**
   - VPC
   - Security groups
   - Network policies

3. **Secrets Management**
   - Secrets Manager
   - Key Vault
   - Secret Manager

4. **Service Mesh**
   - mTLS
   - Policy enforcement
   - Traffic encryption

**Best Practices:**
- Use IAM for access
- Network segmentation
- Secrets management
- Service mesh mTLS
- Regular audits

**Example:**
- IAM for authentication
- VPC for network isolation
- Secrets Manager for secrets
- Service mesh for mTLS

---

## 280. What is the difference between cloud-native and traditional security?

**Cloud-Native Security:**
- **Approach**: Zero trust
- **Methods**: mTLS, IAM, policies
- **Scale**: Cloud scale
- **Automation**: Automated
- **Focus**: Identity-based

**Traditional Security:**
- **Approach**: Perimeter
- **Methods**: Firewalls, VPNs
- **Scale**: Limited
- **Automation**: Manual
- **Focus**: Network-based

**Comparison:**

| Aspect | Cloud-Native | Traditional |
|--------|--------------|-------------|
| **Approach** | Zero trust | Perimeter |
| **Methods** | mTLS, IAM | Firewalls |
| **Scale** | Cloud scale | Limited |
| **Automation** | Automated | Manual |

**Best Practices:**
- Use zero trust model
- mTLS for communication
- IAM for access
- Automated security
- Cloud-native approach

