# .NET Framework ASP.NET Web API Interview Questions and Answers

This guide is for experienced .NET developers preparing for interviews involving **ASP.NET Web API 2 on .NET Framework**, IIS, OWIN, Entity Framework, security, performance, and production support.

The explanations start simply and then add the depth expected from an experienced developer.

> Important: This guide focuses on classic ASP.NET Web API 2 (`System.Web.Http`) running on .NET Framework. ASP.NET Core uses a different hosting model, middleware pipeline, dependency injection system, and configuration approach.

---

## Table of Contents

1. [Web API Fundamentals](#1-web-api-fundamentals)
2. [Request Pipeline and Configuration](#2-request-pipeline-and-configuration)
3. [Routing and HTTP](#3-routing-and-http)
4. [Binding Validation and Responses](#4-binding-validation-and-responses)
5. [Security](#5-security)
6. [Data Access and Performance](#6-data-access-and-performance)
7. [Errors Logging and Reliability](#7-errors-logging-and-reliability)
8. [Testing Deployment and Production Scenarios](#8-testing-deployment-and-production-scenarios)
9. [Rapid-Fire Revision](#9-rapid-fire-revision)

---

# 1. Web API Fundamentals

## Q1. What is ASP.NET Web API?

### Simple Answer

ASP.NET Web API is a framework for building HTTP services. It allows applications such as browsers, mobile apps, and other services to communicate using HTTP.

### Interview Answer

ASP.NET Web API 2 is an HTTP service framework built on .NET Framework. It is commonly used to create REST-style APIs that expose resources through URLs and HTTP verbs such as GET, POST, PUT, PATCH, and DELETE. It supports routing, model binding, validation, content negotiation, filters, authentication, authorization, and extensibility through handlers and formatters.

### Deeper Explanation

A Web API controller receives an HTTP request, executes application logic, and produces an HTTP response. The response commonly contains JSON, but Web API can select another format based on the request headers and configured formatters.

Classic Web API is not the same as MVC:

- MVC primarily returns HTML views.
- Web API primarily returns data over HTTP.
- Web API uses `ApiController`.
- MVC uses `Controller`.
- Web API has its own routing and configuration under `System.Web.Http`.

### Common Mistake

Saying that Web API is only for JSON. JSON is common, but content negotiation can support XML or custom media types as well.

---

## Q2. What is the difference between ASP.NET Web API and ASP.NET Core Web API?

### Simple Answer

They are different frameworks with different hosting, configuration, middleware, and dependency injection models.

### Interview Answer

ASP.NET Web API 2 runs on the .NET Framework and commonly hosts in IIS using `System.Web`, `GlobalConfiguration`, and `WebApiConfig`. ASP.NET Core Web API runs on the modern .NET platform and uses the cross-platform Kestrel server, `Program.cs`, a built-in middleware pipeline, and built-in dependency injection.

### Comparison

| Area                       | Web API 2                       | ASP.NET Core Web API                 |
| -------------------------- | ------------------------------- | ------------------------------------ |
| Main namespace             | `System.Web.Http`               | `Microsoft.AspNetCore.Mvc`           |
| Base controller            | `ApiController`                 | `ControllerBase`                     |
| Configuration              | `WebApiConfig`, `web.config`    | `Program.cs`, `appsettings.json`     |
| Pipeline                   | HTTP modules, handlers, filters | Middleware pipeline                  |
| DI                         | Usually third-party container   | Built in                             |
| Hosting                    | IIS/System.Web                  | Kestrel, IIS, containers             |
| Configuration registration | `GlobalConfiguration.Configure` | Service and application builder APIs |

### Common Mistake

Applying ASP.NET Core syntax such as `IActionResult`, `AddControllers`, or `UseMiddleware` directly to a .NET Framework Web API 2 project.

---

## Q3. What is REST, and is every Web API a REST API?

### Simple Answer

REST is a set of architectural constraints for HTTP services. A service that uses HTTP is not automatically RESTful.

### Interview Answer

A REST-style API models business entities as resources, uses predictable URLs, uses HTTP methods according to their meaning, remains stateless between requests, and communicates through representations such as JSON. In practice, many enterprise APIs are REST-like rather than perfectly REST-compliant because they include operations such as `/orders/{id}/approve`.

### Example

```text
GET    /api/orders/42       Get order 42
POST   /api/orders          Create an order
PUT    /api/orders/42       Replace order 42
PATCH  /api/orders/42       Partially update order 42
DELETE /api/orders/42       Delete order 42
```

### Important Properties

- **Stateless:** Each request contains the information needed to process it.
- **Resource-oriented:** URLs identify nouns, not usually verbs.
- **Idempotent operations:** Repeating PUT or DELETE should have the same intended final result.
- **Cacheable:** Responses can declare whether clients may cache them.

### Common Mistake

Using `GET /api/order/delete/42`. Deleting should normally be represented by `DELETE /api/orders/42`.

---

## Q4. What is the Web API request lifecycle?

### Simple Answer

The request enters IIS, passes through the ASP.NET/Web API pipeline, is routed to a controller action, and becomes an HTTP response.

### Interview Answer

A simplified Web API 2 lifecycle is:

1. IIS receives the request.
2. ASP.NET and Web API hosting components accept it.
3. HTTP message handlers process the request.
4. Routing selects a controller and action.
5. Parameter binding reads route, query-string, header, or body values.
6. Validation runs for bound models.
7. Authorization and action filters run at their relevant stages.
8. The controller action executes.
9. The result is converted into an HTTP response.
10. Response handlers and filters can process the response before it returns to the client.

### Why This Matters

The pipeline explains where a concern belongs:

- Cross-cutting request processing: handler.
- Authorization: authorization filter.
- Input validation: model validation or validation filter.
- Exception conversion: exception filter or global exception handler.
- Business rules: service/domain layer, not the controller.

### Common Mistake

Putting authentication, database access, validation, and business rules directly into every controller action. That creates duplication and makes testing difficult.

---

# 2. Request Pipeline and Configuration

## Q5. What is the purpose of `WebApiConfig`?

### Simple Answer

It is the central place where Web API routes and Web API-specific configuration are registered.

### Example

```csharp
public static class WebApiConfig
{
    public static void Register(HttpConfiguration config)
    {
        config.MapHttpAttributeRoutes();

        config.Routes.MapHttpRoute(
            name: "DefaultApi",
            routeTemplate: "api/{controller}/{id}",
            defaults: new { id = RouteParameter.Optional }
        );

        config.Formatters.JsonFormatter.SerializerSettings
            .ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
    }
}
```

It is normally called during application startup:

```csharp
GlobalConfiguration.Configure(WebApiConfig.Register);
```

### Experienced Answer

I keep Web API registration explicit and ordered. I register attribute routes before relying on conventional routes, configure formatters intentionally, and avoid putting business behavior in startup code. I also confirm whether a setting belongs to Web API configuration or to `web.config`/IIS.

### Common Mistake

Registering MVC routes but forgetting Web API routes, or registering Web API configuration in a way that is never called during application startup.

---

## Q6. What is the difference between a message handler and a filter?

### Simple Answer

A message handler works at the HTTP message level. A filter works closer to controller/action execution.

### Interview Answer

A `DelegatingHandler` can inspect or modify the request and response for a broad portion of the pipeline. It is useful for correlation IDs, request timing, custom headers, or low-level authentication. Filters are more closely connected to controllers and actions and are useful for authorization, action validation, exception handling, and action-specific concerns.

### Handler Example

```csharp
public class CorrelationHandler : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request,
        CancellationToken cancellationToken)
    {
        var correlationId = request.Headers.Contains("X-Correlation-Id")
            ? request.Headers.GetValues("X-Correlation-Id").First()
            : Guid.NewGuid().ToString("N");

        request.Properties["CorrelationId"] = correlationId;

        var response = await base.SendAsync(request, cancellationToken);
        response.Headers.Add("X-Correlation-Id", correlationId);
        return response;
    }
}
```

### Filter Example

```csharp
public class AuditAttribute : ActionFilterAttribute
{
    public override void OnActionExecuting(HttpActionContext actionContext)
    {
        // Record the operation and authenticated user here.
        base.OnActionExecuting(actionContext);
    }
}
```

### Common Mistake

Using an action filter for logic that must run for every request, including requests that never reach an action. A handler may be a better fit in that case.

---

## Q7. How do you configure dependency injection in Web API 2?

### Simple Answer

Choose a DI container such as Autofac, Unity, Ninject, or Simple Injector, register interfaces and implementations, and connect the container to Web API's dependency resolver.

### Example Using Unity-Style Registration

```csharp
var container = new UnityContainer();
container.RegisterType<IOrderService, OrderService>(new HierarchicalLifetimeManager());

config.DependencyResolver = new UnityDependencyResolver(container);
```

### Experienced Answer

I use constructor injection and keep controllers thin. The composition root owns registrations and lifetimes. I make sure the container creates and disposes request-scoped dependencies correctly, especially database contexts. I avoid service locator calls such as `DependencyResolver.Current.GetService<T>()` inside business code because they hide dependencies and make unit tests harder.

### Controller Example

```csharp
public class OrdersController : ApiController
{
    private readonly IOrderService orderService;

    public OrdersController(IOrderService orderService)
    {
        this.orderService = orderService;
    }
}
```

### Common Mistakes

- Registering a stateful service as a singleton.
- Creating `DbContext` manually in every method.
- Allowing controllers to depend directly on the DI container.
- Forgetting to register a dependency, causing activation errors at runtime.

---

## Q8. What is the difference between Web API configuration and `web.config`?

### Simple Answer

Web API configuration controls the Web API framework. `web.config` controls ASP.NET/IIS application settings and hosting behavior.

### Examples

**Web API configuration:** routes, formatters, filters, handlers, dependency resolver.

**`web.config`:** connection strings, app settings, compilation, authentication modules, custom errors, IIS settings, request limits, and transforms.

### Experienced Consideration

Configuration should be environment-specific and should not require code changes for deployment. I use config transforms for non-secret environment settings and a secure secret provider or protected configuration for credentials. I also verify that an IIS setting is not overriding the application expectation.

---

# 3. Routing and HTTP

## Q9. How does attribute routing work?

### Simple Answer

Attribute routing defines the URL directly on the controller or action using attributes.

### Example

```csharp
[RoutePrefix("api/customers")]
public class CustomersController : ApiController
{
    [HttpGet]
    [Route("{id:int}")]
    public IHttpActionResult Get(int id)
    {
        return Ok(new { Id = id });
    }

    [HttpGet]
    [Route("search")]
    public IHttpActionResult Search(string name)
    {
        return Ok();
    }
}
```

### Experienced Answer

Attribute routing improves discoverability and supports constraints such as `{id:int}`. I watch for ambiguous routes, route order, and accidental route changes that break clients. I use a consistent resource naming convention and keep versioning visible in the route or media type strategy.

### Common Mistake

Defining both a broad conventional route and multiple overlapping attribute routes without testing route selection. This can lead to unexpected 404 or action-selection errors.

---

## Q10. What are common HTTP status codes in a Web API?

### Practical Answers

- `200 OK`: Successful read or operation with a response body.
- `201 Created`: A resource was created. Include a location when practical.
- `202 Accepted`: The request was accepted for asynchronous processing.
- `204 No Content`: Successful operation with no response body.
- `400 Bad Request`: Invalid request syntax or invalid input.
- `401 Unauthorized`: The client is not authenticated. The name is historically confusing.
- `403 Forbidden`: The client is authenticated but not allowed.
- `404 Not Found`: Resource or route was not found.
- `409 Conflict`: Request conflicts with current resource state.
- `429 Too Many Requests`: Rate limit exceeded.
- `500 Internal Server Error`: Unexpected server failure.
- `503 Service Unavailable`: Service is temporarily unavailable.

### Example

```csharp
[HttpPost]
public IHttpActionResult Create(CreateOrderRequest request)
{
    var order = orderService.Create(request);
    return CreatedAtRoute("DefaultApi", new { id = order.Id }, order);
}
```

### Common Mistake

Returning `200 OK` for every outcome. Status codes help clients distinguish success, validation failure, authorization failure, and transient server failure.

---

## Q11. What is content negotiation?

### Simple Answer

Content negotiation selects the response format based on the client's request headers and server capabilities.

### Example

A client may send:

```http
Accept: application/json
```

or:

```http
Accept: application/xml
```

Web API uses formatters to serialize the response into a supported representation.

### Experienced Answer

I configure the supported media types intentionally and avoid exposing formats that are not required. I also distinguish `Accept`, which describes the desired response format, from `Content-Type`, which describes the request body format. For public APIs, I document the supported media types and test unsupported media type behavior.

### Common Mistake

Assuming `Content-Type: application/json` controls the response. It describes the request body; `Accept` describes the preferred response representation.

---

## Q12. How do you version a Web API?

### Simple Answer

Versioning lets an API evolve without unexpectedly breaking existing consumers.

### Common Strategies

- URL versioning: `/api/v1/orders`.
- Query-string versioning: `/api/orders?version=1`.
- Header versioning: `api-version: 1`.
- Media-type versioning: `Accept: application/vnd.company.orders.v1+json`.

### Experienced Answer

I choose a strategy based on consumer needs, gateway support, discoverability, and backward-compatibility policy. URL versioning is easy to understand and operate, while header/media-type versioning keeps URLs stable but requires better tooling and documentation. I avoid versioning every internal implementation detail; I version the public contract.

### Migration Practices

- Keep old versions available for an announced period.
- Add fields in a backward-compatible way where possible.
- Do not change the meaning of an existing field silently.
- Publish deprecation dates and monitor old-version traffic.

---

# 4. Binding Validation and Responses

## Q13. What is model binding?

### Simple Answer

Model binding converts values from the route, query string, headers, or request body into action parameters or .NET objects.

### Example

```csharp
public class ProductQuery
{
    public string Category { get; set; }
    public int Page { get; set; }
}

[HttpGet]
public IHttpActionResult Get(ProductQuery query)
{
    return Ok(query);
}
```

A request such as `/api/products?category=books&page=2` can be bound to `ProductQuery`.

### Experienced Answer

I make the source of important values explicit with `[FromUri]` and `[FromBody]`, especially when an action has multiple parameters. I do not trust client-supplied identity or authorization values from the body; those come from the authenticated principal and server-side checks.

```csharp
public IHttpActionResult Update(
    int id,
    [FromBody] UpdateProductRequest request)
{
    // id comes from the route and request comes from the body.
    return Ok();
}
```

### Common Mistake

Allowing a client to bind directly to an entity with fields such as `IsAdmin`, `OwnerId`, or `ApprovedAt`. Use request DTOs to prevent over-posting.

---

## Q14. How does Web API validation work?

### Simple Answer

Validation checks whether incoming data satisfies rules before business processing continues.

### Example

```csharp
public class CreateCustomerRequest
{
    [Required]
    [StringLength(100)]
    public string Name { get; set; }

    [Required]
    [EmailAddress]
    public string Email { get; set; }
}

[HttpPost]
public IHttpActionResult Create(CreateCustomerRequest request)
{
    if (!ModelState.IsValid)
    {
        return BadRequest(ModelState);
    }

    return Ok();
}
```

### Experienced Answer

Data annotations handle simple structural rules. Business rules belong in the service/domain layer because they may require database state or other services. I return a consistent validation error shape and never assume that a client-side validation check is sufficient.

### Important Distinction

- Structural validation: required field, length, format, numeric range.
- Business validation: customer cannot place an order while suspended.
- Authorization: current user is allowed to perform the operation.

These are related but not interchangeable.

---

## Q15. Why should APIs use DTOs instead of exposing Entity Framework entities?

### Simple Answer

DTOs define the public API contract and prevent database models from leaking into the API.

### Interview Answer

DTOs prevent over-posting, reduce accidental data exposure, avoid circular-reference serialization problems, and allow the database model to evolve independently from the API contract. They also let the API return a shape designed for the client rather than exposing every database column.

### Example

```csharp
public class CustomerResponse
{
    public int Id { get; set; }
    public string DisplayName { get; set; }
}

public class UpdateCustomerRequest
{
    [Required]
    public string DisplayName { get; set; }
}
```

### Common Mistake

Returning an EF entity that contains password hashes, internal flags, navigation properties, or audit fields.

---

## Q16. When should an API return `IHttpActionResult` versus `HttpResponseMessage`?

### Simple Answer

`IHttpActionResult` is usually simpler for controller actions. `HttpResponseMessage` is useful when low-level control over the HTTP response is needed.

### Example

```csharp
public IHttpActionResult Get(int id)
{
    var customer = service.Find(id);

    if (customer == null)
    {
        return NotFound();
    }

    return Ok(customer);
}
```

Use `HttpResponseMessage` when you need direct control over headers, streaming, custom content, or a response object created by another component.

### Experienced Answer

I prefer `IHttpActionResult` for normal controller logic because it expresses the intended result clearly and improves consistency. I use `HttpResponseMessage` for cases such as file downloads, custom headers, or streaming where the response itself is the key object.

---

# 5. Security

## Q17. What is the difference between authentication and authorization?

### Simple Answer

Authentication identifies the caller. Authorization checks what that caller is allowed to do.

### Example

- Authentication: The token belongs to user 123.
- Authorization: User 123 may view customer 456.

### Experienced Answer

I apply both checks. `[Authorize]` proves that a principal is authenticated, but role checks and resource-level checks are still needed. For example, a user may have the `Employee` role but still must not view another tenant's data.

```csharp
[Authorize(Roles = "Manager")]
[HttpDelete]
public IHttpActionResult Delete(int id)
{
    if (!authorizationService.CanDelete(User, id))
    {
        return StatusCode(HttpStatusCode.Forbidden);
    }

    service.Delete(id);
    return StatusCode(HttpStatusCode.NoContent);
}
```

### Common Mistake

Treating a role check as sufficient for tenant isolation or resource ownership.

---

## Q18. How does token authentication work in a Web API 2 application?

### Simple Answer

The client sends a token with the request. The server validates it and creates an authenticated principal.

### Typical Flow

1. Client authenticates with an identity service.
2. Identity service issues an access token.
3. Client sends `Authorization: Bearer <token>`.
4. The API validates signature, issuer, audience, expiry, and relevant claims.
5. Web API uses the resulting principal for authorization.

### Experienced Answer

Token validation must be performed by trusted middleware or a well-reviewed library. I validate issuer, audience, signature, expiry, and required claims. I use HTTPS, short-lived access tokens, secure refresh-token handling, and key rotation. I never log complete tokens.

### Common Mistakes

- Accepting unsigned or incorrectly validated tokens.
- Checking only token expiry.
- Putting sensitive information in token payloads and assuming payloads are secret.
- Logging the `Authorization` header.

---

## Q19. What is CORS, and why does it fail in production?

### Simple Answer

CORS controls whether a browser allows JavaScript from one origin to call an API hosted on another origin.

### Example

```csharp
public static void Register(HttpConfiguration config)
{
    var cors = new EnableCorsAttribute(
        origins: "https://app.example.com",
        headers: "*",
        methods: "GET,POST,PUT,DELETE");

    config.EnableCors(cors);
}
```

### Experienced Answer

CORS is enforced by browsers; it is not a replacement for API authentication. I avoid `*` in production when credentials are involved, configure allowed origins explicitly, and account for preflight `OPTIONS` requests. I also verify that IIS, a reverse proxy, or a gateway is not removing the CORS headers.

### Common Mistake

Thinking CORS blocks non-browser clients. Postman or a server-to-server caller can call the API even when a browser would block the request.

---

## Q20. What are common Web API security risks?

### Experienced Answer

I look for:

- Broken object-level authorization: user can access another user's ID.
- Over-posting: client changes fields it should not control.
- SQL injection: unsafe string-built SQL.
- Sensitive data exposure: secrets or internal fields in responses/logs.
- Weak transport security: HTTP instead of HTTPS.
- Excessive error details in production.
- Missing rate limits or request-size limits.
- Unsafe deserialization or untrusted type handling.
- Missing audit records for sensitive operations.

### Beginner-Friendly Rule

Never trust a value because it came from a request. Validate it, authorize it, and use parameterized access to the database.

---

# 6. Data Access and Performance

## Q21. How do you use Entity Framework safely in Web API?

### Simple Answer

Use a short-lived `DbContext`, query only what is needed, avoid unnecessary tracking, and keep database logic out of controllers.

### Example

```csharp
public async Task<CustomerResponse> FindAsync(int id)
{
    return await db.Customers
        .AsNoTracking()
        .Where(customer => customer.Id == id)
        .Select(customer => new CustomerResponse
        {
            Id = customer.Id,
            DisplayName = customer.Name
        })
        .SingleOrDefaultAsync();
}
```

### Experienced Answer

For read-only queries, I use projections and `AsNoTracking`. I avoid lazy loading in API serialization because it can produce hidden database calls and N+1 queries. I keep the context lifetime aligned with a request or unit of work and ensure it is disposed by the composition root.

### Common Mistakes

- Calling `.ToList()` before filtering.
- Returning entities and triggering lazy loading during serialization.
- Loading entire tables into memory.
- Running synchronous database calls inside asynchronous actions.
- Sharing one `DbContext` across requests.

---

## Q22. What is the N+1 query problem?

### Simple Answer

The application executes one query for the main records and then one additional query for each record's related data.

### Example Problem

Loading 100 orders and then separately loading each customer's name can result in 101 database queries.

### Fixes

- Project the required fields in one query.
- Use a carefully chosen eager load.
- Batch related data.
- Inspect generated SQL and query counts.

```csharp
var orders = await db.Orders
    .AsNoTracking()
    .Select(order => new OrderResponse
    {
        Id = order.Id,
        CustomerName = order.Customer.Name,
        Total = order.Total
    })
    .ToListAsync();
```

### Interview Point

Do not claim that `Include` always solves every performance issue. The correct choice depends on result size, relationship shape, filtering, and generated SQL.

---

## Q23. How do you improve a slow API?

### Experienced Investigation Sequence

1. Measure the endpoint separately from the client.
2. Add correlation IDs and timing around external calls.
3. Check application logs, IIS logs, database duration, and dependency timings.
4. Inspect SQL execution plans and indexes.
5. Check serialization size and repeated queries.
6. Check thread pool starvation and synchronous blocking.
7. Confirm whether latency is application, database, network, or downstream-service related.
8. Change one bottleneck at a time and measure again.

### Common Improvements

- Use asynchronous I/O end to end.
- Project only required columns.
- Add suitable database indexes.
- Paginate large collections.
- Cache stable reference data.
- Compress responses where appropriate.
- Avoid serializing huge object graphs.
- Add timeouts and cancellation for dependencies.

### Common Mistake

Adding caching before measuring. Caching can hide stale-data problems and may not fix the actual bottleneck.

---

## Q24. Why are pagination and filtering important?

### Simple Answer

They prevent an API from returning unbounded data and protect memory, network, database, and client performance.

### Example Contract

```text
GET /api/orders?page=2&pageSize=25&status=Open
```

### Experienced Answer

I enforce a maximum page size on the server, validate sort fields against an allow-list, and use stable ordering. For very large datasets, keyset pagination can be more efficient than high `OFFSET` values.

### Example Response Metadata

```json
{
  "items": [],
  "page": 2,
  "pageSize": 25,
  "totalCount": 143
}
```

### Common Mistake

Accepting a client-provided page size of one million or concatenating a client-provided sort column into SQL.

---

# 7. Errors Logging and Reliability

## Q25. How should exceptions be handled in Web API?

### Simple Answer

Handle expected business outcomes explicitly and convert unexpected exceptions into a safe, consistent response.

### Experienced Answer

I do not put a broad `try/catch` around every controller method. I handle exceptions at an appropriate global boundary, log the exception with correlation information, map known exception types to meaningful status codes, and return a generic error message in production.

### Example Error Shape

```json
{
  "error": {
    "code": "ORDER_NOT_FOUND",
    "message": "The requested order was not found.",
    "correlationId": "abc123"
  }
}
```

### Status Mapping Examples

- Validation exception: `400`.
- Authentication failure: `401`.
- Authorization failure: `403`.
- Missing resource: `404`.
- Concurrency conflict: `409`.
- Unexpected exception: `500`.
- Temporary dependency outage: often `503`.

### Common Mistakes

- Returning stack traces to clients.
- Catching `Exception` and continuing as if the operation succeeded.
- Logging the same exception at every layer.
- Returning `500` for a normal business condition such as a missing record.

---

## Q26. What should be logged for an API request?

### Simple Answer

Log enough information to diagnose the request without logging secrets or unnecessary personal data.

### Useful Fields

- Timestamp and duration.
- Correlation/request ID.
- HTTP method and route template.
- Response status code.
- Authenticated user or client identifier, where appropriate.
- Tenant identifier, where appropriate.
- Dependency duration and outcome.
- Exception type and stack trace for failures.

### Do Not Log

- Passwords.
- Access tokens or full authorization headers.
- Payment card data.
- Unnecessary personal or health information.
- Entire request bodies by default.

### Experienced Point

Use structured logs so fields can be searched and aggregated. A message such as `Order request failed` is less useful than a structured record containing order ID, correlation ID, status code, and dependency duration.

---

## Q27. What are timeouts, retries, and circuit breakers?

### Simple Answer

They protect an API when a downstream dependency is slow or unavailable.

### Definitions

- **Timeout:** Stop waiting after a defined period.
- **Retry:** Try a failed operation again when the failure may be transient.
- **Circuit breaker:** Temporarily stop calls after repeated failures so the dependency and caller can recover.

### Experienced Rules

- Set a timeout for every external call.
- Retry only transient failures.
- Use exponential backoff and jitter.
- Do not blindly retry non-idempotent operations.
- Bound total retry time within the request deadline.
- Return a meaningful transient failure response.

### Common Mistake

Adding three retries at every layer. Nested retries can multiply traffic during an outage and make the incident worse.

---

## Q28. What is idempotency, and why is it important for APIs?

### Simple Answer

An operation is idempotent when repeating the same request has the same intended final effect as making it once.

### Examples

- `GET` should not change state.
- `PUT /customers/10` with the same representation should produce the same final customer state.
- `DELETE /customers/10` should remain deleted when repeated.
- `POST` is not automatically idempotent because it may create multiple resources.

### Experienced Solution

For payment or order commands that may be retried, accept an idempotency key and persist the result associated with that key. A repeated request can then return the original result instead of creating a duplicate operation.

---

# 8. Testing Deployment and Production Scenarios

## Q29. What should you unit test in a Web API project?

### Simple Answer

Test business behavior and controller outcomes without requiring IIS, a real database, or external services.

### Good Unit Tests

- Valid request calls the service correctly.
- Invalid model returns `400`.
- Missing resource returns `404`.
- Unauthorized operation returns `403`.
- Service exception maps to the expected result where that mapping is owned by the tested layer.
- DTO mapping does not expose restricted fields.

### Additional Tests

- Integration tests for routing, serialization, authentication, and database behavior.
- Contract tests to protect consumers.
- Load tests for throughput and latency.
- Security tests for authorization boundaries and input handling.

### Common Mistake

Testing only that the action returns `200`. The important behavior is often in failure paths and authorization checks.

---

## Q30. What is the difference between IIS application pool recycling and application restart?

### Simple Answer

Both can restart application execution, but an application pool recycle restarts the worker process, while an application restart can also occur when application files or configuration change.

### Experienced Answer

A recycle clears in-memory state and can interrupt in-flight work depending on shutdown behavior. In-process caches, static fields, and background threads should therefore not be treated as durable storage. I use external stores for durable state and configure graceful shutdown where possible.

### Things to Check During Production Issues

- Application pool identity permissions.
- 32-bit versus 64-bit setting.
- Managed pipeline mode.
- Idle timeout and recycling schedule.
- Failed request tracing.
- HTTPS bindings and certificates.
- `web.config` transform output.
- Request filtering and maximum request size.
- Windows Event Viewer and IIS logs.

---

## Q31. What is a 500.19 IIS error?

### Simple Answer

It usually means IIS cannot read or apply the configuration, often because of invalid `web.config` syntax, a missing module, or a locked configuration section.

### Troubleshooting Approach

1. Read the detailed IIS error code and configuration path.
2. Validate XML syntax in `web.config`.
3. Confirm required IIS modules are installed.
4. Check whether the section is locked at a parent level.
5. Confirm application pool and hosting prerequisites.
6. Compare transformed deployment configuration with the source configuration.

### Common Mistake

Debugging controller code first. A 500.19 usually occurs before the request reaches the controller.

---

## Q32. How would you diagnose an API that returns 401 in production but works locally?

### Interview Answer

I compare the complete request and hosting configuration rather than changing authorization code immediately.

### Checklist

- Confirm the `Authorization` header reaches the server or gateway.
- Check token issuer, audience, signing key, and expiry.
- Compare environment-specific authority URLs.
- Check server clock synchronization.
- Check HTTPS termination and forwarded headers.
- Confirm IIS authentication settings and application pool identity.
- Inspect authentication middleware logs without logging the token.
- Confirm the request is reaching the expected application and version.

### Important Distinction

A `401` means authentication was not accepted. A `403` means authentication succeeded but authorization denied the operation.

---

## Q33. How would you design a reliable API endpoint for order creation?

### Experienced Answer Structure

1. Authenticate the caller.
2. Authorize access to the tenant and operation.
3. Validate the request DTO.
4. Enforce an idempotency key.
5. Check business rules in the service layer.
6. Use a transaction for the required local database changes.
7. Save an outbox event if downstream notification is needed.
8. Return `201 Created` for synchronous creation or `202 Accepted` for durable asynchronous processing.
9. Log the correlation ID and business operation result.
10. Avoid exposing internal database entities or sensitive fields.

### Why This Is Experienced-Level

It covers correctness, duplicate prevention, security, consistency, observability, and communication with downstream systems rather than only writing a controller method.

---

# 9. Rapid-Fire Revision

## Q34. What is `ApiController`?

A Web API 2 base controller that provides HTTP-oriented helpers such as `Ok`, `BadRequest`, `NotFound`, and access to request data.

## Q35. What is `IHttpActionResult`?

An abstraction representing an HTTP response result from a Web API action.

## Q36. What is `DelegatingHandler`?

A component that can inspect or modify HTTP requests and responses before or after the rest of the handler pipeline.

## Q37. What is over-posting?

When a client submits fields that the server unintentionally binds and allows it to change. Request DTOs help prevent it.

## Q38. What is a DTO?

A Data Transfer Object designed for communication across a boundary, such as an API request or response.

## Q39. What is a 401 versus 403?

`401` means the caller is not successfully authenticated. `403` means the caller is authenticated but not permitted.

## Q40. What is a 400 versus 422?

Both can represent invalid input depending on the API contract. The important point is to choose a consistent convention and document it. Many Web API 2 APIs use `400` for model validation errors.

## Q41. Why use async in Web API?

Asynchronous I/O allows a request thread to be released while waiting for a database or network operation. It improves scalability for I/O-bound workloads; it does not make CPU-heavy work automatically faster.

## Q42. What is a correlation ID?

An identifier carried through logs and downstream calls so one business request can be traced across components.

## Q43. Why avoid `Task.Run` in a controller for database calls?

It moves work to another thread but does not make blocking I/O non-blocking. Use the database client's asynchronous API instead.

## Q44. Why should API responses be paginated?

To prevent unbounded result sizes, excessive memory usage, slow serialization, network strain, and poor client performance.

## Q45. What makes an API production-ready?

Clear contracts, validation, authentication and authorization, consistent errors, timeouts, observability, secure configuration, tests, versioning, deployment checks, and performance limits.

---

# Final Interview Answering Pattern

For most experienced-level questions, answer in this order:

1. Give the definition in one sentence.
2. Explain how it works in Web API 2.
3. Give a production example.
4. Mention one trade-off or failure mode.
5. Explain how you would test or monitor it.

### Example

> Model binding converts request values into action parameters or DTOs. In Web API 2, values can come from the route, query string, headers, or body. In production I use explicit request DTOs to avoid over-posting and validate `ModelState` before calling the service. I keep business rules outside model validation when they require database state, and I test both invalid input and authorization boundaries.

This answer style demonstrates knowledge, practical judgment, and the ability to explain technical subjects clearly to both engineers and non-specialists.
