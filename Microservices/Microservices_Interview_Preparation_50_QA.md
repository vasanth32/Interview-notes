# Microservices Interview Preparation --- 50 Beginner-Friendly Questions & Answers

> **Goal:** Build a strong interview foundation for .NET/C#
> microservices.\
> **Style:** Beginner-friendly explanations + real-time project usage +
> interview-ready answers.\
> **Example domain used throughout:** E-commerce / Order Management
> system with `Order`, `Payment`, `Inventory`, `Customer`, and
> `Notification` services.

------------------------------------------------------------------------

## How to use this guide

For each question, learn in this order:

1.  **What it means**
2.  **Why we need it**
3.  **How it works**
4.  **How it is used in a real project**
5.  **How to explain it in an interview**

A good interview answer should not sound like a definition copied from a
book. Explain the problem first, then the solution, then your project
example.

------------------------------------------------------------------------

# 1. What is a microservice?

### Simple answer

A microservice is a small, independently deployable application that
owns a specific business capability.

Instead of creating one huge application containing everything, we split
the system into multiple services.

For example:

``` text
                E-Commerce System
                       |
       +---------------+---------------+
       |               |               |
   Order Service   Payment Service   Inventory Service
       |               |               |
    Order DB        Payment DB      Inventory DB
```

Each service normally has:

-   Its own business responsibility
-   Its own code
-   Its own deployment
-   Its own data ownership
-   A clearly defined API or messaging interface

### Real-time project example

When a customer places an order:

``` text
Client
  |
  v
Order Service
  |
  +----> Payment Service
  |
  +----> Inventory Service
  |
  +----> Notification Service
```

The Order Service should not contain all payment, inventory, and
notification logic.

### Interview answer

> "Microservices is an architecture where an application is divided into
> independently deployable services, with each service responsible for a
> specific business capability. In an e-commerce system, for example,
> Order, Payment, Inventory and Notification can be separate services.
> This gives us independent deployment, scaling and ownership, but it
> also introduces distributed-system challenges such as communication,
> consistency, observability and failure handling."

------------------------------------------------------------------------

# 2. Why do we use microservices instead of a monolith?

### Simple answer

A monolith is one large application.

``` text
Monolith
+--------------------------------+
| Order                          |
| Payment                        |
| Inventory                      |
| Customer                       |
| Notification                   |
+--------------------------------+
```

Microservices split those responsibilities.

``` text
Order Service
Payment Service
Inventory Service
Customer Service
Notification Service
```

### Benefits

-   Independent deployment
-   Independent scaling
-   Smaller codebases
-   Team ownership
-   Technology flexibility
-   Fault isolation
-   Easier targeted changes

### Example

Suppose Payment receives very high traffic while Customer traffic is
normal.

With microservices:

``` text
Payment Service:   10 instances
Customer Service:   2 instances
Order Service:      5 instances
```

We can scale only Payment.

### Important interview point

Microservices are **not automatically better**.

They introduce:

-   Network failures
-   Distributed transactions
-   Data consistency problems
-   Deployment complexity
-   Monitoring complexity
-   Service-to-service security

### Interview answer

> "We choose microservices when the system and organization benefit from
> independently deployable business capabilities. The major advantages
> are independent scaling, deployment and ownership. However, I would
> not introduce microservices just for the sake of it because
> distributed systems are more complex than a monolith."

------------------------------------------------------------------------

# 3. What is the difference between monolith and microservices?

  Area            Monolith                   Microservices
  --------------- -------------------------- ----------------------------
  Deployment      Usually one unit           Multiple independent units
  Database        Often shared               Preferably service-owned
  Scaling         Scale entire application   Scale individual services
  Failure         Can affect large portion   Can be isolated
  Codebase        Large                      Smaller per service
  Communication   In-process                 Network/API/message
  Complexity      Lower initially            Higher operationally

### Example

If Payment has a performance problem:

**Monolith:** scaling may mean scaling the whole application.

**Microservices:** scale Payment Service separately.

### Interview tip

Do not say:

> "Microservices is always faster."

That is incorrect.

Network calls can actually make a microservice system slower than an
in-process monolith. The advantage is mainly **independent ownership,
deployment, scaling and architectural boundaries**.

------------------------------------------------------------------------

# 4. How do you decide service boundaries?

This is one of the most important microservices interview questions.

### Beginner-friendly idea

Do not create services based only on database tables.

Instead, identify **business capabilities**.

For example:

``` text
Customer Management
Order Management
Payment Processing
Inventory Management
Shipping
Notification
```

These are better candidates than:

``` text
CustomerTableService
OrderTableService
PaymentTableService
```

### Use business boundaries

Ask:

-   What business responsibility does this service own?
-   Does it have its own business rules?
-   Does a team need to deploy it independently?
-   Does it need independent scaling?
-   Does it have a clear data ownership boundary?

### Real project example

For an order system:

``` text
Order Service
- Create order
- Cancel order
- Get order status

Payment Service
- Authorize payment
- Capture payment
- Refund payment

Inventory Service
- Reserve stock
- Release stock
```

### Interview answer

> "I would identify services around business capabilities and bounded
> contexts rather than technical layers or database tables. For example,
> Order, Payment and Inventory have different business responsibilities
> and can evolve independently."

------------------------------------------------------------------------

# 5. What is bounded context?

### Simple definition

A bounded context is a boundary inside which a particular business model
and terminology have a specific meaning.

For example, the word `Order` may mean different things to different
teams.

``` text
Sales Context
Order = customer purchase

Warehouse Context
Order = fulfillment work

Finance Context
Order = financial transaction
```

Microservices often align well with bounded contexts.

### Why it matters

Without clear boundaries, services become tightly coupled.

### Interview answer

> "A bounded context defines a clear business boundary where domain
> terms and rules have a consistent meaning. In microservices, it helps
> us identify meaningful service boundaries and avoid sharing internal
> business models across services."

------------------------------------------------------------------------

# 6. Should every microservice have its own database?

### Preferred approach

Each service should own its data.

``` text
Order Service ----> Order DB
Payment Service --> Payment DB
Inventory Service -> Inventory DB
```

Instead of:

``` text
Order Service ----\
Payment Service ---+--> Shared DB
Inventory Service -/
```

### Why?

If every service directly changes the same database, services become
tightly coupled.

For example:

``` text
Payment Service
      |
      v
PaymentTable
```

Other services should not directly update that table.

They should communicate through an API or event.

### Important nuance

"Database per service" does not necessarily mean every service must run
a completely separate physical database server.

It means **logical data ownership** should be separated.

### Interview answer

> "I prefer service-owned data. The important principle is that one
> service owns its data and other services do not directly modify its
> tables. This reduces coupling and allows independent schema changes."

------------------------------------------------------------------------

# 7. Why is a shared database considered a problem?

Imagine:

``` text
Order Service ----\
Payment Service ---+--> Same Database
Inventory Service -/
```

Payment Service directly reads Order tables.

Now the Order team changes:

``` text
OrderStatus
```

to:

``` text
StatusCode
```

Payment may break.

This creates database-level coupling.

### Better approach

``` text
Payment Service
      |
      | API/event
      v
Order Service
      |
      v
Order DB
```

### Interview answer

> "A shared database makes service boundaries weak because services
> become dependent on each other's schemas. It also makes independent
> deployment and ownership difficult. Service-owned data gives each
> service freedom to evolve its schema."

------------------------------------------------------------------------

# 8. How do microservices communicate?

There are two major styles.

## Synchronous communication

Usually HTTP/REST or gRPC.

``` text
Order Service
     |
     | HTTP
     v
Payment Service
```

The caller waits for a response.

Example:

``` http
POST /payments
```

Response:

``` json
{
  "paymentId": "P1001",
  "status": "Authorized"
}
```

## Asynchronous communication

Using a message broker.

``` text
Order Service
     |
     | OrderCreated event
     v
Message Broker
     |
     +----> Payment Service
     |
     +----> Notification Service
```

The producer does not need to wait for every consumer.

### Interview answer

> "For request-response operations I can use REST or gRPC. For
> asynchronous workflows and event-driven communication, I can use a
> message broker such as Azure Service Bus, RabbitMQ or Kafka depending
> on the requirement."

------------------------------------------------------------------------

# 9. REST vs gRPC in microservices

  -----------------------------------------------------------------------
  REST                                gRPC
  ----------------------------------- -----------------------------------
  Usually HTTP/JSON                   HTTP/2 + Protocol Buffers

  Easy for external clients           Excellent for internal service
                                      communication

  Human-readable                      Compact binary format

  Very common for public APIs         Useful for high-performance
                                      internal APIs

  Browser-friendly                    Requires suitable client support
  -----------------------------------------------------------------------

### Example

Public API:

``` text
Mobile App -> API Gateway -> Order Service
```

REST is a natural choice.

Internal communication:

``` text
Order Service -> Pricing Service
```

gRPC may be appropriate when low latency and strongly typed contracts
are important.

### Interview answer

> "I would choose based on the use case. REST is simple and widely
> supported, especially for external APIs. gRPC is useful for efficient
> internal service-to-service communication where strongly typed
> contracts and performance are important."

------------------------------------------------------------------------

# 10. What is an API Gateway?

An API Gateway is a single entry point for clients into a group of
backend services.

``` text
Mobile/Web Client
       |
       v
   API Gateway
    /   |   \
   /    |    \
Order Payment Customer
```

### Why use it?

The client does not need to know every internal service address.

The gateway can handle:

-   Routing
-   Authentication
-   Authorization
-   Rate limiting
-   Request aggregation
-   Logging
-   Sometimes response transformation

### Example

Client calls:

``` http
GET /api/orders/1001
```

Gateway routes it to:

``` text
Order Service
```

### Interview answer

> "An API Gateway provides a controlled entry point for clients. It can
> handle routing, authentication, rate limiting and other cross-cutting
> concerns while hiding internal service topology."

------------------------------------------------------------------------

# 11. API Gateway vs Load Balancer

They are related but not the same.

### Load balancer

Mainly distributes traffic across instances.

``` text
Client
  |
Load Balancer
  |
+---+---+---+
|   |   |   |
API API API
```

### API Gateway

Understands API routes and can apply policies.

``` text
Client
   |
Gateway
 / | \
Order Payment Customer
```

A gateway may itself sit behind a load balancer.

### Interview answer

> "A load balancer primarily distributes traffic across instances, while
> an API Gateway acts as an application-level entry point for APIs and
> can perform routing, authentication, rate limiting and aggregation."

------------------------------------------------------------------------

# 12. What is service discovery?

In a distributed system, service instances can change.

Today:

``` text
Payment Service
10.0.0.15
```

Tomorrow:

``` text
10.0.0.20
10.0.0.21
10.0.0.22
```

Clients should not hardcode IP addresses.

Service discovery helps locate available instances.

### Example

``` text
Order Service
      |
      v
Service Discovery
      |
      +--> Payment instance 1
      +--> Payment instance 2
```

In Kubernetes, Services and DNS provide common service-discovery
mechanisms.

### Interview answer

> "Service discovery allows one service to locate available instances of
> another service dynamically instead of hardcoding instance addresses."

------------------------------------------------------------------------

# 13. What is synchronous vs asynchronous communication?

### Synchronous

``` text
Order -> Payment
       waits
Payment -> Response
```

If Payment takes 5 seconds, Order waits.

### Asynchronous

``` text
Order -> Message Broker
             |
             v
         Payment
```

Order can continue after publishing the event, depending on business
requirements.

### When synchronous?

Use it when the immediate response is required.

Example:

``` text
Get customer profile
```

### When asynchronous?

Use it when processing can happen later.

Example:

``` text
OrderCreated -> Send Email
```

### Interview answer

> "Synchronous communication is useful when the caller needs an
> immediate result. Asynchronous messaging is useful for decoupled
> workflows, background processing and operations where the producer
> should not wait for the consumer."

------------------------------------------------------------------------

# 14. What is a message broker?

A message broker receives messages from producers and delivers them to
consumers.

``` text
Producer
   |
   v
Message Broker
   |
   +----> Consumer A
   +----> Consumer B
```

Examples include:

-   Azure Service Bus
-   RabbitMQ
-   Apache Kafka

### Real project

When an order is created:

``` text
Order Service
   |
OrderCreated
   |
Message Broker
   |
   +--> Inventory Service
   +--> Notification Service
   +--> Analytics Service
```

The Order Service does not need direct knowledge of every consumer.

### Interview answer

> "A message broker decouples producers and consumers. It stores or
> transports messages and allows multiple services to process events
> independently."

------------------------------------------------------------------------

# 15. Event vs command --- what is the difference?

### Command

A command tells another component to do something.

Example:

``` text
ReserveInventory
```

It means:

> "Please reserve inventory."

### Event

An event says something already happened.

Example:

``` text
OrderCreated
```

It means:

> "The order has been created."

### Easy memory trick

``` text
Command = Do this
Event   = This happened
```

### Interview answer

> "A command represents an instruction, while an event represents a fact
> that has already happened. For example, `ReserveInventory` is a
> command and `OrderCreated` is an event."

------------------------------------------------------------------------

# 16. What is event-driven architecture?

In event-driven architecture, services communicate by publishing and
consuming events.

``` text
Order Service
     |
     | OrderCreated
     v
Message Broker
   /       \
  v         v
Inventory  Notification
```

The producer does not need to know the internal implementation of
consumers.

### Benefits

-   Loose coupling
-   Asynchronous processing
-   Easy addition of new consumers
-   Better scalability

### Challenge

You must handle:

-   Duplicate events
-   Out-of-order events
-   Failed processing
-   Event schema changes
-   Eventual consistency

### Interview answer

> "Event-driven architecture allows services to react to business events
> asynchronously. It improves decoupling, but it requires careful
> handling of retries, duplicate messages, ordering and eventual
> consistency."

------------------------------------------------------------------------

# 17. What is eventual consistency?

In a distributed system, all services may not see the same state
immediately.

Example:

``` text
Order DB
Order = Created

      |
      | OrderCreated event
      v

Inventory Service
      |
      v
Stock = Reserved
```

There may be a small time gap.

For that period:

``` text
Order says: Created
Inventory says: Not yet reserved
```

Eventually both reach the correct state.

### Why?

Distributed services cannot always update multiple databases in one
traditional ACID transaction.

### Interview answer

> "Eventual consistency means different services may temporarily have
> different views of the data, but they converge to a consistent state
> after asynchronous processing completes."

------------------------------------------------------------------------

# 18. What is a distributed transaction?

A transaction that spans multiple services or databases is a distributed
transaction.

Example:

``` text
Order DB
Payment DB
Inventory DB
```

One business operation touches all three.

Traditional single-database transaction:

``` text
BEGIN
Update A
Update B
COMMIT
```

Across microservices, this is much harder because each service owns a
different database.

### Preferred approach

Use patterns such as:

-   Saga
-   Outbox
-   Compensating actions

### Interview answer

> "A distributed transaction spans multiple services or databases.
> Instead of relying on a single database transaction across services,
> microservice architectures commonly use patterns such as Saga and
> transactional outbox to coordinate reliable business workflows."

------------------------------------------------------------------------

# 19. What is the Saga pattern?

Saga manages a long-running business transaction as a sequence of local
transactions.

Example:

``` text
Create Order
    |
    v
Reserve Inventory
    |
    v
Process Payment
    |
    v
Confirm Order
```

If Payment fails:

``` text
Create Order       SUCCESS
Reserve Inventory  SUCCESS
Payment            FAILED
```

We need compensation:

``` text
Release Inventory
Cancel Order
```

### Two styles

1.  Choreography
2.  Orchestration

------------------------------------------------------------------------

# 20. Saga choreography vs orchestration

## Choreography

Services react to events.

``` text
Order
  |
OrderCreated
  v
Inventory
  |
InventoryReserved
  v
Payment
```

There is no central coordinator.

### Advantage

Loose coupling.

### Disadvantage

The workflow can become difficult to understand as services increase.

## Orchestration

A central Saga Orchestrator coordinates steps.

``` text
          Saga Orchestrator
          /       |       \
         v        v        v
      Order   Inventory  Payment
```

### Advantage

Workflow is easier to visualize and control.

### Disadvantage

The orchestrator becomes an important component that must be designed
carefully.

### Interview answer

> "In choreography, services react to events and there is no central
> coordinator. In orchestration, a Saga orchestrator tells participating
> services what action to perform and handles failures and
> compensations."

------------------------------------------------------------------------

# 21. What is the Outbox Pattern?

Suppose Order Service needs to:

1.  Save an order
2.  Publish `OrderCreated`

Potential failure:

``` text
Save Order      SUCCESS
Publish Event   FAILED
```

Now the database says the order exists, but other services never
received the event.

The Outbox Pattern solves this by storing the event in the same database
transaction.

``` text
BEGIN TRANSACTION

Orders table
   +
Outbox table

COMMIT
```

Then a background worker publishes the Outbox event.

``` text
Outbox Table
     |
     v
Publisher
     |
     v
Message Broker
```

### Interview answer

> "The Outbox Pattern ensures that a database change and the intent to
> publish an event are committed atomically. A background publisher then
> sends the stored event to the broker. This prevents the common problem
> where the database update succeeds but event publishing fails."

------------------------------------------------------------------------

# 22. What is idempotency?

An operation is idempotent when repeating the same request does not
create an unintended additional effect.

Example:

``` text
POST /payments
Idempotency-Key: ABC123
```

Client retries because the network timed out.

Without idempotency:

``` text
Payment 1 = ₹1000
Payment 2 = ₹1000
```

Customer gets charged twice.

With idempotency:

``` text
ABC123 -> Payment already processed
```

Return the existing result.

### Real implementation idea

Store:

``` text
IdempotencyKey
RequestHash
Response
Status
CreatedAt
```

### Interview answer

> "Idempotency protects operations from duplicate effects caused by
> retries. For example, in payment processing, I would accept an
> idempotency key, persist it with the result and return the existing
> result when the same key is received again."

------------------------------------------------------------------------

# 23. Why are retries dangerous?

Retries are useful for temporary failures.

But blindly retrying can make a problem worse.

Example:

``` text
Payment Service is slow
       ^
       |
Order Service retries 5 times
```

Now 1 request becomes 5 requests.

This can overload Payment.

### Better approach

Use:

-   Limited retries
-   Exponential backoff
-   Jitter
-   Retry only transient failures
-   Idempotency for side effects

Example:

``` text
Attempt 1 -> immediate
Attempt 2 -> 200 ms
Attempt 3 -> 500 ms
Attempt 4 -> 1 sec
```

### Interview answer

> "Retries should be limited and used mainly for transient failures. I
> combine exponential backoff and jitter with idempotent operations to
> avoid duplicate effects and retry storms."

------------------------------------------------------------------------

# 24. What is exponential backoff?

Instead of retrying immediately every time, increase the delay between
attempts.

``` text
Retry 1 -> 100 ms
Retry 2 -> 200 ms
Retry 3 -> 400 ms
Retry 4 -> 800 ms
```

Random jitter is often added:

``` text
delay = calculated delay + random value
```

This prevents many instances from retrying at exactly the same moment.

### Interview answer

> "Exponential backoff increases the retry delay after each failed
> attempt. Jitter adds randomness so many service instances don't retry
> simultaneously."

------------------------------------------------------------------------

# 25. What is a circuit breaker?

A circuit breaker prevents repeated calls to a failing dependency.

Imagine Payment is down.

Without circuit breaker:

``` text
Order -> Payment FAIL
Order -> Payment FAIL
Order -> Payment FAIL
Order -> Payment FAIL
...
```

With circuit breaker:

``` text
Order -> Payment FAIL
        |
        v
Circuit opens
        |
Future calls fail fast
```

After a waiting period, it can test the dependency again.

Typical states:

``` text
Closed -> Open -> Half-Open -> Closed
```

### Interview answer

> "A circuit breaker stops repeatedly calling an unhealthy dependency.
> It opens after failures, fails fast for a period, then uses a
> half-open state to test whether the dependency has recovered."

------------------------------------------------------------------------

# 26. What is timeout and why is it important?

Never allow a service call to wait forever.

Bad:

``` text
Order -> Payment
          |
       waiting...
          |
       waiting...
```

Good:

``` text
Payment timeout = 3 seconds
```

If no response:

``` text
Timeout
  |
Fallback / retry / compensation
```

### Why?

Without timeouts:

-   Threads/tasks can remain occupied
-   Requests pile up
-   Failures spread
-   Latency increases

### Interview answer

> "Every network call should have a sensible timeout because
> dependencies can become slow or unavailable. Timeouts prevent
> indefinite waiting and help contain failures."

------------------------------------------------------------------------

# 27. What is bulkhead isolation?

Bulkhead comes from ship design: if one compartment floods, the whole
ship should not sink.

In software:

``` text
Service
+-------------------+
| Payment calls     |  limited resources
+-------------------+
| Customer calls    |  separate resources
+-------------------+
```

If Payment becomes slow, it should not consume all available resources
and prevent Customer operations.

### Interview answer

> "Bulkhead isolation limits resources for different dependency groups
> or workloads so failure in one dependency does not exhaust the entire
> service."

------------------------------------------------------------------------

# 28. What is fault tolerance in microservices?

Fault tolerance means the system continues operating acceptably even
when components fail.

Possible failures:

-   Service unavailable
-   Network timeout
-   Database unavailable
-   Message processing failure
-   Dependency latency
-   Instance crash

Common techniques:

``` text
Timeout
Retry
Circuit Breaker
Bulkhead
Fallback
Health Checks
Queueing
Redundancy
```

### Example

If Notification Service is unavailable:

``` text
Order creation
      |
      +----> Notification FAILED
      |
      v
Order still succeeds
```

If email is not business-critical, the order should not necessarily
fail.

### Interview answer

> "Fault tolerance means designing the system so individual failures do
> not unnecessarily bring down the whole business workflow. We use
> techniques such as timeouts, retries, circuit breakers, queues and
> graceful degradation."

------------------------------------------------------------------------

# 29. What is a health check?

A health check tells whether a service is functioning.

Common endpoints:

``` text
/health/live
/health/ready
```

### Liveness

"Is the process alive?"

### Readiness

"Can this instance receive traffic?"

For example, if the service is running but cannot connect to a required
database, readiness may fail.

### Kubernetes example

``` text
Load Balancer
     |
Readiness Check
     |
Only healthy instances receive traffic
```

### Interview answer

> "Liveness checks whether the application process is alive, while
> readiness indicates whether the instance is ready to receive traffic.
> Orchestrators such as Kubernetes can use these checks to manage
> service instances."

------------------------------------------------------------------------

# 30. What is observability?

Observability helps us understand what is happening inside a distributed
system.

Three major pillars:

``` text
Logs
Metrics
Traces
```

### Logs

"What happened?"

``` text
Payment authorization failed
```

### Metrics

"How much/how often?"

``` text
Payment latency = 450 ms
Error rate = 2%
```

### Traces

"Where did this request travel?"

``` text
API Gateway
   |
Order
   |
Payment
   |
Database
```

### Interview answer

> "Observability is the ability to understand system behavior using
> logs, metrics and distributed traces. In microservices, it is
> especially important because one user request can cross multiple
> services."

------------------------------------------------------------------------

# 31. What is distributed tracing?

A single request may pass through many services.

``` text
Client
 |
Gateway
 |
Order Service
 |
Payment Service
 |
Payment DB
```

Distributed tracing gives the request a trace context and creates spans
for each operation.

Example:

``` text
Trace ID: ABC123

Order:   100 ms
Payment: 700 ms
DB:      500 ms
```

We can quickly identify that Payment/DB caused the latency.

### Interview answer

> "Distributed tracing follows a request across service boundaries using
> trace context. It lets us see the end-to-end request path and identify
> which service or dependency caused latency or failure."

------------------------------------------------------------------------

# 32. What is correlation ID?

A correlation ID is an identifier used to associate logs belonging to
the same request or business operation.

``` text
CorrelationId = 8f21...
```

Gateway logs:

``` text
Request received
CorrelationId=8f21
```

Order logs:

``` text
Creating order
CorrelationId=8f21
```

Payment logs:

``` text
Payment started
CorrelationId=8f21
```

Now searching for `8f21` helps investigate the request.

### Difference from trace ID

A modern distributed tracing system usually propagates trace context and
trace IDs automatically. Correlation IDs are still useful as
business/request identifiers depending on the logging design.

### Interview answer

> "A correlation ID helps associate logs and operations belonging to the
> same request or business flow. In distributed tracing, trace context
> provides a standardized way to propagate request identity across
> services."

------------------------------------------------------------------------

# 33. How do you secure microservices?

Security should exist at multiple levels.

``` text
Client
  |
Authentication
  |
Authorization
  |
API Gateway
  |
Service-to-service authentication
  |
Service
```

Common mechanisms:

-   OAuth 2.0 / OpenID Connect
-   JWT bearer tokens
-   HTTPS/TLS
-   Role/claim-based authorization
-   Managed identities
-   Secrets management
-   Network policies

### JWT flow

``` text
Client
 |
Login
 v
Identity Provider
 |
JWT
 v
API Gateway/API
 |
Validate token
 v
ClaimsPrincipal
```

### Interview answer

> "I secure microservices using HTTPS, token-based authentication such
> as OAuth 2.0/OIDC and JWTs, authorization based on claims or roles,
> and secure service-to-service communication. Secrets should be stored
> in a secure secret store rather than source code."

------------------------------------------------------------------------

# 34. Authentication vs authorization

### Authentication

"Who are you?"

Example:

``` text
User = Vasanth
```

### Authorization

"What are you allowed to do?"

Example:

``` text
Vasanth -> CanCreateOrder
Vasanth -> CannotRefundPayment
```

### Interview answer

> "Authentication verifies identity, while authorization determines what
> an authenticated identity is allowed to access."

------------------------------------------------------------------------

# 35. How does JWT authentication work in ASP.NET Core?

A simplified flow:

``` text
Client
  |
Bearer JWT
  |
ASP.NET Core
  |
JWT Authentication Handler
  |
Validate:
- Signature
- Issuer
- Audience
- Expiration
  |
ClaimsPrincipal
  |
Authorization
```

The authentication handler validates the token and creates
`HttpContext.User`.

Then `[Authorize]` and policies determine access.

### Example

``` csharp
[Authorize]
[HttpGet]
public IActionResult GetOrder()
{
    return Ok();
}
```

### Interview answer

> "The JWT bearer authentication handler validates the token using
> configured validation parameters such as signature, issuer, audience
> and expiration. If valid, ASP.NET Core creates the ClaimsPrincipal.
> Authorization then checks policies, roles or claims."

------------------------------------------------------------------------

# 36. What is API versioning?

APIs evolve.

Version 1:

``` http
GET /api/v1/orders/1001
```

Version 2:

``` http
GET /api/v2/orders/1001
```

Maybe V2 changes the response structure.

Versioning allows existing clients to continue working while new clients
move to the new contract.

### Strategies

-   URL versioning
-   Header versioning
-   Query-string versioning

### Interview answer

> "API versioning allows us to evolve an API without unexpectedly
> breaking existing consumers. I prefer a clear strategy and a defined
> deprecation process rather than changing contracts silently."

------------------------------------------------------------------------

# 37. What is backward compatibility?

A new version should ideally continue supporting existing consumers.

Example:

V1 expects:

``` json
{
  "name": "Phone"
}
```

If V2 changes it to:

``` json
{
  "productName": "Phone"
}
```

old clients may break.

### Better approach

Add fields when possible:

``` json
{
  "name": "Phone",
  "productName": "Phone"
}
```

Then deprecate the old field gradually.

### Interview answer

> "Backward compatibility means newer service versions continue to work
> with existing consumers where practical. Contract changes should be
> additive where possible, with controlled deprecation for breaking
> changes."

------------------------------------------------------------------------

# 38. How do you handle failures in message processing?

Suppose:

``` text
OrderCreated
    |
    v
Inventory Consumer
    |
Database temporarily unavailable
```

The consumer fails.

Common strategies:

1.  Retry
2.  Dead-letter queue
3.  Idempotent processing
4.  Alerting
5.  Manual/recovery processing

### Dead-letter queue

Messages that cannot be successfully processed after configured attempts
can be moved to a DLQ.

``` text
Queue
 |
 +--> Consumer
       |
       +--> success
       |
       +--> retry
       |
       +--> DLQ
```

### Interview answer

> "For transient failures I use controlled retries. Messages that
> repeatedly fail can be moved to a dead-letter queue for investigation
> and recovery. The consumer should also be idempotent so duplicate
> delivery does not create duplicate business effects."

------------------------------------------------------------------------

# 39. What is at-least-once delivery?

It means a message may be delivered one or more times.

``` text
Message M1
   |
Consumer receives M1
   |
Processing succeeds
   |
Acknowledgement lost
   |
Broker delivers M1 again
```

So consumers must tolerate duplicates.

### Important principle

Do not assume:

``` text
Exactly once
```

unless the platform and design genuinely provide the required
guarantees.

### Interview answer

> "At-least-once delivery prioritizes not losing messages, so a consumer
> may receive duplicates. Therefore consumers should be idempotent and
> maintain appropriate processing state."

------------------------------------------------------------------------

# 40. What is a poison message?

A poison message is a message that repeatedly fails processing.

Example:

``` json
{
  "quantity": "INVALID"
}
```

Every retry fails because the payload itself is invalid.

If we retry forever:

``` text
Queue -> Consumer -> Fail -> Retry -> Fail -> Retry...
```

Use a dead-letter queue after a reasonable number of attempts.

### Interview answer

> "A poison message is a message that repeatedly fails because of
> invalid data or an unrecoverable processing problem. We typically
> limit retries and move such messages to a dead-letter queue."

------------------------------------------------------------------------

# 41. How do you maintain data consistency across microservices?

Avoid trying to make every service database part of one giant
transaction.

Instead:

``` text
Local Transaction
      +
Event
      +
Saga/Compensation
      +
Outbox
```

Example:

``` text
Order Created
     |
Inventory Reserved
     |
Payment Authorized
     |
Order Confirmed
```

If Payment fails:

``` text
Release Inventory
Cancel Order
```

### Interview answer

> "I use local ACID transactions inside each service and coordinate
> cross-service consistency using patterns such as Saga, transactional
> outbox and compensating actions. This generally leads to eventual
> consistency rather than one global database transaction."

------------------------------------------------------------------------

# 42. How do you prevent duplicate order creation?

Use idempotency.

Client sends:

``` text
Idempotency-Key: ORDER-12345
```

Service checks:

``` text
Has ORDER-12345 already been processed?
```

If yes:

``` text
Return existing order
```

If no:

``` text
Create order
Store key/result
```

### Important

The idempotency record and business operation should be stored
atomically where possible.

### Interview answer

> "For create operations that can be retried, I use an idempotency key.
> The service stores the key with the resulting operation so a repeated
> request returns the original result instead of creating a second
> order."

------------------------------------------------------------------------

# 43. How do you handle concurrency in microservices?

Imagine two requests try to update the same inventory:

``` text
Stock = 1

Request A -> buy 1
Request B -> buy 1
```

Without concurrency control, both may succeed incorrectly.

Possible techniques:

-   Optimistic concurrency
-   Row version / timestamp
-   Database constraints
-   Atomic update
-   Distributed locks where genuinely necessary
-   Serial processing for specific workflows

### Optimistic concurrency example

``` text
ProductId = 10
Stock = 5
Version = 7
```

Update only if:

``` text
Version = 7
```

If another process already changed it to Version 8, the update fails and
the service can retry/reload.

### Interview answer

> "For business data such as inventory, I use appropriate concurrency
> controls such as optimistic concurrency or atomic database updates.
> The exact approach depends on the contention and business
> requirement."

------------------------------------------------------------------------

# 44. How do you scale microservices horizontally?

Horizontal scaling means adding more instances.

``` text
Payment Service

      Load Balancer
       /    |    \
      v     v     v
   Instance 1 2 3
```

If traffic increases:

``` text
3 instances -> 10 instances
```

### Requirements

The service should ideally be stateless.

Avoid storing user session state only in local memory.

Use:

-   Shared/distributed cache when required
-   Database
-   External session store
-   Object storage
-   Message broker

### Interview answer

> "Horizontal scaling means adding more instances of a service behind a
> load balancer. To scale effectively, I keep APIs stateless and
> externalize shared state."

------------------------------------------------------------------------

# 45. What is caching in microservices?

Caching stores frequently accessed data closer to the application.

Example:

``` text
Client
 |
Product Service
 |
Cache
 | hit
 v
Product data
```

Without cache:

``` text
Every request -> Database
```

With cache:

``` text
Most requests -> Cache
Some requests  -> Database
```

### Common use cases

-   Product catalog
-   Configuration
-   Reference data
-   Frequently read customer information

### Challenges

-   Cache invalidation
-   Stale data
-   Memory limits
-   Consistency

### Interview answer

> "Caching reduces database load and latency for frequently accessed
> data. I would use it where the data can tolerate the required level of
> staleness and define an appropriate expiration/invalidation strategy."

------------------------------------------------------------------------

# 46. What is the cache-aside pattern?

Application checks cache first.

``` text
Request
  |
  v
Cache?
 /   \
Hit  Miss
 |     |
Return  DB
        |
        v
      Cache
        |
        v
      Return
```

### Example

``` csharp
var product = await cache.GetAsync(key);

if (product == null)
{
    product = await repository.GetAsync(id);
    await cache.SetAsync(key, product);
}
```

### Interview answer

> "In cache-aside, the application checks the cache first. On a miss it
> reads from the database and then populates the cache."

------------------------------------------------------------------------

# 47. How do you deploy microservices?

A common modern approach is containerization.

``` text
Source Code
    |
Docker Image
    |
Container Registry
    |
Kubernetes / Container Platform
    |
Running Instances
```

### CI/CD

``` text
Developer
   |
Git
   |
Build
   |
Unit Tests
   |
Security Scan
   |
Docker Build
   |
Deploy
   |
Monitoring
```

### Benefits

-   Repeatable deployments
-   Environment consistency
-   Independent deployment
-   Easy scaling
-   Rollback capability

### Interview answer

> "We can package each microservice as a container and deploy it
> independently through a CI/CD pipeline. The pipeline builds, tests,
> scans and publishes the image, then deploys it to the target container
> platform."

------------------------------------------------------------------------

# 48. What is Kubernetes and why is it used with microservices?

Kubernetes is a container orchestration platform.

It helps manage:

-   Container deployment
-   Scaling
-   Service discovery
-   Load balancing
-   Health checks
-   Rolling updates
-   Self-healing

Example:

``` text
Kubernetes Cluster
|
+-- Order Deployment
|    +-- Pod
|    +-- Pod
|
+-- Payment Deployment
     +-- Pod
     +-- Pod
     +-- Pod
```

If a Pod crashes, Kubernetes can create another one.

### Interview answer

> "Kubernetes automates deployment and management of containers. In a
> microservices environment it can provide service discovery, scaling,
> health-based replacement and rolling deployments."

------------------------------------------------------------------------

# 49. How do you troubleshoot a slow microservice?

Do not immediately change code.

Follow a systematic approach.

### Step 1 --- Check metrics

``` text
Latency
CPU
Memory
Error rate
Request rate
```

### Step 2 --- Check distributed traces

Find where the time is spent.

``` text
Gateway     20ms
Order       30ms
Payment    900ms
Database   800ms
```

### Step 3 --- Check logs

Look for:

-   Exceptions
-   Timeouts
-   Retries
-   Dependency failures

### Step 4 --- Check database

Look for:

-   Slow queries
-   Missing indexes
-   Lock contention
-   Connection pool pressure

### Step 5 --- Check infrastructure

Look at:

-   CPU
-   Memory
-   Network
-   Container restarts
-   Scaling

### Interview answer

> "I would start with metrics to identify whether the issue is latency,
> errors or resource pressure. Then I would use distributed tracing to
> identify the slow service or dependency, inspect logs, check database
> performance and finally inspect infrastructure and scaling behavior."

------------------------------------------------------------------------

# 50. Design an Order Processing Microservices system

This is a common system-design-style interview question.

### Requirements

Customer places an order.

We need:

-   Create order
-   Reserve inventory
-   Process payment
-   Confirm order
-   Send notification

### Architecture

``` text
                    Client
                       |
                       v
                 API Gateway
                       |
                       v
                 Order Service
                  /          \
                 v            v
          Order Database   Outbox
                              |
                              v
                        Message Broker
                         /    |     \
                        v     v      v
                 Inventory  Payment  Notification
                    |         |
                    v         v
              Inventory DB  Payment DB
```

### Happy path

``` text
1. Client -> Create Order
2. Order Service saves Order = Pending
3. Order Service writes OrderCreated to Outbox
4. Outbox publisher sends event
5. Inventory reserves stock
6. Payment authorizes payment
7. Order becomes Confirmed
8. Notification service sends confirmation
```

### Failure path

Suppose payment fails:

``` text
Order = Pending
Inventory = Reserved
Payment = Failed
```

Compensation:

``` text
Release Inventory
Cancel Order
Notify customer
```

This is a Saga-style workflow.

### Reliability

Use:

``` text
Timeouts
Retries
Circuit breaker
Idempotency
Outbox
Dead-letter queue
Health checks
```

### Observability

Use:

``` text
Structured logs
Metrics
Distributed tracing
Correlation/trace context
Alerts
```

### Security

Use:

``` text
HTTPS
OAuth/OIDC
JWT
Authorization policies
Secret management
```

### Scaling

``` text
API Gateway
     |
Load Balancer
     |
+----+----+----+
|    |    |    |
Order instances
```

Payment and Order can be scaled independently.

### Interview answer

> "I would separate the system by business capability into Order,
> Inventory, Payment and Notification services. Each service owns its
> data. The API Gateway provides the client entry point. For the order
> workflow, I would use asynchronous events and a Saga-style process,
> with an Outbox to reliably publish events. Idempotency would protect
> create/payment operations from retries, and retries, timeouts and
> circuit breakers would handle transient dependency failures. Finally,
> distributed tracing, structured logs and metrics would provide
> observability."

------------------------------------------------------------------------

# Quick Interview Cheat Sheet

## Architecture

Remember:

``` text
Business Capability
        |
Bounded Context
        |
Service Boundary
        |
Service-Owned Data
```

## Communication

``` text
Immediate response -> REST / gRPC
Async workflow      -> Message Broker
```

## Reliability

``` text
Timeout
   +
Retry + Backoff
   +
Circuit Breaker
   +
Idempotency
   +
Bulkhead
```

## Data consistency

``` text
Local Transaction
       +
Outbox
       +
Event
       +
Saga
       +
Compensation
```

## Messaging

``` text
Command = Do this
Event   = This happened
```

## Observability

``` text
Logs + Metrics + Traces
```

## Security

``` text
Authentication -> Who are you?
Authorization  -> What can you do?
```

## Scaling

``` text
Stateless Service
       |
Load Balancer
       |
Multiple Instances
```

------------------------------------------------------------------------

# 10 Interview Follow-Up Questions You Should Expect

After answering a main question, interviewers often go deeper.

### If you say "we use retries"

Expect:

-   Which failures do you retry?
-   How many times?
-   What is exponential backoff?
-   What if the operation is not idempotent?
-   How do you avoid retry storms?

### If you say "we use Kafka/RabbitMQ/Azure Service Bus"

Expect:

-   What happens if consumer fails?
-   What is acknowledgment?
-   Can messages be duplicated?
-   What is dead-lettering?
-   How do you handle ordering?
-   How do you handle poison messages?

### If you say "we use Saga"

Expect:

-   Choreography or orchestration?
-   What happens if payment fails?
-   What is compensation?
-   What is eventual consistency?
-   How do you track Saga state?

### If you say "we use API Gateway"

Expect:

-   Gateway vs load balancer?
-   Where do you authenticate?
-   What happens if gateway is down?
-   How do you rate-limit?
-   Can gateway become a bottleneck?

### If you say "each service has its own DB"

Expect:

-   How do services get data from each other?
-   How do you maintain consistency?
-   How do you join data across services?
-   How do you handle transactions?
-   What is the Outbox Pattern?

------------------------------------------------------------------------

# Final Mental Model

When you face almost any microservices interview question, think through
these 7 areas:

``` text
                 MICROservices
                      |
       +--------------+--------------+
       |              |              |
    Boundary       Communication    Data
       |              |              |
  Business        REST/Event       Ownership
  Capability      Broker           Consistency
       |
       +--------------+--------------+
                      |
                 Reliability
                      |
          Timeout / Retry / CB
                      |
       +--------------+--------------+
       |                             |
 Observability                    Security
 Logs/Metrics/Traces          AuthN/AuthZ/TLS
       |
       +--------------+
                      |
                   Scaling
              Stateless + Instances
```

## The most important interview principle

Do not just memorize patterns.

For every pattern, remember:

> **Problem → Why it happens → Solution → Trade-off → Real project
> example**

For example:

> "We used an Outbox because saving the database record and publishing
> an event are two separate operations. If the database succeeds but
> publishing fails, downstream services don't know about the change. The
> Outbox stores the event in the same transaction and publishes it
> asynchronously. The trade-off is additional infrastructure and
> eventual consistency."

That style of explanation demonstrates much stronger practical
understanding than simply saying:

> "Outbox is a design pattern."

------------------------------------------------------------------------

# Suggested Study Order

### Day 1 --- Fundamentals

Questions 1--7

### Day 2 --- Communication

Questions 8--18

### Day 3 --- Reliability

Questions 19--30

### Day 4 --- Security & APIs

Questions 31--38

### Day 5 --- Messaging & Data

Questions 39--46

### Day 6 --- Deployment & Troubleshooting

Questions 47--49

### Day 7 --- System Design

Question 50 + all follow-ups

------------------------------------------------------------------------

# One-Line Revision List

1.  Microservice = independently deployable business capability.
2.  Microservices improve independent scaling/deployment but add
    distributed complexity.
3.  Monolith is one deployable unit; microservices use multiple
    deployable units.
4.  Boundaries should follow business capabilities.
5.  Bounded context defines a meaningful domain boundary.
6.  Prefer service-owned data.
7.  Shared databases create coupling.
8.  Services communicate synchronously or asynchronously.
9.  REST is common; gRPC is useful for efficient internal communication.
10. Gateway is an API entry point.
11. Load balancer distributes traffic; gateway applies API-level
    behavior.
12. Service discovery finds service instances dynamically.
13. Sync waits; async decouples.
14. Broker transports messages between producers and consumers.
15. Command = instruction; event = fact.
16. Event-driven architecture uses events for decoupled communication.
17. Eventual consistency means convergence over time.
18. Distributed transactions span service boundaries.
19. Saga coordinates long-running distributed workflows.
20. Choreography is event-driven; orchestration has a coordinator.
21. Outbox reliably bridges DB changes and event publishing.
22. Idempotency prevents duplicate effects.
23. Retries can amplify failures.
24. Backoff spaces out retries.
25. Circuit breaker prevents repeated calls to unhealthy dependencies.
26. Timeouts prevent indefinite waiting.
27. Bulkheads isolate resources.
28. Fault tolerance contains failures.
29. Health checks help route traffic and manage instances.
30. Observability = logs + metrics + traces.
31. Distributed tracing follows requests across services.
32. Correlation IDs connect related logs/operations.
33. Secure services with strong authentication, authorization and
    transport security.
34. Authentication = identity; authorization = permissions.
35. JWT authentication validates bearer tokens and builds claims.
36. API versioning protects consumers from breaking changes.
37. Backward compatibility reduces client breakage.
38. Failed messages need retries/DLQ/recovery.
39. At-least-once delivery requires duplicate-safe consumers.
40. Poison messages repeatedly fail.
41. Use Saga/Outbox/compensation for distributed consistency.
42. Idempotency protects order creation from retries.
43. Concurrency control prevents lost updates/overselling.
44. Horizontal scaling adds instances.
45. Caching reduces latency and database load.
46. Cache-aside checks cache, then DB on a miss.
47. CI/CD + containers enable repeatable independent deployments.
48. Kubernetes orchestrates containers.
49. Troubleshoot with metrics → traces → logs → DB → infrastructure.
50. Good system design combines boundaries, communication, data,
    reliability, security, observability and scaling.
