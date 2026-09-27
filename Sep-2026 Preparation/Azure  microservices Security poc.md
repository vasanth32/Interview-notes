## Final POC you will build

```text
                         ┌──────────────────┐
                         │    Angular UI    │
                         └────────┬─────────┘
                                  │
                           Login / OAuth
                                  │
                                  ▼
                         ┌──────────────────┐
                         │ Microsoft Entra  │
                         │       ID         │
                         └────────┬─────────┘
                                  │
                              JWT token
                                  │
                                  ▼
                         ┌──────────────────┐
                         │   Azure APIM     │
                         │                  │
                         │ JWT validation   │
                         │ CORS             │
                         │ Rate limiting    │
                         └────────┬─────────┘
                                  │
                     ┌────────────┴────────────┐
                     ▼                         ▼
              OrderService              CustomerService
               .NET API                  .NET API
                     │
                     │ Managed Identity
                     ▼
               ┌─────────────┐
               │  Key Vault  │
               └─────────────┘
                     │
                     ▼
                  Secret
```

Later, you'll add:

```text
OrderService → CustomerService
       │
       └── Service-to-service authentication
             using Managed Identity
```

And Application Insights for troubleshooting.

---

# How we'll use GitHub Copilot

Don't ask Copilot:

> "Build the entire POC."

That defeats the learning purpose.

Instead, give Copilot **small prompts phase by phase**, inspect what it creates, run it, break it, and understand it.

For every phase I'll give you:

1. **What you're learning**
2. **Manual Azure work**
3. **Copilot prompt**
4. **What you should understand**
5. **Interview questions**
6. **Hands-on test**

---

# PHASE 0 — Setup

### Goal

Get your local environment ready.

You need:

- Visual Studio / VS Code
- .NET 10 SDK
- Node.js
- Angular CLI
- Git
- GitHub Copilot
- Azure account/subscription
- Azure CLI

Don't create Azure resources yet.

---

## Copilot Prompt 0

Paste this into GitHub Copilot Chat:

I am building a small learning project called AzureMicroservicesSecurityPOC.

The purpose is to learn Azure microservices security for a .NET full-stack interview.

Technology:

- .NET 10
- ASP.NET Core Web API
- Angular
- Microsoft Entra ID
- Azure API Management
- Azure Key Vault
- Managed Identity
- Application Insights
- Azure SQL later

For now, do NOT create Azure resources and do NOT add authentication.

Create a clean solution structure for two small microservices:

1. OrderService
2. CustomerService

Each should be an independent ASP.NET Core Web API.

Keep the implementation extremely simple.

OrderService:

- GET /api/orders
- GET /api/orders/{id}
- POST /api/orders

CustomerService:

- GET /api/customers
- GET /api/customers/{id}

Use in-memory data initially.

Use clean, readable code suitable for a beginner learning microservices.

Do not introduce unnecessary design patterns, repositories, databases, Docker, Kubernetes, or authentication yet.

After creating the code, explain:

1. Project structure
2. How the two services are independent
3. How I can run both services locally
4. Which ports each service uses
5. How to test each API with Swagger
6. Why we are intentionally keeping authentication out of this phase.

### Your task

Run both APIs.

You should be able to do:

```text
Order API
https://localhost:xxxx/swagger

Customer API
https://localhost:yyyy/swagger
```

Don't proceed until both work.

---

# PHASE 1 — Understand authentication

Now we're going to introduce **Microsoft Entra ID**.

But first understand the flow.

```text
User
 ↓
Angular
 ↓
Entra ID
 ↓
Access Token
 ↓
API
```

At this stage, you can initially protect **one API directly**, before introducing APIM.

This makes the authentication concept much easier.

---

# Manual Azure Work — Create Entra App Registration

Go to Azure Portal.

Search:

**Microsoft Entra ID**

Then:

**App registrations → New registration**

Create:

```text
Name:
AzureSecurityPOC-OrderAPI
```

For supported account types, for a learning project use:

**Accounts in this organizational directory only**

Don't worry about redirect URI yet.

Click:

**Register**

Record:

- Application/client ID
- Directory/tenant ID

### Important

Don't create a client secret for the API.

The API itself doesn't need a client secret just to validate JWT access tokens.

That's an important concept.

---

# Expose your API

Inside your App Registration:

**Expose an API**

Click:

**Add → Application ID URI**

Use the generated default value.

Then:

**Add a scope**

Example:

```text
Scope name:
Order.Read
```

Who can consent:

```text
Admins and users
```

Display name:

```text
Read Orders
```

Description:

```text
Allows the application to read orders.
```

Create another:

```text
Order.Write
```

Now you have:

```text
Order.Read
Order.Write
```

---

# Copilot Prompt 1

Now secure OrderService using Microsoft Entra ID JWT bearer authentication.

Important:

- Do not implement login UI yet.
- Do not use a client secret.
- The API should validate bearer access tokens issued by Microsoft Entra ID.

Use Microsoft.Identity.Web where appropriate.

Configuration should use:

- Tenant ID
- Client ID
- Authority / Microsoft Entra configuration

Protect the Order API using [Authorize].

Initially make GET /api/orders require authentication.

Keep POST /api/orders unprotected temporarily so I can compare authenticated and unauthenticated behavior.

Explain every important line of code in beginner-friendly terms.

Also explain:

1. What JWT bearer authentication does.
2. How the API validates the token.
3. What issuer means.
4. What audience means.
5. What signature validation means.
6. What expiration means.
7. Why the API does not need to call Microsoft Entra ID for every request.
8. Difference between authentication and authorization.

Do not introduce APIM, Key Vault, Managed Identity, Docker, or Angular yet.

---

# PHASE 2 — Actually obtain a token

Now you need to experience the most important flow:

```text
Client
 ↓
Entra ID
 ↓
Access Token
 ↓
Authorization: Bearer <token>
 ↓
.NET API
```

For the first experiment, use a simple client such as Postman.

Create an app registration for your test client.

### Azure Portal

Go:

**Microsoft Entra ID → App registrations → New registration**

Name:

```text
AzureSecurityPOC-Client
```

Then configure the appropriate redirect URI for your chosen Postman OAuth flow.

The important thing isn't memorizing the portal clicks.

The important thing is understanding:

```text
Client application
       ↓
requests authorization
       ↓
Entra ID
       ↓
access token
       ↓
API
```

---

# Copilot Prompt 2

Help me understand how an OAuth 2.0 access token is obtained and used to call my protected OrderService.

Do not modify my API architecture.

Create a beginner-friendly explanation of:

1. Client
2. Resource/API
3. Authorization server
4. Access token
5. Scope
6. Audience
7. Issuer
8. Authorization header
9. JWT claims

Show an example request:

Authorization: Bearer <access-token>

Explain exactly what happens from the moment the client requests a token until OrderService accepts or rejects the request.

Also explain:

- 401 Unauthorized
- 403 Forbidden
- expired token
- wrong audience
- missing scope

Give me a small checklist of experiments I can perform manually using Postman.

---

# PHASE 3 — Authorization

Now make the POC realistic.

Authentication:

```text
Is this a valid user/token?
```

Authorization:

```text
What is this user allowed to do?
```

Use your scopes.

For example:

```text
Order.Read
Order.Write
```

Then:

```text
GET /orders
     ↓
Order.Read

POST /orders
     ↓
Order.Write
```

---

# Copilot Prompt 3

Extend my OrderService authorization.

Use Microsoft Entra ID scopes.

Required permissions:

Order.Read
Order.Write

Implement authorization so:

GET /api/orders
requires Order.Read.

GET /api/orders/{id}
requires Order.Read.

POST /api/orders
requires Order.Write.

Explain:

1. Authentication vs authorization.
2. Role vs scope.
3. Why a valid JWT can still result in 403.
4. How the API reads claims/scopes from the JWT.
5. Why authorization must also be enforced by the backend even if APIM performs JWT validation.

Keep the implementation simple and readable.

Do not add APIM yet.

---

# PHASE 4 — Introduce APIM

Now the architecture becomes:

```text
Angular/Postman
      ↓
    APIM
      ↓
OrderService
```

This is a major interview phase.

## Manual Azure Work

Azure Portal:

**Create a resource → API Management**

For your learning POC, use the lowest-cost suitable option available in your subscription. Azure APIM pricing/tiers can change, so check the current portal pricing before creating it.

Give it a simple name:

```text
azure-security-poc-apim
```

Region: choose the same region as your other resources where practical.

After deployment:

Go to:

**APIM → APIs → Add API**

Initially import your OrderService OpenAPI definition.

For learning, you can first expose the API through a publicly reachable development endpoint.

---

# Important concept

Your architecture becomes:

```text
Client
  ↓
APIM
  ↓
OrderService
```

The client should eventually use the APIM URL, **not the backend URL**.

---

# Copilot Prompt 4

I have now created Azure API Management manually.

Help me understand how APIM fits in front of my OrderService.

Do not generate Azure infrastructure code.

Explain:

1. API Gateway
2. APIM
3. API
4. Operation
5. Backend
6. Product
7. Subscription
8. Subscription key
9. Inbound policy
10. Backend policy
11. Outbound policy
12. On-error policy

Show the request flow:

Client → APIM → OrderService

Explain what happens at each stage.

Then help me configure my existing API for APIM without changing the .NET application unnecessarily.

Do not introduce JWT validation policies yet. I want to understand the basic gateway flow first.

---

# PHASE 5 — JWT validation at APIM

Now we're going to move the security boundary.

```text
Client
  ↓
JWT
  ↓
APIM
  ↓
JWT validation
  ↓
OrderService
```

APIM should reject invalid tokens before the request reaches your API.

This is extremely valuable for interviews.

---

# Copilot Prompt 5

I want to configure Azure API Management to validate Microsoft Entra ID JWT access tokens before forwarding requests to OrderService.

Explain the APIM validate-jwt policy in beginner-friendly terms.

Show me a policy that validates:

1. Token issuer
2. Audience
3. Signature
4. Expiration
5. Required scope

Use my Order.Read and Order.Write scopes appropriately.

Explain exactly what happens for:

- No token
- Expired token
- Invalid signature
- Wrong issuer
- Wrong audience
- Missing scope
- Valid token

For each case tell me whether the expected result is 401, 403, or another response.

Do not hide the important details behind abstractions. I want to understand what APIM is actually checking.

---

# PHASE 6 — CORS + Rate Limiting

Now add two common APIM policies.

### CORS

```text
Angular
   ↓
APIM
```

Only your Angular application's origin should be allowed.

### Rate limiting

For example:

```text
10 requests / minute
```

This lets you experience:

```text
429 Too Many Requests
```

---

# Copilot Prompt 6

Help me add two Azure API Management policies to my security POC:

1. CORS
2. Rate limiting

Explain CORS first.

Show:

- What CORS protects against
- What CORS does NOT protect against
- Why CORS is mainly a browser security mechanism
- Why CORS is not authentication

Then configure a simple rate limit policy.

Use a deliberately small limit so I can trigger HTTP 429 during testing.

Explain:

- Why rate limiting is useful
- Difference between rate limiting and authentication
- What HTTP 429 means
- Where rate limiting belongs in a microservices architecture

Give me manual test steps.

---

# PHASE 7 — Managed Identity

Now comes one of the most important parts.

Create the second service interaction:

```text
OrderService
      ↓
CustomerService
```

But don't use:

```text
API key
username/password
client secret
```

Instead:

```text
OrderService
      ↓
Managed Identity
      ↓
Entra ID
      ↓
Access Token
      ↓
CustomerService
```

---

## Azure Portal manual work

For the Azure-hosted OrderService, enable:

**Identity → System assigned → On**

Azure creates an identity for the service.

You'll see an object/principal identity associated with the resource.

Do the same for CustomerService if needed.

---

# Important understanding

Managed Identity isn't magic.

Conceptually:

```text
Azure resource
     ↓
has an identity
     ↓
Entra ID trusts that identity
     ↓
resource obtains token
     ↓
token used to access another resource
```

---

# Copilot Prompt 7

I want OrderService to call CustomerService securely using Azure Managed Identity.

Design this as a simple service-to-service authentication flow.

Architecture:

OrderService → CustomerService

Requirements:

- Do not use client secrets.
- Do not hard-code credentials.
- Use Microsoft Entra ID.
- Use Managed Identity when running in Azure.
- Use a simple local-development approach that does not require storing secrets.

Explain:

1. What Managed Identity is.
2. System-assigned vs user-assigned Managed Identity.
3. How Managed Identity obtains an access token.
4. What the target API validates.
5. Authentication vs authorization in service-to-service communication.
6. Why Managed Identity is safer than storing client secrets.
7. What happens if the identity has no permission.

Generate only the minimum .NET code needed for this flow.

Explain each important line.

---

# PHASE 8 — Key Vault

Now introduce the secret.

Imagine CustomerService needs an external service API key.

Store it in:

```text
Azure Key Vault
```

not:

```text
appsettings.json
```

---

## Manual Azure Portal work

Create:

**Key Vault**

Then:

**Objects → Secrets → Generate/Import**

Create:

```text
ExternalServiceApiKey
```

Use a dummy value for the POC.

Then configure the application's managed identity with the minimum permission required to read that secret.

Prefer the modern Azure RBAC approach where appropriate.

---

# Copilot Prompt 8

Integrate Azure Key Vault into my CustomerService.

Requirements:

- Store a dummy external API key in Azure Key Vault.
- Do not put the secret in appsettings.json.
- Do not put the secret in source control.
- Use Managed Identity for Azure authentication to Key Vault.
- Follow least privilege.

Explain:

1. What Key Vault is.
2. Secret vs key vs certificate.
3. Why Key Vault alone does not authenticate my application.
4. How Managed Identity and Key Vault work together.
5. RBAC and least privilege.
6. What happens when the application does not have permission.
7. How secret rotation works conceptually.

Show the minimal .NET configuration/code.

Also explain how I can use local development without copying the production secret into source control.

---

# PHASE 9 — Application Insights

You already have professional experience here, so don't spend too long.

Connect Application Insights.

Then intentionally create:

```text
Angular
 ↓
APIM
 ↓
OrderService
 ↓
CustomerService
 ↓
Key Vault
```

and investigate failures.

---

# Copilot Prompt 9

Help me add Application Insights to this Azure security POC.

I want to learn troubleshooting rather than just enabling telemetry.

Create a simple observability approach for:

Angular → APIM → OrderService → CustomerService

Explain:

1. Logs
2. Metrics
3. Traces
4. Dependencies
5. Exceptions
6. Correlation
7. Request IDs
8. Distributed tracing

Give me practical troubleshooting exercises for:

- API returns 401
- API returns 403
- APIM returns 429
- CustomerService returns 500
- Key Vault access is denied
- Database dependency is slow

For each exercise explain what I should look for in Application Insights and which KQL queries would help.

---

# PHASE 10 — Security Failure Day 🔥

This phase is extremely important.

Don't just make everything work.

**Break it deliberately.**

Create a checklist:

```text
☐ Remove Authorization header
☐ Expire token
☐ Use wrong audience
☐ Use wrong issuer
☐ Remove required scope
☐ Exceed rate limit
☐ Remove Key Vault permission
☐ Disable Managed Identity
☐ Use wrong secret name
☐ Make CustomerService unavailable
☐ Try direct backend access
```

For each one:

```text
What failed?
Why?
Where did it fail?
What status code?
How did I identify it?
How would I fix it?
```

This is where your interview confidence will improve dramatically.

---

# Copilot Prompt 10

Act as my senior .NET/Azure interviewer.

I have built this security architecture:

Angular
→ Microsoft Entra ID
→ Azure APIM
→ OrderService
→ CustomerService
→ Managed Identity
→ Azure Key Vault
→ Application Insights

Create a security troubleshooting interview lab.

Give me one scenario at a time.

Do not immediately give me the answer.

Wait for my response.

Evaluate my answer for:

- Correctness
- Missing concepts
- Security concerns
- Azure-specific details
- Production considerations

Then explain the ideal answer.

Cover these scenarios:

1. Missing JWT
2. Expired JWT
3. Wrong audience
4. Wrong issuer
5. Missing scope
6. APIM returns 401
7. APIM returns 403
8. APIM returns 429
9. Direct backend access
10. Managed Identity authentication failure
11. Key Vault authorization failure
12. Secret rotation
13. Service-to-service authentication
14. CORS failure
15. Token leakage
16. Excessive permissions
17. APIM backend failure
18. Application Insights troubleshooting

Ask me questions one at a time like a real interview.

---

# Your final architecture

By the end, don't worry if it looks complicated. You should be able to explain it in one minute:

> "The Angular application authenticates users through Microsoft Entra ID using OAuth 2.0/OpenID Connect. It obtains an access token and sends it to Azure API Management. APIM acts as the API gateway and validates the JWT, including issuer, audience, expiration and required permissions. It also handles policies such as CORS and rate limiting. APIM forwards valid requests to the .NET microservices. For service-to-service communication, the services use Managed Identity rather than storing client secrets. Secrets required by the application are stored in Azure Key Vault, which the application accesses through its managed identity with least-privilege permissions. Application Insights provides telemetry for requests, dependencies, exceptions and distributed troubleshooting."

If you can **build it, break it, fix it, and explain that paragraph in your own words**, you'll have much stronger interview preparation than simply reading Azure security notes.

### Keep the scope small

Don't add these initially:

❌ AKS
❌ Kafka
❌ Service Bus
❌ Redis
❌ Terraform
❌ Azure DevOps pipeline
❌ complicated databases
❌ 5+ microservices

First finish:

**Angular → Entra ID → APIM → 2 .NET APIs → Managed Identity → Key Vault → Application Insights.**

Then, only if you have time, add **AKS + Workload Identity** as Phase 11. This keeps the POC achievable while covering the security questions most relevant to your .NET/Azure interview.
