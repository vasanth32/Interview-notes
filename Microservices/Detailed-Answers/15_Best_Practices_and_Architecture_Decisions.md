# Microservices Interview Answers - Best Practices & Architecture Decisions (Questions 281-300)

## 281. What are the best practices for designing microservices?

**Best Practices:**

1. **Service Boundaries**
   - Domain-driven design
   - Single responsibility
   - Clear boundaries

2. **Independence**
   - Independent deployment
   - Own database
   - Technology choice

3. **Communication**
   - APIs for communication
   - Async when possible
   - Event-driven

4. **Resilience**
   - Circuit breakers
   - Retries
   - Fallbacks

5. **Observability**
   - Logging
   - Metrics
   - Tracing

6. **Security**
   - Authentication
   - Authorization
   - mTLS

**Best Practices Summary:**
- Right size services
- Database per service
- API-first design
- Design for failure
- Comprehensive observability
- Security by design

---

## 282. How do you determine the right size of a microservice?

**Factors:**

1. **Business Capability**
   - Single business capability
   - Cohesive functionality
   - Clear boundaries

2. **Team Size**
   - 2-pizza team
   - Can be maintained by small team
   - Team ownership

3. **Deployment Frequency**
   - Independent deployment
   - Can deploy independently
   - No coordination needed

4. **Data Ownership**
   - Own data
   - Clear data boundaries
   - Independent data model

**Guidelines:**
- Not too small (nanoservices)
- Not too large (distributed monolith)
- Right size for team
- Single business capability

**Best Practices:**
- Start with business capability
- Adjust based on team
- Monitor size
- Refactor if needed

---

## 283. What is the difference between too small and too large microservices?

**Too Small (Nanoservices):**
- **Size**: Single function/method
- **Overhead**: Too high
- **Network**: Excessive calls
- **Problem**: Overhead > value

**Too Large (Distributed Monolith):**
- **Size**: Multiple capabilities
- **Coupling**: High coupling
- **Deployment**: Coordinated
- **Problem**: No independence

**Right Size:**
- **Size**: Single business capability
- **Overhead**: Acceptable
- **Independence**: High
- **Balance**: Overhead vs value

**Comparison:**

| Aspect | Too Small | Right Size | Too Large |
|--------|-----------|------------|----------|
| **Size** | Function | Capability | Multiple |
| **Overhead** | Too high | Acceptable | Low |
| **Independence** | High | High | Low |

**Best Practices:**
- Avoid nanoservices
- Avoid distributed monolith
- Right size for capability
- Balance overhead

---

## 284. How do you handle service boundaries?

**Service Boundaries:**

1. **Domain-Driven Design**
   - Bounded contexts
   - Domain models
   - Clear boundaries

2. **Data Ownership**
   - Own data
   - No shared databases
   - Clear data boundaries

3. **API Boundaries**
   - Well-defined APIs
   - Versioning
   - Clear contracts

4. **Team Boundaries**
   - Team ownership
   - Conway's Law
   - Team autonomy

**Best Practices:**
- Use DDD for boundaries
- Database per service
- Clear APIs
- Team ownership
- Document boundaries

**Example:**
- Order Service: Order management
- Payment Service: Payment processing
- Shipping Service: Shipping management
- Each owns its domain

---

## 285. What is the difference between domain-driven design and microservices?

**Domain-Driven Design (DDD):**
- **Focus**: Domain modeling
- **Approach**: Design methodology
- **Concepts**: Bounded contexts, aggregates
- **Scope**: Design approach

**Microservices:**
- **Focus**: Architecture style
- **Approach**: Service decomposition
- **Concepts**: Services, APIs
- **Scope**: Architecture

**Relationship:**
- DDD helps identify microservices
- Bounded contexts = microservices
- DDD guides service boundaries
- Complementary

**Comparison:**

| Aspect | DDD | Microservices |
|--------|-----|---------------|
| **Focus** | Domain | Architecture |
| **Approach** | Design | Decomposition |
| **Relationship** | Guides | Implementation |

**Best Practices:**
- Use DDD for boundaries
- Bounded contexts = services
- Domain models per service
- Complementary approaches

---

## 286. How do you implement microservices using DDD?

**DDD Implementation:**

1. **Identify Bounded Contexts**
   - Domain analysis
   - Identify contexts
   - Map to services

2. **Define Aggregates**
   - Domain aggregates
   - Aggregate roots
   - Service boundaries

3. **Domain Events**
   - Domain events
   - Event-driven communication
   - Service integration

4. **Ubiquitous Language**
   - Common language
   - Domain terms
   - Clear communication

**Example:**
- Order Bounded Context → Order Service
- Payment Bounded Context → Payment Service
- Shipping Bounded Context → Shipping Service

**Best Practices:**
- Use DDD for boundaries
- Bounded contexts = services
- Domain events for communication
- Ubiquitous language

---

## 287. What is the difference between bounded context and microservice?

**Bounded Context:**
- **Type**: DDD concept
- **Focus**: Domain boundary
- **Scope**: Domain model
- **Purpose**: Design boundary

**Microservice:**
- **Type**: Architecture pattern
- **Focus**: Service boundary
- **Scope**: Service implementation
- **Purpose**: Deployment unit

**Relationship:**
- Bounded context often = microservice
- But not always
- Can have multiple services per context
- Can have multiple contexts per service (avoid)

**Comparison:**

| Aspect | Bounded Context | Microservice |
|--------|----------------|--------------|
| **Type** | Design concept | Architecture |
| **Focus** | Domain | Service |
| **Relationship** | Often same | Implementation |

**Best Practices:**
- Align bounded contexts with services
- One context = one service (preferred)
- Clear mapping
- Document relationship

---

## 288. How do you handle shared kernel in microservices?

**Shared Kernel:**
- **Definition**: Shared domain model
- **Problem**: Tight coupling
- **Solution**: Avoid or minimize

**Strategies:**

1. **Avoid Shared Kernel**
   - Each service has own model
   - No shared domain code
   - Independence

2. **Minimal Shared Libraries**
   - Only utilities
   - No business logic
   - Common code only

3. **API Contracts**
   - Share contracts/interfaces
   - Not implementations
   - Language-agnostic

**Best Practices:**
- Avoid shared kernel
- Minimal shared libraries
- Share contracts, not code
- Independence first

**Anti-Pattern:**
- Shared business logic
- Tight coupling
- Deployment coupling

---

## 289. What is the difference between shared kernel and shared library?

**Shared Kernel:**
- **Type**: DDD concept
- **Content**: Domain model
- **Problem**: Tight coupling
- **Scope**: Domain

**Shared Library:**
- **Type**: Code library
- **Content**: Code/utilities
- **Problem**: Can cause coupling
- **Scope**: Code

**Comparison:**

| Aspect | Shared Kernel | Shared Library |
|--------|---------------|----------------|
| **Type** | Domain concept | Code library |
| **Content** | Domain model | Code |
| **Problem** | Tight coupling | Can cause coupling |

**Best Practices:**
- Avoid shared kernel
- Minimize shared libraries
- Only utilities
- No business logic

---

## 290. How do you implement microservices using event-driven architecture?

**Event-Driven Microservices:**

1. **Event Producers**
   - Services publish events
   - Domain events
   - Business events

2. **Event Consumers**
   - Services subscribe to events
   - React to events
   - Process events

3. **Event Bus**
   - Message broker
   - Event routing
   - Event distribution

**Architecture:**
```
Service A → Publishes Event → Event Bus → Service B (subscribes)
```

**Best Practices:**
- Use events for communication
- Domain events
- Event sourcing
- Event-driven workflows
- Async communication

**Example:**
- OrderCreated event → Inventory, Payment, Shipping subscribe
- Event-driven order processing
- Loose coupling

---

## 291. What is the difference between event-driven and request-driven architecture?

**Event-Driven:**
- **Communication**: Async events
- **Coupling**: Loose
- **Pattern**: Pub/sub
- **Use Case**: Event-driven workflows

**Request-Driven:**
- **Communication**: Sync requests
- **Coupling**: Tighter
- **Pattern**: Request/response
- **Use Case**: Immediate responses

**Comparison:**

| Aspect | Event-Driven | Request-Driven |
|--------|--------------|----------------|
| **Communication** | Async | Sync |
| **Coupling** | Loose | Tighter |
| **Pattern** | Pub/sub | Request/response |
| **Latency** | Acceptable delay | Immediate |

**Best Practices:**
- Use event-driven for workflows
- Use request-driven for immediate responses
- Combine both
- Choose based on needs

---

## 292. How do you handle microservices using CQRS?

**CQRS in Microservices:**

1. **Command Side**
   - Write operations
   - Optimized for writes
   - Domain model

2. **Query Side**
   - Read operations
   - Optimized for reads
   - Denormalized views

3. **Event Sync**
   - Events sync read models
   - Eventually consistent
   - Event-driven

**Best Practices:**
- Separate read/write models
- Optimize each
- Sync via events
- Accept eventual consistency
- Monitor sync lag

**Example:**
- Write: Normalized relational DB
- Read: Denormalized document DB
- Sync: Events update read model

---

## 293. What is the difference between CQRS and event sourcing?

**CQRS:**
- **Focus**: Read/write separation
- **Storage**: Current state
- **Purpose**: Optimization
- **Can use**: With or without event sourcing

**Event Sourcing:**
- **Focus**: Event storage
- **Storage**: Events only
- **Purpose**: Audit trail, replay
- **Can use**: With CQRS

**Comparison:**

| Aspect | CQRS | Event Sourcing |
|--------|------|----------------|
| **Focus** | Read/write | Event storage |
| **Storage** | State | Events |
| **Purpose** | Optimization | Audit, replay |

**Common Combination:**
- Event sourcing for write side
- CQRS for read side
- Events populate read models
- Best of both

**Best Practices:**
- Use CQRS for optimization
- Use event sourcing for audit
- Can combine both
- Choose based on needs

---

## 294. How do you implement microservices using API Gateway?

**API Gateway Implementation:**

1. **Choose Gateway**
   - Kong, AWS API Gateway
   - Spring Cloud Gateway
   - Choose based on needs

2. **Configure Routing**
   - Route to services
   - Path-based routing
   - Load balancing

3. **Add Cross-Cutting Concerns**
   - Authentication
   - Rate limiting
   - Monitoring

**Example:**
```
Client → API Gateway → Order Service
                    → Payment Service
                    → User Service
```

**Best Practices:**
- Single gateway for external
- Handle cross-cutting concerns
- Don't put business logic
- Monitor gateway
- Version APIs

---

## 295. What is the difference between API Gateway and service mesh?

**API Gateway:**
- **Traffic**: North-South (external)
- **Placement**: Edge
- **Pattern**: Centralized
- **Focus**: External APIs

**Service Mesh:**
- **Traffic**: East-West (internal)
- **Placement**: Everywhere
- **Pattern**: Sidecar
- **Focus**: Internal communication

**Comparison:**

| Aspect | API Gateway | Service Mesh |
|--------|-------------|--------------|
| **Traffic** | External | Internal |
| **Placement** | Edge | Everywhere |
| **Pattern** | Centralized | Sidecar |

**Can Use Both:**
- API Gateway for external
- Service Mesh for internal
- Complementary
- Different concerns

---

## 296. How do you handle microservices using service discovery?

**Service Discovery:**

1. **Choose Tool**
   - Eureka, Consul
   - Kubernetes Services
   - Choose based on needs

2. **Register Services**
   - Services register on startup
   - Health checks
   - Metadata

3. **Discover Services**
   - Query registry
   - Get instances
   - Load balancing

**Best Practices:**
- Use service discovery
- Health checks
- Client-side caching
- Monitor registry
- High availability

**Example:**
- Services register with Eureka
- Clients query Eureka
- Get list of instances
- Load balance requests

---

## 297. What is the difference between service discovery and load balancing?

**Service Discovery:**
- **Purpose**: Find services
- **Function**: Service registry
- **Scope**: Service location
- **Part of**: Load balancing

**Load Balancing:**
- **Purpose**: Distribute requests
- **Function**: Request distribution
- **Scope**: Request routing
- **Uses**: Service discovery

**Comparison:**

| Aspect | Service Discovery | Load Balancing |
|--------|------------------|----------------|
| **Purpose** | Find services | Distribute requests |
| **Function** | Registry | Distribution |
| **Relationship** | Part of | Uses discovery |

**Best Practices:**
- Service discovery finds services
- Load balancing distributes requests
- Work together
- Complementary

---

## 298. How do you implement microservices using circuit breaker?

**Circuit Breaker Implementation:**

1. **Choose Library**
   - Resilience4j (Java)
   - Polly (.NET)
   - Choose based on language

2. **Configure**
   - Failure threshold
   - Timeout
   - Fallback

3. **Monitor**
   - Circuit state
   - Failure rates
   - Alert on opens

**Example:**
```java
@CircuitBreaker(name = "payment-service", fallbackMethod = "fallback")
public PaymentResult processPayment(PaymentRequest request) {
    return paymentService.process(request);
}

public PaymentResult fallback(PaymentRequest request, Exception e) {
    return PaymentResult.failed("Service unavailable");
}
```

**Best Practices:**
- Implement circuit breakers
- Set appropriate thresholds
- Provide fallbacks
- Monitor state
- Test behavior

---

## 299. What is the difference between circuit breaker and retry pattern?

**Circuit Breaker:**
- **Purpose**: Prevent cascading failures
- **Action**: Stop calling failing service
- **State**: Open/Closed/Half-Open
- **Use Case**: Failing service

**Retry Pattern:**
- **Purpose**: Handle transient failures
- **Action**: Retry failed requests
- **State**: Retry count
- **Use Case**: Transient failures

**Comparison:**

| Aspect | Circuit Breaker | Retry |
|--------|----------------|-------|
| **Purpose** | Prevent failures | Handle failures |
| **Action** | Stop calling | Retry |
| **Use Case** | Failing service | Transient failures |

**Best Practices:**
- Use retry for transient failures
- Use circuit breaker for failing services
- Can combine both
- Retry → Circuit breaker

---

## 300. How do you handle microservices using saga pattern?

**Saga Pattern Implementation:**

1. **Choose Type**
   - Choreography-based
   - Orchestration-based
   - Choose based on needs

2. **Define Steps**
   - Break transaction into steps
   - Each step = local transaction
   - Define compensations

3. **Implement**
   - Execute steps
   - Handle failures
   - Execute compensations

**Example:**
```
Order Saga:
1. Create Order
2. Reserve Inventory → Compensate: Release Inventory
3. Process Payment → Compensate: Refund, Release Inventory
4. Create Shipment → Compensate: Cancel Shipment, Refund, Release Inventory
```

**Best Practices:**
- Use saga for distributed transactions
- Implement compensating actions
- Make idempotent
- Monitor sagas
- Test failure scenarios

