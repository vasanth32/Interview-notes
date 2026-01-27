# Microservices Interview Answers - Architecture Decisions & Trade-offs (Questions 461-480)

## 461. When would you choose synchronous over asynchronous communication?

**Choose Synchronous When:**

1. **Immediate Response Needed**
   - User needs immediate feedback
   - Real-time requirements
   - Interactive applications

2. **Simple Request/Response**
   - Straightforward operations
   - No complex workflows
   - Direct communication

3. **Transactional Operations**
   - Need immediate confirmation
   - ACID requirements
   - Consistency critical

4. **Read Operations**
   - Fetching current data
   - Query operations
   - Data retrieval

**Best Practices:**
- Use sync for immediate response
- Use async for workflows
- Balance based on needs
- Consider user experience

---

## 462. When would you choose REST over gRPC?

**Choose REST When:**

1. **Public APIs**
   - External APIs
   - Browser clients
   - Wide compatibility

2. **Human Readability**
   - Easy debugging
   - JSON format
   - Developer-friendly

3. **HTTP Caching**
   - Need HTTP caching
   - CDN integration
   - Cache benefits

4. **Simple Use Cases**
   - CRUD operations
   - Simple APIs
   - Standard HTTP

**Best Practices:**
- REST for public APIs
- gRPC for internal
- Choose based on needs
- Consider compatibility

---

## 463. When would you choose SQL over NoSQL for a microservice?

**Choose SQL When:**

1. **Structured Data**
   - Relational data
   - Complex relationships
   - ACID requirements

2. **Transactions**
   - Need transactions
   - Strong consistency
   - Data integrity

3. **Complex Queries**
   - Joins needed
   - Complex queries
   - Reporting

4. **Mature Ecosystem**
   - Existing SQL skills
   - Mature tools
   - Proven technology

**Best Practices:**
- SQL for structured data
- NoSQL for unstructured
- Choose based on data
- Consider requirements

---

## 464. When would you choose event-driven over request-driven architecture?

**Choose Event-Driven When:**

1. **Loose Coupling**
   - Need loose coupling
   - Independent services
   - Decoupled workflows

2. **Async Workflows**
   - Long-running processes
   - Background processing
   - Can tolerate delay

3. **High Scalability**
   - High throughput
   - Event streaming
   - Scalable processing

4. **Event Sourcing**
   - Need event history
   - Audit trail
   - Replay capability

**Best Practices:**
- Event-driven for workflows
- Request-driven for immediate
- Choose based on needs
- Can combine both

---

## 465. When would you choose orchestration over choreography?

**Choose Orchestration When:**

1. **Complex Workflows**
   - Many steps
   - Complex logic
   - Centralized control needed

2. **Need Control**
   - Centralized control
   - Clear workflow
   - Easier debugging

3. **Error Handling**
   - Complex error handling
   - Centralized recovery
   - Better error management

**Best Practices:**
- Orchestration for complex
- Choreography for simple
- Choose based on complexity
- Consider control needs

---

## 466. When would you choose API Gateway over service mesh?

**Choose API Gateway When:**

1. **External Access**
   - External clients
   - Public APIs
   - Client-facing

2. **API Management**
   - API versioning
   - Rate limiting
   - API documentation

3. **Single Entry Point**
   - Need single entry
   - Centralized auth
   - Simplified client

**Best Practices:**
- API Gateway for external
- Service Mesh for internal
- Can use both
- Different purposes

---

## 467. When would you choose centralized logging over distributed logging?

**Choose Centralized When:**

1. **Correlation Needed**
   - Need to correlate logs
   - Cross-service debugging
   - Unified search

2. **Compliance**
   - Audit requirements
   - Compliance needs
   - Centralized storage

3. **Analysis**
   - Log analysis
   - Pattern detection
   - Reporting

**Best Practices:**
- Centralized for correlation
- Distributed for scale
- Choose based on needs
- Consider compliance

---

## 468. When would you choose strong consistency over eventual consistency?

**Choose Strong Consistency When:**

1. **Critical Data**
   - Financial data
   - Payment processing
   - Critical operations

2. **User Experience**
   - Immediate consistency needed
   - User expects consistency
   - Real-time updates

3. **Business Requirements**
   - Business requires consistency
   - Regulatory requirements
   - Data integrity critical

**Best Practices:**
- Strong for critical data
- Eventual for most cases
- Choose based on requirements
- Balance consistency and availability

---

## 469. When would you choose blue-green over canary deployment?

**Choose Blue-Green When:**

1. **Zero Downtime Critical**
   - Zero downtime required
   - Quick rollback needed
   - Instant switch

2. **Thoroughly Tested**
   - Changes tested thoroughly
   - Low risk
   - Confidence in changes

3. **Simple Rollout**
   - Simple deployment
   - No gradual rollout needed
   - Full switch acceptable

**Best Practices:**
- Blue-green for tested changes
- Canary for high-risk
- Choose based on risk
- Consider downtime tolerance

---

## 470. When would you choose containers over serverless?

**Choose Containers When:**

1. **Long-Running Services**
   - Long-running processes
   - Stateful services
   - Persistent connections

2. **Full Control**
   - Need full control
   - Custom runtime
   - Specific requirements

3. **Predictable Workloads**
   - Steady workload
   - Predictable traffic
   - Reserved capacity

**Best Practices:**
- Containers for long-running
- Serverless for event-driven
- Choose based on workload
- Consider control needs

---

## 471. When would you choose Kubernetes over Docker Swarm?

**Choose Kubernetes When:**

1. **Complex Requirements**
   - Complex orchestration
   - Advanced features
   - Enterprise needs

2. **Large Scale**
   - Large clusters
   - Many services
   - High scale

3. **Ecosystem**
   - Need large ecosystem
   - Third-party tools
   - Community support

**Best Practices:**
- Kubernetes for complex
- Docker Swarm for simple
- Choose based on needs
- Consider complexity

---

## 472. When would you choose Kafka over RabbitMQ?

**Choose Kafka When:**

1. **High Throughput**
   - Millions of messages
   - High volume
   - Event streaming

2. **Event Sourcing**
   - Need event history
   - Replay capability
   - Event log

3. **Multiple Consumers**
   - Many consumers
   - Independent consumption
   - Event streaming

**Best Practices:**
- Kafka for high throughput
- RabbitMQ for queuing
- Choose based on needs
- Consider use case

---

## 473. When would you choose CQRS over traditional CRUD?

**Choose CQRS When:**

1. **Different Read/Write Patterns**
   - Different patterns
   - Optimize separately
   - Performance critical

2. **High Read Load**
   - High read volume
   - Complex queries
   - Read optimization needed

3. **Complex Queries**
   - Complex read queries
   - Denormalized views
   - Query optimization

**Best Practices:**
- CQRS for different patterns
- CRUD for simple
- Choose based on needs
- Consider complexity

---

## 474. When would you choose event sourcing over traditional persistence?

**Choose Event Sourcing When:**

1. **Audit Trail Needed**
   - Complete history
   - Compliance
   - Audit requirements

2. **Event-Driven Architecture**
   - Event-driven system
   - Natural fit
   - Event history

3. **Time Travel**
   - Need to replay
   - Debugging
   - Historical analysis

**Best Practices:**
- Event sourcing for audit
- Traditional for simple
- Choose based on needs
- Consider complexity

---

## 475. When would you choose saga pattern over distributed transactions?

**Choose Saga When:**

1. **Microservices**
   - Distributed services
   - Independent databases
   - No shared transactions

2. **Long-Running**
   - Long transactions
   - Can tolerate delay
   - Eventually consistent OK

3. **Scalability**
   - Need scalability
   - High performance
   - No blocking

**Best Practices:**
- Saga for microservices
- Distributed transactions avoided
- Choose saga
- Eventually consistent

---

## 476. When would you choose circuit breaker over retry pattern?

**Choose Circuit Breaker When:**

1. **Service Failing**
   - Service is down
   - Persistent failures
   - Not transient

2. **Prevent Cascading**
   - Prevent failures
   - Protect system
   - Fail fast

3. **Give Time to Recover**
   - Service needs recovery
   - Stop calling
   - Recovery time

**Best Practices:**
- Circuit breaker for failing
- Retry for transient
- Can combine both
- Choose based on failure type

---

## 477. When would you choose service mesh over API Gateway?

**Choose Service Mesh When:**

1. **Internal Communication**
   - Service-to-service
   - Internal traffic
   - East-West traffic

2. **Comprehensive Features**
   - Need mTLS, observability
   - Traffic management
   - Policy enforcement

3. **Infrastructure Layer**
   - Infrastructure concerns
   - Transparent to apps
   - Sidecar pattern

**Best Practices:**
- Service mesh for internal
- API Gateway for external
- Can use both
- Different purposes

---

## 478. When would you choose centralized over decentralized governance?

**Choose Centralized When:**

1. **Consistency Needed**
   - Need consistency
   - Standardization
   - Uniform policies

2. **Compliance**
   - Compliance requirements
   - Centralized control
   - Audit needs

3. **Small Organization**
   - Small organization
   - Centralized easier
   - Less complexity

**Best Practices:**
- Centralized for consistency
- Decentralized for autonomy
- Choose based on needs
- Balance control and autonomy

---

## 479. When would you choose monolith over microservices?

**Choose Monolith When:**

1. **Small Team**
   - Small team
   - Simple application
   - Limited complexity

2. **Simple Domain**
   - Simple business domain
   - No clear boundaries
   - Tightly coupled

3. **Early Stage**
   - Early stage startup
   - Rapid iteration
   - Unknown requirements

**Best Practices:**
- Monolith for simple
- Microservices for complex
- Start simple
- Evolve as needed

---

## 480. When would you choose microservices over serverless?

**Choose Microservices When:**

1. **Long-Running**
   - Long-running processes
   - Persistent connections
   - Stateful services

2. **Full Control**
   - Need full control
   - Custom runtime
   - Specific requirements

3. **Predictable Workloads**
   - Steady workload
   - Predictable traffic
   - Reserved capacity

**Best Practices:**
- Microservices for long-running
- Serverless for event-driven
- Choose based on workload
- Consider control needs

