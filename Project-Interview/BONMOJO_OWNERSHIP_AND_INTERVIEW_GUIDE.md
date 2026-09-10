# Bonmojo Project: Ownership and Interview Guide

## What the feedback means

Bonmojo is the project where ownership can become least clear because the notes describe a broad online gaming platform and many Azure services. A long service list does not prove implementation depth. The interviewer needs one narrow feature that you can trace from request to data, message, provider, monitoring, and recovery.

Choose one primary lane before the interview:

- payment and wallet processing;
- sports betting and settlement;
- casino/game-provider integration; or
- deployment and platform operations.

You can mention the other services as context, but do not present every service as your personal work.

## Project in simple language

Bonmojo is an online casino and sports-betting platform. It has user, sports, casino, payment, and game-provider capabilities. The platform needs quick responses for users, reliable updates for money-related operations, secure provider credentials, and good observability during live events.

The documented design uses .NET microservices, an API Gateway, SQL Server, asynchronous messaging, Redis, Blob Storage, Key Vault, Application Insights, and independent deployments. Before saying "we used" for a service, confirm whether you implemented it, configured it, supported it, or only included it in the architecture/POC.

## Ownership

### Your ownership statement

Use a truthful version of this template:

> My primary contribution to Bonmojo was **[feature/service]**. I owned **[specific API, workflow, integration, or deployment slice]**. I implemented **[two or three concrete actions]**, made the decision to **[decision]** because **[trade-off]**, and validated it with **[tests, logs, or deployment evidence]**. I collaborated with **[team or platform owner]** for **[dependency]**. I did not personally own **[explicit boundary]**.

Example for payment:

> My primary contribution was the payment workflow. I owned the request validation, transaction state transitions, provider integration boundary, and persistence of the provider reference. I added idempotency around the client transaction ID and made the response asynchronous for operations that could take time. I tested duplicate requests, provider timeout, callback replay, and failed withdrawal. The payment gateway credentials and production network configuration were owned by the platform team.

Do not claim finance-grade reconciliation unless you can explain matching, exception queues, reversals, settlement timing, audit history, and operational ownership.

## Pick a feature and draw its full boundary

### Option A: Payment and wallet flow

1. The client sends a deposit or withdrawal request.
2. The API validates the user, amount, currency, limits, and idempotency key.
3. The Payment Service records a pending transaction.
4. The provider call is made directly or through a worker, depending on latency and reliability needs.
5. The provider result is stored with its external reference.
6. The wallet balance changes only under a transaction-safe rule.
7. A payment event is published for notifications and reporting.
8. A timeout or callback replay is handled without double crediting or debiting.

Ownership is demonstrated by explaining the state machine, not by naming Azure SQL or Service Bus.

Suggested states are `Pending`, `Succeeded`, `Failed`, `Cancelled`, `Reversed`, and `NeedsReview`. Use the states that exist in your implementation, not this list automatically.

### Option B: Sports bet and settlement flow

1. The user receives odds with an expiry or version.
2. The Betting Service validates the stake, balance, event state, and current odds.
3. It records the bet and reserves or deducts funds safely.
4. The completed-event message starts settlement.
5. Settlement calculates the outcome and updates the bet and wallet exactly once.
6. A notification/reporting event is published.
7. A failed settlement is retried or moved to an operational queue.

Follow-ups will focus on odds changing between display and placement, duplicate settlement, race conditions, and how an operator corrects a disputed result.

### Option C: Game-provider integration

1. The user selects a game.
2. The Casino Service asks the provider boundary for a session or launch token.
3. Provider-specific fields are translated into a common internal model.
4. Secrets are loaded from Key Vault or an equivalent secret store, not source code.
5. Provider failures are mapped to safe client errors and detailed internal logs.
6. The session and game result are recorded for support and audit.

The ownership story is the adapter boundary: common platform behavior stays stable while provider-specific APIs vary.

## Ownership map

| Area              | What you must be able to explain                         | Evidence                               |
| ----------------- | -------------------------------------------------------- | -------------------------------------- |
| API               | Validation, authentication, authorization, error mapping | Request examples and negative tests    |
| Business workflow | State transitions and invariants                         | State diagram and transaction boundary |
| Database          | Tables, indexes, consistency, ownership                  | Schema and one query plan              |
| Messaging         | Event contract, retry, DLQ, duplicate handling           | Sample message and consumer test       |
| Security          | Secret access, least privilege, sensitive data           | Key Vault/identity path                |
| Performance       | Cache key, TTL, invalidation, rate limit                 | Measurement before and after           |
| Deployment        | Image, settings, health check, rollback                  | Pipeline run or POC record             |
| Operations        | Dashboard, alert, correlation ID, incident step          | Query and incident example             |

## Three ownership stories

### Story A: Duplicate payment protection

**Situation:** A payment request or provider callback can be delivered more than once.

**Task:** I needed to ensure the user balance changed at most once for one business transaction.

**Action:** I used a stable client/provider reference, checked existing transaction state, made the state transition conditional, and stored the provider response. I added tests for the same request twice, a callback replay, and a timeout followed by a successful callback.

**Result:** Repeated delivery became a safe no-op or a controlled state update instead of a second wallet mutation. State your actual test evidence and do not claim exactly-once delivery; the goal is idempotent business effects.

**Follow-ups:** What if the database commit succeeds but the event publish fails? How does support replay it? What happens when the provider says success but your system has no matching pending transaction?

### Story B: Provider adapter

**Situation:** Multiple game providers exposed different APIs and payloads.

**Task:** I needed to avoid spreading provider-specific code through the Casino Service.

**Action:** I defined a common internal contract, implemented provider adapters, mapped errors and identifiers, isolated credentials, and tested the common flow against provider-specific responses.

**Result:** A new provider could be added behind the same application boundary, and provider failure did not leak raw credentials or internal details to the client.

**Follow-ups:** How do you version an adapter? How do you handle provider rate limits? Where do you log a provider request without logging sensitive data?

### Story C: Operational diagnosis

**Situation:** A live betting or payment workflow becomes slow or fails during peak traffic.

**Task:** I needed to identify whether the bottleneck was the API, database, cache, queue, or external provider.

**Action:** I followed a correlation ID across the gateway and services, checked request/dependency latency, examined queue age and DLQ count, reviewed SQL performance, and compared provider response time. I changed one suspected bottleneck at a time.

**Result:** The investigation produced a layer-specific cause and a reversible mitigation, such as throttling, retry limits, cache adjustment, or provider isolation.

**Follow-ups:** Which metric triggers an alert? How do you distinguish provider slowness from your database slowness? What is the rollback decision?

## Be careful with the Azure service list

Explain services through decisions:

- **Service Bus:** decouple work that does not need to complete before the user response; explain retries, DLQ, and duplicate processing.
- **Redis:** cache data with a clear TTL and invalidation rule; never treat cache as the authoritative wallet balance unless designed for it.
- **Key Vault:** retrieve secrets using an identity and least privilege; explain rotation and failure behavior.
- **Application Insights:** trace requests and dependencies; define an alert that leads to action.
- **App Service or containers:** explain health checks, configuration, scaling signal, and rollback.
- **Azure SQL:** explain transaction boundaries, indexes, and how money-related updates remain consistent.

Avoid unsupported claims such as exact latency, cost reduction, uptime, or transaction volume unless you can show how the number was measured.

## Follow-up Questions

- Which service did you personally own?
- Walk me through one payment from request to settlement.
- How do you prevent double debit or double credit?
- How do you reconcile internal transactions with the provider's settlement report?
- What happens when a queue message is delivered twice?
- What is in the DLQ, and who is allowed to replay it?
- How do you protect provider keys and rotate them without downtime?
- How do you handle an unavailable Redis cache?
- How do you deploy a change that affects payment schema?
- Tell me about a defect you introduced and how you detected it.
- Which design is implemented, which is a POC, and which is a future option?

## Evidence checklist

- Select one lane: payments, betting, casino/provider, or deployment.
- Write the exact files/classes/endpoints you changed.
- Draw the state machine for the chosen workflow.
- Prepare tests for duplicate requests, timeout, retry, and partial failure.
- Prepare one log/trace example with a correlation ID.
- Separate production evidence from POC architecture.
- Remove or qualify metrics you cannot defend.

## One-minute answer

> Bonmojo is a microservice platform for sports betting and casino games. My primary ownership was **[chosen lane]**, especially **[specific workflow]**. I implemented **[specific code or configuration]** and made **[decision]** to balance **[reliability, latency, consistency, or maintainability]**. The difficult part was **[failure or integration problem]**, so I added **[retry, idempotency, adapter, monitoring, or rollback control]** and validated it with **[test/evidence]**. I collaborated with the platform team on **[boundary]**, and I can clearly distinguish that from the parts I designed as a POC.
