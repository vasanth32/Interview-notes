# Kubernetes Infrastructure Explanations - Part 2

This is a continuation of Infrastructure Explanations.md. Part 1 covers POC-5 through POC-10. Part 2 covers POC-11 and beyond.

---

# POC-11: Service Failure Handling - Infrastructure Explanation

## Overview

POC-11 implements **resilience patterns** to handle service failures gracefully. In a microservices architecture, services depend on each other, and failures are inevitable. This phase teaches you how to build services that can handle failures, retry operations, and degrade gracefully when dependencies are unavailable. Think of it as adding "shock absorbers and backup systems" to your microservices.

---

## The Failure Problem

### The Problem: What Happens When a Service Fails?

**In a Simple System:**
```
User Request → OrderService → ProductService
                              ↓
                         (Service is down!)
                              ↓
                    OrderService fails
                              ↓
                    User gets error
```

**Problems:**
- ❌ One service failure cascades to others
- ❌ No retry mechanism
- ❌ No fallback options
- ❌ Poor user experience
- ❌ System becomes unstable

### Real-World Scenarios:

1. **Temporary Network Issues**
   - Network hiccup for 1 second
   - Service should retry, not fail immediately

2. **Service Overload**
   - Service is slow but not down
   - Should timeout and use fallback

3. **Service Down**
   - Service is completely unavailable
   - Should fail fast and use cached data

4. **Partial Failures**
   - Some endpoints work, others don't
   - Should handle gracefully

### ✅ The Solution: Resilience Patterns

**Resilience** = The ability of a system to handle failures and continue operating.

**Key Patterns:**
1. **Retry**: Try again if request fails
2. **Circuit Breaker**: Stop calling failing service temporarily
3. **Timeout**: Don't wait forever
4. **Fallback**: Use alternative when service unavailable

---

## What is Polly?

**Polly** is a .NET resilience and transient-fault-handling library that allows you to express policies such as Retry, Circuit Breaker, Timeout, Bulkhead Isolation, and Fallback in a fluent and thread-safe manner.

### Why Polly?

**Without Polly:**
```csharp
// ❌ Manual retry logic - error-prone
try
{
    var result = await _httpClient.GetAsync(url);
    return result;
}
catch (Exception ex)
{
    // Retry once
    await Task.Delay(1000);
    try
    {
        return await _httpClient.GetAsync(url);
    }
    catch
    {
        throw; // Give up
    }
}
```

**With Polly:**
```csharp
// ✅ Clean, declarative policies
var policy = Policy
    .Handle<HttpRequestException>()
    .RetryAsync(3);

var result = await policy.ExecuteAsync(() => 
    _httpClient.GetAsync(url));
```

**Benefits:**
- ✅ **Declarative**: Express intent clearly
- ✅ **Composable**: Combine multiple policies
- ✅ **Testable**: Easy to unit test
- ✅ **Thread-Safe**: Works in async scenarios
- ✅ **Feature-Rich**: Many patterns built-in

---

## Resilience Patterns Explained

### 1. Retry Policy

**What it does**: Automatically retries failed requests.

**When to use**: Temporary failures (network hiccups, timeouts).

**Example:**
```csharp
var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .OrResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
    .WaitAndRetryAsync(
        retryCount: 3,
        sleepDurationProvider: retryAttempt => 
            TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)), // Exponential backoff
        onRetry: (outcome, timespan, retryCount, context) =>
        {
            _logger.LogWarning(
                "Retry {RetryCount} after {Delay}ms",
                retryCount, timespan.TotalMilliseconds);
        });
```

**How it works:**
```
Request 1 → Fails
  ↓ Wait 2 seconds
Request 2 → Fails
  ↓ Wait 4 seconds
Request 3 → Fails
  ↓ Wait 8 seconds
Request 4 → Success! ✅
```

**Exponential Backoff**: Wait time doubles each retry (2s, 4s, 8s)
- Prevents overwhelming the failing service
- Gives service time to recover

### 2. Circuit Breaker Pattern

**What it does**: Stops calling a failing service temporarily, then tests if it's recovered.

**When to use**: Service is consistently failing (down or overloaded).

**Analogy**: Like an electrical circuit breaker - when too much current flows, it "trips" to prevent damage.

**States:**
1. **Closed** (Normal): Requests flow through
2. **Open** (Tripped): Requests fail immediately, no calls made
3. **Half-Open** (Testing): Allow one test request to see if service recovered

**Example:**
```csharp
var circuitBreaker = Policy
    .Handle<HttpRequestException>()
    .CircuitBreakerAsync(
        handledEventsAllowedBeforeBreaking: 5, // Trip after 5 failures
        durationOfBreak: TimeSpan.FromSeconds(30), // Stay open for 30 seconds
        onBreak: (exception, duration) =>
        {
            _logger.LogError(
                "Circuit breaker opened for {Duration}ms",
                duration.TotalMilliseconds);
        },
        onReset: () =>
        {
            _logger.LogInformation("Circuit breaker reset");
        });
```

**How it works:**
```
Request 1 → Fails
Request 2 → Fails
Request 3 → Fails
Request 4 → Fails
Request 5 → Fails
  ↓
Circuit Breaker Opens (stops calling service)
  ↓
Wait 30 seconds
  ↓
Circuit Breaker Half-Open (test request)
  ↓
Test Request → Success
  ↓
Circuit Breaker Closes (normal operation resumes)
```

### 3. Timeout Policy

**What it does**: Cancels requests that take too long.

**When to use**: Services that might hang or be slow.

**Example:**
```csharp
var timeoutPolicy = Policy
    .TimeoutAsync(
        TimeSpan.FromSeconds(5),
        onTimeoutAsync: (context, timespan, task) =>
        {
            _logger.LogWarning("Request timed out after {Timeout}ms", 
                timespan.TotalMilliseconds);
            return Task.CompletedTask;
        });
```

**How it works:**
```
Request starts
  ↓
Wait 5 seconds
  ↓
If not complete → Cancel and throw TimeoutException
If complete → Return result
```

### 4. Fallback Policy

**What it does**: Provides alternative response when primary fails.

**When to use**: When you have backup data or default values.

**Example:**
```csharp
var fallbackPolicy = Policy
    .Handle<HttpRequestException>()
    .OrResult<HttpResponseMessage>(r => !r.IsSuccessStatusCode)
    .FallbackAsync(
        fallbackAction: async (ct) =>
        {
            // Return cached data
            return new HttpResponseMessage
            {
                Content = new StringContent(JsonSerializer.Serialize(cachedProducts)),
                StatusCode = HttpStatusCode.OK
            };
        },
        onFallbackAsync: (result, context) =>
        {
            _logger.LogWarning("Using fallback data");
            return Task.CompletedTask;
        });
```

**How it works:**
```
Try primary service
  ↓
Fails
  ↓
Use fallback (cached data, default values, etc.)
  ↓
Return fallback result to user
```

---

## Combining Policies: Policy Wrap

### What is Policy Wrap?

**Policy Wrap** allows you to combine multiple policies into one.

**Order matters**: Policies execute from outside to inside.

**Example:**
```csharp
// Combine all policies
var resiliencePolicy = Policy.WrapAsync(
    fallbackPolicy,      // Outer: Fallback if all else fails
    circuitBreaker,      // Middle: Stop calling if service is down
    timeoutPolicy,       // Inner: Don't wait forever
    retryPolicy          // Innermost: Retry on failure
);

// Usage
var result = await resiliencePolicy.ExecuteAsync(async () =>
{
    return await _httpClient.GetAsync("http://productservice/api/products/1");
});
```

**Execution Flow:**
```
Request
  ↓
Fallback Policy (outer)
  ↓
Circuit Breaker
  ↓ (if closed)
Timeout Policy
  ↓ (if not timed out)
Retry Policy
  ↓ (retries up to 3 times)
Actual HTTP Call
  ↓
If all fail → Fallback Policy provides alternative
```

---

## Implementation: Complete Example

### Step 1: Install Polly

```powershell
dotnet add package Microsoft.Extensions.Http.Polly
dotnet add package Polly.Extensions.Http
```

### Step 2: Configure HttpClient with Polly

**In Program.cs:**

```csharp
var builder = WebApplication.CreateBuilder(args);

// Configure HttpClient with Polly policies
builder.Services.AddHttpClient<IProductService, ProductService>()
    .AddPolicyHandler(GetRetryPolicy())
    .AddPolicyHandler(GetCircuitBreakerPolicy())
    .AddPolicyHandler(GetTimeoutPolicy());

var app = builder.Build();

// Policy definitions
static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .OrResult(msg => msg.StatusCode == System.Net.HttpStatusCode.TooManyRequests)
        .WaitAndRetryAsync(
            retryCount: 3,
            sleepDurationProvider: retryAttempt => 
                TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
            onRetry: (outcome, timespan, retryCount, context) =>
            {
                var logger = context.Values.ContainsKey("logger") 
                    ? context["logger"] as ILogger 
                    : null;
                logger?.LogWarning(
                    "Retry {RetryCount} after {Delay}ms",
                    retryCount, timespan.TotalMilliseconds);
            });
}

static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .CircuitBreakerAsync(
            handledEventsAllowedBeforeBreaking: 5,
            durationOfBreak: TimeSpan.FromSeconds(30));
}

static IAsyncPolicy<HttpResponseMessage> GetTimeoutPolicy()
{
    return Policy.TimeoutAsync<HttpResponseMessage>(TimeSpan.FromSeconds(5));
}
```

### Step 3: Use in Service

**OrderService.cs:**

```csharp
public class OrderService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<OrderService> _logger;
    private readonly IMemoryCache _cache;
    
    public OrderService(
        HttpClient httpClient,
        ILogger<OrderService> logger,
        IMemoryCache cache)
    {
        _httpClient = httpClient;
        _logger = logger;
        _cache = cache;
    }
    
    public async Task<Product> GetProductAsync(int productId)
    {
        // Try to get from cache first
        var cacheKey = $"product-{productId}";
        if (_cache.TryGetValue(cacheKey, out Product cachedProduct))
        {
            return cachedProduct;
        }
        
        try
        {
            // HttpClient automatically uses Polly policies
            var response = await _httpClient.GetAsync(
                $"http://productservice/api/products/{productId}");
            
            response.EnsureSuccessStatusCode();
            
            var product = await response.Content.ReadFromJsonAsync<Product>();
            
            // Cache for 5 minutes
            _cache.Set(cacheKey, product, TimeSpan.FromMinutes(5));
            
            return product;
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "Failed to get product {ProductId}", productId);
            
            // Fallback: Return cached product if available (even if expired)
            if (_cache.TryGetValue(cacheKey, out Product staleProduct))
            {
                _logger.LogWarning("Using stale cached product {ProductId}", productId);
                return staleProduct;
            }
            
            throw;
        }
    }
}
```

---

## Health Check Integration

### Why Integrate with Health Checks?

Health checks should reflect the actual state of dependencies, including circuit breakers.

**In Program.cs:**

```csharp
builder.Services.AddHealthChecks()
    .AddCheck<ProductServiceHealthCheck>("productservice")
    .AddCheck<DatabaseHealthCheck>("database");

// Custom health check that considers circuit breaker
public class ProductServiceHealthCheck : IHealthCheck
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly CircuitBreakerState _circuitBreakerState;
    
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        // If circuit breaker is open, service is unhealthy
        if (_circuitBreakerState.IsOpen)
        {
            return HealthCheckResult.Unhealthy(
                "ProductService circuit breaker is open");
        }
        
        try
        {
            var client = _httpClientFactory.CreateClient();
            var response = await client.GetAsync(
                "http://productservice/health", cancellationToken);
            
            if (response.IsSuccessStatusCode)
            {
                return HealthCheckResult.Healthy("ProductService is responding");
            }
            
            return HealthCheckResult.Degraded(
                $"ProductService returned {response.StatusCode}");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy(
                "ProductService is not reachable", ex);
        }
    }
}
```

---

## Monitoring Resilience Patterns

### Track in Application Insights

```csharp
public class ResilienceTelemetryProcessor : ITelemetryProcessor
{
    private readonly ITelemetryProcessor _next;
    
    public void Process(ITelemetry item)
    {
        if (item is DependencyTelemetry dependency)
        {
            // Track retry attempts
            if (dependency.Properties.ContainsKey("Polly.Retry.Count"))
            {
                dependency.Properties["RetryCount"] = 
                    dependency.Properties["Polly.Retry.Count"];
            }
            
            // Track circuit breaker state
            if (dependency.Properties.ContainsKey("Polly.CircuitBreaker.State"))
            {
                dependency.Properties["CircuitBreakerState"] = 
                    dependency.Properties["Polly.CircuitBreaker.State"];
            }
        }
        
        _next.Process(item);
    }
}
```

### Dashboard Metrics

Track:
- Retry count per service
- Circuit breaker open/close events
- Timeout occurrences
- Fallback usage
- Success rate after retries

---

## Best Practices

### 1. Choose Appropriate Retry Count

**✅ Good:**
```csharp
// 3 retries for transient failures
.WaitAndRetryAsync(3, ...)
```

**❌ Bad:**
```csharp
// Too many retries can overwhelm service
.WaitAndRetryAsync(10, ...)
```

### 2. Use Exponential Backoff

**✅ Good:**
```csharp
// Exponential: 2s, 4s, 8s
sleepDurationProvider: retryAttempt => 
    TimeSpan.FromSeconds(Math.Pow(2, retryAttempt))
```

**❌ Bad:**
```csharp
// Fixed delay: 1s, 1s, 1s (can overwhelm service)
sleepDurationProvider: retryAttempt => TimeSpan.FromSeconds(1)
```

### 3. Set Reasonable Timeouts

**✅ Good:**
```csharp
// 5 seconds for API calls
.TimeoutAsync(TimeSpan.FromSeconds(5))
```

**❌ Bad:**
```csharp
// Too long - user will give up
.TimeoutAsync(TimeSpan.FromMinutes(5))
```

### 4. Implement Fallbacks

**✅ Good:**
```csharp
// Always have a fallback
.FallbackAsync(async () => GetCachedData())
```

**❌ Bad:**
```csharp
// No fallback - user gets error
// Just let exception propagate
```

### 5. Monitor Circuit Breaker State

**✅ Good:**
```csharp
// Log when circuit breaker opens/closes
onBreak: (exception, duration) => _logger.LogError(...)
onReset: () => _logger.LogInformation(...)
```

---

## Troubleshooting

### Issue 1: Circuit Breaker Never Closes

**Symptoms**: Circuit breaker stays open even after service recovers

**Solutions:**
```csharp
// Check duration of break is reasonable
durationOfBreak: TimeSpan.FromSeconds(30) // Not too long

// Verify test requests are being made
// Circuit breaker should transition to half-open after duration
```

### Issue 2: Too Many Retries

**Symptoms**: High latency, service overwhelmed

**Solutions:**
```csharp
// Reduce retry count
.WaitAndRetryAsync(2, ...) // Instead of 5

// Increase backoff delay
sleepDurationProvider: retryAttempt => 
    TimeSpan.FromSeconds(Math.Pow(3, retryAttempt)) // 3s, 9s, 27s
```

### Issue 3: Fallback Not Working

**Symptoms**: Users still get errors when fallback should trigger

**Solutions:**
```csharp
// Verify fallback policy is outermost
var policy = Policy.WrapAsync(
    fallbackPolicy,  // Must be outermost
    circuitBreaker,
    retryPolicy
);

// Check fallback conditions match
.Handle<HttpRequestException>() // Must match actual exceptions
```

---

## Real-World Example

### Complete Resilience Setup:

**OrderService calling ProductService:**

```csharp
// Policies
var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .WaitAndRetryAsync(3, retryAttempt => 
        TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));

var circuitBreaker = Policy
    .Handle<HttpRequestException>()
    .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30));

var timeout = Policy.TimeoutAsync<HttpResponseMessage>(5);

var fallback = Policy
    .Handle<HttpRequestException>()
    .FallbackAsync<HttpResponseMessage>(async () =>
        new HttpResponseMessage
        {
            Content = new StringContent(JsonSerializer.Serialize(GetCachedProducts())),
            StatusCode = HttpStatusCode.OK
        });

var resiliencePolicy = Policy.WrapAsync(fallback, circuitBreaker, timeout, retryPolicy);

// Usage
var response = await resiliencePolicy.ExecuteAsync(async () =>
    await _httpClient.GetAsync("http://productservice/api/products"));
```

**Flow:**
1. Try with retry (up to 3 times with exponential backoff)
2. If timeout (5 seconds) → Cancel
3. If circuit breaker open → Fail immediately
4. If all fail → Use fallback (cached data)

---

## Summary

POC-11 implements comprehensive failure handling:
- ✅ **Retry Policy**: Automatically retry failed requests with exponential backoff
- ✅ **Circuit Breaker**: Stop calling failing services temporarily
- ✅ **Timeout Policy**: Don't wait forever for responses
- ✅ **Fallback Policy**: Provide alternatives when services fail
- ✅ **Policy Composition**: Combine policies for robust resilience
- ✅ **Health Check Integration**: Reflect resilience state in health checks

This resilience foundation ensures your microservices can handle failures gracefully, maintain good user experience, and prevent cascading failures. Your system becomes more robust and reliable.

---

# POC-12: Async Notification Flow - Infrastructure Explanation

## Overview

POC-12 implements **asynchronous messaging** using Azure Service Bus. Instead of services calling each other directly (synchronously), services publish events to a message queue, and other services consume those events asynchronously. This decouples services, improves performance, and enables better scalability. Think of it as adding a "postal service" to your microservices - services send messages and don't wait for immediate responses.

---

## The Synchronous Communication Problem

### The Problem: Direct Service Calls

**Synchronous Flow:**
```
User creates order
  ↓
OrderService.CreateOrder()
  ↓
OrderService calls NotificationService.SendEmail() (waits for response)
  ↓
Email sent (takes 2-3 seconds)
  ↓
Response returned to user
```

**Problems:**
- ❌ **Slow**: User waits for email to be sent (2-3 seconds)
- ❌ **Tight Coupling**: OrderService depends on NotificationService
- ❌ **Failure Cascade**: If NotificationService is down, orders fail
- ❌ **Scaling Issues**: Can't scale services independently
- ❌ **No Retry**: If email fails, it's lost

### ✅ The Solution: Asynchronous Messaging

**Asynchronous Flow:**
```
User creates order
  ↓
OrderService.CreateOrder()
  ↓
OrderService publishes "OrderPlaced" event to Service Bus (instant)
  ↓
Response returned to user immediately ✅
  ↓
(Background) NotificationService consumes event
  ↓
(Background) Email sent
```

**Benefits:**
- ✅ **Fast**: User gets immediate response
- ✅ **Decoupled**: Services don't depend on each other directly
- ✅ **Resilient**: If NotificationService is down, messages queue up
- ✅ **Scalable**: Can scale consumers independently
- ✅ **Reliable**: Messages are persisted, can retry on failure

---

## What is Azure Service Bus?

### Analogy:

Think of **Azure Service Bus** like a **postal service**:
- **Publisher** = Sender (puts message in mailbox)
- **Queue** = Mailbox (holds messages)
- **Consumer** = Recipient (reads messages from mailbox)
- **Dead Letter Queue** = Returned mail (messages that couldn't be delivered)

### Service Bus Components:

1. **Namespace**: Container for queues and topics
2. **Queue**: First-In-First-Out (FIFO) message storage
3. **Topic**: Publish-Subscribe pattern (one message to many subscribers)
4. **Dead Letter Queue (DLQ)**: Failed messages go here

### How It Works:

```
Publisher Service
   │
   │ Creates message
   │
   ↓
Azure Service Bus Queue
   │
   │ Stores message
   │ (Persisted, durable)
   │
   ↓
Consumer Service
   │
   │ Reads message
   │ Processes it
   │ Marks as complete
```

---

## Message Flow: Step by Step

### 1. Publishing (OrderService)

```csharp
// OrderService creates order
var order = new Order { ... };
await _orderRepository.CreateAsync(order);

// Publish event to Service Bus
var message = new ServiceBusMessage(JsonSerializer.Serialize(
    new OrderPlacedEvent
    {
        OrderId = order.Id,
        CustomerEmail = order.CustomerEmail,
        ProductId = order.ProductId,
        Quantity = order.Quantity,
        CorrelationId = HttpContext.Items["CorrelationId"]?.ToString()
    }));

await _serviceBusSender.SendMessageAsync(message);
```

### 2. Consuming (NotificationService)

```csharp
// Background service consumes messages
public class NotificationProcessor : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await foreach (var message in _serviceBusReceiver.ReceiveMessagesAsync(stoppingToken))
        {
            try
            {
                // Process message
                var orderPlacedEvent = JsonSerializer.Deserialize<OrderPlacedEvent>(
                    message.Body.ToString());
                
                await SendNotificationAsync(orderPlacedEvent);
                
                // Mark as complete (remove from queue)
                await _serviceBusReceiver.CompleteMessageAsync(message);
            }
            catch (Exception ex)
            {
                // Dead letter on failure
                await _serviceBusReceiver.DeadLetterMessageAsync(message);
            }
        }
    }
}
```

### 3. Message Lifecycle

```
1. Message Published
   ↓
2. Message in Queue (waiting)
   ↓
3. Consumer receives message (locked)
   ↓
4a. Processing succeeds
    ↓
    Complete message (removed from queue)
    
4b. Processing fails
    ↓
    Dead letter message (moved to DLQ)
```

---

## Implementation: Publisher (OrderService)

### Step 1: Install Service Bus Package

```powershell
dotnet add package Azure.Messaging.ServiceBus
```

### Step 2: Configure Service Bus Client

**In Program.cs:**

```csharp
var builder = WebApplication.CreateBuilder(args);

// Get connection string from Key Vault
var serviceBusConnectionString = builder.Configuration
    ["ServiceBus:ConnectionString"];

// Register Service Bus client
builder.Services.AddSingleton(serviceProvider =>
{
    return new ServiceBusClient(serviceBusConnectionString);
});

// Register sender for publishing
builder.Services.AddSingleton(serviceProvider =>
{
    var client = serviceProvider.GetRequiredService<ServiceBusClient>();
    return client.CreateSender("notification-queue");
});

var app = builder.Build();
```

### Step 3: Publish Event

**OrderService.cs:**

```csharp
public class OrderService
{
    private readonly ServiceBusSender _serviceBusSender;
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly ILogger<OrderService> _logger;
    
    public OrderService(
        ServiceBusSender serviceBusSender,
        IHttpContextAccessor httpContextAccessor,
        ILogger<OrderService> logger)
    {
        _serviceBusSender = serviceBusSender;
        _httpContextAccessor = httpContextAccessor;
        _logger = logger;
    }
    
    public async Task<Order> CreateOrderAsync(OrderDto orderDto)
    {
        // Create order in database
        var order = new Order
        {
            ProductId = orderDto.ProductId,
            Quantity = orderDto.Quantity,
            CustomerEmail = orderDto.CustomerEmail,
            Status = "Pending"
        };
        
        await _orderRepository.CreateAsync(order);
        
        // Publish event asynchronously (fire and forget)
        _ = Task.Run(async () =>
        {
            try
            {
                var correlationId = _httpContextAccessor.HttpContext?
                    .Items["CorrelationId"]?.ToString();
                
                var orderPlacedEvent = new OrderPlacedEvent
                {
                    OrderId = order.Id,
                    CustomerEmail = order.CustomerEmail,
                    ProductId = order.ProductId,
                    Quantity = order.Quantity,
                    CorrelationId = correlationId,
                    Timestamp = DateTime.UtcNow
                };
                
                var messageBody = JsonSerializer.Serialize(orderPlacedEvent);
                var message = new ServiceBusMessage(messageBody);
                
                // Add correlation ID to message properties
                if (!string.IsNullOrEmpty(correlationId))
                {
                    message.CorrelationId = correlationId;
                }
                
                await _serviceBusSender.SendMessageAsync(message);
                
                _logger.LogInformation(
                    "OrderPlaced event published for order {OrderId} with correlation {CorrelationId}",
                    order.Id, correlationId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Failed to publish OrderPlaced event for order {OrderId}",
                    order.Id);
                // Don't fail order creation if event publishing fails
            }
        });
        
        return order; // Return immediately, notification happens in background
    }
}
```

---

## Implementation: Consumer (NotificationService)

### Step 1: Create Background Service

**NotificationProcessor.cs:**

```csharp
public class NotificationProcessor : BackgroundService
{
    private readonly ServiceBusProcessor _processor;
    private readonly ILogger<NotificationProcessor> _logger;
    private readonly INotificationService _notificationService;
    
    public NotificationProcessor(
        ServiceBusClient client,
        ILogger<NotificationProcessor> logger,
        INotificationService notificationService)
    {
        _logger = logger;
        _notificationService = notificationService;
        
        // Create processor for queue
        _processor = client.CreateProcessor("notification-queue", new ServiceBusProcessorOptions
        {
            MaxConcurrentCalls = 5, // Process 5 messages concurrently
            AutoCompleteMessages = false // Manual completion
        });
    }
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        // Register message handler
        _processor.ProcessMessageAsync += ProcessMessageAsync;
        _processor.ProcessErrorAsync += ProcessErrorAsync;
        
        // Start processing
        await _processor.StartProcessingAsync(stoppingToken);
        
        // Keep running until cancellation
        try
        {
            await Task.Delay(Timeout.Infinite, stoppingToken);
        }
        catch (TaskCanceledException)
        {
            // Expected when stopping
        }
    }
    
    private async Task ProcessMessageAsync(ProcessMessageEventArgs args)
    {
        try
        {
            var correlationId = args.Message.CorrelationId;
            
            _logger.LogInformation(
                "Processing notification message {MessageId} with correlation {CorrelationId}",
                args.Message.MessageId, correlationId);
            
            // Deserialize event
            var eventBody = args.Message.Body.ToString();
            var orderPlacedEvent = JsonSerializer.Deserialize<OrderPlacedEvent>(eventBody);
            
            if (orderPlacedEvent == null)
            {
                throw new InvalidOperationException("Invalid event format");
            }
            
            // Process notification
            await _notificationService.SendOrderConfirmationAsync(
                orderPlacedEvent.CustomerEmail,
                orderPlacedEvent.OrderId,
                orderPlacedEvent.ProductId,
                orderPlacedEvent.Quantity);
            
            _logger.LogInformation(
                "Notification sent for order {OrderId} with correlation {CorrelationId}",
                orderPlacedEvent.OrderId, correlationId);
            
            // Complete message (remove from queue)
            await args.CompleteMessageAsync(args.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Error processing notification message {MessageId}",
                args.Message.MessageId);
            
            // Dead letter the message (move to DLQ)
            await args.DeadLetterMessageAsync(args.Message, 
                reason: ex.GetType().Name,
                errorDescription: ex.Message);
        }
    }
    
    private Task ProcessErrorAsync(ProcessErrorEventArgs args)
    {
        _logger.LogError(args.Exception,
            "Service Bus error: {ErrorSource}",
            args.ErrorSource);
        return Task.CompletedTask;
    }
    
    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        await _processor.StopProcessingAsync(cancellationToken);
        await _processor.DisposeAsync();
        await base.StopAsync(cancellationToken);
    }
}
```

### Step 2: Register Background Service

**In Program.cs:**

```csharp
builder.Services.AddHostedService<NotificationProcessor>();
```

---

## Dead Letter Queue (DLQ)

### What is a Dead Letter Queue?

A **Dead Letter Queue (DLQ)** is a special queue where messages that couldn't be processed are stored.

### When Messages Go to DLQ:

1. **Processing Fails**: Exception during message processing
2. **Max Delivery Count**: Message delivered too many times (default: 10)
3. **Time to Live Expired**: Message too old
4. **Manual Dead Letter**: Explicitly dead lettered

### Why DLQ is Important:

- ✅ **Error Investigation**: See what failed and why
- ✅ **Manual Retry**: Can manually reprocess messages
- ✅ **Prevents Queue Blocking**: Failed messages don't block queue
- ✅ **Audit Trail**: Track problematic messages

### Processing DLQ Messages:

```csharp
// Create processor for DLQ
var dlqProcessor = client.CreateProcessor("notification-queue/$deadletterqueue");

dlqProcessor.ProcessMessageAsync += async (args) =>
{
    _logger.LogWarning(
        "Processing DLQ message {MessageId}. Reason: {DeadLetterReason}",
        args.Message.MessageId,
        args.Message.DeadLetterReason);
    
    // Investigate why it failed
    // Maybe fix data and reprocess
    // Or alert administrators
};
```

---

## Event Models

### Why Event Models?

Events represent "something happened" in your system. They should be:
- **Immutable**: Once created, don't change
- **Versioned**: Support multiple versions for compatibility
- **Self-Contained**: Include all needed data

### Example Event Model:

```csharp
public class OrderPlacedEvent
{
    [JsonPropertyName("orderId")]
    public int OrderId { get; set; }
    
    [JsonPropertyName("customerEmail")]
    public string CustomerEmail { get; set; }
    
    [JsonPropertyName("productId")]
    public int ProductId { get; set; }
    
    [JsonPropertyName("quantity")]
    public int Quantity { get; set; }
    
    [JsonPropertyName("correlationId")]
    public string CorrelationId { get; set; }
    
    [JsonPropertyName("timestamp")]
    public DateTime Timestamp { get; set; }
    
    [JsonPropertyName("eventVersion")]
    public string EventVersion { get; set; } = "1.0";
}
```

### Versioning Events:

```csharp
// Version 1.0
public class OrderPlacedEventV1
{
    public int OrderId { get; set; }
    public string CustomerEmail { get; set; }
}

// Version 2.0 (adds new field)
public class OrderPlacedEventV2
{
    public int OrderId { get; set; }
    public string CustomerEmail { get; set; }
    public string ShippingAddress { get; set; } // New field
}

// Consumer handles both versions
if (event.EventVersion == "1.0")
{
    // Handle V1
}
else if (event.EventVersion == "2.0")
{
    // Handle V2
}
```

---

## Best Practices

### 1. Idempotency

**Make message processing idempotent** (safe to process multiple times):

```csharp
// ✅ Good: Check if already processed
if (await _notificationRepository.ExistsAsync(orderId))
{
    _logger.LogInformation("Notification already sent for order {OrderId}", orderId);
    return; // Skip processing
}

await _notificationService.SendAsync(...);
await _notificationRepository.SaveAsync(orderId);
```

### 2. Correlation IDs

**Always include correlation ID**:

```csharp
message.CorrelationId = correlationId;
// Or
message.ApplicationProperties["CorrelationId"] = correlationId;
```

### 3. Error Handling

**Handle errors gracefully**:

```csharp
try
{
    await ProcessMessageAsync(message);
    await args.CompleteMessageAsync(args.Message);
}
catch (TransientException ex)
{
    // Retry later (don't complete, message will be redelivered)
    _logger.LogWarning(ex, "Transient error, will retry");
}
catch (Exception ex)
{
    // Dead letter permanent failures
    await args.DeadLetterMessageAsync(args.Message);
}
```

### 4. Message Size

**Keep messages small**:

```csharp
// ✅ Good: Send IDs, fetch details if needed
var event = new OrderPlacedEvent { OrderId = 123 };

// ❌ Bad: Send entire order object
var event = new OrderPlacedEvent { Order = fullOrderObject };
```

### 5. Monitoring

**Track message processing**:

```csharp
_logger.LogInformation(
    "Message processed: Queue={Queue}, MessageId={MessageId}, Duration={Duration}ms",
    queueName, messageId, duration);
```

---

## Troubleshooting

### Issue 1: Messages Not Being Consumed

**Symptoms**: Messages stuck in queue

**Solutions:**
```csharp
// Check processor is started
await _processor.StartProcessingAsync();

// Verify connection string
var connectionString = builder.Configuration["ServiceBus:ConnectionString"];

// Check queue exists
az servicebus queue show --name notification-queue
```

### Issue 2: Messages Going to DLQ Immediately

**Symptoms**: All messages dead lettered

**Solutions:**
```csharp
// Check MaxDeliveryCount (might be too low)
var options = new ServiceBusProcessorOptions
{
    MaxConcurrentCalls = 5,
    MaxAutoLockRenewDuration = TimeSpan.FromMinutes(5) // Renew lock
};

// Verify message format
var event = JsonSerializer.Deserialize<OrderPlacedEvent>(messageBody);
if (event == null) throw new InvalidOperationException("Invalid format");
```

### Issue 3: Duplicate Processing

**Symptoms**: Same message processed multiple times

**Solutions:**
```csharp
// Implement idempotency check
if (await _repository.ExistsAsync(orderId))
{
    return; // Already processed
}
```

---

## Real-World Example

### Complete Flow:

```
1. User creates order
   POST /api/orders
   ↓
2. OrderService creates order in database
   ↓
3. OrderService publishes OrderPlacedEvent to Service Bus
   (Returns 201 Created immediately)
   ↓
4. NotificationService consumes event (background)
   ↓
5. NotificationService sends email
   ↓
6. Message completed (removed from queue)
```

**If NotificationService is down:**
- Messages queue up in Service Bus
- When service recovers, processes queued messages
- No data loss!

---

## Summary

POC-12 implements asynchronous messaging for microservices:
- ✅ **Azure Service Bus**: Reliable message queuing
- ✅ **Event Publishing**: Services publish events instead of direct calls
- ✅ **Background Processing**: Consumers process messages asynchronously
- ✅ **Dead Letter Queue**: Handle failed messages gracefully
- ✅ **Correlation IDs**: Track events across services
- ✅ **Decoupling**: Services don't depend on each other directly

This asynchronous foundation enables better scalability, resilience, and performance. Services can operate independently and handle failures gracefully.

---

# POC-13: Scale Hot Services Only - Infrastructure Explanation

## Overview

POC-13 implements **Horizontal Pod Autoscaling (HPA)** - Kubernetes automatically scales the number of pods up or down based on CPU, memory, or custom metrics. This ensures you only scale services that need it, optimizing costs while maintaining performance. Think of it as having an "automatic traffic controller" that adds more lanes when traffic is heavy, and removes lanes when traffic is light.

---

## The Scaling Problem

### The Problem: Manual Scaling

**Without Autoscaling:**
```
High Traffic Period:
  - ProductService: 2 pods (overloaded, slow responses)
  - OrderService: 2 pods (overloaded, slow responses)
  - NotificationService: 2 pods (idle, wasting resources)

Low Traffic Period:
  - All services: 2 pods (most are idle, wasting money)
```

**Problems:**
- ❌ **Over-provisioning**: Paying for resources you don't need
- ❌ **Under-provisioning**: Services slow during peak times
- ❌ **Manual intervention**: Need to manually scale up/down
- ❌ **No optimization**: Can't scale individual services

### ✅ The Solution: Horizontal Pod Autoscaling (HPA)

**With HPA:**
```
High Traffic on OrderService:
  - OrderService: Auto-scales to 10 pods ✅
  - ProductService: Stays at 2 pods (not needed)
  - NotificationService: Stays at 2 pods (not needed)

Low Traffic:
  - All services: Auto-scale down to minimum (2 pods) ✅
```

**Benefits:**
- ✅ **Automatic**: Scales based on actual usage
- ✅ **Cost-effective**: Only scale what's needed
- ✅ **Per-service**: Each service scales independently
- ✅ **Responsive**: Reacts to traffic changes quickly

---

## What is Horizontal Pod Autoscaling (HPA)?

### Analogy:

Think of HPA like a **smart restaurant manager**:
- **Monitors**: How busy each section is (CPU, memory, requests)
- **Decides**: When to add more waiters (scale up) or send them home (scale down)
- **Acts**: Automatically adjusts staffing based on demand

### How HPA Works:

```
1. HPA monitors metrics (CPU, memory, requests)
   ↓
2. Compares to target (e.g., 70% CPU)
   ↓
3. Calculates desired replica count
   ↓
4. Updates Deployment
   ↓
5. Kubernetes creates/deletes pods
   ↓
6. Repeat every 15-30 seconds
```

### Scaling Triggers:

1. **CPU Utilization**: Pod CPU usage exceeds threshold
2. **Memory Utilization**: Pod memory usage exceeds threshold
3. **Custom Metrics**: Request rate, queue length, etc.

---

## HPA Configuration

### Basic HPA YAML:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: productservice-hpa
  namespace: microservices
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: productservice
  minReplicas: 2        # Minimum pods
  maxReplicas: 10       # Maximum pods
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70  # Target 70% CPU
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80  # Target 80% memory
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300  # Wait 5 min before scaling down
      policies:
      - type: Percent
        value: 50  # Scale down by 50% at a time
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0  # Scale up immediately
      policies:
      - type: Percent
        value: 100  # Can double pods
        periodSeconds: 60
      - type: Pods
        value: 2  # Or add 2 pods at a time
        periodSeconds: 60
      selectPolicy: Max  # Use the more aggressive policy
```

### Key Parameters Explained:

#### **minReplicas / maxReplicas**
- **minReplicas**: Always keep at least this many pods
- **maxReplicas**: Never scale beyond this many pods
- Prevents runaway scaling

#### **target averageUtilization**
- **70% CPU**: If average CPU across pods > 70%, scale up
- **80% Memory**: If average memory > 80%, scale up
- Lower threshold = more aggressive scaling

#### **behavior**
- **scaleDown**: How quickly to reduce pods
- **scaleUp**: How quickly to add pods
- Prevents thrashing (constant scaling up/down)

---

## Per-Service HPA Configuration

### ProductService HPA (Moderate Scale):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: productservice-hpa
  namespace: microservices
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: productservice
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### OrderService HPA (Higher Scale):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: orderservice-hpa
  namespace: microservices
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: orderservice
  minReplicas: 3        # Higher minimum (more traffic expected)
  maxReplicas: 20       # Higher maximum (can handle more load)
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### NotificationService HPA (Lower Scale):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: notificationservice-hpa
  namespace: microservices
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: notificationservice
  minReplicas: 2
  maxReplicas: 5        # Lower maximum (less traffic)
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

---

## Metrics Server

### What is Metrics Server?

**Metrics Server** collects resource usage data (CPU, memory) from pods and makes it available to HPA.

### Why Needed?

HPA needs metrics to make scaling decisions. Without Metrics Server, HPA can't see CPU/memory usage.

### Installation:

```powershell
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Verify:

```powershell
# Check metrics server is running
kubectl get deployment metrics-server -n kube-system

# Check if metrics are available
kubectl top pods -n microservices
```

---

## Scaling Behavior Example

### Scenario: Sudden Traffic Spike

```
Time 0:00 - Normal traffic
  OrderService: 3 pods, CPU: 50%
  
Time 0:01 - Traffic spike starts
  OrderService: 3 pods, CPU: 85% (above 70% threshold)
  
Time 0:15 - HPA checks metrics (every 15 seconds)
  Calculates: Need 4 pods to bring CPU to 70%
  Scales to 4 pods
  
Time 0:30 - Still high traffic
  OrderService: 4 pods, CPU: 75%
  HPA scales to 5 pods
  
Time 0:45 - Traffic continues
  OrderService: 5 pods, CPU: 72%
  HPA scales to 6 pods
  
Time 1:00 - Traffic stabilizes
  OrderService: 6 pods, CPU: 65% (below threshold)
  HPA waits (stabilization window: 5 minutes)
  
Time 6:00 - Still below threshold
  HPA scales down to 5 pods
  
Time 11:00 - Still below threshold
  HPA scales down to 4 pods
  
Time 16:00 - Still below threshold
  HPA scales down to 3 pods (minReplicas)
```

---

## Custom Metrics (Advanced)

### Request Rate Based Scaling:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: productservice-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: productservice
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"  # 100 requests per second per pod
```

**Benefits:**
- Scale based on actual business metrics (requests)
- More accurate than CPU for web services
- Better user experience

---

## Best Practices

### 1. Set Appropriate Min/Max

**✅ Good:**
```yaml
minReplicas: 2  # Always have redundancy
maxReplicas: 10  # Based on expected peak load
```

**❌ Bad:**
```yaml
minReplicas: 1  # No redundancy
maxReplicas: 100  # Too high, waste money
```

### 2. Use Stabilization Windows

**✅ Good:**
```yaml
scaleDown:
  stabilizationWindowSeconds: 300  # Wait before scaling down
```

**Prevents:**
- Scaling down too quickly
- Removing pods that are temporarily idle
- Thrashing (constant up/down)

### 3. Monitor Scaling Events

**Track:**
- How often services scale
- What triggers scaling
- Cost impact of scaling

### 4. Test Under Load

**Before production:**
- Load test your services
- Verify HPA scales appropriately
- Check costs at peak scale

---

## Troubleshooting

### Issue 1: HPA Not Scaling

**Symptoms**: Pods stay at minReplicas despite high CPU

**Solutions:**
```powershell
# Check HPA status
kubectl describe hpa productservice-hpa -n microservices

# Check metrics server
kubectl top pods -n microservices

# Verify resource requests are set
kubectl describe deployment productservice -n microservices
# Look for: Requests: cpu: 250m
```

### Issue 2: Scaling Too Aggressively

**Symptoms**: Pods scale up/down constantly

**Solutions:**
```yaml
# Increase stabilization window
scaleDown:
  stabilizationWindowSeconds: 600  # Wait 10 minutes

# Adjust target utilization
averageUtilization: 80  # Higher threshold (less aggressive)
```

### Issue 3: Not Scaling Down

**Symptoms**: Pods stay at high count even with low traffic

**Solutions:**
```yaml
# Reduce stabilization window
scaleDown:
  stabilizationWindowSeconds: 60  # Scale down faster

# Check if pods are actually idle
kubectl top pods -n microservices
```

---

## Cost Optimization

### Why "Scale Hot Services Only" Saves Money:

**Example:**
```
Without HPA:
  ProductService: 5 pods (always)
  OrderService: 5 pods (always)
  NotificationService: 5 pods (always)
  Total: 15 pods × $0.10/hour = $1.50/hour

With HPA (average):
  ProductService: 3 pods (average)
  OrderService: 4 pods (average, more traffic)
  NotificationService: 2 pods (average, less traffic)
  Total: 9 pods × $0.10/hour = $0.90/hour
  
Savings: 40% reduction in costs!
```

**Key Points:**
- Scale only when needed
- Each service scales independently
- Automatic optimization

---

## Summary

POC-13 implements intelligent autoscaling:
- ✅ **Horizontal Pod Autoscaling**: Automatic scaling based on metrics
- ✅ **Per-Service Configuration**: Each service scales independently
- ✅ **CPU/Memory Based**: Scale on resource utilization
- ✅ **Cost Optimization**: Only scale services that need it
- ✅ **Stabilization**: Prevent thrashing with windows
- ✅ **Custom Metrics**: Scale on business metrics (requests, queue length)

This autoscaling foundation ensures your services can handle traffic spikes automatically while optimizing costs. You only pay for what you need, when you need it.

---

# POC-14: Canary per Service - Infrastructure Explanation

## Overview

POC-14 implements **Canary Deployments** - a deployment strategy where you gradually roll out a new version to a small percentage of users, monitor it, and gradually increase traffic if it's healthy. This minimizes risk by catching issues early before they affect all users. Think of it as "testing the waters" before diving in completely.

---

## The Deployment Risk Problem

### The Problem: Big Bang Deployments

**Traditional Deployment:**
```
Deploy new version
  ↓
All traffic goes to new version immediately
  ↓
If bug exists → All users affected ❌
  ↓
Rollback (but damage done)
```

**Problems:**
- ❌ **High Risk**: All users see new version at once
- ❌ **Slow Detection**: Issues might not be noticed immediately
- ❌ **Big Impact**: If something breaks, everyone is affected
- ❌ **Difficult Rollback**: Need to rollback entire deployment

### ✅ The Solution: Canary Deployment

**Canary Deployment:**
```
Deploy new version (canary)
  ↓
Route 10% traffic to canary
  ↓
Monitor metrics (errors, latency)
  ↓
If healthy → Increase to 50%
  ↓
If still healthy → Increase to 100%
  ↓
If issues → Rollback canary (only 10% affected)
```

**Benefits:**
- ✅ **Low Risk**: Only small percentage sees new version
- ✅ **Early Detection**: Catch issues before full rollout
- ✅ **Gradual Rollout**: Increase traffic slowly
- ✅ **Easy Rollback**: Just remove canary, traffic goes back to stable

---

## What is a Canary Deployment?

### Analogy:

Think of **Canary Deployment** like **testing food at a restaurant**:
- **Canary Version** = New dish being tested
- **10% Traffic** = Small group of testers
- **Monitoring** = Watch for reactions (errors, complaints)
- **Gradual Increase** = If good, serve to more customers
- **Rollback** = If bad, stop serving it

### Historical Origin:

The name comes from **coal mining** - miners used canaries to detect toxic gas. If the canary died, they knew to evacuate. Similarly, if the canary version fails, you know to stop the deployment.

### Canary vs Other Strategies:

| Strategy | Risk | Rollback Speed | Traffic Split |
|----------|------|----------------|---------------|
| **Big Bang** | High | Slow | 100% new |
| **Blue-Green** | Medium | Fast | 100% new (after switch) |
| **Canary** | Low | Fast | Gradual (10% → 50% → 100%) |

---

## How Canary Deployment Works

### Step-by-Step Flow:

```
1. Deploy Canary Version
   ↓
   Canary pods running new version
   Stable pods running old version
   
2. Configure Traffic Split
   ↓
   90% → Stable version
   10% → Canary version
   
3. Monitor Canary
   ↓
   Check: Errors, latency, CPU, memory
   
4a. Canary Healthy
    ↓
    Increase to 50% canary, 50% stable
    ↓
    Monitor again
    ↓
    If still healthy → 100% canary
    ↓
    Remove stable version
    
4b. Canary Unhealthy
    ↓
    Rollback: Remove canary
    ↓
    100% traffic back to stable
    ↓
    Investigate issues
```

### Visual Representation:

```
Traffic Split Over Time:

Time 0:00
  ┌─────────────┐
  │ Stable: 100% │
  └─────────────┘

Time 0:05 (Canary deployed)
  ┌─────────────┐
  │ Stable: 90%  │
  │ Canary: 10% │
  └─────────────┘

Time 0:15 (Canary healthy)
  ┌─────────────┐
  │ Stable: 50% │
  │ Canary: 50% │
  └─────────────┘

Time 0:25 (Canary still healthy)
  ┌─────────────┐
  │ Canary: 100%│
  └─────────────┘
  (Stable removed)
```

---

## Implementation: Canary Deployment

### Step 1: Deploy Canary Version

**productservice-canary.yaml:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: productservice-canary
  namespace: microservices
  labels:
    app: productservice
    version: canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: productservice
      version: canary
  template:
    metadata:
      labels:
        app: productservice
        version: canary
    spec:
      containers:
      - name: productservice
        image: acr.azurecr.io/productservice:v2.0.0  # New version
        ports:
        - containerPort: 8080
```

**Apply:**
```powershell
kubectl apply -f productservice-canary.yaml -n microservices
```

### Step 2: Configure Traffic Split with Ingress

**Using NGINX Ingress Annotations:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: productservice-ingress
  namespace: microservices
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "10"  # 10% to canary
    nginx.ingress.kubernetes.io/canary-by-header: "X-Canary"
    nginx.ingress.kubernetes.io/canary-by-cookie: "canary"
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /products
        pathType: Prefix
        backend:
          service:
            name: productservice
            port:
              number: 80
```

### Step 3: Create Separate Services

**productservice-stable.yaml:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: productservice-stable
  namespace: microservices
spec:
  selector:
    app: productservice
    version: stable
  ports:
  - port: 80
    targetPort: 8080
```

**productservice-canary-svc.yaml:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: productservice-canary
  namespace: microservices
spec:
  selector:
    app: productservice
    version: canary
  ports:
  - port: 80
    targetPort: 8080
```

### Step 4: Update Ingress for Traffic Split

**ingress-with-canary.yaml:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: productservice-ingress
  namespace: microservices
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      # Stable service (90% traffic)
      - path: /products
        pathType: Prefix
        backend:
          service:
            name: productservice-stable
            port:
              number: 80
      # Canary service (10% traffic)
      - path: /products
        pathType: Prefix
        backend:
          service:
            name: productservice-canary
            port:
              number: 80
        # Canary annotations
        metadata:
          annotations:
            nginx.ingress.kubernetes.io/canary: "true"
            nginx.ingress.kubernetes.io/canary-weight: "10"
```

---

## Traffic Split Methods

### Method 1: Weight-Based (Percentage)

```yaml
annotations:
  nginx.ingress.kubernetes.io/canary: "true"
  nginx.ingress.kubernetes.io/canary-weight: "10"  # 10% to canary
```

**How it works:**
- 10% of requests → Canary
- 90% of requests → Stable
- Random distribution

### Method 2: Header-Based

```yaml
annotations:
  nginx.ingress.kubernetes.io/canary: "true"
  nginx.ingress.kubernetes.io/canary-by-header: "X-Canary"
  nginx.ingress.kubernetes.io/canary-by-header-value: "true"
```

**How it works:**
- Requests with `X-Canary: true` header → Canary
- All other requests → Stable
- Useful for internal testing

### Method 3: Cookie-Based

```yaml
annotations:
  nginx.ingress.kubernetes.io/canary: "true"
  nginx.ingress.kubernetes.io/canary-by-cookie: "canary"
```

**How it works:**
- Requests with `canary=always` cookie → Canary
- All other requests → Stable
- Useful for user opt-in testing

---

## Monitoring Canary

### Key Metrics to Monitor:

1. **Error Rate**
   - Compare canary vs stable
   - Canary should have similar or lower error rate

2. **Response Time**
   - Canary should not be significantly slower
   - P95, P99 latencies

3. **CPU/Memory Usage**
   - Check resource consumption
   - Ensure canary isn't resource-heavy

4. **Business Metrics**
   - Conversion rates
   - User engagement
   - Feature usage

### Application Insights Comparison:

```kusto
// Compare error rates
requests
| where timestamp > ago(1h)
| where cloud_RoleName == "productservice"
| summarize 
    ErrorRate = countif(success == false) * 100.0 / count(),
    AvgDuration = avg(duration)
    by bin(timestamp, 5m), customDimensions.version
| render timechart
```

**Expected:**
- Canary error rate ≈ Stable error rate
- Canary latency ≈ Stable latency

---

## Gradual Rollout Process

### Phase 1: Initial Canary (10%)

```powershell
# Deploy canary
kubectl apply -f productservice-canary.yaml

# Set 10% traffic
kubectl annotate ingress productservice-ingress \
  -n microservices \
  nginx.ingress.kubernetes.io/canary-weight=10

# Monitor for 15-30 minutes
kubectl get pods -n microservices -w
# Check Application Insights
```

**Success Criteria:**
- Error rate < 0.1%
- Response time < 200ms (P95)
- No critical issues reported

### Phase 2: Increase to 50%

```powershell
# If canary healthy, increase traffic
kubectl annotate ingress productservice-ingress \
  -n microservices \
  nginx.ingress.kubernetes.io/canary-weight=50 \
  --overwrite

# Monitor for 15-30 minutes
```

**Success Criteria:**
- Error rate still acceptable
- No performance degradation
- User feedback positive

### Phase 3: Full Rollout (100%)

```powershell
# If canary still healthy, full rollout
kubectl annotate ingress productservice-ingress \
  -n microservices \
  nginx.ingress.kubernetes.io/canary-weight=100 \
  --overwrite

# Wait for stable traffic
# Then remove stable deployment
kubectl delete deployment productservice-stable -n microservices
```

### Rollback Process:

```powershell
# If canary has issues, rollback immediately
kubectl annotate ingress productservice-ingress \
  -n microservices \
  nginx.ingress.kubernetes.io/canary-weight=0 \
  --overwrite

# Remove canary
kubectl delete deployment productservice-canary -n microservices

# All traffic back to stable
```

---

## Best Practices

### 1. Start Small

**✅ Good:**
```yaml
canary-weight: 10  # Start with 10%
```

**❌ Bad:**
```yaml
canary-weight: 50  # Too aggressive
```

### 2. Monitor Closely

**Monitor:**
- Error rates (every minute)
- Response times (P95, P99)
- Resource usage
- Business metrics

### 3. Have Rollback Plan

**Always:**
- Know how to rollback quickly
- Test rollback process
- Have monitoring alerts set up

### 4. Gradual Increase

**✅ Good:**
```
10% → Wait 30 min → 50% → Wait 30 min → 100%
```

**❌ Bad:**
```
10% → Immediately → 100%
```

### 5. Use Feature Flags

**Combine with feature flags:**
```csharp
// In canary version
if (featureFlags.EnableNewFeature)
{
    // New feature code
}
else
{
    // Old feature code
}
```

---

## Troubleshooting

### Issue 1: Canary Not Receiving Traffic

**Symptoms**: All traffic still goes to stable

**Solutions:**
```powershell
# Verify canary deployment exists
kubectl get deployment productservice-canary -n microservices

# Check ingress annotations
kubectl describe ingress productservice-ingress -n microservices

# Verify canary service selector matches deployment labels
kubectl get svc productservice-canary -n microservices -o yaml
```

### Issue 2: Canary Has High Error Rate

**Symptoms**: Canary showing more errors than stable

**Solutions:**
```powershell
# Immediately rollback
kubectl annotate ingress productservice-ingress \
  -n microservices \
  nginx.ingress.kubernetes.io/canary-weight=0

# Check canary logs
kubectl logs -l version=canary -n microservices

# Investigate issues before retrying
```

### Issue 3: Traffic Split Not Working

**Symptoms**: Traffic not split as expected

**Solutions:**
```powershell
# Check NGINX ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Verify annotations are correct
# Weight must be 0-100
```

---

## Real-World Example

### Complete Canary Deployment:

```
Day 1, 10:00 AM
  Deploy canary v2.0.0
  Set 10% traffic
  Monitor for 30 minutes
  
Day 1, 10:30 AM
  Canary healthy (error rate: 0.05%, latency: 150ms)
  Increase to 50% traffic
  Monitor for 30 minutes
  
Day 1, 11:00 AM
  Canary still healthy (error rate: 0.06%, latency: 155ms)
  Increase to 100% traffic
  Monitor for 1 hour
  
Day 1, 12:00 PM
  Canary stable, no issues
  Remove stable deployment
  Canary becomes new stable
```

**If Issues Found:**
```
Day 1, 10:15 AM
  Canary shows error rate: 2% (too high!)
  Immediately rollback to 0%
  Remove canary
  Investigate issues
  Fix and retry later
```

---

## Summary

POC-14 implements safe, gradual deployments:
- ✅ **Canary Deployment**: Test new versions with small traffic percentage
- ✅ **Traffic Splitting**: Route percentage of traffic to canary
- ✅ **Gradual Rollout**: Increase traffic slowly (10% → 50% → 100%)
- ✅ **Monitoring**: Track canary vs stable metrics
- ✅ **Quick Rollback**: Remove canary if issues detected
- ✅ **Risk Mitigation**: Only small percentage affected if issues exist

This canary deployment strategy minimizes risk and allows you to catch issues early before they affect all users. It's a production-ready deployment pattern that gives you confidence in your releases.

---

# POC-15: Microservice Security Hardening - Infrastructure Explanation

## Overview

POC-15 implements **security hardening** - additional layers of protection for your microservices. This includes Web Application Firewall (WAF), security headers, rate limiting, and DDoS protection. Think of it as adding "security guards, firewalls, and access controls" to protect your services from attacks.

---

## The Security Threat Landscape

### Common Attacks:

1. **SQL Injection**: Malicious SQL in user input
2. **Cross-Site Scripting (XSS)**: Injecting malicious scripts
3. **DDoS Attacks**: Overwhelming services with traffic
4. **Rate Limiting Bypass**: Too many requests from one source
5. **Information Disclosure**: Exposing server details in headers

### ✅ The Solution: Defense in Depth

**Multiple Security Layers:**
- **WAF**: Block malicious requests
- **Security Headers**: Prevent common attacks
- **Rate Limiting**: Prevent abuse
- **DDoS Protection**: Handle traffic floods

---

## Web Application Firewall (WAF)

### What is WAF?

**WAF** is a firewall that filters HTTP/HTTPS traffic to protect web applications from attacks.

### How WAF Works:

```
Malicious Request
   ↓
WAF Analyzes Request
   ↓
Checks Against Rules (OWASP Top 10)
   ↓
If Malicious → Block ❌
If Safe → Allow ✅
```

### OWASP Top 10 Protection:

1. **Injection** (SQL, NoSQL, Command)
2. **Broken Authentication**
3. **Sensitive Data Exposure**
4. **XML External Entities (XXE)**
5. **Broken Access Control**
6. **Security Misconfiguration**
7. **Cross-Site Scripting (XSS)**
8. **Insecure Deserialization**
9. **Using Components with Known Vulnerabilities**
10. **Insufficient Logging & Monitoring**

### Implementation:

**Azure Application Gateway with WAF:**

```powershell
# Create Application Gateway with WAF
az network application-gateway create \
  --name agw-microservices \
  --resource-group rg-microservices-poc \
  --location eastus \
  --capacity 2 \
  --sku WAF_v2 \
  --waf-policy waf-policy-microservices
```

**WAF Policy Configuration:**

```powershell
# Create WAF policy
az network application-gateway waf-policy create \
  --name waf-policy-microservices \
  --resource-group rg-microservices-poc

# Enable OWASP rules
az network application-gateway waf-policy managed-rule-set add \
  --policy-name waf-policy-microservices \
  --resource-group rg-microservices-poc \
  --type OWASP \
  --version 3.2
```

---

## Security Headers

### Why Security Headers?

Security headers tell browsers how to handle your content, preventing common attacks.

### Key Security Headers:

#### **1. HSTS (HTTP Strict Transport Security)**
```csharp
Strict-Transport-Security: max-age=31536000; includeSubDomains
```
**Purpose**: Force HTTPS, prevent downgrade attacks

#### **2. X-Content-Type-Options**
```csharp
X-Content-Type-Options: nosniff
```
**Purpose**: Prevent MIME type sniffing

#### **3. X-Frame-Options**
```csharp
X-Frame-Options: DENY
```
**Purpose**: Prevent clickjacking attacks

#### **4. Content-Security-Policy**
```csharp
Content-Security-Policy: default-src 'self'
```
**Purpose**: Control which resources can be loaded

### Implementation:

**Security Headers Middleware:**

```csharp
public class SecurityHeadersMiddleware
{
    private readonly RequestDelegate _next;
    
    public SecurityHeadersMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        // Add security headers
        context.Response.Headers.Add("Strict-Transport-Security", 
            "max-age=31536000; includeSubDomains");
        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
        context.Response.Headers.Add("X-Frame-Options", "DENY");
        context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
        context.Response.Headers.Add("Content-Security-Policy", 
            "default-src 'self'; script-src 'self' 'unsafe-inline'");
        
        // Remove server header
        context.Response.Headers.Remove("Server");
        
        await _next(context);
    }
}
```

---

## Rate Limiting

### What is Rate Limiting?

**Rate Limiting** restricts the number of requests a client can make in a given time period.

### Why Rate Limiting?

- ✅ **Prevent Abuse**: Stop malicious users
- ✅ **Protect Resources**: Prevent overload
- ✅ **Fair Usage**: Ensure fair access

### Implementation:

**NGINX Ingress Rate Limiting:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: productservice-ingress
  annotations:
    nginx.ingress.kubernetes.io/limit-rps: "100"  # 100 requests per second
    nginx.ingress.kubernetes.io/limit-connections: "10"  # 10 concurrent connections
spec:
  # ...
```

**Application-Level Rate Limiting:**

```csharp
// Install: AspNetCoreRateLimit
builder.Services.AddMemoryCache();
builder.Services.Configure<IpRateLimitOptions>(options =>
{
    options.GeneralRules = new List<RateLimitRule>
    {
        new RateLimitRule
        {
            Endpoint = "*",
            Limit = 100,
            Period = "1m"  // 100 requests per minute
        }
    };
});
```

---

## DDoS Protection

### What is DDoS?

**DDoS (Distributed Denial of Service)** is an attack that floods a service with traffic to make it unavailable.

### Azure DDoS Protection:

```powershell
# Create DDoS Protection Plan
az network ddos-protection plan create \
  --name ddos-plan-microservices \
  --resource-group rg-microservices-poc \
  --location eastus

# Associate with Virtual Network
az network vnet update \
  --name aks-vnet \
  --resource-group rg-microservices-poc \
  --ddos-protection-plan ddos-plan-microservices \
  --protection-mode Enabled
```

**Protection Levels:**
- **Basic**: Automatic mitigation (always on)
- **Standard**: Advanced mitigation with alerts

---

## Summary

POC-15 implements comprehensive security hardening:
- ✅ **WAF**: Block malicious requests at the edge
- ✅ **Security Headers**: Prevent common browser-based attacks
- ✅ **Rate Limiting**: Prevent abuse and overload
- ✅ **DDoS Protection**: Handle traffic floods
- ✅ **Defense in Depth**: Multiple security layers

This security hardening ensures your microservices are protected from common attacks and can handle malicious traffic gracefully.

---

# POC-16: Cost Visibility - Infrastructure Explanation

## Overview

POC-16 implements **cost visibility** - the ability to see how much each service costs. In microservices, different services consume different resources, and you need to track costs per service to optimize spending. Think of it as adding "itemized billing" so you know exactly what each service costs.

---

## The Cost Problem

### The Problem: Unknown Costs

**Without Cost Visibility:**
```
Total Azure Bill: $1,000/month
  ↓
Which service costs what?
  ↓
Can't optimize spending
  ↓
Wasting money on unused resources
```

### ✅ The Solution: Resource Tagging

**With Cost Visibility:**
```
Total Azure Bill: $1,000/month
  ├─ ProductService: $300 (30%)
  ├─ OrderService: $500 (50%)
  ├─ NotificationService: $100 (10%)
  └─ Shared Infrastructure: $100 (10%)
  
Now you can optimize!
```

---

## Resource Tagging Strategy

### What are Tags?

**Tags** are key-value pairs you attach to Azure resources for organization and cost tracking.

### Tagging Strategy:

```hcl
# Terraform tags
tags = {
  Environment    = "dev"           # dev, staging, prod
  Service        = "productservice" # Which service
  CostCenter     = "Engineering"    # Who pays
  Owner          = "team-alpha"     # Who owns it
  Project        = "microservices"  # Which project
  ManagedBy      = "terraform"      # How it's managed
}
```

### Implementation:

**In Terraform:**

```hcl
variable "common_tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "microservices"
    ManagedBy   = "terraform"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  # ...
  tags = merge(var.common_tags, {
    Service = "shared"
    CostCenter = "Infrastructure"
  })
}

resource "azurerm_sql_database" "productdb" {
  # ...
  tags = merge(var.common_tags, {
    Service = "productservice"
    CostCenter = "Engineering"
  })
}
```

---

## Cost Analysis

### View Costs by Service:

**Azure Portal → Cost Management → Cost Analysis**

**Group by Tag:**
- Group by: `Service`
- Filter: `Environment = prod`
- Time range: Last 30 days

**Results:**
```
Service              | Cost    | Percentage
---------------------|---------|-----------
productservice       | $300    | 30%
orderservice         | $500    | 50%
notificationservice  | $100    | 10%
shared               | $100    | 10%
```

### Cost Alerts:

**Create Budget:**

```powershell
az consumption budget create \
  --budget-name microservices-monthly \
  --amount 1000 \
  --time-grain Monthly \
  --start-date 2024-01-01 \
  --resource-group rg-microservices-poc
```

**Set Alert Thresholds:**
- 50% of budget → Warning email
- 80% of budget → Alert email
- 100% of budget → Critical alert

---

## Cost Optimization

### Identify Expensive Services:

1. **View Cost Analysis**
   - See which service costs most
   - Identify trends

2. **Right-Size Resources**
   - Reduce pod CPU/memory if over-provisioned
   - Use appropriate database tiers

3. **Reserved Instances**
   - For stable workloads
   - Save up to 72%

4. **Auto-Scaling**
   - Scale down during low traffic
   - Only pay for what you use

---

## Summary

POC-16 implements cost visibility and optimization:
- ✅ **Resource Tagging**: Track costs per service
- ✅ **Cost Analysis**: View spending by service
- ✅ **Budget Alerts**: Get notified of spending
- ✅ **Cost Optimization**: Identify and reduce waste

This cost visibility ensures you can optimize spending and only pay for what you need.

---

# POC-17: Partial DR (Disaster Recovery) - Infrastructure Explanation

## Overview

POC-17 implements **Disaster Recovery (DR)** - the ability to recover from failures. In microservices, you can recover individual services independently (partial DR), rather than recovering everything at once. Think of it as having "backup plans" for each service so you can restore them individually if needed.

---

## Disaster Recovery Concepts

### Key Terms:

**RPO (Recovery Point Objective)**: Maximum acceptable data loss
- Example: RPO of 1 hour = Can lose up to 1 hour of data

**RTO (Recovery Time Objective)**: Maximum acceptable downtime
- Example: RTO of 4 hours = Must be back online within 4 hours

### Partial DR Benefits:

- ✅ **Service-Specific**: Restore only affected services
- ✅ **Faster Recovery**: Don't need to restore everything
- ✅ **Cost-Effective**: Only restore what's needed
- ✅ **Independent**: Services don't affect each other

---

## Automated Backups

### Azure SQL Backups:

**Automatic Backups:**
- Full backups: Weekly
- Differential backups: Every 12-24 hours
- Transaction log backups: Every 5-10 minutes
- Retention: 7-35 days (configurable)

**Verify Backup Policy:**

```powershell
az sql db show \
  --resource-group rg-microservices-poc \
  --server mysqlserver \
  --name ProductDb \
  --query backupLongTermRetentionPolicy
```

---

## Restore Procedures

### Point-in-Time Restore:

```powershell
# Restore to specific time
az sql db restore \
  --resource-group rg-microservices-poc \
  --server mysqlserver \
  --name ProductDb \
  --dest-name ProductDb-restored \
  --time "2024-01-15T10:00:00Z"
```

### Service-Specific Restore:

**Restore ProductService Only:**

```
1. Restore ProductDb to point in time
   ↓
2. Update ProductService connection string
   ↓
3. Restart ProductService pods
   ↓
4. Verify ProductService works
   ↓
5. Other services unaffected ✅
```

---

## RPO/RTO Documentation

### Example DR Runbook:

```
Service: ProductService
RPO: 1 hour (can lose up to 1 hour of data)
RTO: 2 hours (must be back online within 2 hours)

Backup Strategy:
- Full backup: Weekly
- Transaction log: Every 5 minutes

Restore Procedure:
1. Identify point in time
2. Restore ProductDb
3. Update connection string
4. Restart service
5. Verify functionality

Test Frequency: Quarterly
```

---

## Summary

POC-17 implements disaster recovery:
- ✅ **Automated Backups**: Regular database backups
- ✅ **Point-in-Time Restore**: Restore to specific time
- ✅ **Service-Specific Recovery**: Restore individual services
- ✅ **RPO/RTO Documentation**: Clear recovery objectives

This DR foundation ensures you can recover from failures quickly and minimize data loss.

---

# POC-18: Service Incident Simulation - Infrastructure Explanation

## Overview

POC-18 implements **chaos engineering** - intentionally breaking things to test your system's resilience. By simulating failures, you verify that your monitoring, alerts, and recovery procedures work correctly. Think of it as "fire drills" for your microservices - you practice handling failures so you're ready when real incidents occur.

---

## Why Incident Simulation?

### The Problem: Unknown Failure Modes

**Without Testing:**
```
Real Incident Occurs
  ↓
System Fails Unexpectedly
  ↓
Team Doesn't Know How to Respond
  ↓
Extended Downtime ❌
```

### ✅ The Solution: Practice Failures

**With Simulation:**
```
Simulate Failure
  ↓
Test Response Procedures
  ↓
Verify Monitoring Works
  ↓
Document Lessons Learned
  ↓
Ready for Real Incidents ✅
```

---

## Chaos Engineering Principles

### 1. Start Small

**Begin with:**
- Single pod failure
- One service down
- Network latency

**Then progress to:**
- Multiple service failures
- Database failures
- Regional outages

### 2. Test in Non-Production First

**Always:**
- Test in dev/staging first
- Verify procedures work
- Then test in production (carefully)

### 3. Have Rollback Plan

**Before testing:**
- Know how to restore
- Have rollback procedures ready
- Test rollback first

---

## Incident Simulation Scenarios

### Scenario 1: Service Pod Failure

```powershell
# Kill OrderService pods
kubectl scale deployment orderservice --replicas=0 -n microservices

# Observe:
# - Application Insights alerts fire
# - Other services continue working
# - Circuit breakers activate
# - Users see graceful degradation
```

### Scenario 2: Database Failure

```powershell
# Stop database (simulate)
az sql db pause --name ProductDb --server mysqlserver

# Observe:
# - Health checks fail
# - Services show degraded state
# - Alerts fire
# - Fallback mechanisms activate
```

### Scenario 3: High Latency

```powershell
# Add network latency (using chaos mesh or similar)
# Simulate slow ProductService

# Observe:
# - Timeout policies trigger
# - Retry policies activate
# - Fallback data used
```

---

## Incident Response Playbook

### Template:

```
Incident: [Service Name] Failure

1. Detection
   - Alert received: [Alert name]
   - Time: [Timestamp]
   - Detected by: [Monitoring system]

2. Impact Assessment
   - Affected services: [List]
   - User impact: [Description]
   - Business impact: [Description]

3. Response
   - Actions taken: [List]
   - Timeline: [Timeline]
   - Rollback: [Yes/No]

4. Root Cause
   - Cause: [Description]
   - Contributing factors: [List]

5. Resolution
   - Fix applied: [Description]
   - Verification: [How verified]

6. Prevention
   - Changes made: [List]
   - Monitoring added: [List]
   - Process improvements: [List]
```

---

## RCA (Root Cause Analysis) Template

```
Title: [Incident Title]
Date: [Date]
Duration: [How long]
Impact: [What was affected]

Timeline:
- [Time] - [Event]
- [Time] - [Event]

Root Cause:
[Detailed explanation]

Contributing Factors:
1. [Factor 1]
2. [Factor 2]

Resolution:
[What was done to fix]

Prevention:
1. [Action 1]
2. [Action 2]

Lessons Learned:
[Key takeaways]
```

---

## Testing Recovery Procedures

### Test Rollback:

```powershell
# Deploy problematic version
kubectl apply -f deployment-v2-buggy.yaml

# Verify issues
# Check logs, metrics

# Rollback
kubectl rollout undo deployment productservice -n microservices

# Verify rollback successful
kubectl rollout status deployment productservice -n microservices
```

### Test Monitoring:

**Verify:**
- Alerts fire correctly
- Dashboards update
- Notifications sent
- On-call engineer notified

---

## Summary

POC-18 implements incident simulation and response:
- ✅ **Chaos Engineering**: Test system resilience
- ✅ **Incident Simulation**: Practice handling failures
- ✅ **Response Playbooks**: Document procedures
- ✅ **RCA Templates**: Learn from incidents
- ✅ **Recovery Testing**: Verify procedures work

This incident simulation ensures your team is prepared for real failures and can respond quickly and effectively.

---

## 🎉 Complete Microservices Journey

Congratulations! You've completed all POCs from POC-5 through POC-18. You now have:

- ✅ **Kubernetes Deployment**: Services running in AKS
- ✅ **Health Probes**: Automatic recovery
- ✅ **Ingress Routing**: Single entry point
- ✅ **Security**: Key Vault, JWT, WAF
- ✅ **Database Isolation**: Per-service databases
- ✅ **Observability**: Distributed tracing, logging
- ✅ **Resilience**: Retry, circuit breaker, fallback
- ✅ **Async Messaging**: Service Bus integration
- ✅ **Autoscaling**: HPA per service
- ✅ **Canary Deployments**: Safe rollouts
- ✅ **Security Hardening**: WAF, rate limiting
- ✅ **Cost Visibility**: Track spending per service
- ✅ **Disaster Recovery**: Backup and restore
- ✅ **Incident Response**: Chaos testing

Your microservices architecture is now production-ready! 🚀

---





