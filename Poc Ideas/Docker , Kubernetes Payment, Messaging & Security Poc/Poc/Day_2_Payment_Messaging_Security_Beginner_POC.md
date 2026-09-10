# Day 2 --- Beginner POC: Payment → Messaging → Idempotency → Reconciliation → Security

## Goal for Day 2

Today we will extend yesterday's simple API into a **small
payment-processing POC**.

We are NOT building a real payment system.

We are building a learning project so you can understand the concepts
that were missing in your interview.

By the end:

``` text
Client
  ↓
Payment API
  ↓
Idempotency
  ↓
Payment stored
  ↓
Message
  ↓
Background Worker
  ↓
Reconciliation
```

Then we will learn the security concepts:

``` text
Client
  ↓
JWT
  ↓
API
  ↓
Managed Identity concept
  ↓
Key Vault concept
```

For the security section, we will focus on understanding the
architecture rather than spending the whole day setting up Azure
infrastructure.

------------------------------------------------------------------------

# 0. Before starting

Make sure Day 1 works.

Run:

``` powershell
kubectl get pods
kubectl get deployments
kubectl get services
```

Your API should be available.

If Day 1 is not working, fix Day 1 first.

Do not build on a broken foundation.

------------------------------------------------------------------------

# 1. Task 1 --- Create a Payment model

Go into:

``` text
Payment.Api
```

Create a folder:

``` text
Models
```

Create:

``` text
Models/Payment.cs
```

Add:

``` csharp
namespace Payment.Api.Models;

public class Payment
{
    public Guid PaymentId { get; set; }

    public string IdempotencyKey { get; set; } = string.Empty;

    public decimal Amount { get; set; }

    public string Currency { get; set; } = "INR";

    public string Status { get; set; } = "PENDING";

    public DateTime CreatedAt { get; set; }
}
```

------------------------------------------------------------------------

# 2. Understand the model

A payment has:

``` text
PaymentId
    ↓
Which payment?

IdempotencyKey
    ↓
Which client request?

Amount
    ↓
How much?

Currency
    ↓
INR

Status
    ↓
PENDING / SUCCESS / FAILED

CreatedAt
    ↓
When created?
```

Do not worry about Entity Framework yet.

We will initially use an in-memory collection.

------------------------------------------------------------------------

# 3. Task 2 --- Create a payment request model

Create:

``` text
Models/CreatePaymentRequest.cs
```

Add:

``` csharp
namespace Payment.Api.Models;

public class CreatePaymentRequest
{
    public decimal Amount { get; set; }

    public string Currency { get; set; } = "INR";
}
```

------------------------------------------------------------------------

# 4. Task 3 --- Create an in-memory payment store

For learning purposes, we will temporarily store payments in memory.

Create:

``` text
PaymentStore.cs
```

Add:

``` csharp
using Payment.Api.Models;

namespace Payment.Api;

public static class PaymentStore
{
    public static List<Payment> Payments { get; } = new();
}
```

This is intentionally simple.

In a real production application, we would normally use a database.

------------------------------------------------------------------------

# 5. Task 4 --- Create POST /payments

Open:

``` text
Program.cs
```

Add:

``` csharp
using Payment.Api.Models;
```

Then add this endpoint before `app.Run()`:

``` csharp
app.MapPost("/payments", (CreatePaymentRequest request, HttpRequest httpRequest) =>
{
    var idempotencyKey = httpRequest.Headers["Idempotency-Key"].FirstOrDefault();

    if (string.IsNullOrWhiteSpace(idempotencyKey))
    {
        return Results.BadRequest(new
        {
            message = "Idempotency-Key header is required."
        });
    }

    var existingPayment = PaymentStore.Payments
        .FirstOrDefault(x => x.IdempotencyKey == idempotencyKey);

    if (existingPayment is not null)
    {
        return Results.Ok(existingPayment);
    }

    var payment = new Payment
    {
        PaymentId = Guid.NewGuid(),
        IdempotencyKey = idempotencyKey,
        Amount = request.Amount,
        Currency = request.Currency,
        Status = "SUCCESS",
        CreatedAt = DateTime.UtcNow
    };

    PaymentStore.Payments.Add(payment);

    return Results.Ok(payment);
});
```

------------------------------------------------------------------------

# 6. Run the API

Run:

``` powershell
dotnet run
```

Use Postman.

Send:

``` text
POST /payments
```

Body:

``` json
{
  "amount": 1000,
  "currency": "INR"
}
```

Add header:

``` text
Idempotency-Key: PAYMENT-001
```

You should receive something like:

``` json
{
  "paymentId": "some-guid",
  "idempotencyKey": "PAYMENT-001",
  "amount": 1000,
  "currency": "INR",
  "status": "SUCCESS"
}
```

------------------------------------------------------------------------

# 7. Task 5 --- Test duplicate payment

This is VERY important.

Send the exact same request again:

``` text
POST /payments
```

with:

``` text
Idempotency-Key: PAYMENT-001
```

You should get the existing payment.

You should NOT get a new PaymentId.

------------------------------------------------------------------------

# 8. Understand idempotency

Suppose a customer clicks Pay twice.

Without idempotency:

``` text
Request 1 → Payment ₹1000
Request 2 → Payment ₹1000
```

Customer gets charged twice.

With idempotency:

``` text
Request 1 → PAYMENT-001 → Create
Request 2 → PAYMENT-001 → Existing payment
```

So:

> **Idempotency means processing the same request repeatedly does not
> create multiple effects.**

------------------------------------------------------------------------

# 9. Interview question

Answer aloud:

> How would you prevent duplicate payments?

Good beginner answer:

> I would require an idempotency key from the client. I would store it
> with the payment and ensure it is unique. If the same key is received
> again, I return the existing payment result instead of creating
> another payment.

------------------------------------------------------------------------

# 10. Important production improvement

Our POC currently has:

``` csharp
List<Payment>
```

This is NOT production-safe.

Why?

Because:

``` text
Application restart
       ↓
Memory disappears
```

And multiple application instances could each have different lists.

In production we would use a database and enforce uniqueness.

For example:

``` text
Payments
----------------
PaymentId
IdempotencyKey UNIQUE
Amount
Status
CreatedAt
```

This database-level uniqueness is important because two requests can
arrive at exactly the same time.

------------------------------------------------------------------------

# 11. Task 6 --- Create a payment event

Create:

``` text
Models/PaymentCreatedEvent.cs
```

Add:

``` csharp
namespace Payment.Api.Models;

public class PaymentCreatedEvent
{
    public Guid PaymentId { get; set; }

    public decimal Amount { get; set; }

    public string Currency { get; set; } = "INR";

    public DateTime CreatedAt { get; set; }
}
```

This represents a message that another component can process.

------------------------------------------------------------------------

# 12. Understand messaging

Imagine:

``` text
Payment API
     ↓
"Payment created"
     ↓
Queue
     ↓
Worker
```

The API doesn't need to directly call every downstream system.

A message queue allows work to happen asynchronously.

Simple idea:

> **API creates the payment; background processing can happen
> separately.**

------------------------------------------------------------------------

# 13. Task 7 --- Build a tiny in-memory message queue

For this beginner POC, don't install Azure Service Bus yet.

Create:

``` text
MessageQueue.cs
```

Add:

``` csharp
using System.Collections.Concurrent;
using Payment.Api.Models;

namespace Payment.Api;

public static class MessageQueue
{
    public static ConcurrentQueue<PaymentCreatedEvent> Messages { get; } = new();
}
```

------------------------------------------------------------------------

# 14. Put a message into the queue

Modify the payment endpoint.

After:

``` csharp
PaymentStore.Payments.Add(payment);
```

add:

``` csharp
MessageQueue.Messages.Enqueue(new PaymentCreatedEvent
{
    PaymentId = payment.PaymentId,
    Amount = payment.Amount,
    Currency = payment.Currency,
    CreatedAt = payment.CreatedAt
});
```

Now:

``` text
POST /payments
      ↓
Create payment
      ↓
Store payment
      ↓
Put event into queue
```

------------------------------------------------------------------------

# 15. Task 8 --- Create a worker

Create:

``` text
PaymentWorker.cs
```

Add:

``` csharp
using Microsoft.Extensions.Hosting;

namespace Payment.Api;

public class PaymentWorker : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            while (MessageQueue.Messages.TryDequeue(out var message))
            {
                Console.WriteLine(
                    $"Processing PaymentId: {message.PaymentId}, Amount: {message.Amount}");
            }

            await Task.Delay(1000, stoppingToken);
        }
    }
}
```

------------------------------------------------------------------------

# 16. Register the worker

In `Program.cs`, before:

``` csharp
var app = builder.Build();
```

add:

``` csharp
builder.Services.AddHostedService<PaymentWorker>();
```

So the beginning becomes:

``` csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHostedService<PaymentWorker>();

var app = builder.Build();
```

------------------------------------------------------------------------

# 17. Run and test

Run:

``` powershell
dotnet run
```

Create a payment.

Look at the terminal.

You should see:

``` text
Processing PaymentId: ...
Amount: 1000
```

You have now created a tiny asynchronous flow.

------------------------------------------------------------------------

# 18. Understand what you just built

``` text
POST /payments
       │
       ▼
Payment API
       │
       ├── Save payment
       │
       └── Queue event
                │
                ▼
          Background Worker
```

This is the basic idea behind many messaging architectures.

------------------------------------------------------------------------

# 19. Task 9 --- Duplicate messages

Now manually enqueue the same event twice.

For learning, add this temporary endpoint:

``` csharp
app.MapPost("/test/duplicate-message", () =>
{
    var paymentId = Guid.NewGuid();

    var message = new PaymentCreatedEvent
    {
        PaymentId = paymentId,
        Amount = 1000,
        Currency = "INR",
        CreatedAt = DateTime.UtcNow
    };

    MessageQueue.Messages.Enqueue(message);
    MessageQueue.Messages.Enqueue(message);

    return Results.Ok(new
    {
        message = "Duplicate messages added",
        paymentId
    });
});
```

Call:

``` text
POST /test/duplicate-message
```

You should see the worker process the same PaymentId twice.

------------------------------------------------------------------------

# 20. Why is that a problem?

Imagine the worker sends money.

``` text
Message
   ↓
Worker
   ↓
Charge customer
```

If the same message arrives twice:

``` text
Message 1 → Charge ₹1000
Message 2 → Charge ₹1000 again ❌
```

Therefore the consumer must be idempotent too.

------------------------------------------------------------------------

# 21. Task 10 --- Make the consumer idempotent

Create:

``` text
ProcessedPayments.cs
```

Add:

``` csharp
using System.Collections.Concurrent;

namespace Payment.Api;

public static class ProcessedPayments
{
    public static ConcurrentDictionary<Guid, bool> PaymentIds { get; } = new();
}
```

Now change the worker:

``` csharp
using Microsoft.Extensions.Hosting;

namespace Payment.Api;

public class PaymentWorker : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            while (MessageQueue.Messages.TryDequeue(out var message))
            {
                if (!ProcessedPayments.PaymentIds.TryAdd(message.PaymentId, true))
                {
                    Console.WriteLine(
                        $"Duplicate message ignored for PaymentId: {message.PaymentId}");

                    continue;
                }

                Console.WriteLine(
                    $"Processing PaymentId: {message.PaymentId}, Amount: {message.Amount}");
            }

            await Task.Delay(1000, stoppingToken);
        }
    }
}
```

------------------------------------------------------------------------

# 22. Test again

Run the duplicate-message endpoint.

Now you should see:

``` text
Processing PaymentId: ...
Duplicate message ignored for PaymentId: ...
```

You have demonstrated:

> **Idempotent message consumption.**

------------------------------------------------------------------------

# 23. Interview question

Answer:

> What happens if the same message is delivered twice?

Good answer:

> Message delivery can result in duplicate messages, so the consumer
> should be idempotent. I would use a unique business/message ID and
> record processed IDs so the same business operation is not performed
> twice.

------------------------------------------------------------------------

# 24. Task 11 --- Understand reconciliation

Now imagine our system says:

``` text
Payment 100 → ₹1000
Payment 101 → ₹2000
Payment 102 → ₹500
```

But the payment gateway says:

``` text
Payment 100 → ₹1000
Payment 101 → ₹2500
Payment 103 → ₹700
```

We need to compare them.

``` text
Payment 100
Our system: ₹1000
Gateway:    ₹1000
Result: MATCH

Payment 101
Our system: ₹2000
Gateway:    ₹2500
Result: AMOUNT MISMATCH

Payment 102
Our system: ₹500
Gateway:    Missing
Result: MISSING FROM GATEWAY

Payment 103
Our system: Missing
Gateway:    ₹700
Result: MISSING FROM OUR SYSTEM
```

This is reconciliation.

------------------------------------------------------------------------

# 25. Task 12 --- Create reconciliation models

Create:

``` text
Models/SettlementRecord.cs
```

``` csharp
namespace Payment.Api.Models;

public class SettlementRecord
{
    public Guid PaymentId { get; set; }

    public decimal Amount { get; set; }
}
```

Create:

``` text
Models/ReconciliationResult.cs
```

``` csharp
namespace Payment.Api.Models;

public class ReconciliationResult
{
    public Guid PaymentId { get; set; }

    public decimal? OurAmount { get; set; }

    public decimal? GatewayAmount { get; set; }

    public string Result { get; set; } = string.Empty;
}
```

------------------------------------------------------------------------

# 26. Task 13 --- Create sample gateway settlement data

Create:

``` text
SettlementStore.cs
```

``` csharp
using Payment.Api.Models;

namespace Payment.Api;

public static class SettlementStore
{
    public static List<SettlementRecord> Records { get; } = new();
}
```

Add this temporary endpoint:

``` csharp
app.MapPost("/test/seed-settlement", () =>
{
    SettlementStore.Records.Clear();

    SettlementStore.Records.AddRange(new[]
    {
        new SettlementRecord
        {
            PaymentId = Guid.Parse("11111111-1111-1111-1111-111111111111"),
            Amount = 1000
        },
        new SettlementRecord
        {
            PaymentId = Guid.Parse("22222222-2222-2222-2222-222222222222"),
            Amount = 2500
        }
    });

    return Results.Ok(SettlementStore.Records);
});
```

------------------------------------------------------------------------

# 27. Task 14 --- Build a simple reconciliation endpoint

Add:

``` csharp
app.MapGet("/reconciliation", () =>
{
    var paymentIds = PaymentStore.Payments
        .Select(x => x.PaymentId)
        .Union(SettlementStore.Records.Select(x => x.PaymentId))
        .Distinct();

    var results = new List<ReconciliationResult>();

    foreach (var paymentId in paymentIds)
    {
        var payment = PaymentStore.Payments
            .FirstOrDefault(x => x.PaymentId == paymentId);

        var settlement = SettlementStore.Records
            .FirstOrDefault(x => x.PaymentId == paymentId);

        string result;

        if (payment is null)
        {
            result = "MISSING_FROM_OUR_SYSTEM";
        }
        else if (settlement is null)
        {
            result = "MISSING_FROM_GATEWAY";
        }
        else if (payment.Amount != settlement.Amount)
        {
            result = "AMOUNT_MISMATCH";
        }
        else
        {
            result = "MATCH";
        }

        results.Add(new ReconciliationResult
        {
            PaymentId = paymentId,
            OurAmount = payment?.Amount,
            GatewayAmount = settlement?.Amount,
            Result = result
        });
    }

    return Results.Ok(results);
});
```

------------------------------------------------------------------------

# 28. Test reconciliation

Create some payments.

Seed settlement:

``` text
POST /test/seed-settlement
```

Then:

``` text
GET /reconciliation
```

Look at the results.

You should see statuses such as:

``` text
MATCH
AMOUNT_MISMATCH
MISSING_FROM_GATEWAY
```

------------------------------------------------------------------------

# 29. Understand finance-grade reconciliation

A real system would need much more.

Remember these words:

``` text
Matching
Exceptions
Audit trail
Reversals
Idempotency
Settlement
```

For your interview, explain:

> "Reconciliation compares our transaction records with the external
> gateway or settlement records. We identify matched transactions and
> exceptions such as missing records, amount mismatches, duplicates and
> reversals. Exceptions are retained for investigation and the process
> needs an audit trail."

That is much stronger than:

> "We compare two tables."

------------------------------------------------------------------------

# 30. Task 15 --- Learn authentication

Now stop coding for 15 minutes.

Understand this:

``` text
Authentication
       ↓
Who are you?

Authorization
       ↓
What are you allowed to do?
```

Example:

``` text
User logs in
    ↓
Identity provider
    ↓
JWT
    ↓
Payment API
```

The JWT contains claims about the caller.

The API can use those claims to decide what the caller can access.

------------------------------------------------------------------------

# 31. Task 16 --- Understand JWT

A JWT conceptually contains:

``` text
HEADER
PAYLOAD
SIGNATURE
```

Important claims include:

``` text
iss  → issuer
aud  → audience
exp  → expiration
scope → permissions
roles → roles
```

Do not implement a complete identity provider today.

Your goal is to be able to explain the flow.

------------------------------------------------------------------------

# 32. Interview question

> What is the difference between authentication and authorization?

Answer:

> Authentication verifies who the caller is. Authorization determines
> what that authenticated caller is allowed to do.

------------------------------------------------------------------------

# 33. Task 17 --- Understand Managed Identity

This was specifically mentioned as a gap in your feedback.

Imagine your API needs to access an Azure resource.

Bad design:

``` text
API
 ↓
username/password
 ↓
Azure resource
```

The credential has to be stored somewhere.

Better Azure design:

``` text
API
 ↓
Managed Identity
 ↓
Azure RBAC
 ↓
Azure resource
```

The application gets an identity from Azure.

You then grant that identity only the permissions it needs.

------------------------------------------------------------------------

# 34. Remember this interview answer

> "I prefer Managed Identity for Azure-to-Azure communication because it
> avoids storing long-lived credentials in application configuration. I
> assign the application's identity the minimum RBAC permissions
> required for the target resource."

That is enough for your current level.

------------------------------------------------------------------------

# 35. Task 18 --- Understand Key Vault

Think:

``` text
Key Vault
    │
    ├── Secrets
    ├── Keys
    └── Certificates
```

Application:

``` text
Payment API
     ↓
Managed Identity
     ↓
Key Vault
     ↓
Secret
```

Do NOT put:

``` text
password=MyPassword123
```

inside:

``` text
appsettings.json
```

or source control.

------------------------------------------------------------------------

# 36. Interview question

> How would you securely store secrets in Azure?

Answer:

> I would use Azure Key Vault rather than storing secrets in source code
> or plain configuration. The application can use Managed Identity and
> RBAC to access only the secrets it needs.

------------------------------------------------------------------------

# 37. Task 19 --- Think about Kubernetes security

You already learned:

``` text
Docker
Kubernetes
Deployment
Service
Probes
```

Now connect security:

``` text
Client
  ↓
JWT
  ↓
API Gateway / APIM
  ↓
Payment API
  ↓
Managed Identity
  ↓
Azure resource
```

For a production architecture, you would also consider:

``` text
TLS
Network restrictions
RBAC
Secrets
Logging
Audit
Least privilege
```

You don't need to implement all of these in this 2-day beginner POC.

------------------------------------------------------------------------

# 38. Task 20 --- Practice one production incident

Imagine:

``` text
10:00
New Payment API version deployed.

10:05
Payment failures increase.

10:07
Customers report failed payments.
```

What do you do?

Write your answer before reading below.

A reasonable Lead-level sequence:

``` text
1. Confirm the incident.
2. Understand customer/business impact.
3. Stop further rollout.
4. Check monitoring and logs.
5. Decide whether rollback or fix-forward is safer.
6. Communicate status to stakeholders.
7. Restore service.
8. Verify payment success and reconciliation.
9. Investigate root cause.
10. Create preventive actions.
```

------------------------------------------------------------------------

# 39. Understand rollback

Suppose:

``` text
Version 1 → Working

Version 2 → Payment failures
```

If the problem is serious and the previous version is known to be safe:

``` text
Version 2
   ↓
ROLLBACK
   ↓
Version 1
```

As a Lead, don't say:

> "I would always rollback."

Say:

> "I would assess impact, rollback safety, data compatibility and
> whether a fix-forward is faster and safer. For a high-severity payment
> failure with a known-good previous version, rollback may be the
> fastest way to restore service."

That demonstrates decision-making.

------------------------------------------------------------------------

# 40. Task 21 --- Learn 30/60/90

Remember only:

``` text
30 = LEARN
60 = IMPROVE
90 = OWN
```

## First 30 days

I would:

-   understand the architecture
-   understand the business domain
-   understand deployment
-   review production incidents
-   understand team responsibilities
-   identify major technical risks

## 60 days

I would:

-   address high-priority technical risks
-   improve observability/reliability
-   establish useful engineering standards
-   identify deployment improvements
-   mentor engineers

## 90 days

I would:

-   own a major technical initiative
-   establish measurable outcomes
-   influence architecture decisions
-   create a longer-term technical roadmap

------------------------------------------------------------------------

# 41. Task 22 --- Your most important exercise

Take one real project from your resume.

Write:

``` text
Project:
Problem:

What did we build?

What did I personally do?

What technical decision did I make?

What alternatives did I consider?

Why did I choose my approach?

What production problem happened?

How did I investigate it?

What decision did I make during the incident?

What was the result?
```

Do NOT invent achievements.

Use real experience.

------------------------------------------------------------------------

# 42. Change your interview answer style

Your previous interview appears to have demonstrated good implementation
knowledge.

Now add ownership.

Instead of:

> "We used Azure Functions."

Say:

> "We had a long-running batch workload. I chose Durable Functions
> because the workflow required orchestration and reliable state
> management. I also considered retry behavior and idempotency because
> individual activities could be retried."

Instead of:

> "We used Kubernetes."

Say:

> "We used Kubernetes to run multiple replicas and provide controlled
> deployments. I would use readiness probes to prevent traffic from
> reaching an instance that isn't ready and liveness probes to allow
> unhealthy instances to be restarted."

Instead of:

> "We use JWT."

Say:

> "I would validate the JWT at the gateway/API boundary and then use
> scopes or roles for authorization. For Azure resource access, I would
> avoid application secrets and prefer Managed Identity with
> least-privilege RBAC."

------------------------------------------------------------------------

# 43. Final Day 2 interview test

Answer these without looking at notes.

## Kubernetes

1.  What is Docker?
2.  Image vs container?
3.  Why Kubernetes?
4.  What is a Pod?
5.  What is a Deployment?
6.  What is a Service?
7.  Readiness vs liveness?
8.  What happens if a Pod crashes?

## Payments

9.  What is idempotency?
10. How do you prevent duplicate payments?
11. What happens if a message arrives twice?
12. What is reconciliation?
13. How would you handle an amount mismatch?

## Security

14. Authentication vs authorization?
15. What is JWT?
16. Why Managed Identity?
17. Why Key Vault?
18. What is least privilege?

## Leadership

19. When would you rollback?
20. What would you do during a production incident?
21. What would your first 30/60/90 days look like?
22. Tell me about a technical decision you personally owned.

------------------------------------------------------------------------

# 44. Final architecture you should be able to draw

At the end of these two days, draw this on paper from memory:

``` text
                    Client
                      │
                      │ JWT
                      ▼
               ┌─────────────┐
               │    APIM     │
               └──────┬──────┘
                      │
                      ▼
             ┌────────────────┐
             │  Payment API   │
             │     .NET       │
             └───────┬────────┘
                     │
              Idempotency
                     │
                     ▼
                Payment DB
                     │
                     ▼
                  Message
                     │
                     ▼
              Message Queue
                     │
                     ▼
             Background Worker
                     │
                     ▼
              Reconciliation
                     │
                     ▼
             Settlement Data


Kubernetes:

Deployment
    │
    ├── Pod 1
    │     └── Payment API
    │
    └── Pod 2
          └── Payment API

Service
    │
    ├── Pod 1
    └── Pod 2

Pods:
    ├── Readiness probe
    └── Liveness probe


Azure security concept:

Payment API
    │
    ▼
Managed Identity
    │
    ▼
Key Vault / Azure resources
```

------------------------------------------------------------------------

# 45. Your 2-day success criteria

You do NOT need to become an expert.

You succeed if you can say:

> "I built a small .NET payment API, containerized it with Docker,
> deployed it to Kubernetes with two replicas, exposed it using a
> Service, and configured readiness and liveness probes. I added
> idempotency to prevent duplicate payment requests, asynchronous
> processing through a queue/worker, duplicate-message protection, and a
> simple reconciliation process. For production Azure security, I would
> use JWT/Entra ID for authentication, Managed Identity for Azure
> resource access, Key Vault for secrets, and least-privilege RBAC."

That is a **much stronger interview story** than simply memorizing
Kubernetes or payment definitions.

------------------------------------------------------------------------

# Important rule for our next session

Do **not** jump to Task 2 after reading Task 1.

Work like this:

``` text
Task 1
  ↓
Do it yourself
  ↓
Run it
  ↓
Something doesn't work?
  ↓
Ask me
  ↓
Fix it
  ↓
Explain it back to me
  ↓
Then Task 2
```

When you are ready, come back and say:

> **"Day 1 Task 1"**

I will walk you through **only that tiny task**, step by step, and wait
for your result before moving forward.
