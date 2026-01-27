# Microservices Interview Answers (Part 02: Q41–Q80)

### 41. What is service discovery and why is it needed?
- **What**: Service discovery is how services find each other’s network locations dynamically (instances come/go).
- **Why**: In K8s/containers, IPs change; hardcoding endpoints breaks reliability and scaling.
- **Scenario**: Order service scales from 3→20 pods; clients must hit any healthy instance.
- **High-level flow**: Register instances → maintain health → clients/gateway resolve via registry/DNS → load balance.
- **Practical**: In Kubernetes, `Service` + DNS provides discovery; outside K8s, tools like Consul/Eureka handle registration/health.

### 42. What are the types of service discovery patterns?
- **What**: Client-side discovery, server-side discovery, and platform/DNS-based discovery.
- **Why**: Each shifts complexity between clients, infrastructure, and gateways.
- **Scenario**: A .NET service either queries Consul itself (client-side) or calls a load balancer (server-side).
- **High-level flow**: Client-side: client queries registry; Server-side: client hits LB/gateway; Platform: DNS/service abstraction.
- **Practical**: I prefer platform-native discovery (K8s) or server-side (gateway/LB) to avoid duplicating discovery logic in every service.

### 43. What is client-side service discovery?
- **What**: The client queries a service registry, picks an instance, and calls it directly.
- **Why**: Avoids extra hop, enables smart client-side load balancing.
- **Scenario**: A .NET service looks up `inventory` instances in Consul and round-robins.
- **High-level flow**: Query registry → filter healthy instances → pick instance → call with retries/timeouts.
- **Practical**: Powerful but increases client complexity; you must standardize libraries and handle edge cases consistently.

### 44. What is server-side service discovery?
- **What**: Client calls a router/load balancer; router resolves service instances and forwards the request.
- **Why**: Keeps clients simple and centralizes routing policies.
- **Scenario**: API Gateway routes `/orders` to the Orders service instances.
- **High-level flow**: Client → gateway/LB → registry lookup → forward to healthy instance → return response.
- **Practical**: This is common with YARP/Ocelot, NGINX/Envoy, or cloud LBs; it also simplifies certificate and auth enforcement.

### 45. What is the difference between service registry and service discovery?
- **What**: Registry is the database of service instances; discovery is the process of finding and selecting an instance.
- **Why**: Separating concepts clarifies responsibilities (registration, health, lookup, selection).
- **Scenario**: Consul is a registry; your gateway performing lookups is discovery.
- **High-level flow**: Instance registers → health checks update registry → clients/gateway discover via queries/DNS.
- **Practical**: Failures often happen when health is stale; keep TTL/health checks tight and observable.

### 46. What are popular service discovery tools?
- **What**: Consul, Eureka, Kubernetes DNS/Services, etcd-backed patterns, and cloud-native registries.
- **Why**: They provide registration, health checks, and lookup APIs.
- **Scenario**: Legacy Spring stack uses Eureka; polyglot stack uses Consul; K8s uses `Service` DNS.
- **High-level flow**: Choose tool → integrate registration/health → configure clients/gateway → monitor registry health.
- **Practical**: In K8s, “use the platform” first; in VM-based setups, Consul is a solid default.

### 47. How does Consul handle service discovery?
- **What**: Consul maintains a registry with health checks and provides DNS/HTTP APIs for lookups.
- **Why**: Enables dynamic service endpoints and health-aware routing.
- **Scenario**: Orders queries `inventory.service.consul` via DNS to get healthy instances.
- **High-level flow**: Service registers → Consul runs health checks → clients query DNS/HTTP → load balance to healthy nodes.
- **Practical**: Consul works well with sidecars/Envoy too; keep health checks meaningful (not just “process up”).

### 48. How does Eureka handle service discovery?
- **What**: Eureka is a Netflix OSS registry where services register themselves and clients query for instances.
- **Why**: Designed for cloud environments with frequent instance churn.
- **Scenario**: Client fetches instance list from Eureka and does client-side load balancing.
- **High-level flow**: Service registers → heartbeats → clients cache registry → resolve and call instances.
- **Practical**: It’s common in Java ecosystems; in .NET you’d typically prefer K8s DNS or Consul unless you’re in a mixed-stack environment.

### 49. What is API Gateway and what are its responsibilities?
- **What**: A single entry point that routes requests to services and handles cross-cutting concerns.
- **Why**: Simplifies clients and centralizes policy enforcement.
- **Scenario**: Mobile app calls gateway; gateway routes to Catalog/Orders and applies auth + rate limits.
- **High-level flow**: Authenticate → authorize → route → transform/aggregate → enforce limits → log/trace.
- **Practical**: In .NET, YARP is a strong choice; keep business logic out of the gateway (avoid turning it into a mini-monolith).

### 50. What are the benefits of using an API Gateway?
- **What**: Central auth, routing, throttling, request shaping, aggregation, and observability at the edge.
- **Why**: Reduces client complexity and prevents every service duplicating the same cross-cutting code.
- **Scenario**: Add rate limiting once at gateway instead of 20 services.
- **High-level flow**: Define routes → policies (auth/limits) → transforms → deploy with HA → monitor.
- **Practical**: Gateways are a great place for “edge” concerns; internal service-to-service auth is still needed (zero-trust).

### 51. What is the difference between API Gateway and service mesh?
- **What**: Gateway handles north-south traffic (client↔system); mesh handles east-west traffic (service↔service).
- **Why**: They solve different layers: edge API management vs internal traffic/security.
- **Scenario**: Gateway authenticates external users; mesh enforces mTLS between services.
- **High-level flow**: Gateway at perimeter; mesh sidecars handle routing/retries/telemetry internally.
- **Practical**: You can use both: gateway for external APIs, mesh for internal policy and traffic control.

### 52. How does API Gateway handle authentication and authorization?
- **What**: It validates tokens/keys (authn) and enforces access rules (authz) before routing.
- **Why**: Central enforcement reduces duplicated security bugs.
- **Scenario**: Validate JWT (issuer/audience) and enforce scopes/roles for `/admin/*`.
- **High-level flow**: Validate token → map claims → check policy → forward identity context → services re-check critical permissions.
- **Practical**: In .NET stacks, I do JWT validation at gateway plus service-level authorization for defense-in-depth.

### 53. What is API Gateway routing and load balancing?
- **What**: Routing maps paths/hosts to services; load balancing distributes requests across healthy instances.
- **Why**: Supports scaling and resilience without client changes.
- **Scenario**: `/orders/*` routes to Orders; gateway round-robins across pods.
- **High-level flow**: Match route → pick backend pool → health-check → apply LB strategy → forward with timeouts.
- **Practical**: Prefer health-aware LB and timeouts; otherwise the gateway can amplify failures by sending traffic to unhealthy instances.

### 54. How does API Gateway handle rate limiting?
- **What**: It caps requests per client/IP/token using counters and policies.
- **Why**: Prevents abuse and protects downstream services from overload.
- **Scenario**: Public API allows 100 req/min per API key; bursts are smoothed.
- **High-level flow**: Identify caller → check counter (Redis/distributed store) → allow/deny → return 429 + headers.
- **Practical**: Use distributed storage for multi-node gateways; in cloud, managed API gateways often provide this out-of-the-box.

### 55. What is the difference between API Gateway and reverse proxy?
- **What**: Reverse proxy mainly forwards traffic; API Gateway adds API-specific features (auth, quotas, transforms, aggregation).
- **Why**: Gateways are product-facing; proxies are infrastructure routing.
- **Scenario**: NGINX as reverse proxy vs gateway doing JWT validation and per-client throttling.
- **High-level flow**: Proxy: route + TLS termination; Gateway: route + policies + developer-facing controls.
- **Practical**: YARP can act as both; the difference is how much API management policy you layer on top.

### 56. How do you handle API versioning at the gateway level?
- **What**: Route versions by path (`/v2`), header, or host; support parallel versions during migration.
- **Why**: Allows non-breaking evolution for external consumers.
- **Scenario**: `/v1/orders` and `/v2/orders` map to different backends or transforms.
- **High-level flow**: Define versioning scheme → route to appropriate service/version → deprecate old → monitor usage.
- **Practical**: I prefer URI or header-based versioning with strong deprecation timelines and dashboards.

### 57. What is circuit breaker pattern in API Gateway?
- **What**: The gateway stops calling a failing downstream service temporarily to prevent cascading failures.
- **Why**: Protects the system and improves overall availability.
- **Scenario**: Inventory service is timing out; gateway opens circuit and serves fallback/fast failure.
- **High-level flow**: Track failures → open circuit → reject fast → half-open after cool-down → close on success.
- **Practical**: Pair circuit breakers with good fallbacks (cached reads, “try again” UX) and strict timeouts.

### 58. How does API Gateway handle request aggregation?
- **What**: It composes multiple backend calls into one response for the client.
- **Why**: Reduces client chattiness and improves perceived latency for UI use cases.
- **Scenario**: Product page needs catalog + pricing + inventory; gateway returns a single DTO.
- **High-level flow**: Receive request → parallel calls → combine/transform → partial failure strategy → respond.
- **Practical**: Keep aggregation close to UI needs (often BFF); avoid complex business workflows in the gateway.

### 59. What is the difference between edge gateway and internal gateway?
- **What**: Edge gateway fronts external clients; internal gateway fronts internal consumers or segments traffic between domains.
- **Why**: Different policies: edge needs strong auth, WAF, quotas; internal optimizes routing and service policies.
- **Scenario**: Public API gateway vs internal gateway per domain (Orders domain gateway).
- **High-level flow**: Edge: identity + throttling + transforms; Internal: routing + mTLS + tenancy boundaries.
- **Practical**: Internal gateways can reduce coupling by providing stable “domain APIs” while services evolve behind them.

### 60. How do you implement service mesh with API Gateway?
- **What**: Use gateway for north-south; mesh handles east-west via sidecars and policies.
- **Why**: Separation of concerns keeps edge and internal traffic management clean.
- **Scenario**: Gateway terminates OAuth; mesh enforces mTLS and traffic splitting between service versions.
- **High-level flow**: Deploy mesh → configure ingress/egress gateways → route traffic into mesh → apply policies (mTLS, retries).
- **Practical**: Ensure identity propagation and tracing context from gateway into mesh to avoid “blind spots” in observability.

### 61. What is the database per service pattern?
- **What**: Each service has its own datastore and schema; others access data only via API/events.
- **Why**: Prevents shared-schema coupling and enables independent deployments.
- **Scenario**: Billing needs customer address—consume an event and store a local copy.
- **High-level flow**: Assign ownership → isolate credentials → integrate via events/APIs → apply migrations per service.
- **Practical**: Even on the same SQL Server, enforce separate DB/schema and permissions; ownership is the real rule.

### 62. How do you handle data consistency across multiple databases?
- **What**: Use eventual consistency with reliable messaging (outbox/inbox), sagas, and reconciliation.
- **Why**: Cross-DB ACID is fragile and reduces availability.
- **Scenario**: Order DB commit succeeds; publish `OrderCreated` so Shipping builds its projection.
- **High-level flow**: Local transaction → outbox publish → consumers update local DB → compensations + periodic reconciliation.
- **Practical**: Design for retries and duplicates; your “happy path” must also be your “retry path”.

### 63. What is the shared database anti-pattern?
- **What**: Multiple services read/write the same database/schema directly.
- **Why**: Creates tight coupling, coordinated deployments, and hidden dependencies.
- **Scenario**: One service changes a column; five services break at runtime.
- **High-level flow**: Identify shared tables → pick an owner service → expose API/events → migrate consumers → lock down DB access.
- **Practical**: Shared reporting DB is okay as a projection; shared operational tables across services is where pain starts.

### 64. How do you handle transactions across multiple services?
- **What**: Use sagas with compensations rather than a single distributed transaction.
- **Why**: Network partitions and partial failures make global ACID unreliable.
- **Scenario**: Checkout: reserve inventory, charge payment, create shipment; compensate on failures.
- **High-level flow**: Define steps + compensations → orchestrate/choreograph → persist saga state → retry/timeouts → finalization.
- **Practical**: Write down business “undo” rules first; the code follows those rules, not the other way around.

### 65. What is eventual consistency and how do you achieve it?
- **What**: Data converges over time via asynchronous propagation.
- **Why**: Enables availability and independent scaling.
- **Scenario**: “My orders” page shows latest status within seconds after payment.
- **High-level flow**: Publish domain events → consumers update projections → handle duplicates/out-of-order → reconcile.
- **Practical**: I use outbox + idempotent handlers and monitor “event lag” as a first-class metric.

### 66. What is CQRS (Command Query Responsibility Segregation)?
- **What**: Separate models/paths for writes (commands) and reads (queries).
- **Why**: Reads and writes have different scaling and modeling needs.
- **Scenario**: Orders writes are strict; reads need denormalized “order summary” for UI.
- **High-level flow**: Commands validate + persist → emit events → build read projections → queries hit read store.
- **Practical**: CQRS is especially valuable when read patterns are complex or high-volume compared to writes.

### 67. How does CQRS help in microservices architecture?
- **What**: It keeps write models clean and lets each service expose optimized read models without leaking domain internals.
- **Why**: Reduces chatty read calls and avoids join-across-services anti-patterns.
- **Scenario**: UI queries a read model built from events instead of calling 5 services.
- **High-level flow**: Emit events → projection service/store → query via API/BFF → keep projections eventually consistent.
- **Practical**: CQRS + events is my go-to for “read-heavy dashboards” and reporting without shared DBs.

### 68. What is event sourcing and how does it work?
- **What**: Persist state changes as an append-only stream of events; current state is derived by replaying events.
- **Why**: Full audit trail and the ability to rebuild projections.
- **Scenario**: Financial ledger: `Deposited`, `Withdrawn`, `FeeApplied` events.
- **High-level flow**: Command → validate against current state → append event(s) → publish → projections update.
- **Practical**: Event sourcing demands strong event versioning and tooling; I use it for domains needing audit/replay, not everywhere.

### 69. What are the benefits and drawbacks of event sourcing?
- **What**: Benefits: audit, replay, temporal queries; Drawbacks: complexity, event evolution, and harder ad-hoc queries.
- **Why**: You trade operational simplicity for powerful history and rebuild capabilities.
- **Scenario**: Recompute loyalty points by replaying purchase events after a rules change.
- **High-level flow**: Append events → maintain snapshots/projections → evolve schemas → handle replays safely.
- **Practical**: Without disciplined schema governance and observability, event sourcing can become hard to maintain.

### 70. How do you handle data migration in microservices?
- **What**: Each service owns its migration; cross-service changes are handled via contract evolution and dual-write/dual-read strategies.
- **Why**: There is no “big-bang schema migration” across all services safely.
- **Scenario**: Split `Address` into `ShippingAddress` and `BillingAddress` with backward compatibility.
- **High-level flow**: Add new fields/tables → dual-write → backfill → switch reads → remove old after deprecation.
- **Practical**: In .NET, EF Core migrations per service + feature flags + dashboards for old-field usage works well.

### 71. What is the saga pattern for data consistency?
- **What**: A saga coordinates multiple local DB transactions with compensations to achieve business consistency.
- **Why**: Maintains correctness without distributed locks/2PC.
- **Scenario**: Order saga ensures “paid + reserved + shipped” or compensates to “cancelled/refunded”.
- **High-level flow**: Start saga → execute step transactions → publish events/commands → compensate on failure → complete.
- **Practical**: I persist saga state (current step, correlation id, timestamps) so restarts and retries are safe.

### 72. How do you handle read and write operations in distributed databases?
- **What**: Writes are owned by one service; reads use projections, caching, and read replicas depending on needs.
- **Why**: Cross-service writes cause coupling; cross-service reads cause latency and fragility.
- **Scenario**: Reporting reads from a denormalized store built from events.
- **High-level flow**: Single-writer for invariants → publish events → build read models → queries hit local store/cache.
- **Practical**: For user-facing reads, I prioritize low latency: local read model + cache beats runtime fan-out calls.

### 73. What is the difference between SQL and NoSQL in microservices context?
- **What**: SQL offers strong consistency and relational queries; NoSQL offers flexible schema and horizontal scaling patterns.
- **Why**: Different services have different data shapes and access patterns.
- **Scenario**: Orders uses SQL (transactions); Catalog search uses NoSQL/document or search engine.
- **High-level flow**: Choose per service based on invariants and query patterns → encapsulate behind service API.
- **Practical**: “Polyglot persistence” is normal in microservices—pick the best store per bounded context.

### 74. When would you choose NoSQL over SQL for a microservice?
- **What**: Choose NoSQL for high-scale reads/writes with simple access patterns, flexible schema, or document-like aggregates.
- **Why**: Avoids heavy joins and supports partitioning at scale.
- **Scenario**: Session store, product catalog documents, user activity feed.
- **High-level flow**: Model aggregates as documents → choose partition key → implement idempotent writes → add TTL/indexing.
- **Practical**: If you need complex relational constraints and transactions, SQL is still the safer default.

### 75. How do you handle data replication in microservices?
- **What**: Replicate via events (source of truth publishes) or database replication for read replicas within a service.
- **Why**: Replication improves read performance and availability but introduces staleness.
- **Scenario**: Analytics service builds its own DB by consuming `Order*` events.
- **High-level flow**: Define event contracts → consume with idempotency → build projection → monitor lag → reconcile.
- **Practical**: I avoid “replicate by querying another service at runtime”; I replicate by events to keep reads stable.

### 76. What is the difference between master-slave and master-master replication?
- **What**: Master-slave: one writer, many read replicas; Master-master: multiple writers across nodes/regions.
- **Why**: Master-master improves write availability but increases conflict resolution complexity.
- **Scenario**: Global app wants local writes in multiple regions—conflicts must be handled.
- **High-level flow**: Master-slave: route writes to primary; Master-master: multi-primary writes + conflict resolution.
- **Practical**: For most microservices, single-writer (master-slave) is simpler; multi-writer requires careful domain rules for conflicts.

### 77. How do you ensure data integrity in a distributed system?
- **What**: Enforce invariants within the owning service; use contracts, idempotency, and reconciliation across services.
- **Why**: You cannot rely on cross-service DB constraints.
- **Scenario**: Prevent duplicate orders via idempotency keys and unique constraints in Orders DB.
- **High-level flow**: Validate locally → persist with constraints → publish events reliably → verify with audits/reconciliation.
- **Practical**: I add “data correctness jobs” that compare projections vs source-of-truth and self-heal or alert.

### 78. What is the difference between ACID and BASE properties?
- **What**: ACID focuses on strong transactional guarantees; BASE focuses on availability with eventual consistency.
- **Why**: Distributed systems often accept BASE to remain highly available.
- **Scenario**: Inventory projection can be eventually consistent; payment ledger needs ACID within its boundary.
- **High-level flow**: Use ACID inside a service; use events/sagas (BASE) across services.
- **Practical**: The trick is knowing where ACID is mandatory (money, compliance) and where BASE is acceptable (views, analytics).

### 79. How do you handle data partitioning in microservices?
- **What**: Partition data by a key (tenant/user/order) to scale horizontally; each service chooses its own partition strategy.
- **Why**: Keeps hot spots manageable and reduces contention.
- **Scenario**: Orders partitioned by `CustomerId` or `OrderId` for even distribution.
- **High-level flow**: Choose partition key → avoid cross-partition queries → add routing layer → monitor hot partitions.
- **Practical**: Bad keys cause “hot partitions”; I validate distribution with real traffic metrics before locking the design.

### 80. What is the difference between horizontal and vertical partitioning?
- **What**: Horizontal splits rows by key/shard; vertical splits columns/features into separate tables/stores.
- **Why**: Horizontal helps scale throughput; vertical helps isolate access patterns and reduce row width.
- **Scenario**: Horizontal: shard orders by customer; Vertical: move large blobs/audit fields to separate store.
- **High-level flow**: Horizontal: shard routing; Vertical: split schema + join via service logic/projections.
- **Practical**: In microservices, vertical partitioning often maps to bounded contexts (split by ownership), not just columns.


