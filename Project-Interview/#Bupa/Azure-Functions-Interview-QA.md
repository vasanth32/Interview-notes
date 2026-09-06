# Azure Functions Batch Jobs - Interview Questions and Answers

This is a standalone interview-preparation note based on the Bupa batch-job modernization work. The answers are written in simple language so they can be explained naturally in an interview.

---

## 1. What does your Azure Function project do?

**Answer:**

> I work on Bupa back-office batch-processing applications. They automate large-volume insurance work such as tax statement generation and finalization, medical claim reconciliation, membership-criteria checks, and insurance cover changes. The legacy jobs are being modernized into .NET 8 Azure Function applications using Durable Functions. This improves operational tracking, logging, scalability, and supportability while keeping the existing business rules unchanged.

A normal API usually handles one request and returns quickly. A batch job runs in the background and processes a large number of records, often on a schedule.

---

## 2. Why did you use Durable Functions instead of a normal HTTP-triggered Function?

**Answer:**

> Batch jobs can run for a long time, sometimes minutes or hours. A normal HTTP request is not suitable because the client may wait too long or time out. With Durable Functions, the HTTP endpoint validates the request and returns `202 Accepted` immediately with a `runId`. The work continues asynchronously, and the caller can check progress through a separate status endpoint.

**Important point:** Durable Functions make the workflow reliable and trackable. They do not automatically make a slow database operation faster.

---

## 3. Explain the Azure Durable Functions flow in your project.

**Answer:**

> First, Control-M or another internal system sends a POST request to an HTTP Starter endpoint. The Starter validates the input, creates correlation information such as a job request ID, and schedules a Durable orchestration. It returns `202 Accepted` with a `runId` and a status URL. The Orchestrator coordinates the workflow and calls an Activity function. The Activity calls the processor, which performs the real business work, such as calling Oracle or another internal API. The caller polls the status endpoint with the `runId` until the job is completed or failed.

```text
Client or scheduler
    -> HTTP Starter
    -> 202 Accepted + runId
    -> Durable Orchestrator
    -> Activity function
    -> Processor / Oracle / internal API
    -> Status endpoint returns progress and result
```

---

## 4. What is the difference between a Starter, Orchestrator, and Activity function?

**Answer:**

> The Starter is the entry point. It receives and validates the request, starts the Durable workflow, and returns quickly. The Orchestrator controls the workflow: it decides which steps run and in what sequence. The Activity performs the real external work, such as database calls, HTTP calls, file processing, or invoking an existing processor. This separation keeps the code clean and easier to test.

---

## 5. Why should an Orchestrator not call Oracle or an HTTP API directly?

**Answer:**

> A Durable Orchestrator can replay its execution history after a restart or scale-out event. If it directly calls Oracle or an HTTP API, that external action could be repeated during replay and create duplicate updates or inconsistent results. Therefore, I keep the Orchestrator focused on deterministic coordination and move database, API, and file operations into Activity functions.

---

## 6. How do you handle a failed batch job?

**Answer:**

> The Activity or processor captures and logs the error with the `RunId`, `JobRequestId`, exception details, and job status. If the problem is unrecoverable, the orchestration completes with a failed status. The status endpoint returns the current runtime state and available error information. This helps the support team trace one specific run instead of searching through logs from many jobs.

For a temporary problem, such as a short service outage, I would use controlled retries with limits. For a business validation error, I would return a meaningful failure rather than retrying the same invalid request.

---

## 7. How do you monitor these jobs in production?

**Answer:**

> We use structured Serilog logging with three destinations: console, SQL Server, and Application Insights. Important logs include correlation values such as `RunId`, `JobRequestId`, and status. SQL Server stores detailed execution logs for operational investigation. Application Insights is used for cloud monitoring, errors, timings, dashboards, and alerts.

We avoid sending every detailed information log to Application Insights. It receives warnings, errors, and selected lifecycle events such as job started and job completed. This keeps telemetry useful and controls ingestion cost.

---

## 8. Why use both SQL logging and Application Insights?

**Answer:**

> They have different purposes. SQL logging is useful for detailed, searchable history for a particular job run or business identifier. Application Insights is useful for operational monitoring, trends, exceptions, performance timings, dashboards, and alerts. Using both gives support teams detailed evidence as well as a high-level health view.

---

## 9. How does Durable Functions remember the job status after the original HTTP request ends?

**Answer:**

> Durable Functions persist orchestration state in Azure Storage. Azure Storage queues carry work and control messages, while storage tables keep orchestration history and current instance state. The `runId` identifies that persisted orchestration instance. In local development, we use Azurite as the Azure Storage emulator. In Azure, the Function App uses a real Storage Account configured through `AzureWebJobsStorage`.

---

## 10. How do you secure endpoints that use `AuthorizationLevel.Anonymous`?

**Answer:**

> In this project, internal schedulers need to invoke the Starter and status endpoints without managing Function keys, so the endpoints use anonymous Function-level authorization. This does not mean the APIs should be publicly accessible. The real security boundary is provided by platform and network controls such as APIM, private endpoints, firewall or IP allow-lists, restricted ingress, and workload identity. I would always confirm those protections exist before using this approach in production.

---

## 11. Tell me about a difficult production issue you investigated.

**Answer using STAR:**

> **Situation:** The `LMembershipCriteriaJob` was a long-running Durable Function that called an on-premises Oracle stored procedure. In AKS, it failed consistently at about 3600 seconds with `ORA-12537: TNS: connection closed`.
>
> **Task:** I needed to find whether the cause was Azure Functions, our application timeout settings, Oracle, or the network path.
>
> **Action:** I checked each layer methodically. I increased the Function timeout to six hours and confirmed the host remained running. I raised the Oracle command timeout to 7200 seconds. I ran the same code locally against the same Oracle database, where it ran beyond one hour. I also checked the Oracle session state, user profile limits, SQL\*Net settings, database logs, and the stored procedure independently.
>
> **Result:** The Azure Function host remained alive and Oracle continued processing, but the TCP connection closed only from the Azure/AKS environment at almost exactly one hour. We ruled out application and Oracle causes and escalated to infrastructure with evidence that the likely cause was a network-path timeout, such as a firewall, NAT, VPN, or load-balancer session timeout.

---

## 12. Why was the exact 3600-second failure important?

**Answer:**

> A failure at the same time on every run is strong evidence of a configured timeout instead of random application behavior. Since 3600 seconds is one hour, it suggested that an infrastructure component might have a one-hour session or idle timeout. That clue helped us focus on proving which layer was closing the connection instead of repeatedly increasing application-level timeouts.

---

## 13. How do you test a migrated tax batch job?

**Answer:**

> We test in stages. First, developers test input validation, business rules, error handling, and API endpoints. Then the team runs the job end to end through Control-M with a limited and controlled data set. Finally, the business performs full production-like regression with the Hugo database and normal scheduling dependencies. The key requirement is functional parity: tax calculations, statements, extracts, adjustments, and downstream data must remain correct after the technology migration.

---

## 14. Why do some batch jobs access the database directly instead of using REST APIs?

**Answer:**

> High-volume batch jobs may access Oracle directly to reduce API hops and network overhead, which can improve throughput. The trade-off is tighter coupling to database contracts. We manage that risk through controlled database access, least-privilege permissions, structured logging, validation, and regression testing. When a domain API is the correct business boundary, the job uses the REST API instead.

---

## 15. How would you make a batch job idempotent?

**Answer:**

> Idempotency means that retrying the same request must not create duplicate business effects. I would use a stable job request ID or business key, record the execution state, and check whether the work has already completed. Database updates should be conditional or transactional where possible. For external calls or file generation, I would use an idempotency key and persist the outcome. This is important because cloud workloads can retry after temporary failures.

---

## 16. How would you improve a job that is becoming slower as data volume grows?

**Answer:**

> I would first measure where time is being spent: data retrieval, stored procedures, file generation, or external API calls. Based on that evidence, I could split independent work into Durable Activities, process records in safe batches, checkpoint progress, and use controlled parallelism. I would also review database query plans and network timeout settings. I would not add parallelism blindly because it can overload Oracle or create database contention.

---

## 17. What happens if the Function App restarts while a Durable job is running?

**Answer:**

> Durable Functions persist the orchestration state and history in Azure Storage. When the Function host becomes available again, the Durable runtime can resume the orchestration from that saved state. Activity code must still be idempotent because an external operation may be retried after an interruption.

---

## 18. What was your contribution to the modernization project?

**Answer:**

> I supported the migration of legacy batch workloads to .NET 8 Azure Functions using the Durable Functions pattern. My work included API-triggered orchestration, status tracking, processor integration, structured logging, test support, and production troubleshooting. I also investigated the long-running Oracle timeout issue using application logs, Azure-hosted behavior, and Oracle session checks, which narrowed the likely cause to the infrastructure network path.

---

## Questions to ask the interviewer

- How are long-running or scheduled workloads implemented in your team today?
- What is your approach to observability and correlation across APIs, batch jobs, and external systems?
- How do you handle idempotency and retries for jobs that update business data?
- Which operational metrics matter most for your batch workloads: completion time, error rate, throughput, or data reconciliation?
- What modernization challenges is the team focusing on this year?

---

## Quick vocabulary

- **Starter:** HTTP entry point that validates input and starts an orchestration.
- **Orchestrator:** Coordinates durable workflow steps. It should not perform direct external I/O.
- **Activity:** Performs real work such as database calls, API calls, or file processing.
- **`runId` / instance ID:** Unique identifier used to track a particular job run.
- **Azurite:** Local emulator for Azure Storage.
- **Lifecycle event:** Important log event, such as job start or completion, that is useful for monitoring.
- **Idempotency:** Retrying an operation does not duplicate its business effect.
