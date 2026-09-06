
## 1. Azure API Management — APIM

### Must know

- What is APIM and why did you use it?
- APIM vs API Gateway
- How does request flow through APIM?
- APIM policies
- Inbound / backend / outbound / on-error policies
- Authentication & authorization
- JWT validation in APIM
- Subscription keys
- Rate limiting / throttling
- Request/response transformation
- Backend configuration
- Versioning
- Revisions vs versions
- CORS
- Named Values
- How APIM connects to backend APIs
- How to troubleshoot a **401 / 403 / 404 / 429 / 500** through APIM

### Scenario questions

> Client is getting 401 through APIM. How do you troubleshoot?

> API works directly but fails through APIM. What do you check?

> How would you prevent a client from sending too many requests?

> Where would you store APIM configuration/secrets?

---

# 2. Azure Service Bus

This is one of the areas I'd prepare **deeply**.

### Must know

- What is Azure Service Bus?
- Queue vs Topic
- Subscription
- Sender vs Receiver
- Message lifecycle
- Peek vs Receive
- Complete
- Abandon
- Dead-letter queue
- Message lock
- Lock renewal
- Retry
- Duplicate messages
- Duplicate detection
- Sessions
- Ordering
- TTL
- Message size
- Max delivery count
- Dead-lettering
- Competing consumers
- At-least-once delivery

### Very important scenarios

> What happens if your Function receives a message but crashes before completing it?

> What happens when the message lock expires?

> Why can the same message be processed twice?

> How do you prevent duplicate processing?

> What happens to a message after maximum delivery attempts?

> Queue vs Topic — when would you use each?

> How would you troubleshoot messages stuck in the DLQ?

### Be able to explain this flow

**API → Service Bus Queue → Azure Function → Database**

And:

**Publisher → Topic → Subscription A / Subscription B → Consumers**

---

# 3. Azure Functions

This is another **high-priority area** for you.

### Must know

- What is Azure Function?
- Function App vs Function
- Why use Functions instead of Web API?
- HTTP trigger
- Service Bus trigger
- Timer trigger
- Blob trigger
- Queue trigger
- How does a Function get triggered?
- Bindings
- Input/output bindings
- Dependency Injection
- Configuration
- Application settings
- Key Vault integration
- Logging
- Scaling
- Cold start
- Consumption vs Premium vs Dedicated
- Timeout
- Retry behavior
- Durable Functions — basic understanding

### Very likely project questions

> How does your Service Bus trigger Function get triggered?

> Why did you use Azure Function instead of an API?

> What happens if your Function fails while processing a Service Bus message?

> How do you handle retries?

> How do you prevent duplicate processing?

> How do you configure connection strings?

> How do you monitor a Function in production?

> How does Azure Functions scale?

---

# 4. Azure Key Vault

Don't just say:

> "We use Key Vault to store secrets."

Know the complete flow.

### Must know

- Why Key Vault?
- Secrets
- Keys
- Certificates
- Managed Identity
- Access policies vs Azure RBAC
- How application accesses Key Vault
- How to avoid storing secrets in code
- How to rotate secrets
- Environment-specific configuration

### Very important scenario

> Your API needs a database connection string. How would you securely configure it?

Be able to explain:

**Application → Managed Identity → Key Vault → Secret**

And understand that ideally **you don't put the Key Vault password inside your application**. Managed Identity allows Azure resources to authenticate without embedding credentials.

---

# 5. Application Insights

Prepare this from a **production troubleshooting perspective**.

### Must know

- What is Application Insights?
- Logs
- Requests
- Dependencies
- Exceptions
- Traces
- Performance
- Availability
- Application Map
- Correlation IDs
- Distributed tracing
- KQL basics

### KQL is important

Know basic queries such as:

```kusto
requests
| where success == false
| order by timestamp desc
```

And:

```kusto
exceptions
| order by timestamp desc
```

Also understand:

```text
Client
   ↓
APIM
   ↓
API
   ↓
Service Bus
   ↓
Function
   ↓
SQL
```

How would you identify **where the failure occurred?**

That's a very good interview scenario.

---

# 6. Integration between all five services

This is where you can really stand out.

Prepare one complete architecture from **your project**.

For example:

```text
Client
   |
   v
APIM
   |
   v
.NET Web API
   |
   +------> Azure SQL
   |
   +------> Service Bus
                 |
                 v
           Azure Function
                 |
                 v
              SQL / External API

        Key Vault
             |
             v
   Secrets / Configuration

Application Insights
             |
             v
   API + Function + Dependencies
```

You should be able to explain:

**"What happens from the moment the client sends the request until the complete business operation finishes?"**

Then explain **why each Azure service exists**.

---

# 7. Prepare failure scenarios

This is probably the **most valuable preparation**.

Practice:

### APIM

- 401
- 403
- 404
- 429
- 500

### API

- API timeout
- External API unavailable
- SQL timeout
- Invalid configuration

### Service Bus

- Duplicate message
- Lock expired
- Message processing failure
- DLQ
- Poison message
- Retry

### Function

- Function failure
- Timeout
- Cold start
- Scaling
- Trigger not firing

### Key Vault

- Secret not found
- Permission denied
- Managed Identity failure
- Secret rotation

### Application Insights

- Finding exceptions
- Finding slow APIs
- Finding dependency failures
- Tracing one request across services

---

# 8. Questions connecting Azure + .NET

These are especially important for your profile.

Prepare:

- How does .NET API authenticate with Azure services?
- How does DI work in Azure Functions?
- How do you configure Azure services in .NET?
- `IConfiguration` usage
- Options pattern
- Managed Identity
- `DefaultAzureCredential`
- Azure SDK
- Retry policies
- Timeout
- Circuit Breaker
- Idempotency
- Logging
- Exception handling
- Health checks

---

# 9. Don't forget security

Prepare:

**Authentication**

- JWT
- OAuth 2.0 basics
- Managed Identity

**Authorization**

- Roles/permissions
- APIM policies
- Azure RBAC

**Secrets**

- Key Vault

**Network**

- Private endpoints — basic understanding
- VNet integration — basic understanding
- Firewall restrictions

---

# 10. Your highest-priority questions

If you have limited time, I'd make sure you can confidently answer these **20 questions**:

1. Why did you use APIM?
2. How does APIM request flow work?
3. What APIM policies have you used?
4. How do you troubleshoot 401/403/429/500 in APIM?
5. Why did you use Service Bus?
6. Queue vs Topic?
7. What happens when message processing fails?
8. What is DLQ and why does a message go there?
9. How do you handle duplicate messages?
10. What is message lock?
11. Why Azure Function instead of Web API?
12. How does your Function get triggered?
13. What happens when a Function fails?
14. How does Azure Function scale?
15. How do you configure secrets in your application?
16. How does Key Vault authentication work?
17. What is Managed Identity?
18. How do you troubleshoot production errors using Application Insights?
19. How do you trace a request across API → Service Bus → Function?
20. Explain your **complete project architecture and why each Azure service was chosen.**

### One important interview strategy

For every Azure service, prepare these **6 answers**:

**What is it?**
→ **Why did we use it?**
→ **How does it work?**
→ **How did I use it in my project?**
→ **What happens when it fails?**
→ **How do I troubleshoot it?**

If you can answer those six for **APIM + Service Bus + Functions + Key Vault + Application Insights**, you'll be much more prepared than someone who has memorized Azure definitions.
