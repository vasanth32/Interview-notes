# Microservices Interview Answers - Design Patterns (Questions 146-170)

## 146. What are the common design patterns used in microservices?

**Common Design Patterns:**

1. **API Gateway Pattern**
   - Single entry point
   - Routing, auth, rate limiting

2. **Circuit Breaker Pattern**
   - Prevent cascading failures
   - Fail fast

3. **Saga Pattern**
   - Distributed transactions
   - Compensating actions

4. **Database Per Service**
   - Each service has own database
   - Data isolation

5. **Event Sourcing**
   - Store events
   - Replay capability

6. **CQRS**
   - Separate read/write models
   - Optimized for each

7. **Bulkhead Pattern**
   - Isolate resources
   - Prevent cascading failures

8. **Sidecar Pattern**
   - Helper container
   - Cross-cutting concerns

9. **Strangler Fig Pattern**
   - Gradual migration
   - Replace monolith

10. **Backends for Frontends (BFF)**
    - Different APIs per client
    - Optimized for each

**Benefits:**
- Solve common problems
- Proven solutions
- Best practices
- Reusable patterns

---

## 147. What is the API Gateway pattern?

**API Gateway Pattern** provides a single entry point for all client requests, routing them to appropriate microservices.

**Responsibilities:**
- Request routing
- Authentication/authorization
- Rate limiting
- Load balancing
- Request/response transformation
- Monitoring

**Benefits:**
- Single entry point
- Centralized cross-cutting concerns
- Client simplification
- Security enforcement

**Example:**
```
Client → API Gateway → Microservices
         (Auth, Rate Limit, Route)
```

**Implementation:**
- Kong
- AWS API Gateway
- Zuul
- Spring Cloud Gateway

**Best Practices:**
- Single gateway for external
- Handle cross-cutting concerns
- Don't put business logic
- Monitor gateway

---

## 148. What is the circuit breaker pattern?

**Circuit Breaker Pattern** prevents cascading failures by stopping requests to a failing service and providing fallback responses.

**States:**

1. **Closed**: Normal operation, requests pass through
2. **Open**: Service failing, requests fail fast
3. **Half-Open**: Testing if service recovered

**How It Works:**
- Monitor failures
- If failure rate > threshold → Open circuit
- Return error immediately
- After timeout → Half-open
- Test request → If success → Close

**Benefits:**
- Prevents cascading failures
- Fails fast
- Gives service time to recover
- Better user experience

**Implementation:**
- Resilience4j (Java)
- Hystrix (deprecated)
- Polly (.NET)
- Istio (service mesh)

**Example:**
```java
@CircuitBreaker(name = "payment-service", fallbackMethod = "fallback")
public PaymentResult processPayment(PaymentRequest request) {
    return paymentService.process(request);
}

public PaymentResult fallback(PaymentRequest request, Exception e) {
    return PaymentResult.failed("Payment service unavailable");
}
```

---

## 149. How does the circuit breaker pattern prevent cascading failures?

**Cascading Failures:**
- Service A calls Service B
- Service B is slow/failing
- Service A waits, consumes resources
- Service A becomes slow/failing
- Affects Service C calling Service A
- Chain reaction

**How Circuit Breaker Prevents:**

1. **Fail Fast**
   - Don't wait for failing service
   - Return error immediately
   - Free resources quickly

2. **Stop Calling**
   - Open circuit stops calls
   - No resource consumption
   - Service can recover

3. **Fallback**
   - Return cached/default response
   - Partial functionality
   - Better than complete failure

4. **Recovery Testing**
   - Half-open state tests recovery
   - Gradual recovery
   - Prevents immediate failure

**Example:**
```
Without Circuit Breaker:
Service A → Service B (slow) → Service A waits → Service A slow → Service C affected

With Circuit Breaker:
Service A → Circuit Open → Fail fast → Service A OK → Service C OK
```

**Benefits:**
- Isolates failures
- Prevents propagation
- Faster recovery
- Better resilience

---

## 150. What are the states of a circuit breaker?

**Three States:**

1. **Closed (Normal)**
   - Requests pass through
   - Monitoring failures
   - Normal operation
   - If failures exceed threshold → Open

2. **Open (Failure Detected)**
   - Requests fail fast
   - Don't call failing service
   - Return error/fallback immediately
   - After timeout → Half-open

3. **Half-Open (Testing)**
   - Allow test requests
   - Check if service recovered
   - If success → Close
   - If failure → Open

**State Transitions:**
```
Closed → (Failures > threshold) → Open
Open → (Timeout) → Half-Open
Half-Open → (Success) → Closed
Half-Open → (Failure) → Open
```

**Configuration:**
- Failure threshold: When to open
- Timeout: When to test (half-open)
- Success threshold: When to close

**Example:**
- Failure threshold: 5 failures
- Timeout: 60 seconds
- Success threshold: 2 successes

---

## 151. What is the bulkhead pattern?

**Bulkhead Pattern** isolates resources (thread pools, connections) to prevent failures in one area from affecting others.

**Origin:** Ship bulkheads prevent water from spreading.

**In Microservices:**
- Isolate thread pools
- Separate connection pools
- Isolate resources
- Prevent cascading failures

**Example:**

**Without Bulkhead:**
```
Single thread pool for all services
Service A slow → Consumes all threads → Service B blocked
```

**With Bulkhead:**
```
Separate thread pools
Service A thread pool → Service A only
Service B thread pool → Service B only
Service A slow → Doesn't affect Service B
```

**Implementation:**
```java
// Separate thread pools
ExecutorService serviceAExecutor = Executors.newFixedThreadPool(10);
ExecutorService serviceBExecutor = Executors.newFixedThreadPool(10);

// Use specific executor
CompletableFuture.supplyAsync(() -> callServiceA(), serviceAExecutor);
CompletableFuture.supplyAsync(() -> callServiceB(), serviceBExecutor);
```

**Benefits:**
- Isolate failures
- Prevent resource exhaustion
- Better resilience
- Independent scaling

**Use Cases:**
- Critical vs non-critical services
- Different SLA requirements
- Resource isolation

---

## 152. What is the retry pattern and when do you use it?

**Retry Pattern** automatically retries failed operations, useful for transient failures.

**When to Use:**
- Transient failures
- Network issues
- Temporary unavailability
- Idempotent operations

**When NOT to Use:**
- Permanent failures
- Non-idempotent operations (without care)
- Long-running operations
- User-facing synchronous operations

**Retry Strategies:**

1. **Fixed Delay**
   - Same delay between retries
   - Simple
   - Example: Retry every 1 second

2. **Exponential Backoff**
   - Delay increases exponentially
   - Reduces load
   - Example: 1s, 2s, 4s, 8s

3. **Jitter**
   - Random variation
   - Prevents thundering herd
   - Better distribution

**Implementation:**
```java
@Retryable(value = {Exception.class}, maxAttempts = 3, backoff = @Backoff(delay = 1000))
public void callService() {
    // Retry on failure
}
```

**Best Practices:**
- Use for transient failures
- Implement exponential backoff
- Set max retries
- Make operations idempotent
- Use with circuit breaker

---

## 153. What is exponential backoff in retry pattern?

**Exponential Backoff** increases delay between retries exponentially, reducing load on failing service.

**How It Works:**
- Delay = baseDelay * 2^attemptNumber
- Example: 1s, 2s, 4s, 8s, 16s

**Benefits:**
- Reduces load on failing service
- Gives service time to recover
- Prevents overwhelming
- Better than fixed delay

**Example:**
```
Attempt 1: Immediate
Attempt 2: Wait 1 second
Attempt 3: Wait 2 seconds
Attempt 4: Wait 4 seconds
Attempt 5: Wait 8 seconds
```

**With Jitter:**
- Add random variation
- Prevents synchronized retries
- Better distribution
- Example: delay ± 20% random

**Implementation:**
```java
@Retryable(
    value = {Exception.class},
    maxAttempts = 5,
    backoff = @Backoff(
        delay = 1000,
        multiplier = 2,
        maxDelay = 10000
    )
)
public void callService() {
    // Exponential backoff retry
}
```

**Best Practices:**
- Use exponential backoff
- Add jitter
- Set max delay
- Limit max attempts
- Combine with circuit breaker

---

## 154. What is the timeout pattern?

**Timeout Pattern** sets maximum time to wait for a response, preventing indefinite waiting.

**Why Important:**
- Services can hang
- Network issues
- Resource exhaustion
- User experience

**Implementation:**

**HTTP Timeout:**
```java
RestTemplate restTemplate = new RestTemplate();
HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory();
factory.setConnectTimeout(5000); // 5 seconds
factory.setReadTimeout(10000); // 10 seconds
restTemplate.setRequestFactory(factory);
```

**Async Timeout:**
```java
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> callService());
String result = future.get(5, TimeUnit.SECONDS); // Timeout after 5 seconds
```

**Best Practices:**
- Set appropriate timeouts
- Different timeouts per service
- Fail fast
- Return meaningful errors
- Monitor timeout rates

**Configuration:**
- Connection timeout: Time to establish connection
- Read timeout: Time to read response
- Overall timeout: Total time allowed

---

## 155. What is the strangler fig pattern?

**Strangler Fig Pattern** gradually replaces a monolith by creating new microservices around it, eventually strangling the monolith.

**How It Works:**

1. **Identify Functionality**
   - Identify feature to extract
   - Create new microservice
   - Implement functionality

2. **Route Traffic**
   - Route new requests to microservice
   - Keep old requests to monolith
   - Gradual migration

3. **Replace**
   - Migrate remaining functionality
   - Remove monolith code
   - Complete migration

**Benefits:**
- Low risk
- Gradual migration
- No big bang
- Test incrementally

**Example:**
```
Monolith → Extract User Service → Route new requests → Migrate old → Remove monolith code
```

**Best Practices:**
- Start with independent features
- Use API Gateway for routing
- Migrate gradually
- Test thoroughly
- Monitor closely

---

## 156. How do you migrate from monolith to microservices using strangler pattern?

**Migration Steps:**

1. **Identify Feature**
   - Choose independent feature
   - Low coupling
   - Clear boundaries

2. **Create Microservice**
   - Implement feature as microservice
   - Deploy independently
   - Test thoroughly

3. **Route Traffic**
   - Use API Gateway
   - Route new requests to microservice
   - Keep old to monolith

4. **Migrate Data**
   - Migrate existing data
   - Sync if needed
   - Handle dual-write

5. **Migrate Clients**
   - Update clients gradually
   - Test each client
   - Monitor closely

6. **Remove Monolith Code**
   - After all migrated
   - Remove old code
   - Complete migration

**Example:**
```
1. Extract User Service
2. Deploy User Service
3. Route /api/users to User Service
4. Migrate user data
5. Update clients
6. Remove user code from monolith
```

**Best Practices:**
- Start small
- Independent features first
- Use API Gateway
- Test thoroughly
- Monitor migration

---

## 157. What is the database per service pattern?

**Database Per Service Pattern** ensures each microservice has its own private database.

**Key Principles:**
- Data ownership
- Technology independence
- Independent scaling
- Loose coupling

**Benefits:**
- Service independence
- Technology diversity
- Independent scaling
- Fault isolation

**Challenges:**
- Data consistency
- Distributed transactions
- Data duplication
- Querying across services

**Implementation:**
- Each service has own database
- Access via APIs only
- Use events for synchronization
- Eventually consistent

**Best Practices:**
- Never share databases
- Use APIs for access
- Event-driven sync
- Accept eventual consistency

---

## 158. What is the shared data pattern and why is it an anti-pattern?

**Shared Data Pattern** is when multiple microservices share the same database.

**Why Anti-Pattern:**

1. **Tight Coupling**
   - Services coupled via database
   - Schema changes affect multiple
   - Violates independence

2. **Scaling Issues**
   - Can't scale independently
   - Resource contention
   - One affects all

3. **Technology Lock-in**
   - All use same database
   - Can't choose best fit
   - Limits flexibility

4. **Deployment Coupling**
   - Schema changes require coordination
   - Can't deploy independently
   - Slows development

**Solution:**
- Database per service
- Access via APIs
- Use events for sync
- Independent databases

**Best Practices:**
- Avoid shared databases
- Use database per service
- Access via APIs
- Event-driven sync

---

## 159. What is the saga pattern?

**Saga Pattern** manages distributed transactions using local transactions and compensating actions.

**How It Works:**
- Break transaction into steps
- Each step is local transaction
- If step fails, execute compensating actions
- Eventually consistent

**Types:**

1. **Choreography-Based**
   - Services coordinate via events
   - No central coordinator
   - Decentralized

2. **Orchestration-Based**
   - Central orchestrator
   - Coordinates steps
   - Centralized control

**Example:**
```
Order Processing Saga:
1. Create Order → If fails: Nothing
2. Reserve Inventory → If fails: Cancel Order
3. Process Payment → If fails: Release Inventory, Cancel Order
4. Create Shipment → If fails: Refund, Release Inventory, Cancel Order
```

**Benefits:**
- Distributed transactions
- No blocking
- Scalable
- Eventually consistent

---

## 160. What are the different types of saga patterns?

**Two Types:**

### 1. Choreography-Based Saga

**Characteristics:**
- No central coordinator
- Services coordinate via events
- Decentralized control

**Flow:**
```
Service A completes → Publishes event
Service B subscribes → Processes → Publishes event
Service C subscribes → Processes → Publishes event
```

**Pros:**
- Loose coupling
- No single point of failure
- Scalable

**Cons:**
- Hard to understand flow
- Difficult to debug

### 2. Orchestration-Based Saga

**Characteristics:**
- Central orchestrator
- Orchestrator coordinates steps
- Centralized control

**Flow:**
```
Orchestrator → Calls Service A
If success → Calls Service B
If failure → Executes compensations
```

**Pros:**
- Clear workflow
- Easy to understand
- Centralized control

**Cons:**
- Orchestrator can bottleneck
- Additional service

**Choose:**
- Choreography: Simple workflows, event-driven
- Orchestration: Complex workflows, need control

**When to Use Which (Scenarios):**

**Use Choreography-Based Saga when:**
- Workflows are **simple and mostly linear**
  - Example: `OrderPlaced` → `ReserveInventory` → `ProcessPayment` → `SendConfirmation`
  - Each service just reacts to an event and publishes the next one.
- Teams/services are **highly decoupled**
  - Example: Inventory, Payment, Notification are owned by different teams that only agree on event contracts (`OrderPaid`, `OrderCancelled`).
- You already have a **strong event-driven architecture**
  - Example: System is built around topics/queues (Kafka, RabbitMQ, Service Bus) and services are natural publishers/subscribers.
- It’s okay if each service **controls only its own behavior**
  - Example: Notification Service decides on email/SMS based on its rules without a central workflow brain.

**Use Orchestration-Based Saga when:**
- Workflows are **complex with many branches and conditions**
  - Example: Loan application: credit check, fraud check, document verification, manual approval, each with different compensations.
- You need **clear visibility and central control** of the whole process
  - Example: Business wants a single place to see: current step, which step failed, what compensating actions ran.
- You require **strict ordering and business rules**
  - Example: KYC → Create Account → Issue Card → Activate; if activation fails, roll back some but not all previous steps.
- **Auditing/compliance** is important
  - Example: Banking/healthcare where you must prove which steps were executed, when, and with what result.

---

## 161. What is the event sourcing pattern?

**Event Sourcing** stores all changes as events rather than current state.

**How It Works:**
- Store events (what happened)
- Don't store current state
- Replay events to get state
- Complete history

**Example:**
```
Events:
- OrderCreated (orderId: 123, amount: 100)
- PaymentProcessed (orderId: 123)
- OrderShipped (orderId: 123)

Current State: Order 123 - Created, Paid, Shipped
```

**Benefits:**
- Complete audit trail
- Time travel
- Debugging
- Replay capability

**Challenges:**
- Complexity
- Storage requirements
- Replay performance

**Use When:**
- Need audit trail
- Event-driven architecture
- Complex domain
- Compliance requirements

---

## 162. What is the CQRS pattern?

**CQRS (Command Query Responsibility Segregation)** separates read and write operations into different models.

**Key Concepts:**
- Command side: Writes
- Query side: Reads
- Different models
- Optimized for each

**Benefits:**
- Optimized reads
- Optimized writes
- Independent scaling
- Performance

**When to Use:**
- Different read/write patterns
- Complex queries
- High read load
- Performance critical

**Implementation:**
- Write: Normalized model
- Read: Denormalized model
- Sync via events

**Best Practices:**
- Use when needed
- Sync via events
- Accept eventual consistency
- Monitor sync lag

---

## 163. What is the aggregator pattern?

**Aggregator Pattern** collects data from multiple services and returns aggregated response.

**How It Works:**
- Client requests aggregated data
- Aggregator calls multiple services
- Combines responses
- Returns single response

**Example:**
```
Client → Aggregator → User Service
                    → Order Service
                    → Payment Service
         ← Combined Response
```

**Benefits:**
- Single request
- Reduced latency
- Simplified client
- Better performance

**Use Cases:**
- Dashboard data
- Composite views
- Data aggregation

**Implementation:**
```java
@Service
public class DashboardAggregator {
    public DashboardData getDashboard(String userId) {
        User user = userService.getUser(userId);
        List<Order> orders = orderService.getOrders(userId);
        PaymentInfo payment = paymentService.getPaymentInfo(userId);
        
        return new DashboardData(user, orders, payment);
    }
}
```

---

## 164. What is the proxy pattern in microservices?

**Proxy Pattern** provides a surrogate or placeholder for another object to control access.

**In Microservices:**

1. **API Gateway as Proxy**
   - Proxies requests to services
   - Adds cross-cutting concerns
   - Load balancing

2. **Service Proxy**
   - Proxy for service calls
   - Adds retry, circuit breaker
   - Abstraction layer

**Types:**

1. **Virtual Proxy**
   - Lazy loading
   - Create on demand

2. **Protection Proxy**
   - Access control
   - Security

3. **Remote Proxy**
   - Network communication
   - Service calls

**Example:**
```java
@Service
public class OrderServiceProxy {
    @CircuitBreaker(name = "order-service")
    @Retryable
    public Order getOrder(String id) {
        return orderServiceClient.getOrder(id);
    }
}
```

**Benefits:**
- Abstraction
- Cross-cutting concerns
- Control access
- Load balancing

---

## 165. What is the branch pattern?

**Branch Pattern** extends aggregator pattern to call multiple services in parallel and combine results.

**How It Works:**
- Aggregator calls multiple services
- Services called in parallel
- Results combined
- Single response

**Example:**
```
Aggregator → Service A (parallel)
           → Service B (parallel)
           → Service C (parallel)
         ← Combine Results
```

**Benefits:**
- Parallel execution
- Reduced latency
- Better performance
- Efficient

**Implementation:**
```java
@Service
public class BranchAggregator {
    public CombinedData getData(String id) {
        CompletableFuture<DataA> futureA = CompletableFuture.supplyAsync(() -> serviceA.getData(id));
        CompletableFuture<DataB> futureB = CompletableFuture.supplyAsync(() -> serviceB.getData(id));
        CompletableFuture<DataC> futureC = CompletableFuture.supplyAsync(() -> serviceC.getData(id));
        
        CompletableFuture.allOf(futureA, futureB, futureC).join();
        
        return new CombinedData(futureA.get(), futureB.get(), futureC.get());
    }
}
```

**Best Practices:**
- Use for independent calls
- Handle failures
- Set timeouts
- Monitor performance

---

## 166. What is the chained microservices pattern?

**Chained Microservices Pattern** chains services where output of one becomes input to next.

**How It Works:**
```
Service A → Service B → Service C → Response
```

**Characteristics:**
- Sequential calls
- Output → Input
- Chain of services
- Synchronous

**Example:**
```
Order Service → Payment Service → Inventory Service → Shipping Service
```

**Benefits:**
- Simple flow
- Clear sequence
- Easy to understand

**Drawbacks:**
- Sequential latency
- Single point of failure
- Tight coupling

**Use When:**
- Sequential processing needed
- Simple workflows
- Synchronous required

**Best Practices:**
- Use for sequential flows
- Handle failures
- Set timeouts
- Consider async alternatives

---

## 167. What is the sidecar pattern?

**Sidecar Pattern** deploys helper container alongside main application container.

**How It Works:**
- Main container: Application
- Sidecar container: Helper functionality
- Share network/storage
- Co-located

**Use Cases:**
- Logging
- Monitoring
- Service mesh (Envoy)
- Configuration

**Example - Kubernetes:**
```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    image: my-app
  - name: sidecar
    image: logging-sidecar
    # Collects logs from app
```

**Benefits:**
- Separation of concerns
- Reusable sidecars
- Language agnostic
- Independent deployment

**Service Mesh:**
- Envoy sidecar per pod
- Handles traffic
- mTLS, routing
- Observability

---

## 168. What is the ambassador pattern?

**Ambassador Pattern** provides helper service that acts as outbound proxy for main service.

**How It Works:**
- Ambassador handles external communication
- Main service talks to ambassador
- Ambassador talks to external services
- Abstraction layer

**Use Cases:**
- Service discovery
- Retry logic
- Circuit breaking
- Monitoring

**Example:**
```
Main Service → Ambassador → External Service
             (handles retry, circuit breaker)
```

**Benefits:**
- Offload complexity
- Reusable logic
- Language agnostic
- Independent updates

**Difference from Sidecar:**
- Sidecar: Co-located, shared resources
- Ambassador: Separate service, network communication

---

## 169. What is the adapter pattern in microservices?

**Adapter Pattern** allows incompatible interfaces to work together.

**In Microservices:**

1. **Protocol Adapter**
   - Convert protocols
   - REST to gRPC
   - HTTP to message queue

2. **Data Adapter**
   - Transform data formats
   - JSON to XML
   - Different schemas

3. **Legacy Adapter**
   - Integrate legacy systems
   - Wrap old APIs
   - Modernize gradually

**Example:**
```java
@Component
public class LegacyAdapter {
    public Order convertLegacyOrder(LegacyOrder legacy) {
        return new Order(
            legacy.getOrderNumber(),
            legacy.getAmount(),
            convertDate(legacy.getDate())
        );
    }
}
```

**Benefits:**
- Integrate incompatible systems
- Gradual migration
- Protocol conversion
- Data transformation

**Use Cases:**
- Legacy integration
- Protocol conversion
- Data transformation
- API versioning

---

## 170. What is the backends for frontends (BFF) pattern?

**BFF Pattern** creates separate backend services optimized for specific frontend clients.

**How It Works:**
- Different BFF per client type
- BFF optimized for client needs
- BFF calls microservices
- Client-specific API

**Example:**
```
Web BFF → Web-optimized API → Microservices
Mobile BFF → Mobile-optimized API → Microservices
Admin BFF → Admin-optimized API → Microservices
```

**Benefits:**
- Client-specific optimization
- Different data formats
- Reduced over-fetching
- Better performance

**Use Cases:**
- Multiple client types
- Different requirements
- Performance optimization
- Client-specific needs

**Implementation:**
- Separate BFF services
- Optimize per client
- Aggregate data
- Transform responses

**Best Practices:**
- Create BFF per client type
- Optimize for client needs
- Don't duplicate business logic
- Keep BFF thin

