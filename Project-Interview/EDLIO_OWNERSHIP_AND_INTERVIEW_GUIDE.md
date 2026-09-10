# Edlio Project: Ownership and Interview Guide

## Why this guide exists

Your Edlio material shows good knowledge of microservices, AWS, security, queues, payments, and deployment. The interview risk is that the answer can sound like a description of the whole platform rather than proof of what **you** owned.

The interviewer should be able to answer these questions after every story:

1. Which service, feature, or delivery area did you personally own?
2. What did you build or change yourself?
3. Which technical decision did you make, and what trade-off did you consider?
4. What went wrong or was difficult?
5. How did you prove the result?

Do not describe all nine services before explaining your own area. Start narrow, then expand only when asked.

## Project in simple language

Edlio is an online school platform with multiple portals and tenants. Students, school administrators, and platform administrators use the system for identity, enrollment, activities, fees, payments, notifications, and reporting.

The architecture uses independently deployable services, a database-per-service approach, API Gateway, asynchronous messaging, containers, and cloud monitoring. The important business challenge is that one user action can cross several services while tenant isolation and payment correctness must be preserved.

## Ownership

### Your ownership statement

Use this version only after replacing any uncertain details with facts you can defend:

> I worked on the Edlio-like multi-tenant school platform. My primary ownership was the Identity and Access Service and selected enrollment and payment-related flows. I implemented authentication and authorization with JWT claims for user, role, tenant, and permissions; enforced tenant-aware access at the service boundary; worked on asynchronous events and service integration; and contributed to deployment, logging, and failure-handling patterns. My responsibility was to make the flow secure, testable, and traceable across services, not just to create individual endpoints.

If your actual ownership was a POC rather than a production system, say:

> This was a POC and learning implementation. I personally built and validated the flow locally and documented the production design. I would not claim that I operated all nine services in production.

That distinction increases credibility.

## Ownership map

| Area       | Say "I owned" only when you can explain                                       | Evidence to prepare                                 |
| ---------- | ----------------------------------------------------------------------------- | --------------------------------------------------- |
| Identity   | Login, password handling, JWT claims, refresh/revocation, RBAC, tenant checks | Endpoint flow, token example, authorization test    |
| Enrollment | Request validation, enrollment state, capacity or fee event                   | Sequence diagram, state transitions, failure case   |
| Payment    | Payment transaction state, idempotency, reconciliation, gateway boundary      | Data model, duplicate request test, reversal path   |
| Messaging  | Event contract, producer/consumer, retry, DLQ, idempotency                    | Sample event, retry policy, poison-message handling |
| Deployment | Docker image, health check, ECS task, ALB route, pipeline step                | One deployment run and rollback procedure           |
| Operations | Correlation ID, logs, dashboards, alert, incident response                    | Example query, alert threshold, diagnosis timeline  |

Use "the team" for work you supported or consumed. Use "the platform" for architecture that you studied or designed but did not personally implement.

## A beginner-friendly technical walkthrough

### 1. A student logs in

1. The client sends credentials to the Identity Service.
2. The service validates the credentials and loads the user's school/tenant and roles.
3. It creates a short-lived access token and a refresh-token record.
4. The token contains claims such as `userId`, `tenantId`, `role`, and permissions.
5. The API Gateway and downstream service validate the token.
6. The service checks both permission and tenant ownership before reading or changing data.

The important ownership point is not "I used JWT." It is "I decided which claims were required, where they were validated, and how a school administrator was prevented from accessing another school's data."

### 2. A student enrolls in an activity

1. The request reaches the API Gateway.
2. Authentication and authorization are checked.
3. The Enrollment Service validates the activity, student, capacity, and current state.
4. The service stores its own enrollment data.
5. It publishes an `EnrollmentCreated` event.
6. Fee, Notification, and Reporting consumers process the event independently.
7. A failed consumer retries; a message that cannot be processed moves to a DLQ.

Explain that the enrollment response does not need to wait for email or reporting. Also explain that asynchronous processing creates eventual consistency, so the system needs status tracking and idempotent consumers.

### 3. A payment crosses service boundaries

The Payment Service should own payment state. Other services should not update its tables directly. A safe flow records a business transaction ID, sends the request to the payment provider, stores the provider response, and publishes a result event.

Follow-up points to prepare:

- What happens if the provider responds but the application crashes before saving the response?
- What happens if the same event is delivered twice?
- How are pending, completed, failed, reversed, and reconciled states represented?
- How does finance find transactions that do not match the provider settlement file?

Do not claim that a saga or reconciliation design is complete unless you can show the state model and failure path.

## Three strong ownership stories

### Story A: Tenant-aware authorization

**Situation:** Several portals used the same platform, but school data had to remain isolated.

**Task:** I needed to authenticate users and make authorization depend on both role and tenant.

**Action:** I designed the JWT claims, implemented role/permission checks, extracted the tenant from the authenticated context, and added negative tests where a valid SchoolAdmin token attempted to access another school's data. I kept authentication concerns in the Identity boundary and authorization checks close to the protected resource.

**Result:** The system had a repeatable authorization flow instead of relying on the client to hide data. The result should be stated with a real test or measured outcome, not an invented availability or user number.

**Likely follow-up:** What happens if a user changes schools? How do you revoke a refresh token? Where do you log denied access? Can a SuperAdmin cross tenant boundaries, and is that explicit?

### Story B: Reliable event processing

**Situation:** Synchronous calls made enrollment dependent on fee calculation, notifications, and reporting.

**Task:** I needed to make downstream work asynchronous without losing business events.

**Action:** I defined event fields and versioning, published after the enrollment transaction reached the required state, configured visibility timeout and retries, acknowledged only after successful processing, and routed poison messages to a DLQ. Consumers used an idempotency key before applying business effects.

**Result:** The core enrollment request was decoupled from slower downstream work, while support still had a path to inspect and replay failures.

**Likely follow-up:** What if publishing fails after the database commit? A strong answer mentions an outbox or another explicit consistency strategy.

### Story C: Container deployment

**Situation:** Multiple services needed independent deployment and health-based traffic routing.

**Task:** I needed to package a service, expose health checks, and deploy it behind a load balancer.

**Action:** I created the Docker image, configured environment-specific settings outside the image, added `/health`, pushed the image to ECR, created the ECS task/service and target group, and tested unhealthy-task replacement. I used a staged deployment and defined how to return to the previous task definition.

**Result:** The service could be deployed independently and traffic was sent only to healthy tasks.

**Likely follow-up:** Who owned the VPC and IAM? What was your exact step versus the DevOps team's step? How did you test rollback?

## Follow-up Questions

- Which service did you personally code most deeply?
- Show the request path for one user story from client to database and event consumer.
- Why database-per-service instead of one shared database?
- How did you handle distributed transactions? Why saga instead of a local transaction?
- How did you prevent duplicate enrollment, payment, or event processing?
- What was one production-like failure you reproduced?
- What did you monitor, and what alert would wake you up?
- Which AWS service did you configure yourself, and which was only part of the design?
- What would you change before calling this finance-grade?

## Evidence checklist before an interview

- Draw one sequence diagram from login or enrollment.
- Prepare one real code-level example for authorization and one for event handling.
- Write down the exact services you implemented, reviewed, or only studied.
- Replace unsupported metrics such as "zero breaches" or "60% improvement" with test results or remove them.
- Prepare one failure timeline with log evidence and the final fix.
- Know your rollback trigger and who had authority to approve it.

## One-minute answer

> Edlio was a multi-tenant school platform. My strongest ownership was the identity and authorization boundary, plus selected service integration flows. I worked on JWT claims, tenant isolation, role and permission checks, and the event-driven path used by enrollment and downstream services. I also worked through deployment and observability concerns so a request could be traced across services. The key design trade-off was using asynchronous events for responsiveness and independent scaling, while adding idempotency, retries, and DLQs because delivery is not the same as exactly-once processing. This was a POC/design-led project where I can clearly separate what I implemented from what I proposed for production.
