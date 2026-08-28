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

## 8. Likely interview questions & short answers

**Q: What does your project do, in one sentence?**
A: Automates back-office insurance processes — tax generation/finalization, medical claims reconciliation, and membership/cover changes — as scheduled Azure Function batch jobs for Bupa.

**Q: Why Durable Functions instead of just a normal Azure Function?**
A: Batch jobs can run long (minutes to hours) and plain HTTP triggers time out. Durable Functions return `202 Accepted` immediately with a `runId` and let the orchestration run in the background while the caller polls status.

**Q: How do you avoid putting business logic in the Function/Orchestrator?**
A: Business logic lives in a separate class library ("Processor"), injected via DI. The Orchestrator only coordinates and calls an Activity; the Activity calls the Processor. Keeps it testable and framework-agnostic.

**Q: Why is your batch endpoint `Anonymous` auth instead of a function key?**
A: These are triggered by internal schedulers/other systems, not end-users, so we secure them at the network layer (APIM/private endpoint/firewall) instead of function keys, which don't fit an automated caller well.

**Q: How do you monitor these jobs in production?**
A: Serilog writes structured logs to SQL Server (full detail) and Application Insights (filtered — only warnings/errors and tagged lifecycle events like job start/finish summaries), so dashboards stay meaningful and cheap.

**Q: Tell me about a hard bug you solved.**
A: The Oracle 1-hour timeout on AKS (see section 6) — walk through the layer-by-layer elimination.

**Q: What's the tax pipeline order?**
A: Generate (`TaxGenerationJob`) → Verify (`TaxVerifyJob`) → Post-process/finalize or adjust (`TaxGenPst`).

**Q: What database do you use?**
A: Oracle for the core domain/business data (legacy + current), SQL Server for structured job logging, Application Insights for telemetry.

---

## 9. Quick vocabulary cheat-sheet

- **Orchestrator** — coordinates workflow steps, must be deterministic, no direct I/O.
- **Activity** — does the actual work (DB calls, HTTP calls, business logic).
- **Starter** — the HTTP entry point that kicks off an orchestration.
- **runId / instanceId** — unique ID to track/poll a specific job run.
- **Azurite** — local emulator for Azure Storage (used by Durable Functions for state).
- **MEF (legacy)** — Managed Extensibility Framework, used by the old Windows Service to dynamically load jobs as plugins.
- **Lifecycle event** — a log tagged as important enough to also go to Application Insights (job start/finish summaries).
