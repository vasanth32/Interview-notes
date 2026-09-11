# Project Based Answers

## Q1: Explain the Complete Architecture of Your Recent Project

> "Vasanth, take one of your recent projects and explain the complete architecture to me, from the client request until the response"

### Project Overview

This project was an enterprise **batch-processing system** for a health insurance platform. We had multiple batch jobs that needed to process data periodically and integrate with systems such as Oracle HUGO and SQL databases.

### High-Level Architecture Flow

```

Batch Trigger → Azure Function → Durable Function orchestration → Activity/Business Logic → Oracle/SQL → Logging & Monitoring

```

### Technology Stack & Architecture Breakdown

#### 1. **Core Execution Layer**

- **Azure Functions** with .NET Core as the entry point

- Functions triggered periodically based on schedule

- Handled the job execution responsibility

#### 2. **Orchestration & Workflow Management**

- **Azure Durable Functions** for complex workflows

- Coordinated multiple activities without putting all logic in the orchestrator

- Supported long-running, multi-step processing

- Built-in retry and state management

#### 3. **Business Logic & Clean Architecture**

- Business logic kept separate from the function trigger

- Service and business-layer components for reusability

- Function responsibility: trigger + orchestration

- Service layer responsibility: actual business logic

#### 4. **Data Layer**

- Communication with backend systems:
  - Oracle HUGO database

  - SQL databases

- Data processing based on batch requirements

#### 5. **Configuration & Secrets Management**

- **Azure Key Vault** for sensitive information

- Credentials and configuration secured (no hardcoding)

- Environment-based configuration

#### 6. **Reliability & Error Handling**

- Failure and retry handling at appropriate processing levels

- Durable Functions automatically retried failed activities

- Workflow could continue without full restart

#### 7. **Monitoring & Logging**

- **Application Insights** for monitoring and diagnostics

- **Serilog** for application logging

- Production troubleshooting and performance analysis

- Failure investigation and execution details tracking

#### 8. **Quality Assurance**

- **Unit & Integration Tests** using xUnit and Moq

- **SonarQube** for code quality analysis

- **Checkmarx** for security vulnerability scanning

#### 9. **Deployment**

- Deployed as **Azure Function Apps**

- Runs periodic workloads independently from client-facing APIs

### Architecture Summary

| Component | Responsibility |

|-----------|-----------------|

| Azure Functions | Job execution & trigger handling |

| Durable Functions | Workflow orchestration & state management |

| Business/Service Layers | Core processing logic |

| Oracle/SQL | Data persistence |

| Key Vault | Secure configuration |

| Application Insights + Serilog | Monitoring & logging |

---

## Q2: Why Azure Functions Instead of .NET Web API for Batch Jobs?

> "You said Azure Function handles the job. Why didn't you just create a separate .NET Web API for the batch job? What's the actual advantage of Azure Functions here?"

### The Core Difference

While technically a .NET Web API could execute the same logic, Azure Functions was chosen based on **workload characteristics**, not execution capability.

### Workload Nature

**Batch Processing Requirements:**

- Periodic/scheduled execution (not continuous request-response)

- Background processing without client waiting

- No requirement for user-facing interaction

- Long-running, multi-step workflows

### Key Advantages of Azure Functions

#### 1. **Serverless Execution Model**

- Focus on business logic without managing application servers

- No infrastructure management overhead

- Automatic scaling based on demand

#### 2. **Platform Integration**

- Seamless integration with Azure ecosystem:
  - Durable Functions for orchestration

  - Application Insights for monitoring

  - Key Vault for secrets management

- Built-in bindings and triggers

#### 3. **Orchestration & State Management**

- **No Custom Implementation Needed:**
  - Scheduling (built-in)

  - State management (Durable Functions)

  - Retry logic (built-in)

  - Long-running workflow tracking (built-in)

- **With a Web API, you'd need to build all of this yourself**

#### 4. **Infrastructure Alignment**

- With Web API, you'd still need something to trigger it periodically (Task Scheduler, separate orchestrator, etc.)

- With Azure Functions, everything is unified in the platform

### Decision Rationale

**Both can execute code. The decision was based on:**

✓ **Workload type** — Scheduled, background, event-driven

✓ **Platform fit** — Durable Functions ecosystem

✓ **Operational overhead** — Minimal infrastructure management

✓ **Built-in capabilities** — Retry, state, scheduling

✓ **Cost efficiency** — Pay-per-execution model

### What a Web API Approach Would Require

If we had used a Web API:

- Separate scheduler/orchestrator service

- Custom scheduling implementation

- Custom state management for long-running workflows

- Custom retry logic

- Custom infrastructure provisioning and management

- Continuous server availability (higher costs)

### Conclusion

Azure Functions with Durable Functions was a **better architectural fit** for a periodic, scheduled, background batch workload compared to a continuously-running Web API.

---

You said it's a background workload. But I can create a Worker Service or Web API with a scheduler. Why exactly is Azure Functions better?

Yes 👍. Let's forget the **interview-answer paragraph** for now. I'll explain it to you like a beginner, so you understand the concept first.

# Azure Functions vs Web API vs Worker Service

The interviewer asks:

> **"Why did you use Azure Function? Couldn't you just create a Web API or Worker Service?"**

The simple answer is:

**Yes, we could.**

Azure Function is **not magically capable of something that Web API cannot do**.

The difference is mainly **how the application is hosted and how the work is triggered/managed**.

---

## 1. First understand a Web API

Imagine you create:

```text

.NET Web API

     ↓

POST /process-batch

     ↓

Process 100,000 records

```

Someone has to call this API.

For example:

```text

Control-M

    ↓

calls API

    ↓

POST /process-batch

    ↓

Web API

    ↓

Process records

```

So yes, you can absolutely build your batch as a Web API.

---

# 2. Then what is a Worker Service?

A Worker Service is designed specifically for background work.

For example:

```text

Worker Service

      ↓

Wait

      ↓

Run batch

      ↓

Wait

      ↓

Run batch

      ↓

Wait...

```

It is normally a continuously running application.

You might host it on:

- VM

- Kubernetes

- App Service

- Container

- etc.

So:

```text

Server

  ↓

Worker Service

  ↓

Background processing

```

---

# 3. Now Azure Function

Azure Function is also capable of running background code.

But Azure gives you a **managed way of running that code based on triggers**.

For example:

```text

Trigger

   ↓

Azure Function

   ↓

Your C# code

```

The trigger could be:

```text

Timer

Queue

HTTP

Event

etc.

```

In **your Bupa project**, you told me the scheduling was handled by **Control-M**.

So your conceptual flow is:

```text

Control-M

    ↓

Azure Function

    ↓

Batch processing

```

---

# 4. So where is the actual difference?

This is the important part.

Imagine you have a batch that runs once every night.

### Option A — Worker Service

You need a Worker Service continuously running:

```text

        Server

          ↓

   Worker Service

          ↓

       waiting

          ↓

       waiting

          ↓

     10:00 PM

          ↓

    Run batch

```

The application is basically sitting there waiting for work.

---

### Option B — Web API

You have:

```text

Control-M

    ↓

HTTP request

    ↓

Web API

    ↓

Run batch

```

You need to maintain the API application and the mechanism that invokes it.

---

### Option C — Azure Function

You have:

```text

Control-M

    ↓

Azure Function

    ↓

Run batch

```

Azure manages much of the underlying hosting/execution infrastructure.

That's one reason Functions can be attractive for this type of workload.

---

# 5. But wait... Control-M already exists!

Exactly! 👏

This is where your interviewer may challenge you.

They might say:

> **"Vasanth, Control-M is already scheduling the job. So why do you need Azure Functions? Why not Control-M → Web API?"**

That's a **very good question**.

And the answer is:

You **could** do:

```text

Control-M

    ↓

Web API

    ↓

Batch

```

There is nothing technically wrong with that.

Your team chose:

```text

Control-M

    ↓

Azure Function

    ↓

Batch

```

because the batch workload was suitable for the **serverless/managed execution model** and the project was already using Azure services.

---

# 6. Think of it like this

Suppose you need someone to clean a room once a day.

### Worker Service

You hire a person and keep them inside the room **24 hours a day**, waiting.

```text

Person

  ↓

Waiting...

  ↓

Waiting...

  ↓

Clean room

```

### Web API

You have a person available and someone calls:

> "Please clean the room."

```text

Caller

  ↓

Person

  ↓

Clean room

```

### Azure Function

You tell the building management:

> "Whenever this job needs to happen, provide the execution environment and run this code."

```text

Trigger

  ↓

Managed execution

  ↓

Run code

```

That's the basic idea.

---

# 7. Very important: Don't say "Functions are better"

In an interview, don't think:

```text

Azure Function > Web API

```

Think:

```text

Which one fits my workload better?

```

For example:

| Requirement | Possible choice |

| --------------------------------------- | ----------------- |

| Client request/response | Web API |

| Continuously running background process | Worker Service |

| Event/scheduled/serverless workload | Azure Function |

| Complex multi-step serverless workflow | Durable Functions |

There can be overlap.

---

# 8. Then why did Bupa use Durable Functions?

That's the **next level**.

Suppose your batch isn't just:

```text

Start

 ↓

Process

 ↓

Finish

```

Instead:

```text

Start

 ↓

Get data from Oracle

 ↓

Validate

 ↓

Process records

 ↓

Update SQL

 ↓

Generate result

 ↓

Finish

```

Now you have a **workflow with multiple steps**.

That's where Durable Functions becomes useful.

```text

Azure Function

      ↓

Durable Function

      ↓

 ┌────┼────┬────┐

 ↓    ↓    ↓    ↓

 A    B    C    D

```

We'll cover this in **Question 3**.

---

## 🧠 Remember just these 3 things

**Control-M**

> "When should the job run?"

**Azure Function**

> "Run my code."

**Durable Function**

> "Manage this multi-step workflow."

---

Suppose the batch takes 2 hours. What happens if the Function execution is interrupted?

### 2. **Unexpected Crash** ⚠️ — Your Server Dies

**What happens:**

- Your function app crashes (bad code, out of memory, etc.)

- No warning, no goodbye

**The sequence:**

```

Your job is running...

    ↓

ERROR! Server crashes

    ↓

Function stops immediately

    ↓

Everything in memory is LOST

    ↓

But progress is saved to Azure Storage

```

**Real-world analogy:**

Like your laptop dying mid-work. You lose what's on screen, but if you had autosaved, you recover from that checkpoint.

**What's lost:**

- ❌ Work still being done in memory

- ❌ Temporary files that weren't flushed to disk

- ❌ Emails that were in the process of being sent

**What's saved:**

- ✅ Job progress (stored in Azure Table Storage)

- ✅ Reports already written to disk

- ✅ Database commits that already finished

**The recovery:**

- Someone needs to manually restart the job (it doesn't auto-restart)

- The system knows the job stopped via the stored progress

---

### 3. **Network Connection Dies** 🚨 — The Most Common Problem!

**The tricky scenario:**

Your job is running fine, but the connection between your Function App and the database breaks. This is the real issue your team documented.

**What happens:**

```

Your job: "Hey Database, process this huge report for me"

    ↓

Database: "Sure, I'm working on it... (processing for 90 minutes)"

    ↓

[SOMEWHERE IN THE MIDDLE]

Network component (Firewall/VPN/Router) says:

"This connection has been idle for 60 minutes. I'm closing it."

    ↓

Your job is STILL WAITING for the answer

    ↓

Database is STILL PROCESSING

    ↓

But the communication line is CUT

    ↓

Your job hangs (waits forever for an answer that will never come)

```

**Real-world analogy:**

You call a pizza shop and ask for a special order. They say "Sure, we're making it!" But then the phone line goes dead. You're holding an empty line, the pizza shop is still cooking, but you can't hear each other.

**The danger:**

- ⚠️ Your job **hangs** (sits idle doing nothing)

- ⚠️ The database **continues working** (you don't know this!)

- ⚠️ After 6 hours (your timeout), the job finally gives up

- ⚠️ Database finishes work, but nobody is there to receive it

**Who's at fault?**

From your team's investigation:

- ❌ NOT Azure Function App (can run 6 hours)

- ❌ NOT Database (keeps running fine)

- ✅ **Probably network security** (Firewall, NAT Gateway, VPN has a ~60-minute idle timeout)

---

## Suppose the batch takes 2 hours. What happens if the Function execution is interrupted?

---

## Q3: Suppose Your Batch Processes 100,000 Records and Fails After 60,000. How Would You Resume It?

> "Suppose your batch processes 100,000 records and fails after processing 60,000. How would you resume it?"

### Simple Answer

I would not restart the whole batch from the beginning.

I would design the batch with a **checkpoint/resume mechanism**.

### Did Our Project Already Handle This?

In our Bupa batch project, we clearly handled **job-level tracking**, but I should be careful not to overclaim **record-level resume** unless I have seen that exact implementation.

What the project had:

- Durable Function `runId` to track one job execution
- Status endpoint to check whether the job is Running, Completed, or Failed
- Azure Storage/Azurite behind Durable Functions to store orchestration state
- SQL/Application Insights logging with `RunId`, `JobRequestId`, and status
- Summary logs like `Processed=X; Failed=Y; Total=Z` for investigation

So if the Function host restarts, Durable Functions can remember the **workflow state** and continue/replay the orchestration.

But that is not exactly the same as saying:

```text
Record 60,000 completed
Restart from record 60,001
```

For that exact behavior, the processor or database procedure must save record-level progress, such as:

- each record status: Pending / Processed / Failed
- last processed record ID
- batch chunk status
- output already generated flag
- retry count / error reason

So the honest interview answer is:

> In our project, Durable Functions gave us job-level durability and status tracking using `runId`, and our logging helped identify processed/failed counts. For true record-level resume, the business processor or database layer should maintain record status or checkpoint information. If that was not already present, I would add a tracking table and make processing idempotent so the restarted job can safely continue from the remaining records.

That means after processing a set of records successfully, the job saves its progress somewhere permanent, usually in a database or job status table.

So if the batch fails after 60,000 records, the system already knows:

```text
Total records       = 100,000
Processed records   = 60,000
Pending records     = 40,000
Next record to start = 60,001
```

When the job is restarted, it reads the last saved checkpoint and continues from the remaining records.

```text
Start batch
    ↓
Process records 1 to 10,000
    ↓
Save checkpoint: 10,000 completed
    ↓
Process records 10,001 to 20,000
    ↓
Save checkpoint: 20,000 completed
    ↓
...
    ↓
Failure after 60,000
    ↓
Restart job
    ↓
Read checkpoint: 60,000 completed
    ↓
Continue from 60,001
```

### How It Works in Practice

Instead of treating 100,000 records as one huge operation, I would process them in smaller chunks.

For example:

```text
Batch 1  → records 1 to 10,000
Batch 2  → records 10,001 to 20,000
Batch 3  → records 20,001 to 30,000
...
```

After each chunk completes successfully, I update a tracking table.

Example tracking table:

| JobId             | LastProcessedRecord | Status |
| ----------------- | ------------------- | ------ |
| TaxJob-2026-09-11 | 60000               | Failed |

When the job runs again, it checks this table first.

If `LastProcessedRecord = 60000`, then the next query should pick records greater than 60,000.

```sql
SELECT *
FROM TaxRecords
WHERE RecordId > 60000
ORDER BY RecordId
```

### Very Important Point: Idempotency

The batch should also be **idempotent**.

In simple terms, idempotent means:

> If the same record is processed again by mistake, it should not create duplicate output or corrupt data.

For example, before generating a tax statement, I can check:

```text
Has this record already been processed?
    ↓
Yes → skip it
No  → process it
```

This protects us if the job fails after processing a record but before updating the checkpoint.

### Interview-Ready Answer

> If a batch has 100,000 records and fails after 60,000, I would resume it using checkpointing. The job should save progress after each successful chunk or record, for example in a job tracking table. When the job restarts, it reads the last successful checkpoint and continues from record 60,001 instead of starting from record 1 again. I would also make the processing idempotent, so even if a few records are retried, duplicate records or duplicate files are not created.

### One-Line Answer

> Save progress regularly, restart from the last successful checkpoint, and make each record safe to retry.

## **Unexpected Crash** ⚠️ — Your Server Dies

**What happens:**

- Your function app crashes (bad code, out of memory, etc.)

- No warning, no goodbye

**The sequence:**

```

Your job is running...

    ↓

ERROR! Server crashes

    ↓

Function stops immediately

    ↓

Everything in memory is LOST

    ↓

But progress is saved to Azure Storage

```

**Real-world analogy:**

Like your laptop dying mid-work. You lose what's on screen, but if you had autosaved, you recover from that checkpoint.

**What's lost:**

- ❌ Work still being done in memory

- ❌ Temporary files that weren't flushed to disk

- ❌ Emails that were in the process of being sent

**What's saved:**

- ✅ Job progress (stored in Azure Table Storage)

- ✅ Reports already written to disk

- ✅ Database commits that already finished

**The recovery:**

- Someone needs to manually restart the job (it doesn't auto-restart)

- The system knows the job stopped via the stored progress

---

### 3. **Network Connection Dies** 🚨 — The Most Common Problem!

**The tricky scenario:**

Your job is running fine, but the connection between your Function App and the database breaks. This is the real issue your team documented.

**What happens:**

```

Your job: "Hey Database, process this huge report for me"

    ↓

Database: "Sure, I'm working on it... (processing for 90 minutes)"

    ↓

[SOMEWHERE IN THE MIDDLE]

Network component (Firewall/VPN/Router) says:

"This connection has been idle for 60 minutes. I'm closing it."

    ↓

Your job is STILL WAITING for the answer

    ↓

Database is STILL PROCESSING

    ↓

But the communication line is CUT

    ↓

Your job hangs (waits forever for an answer that will never come)

```

**Real-world analogy:**

You call a pizza shop and ask for a special order. They say "Sure, we're making it!" But then the phone line goes dead. You're holding an empty line, the pizza shop is still cooking, but you can't hear each other.

**The danger:**

- ⚠️ Your job **hangs** (sits idle doing nothing)

- ⚠️ The database **continues working** (you don't know this!)

- ⚠️ After 6 hours (your timeout), the job finally gives up

- ⚠️ Database finishes work, but nobody is there to receive it

**Who's at fault?**

From your team's investigation:

- ❌ NOT Azure Function App (can run 6 hours)

- ❌ NOT Database (keeps running fine)

- ✅ **Probably network security** (Firewall, NAT Gateway, VPN has a ~60-minute idle timeout)

---

Why did you use both Serilog and Application Insights? Aren't they doing the same thing?

No — they are related, but **they are not the same thing**. Think of them as solving two different parts of observability.

## 1. What is Serilog?

**Serilog is a logging library.**

Your application uses Serilog to **create structured log messages**.

For example:

```csharp
Log.Information(
    "Started processing batch {BatchId}",
    batchId);
```

It can produce information like:

```text
Started processing batch B123
```

or structured data:

```text
BatchId = B123
Status  = Started
```

So think:

> **Serilog = How my application creates/writes logs.**

---

## 2. What is Application Insights?

**Application Insights is an Azure monitoring/telemetry service.**

It helps you collect and investigate things such as:

```text
Requests
Exceptions
Dependencies
Performance
Traces
Failures
Execution duration
```

You can then go into Azure and investigate:

```text
Application Insights
       ↓
Search logs
       ↓
Find failed Function
       ↓
See exception
       ↓
See database dependency
       ↓
Check execution time
```

So think:

> **Application Insights = Where Azure collects and helps you analyze telemetry.**

---

# 3. How can they work together?

This is the important part.

You can have:

```text
Your Azure Function
       │
       ↓
    Serilog
       │
       ↓
Structured log
       │
       ↓
Application Insights
       │
       ↓
Azure monitoring
```

So they're **not necessarily competing tools**.

One is primarily a **logging framework**, while the other is a **monitoring/telemetry platform**.

---

# 4. Real example from your batch

Suppose your batch starts:

```text
Batch ID = B123
```

You might log:

```csharp
Log.Information(
    "Batch {BatchId} started",
    batchId);
```

Then during processing:

```csharp
Log.Information(
    "Processing {RecordCount} records for batch {BatchId}",
    count,
    batchId);
```

If something fails:

```csharp
Log.Error(
    exception,
    "Batch {BatchId} failed",
    batchId);
```

Those logs can be collected into your monitoring setup.

Then in **Application Insights**, you can investigate the execution and correlate the telemetry with the Function execution and dependencies.

---

# 5. Why would a team want Serilog?

Because you want your application's logs to be:

- Consistent
- Structured
- Searchable
- Useful for troubleshooting

Instead of:

```text
Something went wrong
```

you want:

```text
BatchId: B123
Step: CustomerProcessing
RecordId: 45678
Error: Oracle timeout
Duration: 120 seconds
```

That makes production troubleshooting much easier.

---

# 6. Why Application Insights then?

Imagine your Bupa batch normally takes:

```text
20 minutes
```

Today:

```text
2 hours
```

You need to investigate.

Application Insights can help you look at:

```text
Function execution
       ↓
Duration
       ↓
Exceptions
       ↓
Dependency calls
       ↓
Database calls
       ↓
Failures
```

Then your application logs can give you the **business-specific details**.

For example:

```text
Application Insights
       │
       ├── Function took 2 hours
       ├── Oracle dependency was slow
       └── Exception occurred

Serilog logs
       │
       ├── Batch ID = B123
       ├── Step = GenerateReport
       ├── Records = 100,000
       └── Processing reached record 60,000
```

Together, they give you a much better picture.

What exactly would you look at in Application Insights?

Let's understand this like a beginner first.

# 🔍 What exactly would you look at in Application Insights?

Imagine your batch normally takes **20 minutes**, but today someone tells you:

> "Vasanth, today's batch took 2 hours. Find out why."

You open **Application Insights**. You don't just look at one screen. You investigate different types of telemetry.

---

## 1️⃣ First — Did the Function run successfully?

I'd first check:

```text
Function executions
       ↓
Success / Failed
       ↓
Duration
```

For example:

```text
Batch-Job
──────────────
Status: Failed ❌
Duration: 1h 58m
```

Now I know there is a problem.

---

## 2️⃣ Exceptions 🚨

Next I'd check **Exceptions**.

For example:

```text
Exception
   ↓
OracleException
   ↓
Connection timeout
```

This gives me an initial clue about **what went wrong**.

---

## 3️⃣ Logs / Traces 📝

Then I'd look at the application logs.

This is where your structured Serilog logging becomes useful.

For example:

```text
Batch started
Batch ID: B123

Fetching records...
100,000 records found

Processing records...
60,000 completed

Calling Oracle...
⛔ Timeout

Batch failed
```

Now I have much more context than just:

```text
Function failed
```

---

## 4️⃣ Dependencies 🔗

This is **very important for your Bupa project** because your Function communicates with databases/external systems.

I'd check:

```text
Function
   ↓
Dependencies
   ├── Oracle
   ├── SQL
   └── Other external calls
```

I want to know:

> **Which dependency was slow or failed?**

For example:

```text
Oracle
────────────
Duration: 1h 40m
Status: Timeout
```

That immediately gives me a strong lead.

---

## 5️⃣ Performance / Duration ⏱️

I'd compare the current execution with previous executions.

For example:

```text
Yesterday:  20 min
Monday:     22 min
Tuesday:    21 min
Today:      2 hours  ❌
```

Then I'd investigate **where the extra time was spent**.

Maybe:

```text
Function execution
       ↓
Business processing     10 min
Oracle call             1h 40 min  ❌
SQL processing           5 min
Other                    3 min
```

Now I know the Oracle interaction is the area to investigate.

---

# 6️⃣ End-to-end correlation

This is another useful concept.

Suppose your batch has:

```text
Batch ID = B123
```

You can use that identifier in your logs to follow the same batch through different processing steps.

```text
Batch B123
    ↓
Function started
    ↓
Oracle call
    ↓
Processing
    ↓
SQL update
    ↓
Function completed
```

That's why **structured logging** is valuable.

---

# 🧠 So what would YOU say in an interview?

Don't try to list 20 Application Insights features.

Think in this order:

```text
1. Did the Function execute?
          ↓
2. Did it succeed or fail?
          ↓
3. What exception occurred?
          ↓
4. What do the application logs say?
          ↓
5. Which dependency was involved?
          ↓
6. How long did each operation take?
          ↓
7. Can I correlate the complete batch execution?
```

### 🎤 Simple interview answer

> **"If a batch has a problem, I would first check the Function execution status and duration. Then I'd check exceptions and application traces to understand what happened. Since our batch interacts with Oracle and SQL, I'd also check the dependency telemetry to see whether a database or external call was slow or failed. I'd then correlate those logs using the batch or correlation ID to understand the complete execution flow and identify where the problem occurred."**

Tell me one production issue you personally faced in this project and how you solved it

Yes. For this one, you should use the **network/long-running database connection issue you actually described**, because it gives you a realistic production story and connects directly to Azure Functions, Oracle, Application Insights, and troubleshooting.

## 🎤 Interviewer

> **"Tell me one production issue you personally faced in this project and how you solved it."**

Yes. I remember the **exact 3600-second Oracle failure** from your Bupa batch project. More importantly, I checked the uploaded interview document again so we keep the answer consistent with your project evidence.

## 🔴 The problem

You had a **long-running `LMembershipCriteriaJob`**.

The flow was:

```text
Control-M
    ↓
Azure Function
    ↓
Durable Function
    ↓
Batch Processor
    ↓
Oracle Stored Procedure
```

The stored procedure was taking **more than 1 hour**.

But the job was consistently failing at approximately:

```text
3600 seconds
     ↓
1 hour
     ↓
ORA-12537: TNS: connection closed
```

The important clue was:

> **It was failing at almost exactly 3600 seconds every time.**

That strongly suggested a **configured timeout**, rather than a random application or database failure.

---

# 🔍 How we investigated it

We didn't immediately say:

> "Oracle is timing out."

We checked each layer.

### 1️⃣ Check Azure Function timeout

First question:

> Is Azure Function itself killing the job after one hour?

We increased the Function timeout to allow the job to run for several hours.

For example:

```text
Function timeout
       ↓
6 hours
```

But the job **still failed around 3600 seconds**.

So:

```text
Azure Function timeout
        ↓
❌ Not the root cause
```

The Function host was still alive.

---

### 2️⃣ Check Oracle command timeout

Next:

> Is our application cancelling the Oracle command?

We increased the Oracle command timeout to:

```text
7200 seconds
= 2 hours
```

But the connection was still being closed around one hour.

So:

```text
Oracle command timeout
        ↓
❌ Not the root cause
```

---

### 3️⃣ Test the same operation locally

This was the **big clue**.

We ran the same application/database operation from the local environment.

```text
Local machine
      ↓
Same Oracle DB
      ↓
Stored procedure
      ↓
Runs beyond 1 hour ✅
```

But:

```text
Azure / AKS
      ↓
Same Oracle DB
      ↓
Around 3600 sec
      ↓
Connection closed ❌
```

So we now knew:

> **The stored procedure itself was capable of running longer than one hour.**

And the problem was specific to the **Azure/AKS path to Oracle**.

---

# 🔎 4️⃣ Investigate the network path

Then we looked at:

```text
Azure/AKS
     ↓
Network
     ↓
Oracle
```

We discovered that the application traffic was passing through the **Istio Envoy sidecar**.

Think of Envoy as a proxy sitting between your application and Oracle:

```text
Application
     ↓
Envoy Sidecar
     ↓
Network
     ↓
Oracle
```

And the important finding was:

> **Envoy had a default 1-hour TCP idle timeout.**

So our long-running Oracle connection was being dropped by Envoy after approximately:

```text
3600 seconds
```

That explained the:

```text
ORA-12537: TNS: connection closed
```

---

# 🛠️ 5️⃣ The actual fix

We changed the Kubernetes deployment configuration.

We added:

```yaml
podAnnotations:
  traffic.sidecar.istio.io/excludeOutboundPorts: "1521,1530,1624"
```

The important part is:

```yaml
excludeOutboundPorts
```

This tells Istio:

> **Do not intercept traffic going to these Oracle-related ports through the Envoy sidecar.**

So before:

```text
Application
     ↓
Envoy
     ↓
Oracle
```

After:

```text
Application
     ↓
Oracle
```

The Oracle traffic bypasses Envoy.

Therefore the **Envoy 1-hour TCP timeout no longer affects that Oracle connection**.

---

# 🧠 Very simple way to remember the whole story

```text
PROBLEM
   ↓
Oracle stored procedure takes > 1 hour
   ↓
Job fails at exactly ~3600 seconds
   ↓
ORA-12537: TNS connection closed
```

Then:

```text
INVESTIGATION
   ↓
Function timeout? ❌
   ↓
Oracle command timeout? ❌
   ↓
Oracle itself? ❌
   ↓
Local test works > 1 hour
   ↓
Therefore investigate Azure/AKS network path
```

Then:

```text
ROOT CAUSE
   ↓
Oracle traffic was going through Envoy
   ↓
Envoy had 1-hour TCP idle timeout
```

Then:

```text
FIX
   ↓
Exclude Oracle ports from Envoy
   ↓
1521, 1530, 1624
   ↓
Oracle traffic bypasses Envoy
   ↓
Long-running connection is not dropped by Envoy
```

---

# 🎯 Interview answer — memorize this

If the interviewer asks:

### **"Tell me about a production issue you faced and how you solved it."**

Say:

> **"One challenging issue I faced was with a long-running batch job called LMembershipCriteriaJob. It was calling an Oracle stored procedure, and the job was consistently failing at around 3600 seconds with an ORA-12537 TNS connection closed error.**
>
> **I investigated it layer by layer. First, I increased the Azure Function timeout and confirmed that the Function host was still running, so it wasn't the Function timeout. Then I increased the Oracle command timeout to 7200 seconds, but the connection was still getting closed after around one hour.**
>
> **I then ran the same operation locally against the same Oracle database, and it worked beyond one hour. That helped us narrow the issue to the Azure/AKS network path.**
>
> **We found that the Oracle traffic was passing through the Istio Envoy sidecar, which had a one-hour TCP idle timeout. So we configured the Kubernetes pod annotation to exclude the Oracle-related ports 1521, 1530 and 1624 from Envoy sidecar interception. This allowed the Oracle traffic to bypass Envoy and prevented the one-hour TCP connection drop."**

### ⭐ The key sentence

If you remember only one thing:

> **"The Function and Oracle were still running, but the Envoy sidecar was closing the TCP connection at the one-hour mark, so we excluded the Oracle ports from Envoy interception."**

That is the **root cause → fix** you should be able to explain confidently.

---

Yes. Let's treat this as **we actually created a small POC to prove the Saga + Outbox approach**. I’ll explain the architecture, components, flow, failure handling, and what you would see during testing. No code.

> **Important:** Your OSP project material describes Saga, Outbox, event-driven communication, and idempotent handlers. The following is a POC-style explanation of how those pieces fit together, without claiming specific implementation details that aren't in the project file.

# 1. What are we trying to prove with the POC?

We want to prove this scenario:

```text
Student enrolls in Football
          ↓
Enrollment created
          ↓
Seat reserved
          ↓
Fee calculated
          ↓
Everything successful
```

And more importantly:

```text
Student enrolls
      ↓
Enrollment created       ✅
      ↓
Seat reserved            ✅
      ↓
Fee calculation          ❌
      ↓
Can we recover safely?
```

The POC demonstrates that **we can recover from a failure without leaving incorrect business data behind**.

---

# 2. POC architecture

We can keep the POC very small.

### Services

```text
┌──────────────────────┐
│ Enrollment Service   │
│ .NET Web API         │
└──────────┬───────────┘
           │
           │ HTTP / Event
           ↓
┌──────────────────────┐
│ Activity Service     │
│ .NET Web API         │
└──────────────────────┘

           │
           │ Event
           ↓
┌──────────────────────┐
│ Fee Service          │
│ .NET Web API         │
└──────────────────────┘
```

Each service has its own database:

```text
Enrollment Service → Enrollment DB

Activity Service   → Activity DB

Fee Service        → Fee DB
```

And we introduce a message broker:

```text
Services
   ↓
Message Broker
   ↓
Other Services
```

For the POC, you could use something like:

- .NET 8
- ASP.NET Core Web API
- EF Core
- SQL Server
- RabbitMQ or Azure Service Bus
- Docker
- Postman for testing

The project material lists RabbitMQ/Azure Service Bus as possible messaging infrastructure.

---

# 3. First POC — without Saga

Before implementing Saga, I'd actually demonstrate the problem.

Imagine we have:

```text
Enrollment DB
Activity DB
Fee DB
```

We call:

```text
POST /enroll
```

The flow is:

```text
Client
  ↓
Enrollment Service
  ↓
Create Enrollment
  ↓
Activity Service
  ↓
Reserve Seat
  ↓
Fee Service
  ↓
Calculate Fee
```

Now intentionally make Fee Service fail.

For example:

```text
Enrollment       ✅
Activity Seat    ✅
Fee              ❌
```

Look at the databases:

```text
Enrollment DB
-------------------
Enrollment = 1001


Activity DB
-------------------
Seat = Reserved


Fee DB
-------------------
Fee = Not Created
```

That's our problem.

The POC clearly demonstrates:

> **There is no single transaction that can rollback all three databases.**

---

# 4. Now introduce Saga

Now we introduce the Saga concept.

The Saga maintains the business workflow:

```text
Step 1
Create Enrollment

      ↓

Step 2
Reserve Seat

      ↓

Step 3
Calculate Fee
```

Every step is a **local transaction**.

Meaning:

```text
Enrollment Service
     ↓
BEGIN
Create enrollment
COMMIT
```

Then:

```text
Activity Service
     ↓
BEGIN
Reserve seat
COMMIT
```

Then:

```text
Fee Service
     ↓
BEGIN
Calculate fee
COMMIT
```

There is no global database transaction.

---

# 5. Who controls the Saga?

For understanding the POC, I recommend using an **Orchestrator**.

Think of the orchestrator as a coordinator.

```text
             Saga Orchestrator
                    |
       ┌────────────┼────────────┐
       ↓            ↓            ↓
 Enrollment      Activity       Fee
 Service         Service       Service
```

It basically says:

> "Do this first."

Then:

> "Okay, that succeeded. Now do this."

Then:

> "That succeeded too. Now do the next one."

---

# 6. Step-by-step successful flow

Let's say:

```text
StudentId = 501
ActivityId = 10
```

The client sends:

```text
Enroll Student 501
in Activity 10
```

---

## Step 1 — Create Saga

The orchestrator creates something like:

```text
SagaId = SAGA-1001
```

This ID is important because we can track the complete workflow.

Conceptually:

```text
SAGA-1001

Status = Started
```

---

# 7. Step 2 — Create Enrollment

Orchestrator tells Enrollment Service:

```text
Create enrollment
Student = 501
Activity = 10
SagaId = SAGA-1001
```

Enrollment Service performs its local transaction.

```text
Enrollment DB

EnrollmentId | Student | Activity | Status
------------------------------------------------
1001         | 501     | 10       | Pending
```

Transaction commits.

Then:

```text
Create Enrollment
       ↓
SUCCESS
```

---

# 8. Step 3 — Reserve activity capacity

Orchestrator now calls Activity Service:

```text
Reserve seat
Activity = 10
SagaId = SAGA-1001
```

Activity Service checks:

```text
Maximum capacity = 30
Current = 29
```

One seat is available.

It changes:

```text
Current = 30
```

and commits its local transaction.

```text
Reserve Seat
     ↓
SUCCESS
```

---

# 9. Step 4 — Calculate fee

Now orchestrator calls Fee Service:

```text
Calculate fee
Student = 501
Activity = 10
SagaId = SAGA-1001
```

Fee Service calculates:

```text
Activity fee = $100
```

and stores it.

```text
Calculate Fee
      ↓
SUCCESS
```

Now the Saga is complete.

```text
Enrollment     ✅
Seat           ✅
Fee            ✅
```

Final state:

```text
Enrollment = Confirmed
Seat = Reserved
Fee = $100
```

---

# 10. Now the important POC — force a failure

This is where the POC becomes useful.

We intentionally configure Fee Service:

```text
FAIL_FEE_SERVICE = true
```

Now run the exact same enrollment.

Flow:

```text
Create Enrollment
       ↓
      ✅
       ↓
Reserve Seat
       ↓
      ✅
       ↓
Calculate Fee
       ↓
      ❌
```

Now the Saga Orchestrator knows:

> Step 3 failed.

---

# 11. What does the Saga do now?

It doesn't execute:

```text
ROLLBACK
```

because there is no global transaction.

Instead, it performs **compensation**.

The orchestrator says:

```text
Fee failed
   ↓
Undo previous business operations
```

---

# 12. Compensation #1 — Release seat

Activity Service receives:

```text
Release seat
Activity = 10
SagaId = SAGA-1001
```

Before:

```text
Capacity = 30 / 30
```

After:

```text
Capacity = 29 / 30
```

So:

```text
Reserve Seat
     ↓
Release Seat
```

---

# 13. Compensation #2 — Cancel enrollment

Now Enrollment Service receives:

```text
Cancel enrollment
EnrollmentId = 1001
SagaId = SAGA-1001
```

Instead of deleting the record, normally we'd maintain the business history and change status:

```text
Pending
   ↓
Cancelled
```

So:

```text
Enrollment = Cancelled
```

---

# 14. Final state after failure

Now check all databases.

### Enrollment DB

```text
Enrollment 1001
Status = Cancelled
```

### Activity DB

```text
Seat = Available
```

### Fee DB

```text
Fee = Not Created
```

That's a valid business state.

So even though the overall operation failed:

> **We didn't leave a half-completed enrollment behind.**

That's the key thing we're proving with the POC.

---

# 15. Now where does the Message Broker come in?

Now we make the POC more realistic.

Instead of every operation being tightly coupled through HTTP, we can use events for asynchronous communication.

For example:

```text
Enrollment Service
       ↓
EnrollmentCreated
       ↓
Message Broker
       ↓
Fee Service
```

The broker could be:

```text
RabbitMQ
```

or:

```text
Azure Service Bus
```

The project architecture specifically uses event-driven communication for operations that don't require an immediate response.

---

# 16. Why do we need Outbox?

Here's another failure scenario.

Suppose Enrollment Service does this:

```text
Save Enrollment
      ↓
Publish Event
```

What if:

```text
Save Enrollment       ✅
Publish Event         ❌
```

Maybe RabbitMQ/Azure Service Bus is temporarily unavailable.

Now:

```text
Enrollment DB
   ↓
Enrollment exists

Message Broker
   ↓
Event never arrived
```

Other services don't know that enrollment was created.

---

# 17. Add Outbox table

We add an Outbox table inside Enrollment DB.

Conceptually:

```text
Enrollment DB
----------------------------

Enrollment
----------------------------
1001 | Student 501 | Football


Outbox
----------------------------
EventId
EventType
Payload
Status
CreatedAt
```

When enrollment is created, we save **both**:

```text
Enrollment
+
EnrollmentCreated event
```

inside the same local database transaction.

So:

```text
BEGIN TRANSACTION

Create Enrollment
       +
Create Outbox Event

COMMIT
```

Now either both succeed or both fail.

That's the important part.

---

# 18. Background publisher

Then we have a background process.

It continuously checks:

```text
Outbox
```

for unpublished events.

For example:

```text
Outbox

EventId = E1001
Status = Pending
```

Publisher picks it up:

```text
Outbox
   ↓
Publish to RabbitMQ
   ↓
SUCCESS
   ↓
Mark event as Published
```

If broker is down:

```text
Outbox
   ↓
Publish
   ↓
FAIL
   ↓
Keep Pending
   ↓
Retry later
```

So the event isn't lost.

The project POC material describes exactly this Outbox concept: store the event with the local transaction, then have a background process publish it with retry handling.

---

# 19. Now another problem — duplicate events

Suppose:

```text
Publisher
   ↓
Publish Event
   ↓
Message Broker receives it ✅
```

But before the publisher knows that it succeeded, there is a network problem.

It retries.

Now the broker may contain:

```text
EnrollmentCreated E1001
EnrollmentCreated E1001
```

Two messages.

Will Fee Service calculate the fee twice?

That's where **idempotency** comes in.

---

# 20. Idempotent consumer

Fee Service receives:

```text
EventId = E1001
```

It checks:

```text
Have I already processed E1001?
```

If:

```text
NO
```

then process it.

And record:

```text
ProcessedEvent
----------------
E1001
```

If the same event arrives again:

```text
E1001
```

Fee Service checks:

```text
Already processed?
```

Answer:

```text
YES
```

So it ignores the duplicate.

That's why:

```text
Outbox      → prevents lost events

Idempotency → handles duplicate events

Saga        → handles business failure
```

The project material explicitly calls out idempotent event handlers to prevent duplicate processing.

---

# 21. What tools would we use in this POC?

A realistic simple POC could look like:

```text
.NET 8
   ↓
ASP.NET Core Web API
   ↓
EF Core
   ↓
SQL Server
```

Messaging:

```text
RabbitMQ
```

or:

```text
Azure Service Bus
```

Local environment:

```text
Docker
```

Testing:

```text
Postman
```

Monitoring/debugging:

```text
Serilog
Application Insights
```

The actual project architecture lists these types of technologies and patterns, although the exact POC implementation technology can vary.

---

# 22. What would we actually test in Postman?

### Test 1 — Successful enrollment

```text
POST /enroll
```

Expected:

```text
Enrollment created
Seat reserved
Fee calculated
Status = Confirmed
```

---

### Test 2 — Fee Service failure

Configure:

```text
Fee Service = unavailable
```

Call:

```text
POST /enroll
```

Expected:

```text
Enrollment created       ✅
Seat reserved            ✅
Fee calculation          ❌
       ↓
Release seat             ✅
Cancel enrollment        ✅
```

Final:

```text
Enrollment = Cancelled
Seat = Available
Fee = Not Created
```

---

### Test 3 — Message broker failure

Stop RabbitMQ.

Then:

```text
Create Enrollment
```

Expected:

```text
Enrollment DB
     ↓
Enrollment created

Outbox
     ↓
Event stored as Pending
```

Start RabbitMQ again.

Publisher retries:

```text
Pending event
     ↓
RabbitMQ
     ↓
SUCCESS
```

---

### Test 4 — Duplicate event

Send the same event twice:

```text
E1001
E1001
```

Expected:

```text
First E1001
   ↓
Process

Second E1001
   ↓
Already processed
   ↓
Ignore
```

No duplicate fee.

---

# 23. The complete POC picture

This is the mental model I want you to remember:

```text
                         Client
                           |
                           ↓
                  Saga Orchestrator
                           |
             ┌─────────────┼─────────────┐
             ↓             ↓             ↓
       Enrollment       Activity         Fee
        Service          Service        Service
             |             |              |
             ↓             ↓              ↓
        Enrollment      Activity         Fee
             DB             DB             DB
             |
             ↓
          Outbox
             |
             ↓
      Message Broker
             |
       ┌─────┴─────┐
       ↓           ↓
 Activity        Fee
 Service        Service
```

And the failure path:

```text
Enrollment
    ↓
   ✅
    ↓
Activity
    ↓
   ✅
    ↓
Fee
    ↓
   ❌
    |
    ↓
Saga Compensation
    |
    ├── Release Activity Seat
    |
    └── Cancel Enrollment
```

---

# 24. What is the actual problem each pattern solves?

This is the **most important part to memorize**:

| Problem                                                      | Pattern                        |
| ------------------------------------------------------------ | ------------------------------ |
| Multiple databases cannot share one transaction              | **Saga**                       |
| Previous successful operations need to be reversed           | **Compensating Transaction**   |
| Event could be lost between DB update and message publishing | **Outbox**                     |
| Same event could arrive multiple times                       | **Idempotency**                |
| Services shouldn't be tightly coupled                        | **Event-driven communication** |
| Need to coordinate multiple steps                            | **Saga Orchestrator**          |

### One-line mental model

> **Saga manages the workflow, compensation handles failure, Outbox makes events reliable, and idempotency makes retries safe.**

That's the complete story.
