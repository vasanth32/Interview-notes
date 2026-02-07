# BackLog Guide (Beginner): Migration, Architecture, Performance, Multi-Tenant SaaS, and Testing

## How to use this document

- **Goal**: understand *interview-grade* scenarios with **high-level thinking** + **practical steps**.
- **How to read**: for each topic, learn:
  - **What it is** (1–2 lines)
  - **Why it matters**
  - **How to do it safely** (checklist + common mistakes)

---

## Migration from .NET Framework to .NET (Core) – architecture, compatibility, risk mitigation

### What it is
Moving an app from **.NET Framework (Windows-only, older stack)** to **modern .NET (formerly .NET Core)** so you get cross-platform support, better performance, modern hosting, and newer libraries.

### What interviewer expects
- **You won’t “big-bang rewrite”** a large system.
- You’ll plan **incremental migration**, keep production stable, and reduce risk.

### Key architecture decisions (high level)
- **Keep boundaries clean**:
  - UI (Web) ↔ API ↔ Domain/Services ↔ Data
- **Strangler pattern** (most common in real life):
  - Build new .NET services/modules beside old app, route traffic gradually.
- **Shared contracts**:
  - Keep DTOs/Contracts stable so old + new can run together.

### Compatibility checklist
- **Target framework**: start with `net8.0` (or your company standard).
- **Libraries**:
  - Prefer packages that support **.NET Standard 2.0+** or **net6+ / net8**.
  - Replace old WebForms/WCF-only dependencies if needed.
- **APIs that often break**:
  - `System.Web` (ASP.NET classic)
  - AppDomains/Remoting
  - Old config system (web.config heavy)

### Risk mitigation (practical)
- **Baseline first**:
  - Add monitoring + logs + key business metrics before migration.
- **Characterization tests**:
  - Write tests that capture current behavior before changing internals.
- **Incremental releases**:
  - Feature flags + canary deployments + easy rollback.
- **Parallel run**:
  - Run old + new in production and compare outputs for a subset of traffic.

### Tools (common choices)
- **.NET Upgrade Assistant**: helps convert projects and find incompatibilities.
- **try-convert**: converts old `.csproj` to SDK-style project format.

---

## Handling third-party library incompatibility during migration

### What it is
Some NuGet packages you used in .NET Framework **won’t work** in modern .NET (or have different APIs).

### What interviewer expects
You don’t panic or rewrite everything—**you isolate the risk**.

### Practical strategy (best order)
- **Inventory**:
  - List all packages + versions + where they’re used.
- **Find replacements**:
  - Prefer official/active maintained libraries.
- **Wrap behind interfaces** (important):
  - Create `IEmailSender`, `IPdfGenerator`, `IStorageClient`.
  - Implementation can change without changing your business logic.
- **Sidecar / out-of-process option**:
  - If a library is Windows-only, run it as a separate service and call it via HTTP/queue.

### Risk controls
- **Proof-of-compatibility PoC** for the top 3 risky libs.
- **Contract tests** around wrapper interfaces.
- **Fallback plan** documented (library A fails → library B).

---

## Configuration & secret management – Key Vault, managed identities, secret rotation

### What it is
Managing app settings + secrets (DB passwords, API keys) securely—without hardcoding them in code or committing them to Git.

### Beginner mental model
- **Configuration**: non-sensitive settings (feature flags, URLs, timeouts)
- **Secrets**: sensitive values (passwords, tokens, certificates)

### Azure approach (common in real projects)
- **Azure Key Vault**: stores secrets centrally.
- **Managed Identity**: your app authenticates to Key Vault **without storing credentials**.

### Secret rotation (what it means)
Changing secrets regularly (or after incidents) with minimal downtime.

### Practical checklist
- **Never store secrets in**:
  - `appsettings.json` in repo
  - Angular `environment.ts` (frontend code is public after build)
- **Use**:
  - Environment variables for local/dev
  - Key Vault/Secrets Manager for production
- **Rotation plan**:
  - Support **two valid secrets** during transition (old + new)
  - Switch app to new secret, then disable old

### Common mistakes
- Putting secrets in Angular build variables and thinking it’s “hidden”
- Using one Key Vault secret for all environments (dev/prod should be separate)

---

## Designing multi-tenant SaaS APIs – tenant isolation, scaling, noisy-tenant handling

### What it is
One application serves multiple customers (**tenants**). Each tenant’s data must be isolated and protected.

### Tenant identification (how API knows the tenant)
- **Subdomain**: `tenant1.app.com`
- **Header**: `X-Tenant-Id: tenant1`
- **Token claim**: `tenant_id` inside JWT (common)

### Data isolation models (most common options)
- **Shared DB, shared schema + TenantId column** (cheapest, fastest to start)
  - Must enforce tenant filters everywhere.
- **Shared DB, separate schema per tenant** (more isolation)
- **Separate DB per tenant** (best isolation, higher ops cost)

### Noisy tenant problem
One tenant uses too many resources and slows others.

### Practical protections
- **Rate limiting per tenant**
- **Quotas** (requests/day, storage size)
- **Separate queues per tenant** for heavy background jobs
- **Resource partitioning**:
  - Dedicated plans/instances for big tenants (enterprise tier)

---

## High-performance .NET (Core) APIs – diagnosing bottlenecks, endpoint optimization

### What it is
Making APIs respond fast and handle high traffic reliably.

### The performance debugging order (simple, realistic)
1. **Measure first** (don’t guess)
2. **Find the bottleneck**: CPU? DB? IO? network? serialization?
3. **Fix the biggest one**, then measure again

### What to instrument
- **Latency**: p50/p95/p99
- **Throughput**: requests/sec
- **Errors**: 4xx/5xx rate
- **DB**: slow queries, locks, connection pool usage

### Common optimizations
- **Database**:
  - indexes, reduce N+1 queries, select only needed columns
- **API**:
  - caching (memory/redis), compression, pagination
- **Code**:
  - avoid blocking calls, use async correctly, reduce allocations

### Interview-ready example statement
“I first add tracing/metrics, then isolate whether the slow time is in DB or API. 80% of the time we fix query/indexing + overfetching + missing pagination.”

---

## EF Core concurrency handling – optimistic vs pessimistic locking

### What it is
Handling “two users update the same record” safely.

### Optimistic concurrency (most common)
Assume conflicts are rare. Detect conflict when saving.
- Use a **RowVersion/Timestamp** column
- EF throws `DbUpdateConcurrencyException` if data changed since read

**When to use**:
- Typical web apps with low chance of simultaneous edits

**What you do on conflict**:
- Tell user “record changed, please refresh”
- Or auto-merge if safe (depends on domain)

### Pessimistic locking
Lock the row while editing/transaction runs (reduces conflicts but reduces throughput).

**When to use**:
- Money/inventory/critical updates with frequent collisions

**Trade-off**:
- More blocking + potential deadlocks if not careful

---

## Distributed transactions in microservices – Saga, Outbox, eventual consistency

### Why it’s hard
In microservices, you usually **cannot** do one big DB transaction across services.

### Eventual consistency (key concept)
System becomes consistent **after a short time**, not instantly.

### Saga pattern (high level)
Break one big transaction into steps with **compensating actions**.

- **Choreography**: services react to events (no central controller)
- **Orchestration**: a coordinator service tells others what to do

### Outbox pattern (high level)
When you save business data, you also save an “event to publish” in the same DB transaction.
- A background worker publishes outbox events reliably.

### What interviewer expects
- You understand **idempotency** (safe retries)
- You can explain failures and how system recovers

---

## Angular performance optimization – lazy loading, OnPush, virtual scroll

### Lazy loading
Load feature modules/routes only when needed → faster initial load.

### `OnPush` change detection
Angular checks UI updates less often → faster rendering.
- Works best when you treat data as **immutable** (new objects instead of mutating old ones).

### Virtual scroll
Render only visible list items → smooth UI for huge lists.

---

## Angular state management strategy selection

### What it is
Choosing how your app stores and shares state (user, cart, filters, cached data).

### Decision guide (beginner)
- **Small app**: service + RxJS/Signals is enough
- **Medium**: Component Store style (local feature state)
- **Large**: NgRx (clear patterns, more boilerplate, strong discipline)

### What interviewer expects
You don’t pick NgRx “because it’s popular”. You pick based on:
- team size, complexity, debugging needs, performance, time constraints

---

## Angular accessibility (WCAG) implementation and governance

### What it is
Making the app usable for keyboard-only users, screen readers, and users with visual/motor impairments.

### WCAG basics (high level)
- **Perceivable** (contrast, text alternatives)
- **Operable** (keyboard navigation)
- **Understandable** (clear labels, errors)
- **Robust** (works across assistive tech)

### Practical checklist
- **Semantic HTML first** (buttons, labels, headings)
- **Keyboard support**:
  - tab order, focus visible, no keyboard traps
- **Forms**:
  - proper `<label for>` and error messages
- **Governance**:
  - define a “done checklist”, run audits (axe/Lighthouse), keep failures visible

---

## Microservices testing strategy – unit, integration, contract testing

### The test pyramid (simple)
- **Unit tests** (fast): functions/classes in isolation
- **Integration tests** (medium): DB, queues, external services in a test environment
- **Contract tests** (critical in microservices): producer/consumer API contracts stay compatible
- **E2E tests** (slow): full system flows, keep few

### Contract testing (why it matters)
Stops “Service A changed response format and broke Service B” before production.

---

## Test data & environment stability challenges

### The real problem
Tests fail not because code is wrong, but because:
- shared environments are dirty
- data changes
- external dependencies are unstable

### Practical fixes
- **Reset DB per test run** (migrations + seed)
- **Use isolated test containers** (Docker/Testcontainers) when possible
- **Make tests idempotent** (can run multiple times)
- **Avoid time-dependent tests** (freeze clock)

---

## Introducing NUnit tests into legacy systems

### What it is
Adding tests to old code without breaking production.

### Best beginner strategy
- Start with **characterization tests** (capture existing behavior)
- Add tests around **boundaries** (services, repositories)
- Refactor safely once tests protect behavior

### Common migration approach
- Add NUnit project
- Add small “test seams” (interfaces/wrappers) to mock dependencies

---

## CI/CD testing strategies – parallel tests, flaky test handling, fast feedback

### Goals
- **Fast feedback** on PRs
- **Reliable** test signal (few false failures)

### Practical strategy
- **Split tests**:
  - smoke (fast) → runs on every PR
  - full suite → runs on merge/nightly
- **Parallelize**:
  - run tests in multiple jobs
- **Flaky tests**:
  - quarantine + ticket ownership
  - retry *carefully* (don’t hide real bugs)

---

## Jasmine async test reliability best practices

### Why async tests become flaky
Timing issues: promises, timers, HTTP mocks, or not waiting properly.

### Practical best practices
- Prefer **`async/await`** for promise-based code
- Use Angular testing helpers (`fakeAsync`, `tick`) when dealing with timers
- Avoid arbitrary `setTimeout` waits
- Always **flush/complete** observables properly

---

## BDD with Jasmine for stakeholder collaboration

### What it is
Writing tests in a **Given / When / Then** style so non-technical stakeholders can follow intent.

### How it looks in Jasmine
- `describe()` = feature/context
- `it()` = scenario
- inside: Given/When/Then comments or helper functions

### Example style (conceptual)
- **Given** user is logged in
- **When** user adds item to cart
- **Then** cart count increases

---

## Karma test coverage and failing test governance

### Coverage (high level)
Coverage shows “how much code is executed by tests”, but:
- **High coverage ≠ good tests**
- It’s still useful as a guardrail

### Governance (how teams keep quality)
- **Coverage thresholds**:
  - block PR if coverage drops below target (with exceptions process)
- **Failing test policy**:
  - tests must be fixed quickly
  - flaky tests quarantined with owner + deadline
- **Fast feedback**:
  - keep PR pipeline fast; move heavy tests to nightly if needed

---

## If you want to go deeper (tell me your preference)

Pick any 1 topic and I can extend it into a mini “interview answer + PoC plan”, e.g.:
- **Saga + Outbox** with a sample Order → Payment → Inventory flow
- **Multi-tenant isolation** with a sample DB schema + tenant middleware
- **Angular performance** with a sample list page using virtual scroll + server paging


