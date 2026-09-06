# Bupa Batch Job Projects — Interview Prep (Simple Terms)

This note summarizes my current project (Bupa health insurance system) in plain, spoken language for interviews — what the system is, what each batch job does, the architecture, and likely Q&A.

---

## 1. One-line summary (say this first in an interview)

> "I work on a health insurance backend system for Bupa. My part is a set of **Azure Function batch jobs** that automate tax processing, membership eligibility checks, medical claim reconciliation, and cover/membership changes — things that used to run as scheduled Windows Service jobs on a legacy .NET Framework system, and are now being modernized to Azure Durable Functions on AKS."

---

## 2. What is a "batch job" (in case they ask basics)?

A batch job is code that runs **automatically, without a person clicking a button**, usually on a schedule (nightly/weekly) or triggered by another system, to process a large number of records at once — e.g., generate 100,000 tax statements, or check membership eligibility for all customers.

Contrast with an API: an API responds instantly to one user request. A batch job processes bulk data in the background and nobody is "waiting" on the same request/response cycle.

---

## 3. The Legacy System vs the Modern System (important talking point)

|               | Legacy (Hugo.Batch)                     | Modern (my current work)                              |
| ------------- | --------------------------------------- | ----------------------------------------------------- |
| Framework     | .NET Framework 4.8, C# 7.3              | .NET 8 (isolated worker)                              |
| Hosting       | Windows Service (runs 24/7, on-prem/VM) | Azure Functions on AKS (Kubernetes)                   |
| Trigger       | Internal scheduler + MEF plugin loading | HTTP trigger → Durable Function orchestration         |
| Database      | Oracle (stored procedures, PL/SQL)      | Oracle (still) + SQL Server for logs                  |
| Logging       | log4net                                 | Serilog → Console + SQL Server + Application Insights |
| Job discovery | MEF "AddIns" (dynamic plugin loading)   | Explicit Azure Function per job                       |

**Why this matters for interviews:** I can talk about _migrating_ legacy scheduled jobs into cloud-native, observable, horizontally-scalable Azure Functions — a very common "modernization" story interviewers like.

---

## 4. My Batch Job Projects — what each one does

All follow the same **Azure Durable Functions pattern**: HTTP Starter → Orchestrator → Activity → Status endpoint (explained in section 5).

### 4.1 `HI.FunctionApp.Batch.TaxGenPst` (Tax Generation Post-processing)

- Runs **after** tax statements are already generated and sent out.
- Does **not** generate statements — it finalizes/adjusts them.
- Modes: `Annual` (year-end finalization), `AdjustmentForMailHouse`, `AdjustmentForATO` (Australian Tax Office), `SystemFix`, `ManualReissue` (blocked — not allowed via this job).
- Talking point: "It's the cleanup/finalization step of the tax pipeline, not the generator."

### 4.2 `HI.FunctionApp.Batch.TaxGenerationJob`

- The job that actually **generates** the tax statements for members (calculates tax data, produces the documents).
- Feeds into TaxGenPst afterward.

### 4.3 `HI.FunctionApp.Batch.TaxVerifyJob`

- Validates/verifies the tax output before/after distribution — a QA/reconciliation step to make sure generated tax data is correct before it goes to members or the tax office.

### 4.4 `HI.FunctionApp.Batch.MedicalClaimReconJob`

- Reconciles medical claim transmissions — compares claim records/messages, checks statuses, and updates claim header status (e.g., marks a claim `REJD` = rejected) where needed.
- Logs a clear start/finish summary: `"Reconciliation complete. Processed=X; Failed=Y; Total=Z"`.
- Talking point: "It's a data-integrity/reconciliation job that keeps claims data consistent by comparing and fixing mismatches."

### 4.5 `HI.FunctionApp.Batch.LMembershipCriteriaJob`

- Checks membership eligibility/criteria (e.g., PDS = Product Disclosure Statement cessation checks).
- Generates report files (CSV) and — if configured — **emails** the report via a Comms API (only if a recipient email, API config, and PDS records all exist).
- Talking point: this is the job where I investigated a real production issue (see section 6) involving Oracle timeouts on AKS.

### 4.6 `HI.FunctionApp.Batch.ChangeOfCover` (`ChangeOfCoverJob`)

- Handles processing when a member **changes their insurance cover/plan** — a Durable Function orchestration that runs the change workflow asynchronously and lets the caller poll status by `runId`.
- Good example to explain Azure Storage/Azurite usage (queues + tables for orchestration state) — see section 5.3.

---

## 5. The common architecture pattern (very important — expect deep questions here)

All these jobs use the same 4-part **Durable Functions pattern** because batch jobs can run long, and plain HTTP functions time out:

```
Client
  → POST /api/<JobName>          (Starter — validates input, schedules orchestration, returns 202 + runId)
Orchestrator
  → calls Activity                (coordinates the workflow, no direct DB/HTTP calls itself)
Activity
  → runs the real business logic  (calls the Processor / Oracle / external APIs)
Client
  → GET /api/<JobName>/status/{runId}   (Status — returns Running/Completed/Failed)
```

### 5.1 Why Durable Functions instead of a plain HTTP function?

- A normal HTTP function can **time out** on long-running work (batch jobs can run for an hour+).
- Durable Functions return an immediate `202 Accepted` with a `runId`, do the real work in the background, and let the caller **poll status** instead of holding a connection open.

### 5.2 Rules I follow when building these (things I'd mention as "best practices I know")

- Business logic stays in a separate **Processor**/library project, not in the Azure Function itself (separation of concerns, easier to unit test).
- Orchestrator should only **coordinate** — never call DB/HTTP directly (that must happen in the Activity).
- All batch HTTP endpoints (Starter, Status) use `AuthorizationLevel.Anonymous` — because these are triggered by internal schedulers/orchestration systems, not end users, and the real security boundary is network-level (APIM, private endpoints, IP allow-listing), not a function key.
- `Program.cs` must call `FunctionsApplication.CreateBuilder(args)` with the real `args` — passing an empty array can silently break isolated-worker startup.
- Requires `AzureWebJobsStorage` configured (Azurite locally, real Storage Account in Azure) because Durable Functions persist orchestration state in Queues + Tables behind the scenes.

### 5.3 What Azure Storage/Azurite does under the hood (good to explain simply)

When you POST to start a job:

- A **queue** gets a work item for the orchestrator to pick up.
- **Table storage** tracks the current status (`Instances` table) and full replay history (`History` table) per `runId`.
- The Status endpoint just reads the `Instances` table to tell you Running/Completed/Failed.

Locally we use **Azurite** (a storage emulator) so we don't need a real Azure Storage account during development.

---

## 6. Real production issue I investigated (great STAR-format interview story)

**Job:** `LMembershipCriteriaJob`
**Symptom:** Long-running Durable Function talking to an on-prem Oracle DB failed at almost exactly **3600 seconds (1 hour)** with `ORA-12537: TNS: connection closed`, only when hosted on AKS — not locally.

**How I investigated (systematic, layer-by-layer elimination):**

1. Ruled out Azure Functions host timeout (raised `host.json` timeout to 6h, function stayed alive).
2. Ruled out Oracle client-side command timeout (raised `CommandTimeout` to 7200s, no change).
3. Ruled out application code — same code worked fine locally against the same Oracle DB for 90+ minutes.
4. Checked Oracle session (`v$session`) — session stayed `ACTIVE`, Oracle wasn't killing it.
5. Checked Oracle profile limits (`dba_profiles` — `CONNECT_TIME`/`IDLE_TIME`) — both `UNLIMITED`, not the cause.
6. Tested various `SQLNET.EXPIRE_TIME` / `RECV_TIMEOUT` / `SEND_TIMEOUT` values — no change.
7. Confirmed the stored procedure itself legitimately runs 2+ hours when run directly.

**Conclusion (what I'd say in an interview):** Since it happened only in AKS and consistently at 1 hour, it pointed to a **network/infrastructure-level idle connection timeout** between AKS and the on-prem Oracle network path (e.g., a firewall/load balancer/NAT idle timeout), not application code, not Oracle server config, and not the Azure Functions host.

**Why this is a good interview answer:** it shows a **methodical, evidence-based debugging approach** — testing one layer at a time (app → DB client → code parity → DB session → DB profile → network protocol → SQL itself) instead of guessing.

---

## 7. Logging strategy (another strong talking point — shows maturity)

Three destinations for logs: **Console**, **SQL Server** ("Logs" table), **Application Insights**.

- **SQL Server** = full diary — every log line, used for detailed row-by-row debugging.
- **Application Insights** = headline news only — used for dashboards/alerts, so it must stay low-noise (and costs money per volume).

**The problem:** by default every `LogInformation` (even noisy per-record logs) was going to both sinks, flooding App Insights.

**The fix — two "gates" before a log reaches App Insights:**

1. Gate 1: log level is `Warning` or `Error` → always let through.
2. Gate 2: log level is `Information` **and** it's tagged `IsLifecycleEvent = true` (via `logger.BeginScope(...)`) → let through (e.g., "job started", "job completed: Processed=150; Failed=2").

Everything else (e.g., `"HeaderId=12345: updating claim header status to REJD"`) stays in SQL Server only.

**Why this matters:** shows I understand **cost-aware observability** — not just "log everything everywhere."

---

## 8. Likely interview questions and clear answers

### Q1. What does your project do?

**Answer:**

> I work on Bupa back-office batch processing. The jobs automate large-volume insurance operations such as generating and finalizing tax statements, verifying tax results, reconciling medical claims, checking membership criteria, and processing cover changes. We are modernizing legacy scheduled jobs into .NET 8 Azure Function applications using Durable Functions. The business rules and Oracle data remain important, but the new design improves operational tracking, logging, scalability, and supportability.

**Simple follow-up:** A normal API processes one request and responds quickly. A batch job processes many records in the background, often on a schedule, and can run for minutes or hours.

### Q2. Why did you use Durable Functions instead of a normal HTTP-triggered Azure Function?

**Answer:**

> A normal HTTP request is not a good place to execute a long-running batch job because the client may time out while waiting and cannot easily track progress. With Durable Functions, the HTTP endpoint validates the request and returns `202 Accepted` immediately. It gives the caller a `runId`, then the job runs asynchronously. The caller can use the `runId` to call a status endpoint and see whether the job is pending, running, completed, or failed.

**Key point to remember:** Durable Functions make a long-running workflow reliable and observable; they do not make slow database work automatically faster.

### Q3. Explain the flow from starting a batch job to seeing its result.

**Answer:**

> First, Control-M or another internal caller sends a POST request to the HTTP Starter. The starter validates the input, creates correlation information such as the job request ID, and schedules a Durable orchestration. It returns `202 Accepted` with the `runId` and a status link. The Orchestrator then coordinates the next steps and calls an Activity function. The Activity calls the processor, which performs the real work such as calling Oracle or another internal API. Finally, the caller polls the status endpoint using the `runId` to get the current runtime status and final business result.

### Q4. What is the difference between an HTTP Starter, Orchestrator, and Activity function?

**Answer:**

> The HTTP Starter is the entry point. It receives and validates the request, schedules the job, and returns quickly. The Orchestrator controls the workflow: it decides which activities run and in what order. The Activity contains the external work, for example database calls, HTTP calls, file processing, or invoking the existing batch processor. This separation keeps the function code small and makes the business logic easier to test.

### Q5. Why should an Orchestrator not call a database or HTTP API directly?

**Answer:**

> Durable orchestrators can replay their execution history to rebuild state after restarts or scale-out. If an orchestrator directly called Oracle or an HTTP API, that external call could be repeated during replay and cause duplicate updates or unpredictable behavior. Therefore, the orchestrator only coordinates deterministic workflow steps, while Activity functions perform external I/O exactly where it belongs.

### Q6. How do you handle a failed batch run?

**Answer:**

> The processor or Activity captures the error, logs it with the `RunId` and `JobRequestId`, and lets the orchestration finish as failed when appropriate. The status endpoint returns the runtime status and available error details. This lets support teams search SQL logs or Application Insights for one run rather than manually comparing logs from many executions. For retryable failures, such as a temporary service problem, I would use controlled retries with clear limits. For business validation failures, I would return a meaningful error rather than retrying blindly.

### Q7. How do you monitor and troubleshoot the jobs in production?

**Answer:**

> We use structured Serilog logging with three destinations: console logs for the running workload, SQL Server for detailed searchable job logs, and Application Insights for operational telemetry. Every important event carries correlation values such as `RunId`, `JobRequestId`, and status. SQL keeps detailed information-level logs for support investigations. Application Insights receives warnings, errors, and selected lifecycle events such as job start and job completion, which supports dashboards and alerts without creating unnecessary telemetry noise or cost.

### Q8. Why do you use both SQL logging and Application Insights?

**Answer:**

> They serve different purposes. SQL logging is useful for detailed, per-run operational history and filtering by business identifiers. Application Insights is better for cloud monitoring: exceptions, trends, response timings, dashboards, and alerts. Sending every detailed record-level log to Application Insights would create noise and increase ingestion cost, so we filter it to high-value lifecycle events plus warnings and errors.

### Q9. How is a Durable Function able to remember job status after the original HTTP request ends?

**Answer:**

> Durable Functions persist orchestration state in Azure Storage. Azure Storage queues carry work and control messages, while table storage maintains instance status and orchestration history. The `runId` identifies that persisted orchestration instance. In local development, we use Azurite as the Azure Storage emulator; in Azure, the Function App uses a real Storage Account through `AzureWebJobsStorage`.

### Q10. How do you secure endpoints that use `AuthorizationLevel.Anonymous`?

**Answer:**

> In this project, the endpoints are anonymous because internal schedulers need to call the starter and status APIs without managing Function keys. Anonymous at the Function level does not mean publicly exposed without protection. The real boundary is network and platform security, such as APIM, private endpoints, firewall and IP allow-lists, restricted ingress, and workload identity. I would confirm those controls exist before approving this pattern for production.

### Q11. Tell me about a difficult production issue you investigated.

**Answer using STAR:**

> **Situation:** The `LMembershipCriteriaJob` was a long-running Durable Function calling an on-premises Oracle stored procedure. In AKS, it failed consistently at about 3600 seconds with `ORA-12537: TNS: connection closed`.
>
> **Task:** I needed to determine whether the cause was Azure Functions, application timeout configuration, Oracle, or the network path.
>
> **Action:** I investigated one layer at a time. I increased the Function timeout to six hours and confirmed the Function host continued running. I raised the Oracle command timeout to 7200 seconds. I ran the same code locally against the same Oracle database, where it ran beyond an hour. I checked the Oracle session, user profile limits, SQL\*Net settings, database logs, and executed the stored procedure independently.
>
> **Result:** The Azure Function host remained alive and Oracle continued processing, but the TCP connection was closed only from the Azure/AKS environment at almost exactly one hour. We ruled out application and Oracle causes and escalated to the infrastructure team with evidence that the likely cause was a network-path timeout, such as firewall, NAT, VPN, or load-balancer session timeout.

### Q12. Why did the exact 3600-second failure matter?

**Answer:**

> A failure at the same value every time is strong evidence of a configured timeout rather than random application behavior. Since 3600 seconds is one hour, I treated it as a clue to investigate infrastructure timeout settings. That changed the investigation from "increase another application timeout" to "prove which layer closes the connection."

### Q13. How do you test a migrated tax batch job?

**Answer:**

> We test in stages. First, developers test validation, business logic, error handling, and API endpoints. Next, the team runs the job end to end through Control-M using a limited, controlled data set. Finally, the business performs full production-like regression using the full Hugo database and normal scheduling dependencies. The key success condition is functional parity: tax calculations, statements, extracts, adjustments, and downstream data must be correct and unchanged after the technology migration.

### Q14. Why do some batch jobs call the database directly instead of using REST APIs?

**Answer:**

> For high-volume batch processing, direct database access can reduce API hops and network overhead, which can improve throughput. The trade-off is tighter coupling to database contracts. We manage that risk through controlled stored procedures or queries, careful access permissions, logging, validation, and regression testing. Where a domain API is the correct business boundary, the batch job can use the REST API instead.

### Q15. How would you make a batch job idempotent?

**Answer:**

> Idempotency means that retrying the same request should not create duplicate business effects. I would use a job request ID or business key, persist the run state, check whether the same work was already completed, and make database updates conditional or transactional where possible. For file creation or external calls, I would use a stable idempotency key and record the outcome. This is especially important because distributed systems can retry after a transient failure.

### Q16. What would you improve for an even longer-running or higher-volume job?

**Answer:**

> I would first measure where time is being spent: data retrieval, stored procedures, file generation, or external API calls. Then I would consider splitting independent work into durable activities, processing records in safe batches, using controlled parallelism, checkpointing progress, and making each batch idempotent. I would also review database query plans and network timeouts. I would not add parallelism blindly because it can overload Oracle or create contention.

### Q17. What happens if the Function App restarts while a Durable job is running?

**Answer:**

> Durable Functions persist the orchestration history and state in Azure Storage. When the host becomes available again, the Durable runtime can resume the orchestration from its stored history. Activities must still be designed carefully because an in-progress external operation may need idempotency protection if it is retried.

### Q18. What was your contribution to the modernization project?

**Answer:**

> My contribution was to support the migration of legacy batch-processing workloads to .NET 8 Azure Functions using the Durable Functions pattern. I worked on API-triggered orchestration, status tracking, processor integration, structured logging, testing, and production troubleshooting. I also investigated the Oracle timeout issue using evidence from application logs, Azure-hosted behavior, and Oracle session checks, which narrowed the issue to the infrastructure network path.

## 9. Questions to ask the interviewer

Use one or two of these at the end of an interview:

- How are long-running or scheduled workloads implemented in your team today?
- What is your approach to observability and correlation across APIs, batch jobs, and external systems?
- How do you handle idempotency and retries for jobs that update business data?
- Which operational metrics matter most for your batch-processing workloads: completion time, error rate, throughput, or data reconciliation?
- What are the main modernization challenges the team is solving this year?

---

## 10. Quick vocabulary cheat-sheet

- **Orchestrator** — coordinates workflow steps, must be deterministic, no direct I/O.
- **Activity** — does the actual work (DB calls, HTTP calls, business logic).
- **Starter** — the HTTP entry point that kicks off an orchestration.
- **runId / instanceId** — unique ID to track/poll a specific job run.
- **Azurite** — local emulator for Azure Storage (used by Durable Functions for state).
- **MEF (legacy)** — Managed Extensibility Framework, used by the old Windows Service to dynamically load jobs as plugins.
- **Lifecycle event** — a log tagged as important enough to also go to Application Insights (job start/finish summaries).
