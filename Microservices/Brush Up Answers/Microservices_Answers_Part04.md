# Microservices Interview Answers (Part 04: Q121–Q160)

### 121. What is observability in microservices?
- **What**: Ability to understand internal system state from external signals (logs, metrics, traces).
- **Why**: Distributed systems fail in non-obvious ways; you need fast diagnosis.
- **Scenario**: A checkout timeout—was it Orders, Payments, DB, or a downstream dependency?
- **High-level flow**: Instrument services → propagate correlation IDs → centralize telemetry → define SLOs and alerts.
- **Practical**: If you can’t answer “why is latency up?” in minutes using traces + logs, your system isn’t observable.

### 122. What is the difference between monitoring and observability?
- **What**: Monitoring checks known failure modes; observability helps discover unknown/novel issues.
- **Why**: Microservices introduce emergent behavior beyond predefined dashboards.
- **Scenario**: Monitoring shows latency spike; observability (traces) reveals a new N+1 call pattern.
- **High-level flow**: Monitoring: metrics + alerts; Observability: metrics + logs + traces + context.
- **Practical**: I still monitor aggressively, but invest in tracing and structured logs to debug the “unknown unknowns”.

### 123. What are the three pillars of observability?
- **What**: Logs, metrics, and distributed traces (often plus profiles as a “fourth”).
- **Why**: Together they explain “what happened, how often, and where”.
- **Scenario**: Metric shows 500s increased; trace shows dependency; log shows exception detail.
- **High-level flow**: Emit structured logs → publish metrics → instrument spans → correlate by trace/correlation ID.
- **Practical**: The correlation is the magic: without consistent IDs, you’re stitching evidence manually.

### 124. What is distributed tracing and why is it important?
- **What**: Tracks a request across service boundaries as a trace composed of spans.
- **Why**: Pinpoints which hop caused latency/errors in a call chain.
- **Scenario**: API Gateway → Orders → Inventory → DB; tracing shows Inventory is slow.
- **High-level flow**: Create trace at entry → propagate context headers → record spans/attributes → export to backend (Jaeger/Tempo/AppInsights).
- **Practical**: In .NET, OpenTelemetry auto-instruments ASP.NET Core + HttpClient; add custom spans for business steps.

### 125. How does distributed tracing work across microservices?
- **What**: Each service creates spans and propagates trace context via headers (W3C `traceparent`).
- **Why**: Enables end-to-end visibility through async and sync calls.
- **Scenario**: A message handler continues the trace from message headers.
- **High-level flow**: Ingress creates trace → downstream uses same trace id → exporter batches and ships spans.
- **Practical**: Ensure context flows through queues too (inject/extract trace headers) or you’ll lose the async part of the story.

### 126. What is the difference between OpenTracing and OpenTelemetry?
- **What**: OpenTracing was a tracing API; OpenTelemetry is a unified standard for traces, metrics, logs, and instrumentation.
- **Why**: OTel is the modern ecosystem with broad vendor support.
- **Scenario**: Standardize on OTel SDK so you can swap backends without rewriting code.
- **High-level flow**: Add OTel SDK → configure exporters → instrument frameworks → enrich spans/metrics.
- **Practical**: I treat OTel as the default: vendor-neutral telemetry prevents lock-in and improves consistency across services.

### 127. What is correlation ID and how is it used in tracing?
- **What**: A shared identifier that ties logs/events/requests together (often the trace id or a request id).
- **Why**: Lets you jump from an alert to the exact logs/traces for that request.
- **Scenario**: Customer reports an issue; you search logs by correlation id and see the whole flow.
- **High-level flow**: Generate/accept id at edge → propagate via headers → include in logs → pass via message metadata.
- **Practical**: In ASP.NET Core, I log `TraceId` and pass `traceparent`; for business workflows I also add an “OperationId” for sagas.

### 128. How do you implement logging in microservices?
- **What**: Use structured logging with consistent fields and centralized aggregation.
- **Why**: Text logs don’t scale; you need searchable, queryable logs.
- **Scenario**: Query “all 5xx in Orders service for tenant X” quickly.
- **High-level flow**: Standard log schema → include correlation/tenant/user → ship to ELK/Splunk/AppInsights → define retention.
- **Practical**: In .NET, Serilog + enrichers (TraceId, RequestPath, UserId) is a common, effective setup.

### 129. What is structured logging and why is it preferred?
- **What**: Logs as key-value data (JSON), not free-form text.
- **Why**: Enables filtering, aggregation, and dashboards.
- **Scenario**: `{"orderId":123,"status":"Failed","errorCode":"PAY_TIMEOUT"}` is searchable and countable.
- **High-level flow**: Define fields → log with properties → enforce via templates → validate in reviews.
- **Practical**: Structured logs are the difference between “grep” and “ask questions of your production system”.

### 130. How do you aggregate logs from multiple microservices?
- **What**: Ship logs to a centralized system via agents/sidecars and index them with service/environment metadata.
- **Why**: Debugging requires seeing cross-service logs in one place.
- **Scenario**: Trace spans lead you to Orders logs and then to Payments logs in the same time window.
- **High-level flow**: Standardize format → forward (Fluent Bit/Logstash) → index → retention + access controls.
- **Practical**: Tag every log with `service`, `env`, `version`, and `traceId`; otherwise searching becomes guesswork.

### 131. What is the difference between centralized and distributed logging?
- **What**: Centralized = logs collected in one system; distributed = logs remain on nodes/services.
- **Why**: Centralized is essential for microservices; distributed is only viable for small systems.
- **Scenario**: In K8s, pods churn—local logs disappear unless centralized.
- **High-level flow**: Centralize with agents/exporters; distributed relies on node access and is operationally risky.
- **Practical**: “If it’s not centralized, it didn’t happen” is basically true in containerized production.

### 132. What are metrics in microservices monitoring?
- **What**: Numeric time-series signals (latency, error rate, throughput, saturation).
- **Why**: Metrics enable alerting and capacity planning.
- **Scenario**: Alert if p95 latency > 500ms for 5 minutes.
- **High-level flow**: Instrument → scrape/collect (Prometheus) → store → dashboard → alert rules.
- **Practical**: Metrics tell you “something is wrong”; traces/logs tell you “why”.

### 133. What are the key metrics to monitor in microservices?
- **What**: The “golden signals”: latency, traffic, errors, and saturation (plus queue lag for async).
- **Why**: They correlate strongly with user impact.
- **Scenario**: High traffic + rising latency but low CPU often points to downstream dependency.
- **High-level flow**: Define SLIs → set SLOs → alert on burn rate → add dependency metrics.
- **Practical**: I always add dependency metrics (DB latency, broker lag) because many “API issues” are actually dependency issues.

### 134. What is the difference between business metrics and technical metrics?
- **What**: Business metrics measure outcomes (orders/min); technical metrics measure system health (CPU, error rate).
- **Why**: Business impact can be high even when infra looks healthy.
- **Scenario**: Orders API is “green” but conversion drops due to a pricing logic bug.
- **High-level flow**: Track both → correlate → alert on business anomalies too.
- **Practical**: A mature system alerts on “revenue drop” or “checkout success rate” in addition to CPU and 5xx.

### 135. How do you implement health checks in microservices?
- **What**: Expose endpoints for liveness and readiness; include key dependencies.
- **Why**: Enables orchestrators and load balancers to route correctly.
- **Scenario**: Readiness fails if DB migrations pending or broker unavailable.
- **High-level flow**: Implement checks → set timeouts → wire to probes/LB → alert on flapping.
- **Practical**: Keep checks fast; don’t make health endpoints do heavy queries or they’ll become their own outage.

### 136. What is the difference between liveness and readiness checks?
- **What**: Liveness decides restart; readiness decides traffic eligibility.
- **Why**: Prevents routing to an unready service and avoids unnecessary restarts.
- **Scenario**: During warm-up, readiness false; liveness true.
- **High-level flow**: Liveness: minimal; readiness: dependencies + warm-up state.
- **Practical**: Misusing liveness for dependency checks causes restart storms; dependency checks belong in readiness.

### 137. How do you handle alerting in microservices?
- **What**: Alert on SLO burn rates and symptom metrics, route alerts to owners, and avoid noise.
- **Why**: Too many alerts leads to ignored alerts.
- **Scenario**: Alert on sustained 5xx or p95 latency; page only on user impact.
- **High-level flow**: Define SLOs → set thresholds + windows → dedupe/correlate → runbooks → postmortems.
- **Practical**: I treat alerts like code: every alert must have an owner, a runbook, and be actionable.

### 138. What is APM (Application Performance Monitoring)?
- **What**: Tools that combine metrics, traces, errors, and profiling to monitor application performance.
- **Why**: Speeds up root cause analysis and capacity planning.
- **Scenario**: AppInsights/New Relic shows slow SQL query causing API latency.
- **High-level flow**: Instrument → collect → analyze → alert → drill into traces/errors.
- **Practical**: APM is most effective when you standardize instrumentation and include deployment version tags for regressions.

### 139. How do you monitor service dependencies?
- **What**: Track dependency latency, error rates, timeouts, and saturation (DB pools, queue lag).
- **Why**: Dependencies cause many cascading failures.
- **Scenario**: DB connection pool exhaustion drives API timeouts.
- **High-level flow**: Emit dependency spans/metrics → set alerts → add synthetic checks → capacity plan.
- **Practical**: I watch “queue lag” and “DB pool usage” as early-warning signals before customers notice.

### 140. What is the difference between SLI, SLO, and SLA?
- **What**: SLI = measure; SLO = target; SLA = contractual commitment with consequences.
- **Why**: Aligns engineering effort with user expectations and business commitments.
- **Scenario**: SLI: availability; SLO: 99.9%; SLA: 99.5% with credits.
- **High-level flow**: Define SLIs → set SLOs → monitor error budget → negotiate SLA based on reality.
- **Practical**: I manage with SLOs internally; SLAs are business promises and should be conservative.

### 141. How do you implement error tracking in microservices?
- **What**: Capture exceptions with context (service, version, traceId) and group/dedupe them.
- **Why**: Enables trend detection and faster debugging.
- **Scenario**: A null ref spikes after deployment v1.2.3; you see stack traces and affected routes.
- **High-level flow**: Central error sink (Sentry/AppInsights) → enrich events → alert on spikes → link to traces/logs.
- **Practical**: I always attach correlation/trace IDs so an exception is one click away from the full distributed trace.

### 142. What is the difference between errors and exceptions in monitoring?
- **What**: Exceptions are language/runtime events; errors are user/system failures (can happen without exceptions).
- **Why**: You can return 400/500 errors without throwing, and you can throw without user impact.
- **Scenario**: Validation failures are errors but not exceptions; handled gracefully with 400.
- **High-level flow**: Track both: exception telemetry + HTTP/gRPC status codes + business failure rates.
- **Practical**: In APIs, I rely more on error-rate metrics (5xx, timeouts) than raw exception counts.

### 143. How do you track performance bottlenecks in microservices?
- **What**: Use traces, profiling, and dependency metrics to find the slowest spans and hotspots.
- **Why**: Bottlenecks can be CPU, IO, DB, network, or contention.
- **Scenario**: Trace shows 700ms in SQL; fix query/index rather than scaling pods.
- **High-level flow**: Identify slow endpoints → inspect traces → profile CPU/memory → optimize dependencies → re-test.
- **Practical**: I start with “where is the time spent” via tracing; scaling is the last resort after fixing root causes.

### 144. What is the difference between latency and throughput?
- **What**: Latency is time per request; throughput is requests per unit time.
- **Why**: Improving one can harm the other; you need both for SLOs.
- **Scenario**: Adding caching reduces latency and increases throughput; heavy logging can increase latency.
- **High-level flow**: Measure p95/p99 latency and RPS → tune concurrency → optimize IO and dependencies.
- **Practical**: I care about tail latency (p99) because that’s what users feel during partial failures.

### 145. How do you implement custom metrics in microservices?
- **What**: Emit domain and technical counters/histograms (e.g., `orders_created_total`, `payment_failures_total`).
- **Why**: Generic metrics don’t capture business health.
- **Scenario**: Alert on “checkout success rate” falling, even if CPU is fine.
- **High-level flow**: Define metrics → instrument code → export via OTel/Prometheus → dashboard + alert.
- **Practical**: In .NET, I use `System.Diagnostics.Metrics` (OTel) and ensure metrics have stable names/labels to avoid cardinality explosions.

### 146. What are the common design patterns used in microservices?
- **What**: API Gateway, BFF, circuit breaker, retry, bulkhead, timeout, saga, outbox, CQRS, event sourcing, strangler.
- **Why**: They address distributed systems failure modes and evolution.
- **Scenario**: Retry+timeout for transient faults; saga for multi-service workflows.
- **High-level flow**: Identify cross-service risks → apply patterns where needed → standardize via libraries/platform.
- **Practical**: Patterns are guardrails, not goals—use the smallest set that solves your specific failure modes.

### 147. What is the API Gateway pattern?
- **What**: A single entry point that routes/aggregates and enforces policies for external clients.
- **Why**: Simplifies clients and centralizes cross-cutting concerns.
- **Scenario**: One mobile API endpoint composes data from multiple services.
- **High-level flow**: Define routes → auth/rate limit → transforms/aggregation → forward → observe.
- **Practical**: Keep it thin; if business logic grows, move it into a BFF or domain service.

### 148. What is the circuit breaker pattern?
- **What**: Stops calls to a failing dependency for a period to prevent repeated failures.
- **Why**: Avoids cascading failure and resource exhaustion.
- **Scenario**: Payments is down; Orders fails fast instead of waiting on timeouts.
- **High-level flow**: Track failures → open → fast-fail → half-open test → close on success.
- **Practical**: In .NET, Polly is common; always combine with timeouts and meaningful fallback behavior.

### 149. How does the circuit breaker pattern prevent cascading failures?
- **What**: It reduces load on failing dependencies and frees threads/resources in callers.
- **Why**: Timeouts pile up, thread pools saturate, and everything falls over without containment.
- **Scenario**: A slow DB causes API threads to block; circuit breaker fails fast and protects the API.
- **High-level flow**: Detect failure trend → open circuit → shed load → allow recovery.
- **Practical**: Cascades usually start with latency; circuit breakers work best when paired with strict timeouts and bulkheads.

### 150. What are the states of a circuit breaker?
- **What**: Closed (normal), Open (short-circuit), Half-open (trial requests).
- **Why**: Controls transition between failure and recovery safely.
- **Scenario**: After 60s open, allow a few trial calls; close if they succeed.
- **High-level flow**: Closed→Open on threshold; Open→Half-open after delay; Half-open→Closed/Open based on results.
- **Practical**: Tune thresholds per dependency; a one-size config across all services is rarely correct.

### 151. What is the bulkhead pattern?
- **What**: Isolate resources (threads, pools) so one failing component doesn’t sink the whole service.
- **Why**: Prevents noisy neighbor effects.
- **Scenario**: Limit concurrency for slow downstream calls so they don’t consume all threads.
- **High-level flow**: Separate pools/limits → enforce concurrency caps → queue or reject excess.
- **Practical**: In .NET, use separate HttpClient handlers/policies and limit parallelism per downstream to protect the core workload.

### 152. What is the retry pattern and when do you use it?
- **What**: Re-attempt transient failures (timeouts, 503) with controlled strategy.
- **Why**: Networks are unreliable; many failures are temporary.
- **Scenario**: Retry a transient 503 from a dependency with backoff.
- **High-level flow**: Classify transient errors → retry with backoff/jitter → cap attempts → combine with timeout/circuit breaker.
- **Practical**: Never retry non-idempotent operations without idempotency keys; retries can double-charge or double-create.

### 153. What is exponential backoff in retry pattern?
- **What**: Delay increases exponentially between retries (often with jitter).
- **Why**: Reduces load during outages and avoids thundering herd.
- **Scenario**: 200ms → 500ms → 1s → 2s retries, max 3–5 tries.
- **High-level flow**: Compute delay → add jitter → retry → stop on success or max attempts.
- **Practical**: Backoff without jitter can synchronize retries across instances; jitter is essential at scale.

### 154. What is the timeout pattern?
- **What**: Hard limit on how long you wait for a dependency/request.
- **Why**: Prevents resource starvation from slow calls.
- **Scenario**: DB call times out at 2s; return controlled error instead of hanging.
- **High-level flow**: Set per-call deadline → cancel work → return fallback/error → record metric.
- **Practical**: I enforce timeouts at every hop and propagate deadlines so downstream knows the remaining budget.

### 155. What is the strangler fig pattern?
- **What**: Incrementally replace a monolith by routing parts of traffic to new services until the old part can be removed.
- **Why**: Enables gradual migration with lower risk.
- **Scenario**: Route `/catalog` to new Catalog service while rest stays in monolith.
- **High-level flow**: Add gateway/router → extract one capability → redirect traffic → decommission old module → repeat.
- **Practical**: This works best when you start with “edges” (read-heavy areas) and keep contracts stable during migration.

### 156. How do you migrate from monolith to microservices using strangler pattern?
- **What**: Peel off capabilities one by one behind a routing layer and shared auth/observability.
- **Why**: Avoids big-bang rewrites and allows learning/iteration.
- **Scenario**: First extract Auth, then Catalog, then Orders; keep the monolith as a “legacy service” temporarily.
- **High-level flow**: Identify bounded context → create new service + DB → route endpoint → sync data via events → retire monolith feature.
- **Practical**: I prioritize extraction where the domain is clear and the ROI is high (bottlenecks, frequent changes, scaling pain).

### 157. What is the database per service pattern?
- **What**: Each service owns its data store and is the only writer.
- **Why**: Prevents schema coupling and enables independent evolution.
- **Scenario**: Orders modifies schema without coordinating with Reporting; reporting consumes events instead.
- **High-level flow**: Separate schema/DB → service-only credentials → integrate via events/APIs → per-service migrations.
- **Practical**: Even if physically shared infrastructure exists, logical ownership boundaries must be enforced via permissions and process.

### 158. What is the shared data pattern and why is it an anti-pattern?
- **What**: Sharing tables/entities directly across services is an anti-pattern (shared database/ORM models).
- **Why**: Creates tight coupling and breaks independent deployability.
- **Scenario**: Two services share an EF Core `DbContext`; a migration breaks both.
- **High-level flow**: Assign ownership → replace shared access with APIs/events → build read projections.
- **Practical**: Share contracts (OpenAPI/Proto), not databases; data duplication via events is normal and healthy.

### 159. What is the saga pattern?
- **What**: A distributed workflow with local transactions and compensations.
- **Why**: Achieves business consistency without distributed transactions.
- **Scenario**: Checkout saga coordinates inventory, payment, and shipping.
- **High-level flow**: Start → step → event/command → next step → compensate on failure → complete.
- **Practical**: Keep saga steps idempotent and persisted; transient failures are expected, not exceptional.

### 160. What are the different types of saga patterns?
- **What**: Orchestrated sagas and choreographed sagas.
- **Why**: Trade-off between centralized control vs decentralized coupling.
- **Scenario**: Orchestrator for complex “order lifecycle”; choreography for simpler fan-out processes.
- **High-level flow**: Orchestrated: coordinator commands steps; Choreographed: services emit/consume events.
- **Practical**: For interview answers: I emphasize “start with orchestrated for clarity, evolve to choreography as domains mature.”


