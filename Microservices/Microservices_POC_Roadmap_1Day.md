# Microservices POC Roadmap - 1 Day Implementation

> **Goal**: Build 3 practical POCs to understand latency optimization, resilience patterns, and Event Sourcing + CQRS

---

## 📋 Overview

**Time Allocation (8 hours):**
- **POC 1**: Latency Optimization (2.5 hours)
- **POC 2**: Resilience & Troubleshooting (2.5 hours)
- **POC 3**: Event Sourcing + CQRS (3 hours)

**Tech Stack:**
- .NET 8 (ASP.NET Core Web API)
- AWS: API Gateway, Lambda, SQS, DynamoDB, CloudWatch
- OR Azure: API Management, Functions, Service Bus, Cosmos DB, Application Insights
- Docker (optional, for local testing)

---

## 🎯 POC 1: Improving Microservice Latency Under High Traffic

### Architecture Flow

```
┌─────────────┐
│   Client    │
│  (LoadGen)  │
└──────┬──────┘
       │ HTTP Requests
       ▼
┌─────────────────────────────────────┐
│      API Gateway / Load Balancer     │
│  (Rate Limiting, Caching Headers)    │
└──────┬───────────────────────────────┘
       │
       ├─────────────────┬─────────────────┐
       ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Service A   │  │  Service B   │  │  Service C   │
│  (Product)   │  │  (Order)      │  │  (Payment)   │
│              │  │              │  │              │
│  - Caching   │  │  - Async     │  │  - Circuit   │
│  - DB Pool   │  │  - Queue    │  │    Breaker   │
│  - CDN       │  │  - Batch    │  │  - Timeout   │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │
       └─────────┬───────┴─────────┬───────┘
                 ▼                 ▼
         ┌──────────────┐  ┌──────────────┐
         │   Database    │  │  Cache (Redis)│
         │  (Optimized)  │  │  / CDN       │
         └──────────────┘  └──────────────┘
```

### Key Optimizations to Implement

1. **Response Caching** (In-memory & Distributed)
2. **Database Connection Pooling**
3. **Async/Await Pattern**
4. **Response Compression**
5. **Pagination for Large Results**
6. **Load Balancing & Horizontal Scaling**
7. **CDN for Static Assets**

### Step-by-Step Implementation Flow

#### Phase 1: Setup Base Services (30 min)

**Prompt 1: Create Base Microservices**
```
Create 3 .NET 8 Web API microservices:
1. ProductService - manages product catalog
2. OrderService - handles order processing
3. PaymentService - processes payments

Each service should:
- Use minimal APIs or controllers
- Have health check endpoint (/health)
- Use Entity Framework Core with SQLite (for simplicity)
- Include Swagger/OpenAPI
- Have basic CRUD operations
- Use dependency injection
- Include structured logging (Serilog)

ProductService endpoints:
- GET /api/products (with pagination)
- GET /api/products/{id}
- POST /api/products
- GET /api/products/search?query={term}

OrderService endpoints:
- GET /api/orders
- POST /api/orders
- GET /api/orders/{id}

PaymentService endpoints:
- POST /api/payments/process
- GET /api/payments/{id}
```

#### Phase 2: Add Caching Layer (45 min)

**Prompt 2: Implement Response Caching**
```
Add response caching to ProductService:

1. In-memory caching for frequently accessed products:
   - Cache product details by ID (5 min TTL)
   - Cache product list (2 min TTL)
   - Use IMemoryCache with cache keys

2. Distributed caching (Redis simulation or in-memory):
   - Cache search results
   - Cache product categories
   - Use IDistributedCache

3. HTTP Response Caching:
   - Add [ResponseCache] attributes
   - Set Cache-Control headers
   - Configure cache profiles in Program.cs

4. Add cache invalidation on POST/PUT/DELETE

Include metrics to show cache hit/miss rates in logs.
```

**Prompt 3: Add Database Connection Pooling**
```
Optimize database access in all services:

1. Configure connection pooling in DbContext:
   - Set MaxPoolSize = 100
   - Set MinPoolSize = 10
   - Add connection timeout settings

2. Use async methods everywhere:
   - ToListAsync(), FirstOrDefaultAsync(), etc.
   - No blocking calls (.Result, .Wait())

3. Add query optimization:
   - Use Select() to limit fields
   - Add .AsNoTracking() for read-only queries
   - Use compiled queries for repeated queries

4. Add database query logging to measure query time
```

#### Phase 3: Add Performance Optimizations (45 min)

**Prompt 4: Implement Response Compression & Pagination**
```
Add performance optimizations:

1. Response Compression:
   - Enable Gzip/Brotli compression
   - Compress JSON responses
   - Add compression middleware

2. Pagination:
   - Update GET /api/products to support:
     - ?page=1&pageSize=20
     - Return pagination metadata (total, page, pageSize)
   - Use efficient Skip/Take queries

3. Async Processing:
   - Make OrderService process orders asynchronously
   - Use background services for heavy operations
   - Return 202 Accepted for long-running tasks

4. Add response time middleware to log slow requests (>500ms)
```

#### Phase 4: Load Testing & Monitoring (30 min)

**Prompt 5: Create Load Testing Script**
```
Create a load testing script (PowerShell or Python) that:

1. Sends concurrent requests to all services
2. Measures:
   - Response time (p50, p95, p99)
   - Throughput (requests/second)
   - Error rate
   - Cache hit rate

3. Gradually increases load:
   - Start with 10 concurrent users
   - Ramp up to 100, 500, 1000
   - Monitor service health

4. Generate report showing:
   - Before/after optimization metrics
   - Latency improvements
   - Resource utilization
```

**Prompt 6: Add Performance Monitoring**
```
Add performance monitoring to all services:

1. Application Insights / CloudWatch integration:
   - Track request duration
   - Track dependency calls (DB, cache)
   - Track custom metrics (cache hits, queue depth)

2. Add custom metrics:
   - Request count by endpoint
   - Average response time
   - Cache hit percentage
   - Database query time

3. Create dashboards showing:
   - Latency trends
   - Throughput
   - Error rates
   - Resource usage
```

### Expected Results

**Before Optimization:**
- Average latency: 200-500ms
- P95 latency: 800ms-1.5s
- Throughput: 50-100 req/s

**After Optimization:**
- Average latency: 50-100ms (with cache)
- P95 latency: 200-400ms
- Throughput: 500-1000 req/s

---

## 🛡️ POC 2: Intermittent Downtime + Troubleshooting + System Resilience

### Architecture Flow

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│         API Gateway                  │
│  - Circuit Breaker                   │
│  - Retry Policy                      │
│  - Timeout Configuration             │
└──────┬───────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│      Critical Service                │
│  (Order Processing)                  │
│                                      │
│  ┌──────────────────────────────┐  │
│  │  Resilience Patterns:         │  │
│  │  - Circuit Breaker            │  │
│  │  - Retry with Backoff         │  │
│  │  - Bulkhead                   │  │
│  │  - Timeout                    │  │
│  │  - Fallback                   │  │
│  └──────────────────────────────┘  │
└──────┬───────────────────────────────┘
       │
       ├─────────────────┬─────────────────┐
       ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Database    │  │  External    │  │  Cache       │
│  (Can Fail)  │  │  API         │  │  (Redis)     │
│              │  │  (Can Fail)  │  │              │
└──────────────┘  └──────────────┘  └──────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│      Monitoring & Alerting           │
│  - Health Checks                     │
│  - Metrics Collection                │
│  - Distributed Tracing              │
│  - Log Aggregation                   │
└─────────────────────────────────────┘
```

### Resilience Patterns to Implement

1. **Circuit Breaker** - Prevents cascading failures
2. **Retry with Exponential Backoff** - Handles transient failures
3. **Timeout** - Prevents hanging requests
4. **Bulkhead** - Isolates resources
5. **Fallback** - Provides degraded functionality
6. **Health Checks** - Early failure detection

### Step-by-Step Implementation Flow

#### Phase 1: Setup Critical Service with Failure Scenarios (45 min)

**Prompt 7: Create Critical Service with Failure Injection**
```
Create a CriticalOrderService (.NET 8) that:

1. Has endpoints:
   - POST /api/orders (processes orders)
   - GET /api/orders/{id}
   - GET /api/health (detailed health check)

2. Simulate failures:
   - Add configuration flag to simulate:
     * Database timeout (random 1-5% of requests)
     * External API failure (random 1-3% of requests)
     * Slow responses (random 2-5% take >2 seconds)
   - Use middleware to inject failures based on config

3. Add dependency on:
   - Database (SQLite with EF Core)
   - External Payment API (mock service)
   - Cache (in-memory for now)

4. Include detailed logging:
   - Request ID correlation
   - Dependency call tracking
   - Error details with stack traces
```

#### Phase 2: Implement Resilience Patterns (60 min)

**Prompt 8: Implement Circuit Breaker Pattern**
```
Add Polly library and implement Circuit Breaker:

1. Install Polly.Extensions.Http and Microsoft.Extensions.Http.Polly

2. Create Circuit Breaker policy:
   - Open circuit after 5 consecutive failures
   - Half-open after 30 seconds
   - Close circuit after 1 successful call in half-open
   - Track circuit state in logs

3. Apply to:
   - Database calls (via DbContext)
   - External API calls (HttpClient)
   - Cache operations

4. Add circuit breaker state endpoint:
   - GET /api/resilience/state
   - Shows current state (Closed/Open/HalfOpen)
   - Shows failure counts

5. When circuit is open:
   - Return 503 Service Unavailable immediately
   - Don't attempt actual call
   - Log circuit breaker activation
```

**Prompt 9: Implement Retry with Exponential Backoff**
```
Add retry policies with exponential backoff:

1. Create retry policy:
   - Retry up to 3 times
   - Exponential backoff: 1s, 2s, 4s
   - Only retry on transient errors (timeout, 5xx)
   - Don't retry on 4xx (client errors)

2. Apply to:
   - Database operations (connection timeouts)
   - External API calls
   - Cache operations

3. Combine with Circuit Breaker:
   - Retry first, then circuit breaker opens if all retries fail
   - Log each retry attempt with attempt number

4. Add jitter to backoff to prevent thundering herd
```

**Prompt 10: Implement Timeout and Bulkhead**
```
Add timeout and bulkhead patterns:

1. Timeout Policy:
   - Set 2 second timeout for database calls
   - Set 5 second timeout for external API calls
   - Cancel operation if timeout exceeded
   - Return timeout error immediately

2. Bulkhead Pattern:
   - Limit concurrent database connections to 10
   - Limit concurrent external API calls to 5
   - Queue additional requests
   - Reject if queue is full

3. Add timeout configuration:
   - Make timeouts configurable via appsettings.json
   - Different timeouts for different operations

4. Log timeout and bulkhead rejections
```

**Prompt 11: Implement Fallback Pattern**
```
Add fallback mechanisms:

1. Database Fallback:
   - If database fails, use cached data
   - If cache fails, return default/stale data
   - Log fallback activation

2. External API Fallback:
   - If payment API fails, queue for later processing
   - Return 202 Accepted with "queued" status
   - Process queue in background

3. Create fallback responses:
   - Graceful degradation
   - Inform user of partial functionality
   - Include retry-after header

4. Add fallback metrics:
   - Track fallback usage
   - Monitor fallback success rate
```

#### Phase 3: Health Checks & Monitoring (45 min)

**Prompt 12: Implement Comprehensive Health Checks**
```
Add detailed health checks:

1. Basic Health Check:
   - GET /health - simple liveness probe
   - Returns 200 if service is up

2. Detailed Health Check:
   - GET /health/ready - readiness probe
   - Checks:
     * Database connectivity
     * External API connectivity
     * Cache connectivity
     * Circuit breaker states
   - Returns 200 if all dependencies healthy
   - Returns 503 if any dependency unhealthy
   - Include dependency status in response

3. Startup Probe:
   - GET /health/startup
   - Checks if service is fully initialized
   - Useful for Kubernetes deployments

4. Health Check Response Format:
   {
     "status": "Healthy|Degraded|Unhealthy",
     "dependencies": {
       "database": "Healthy|Unhealthy",
       "externalApi": "Healthy|Unhealthy",
       "cache": "Healthy|Unhealthy"
     },
     "circuitBreakers": {
       "database": "Closed|Open|HalfOpen",
       "externalApi": "Closed|Open|HalfOpen"
     },
     "timestamp": "2024-01-01T00:00:00Z"
   }
```

**Prompt 13: Add Distributed Tracing & Logging**
```
Implement distributed tracing:

1. Add correlation IDs:
   - Generate correlation ID for each request
   - Pass correlation ID in headers
   - Include in all logs
   - Return in response headers

2. Structured Logging:
   - Use Serilog with structured logging
   - Log:
     * Request/response details
     * Dependency calls (DB, API, cache)
     * Circuit breaker state changes
     * Retry attempts
     * Timeouts
     * Errors with full context

3. Distributed Tracing:
   - Add Application Insights or OpenTelemetry
   - Track spans for:
     * HTTP requests
     * Database queries
     * External API calls
     * Cache operations

4. Log Aggregation:
   - Send logs to CloudWatch/Application Insights
   - Include correlation IDs for traceability
   - Add log levels (Debug, Info, Warning, Error)
```

#### Phase 4: Troubleshooting Tools (30 min)

**Prompt 14: Create Troubleshooting Endpoints**
```
Add troubleshooting and diagnostic endpoints:

1. GET /api/diagnostics/state:
   - Current circuit breaker states
   - Active retry counts
   - Timeout configurations
   - Bulkhead usage

2. GET /api/diagnostics/metrics:
   - Request count (last hour)
   - Error rate
   - Average response time
   - Circuit breaker trip count
   - Retry count
   - Fallback usage count

3. GET /api/diagnostics/logs?correlationId={id}:
   - Retrieve logs for specific correlation ID
   - Useful for troubleshooting specific requests

4. POST /api/diagnostics/simulate-failure:
   - Enable/disable failure injection
   - Set failure rate percentage
   - Set failure type (timeout, error, slow)

5. GET /api/diagnostics/dependencies:
   - List all external dependencies
   - Current status of each
   - Last successful call time
   - Last failure time and reason
```

### Testing Scenarios

1. **Simulate Database Failure**
   - Enable DB failure injection
   - Verify circuit breaker opens
   - Verify fallback activates
   - Check logs for troubleshooting

2. **Simulate High Load**
   - Send 1000 concurrent requests
   - Verify bulkhead limits
   - Check timeout handling
   - Monitor resource usage

3. **Simulate Intermittent Failures**
   - Random 5% failure rate
   - Verify retry logic
   - Verify circuit breaker behavior
   - Check recovery time

---

## 📦 POC 3: Event Sourcing + CQRS Together

### Architecture Flow

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ├──────────────┬──────────────┐
       ▼              ▼              ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│   Command   │ │   Command   │ │   Query     │
│   Service   │ │   Service   │ │   Service   │
│  (Write)    │ │  (Write)    │ │  (Read)     │
└──────┬──────┘ └──────┬───────┘ └──────┬──────┘
       │               │                │
       │               │                │
       ▼               ▼                ▼
┌─────────────────────────────────────────────┐
│         Event Store (Event Sourcing)         │
│  - Append-only log of events                │
│  - Events: OrderCreated, OrderPaid, etc.    │
│  - Source of truth                          │
└──────┬──────────────────────────────────────┘
       │
       ├─────────────────┬─────────────────┐
       ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Event       │  │  Event       │  │  Read Model  │
│  Handler 1   │  │  Handler 2   │  │  (Projection)│
│  (Email)     │  │  (Analytics) │  │              │
└──────────────┘  └──────────────┘  └──────┬───────┘
                                            │
                                            ▼
                                   ┌──────────────┐
                                   │   Read DB    │
                                   │  (Optimized  │
                                   │   for Query) │
                                   └──────────────┘
```

### Key Concepts

1. **Event Sourcing**: Store state changes as events
2. **CQRS**: Separate read and write models
3. **Event Store**: Append-only event log
4. **Projections**: Build read models from events
5. **Event Handlers**: React to events (side effects)

### Step-by-Step Implementation Flow

#### Phase 1: Setup Event Store & Domain Model (60 min)

**Prompt 15: Create Event Store Infrastructure-Guides**
```
Create Event Sourcing infrastructure:

1. Create Event base class:
   - EventId (Guid)
   - AggregateId (Guid)
   - EventType (string)
   - Timestamp (DateTime)
   - Version (int)

2. Create specific events:
   - OrderCreatedEvent
   - OrderItemAddedEvent
   - OrderPaidEvent
   - OrderShippedEvent
   - OrderCancelledEvent

3. Create EventStore interface and implementation:
   - AppendEvents(aggregateId, events, expectedVersion)
   - GetEvents(aggregateId, fromVersion)
   - GetAllEvents() - for projections
   - Use in-memory store (List<Event>) for POC
   - Can be replaced with database later

4. Create Aggregate base class:
   - Id (Guid)
   - Version (int)
   - Apply(Event) method
   - UncommittedEvents list

5. Create Order aggregate:
   - Inherits from Aggregate
   - Handles business logic
   - Applies events to change state
   - Validates commands before applying events
```

**Prompt 16: Implement Order Aggregate with Event Sourcing**
```
Implement Order aggregate:

1. Order aggregate properties:
   - OrderId
   - CustomerId
   - Status (Created, Paid, Shipped, Cancelled)
   - Items (List<OrderItem>)
   - TotalAmount
   - CreatedAt
   - Version

2. Commands:
   - CreateOrderCommand
   - AddItemCommand
   - PayOrderCommand
   - ShipOrderCommand
   - CancelOrderCommand

3. Command handlers:
   - Validate command
   - Create events
   - Apply events to aggregate
   - Save events to event store

4. Event application:
   - OrderCreatedEvent → set initial state
   - OrderItemAddedEvent → add item to list
   - OrderPaidEvent → change status to Paid
   - OrderShippedEvent → change status to Shipped
   - OrderCancelledEvent → change status to Cancelled

5. Replay events to rebuild state:
   - LoadOrder(aggregateId) method
   - Load all events for aggregate
   - Apply each event in order
   - Return reconstructed aggregate
```

#### Phase 2: Implement CQRS - Write Side (45 min)

**Prompt 17: Create Command Side (Write Model)**
```
Implement CQRS write side:

1. Create CommandService API:
   - POST /api/commands/orders/create
   - POST /api/commands/orders/{id}/add-item
   - POST /api/commands/orders/{id}/pay
   - POST /api/commands/orders/{id}/ship
   - POST /api/commands/orders/{id}/cancel

2. Command handlers:
   - Load aggregate from event store (replay events)
   - Validate command against current state
   - Execute business logic
   - Generate events
   - Save events to event store
   - Publish events to event bus (for projections)

3. Return result:
   - Success: 200 with order ID
   - Validation error: 400 with error details
   - Concurrency conflict: 409 (version mismatch)

4. Add optimistic concurrency:
   - Check expected version when saving
   - Handle version conflicts
   - Retry on conflict

5. Include correlation ID for tracing
```

#### Phase 3: Implement CQRS - Read Side (45 min)

**Prompt 18: Create Query Side (Read Model)**
```
Implement CQRS read side:

1. Create ReadModel (Projection):
   - OrderReadModel class:
     * OrderId
     * CustomerId
     * Status
     * Items (denormalized)
     * TotalAmount
     * CreatedAt
     * UpdatedAt
   - Optimized for queries (no joins needed)

2. Create ReadModelStore:
   - In-memory Dictionary<Guid, OrderReadModel>
   - Can be replaced with database (SQL, Cosmos DB)

3. Create Event Handlers (Projections):
   - OrderCreatedEventHandler → create read model
   - OrderItemAddedEventHandler → update read model
   - OrderPaidEventHandler → update status
   - OrderShippedEventHandler → update status
   - OrderCancelledEventHandler → update status

4. Subscribe to events:
   - When events are saved, trigger projections
   - Update read model asynchronously
   - Handle projection failures gracefully

5. Create QueryService API:
   - GET /api/queries/orders/{id} - get by ID
   - GET /api/queries/orders?customerId={id} - get by customer
   - GET /api/queries/orders?status={status} - filter by status
   - GET /api/queries/orders - list all (paginated)
   - All queries use read model (fast, no event replay)
```

**Prompt 19: Implement Event Bus and Projections**
```
Create event bus and projection system:

1. Create EventBus interface:
   - Publish(Event) method
   - Subscribe<T>(IEventHandler<T>) method
   - In-memory implementation for POC

2. Create EventHandler interface:
   - Handle(Event) method
   - Async support

3. Implement projection handlers:
   - OrderReadModelProjection (handles all order events)
   - Update read model based on event type
   - Idempotent (can replay events safely)

4. Add projection replay:
   - GET /api/admin/projections/replay
   - Rebuild all read models from events
   - Useful for fixing projection bugs

5. Add event store query:
   - GET /api/admin/events/{aggregateId}
   - View all events for an aggregate
   - Useful for debugging

6. Handle projection errors:
   - Log errors
   - Don't fail command if projection fails
   - Support retry for failed projections
```

#### Phase 4: Add Advanced Features (30 min)

**Prompt 20: Add Snapshot Support**
```
Add snapshot support for performance:

1. Create Snapshot class:
   - AggregateId
   - State (serialized aggregate)
   - Version (last event version)
   - Timestamp

2. Snapshot strategy:
   - Create snapshot every N events (e.g., every 10)
   - Store snapshot in separate store

3. Optimize aggregate loading:
   - LoadOrder(aggregateId):
     * Load latest snapshot
     * Load events after snapshot version
     * Replay only recent events
     * Much faster for aggregates with many events

4. Add snapshot endpoint:
   - POST /api/admin/snapshots/create/{aggregateId}
   - Manually create snapshot

5. Auto-snapshot on command:
   - Check if snapshot needed
   - Create snapshot in background
```

**Prompt 21: Add Event Versioning and Migration**
```
Handle event schema changes:

1. Event versioning:
   - Add Version property to events
   - Support multiple versions of same event

2. Event upcasters:
   - Convert old event versions to new format
   - Applied when loading events

3. Example:
   - OrderCreatedEvent v1 → OrderCreatedEvent v2
   - Handle missing fields gracefully

4. Add migration endpoint:
   - POST /api/admin/migrations/upcast-events
   - Migrate all events to latest version
```

### Testing Scenarios

1. **Create Order Flow**
   - Send CreateOrderCommand
   - Verify event stored
   - Verify read model created
   - Query order via read model

2. **Event Replay**
   - Create order with multiple events
   - Rebuild aggregate from events
   - Verify state matches

3. **Concurrency**
   - Send two commands simultaneously
   - Verify optimistic concurrency works
   - One succeeds, one gets conflict

4. **Projection Replay**
   - Create orders
   - Delete read models
   - Replay projections
   - Verify read models rebuilt correctly

---

## 🚀 Cloud Deployment (AWS or Azure)

### AWS Setup Prompts

**Prompt 22: Deploy to AWS**
```
Create AWS deployment configuration:

1. Infrastructure-Guides as Code (Terraform or CloudFormation):
   - API Gateway (for routing)
   - Lambda functions (for services) OR ECS Fargate
   - SQS queues (for async communication)
   - DynamoDB (for event store and read models)
   - ElastiCache Redis (for caching)
   - CloudWatch (for monitoring)

2. For each service:
   - Create Lambda function OR ECS task definition
   - Configure environment variables
   - Set up IAM roles
   - Configure VPC if needed

3. API Gateway:
   - Create REST API
   - Configure routes to services
   - Add rate limiting
   - Add API keys if needed

4. Monitoring:
   - CloudWatch dashboards
   - CloudWatch alarms
   - X-Ray for distributed tracing

5. Create deployment Deployment-Scripts:
   - Build .NET application
   - Package for Lambda/ECS
   - Deploy via AWS CLI or CDK
```

### Azure Setup Prompts

**Prompt 23: Deploy to Azure**
```
Create Azure deployment configuration:

1. Infrastructure-Guides:
   - API Management (for API Gateway)
   - Azure Functions OR App Services (for services)
   - Service Bus (for async communication)
   - Cosmos DB (for event store and read models)
   - Azure Cache for Redis (for caching)
   - Application Insights (for monitoring)

2. For each service:
   - Create Function App OR App Service
   - Configure app settings
   - Set up managed identity
   - Configure networking

3. API Management:
   - Create API
   - Configure policies (rate limiting, caching)
   - Set up backend services

4. Monitoring:
   - Application Insights dashboards
   - Alert rules
   - Log Analytics queries

5. Create deployment Deployment-Scripts:
   - Build .NET application
   - Deploy via Azure CLI or ARM/Bicep
```

---

## 📊 Monitoring & Observability Prompts

**Prompt 24: Add Comprehensive Monitoring**
```
Add monitoring to all services:

1. Application Insights / CloudWatch Integration:
   - Track custom metrics:
     * Event store append time
     * Projection processing time
     * Read model query time
     * Command processing time
   - Track dependencies (DB, cache, event bus)
   - Track exceptions

2. Create dashboards:
   - Request rate
   - Error rate
   - Latency (p50, p95, p99)
   - Event store size
   - Projection lag
   - Circuit breaker states

3. Set up alerts:
   - High error rate (>1%)
   - High latency (p95 >500ms)
   - Circuit breaker opened
   - Projection lag >1 minute
   - Event store growing too fast

4. Distributed tracing:
   - Trace requests across services
   - Include event processing in traces
   - Show full request flow
```

---

## 🧪 Testing Strategy

**Prompt 25: Create Test Suite**
```
Create comprehensive tests:

1. Unit Tests:
   - Aggregate business logic
   - Event application
   - Command validation
   - Projection logic

2. Integration Tests:
   - Event store operations
   - Command handling
   - Query handling
   - Projection updates

3. End-to-End Tests:
   - Full command/query flow
   - Event replay
   - Concurrency scenarios
   - Failure scenarios

4. Load Tests:
   - High command rate
   - High query rate
   - Event store performance
   - Projection performance

5. Chaos Tests:
   - Simulate failures
   - Verify resilience
   - Test recovery
```

---

## 📝 Quick Reference: Prompt Execution Order

### POC 1: Latency Optimization
1. Prompt 1 → Prompt 2 → Prompt 3 → Prompt 4 → Prompt 5 → Prompt 6

### POC 2: Resilience
1. Prompt 7 → Prompt 8 → Prompt 9 → Prompt 10 → Prompt 11 → Prompt 12 → Prompt 13 → Prompt 14

### POC 3: Event Sourcing + CQRS
1. Prompt 15 → Prompt 16 → Prompt 17 → Prompt 18 → Prompt 19 → Prompt 20 → Prompt 21

### Cloud & Monitoring
1. Prompt 22 (AWS) OR Prompt 23 (Azure) → Prompt 24 → Prompt 25

---

## 🎯 Success Criteria

After completing all POCs, you should be able to:

1. **Latency Optimization:**
   - Explain caching strategies
   - Demonstrate 5x+ latency improvement
   - Show monitoring dashboards

2. **Resilience:**
   - Demonstrate circuit breaker in action
   - Show retry logic working
   - Explain troubleshooting process
   - Show health check responses

3. **Event Sourcing + CQRS:**
   - Create order via command
   - Query order via read model
   - Show events in event store
   - Replay events to rebuild state
   - Explain CQRS benefits

---

## 💡 Tips for Using Cursor AI

1. **Execute prompts one at a time** - Don't combine multiple prompts
2. **Review generated code** - Understand what was created
3. **Test after each prompt** - Verify it works before moving on
4. **Ask follow-up questions** - "Explain this code" or "How does this work?"
5. **Iterate** - If something doesn't work, ask Cursor to fix it
6. **Customize** - Modify prompts to fit your specific needs

---

## 🔗 Next Steps After POC

1. Replace in-memory stores with real databases
2. Add authentication/authorization
3. Implement proper event bus (RabbitMQ, Kafka, Service Bus)
4. Add more complex business logic
5. Implement saga pattern for distributed transactions
6. Add event versioning and migration strategies
7. Implement event replay for debugging
8. Add more projections for different read models

---

**Good luck with your POC implementation! 🚀**

