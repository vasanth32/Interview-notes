# Bupa Project: Ownership and Interview Guide

## What the feedback means

The Bupa answers were your strongest technical area. The interviewer could see good Durable Functions, logging, and troubleshooting knowledge. The missing piece was ownership: did you design the job, implement the orchestration, change the processor, run the investigation, or only support the team?

Use precise verbs:

- **Implemented:** I wrote and tested the code.
- **Designed:** I chose the approach and explained the trade-off.
- **Investigated:** I collected evidence and narrowed the cause.
- **Supported:** I helped execute or diagnose someone else's design.
- **Learned/POC:** I built or studied a representative example.

Never use "we migrated six jobs" if you cannot name your personal contribution to at least one job.

## Project in simple language

Bupa processes large volumes of health-insurance data. The batch workloads include tax generation and finalization, tax verification, medical-claim reconciliation, membership criteria checks, and change-of-cover processing.

The modernization moves long-running legacy jobs toward .NET 8 isolated-worker Azure Functions and Durable Functions. The business rules and Oracle data remain important, while the new runtime provides clearer orchestration, status tracking, structured logs, and cloud hosting.

## Ownership

### Your ownership statement

> I worked on the modernization of Bupa back-office batch jobs. My main ownership was the Durable Functions execution pattern and the integration around the existing processors: HTTP starter validation, orchestration, activity execution, status tracking, structured correlation logging, and test support. I also investigated a one-hour Oracle connection failure in the membership criteria job and used evidence from the host, application, database, and network layers to narrow the likely cause to the AKS-to-Oracle network path.

Then name one job:

> The clearest example is `LMembershipCriteriaJob`: it validates membership criteria, generates a report, and optionally calls the communications API. I can explain its trigger, orchestration, processor, failure handling, logging, and production diagnosis.

## Durable Functions explained for beginners

### The four parts

1. **HTTP Starter:** receives a request, validates it, starts an orchestration, and quickly returns `202 Accepted` plus a `runId`.
2. **Orchestrator:** coordinates deterministic steps. It should not call Oracle, an HTTP API, or another external system directly.
3. **Activity:** performs external work such as database access, file generation, or API calls.
4. **Status endpoint:** reads the durable instance status so the caller can see pending, running, completed, or failed.

Durable Functions persist state in Azure Storage. Queues carry work and tables hold instance status and history. Azurite provides the local equivalent during development.

The ownership sentence is:

> I kept coordination in the Orchestrator and moved non-deterministic I/O into Activities because replay can execute orchestration code again.

## Ownership map

| Area                 | Personal ownership must answer                              | Proof to prepare                             |
| -------------------- | ----------------------------------------------------------- | -------------------------------------------- |
| Function entry point | How input was validated and the run started                 | Request/response example with `runId`        |
| Orchestration        | Which activities ran and in what order                      | Orchestration diagram and code path          |
| Processor            | Which business operation you changed or integrated          | Unit test and sample input/output            |
| Reliability          | Retry, timeout, duplicate-run, and partial-failure behavior | Failure test and retry limits                |
| Observability        | Which fields made one run searchable                        | Log example using `RunId` and `JobRequestId` |
| Deployment           | What you configured versus what platform/DevOps owned       | Pipeline stage and rollback process          |
| Incident             | What you tested and what evidence changed your hypothesis   | Timeline of checks and conclusion            |

## Strong project story: the one-hour Oracle failure

### Beginner version

The membership criteria job worked locally but failed in AKS after almost exactly one hour with `ORA-12537: TNS: connection closed`. The goal was to find which layer closed the connection.

I tested one layer at a time:

1. Increased the Function host timeout, so an Azure Functions execution limit was unlikely.
2. Increased the Oracle command timeout, so the application client was unlikely to be the cause.
3. Ran the same code locally against the same database, where it continued beyond one hour.
4. Checked the Oracle session and profile limits, which did not show Oracle terminating the work.
5. Checked SQL\*Net-related settings and confirmed the stored procedure itself legitimately ran for more than an hour.

Because the failure was environment-specific and consistently aligned with 3600 seconds, the evidence pointed to a network-path session timeout between AKS and the on-premises Oracle environment, such as a firewall, NAT, VPN, or load balancer. State this as the evidence-based conclusion unless infrastructure confirmed the exact device.

### STAR answer

> **Situation:** A long-running membership criteria Durable Function failed in AKS at about 3600 seconds with `ORA-12537`, while the same workload ran locally.
>
> **Task:** I needed to determine whether the failure came from the Function host, application timeout, Oracle, or the network path.
>
> **Action:** I increased the host and Oracle client timeouts, compared local and AKS behavior, checked Oracle session and profile state, reviewed SQL\*Net settings, and ran the stored procedure independently. I recorded the result of each test instead of changing several layers at once.
>
> **Result:** The Function host and Oracle continued running, but the connection closed only across the AKS path at a fixed one-hour boundary. I provided evidence that narrowed the issue to infrastructure networking and prevented more blind application-timeout changes.

## A second story: cost-aware logging

The system used Console, SQL Server, and Application Insights for different purposes. SQL Server held detailed per-record history; Application Insights supported alerts, exceptions, and trends.

Your ownership explanation should be specific:

> I identified that detailed information logs were too noisy for Application Insights. I separated lifecycle events from record-level diagnostics by using a lifecycle scope/tag. Warnings and errors remained visible, while detailed information logs stayed in SQL Server. This preserved support evidence and reduced telemetry noise and ingestion cost.

Follow-ups:

- How do you ensure lifecycle tags are not accidentally omitted?
- What correlation fields are mandatory?
- Which alerts indicate a failed job rather than a slow but successful job?
- How do you avoid logging member-sensitive information?

## Follow-up Questions

- Which of the six jobs did you personally implement most deeply?
- What code belongs in the Activity versus the Processor library?
- How do you prevent an activity retry from applying a database update twice?
- What happens if the caller submits the same job twice?
- How do you expose business validation failures versus infrastructure failures?
- Why is an anonymous function endpoint acceptable, and what network controls protect it?
- How did you test a two-hour job without waiting two hours every time?
- What exactly did the platform or DevOps team own?
- What was your fix, and what was only your escalation or diagnosis?

## Evidence checklist

- Pick one job and write its exact request, orchestration, activity, processor, and status flow.
- Prepare one unit test, one integration test, and one failure test you personally ran.
- Know the retry and idempotency behavior for database updates.
- Keep the Oracle incident timeline to five or six evidence-backed steps.
- Replace broad statements such as "we improved scalability" with an observable outcome.
- State whether the deployment target was AKS, Azure Functions hosting, or both, and explain the relationship accurately.

## One-minute answer

> I worked on Bupa's modernization of long-running insurance batch jobs. My ownership was around the Durable Functions pattern and processor integration: validating the request, starting an orchestration, keeping external I/O in Activities, exposing status by `runId`, and adding correlation-aware logging. My strongest incident was a membership criteria job that failed in AKS at exactly one hour with an Oracle connection-closed error. I tested the host, client, application parity, Oracle session, database settings, and stored procedure separately. The evidence ruled out the main application and Oracle causes and narrowed the problem to a network timeout on the AKS-to-Oracle path. I can explain exactly what I implemented, what I investigated, and what required infrastructure ownership.
