# Microservices Interview Answers (Part 05: Q161–Q200)

### 161. What is the event sourcing pattern?
- **What**: Persist state as an append-only stream of events; rebuild state by replaying.
- **Why**: Auditability, replay, and temporal debugging.
- **Scenario**: Financial ledger needs a complete history of changes.
- **High-level flow**: Validate command → append events → publish events → update projections/snapshots.
- **Practical**: Use event sourcing when history matters; otherwise CRUD + outbox is simpler and often sufficient.

### 162. What is the CQRS pattern?
- **What**: Separate write model (commands) from read model (queries), often with different stores.
- **Why**: Lets you optimize reads and writes independently.
- **Scenario**: Orders writes to SQL; read model served from a denormalized projection for UI.
- **High-level flow**: Command → persist → emit event → projection updates → queries hit projection.
- **Practical**: CQRS reduces “read-side joins” across services by building local read models from events.

### 163. What is the aggregator pattern?
- **What**: A component aggregates data from multiple services and returns a composed response.
- **Why**: Reduces client chattiness and improves UX latency.
- **Scenario**: “Order details” response needs Orders + Payments + Shipping summaries.
- **High-level flow**: Receive request → call downstreams (often parallel) → combine/transform → return.
- **Practical**: I implement this as a BFF or gateway composition layer; handle partial failures with graceful degradation.

### 164. What is the proxy pattern in microservices?
- **What**: A proxy sits between client and service to add cross-cutting behavior (routing, auth, caching).
- **Why**: Centralizes policies without changing services.
- **Scenario**: Reverse proxy terminates TLS and enforces IP allowlists.
- **High-level flow**: Client → proxy → policy checks/transforms → backend → response.
- **Practical**: Envoy/NGINX/YARP can be proxies; don’t hide business logic behind proxies (keep them infrastructure-focused).

### 165. What is the branch pattern?
- **What**: A request is routed to different “branches” of processing based on rules (A/B, tenant, version).
- **Why**: Supports experimentation and gradual rollout.
- **Scenario**: Route premium tenants to a high-SLA compute path.
- **High-level flow**: Evaluate rule → choose branch → execute branch pipeline → unify response shape.
- **Practical**: Implement branching with feature flags and consistent telemetry so you can compare outcomes safely.

### 166. What is the chained microservices pattern?
- **What**: Service A calls B calls C in sequence to fulfill a request.
- **Why**: Sometimes unavoidable, but increases latency and failure probability.
- **Scenario**: Gateway → Orders → Pricing → Promotions for checkout totals.
- **High-level flow**: Sequential calls with timeouts → error propagation → fallback strategy.
- **Practical**: Keep chains short; prefer aggregation at the edge or async events to avoid deep call stacks.

### 167. What is the sidecar pattern?
- **What**: Deploy a helper container/process alongside a service instance to handle cross-cutting concerns.
- **Why**: Reuse capabilities without baking them into app code.
- **Scenario**: Sidecar proxy (Envoy) handles mTLS and retries.
- **High-level flow**: Service + sidecar share network/volume → traffic goes through sidecar → telemetry/policy applied.
- **Practical**: Sidecars are powerful but add resource overhead and operational complexity; standardize them via platform templates.

### 168. What is the ambassador pattern?
- **What**: A specialized sidecar that represents an external service locally (proxy/adapter).
- **Why**: Simplifies app code and centralizes connection logic.
- **Scenario**: Local ambassador handles TLS and retries to a third-party payment provider.
- **High-level flow**: App calls local endpoint → ambassador forwards to external dependency → handles auth/limits.
- **Practical**: Use it when many services share the same external dependency patterns (timeouts, certs, auth).

### 169. What is the adapter pattern in microservices?
- **What**: Wrap/translate one interface to another to integrate systems or shield internal models.
- **Why**: Prevents leaking external/legacy contracts into your domain.
- **Scenario**: Adapter converts legacy SOAP responses to modern REST DTOs.
- **High-level flow**: Receive request → map to external contract → call → map back → return.
- **Practical**: In .NET, keep adapters at the boundary (infrastructure layer) so the domain stays clean and testable.

### 170. What is the backends for frontends (BFF) pattern?
- **What**: Create a backend tailored for each client (web, mobile) with client-specific aggregation and shaping.
- **Why**: Avoids one “generic API” becoming too chatty or too opinionated.
- **Scenario**: Mobile BFF returns compact payloads; Web BFF returns richer data for desktop.
- **High-level flow**: Client → BFF → call domain services → aggregate/transform → return.
- **Practical**: BFFs improve UX and reduce client complexity; keep BFFs thin and rely on domain services for business rules.

### 171. What are the main challenges in microservices architecture?
- **What**: Distributed complexity: networking, consistency, observability, deployments, and org alignment.
- **Why**: You trade monolith simplicity for independent evolution at scale.
- **Scenario**: A single user request spans 8 services; diagnosing issues needs tracing and strong practices.
- **High-level flow**: Build platform baseline → standardize patterns → invest in automation and telemetry.
- **Practical**: Microservices succeed when the organization invests in engineering productivity (pipelines, templates, SRE practices).

### 172. How do you handle distributed transactions in microservices?
- **What**: Use sagas/outbox and compensations, not 2PC.
- **Why**: Distributed ACID reduces availability and increases operational risk.
- **Scenario**: Order created, payment captured, inventory reserved with compensation paths.
- **High-level flow**: Local tx → publish events → orchestrate steps → compensate on failure → reconcile.
- **Practical**: Define “source of truth” per business entity and make every step idempotent.

### 173. What is the problem with distributed transactions in microservices?
- **What**: They require coordination across services and are fragile under network partitions/timeouts.
- **Why**: Failure modes multiply and lock contention increases.
- **Scenario**: One service slow causes global transaction timeouts and resource lockups.
- **High-level flow**: Coordinator waits on participants → partial failures block → retries amplify load.
- **Practical**: In real production, “rare partitions” happen weekly; designs must tolerate them gracefully.

### 174. How do you handle network latency in microservices?
- **What**: Reduce hops, use caching, apply timeouts/retries, and choose efficient protocols (gRPC) where appropriate.
- **Why**: Over-network calls are orders of magnitude slower than in-process calls.
- **Scenario**: UI call chain becomes 6 hops; p95 latency explodes.
- **High-level flow**: Measure with tracing → eliminate chatty calls → add caching/BFF → tune timeouts and concurrency.
- **Practical**: I start with tracing to find the slowest hops, then redesign boundaries or read models to remove runtime fan-out.

### 175. How do you handle partial failures in microservices?
- **What**: Use timeouts, circuit breakers, bulkheads, fallbacks, and graceful degradation.
- **Why**: Some dependencies will be down while others are up.
- **Scenario**: Recommendations service down; product page still loads without recommendations.
- **High-level flow**: Detect failure → fail fast or fallback → isolate resources → recover → alert.
- **Practical**: Design UX for degraded modes; “everything must work or nothing works” is a fragile assumption.

### 176. What is cascading failure and how do you prevent it?
- **What**: A failure in one service causes timeouts/retries that overwhelm upstream services.
- **Why**: Latency and retries can amplify load dramatically.
- **Scenario**: DB slows → APIs time out → retries spike → thread pools saturate → full outage.
- **High-level flow**: Timeouts → circuit breakers → bulkheads → backpressure/queues → shed load.
- **Practical**: The fastest fix is usually strict timeouts + limited retries; unlimited retries are a common outage root cause.

### 177. How do you handle service dependencies?
- **What**: Minimize synchronous dependencies; make calls resilient; use async events for cross-domain communication.
- **Why**: Dependencies reduce availability and complicate releases.
- **Scenario**: Orders depends on Inventory; use reservation workflow instead of real-time “check then write” calls.
- **High-level flow**: Map dependency graph → reduce fan-out → cache/read models → apply resilience patterns.
- **Practical**: I track “dependency budgets” (max hops, max latency) and enforce them with SLAs and design reviews.

### 178. What happens when a dependent service is down?
- **What**: Calls fail or time out; upstream must handle gracefully with fallback, queueing, or fast failure.
- **Why**: Otherwise you get cascading failures and poor user experience.
- **Scenario**: Shipping down: accept order but mark shipment creation as pending, retry asynchronously.
- **High-level flow**: Detect via timeouts → fallback or enqueue → alert → retry with backoff → reconcile.
- **Practical**: The key is defining business behavior: “can we accept the request and finish later?”—often yes with async processing.

### 179. How do you handle data consistency across services?
- **What**: Eventual consistency with sagas, outbox/inbox, and projections.
- **Why**: No shared DB constraints; you must build correctness into workflows.
- **Scenario**: Billing reads order totals from a projection maintained via `OrderPlaced` events.
- **High-level flow**: Local invariants → publish events → consumers update → compensations → audits.
- **Practical**: I track “consistency lag” (time from event to projection) and alert when it grows beyond business tolerance.

### 180. What is the CAP theorem and how does it apply to microservices?
- **What**: In a partition, you must choose consistency or availability (CAP: Consistency, Availability, Partition tolerance).
- **Why**: Partitions are inevitable in distributed systems.
- **Scenario**: During a partition, do you reject writes (favor consistency) or accept and reconcile later (favor availability)?
- **High-level flow**: Identify invariants → choose CP or AP per operation → design fallbacks and reconciliation.
- **Practical**: Most microservices systems accept AP for many reads and some writes, but keep CP within critical domains (payments) via single-writer rules.

### 181. How do you choose between consistency and availability?
- **What**: Based on business risk: correctness vs uptime per operation.
- **Why**: Different endpoints have different failure costs.
- **Scenario**: Payment capture favors consistency; product view favors availability.
- **High-level flow**: Classify operations → define SLOs and invariants → design data model and workflows accordingly.
- **Practical**: I document “consistency requirements” per domain early; it prevents endless debates during incident-driven redesigns.

### 182. What is the difference between strong and eventual consistency?
- **What**: Strong = all reads see latest write; eventual = reads may be stale but converge over time.
- **Why**: Strong costs availability/latency; eventual improves resilience and scale.
- **Scenario**: Strong within Orders DB; eventual for reporting projections.
- **High-level flow**: Strong: synchronous commit and read; Eventual: async events + projections.
- **Practical**: I keep strong consistency within a service boundary and use eventual consistency across boundaries.

### 183. How do you handle service versioning?
- **What**: Prefer additive changes; manage breaking changes with parallel versions and deprecation.
- **Why**: Independent deployment means mixed versions will exist.
- **Scenario**: Add new field; keep old behavior; later remove after consumers migrate.
- **High-level flow**: Contract-first → additive changes → observe usage → deprecate → remove.
- **Practical**: Versioning isn’t just URLs—schemas, events, and DB migrations must all be backward compatible during rollout.

### 184. What is backward compatibility and why is it important?
- **What**: New versions work with old clients/consumers (and often vice versa for a period).
- **Why**: Prevents coordinated “big-bang” upgrades.
- **Scenario**: Producer adds optional JSON field; old consumers ignore it safely.
- **High-level flow**: Add fields (optional) → don’t rename/remove → default values → test compatibility.
- **Practical**: Backward compatibility is enforced by contract tests and “compatibility rules” in code reviews.

### 185. How do you handle breaking changes in microservices?
- **What**: Introduce v2 endpoints/events, run in parallel, migrate consumers, then retire v1.
- **Why**: Breaking changes cause outages if pushed abruptly.
- **Scenario**: Change response shape; deploy `/v2` and migrate clients gradually.
- **High-level flow**: Design v2 → dual-run → migrate → monitor → deprecate and remove.
- **Practical**: For events, I prefer versioned event types or schema evolution rules with a registry.

### 186. What is service coupling and how do you avoid it?
- **What**: Coupling is when services must change together due to shared data/logic/contracts.
- **Why**: Coupling kills independent deployment and team autonomy.
- **Scenario**: Shared DB schema forces synchronized releases.
- **High-level flow**: Own data per service → use stable contracts → async events → avoid shared libraries for domain logic.
- **Practical**: I measure coupling by “how many repos/pipelines must change for one feature”; if it’s high, boundaries need work.

### 187. How do you handle shared libraries in microservices?
- **What**: Share only cross-cutting utilities (logging, auth helpers), not domain models or DB entities.
- **Why**: Domain sharing reintroduces monolith coupling.
- **Scenario**: Shared NuGet for common telemetry; not for “OrderEntity”.
- **High-level flow**: Create internal packages → semantic version → keep them small → avoid breaking changes.
- **Practical**: If a shared library update forces many services to upgrade immediately, that library is too coupled.

### 188. What is the problem with shared databases in microservices?
- **What**: They create hidden dependencies, lock contention, and release coupling.
- **Why**: Any schema change becomes a coordinated deployment problem.
- **Scenario**: One service adds an index; another service’s query plan changes and performance tanks.
- **High-level flow**: Identify shared DB → assign ownership → expose APIs/events → migrate consumers → restrict access.
- **Practical**: Shared DB often starts as “quick win” and becomes the hardest thing to unwind later.

### 189. How do you handle testing in microservices?
- **What**: Use a layered strategy: unit, component, contract, integration, and limited end-to-end tests.
- **Why**: Full E2E is expensive and flaky at scale.
- **Scenario**: Provider contract tests ensure changes don’t break consumers.
- **High-level flow**: Unit tests → contract tests → integration tests with real deps → smoke tests in staging.
- **Practical**: The biggest ROI is contract tests + component tests; they catch integration breakages early with low flakiness.

### 190. What is the difference between unit testing and integration testing in microservices?
- **What**: Unit tests isolate code with mocks; integration tests validate real dependencies (DB, broker, HTTP).
- **Why**: You need both: correctness of logic and correctness of integration.
- **Scenario**: Unit test domain rules; integration test EF Core mapping and SQL constraints.
- **High-level flow**: Unit: fast and many; Integration: fewer, slower, run in pipeline with containers.
- **Practical**: In .NET, Testcontainers makes integration tests realistic without massive environment setup.

### 191. How do you handle end-to-end testing in microservices?
- **What**: Keep E2E minimal and focused on critical user journeys; prefer contracts for broad coverage.
- **Why**: E2E is slow and brittle due to many moving parts.
- **Scenario**: “Place order” and “refund order” as top E2E flows.
- **High-level flow**: Seed data → run journey → assert outcomes → collect traces/logs → cleanup.
- **Practical**: I run E2E against a production-like environment and treat failures as signal to improve test isolation/observability.

### 192. What is contract testing and why is it important?
- **What**: Tests that validate API/event contracts between consumers and providers.
- **Why**: Prevents breaking changes without relying on slow E2E tests.
- **Scenario**: Consumer defines expectations; provider verifies it can satisfy them.
- **High-level flow**: Define contract → generate tests → provider verification in CI → publish contract versions.
- **Practical**: Contract tests are the closest thing to “compile-time safety” across service boundaries.

### 193. How do you handle debugging in distributed systems?
- **What**: Use tracing + correlation IDs + structured logs, and reproduce via replayable events/test environments.
- **Why**: You can’t “attach debugger” across 10 services in prod.
- **Scenario**: Find a failing request by traceId, then inspect spans and logs across services.
- **High-level flow**: Start with trace → narrow to service/span → inspect logs → verify dependency metrics → replicate in staging.
- **Practical**: I also rely on “production-like” test data and feature flags to reproduce issues safely.

### 194. What is the problem with local development in microservices?
- **What**: Running many services and dependencies locally is heavy and inconsistent.
- **Why**: Developers waste time on environment setup instead of features.
- **Scenario**: 12 services + Kafka + Redis + SQL is hard to run on a laptop.
- **High-level flow**: Use Docker Compose for small subsets → use remote dev/staging environments → mock via contracts.
- **Practical**: My preference is “develop with 1–2 local services + real shared dev cluster deps”, plus contract mocks for everything else.

### 195. How do you handle configuration management in microservices?
- **What**: Centralize configuration per environment, keep it versioned, and separate config from secrets.
- **Why**: Many services multiply misconfiguration risk.
- **Scenario**: Feature flags and endpoints come from Azure App Configuration; secrets from Key Vault.
- **High-level flow**: Config source → environment overlays → rollout safely → audit changes.
- **Practical**: In .NET, `IOptions` binds config; I enforce “no config in code” and ensure configs are validated at startup.

### 196. What is the difference between configuration and secrets?
- **What**: Configuration is non-sensitive settings; secrets are sensitive credentials/keys.
- **Why**: Secrets need stronger access controls, rotation, and auditing.
- **Scenario**: “MaxRetries=3” is config; DB password is a secret.
- **High-level flow**: Config from config store; secrets from vault/managed identity; never log secrets.
- **Practical**: I treat connection strings as secrets (because they contain credentials) unless using integrated identity.

### 197. How do you handle feature flags in microservices?
- **What**: Use centralized flag management with consistent evaluation and auditing.
- **Why**: Flags enable safe rollout and quick rollback without redeploy.
- **Scenario**: Turn off “new checkout” instantly if error rate spikes.
- **High-level flow**: Define flag → wrap behavior → target tenants/users → ramp → remove after stable.
- **Practical**: Flags are technical debt—set an expiry date and clean them up or they become permanent complexity.

### 198. What is the problem with service discovery in microservices?
- **What**: Incorrect health, stale caches, and split-brain issues can route traffic to bad instances.
- **Why**: Discovery is foundational; failures ripple everywhere.
- **Scenario**: Registry says instance is healthy but it’s stuck; traffic keeps flowing and timeouts spike.
- **High-level flow**: Use meaningful health checks → keep TTL short → implement retries/backoff → monitor discovery latency/errors.
- **Practical**: If discovery is flaky, developers add hardcoded endpoints as a “fix” and the system becomes inconsistent—so invest in discovery reliability early.

### 199. How do you handle service mesh complexity?
- **What**: Treat mesh as a platform product with guardrails, templates, and limited supported features initially.
- **Why**: Mesh adds layers (sidecars, policies, control plane) that can confuse teams.
- **Scenario**: Teams struggle with routing rules; platform team provides standard patterns and validation.
- **High-level flow**: Start with mTLS + telemetry → add traffic splitting → add authz policies → automate policy linting.
- **Practical**: Don’t enable every mesh feature on day one; adopt incrementally and document “golden paths”.

### 200. What is the problem with too many microservices?
- **What**: Cognitive load, operational overhead, and cross-service coordination increase significantly.
- **Why**: More services means more deployments, contracts, and failure points.
- **Scenario**: 200 tiny services owned by 5 engineers becomes unmanageable.
- **High-level flow**: Re-evaluate boundaries → merge where cohesion is low → use modular monolith or “macro services” where appropriate.
- **Practical**: A service should be justified by independent change/scaling/team ownership—not by “microservices for everything”.


