# Microservices Interview Answers (Part 01: Q1–Q40)

### 1. What is microservices architecture and how does it differ from monolithic architecture?
- **What**: Microservices splits an app into small, independently deployable services around business capabilities; monolith ships as one unit.
- **Why**: You optimize for independent change, scaling, and team autonomy instead of shared release cycles.
- **Scenario**: Checkout bug fix shouldn’t require redeploying the entire e-commerce platform.
- **High-level flow**: Identify bounded contexts → split into services with their own data → expose APIs/events → deploy/scale per service.
- **Practical**: In .NET, each service is an ASP.NET Core app with its own repo/pipeline; you reduce “one big release” risk, but pay for distributed ops (network, observability, versioning).

### 2. What are the key characteristics of microservices?
- **What**: Small, business-aligned services with clear APIs, independent deployability, and decentralized data/ownership.
- **Why**: Keeps changes localized and enables parallel development across teams.
- **Scenario**: Catalog team ships faster without coordinating with Payments team.
- **High-level flow**: Define domain boundaries → enforce API contracts → isolate persistence → automate CI/CD → add observability.
- **Practical**: “Small” means cohesive; if a service needs multiple teams to change it, boundaries are wrong.

### 3. What are the advantages of microservices architecture?
- **What**: Independent deployment, targeted scaling, tech flexibility, fault isolation, and team autonomy.
- **Why**: Reduces blast radius and improves delivery throughput for large systems.
- **Scenario**: Recommendation service needs 10× CPU during peak; scale only that service.
- **High-level flow**: Split by domain → containerize → orchestrate (K8s) → apply resilience patterns → monitor SLOs.
- **Practical**: You trade “one app simplicity” for the ability to ship features weekly/daily with safer rollouts.

### 4. What are the disadvantages and challenges of microservices?
- **What**: Operational complexity: distributed tracing, network failures, data consistency, deployment coordination, and higher infra cost.
- **Why**: You move complexity from code-in-process to code-over-network.
- **Scenario**: An order flow spans 6 services; a single timeout can break UX.
- **High-level flow**: Add centralized observability → standardize contracts → use retries/timeouts/circuit breakers → apply sagas/outbox.
- **Practical**: Without strong DevOps + platform practices, microservices can slow teams more than monoliths.

### 5. When should you choose microservices over monolithic architecture?
- **What**: Choose microservices when independent scaling/releasing is critical and you have multiple teams and strong automation.
- **Why**: Microservices benefits show up at org/scale, not at “one small team” scale.
- **Scenario**: 8 squads releasing different parts of a product; monolith release train becomes the bottleneck.
- **High-level flow**: Validate domain boundaries → build platform basics (CI/CD, logging, tracing) → incrementally extract services.
- **Practical**: If you can’t invest in ops/observability, start with a modular monolith and evolve later.

### 6. What is the difference between microservices and SOA (Service-Oriented Architecture)?
- **What**: SOA often centers on shared enterprise integration (ESB), heavier governance; microservices prefer lightweight protocols, decentralized ownership.
- **Why**: Microservices optimize for team autonomy and independent deployment.
- **Scenario**: SOA “shared ESB” becomes a bottleneck; microservices use events/APIs directly.
- **High-level flow**: SOA: central mediation; Microservices: service-owned contracts + bounded contexts + automated delivery.
- **Practical**: Modern microservices avoid “shared everything” (schemas, libraries, ESB) to keep coupling low.

### 7. What is domain-driven design (DDD) and how does it relate to microservices?
- **What**: DDD models software around domain language and boundaries (bounded contexts); those boundaries map well to microservices.
- **Why**: It prevents “technical-layer services” and reduces cross-service chatty calls.
- **Scenario**: “Order” means different things in Sales vs Fulfillment; split contexts.
- **High-level flow**: Discover domain → define bounded contexts → align services to contexts → define contracts/events.
- **Practical**: In .NET, each service owns its domain model + database; integration happens via APIs/events, not shared entity classes.

### 8. What is bounded context in microservices?
- **What**: A boundary where a domain model and its meaning are consistent; outside it, terms can differ.
- **Why**: Controls complexity and coupling by making ownership explicit.
- **Scenario**: “Customer” in CRM vs “Customer” in Billing has different rules/fields.
- **High-level flow**: Identify contexts → define ubiquitous language → set integration contracts → avoid shared DB/entities.
- **Practical**: Good contexts reduce “one change breaks five services” because each service evolves its model independently.

### 9. How do you identify service boundaries in microservices?
- **What**: Boundaries follow business capabilities, data ownership, and change frequency—not technical layers.
- **Why**: Correct boundaries minimize chatty calls and cross-team dependencies.
- **Scenario**: Separate Catalog (read-heavy) from Orders (transaction-heavy) and Payments (risk/compliance).
- **High-level flow**: Event storming → map bounded contexts → define aggregates → validate with teams/SLAs → iterate.
- **Practical**: I look for “high cohesion, low coupling”: one team can deliver features without touching other services.

### 10. What is the difference between microservices and serverless architecture?
- **What**: Microservices are long-running services; serverless runs functions on-demand (FaaS) with managed scaling and billing.
- **Why**: Serverless reduces ops but can constrain runtime, state, and networking patterns.
- **Scenario**: Image resize pipeline is great for serverless; core checkout often fits services.
- **High-level flow**: Microservices: container + orchestrator; Serverless: trigger → function → managed integrations.
- **Practical**: In .NET, serverless (Azure Functions/Lambda) is excellent for event handlers, not always for low-latency stateful workflows.

### 11. What is the API-first approach in microservices?
- **What**: Design contracts (OpenAPI/Proto) before implementation; treat APIs as products.
- **Why**: Reduces rework and supports parallel development via mocks/contract tests.
- **Scenario**: Frontend team starts against OpenAPI mocks while backend builds service.
- **High-level flow**: Define resources/events → specify schema/errors → version strategy → generate clients → implement + contract test.
- **Practical**: In .NET, we often generate clients (NSwag/Refit, or gRPC stubs) and enforce compatibility in CI.

### 12. How do you handle service versioning in microservices?
- **What**: Prefer backward-compatible changes; version only when breaking (headers/URL/v2 service).
- **Why**: Avoids “upgrade all consumers now” outages.
- **Scenario**: Add a new optional field; never remove/rename without a migration plan.
- **High-level flow**: Additive changes → deprecate → dual-write/dual-read → monitor usage → remove later.
- **Practical**: I treat contracts as immutable: add fields, don’t break; for gRPC, use reserved fields/numbers.

### 13. What is the difference between horizontal and vertical scaling in microservices?
- **What**: Horizontal scales out (more instances); vertical scales up (bigger machine).
- **Why**: Horizontal is more resilient and elastic; vertical hits hardware limits.
- **Scenario**: Scale Order API pods from 3 to 30 for a sale; don’t just buy a bigger VM.
- **High-level flow**: Stateless services + external state → load balancer → autoscaling rules → capacity tests.
- **Practical**: In K8s, HPA + stateless ASP.NET Core APIs is the standard; state is in DB/cache/queues.

### 14. What is service mesh and why is it important?
- **What**: A layer (Istio/Linkerd) that handles service-to-service traffic (mTLS, retries, routing) via sidecar proxies.
- **Why**: Centralizes cross-cutting network concerns without changing app code.
- **Scenario**: Canary routing 10% traffic to v2 + mTLS between services with minimal code changes.
- **High-level flow**: Deploy mesh → inject sidecars → define policies (mTLS, retries, timeouts) → observe via telemetry.
- **Practical**: Great for large fleets, but adds complexity—use it when you truly need consistent traffic/security controls.

### 15. How do you ensure consistency across microservices?
- **What**: You don’t aim for global ACID; you use invariants within a service and eventual consistency across services.
- **Why**: Distributed ACID is expensive and fragile at scale.
- **Scenario**: Order placed → payment authorized → inventory reserved with compensations.
- **High-level flow**: Local transaction per service → publish event (outbox) → consumers update their state → saga for coordination.
- **Practical**: In .NET, I pair EF Core transaction + outbox table, then a background publisher to broker (Kafka/RabbitMQ).

### 16. What is eventual consistency and when is it acceptable?
- **What**: Updates propagate asynchronously; different services may temporarily disagree.
- **Why**: Enables availability and independent services without distributed locks/2PC.
- **Scenario**: After payment, “Order status” becomes “Paid” within seconds, not instantly.
- **High-level flow**: Emit events → retry consumers → handle duplicates → reconcile via compensations.
- **Practical**: Acceptable when business tolerates short delay; not acceptable for strict invariants like “don’t oversell” without reservation rules.

### 17. What is the difference between orchestration and choreography in microservices?
- **What**: Orchestration uses a central coordinator; choreography uses events where services react independently.
- **Why**: Orchestration gives visibility/control; choreography reduces central coupling.
- **Scenario**: Checkout saga: orchestrator coordinates steps vs event chain “OrderCreated → PaymentRequested → …”.
- **High-level flow**: Orchestration: workflow engine/handler; Choreography: publish domain events and react.
- **Practical**: For complex business workflows, I often start with orchestration (clear state machine) then evolve toward choreography as domains stabilize.

### 18. How do you handle shared data between microservices?
- **What**: Avoid shared DB; share data via APIs, events, and read models (replication) owned by each service.
- **Why**: Shared data creates tight coupling and coordinated releases.
- **Scenario**: Reporting service needs order totals—subscribe to Order events and build its own read store.
- **High-level flow**: Define source-of-truth service → publish events → consumers maintain local projections → backfill/replay if needed.
- **Practical**: “Duplicate data is fine; duplicate logic isn’t.” Each service owns its storage, even if some fields are replicated.

### 19. What is the database per service pattern?
- **What**: Each service owns its database/schema and is the only writer.
- **Why**: Enforces autonomy and prevents accidental coupling through shared tables.
- **Scenario**: Orders DB changes don’t require Billing service coordination.
- **High-level flow**: Separate DBs/schemas → service-only credentials → integrate via API/events → migrations per service.
- **Practical**: In SQL Server, I still separate by database or schema + permissions; the key is ownership and independent migration pipelines.

### 20. How do you maintain data consistency in a distributed system?
- **What**: Use sagas, outbox/inbox, idempotent consumers, and compensating actions instead of distributed transactions.
- **Why**: Networks fail; you need reliable messaging and recoverable workflows.
- **Scenario**: Payment succeeds but inventory reserve fails—compensate by refund/cancel.
- **High-level flow**: Local commit → publish event (outbox) → process with retries (inbox) → compensate on failure → reconcile jobs.
- **Practical**: Consistency is a business decision: define what must be consistent now vs later, then implement workflows around those invariants.

### 21. What are the different communication patterns in microservices?
- **What**: Sync (HTTP/gRPC), async messaging (queues, pub/sub), and event streaming; also request aggregation (BFF/gateway).
- **Why**: Different patterns fit latency, coupling, and throughput needs.
- **Scenario**: Sync for “get order status”; async for “send email” or “update analytics”.
- **High-level flow**: Classify interactions → choose protocol → define contracts → add resilience (timeouts/retries) → monitor.
- **Practical**: My default: synchronous for user-facing reads, asynchronous for cross-domain writes and side effects.

### 22. What is synchronous communication and when should you use it?
- **What**: Caller waits for response (HTTP/gRPC).
- **Why**: Simpler for request/response and immediate UX.
- **Scenario**: API Gateway calls Product service to render a product page.
- **High-level flow**: Client → gateway/service → downstream call → return → handle timeouts/circuit breakers.
- **Practical**: Keep sync call chains short (1–2 hops); otherwise latency and failure probability explode.

### 23. What is asynchronous communication and its benefits?
- **What**: Caller doesn’t wait; work is queued or evented (RabbitMQ/Kafka/Azure Service Bus).
- **Why**: Better resilience, throughput, and decoupling; smooths spikes.
- **Scenario**: “OrderPlaced” event triggers email, invoice, analytics independently.
- **High-level flow**: Publish message/event → broker stores → consumers process with retries → DLQ for poison messages.
- **Practical**: Requires idempotency and observability (correlation IDs), but makes systems far more stable under load.

### 24. What is the difference between REST and gRPC?
- **What**: REST typically uses HTTP+JSON; gRPC uses HTTP/2 with Protobuf and strongly typed contracts.
- **Why**: gRPC is faster and better for internal service-to-service; REST is universal and easy for browsers.
- **Scenario**: Internal pricing calls at high QPS use gRPC; public API uses REST.
- **High-level flow**: REST: OpenAPI + JSON; gRPC: proto → generate client/server → streaming support.
- **Practical**: In .NET, gRPC gives strong typing and streaming; REST is better for external clients and debuggability.

### 25. When would you choose gRPC over REST?
- **What**: Choose gRPC for low-latency, high-throughput internal calls, streaming, and strict contracts.
- **Why**: Protobuf + HTTP/2 reduces payload and improves performance.
- **Scenario**: Real-time fraud scoring or inventory checks with many small calls.
- **High-level flow**: Define proto → generate stubs → enforce deadlines/timeouts → add retries/circuit breaker.
- **Practical**: If you need browser-first compatibility, REST is simpler; gRPC-Web exists but adds tooling complexity.

### 26. What is message queuing and how is it used in microservices?
- **What**: A broker buffers messages so producers and consumers are decoupled in time and scale.
- **Why**: Absorbs spikes and enables reliable background processing.
- **Scenario**: Payment service enqueues “CapturePayment”; workers process at a controlled rate.
- **High-level flow**: Producer publishes → broker persists → consumer reads/acks → retry/DLQ on failures.
- **Practical**: In .NET, MassTransit/NServiceBus simplify retries, sagas, and message routing on top of RabbitMQ/ASB.

### 27. What is event-driven architecture in microservices?
- **What**: Services publish domain events; other services react, forming loosely coupled workflows.
- **Why**: Minimizes direct dependencies and supports scalability.
- **Scenario**: “UserRegistered” triggers welcome email, profile setup, analytics.
- **High-level flow**: Emit domain event → broker/stream → consumers update local state → ensure idempotency and ordering where needed.
- **Practical**: The key is event design: events are facts (“OrderPlaced”), not commands (“DoPaymentNow”).

### 28. What is the difference between event sourcing and CQRS?
- **What**: Event sourcing stores state as an append-only event log; CQRS separates write (commands) from read (queries) models.
- **Why**: Event sourcing gives audit/replay; CQRS improves scaling and model clarity.
- **Scenario**: Banking ledger uses event sourcing; reads use projections (CQRS).
- **High-level flow**: Commands validate → append events → projections build read models → queries hit projections.
- **Practical**: You can do CQRS without event sourcing (normal DB writes), but event sourcing almost always implies CQRS projections.

### 29. What is a message broker and which ones are commonly used?
- **What**: Infrastructure that routes, buffers, and persists messages/events between services.
- **Why**: Provides decoupling, retries, backpressure, and delivery guarantees.
- **Scenario**: RabbitMQ for work queues; Kafka for event streaming; Azure Service Bus for managed enterprise messaging.
- **High-level flow**: Define topics/queues → publish → consumer groups → retries/DLQ → monitoring.
- **Practical**: Pick based on use case: task distribution vs event log vs cloud-managed requirements and ops skill.

### 30. What is the difference between RabbitMQ and Apache Kafka?
- **What**: RabbitMQ is queue-based messaging with flexible routing; Kafka is a distributed commit log optimized for streaming and replay.
- **Why**: Kafka excels at high-throughput events + reprocessing; RabbitMQ excels at work queues and complex routing patterns.
- **Scenario**: “SendEmail” tasks fit RabbitMQ; “OrderEvents” stream fits Kafka.
- **High-level flow**: RabbitMQ: exchanges/queues/acks; Kafka: topics/partitions/consumer groups/offsets.
- **Practical**: If you need durable replay and multiple independent consumers at scale, Kafka is a strong fit; otherwise RabbitMQ is simpler operationally.

### 31. When would you use Kafka over RabbitMQ?
- **What**: Use Kafka for event streaming, audit trails, and replayable pipelines with high throughput.
- **Why**: Kafka’s partitioned log and offsets make “replay and rebuild” practical.
- **Scenario**: Rebuild analytics projections by replaying last 30 days of events.
- **High-level flow**: Publish immutable events → partition by key → consumers track offsets → build projections → handle schema evolution.
- **Practical**: Kafka needs careful partitioning and schema governance; don’t use it just because it’s popular.

### 32. What is pub/sub pattern in microservices?
- **What**: Publishers emit messages to a topic; many subscribers receive independently.
- **Why**: Enables fan-out without hardcoding dependencies.
- **Scenario**: “OrderPlaced” topic consumed by Billing, Shipping, Notifications, Analytics.
- **High-level flow**: Publish to topic → broker delivers to subscriber queues/groups → each consumer processes with retries.
- **Practical**: Pub/sub works best when events are stable facts; avoid publishing internal implementation details.

### 33. How do you handle message ordering in distributed systems?
- **What**: Enforce ordering per key (partitioning) and design consumers to tolerate out-of-order when global ordering isn’t feasible.
- **Why**: Global ordering kills scalability; per-aggregate ordering is usually enough.
- **Scenario**: Order status updates must be processed in order per OrderId.
- **High-level flow**: Partition/queue by key → single-thread per key/partition → store last processed version → ignore stale events.
- **Practical**: I include a sequence/version (or event time + optimistic rules) and make handlers idempotent and order-aware.

### 34. What is idempotency and why is it important in microservices?
- **What**: Processing the same request/message multiple times results in the same final state.
- **Why**: Retries and at-least-once delivery are normal; idempotency prevents duplicate side effects.
- **Scenario**: Payment capture retried due to timeout must not charge twice.
- **High-level flow**: Use idempotency key → store processed keys/results → reject/return same outcome → ensure DB uniqueness.
- **Practical**: In .NET, I often persist an idempotency record keyed by (ClientId, IdempotencyKey) with the response snapshot.

### 35. How do you ensure message delivery guarantees?
- **What**: Choose semantics (at-most-once, at-least-once, exactly-once-ish) and implement accordingly with retries/DLQ and idempotency.
- **Why**: No free lunch: stronger guarantees increase complexity and cost.
- **Scenario**: “InvoiceGenerated” must not be lost; duplicates are acceptable if idempotent.
- **High-level flow**: Durable broker → consumer acks after commit → retry with backoff → DLQ + alert → idempotent handler.
- **Practical**: “Exactly once” in practice means “at least once + idempotent processing + transactional outbox/inbox”.

### 36. What is the saga pattern and when do you use it?
- **What**: A saga is a sequence of local transactions with compensating actions for failures.
- **Why**: Replaces distributed transactions across services.
- **Scenario**: Place order → reserve stock → capture payment; if stock fails, cancel/refund.
- **High-level flow**: Start saga → execute step → publish event → next step → on failure run compensations → end.
- **Practical**: In .NET, MassTransit/NServiceBus sagas or a custom orchestrator persist saga state and handle retries/timeouts.

### 37. What are the different types of saga patterns?
- **What**: Orchestration-based (central coordinator) and choreography-based (event reactions).
- **Why**: Orchestration improves control; choreography reduces central coupling.
- **Scenario**: Orchestrator for checkout; choreography for simpler “user registered” workflows.
- **High-level flow**: Orchestration: coordinator issues commands; Choreography: services react to events and emit next events.
- **Practical**: I pick orchestration when the business cares about explicit workflow state and auditing.

### 38. How do you handle distributed transactions in microservices?
- **What**: Avoid 2PC; use sagas, outbox/inbox, compensations, and reconciliation.
- **Why**: Distributed ACID doesn’t scale well and fails badly under partitions.
- **Scenario**: Payment succeeded but shipping label creation failed; compensate and retry.
- **High-level flow**: Local commit → publish event → next service commits → on failure compensate → periodic reconciliation jobs.
- **Practical**: Business rules must define “undo”: cancel order, refund, release inventory, and notify users.

### 39. What is two-phase commit (2PC) and why is it avoided in microservices?
- **What**: A coordinator asks participants to prepare, then commit; ensures atomic commit across resources.
- **Why**: It’s slow, blocks resources, and is fragile under network partitions—bad for availability.
- **Scenario**: One DB participant is slow; the whole transaction holds locks and degrades the system.
- **High-level flow**: Prepare phase → participants lock → commit/rollback; failures cause blocking/timeouts.
- **Practical**: Microservices prefer availability and autonomy, so we redesign workflows (sagas) instead of forcing atomic cross-service commits.

### 40. How do you implement request/response pattern in microservices?
- **What**: A service calls another via HTTP/gRPC and waits for response; optionally via async RPC over messaging.
- **Why**: Fits read queries and simple commands needing immediate feedback.
- **Scenario**: Gateway calls Pricing service to price a cart before showing totals.
- **High-level flow**: Client → service A → call service B with timeout → handle transient faults (retry/backoff) → return.
- **Practical**: In .NET, I standardize HttpClientFactory + Polly policies, enforce deadlines, and propagate correlation IDs for tracing.


