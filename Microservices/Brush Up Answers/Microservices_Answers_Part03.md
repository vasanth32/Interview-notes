# Microservices Interview Answers (Part 03: Q81–Q120)

### 81. What are the different deployment strategies for microservices?
- **What**: Blue-green, canary, rolling, recreate, and feature-flag driven deployments.
- **Why**: You need safe, incremental rollout with fast rollback per service.
- **Scenario**: Deploy Orders v2 to 5% traffic first to validate error rates.
- **High-level flow**: Build artifact → deploy new version → shift traffic → monitor SLOs → rollback/rollforward.
- **Practical**: In K8s, rolling + canary (via ingress/service mesh) plus feature flags is a very common combination.

### 82. What is blue-green deployment?
- **What**: Two identical environments: blue (current) and green (new); switch traffic atomically.
- **Why**: Enables near-instant rollback by switching back.
- **Scenario**: Release a risky auth change; flip traffic when smoke tests pass.
- **High-level flow**: Deploy to green → run tests → switch routing → monitor → keep blue for rollback window.
- **Practical**: Requires duplicated capacity; I use it for high-risk changes or when rollback speed matters more than cost.

### 83. What is canary deployment?
- **What**: Roll out to a small subset of users/traffic, then gradually increase.
- **Why**: Detects issues early with limited blast radius.
- **Scenario**: 1% → 10% → 50% → 100% based on error rate and latency.
- **High-level flow**: Deploy new version → route small traffic slice → evaluate metrics → increase or rollback.
- **Practical**: Works best with strong observability (dashboards + alerts) and automatic rollback rules.

### 84. What is rolling deployment?
- **What**: Replace instances gradually (old→new) while keeping service available.
- **Why**: Simple and cost-effective; no duplicate environment needed.
- **Scenario**: K8s Deployment updates pods one batch at a time.
- **High-level flow**: Start new pods → readiness checks → shift traffic → terminate old pods → complete rollout.
- **Practical**: Ensure backward compatibility during rollout because old and new versions run side-by-side briefly.

### 85. What is the difference between blue-green and canary deployment?
- **What**: Blue-green flips traffic between environments; canary gradually shifts traffic percentages to a new version.
- **Why**: Blue-green optimizes rollback speed; canary optimizes risk detection.
- **Scenario**: Canary for performance-sensitive services; blue-green for schema-sensitive releases.
- **High-level flow**: Blue-green: deploy then switch; Canary: deploy then increment traffic.
- **Practical**: Many teams do “canary within blue-green”: green starts at 1% before full cutover.

### 86. How do you handle database migrations during deployment?
- **What**: Use backward-compatible migrations with expand/contract and avoid breaking schema changes during rolling updates.
- **Why**: Old and new app versions run concurrently; schema must support both.
- **Scenario**: Add nullable column, dual-write, backfill, then switch reads.
- **High-level flow**: Expand schema → deploy app (dual-read/write) → backfill → cutover → contract (remove old).
- **Practical**: In EF Core, I separate “safe expand” migrations from “cleanup” migrations and gate cleanup behind deployment completion.

### 87. What is containerization and how does it help microservices?
- **What**: Package app + dependencies into an image that runs consistently across environments.
- **Why**: Improves portability, isolation, and repeatable deployments.
- **Scenario**: Same ASP.NET Core image runs on dev, staging, and K8s prod.
- **High-level flow**: Build image → push to registry → deploy via orchestrator → scale/rollout.
- **Practical**: Containers make “works on my machine” rarer; but you still need good configs, secrets, and observability.

### 88. What is the difference between Docker and Kubernetes?
- **What**: Docker builds/runs containers; Kubernetes orchestrates containers across a cluster (scheduling, scaling, self-healing).
- **Why**: Docker solves packaging; K8s solves running at scale reliably.
- **Scenario**: Docker for local dev; K8s for production with autoscaling and rollouts.
- **High-level flow**: Docker image → K8s Deployment/Service → ingress → autoscaling → monitoring.
- **Practical**: Most orgs use both: Docker to build; Kubernetes to operate.

### 89. What is Kubernetes and why is it used for microservices?
- **What**: K8s is a container orchestrator providing scheduling, discovery, scaling, rollouts, and self-healing.
- **Why**: Microservices produce many deployable units; you need automation to manage them.
- **Scenario**: Auto-restart crashed pods and scale APIs during peak traffic.
- **High-level flow**: Define deployments/services → apply manifests → K8s schedules pods → health checks → autoscale.
- **Practical**: It standardizes production operations; the learning curve is real, so platform enablement matters.

### 90. What are Kubernetes pods, services, and deployments?
- **What**: Pod = runnable unit; Deployment = desired state + rolling updates; Service = stable endpoint + load balancing to pods.
- **Why**: Separates lifecycle management (Deployment) from networking (Service).
- **Scenario**: Orders Deployment manages pods; Orders Service provides stable DNS and LB.
- **High-level flow**: Deployment creates pods → readiness gates traffic → Service routes → HPA scales replicas.
- **Practical**: If your app is stateful, you’ll add StatefulSets and persistent volumes; stateless APIs typically use Deployments.

### 91. How do you scale microservices horizontally?
- **What**: Increase instance count (pods/containers) behind a load balancer.
- **Why**: Improves throughput and resilience.
- **Scenario**: Scale API replicas based on CPU or RPS.
- **High-level flow**: Make service stateless → externalize state → add autoscaling → validate with load tests.
- **Practical**: .NET APIs scale well horizontally when you avoid in-memory session state and use distributed cache for shared state.

### 92. What is auto-scaling and how does it work?
- **What**: Automatically adjusts replica count based on metrics (CPU, memory, custom metrics).
- **Why**: Matches capacity to demand without manual intervention.
- **Scenario**: HPA scales from 3→15 replicas during a sale.
- **High-level flow**: Collect metrics → evaluate rules → scale replicas → stabilize with cooldowns.
- **Practical**: Autoscaling only works if your bottleneck isn’t the database; always test the full system, not just the API tier.

### 93. What are the different scaling strategies?
- **What**: Horizontal/vertical scaling, reactive/proactive autoscaling, and scaling by queue depth or latency.
- **Why**: Different workloads require different triggers and limits.
- **Scenario**: Worker services scale on queue backlog; APIs scale on latency/RPS.
- **High-level flow**: Pick SLO → pick metric trigger → set min/max → add warm-up/cooldown → validate.
- **Practical**: I like queue-depth scaling for async processing because it directly measures “work waiting”.

### 94. How do you handle stateful services in microservices?
- **What**: Prefer stateless services; for stateful, use managed state stores or K8s StatefulSets with persistent volumes.
- **Why**: Stateful scaling and failover are harder.
- **Scenario**: Stateful stream processing may need partition ownership and durable checkpoints.
- **High-level flow**: Externalize state (DB/cache) → design for failover → use leader election if needed → back up and test recovery.
- **Practical**: Most business microservices can remain stateless and store state in SQL/Redis; that simplifies autoscaling and rollouts.

### 95. What is the difference between stateless and stateful services?
- **What**: Stateless keeps no session data in instance memory; stateful keeps important runtime state locally.
- **Why**: Stateless scales and recovers easily; stateful requires sticky routing or replication.
- **Scenario**: Stateless API vs in-memory session cart service (stateful, risky).
- **High-level flow**: Stateless: scale out freely; Stateful: manage persistence, replication, and failover.
- **Practical**: For .NET web APIs, I avoid in-memory sessions and store sessions/carts in Redis or DB.

### 96. How do you implement health checks in microservices?
- **What**: Expose endpoints that report service health and dependencies (DB, broker) status.
- **Why**: Orchestrators use health to route traffic and restart unhealthy instances.
- **Scenario**: `/health/ready` fails if DB connection is down; `/health/live` stays true if process is alive.
- **High-level flow**: Implement liveness + readiness → check key deps → integrate with K8s probes → alert on failures.
- **Practical**: In ASP.NET Core, `Microsoft.Extensions.Diagnostics.HealthChecks` is standard; keep checks fast and meaningful.

### 97. What is the difference between liveness and readiness probes?
- **What**: Liveness = should K8s restart the container; Readiness = should it receive traffic.
- **Why**: Prevents killing a healthy-but-busy app and prevents routing to an unready app.
- **Scenario**: App starting up: liveness OK, readiness false until caches warmed/migrations done.
- **High-level flow**: Liveness checks process health; Readiness checks ability to serve requests.
- **Practical**: Many outages come from misconfigured probes—keep readiness strict, liveness simple.

### 98. How do you handle service dependencies during deployment?
- **What**: Use backward-compatible contracts, feature flags, and progressive delivery; avoid tight runtime coupling.
- **Why**: Independent deployment is the goal; dependencies shouldn’t force lockstep releases.
- **Scenario**: Deploy Orders v2 that can talk to Payments v1 via additive contract changes.
- **High-level flow**: Contract-first → additive changes → deploy producer first → deploy consumers → deprecate later.
- **Practical**: I track dependency graphs and ensure “old works with new” during rollout windows.

### 99. What is feature flags and how do you use them in microservices?
- **What**: Runtime toggles that enable/disable features without redeploying.
- **Why**: Safer releases and faster rollback of business logic changes.
- **Scenario**: Enable new pricing algorithm for 10% of users.
- **High-level flow**: Add flag → wrap behavior → configure per env/tenant → ramp up → remove flag later.
- **Practical**: Use a shared feature management service (LaunchDarkly/Azure App Config) and ensure flags are audited and cleaned up.

### 100. How do you implement zero-downtime deployment?
- **What**: Deploy without interrupting availability using rolling/canary + readiness checks + backward-compatible changes.
- **Why**: Users shouldn’t feel deployments.
- **Scenario**: Rolling update with min available replicas and graceful shutdown.
- **High-level flow**: Add readiness gates → drain connections → deploy new pods → keep old pods serving until new are ready.
- **Practical**: In .NET, implement graceful shutdown (`IHostApplicationLifetime`), set timeouts, and avoid long blocking startup.

### 101. What are the security challenges in microservices architecture?
- **What**: More network surface area, more identities, more secrets, and more chances for misconfiguration.
- **Why**: Each service boundary is an attack boundary.
- **Scenario**: A compromised service credential allows lateral movement if mTLS and least privilege aren’t enforced.
- **High-level flow**: Strong identity → mTLS → least privilege → centralized audit → secure SDLC.
- **Practical**: Treat internal traffic as untrusted (zero trust); assume attackers can get inside your network.

### 102. How do you implement authentication in microservices?
- **What**: Central identity provider issues tokens; services validate tokens and apply authorization rules.
- **Why**: Avoids each service being its own identity store.
- **Scenario**: Azure AD/IdentityServer issues JWT; gateway and services validate issuer/audience.
- **High-level flow**: User authenticates → token issued → gateway validates → services validate + authorize → propagate claims.
- **Practical**: I keep authentication centralized, but authorization decisions remain close to the data and domain rules.

### 103. What is the difference between authentication and authorization?
- **What**: Authentication = who you are; Authorization = what you can do.
- **Why**: Mixing them leads to security bugs and unclear policies.
- **Scenario**: User is authenticated via JWT, but only “Admin” role can delete users.
- **High-level flow**: Authenticate (token) → map identity/claims → authorize (policy/roles/scopes) → execute.
- **Practical**: In .NET, `AddAuthentication()` validates identity; `AddAuthorization()` enforces policies at endpoints/handlers.

### 104. What is OAuth 2.0 and how is it used in microservices?
- **What**: OAuth2 is an authorization framework for obtaining access tokens to call APIs.
- **Why**: Enables delegated access and standardized token flows.
- **Scenario**: SPA uses Authorization Code + PKCE to call APIs via gateway.
- **High-level flow**: Client requests auth → receives access token → calls API with Bearer token → API validates.
- **Practical**: OAuth2 defines flows and scopes; OpenID Connect adds authentication (ID token) on top.

### 105. What is JWT (JSON Web Token) and how does it work?
- **What**: A signed token containing claims; services validate signature and claims without calling the issuer every time.
- **Why**: Scales well for distributed validation.
- **Scenario**: JWT includes `sub`, roles/scopes, expiry; gateway validates and forwards.
- **High-level flow**: Issue JWT → client sends Bearer token → API validates signature/exp/aud/iss → authorize.
- **Practical**: Keep JWT small, short-lived, and never put secrets in it; use refresh tokens where needed.

### 106. How do you secure inter-service communication?
- **What**: Use mTLS, service identity, authorization policies, and network segmentation.
- **Why**: Prevents spoofing and lateral movement.
- **Scenario**: Only Orders service identity can call Payments “capture” endpoint.
- **High-level flow**: Establish service identity → enforce mTLS → authorize service-to-service calls → log/audit.
- **Practical**: Service mesh makes mTLS + policy easier, but you still need app-level authz for sensitive operations.

### 107. What is mTLS (mutual TLS) and why is it important?
- **What**: Both client and server present certificates; each verifies the other.
- **Why**: Strong service identity and encrypted traffic by default.
- **Scenario**: A rogue pod cannot call a service without a valid cert.
- **High-level flow**: Issue certs (CA) → rotate automatically → enforce mTLS policies → monitor failures.
- **Practical**: In production, automate cert lifecycle (mesh or SPIFFE/SPIRE) or it becomes operationally painful.

### 108. How do you implement API security in microservices?
- **What**: Secure endpoints with authn/authz, input validation, rate limiting, and secure defaults.
- **Why**: APIs are your primary attack surface.
- **Scenario**: Prevent injection, enforce scopes, block abusive clients, and log security events.
- **High-level flow**: Gateway policies → service authorization → validation → output encoding → audit logs.
- **Practical**: In ASP.NET Core, combine endpoint authorization policies, validation (FluentValidation), and WAF/rate limits at the edge.

### 109. What is the difference between API key and OAuth token?
- **What**: API key is a static shared secret; OAuth token is a time-bound, scoped token issued by an IdP.
- **Why**: OAuth provides better rotation, scoping, and auditing; API keys are simpler but riskier.
- **Scenario**: Internal batch job uses client credentials flow (OAuth) instead of embedding an API key.
- **High-level flow**: API key: send key → validate; OAuth: obtain token → validate signature/claims.
- **Practical**: I use API keys for simple partner integrations only when OAuth isn’t feasible, and I rotate + scope them aggressively.

### 110. How do you handle secrets management in microservices?
- **What**: Store secrets in a vault/managed secret store; inject at runtime, never in code or images.
- **Why**: Prevents leakage and enables rotation/auditing.
- **Scenario**: DB passwords and signing keys come from Azure Key Vault/AWS Secrets Manager/K8s secrets (prefer sealed/external).
- **High-level flow**: Central store → least-privilege access → runtime injection → rotation → audit.
- **Practical**: Prefer managed identities/workload identity to reduce the number of long-lived secrets entirely.

### 111. What are the best practices for securing microservices?
- **What**: Zero trust, least privilege, mTLS, secure supply chain, and continuous monitoring.
- **Why**: Many small services multiply risk.
- **Scenario**: A compromised container image should be blocked by scanning + policy.
- **High-level flow**: Threat model → secure CI/CD (SAST/DAST/SBOM) → runtime policies → logging/audit → incident response.
- **Practical**: Consistency matters: a shared platform baseline (templates, policies) prevents “one insecure service” from sinking the fleet.

### 112. How do you implement role-based access control (RBAC)?
- **What**: Map users/services to roles; enforce role-based policies at gateways and services.
- **Why**: Simplifies authorization for common patterns.
- **Scenario**: Only `SupportAgent` can view PII; only `Admin` can change pricing rules.
- **High-level flow**: Define roles → assign via IdP/groups → include claims → enforce policies in APIs.
- **Practical**: In .NET, use policy-based authorization; for complex domains, complement RBAC with ABAC (attribute-based) checks.

### 113. What is the principle of least privilege in microservices?
- **What**: Grant the minimum permissions needed for each identity (user/service).
- **Why**: Limits blast radius if credentials are compromised.
- **Scenario**: Reporting service can read projections but cannot call Payments capture APIs.
- **High-level flow**: Define roles/scopes → service accounts per service → restrict network + data permissions → audit.
- **Practical**: I implement least privilege at multiple layers: IAM, network policies, DB grants, and app-level authorization.

### 114. How do you prevent API abuse in microservices?
- **What**: Rate limiting, quotas, auth, WAF rules, bot detection, and anomaly monitoring.
- **Why**: Abuse can be accidental (buggy client) or malicious (DDoS, scraping).
- **Scenario**: A client loops and hits `/search` 10k times/min; gateway throttles and alerts.
- **High-level flow**: Identify clients → enforce limits → detect anomalies → block/ban → monitor.
- **Practical**: Protect the expensive endpoints first (search, exports); add caching and pagination to reduce amplification.

### 115. What is rate limiting and how do you implement it?
- **What**: Enforce maximum request rate per key over a time window.
- **Why**: Prevents overload and enforces fair usage.
- **Scenario**: 100 req/min per API key with burst allowance.
- **High-level flow**: Choose algorithm (token bucket/leaky bucket/fixed window) → store counters (Redis) → return 429.
- **Practical**: In distributed gateways, use Redis-backed token bucket; include headers so clients can back off properly.

### 116. How do you handle security in service-to-service communication?
- **What**: Authenticate services (mTLS/workload identity) and authorize calls with service-level policies.
- **Why**: Internal networks are not inherently safe.
- **Scenario**: Only Shipping identity can call label generation endpoint.
- **High-level flow**: Establish identities → secure channel (mTLS) → policy checks → audit and rotate.
- **Practical**: I treat services as “users”: they get identities, scopes, and least-privileged access like any human user.

### 117. What is the difference between perimeter security and defense in depth?
- **What**: Perimeter focuses on edge controls; defense in depth layers controls throughout the system.
- **Why**: Perimeter fails once an attacker is inside.
- **Scenario**: Even if gateway is bypassed, services still require auth and mTLS.
- **High-level flow**: Edge WAF + auth → internal mTLS + authz → DB least privilege → auditing.
- **Practical**: Microservices require defense in depth because lateral movement is the primary risk once one service is compromised.

### 118. How do you implement security at the API Gateway level?
- **What**: Token validation, request validation, rate limits, IP allow/deny, and centralized logging.
- **Why**: Gateway is the best choke point for consistent policy enforcement.
- **Scenario**: Validate JWT, enforce scopes, block suspicious payloads, and apply per-client quotas.
- **High-level flow**: Configure auth middleware → policies → route rules → observability → incident playbooks.
- **Practical**: Don’t rely solely on gateway; services still must validate critical authorization and input.

### 119. What are the security implications of service mesh?
- **What**: Mesh can enforce mTLS and policies, but adds a powerful control plane that must be secured.
- **Why**: Misconfigured mesh policies can either block traffic or allow too much.
- **Scenario**: Enforce “default deny” for service-to-service calls via mesh authorization policies.
- **High-level flow**: Secure control plane → manage identities/certs → define policies → audit changes → monitor.
- **Practical**: Treat mesh config like code: version it, review it, and restrict who can change it.

### 120. How do you handle security in event-driven microservices?
- **What**: Authenticate producers/consumers, authorize topics, encrypt sensitive payloads, and validate schemas.
- **Why**: Events can leak PII and become an ungoverned data lake.
- **Scenario**: Only Payments can publish `PaymentCaptured`; consumers must have read access to that topic.
- **High-level flow**: Broker ACLs → schema registry → encryption/tokenization → consumer validation → audit.
- **Practical**: I avoid publishing raw PII in events; instead publish references or tokenized data and enforce strict topic permissions.


