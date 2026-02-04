# 🔥 High-Impact Scenario-Based PoCs - Interview Practice Guide

> **This is exactly how interviews are going now** — **pure scenario + architecture + performance thinking**, not theory.

This guide contains **curated REAL interview-grade PoC scenarios** you can practice. Each item includes **what interviewer expects + what you should design/code**.

---

## 📋 Table of Contents

1. [3 GB File Upload – Faster & Reliable](#1-3-gb-file-upload--faster--reliable)
2. [1 Lakh Live Records in Angular Dashboard](#2-1-lakh-live-records-in-angular-dashboard)
3. [Clean Architecture – Order Management](#3-clean-architecture--order-management)
4. [CQRS – Product Catalog](#4-cqrs--product-catalog)
5. [Repository + Unit of Work – Transaction Safety](#5-repository--unit-of-work--transaction-safety)
6. [Factory Pattern – Payment Gateway](#6-factory-pattern--payment-gateway)
7. [Rate Limiting – Public API Protection](#7-rate-limiting--public-api-protection)
8. [Idempotency – Avoid Duplicate Orders](#8-idempotency--avoid-duplicate-orders)
9. [Async Processing – Email / SMS](#9-async-processing--email--sms)
10. [Caching Strategy – Heavy Read APIs](#10-caching-strategy--heavy-read-apis)
11. [Soft Delete + Audit](#11-soft-delete--audit)
12. [Global Exception Handling](#12-global-exception-handling)
13. [Concurrency Handling](#13-concurrency-handling)
14. [Search Optimization](#14-search-optimization)
15. [Feature Toggle](#15-feature-toggle)

---

## 1️⃣ 3 GB File Upload – Faster & Reliable

### Scenario

> User uploads a 3GB video → should not fail, should resume if network breaks.

### Expected Thinking

- ✅ Chunk upload (split into smaller pieces)
- ✅ Parallel upload (multiple chunks simultaneously)
- ✅ Resume support (continue from where it stopped)
- ✅ No API timeout (handle long-running operations)
- ✅ Progress tracking (show upload percentage)
- ✅ Direct cloud upload (optional - bypass API server)

### PoC Design

**Angular Side:**
- Split file into 5–10 MB chunks
- Upload chunks in parallel (3-5 concurrent)
- Track chunk upload status
- Resume failed chunks
- Show progress bar

**API Side:**
- Receive chunks with metadata (chunk number, total chunks, file hash)
- Store chunks temporarily (Blob Storage / S3)
- Validate chunk integrity
- Merge chunks on completion
- Optional: Generate pre-signed URLs for direct upload

**Database:**
- Track upload session (FileId, TotalChunks, CompletedChunks, Status)
- Store file metadata (Name, Size, Type, UploadDate)

### Patterns Used

- **Factory Pattern** - Choose storage provider (Azure Blob / AWS S3 / Local)
- **Clean Architecture** - Upload domain separated from infrastructure
- **Strategy Pattern** - Different upload strategies (chunked, direct, resumable)

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: Upload entire file at once
[HttpPost]
public async Task<IActionResult> Upload(IFormFile file)
{
    // This will timeout for 3GB file!
    using var stream = file.OpenReadStream();
    await storage.SaveAsync(stream);
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Chunked upload with resume support
[HttpPost("chunk")]
public async Task<IActionResult> UploadChunk(
    [FromForm] IFormFile chunk,
    [FromForm] string fileId,
    [FromForm] int chunkNumber,
    [FromForm] int totalChunks)
{
    // Validate chunk
    // Store chunk with metadata
    // Update upload session
    // Return chunk status
}

[HttpPost("complete")]
public async Task<IActionResult> CompleteUpload(string fileId)
{
    // Merge all chunks
    // Validate file integrity
    // Return final file URL
}
```

### Scalability Explanation

- **Horizontal Scaling**: Multiple API instances can handle different chunks
- **Storage**: Use cloud storage (S3/Blob) for scalability
- **Resume**: Client can retry failed chunks without re-uploading entire file
- **Performance**: Parallel uploads reduce total upload time significantly

---

## 2️⃣ 1 Lakh Live Records in Angular Dashboard

### Scenario

> Admin dashboard shows 1 lakh (100,000) live records, filtering + scrolling should be smooth.

### Expected Thinking

- ✅ Never load all data at once
- ✅ Server-side pagination (API handles pagination)
- ✅ Virtual scrolling (render only visible items)
- ✅ Debounced filters (wait for user to stop typing)
- ✅ Keyset pagination (faster than OFFSET)
- ✅ Lazy loading (load as user scrolls)

### PoC Design

**API Side:**
- Endpoint: `GET /api/users?pageNo=1&pageSize=50&sortBy=name&sortOrder=asc&search=john`
- SQL: Use `OFFSET-FETCH` or keyset pagination
- Return: `{ data: [], totalCount: 100000, pageNo: 1, pageSize: 50 }`
- Index: Ensure indexed columns for filtering/sorting

**Angular Side:**
- Virtual scrolling (CDK Virtual Scroll)
- Debounced search (RxJS debounceTime)
- Infinite scroll or pagination controls
- Loading states and error handling

#### 🔍 Beginner Explanation: Angular Techniques

**1. Virtual Scrolling (CDK Virtual Scroll) - What is it?**
```
Imagine you have a window (viewport) that shows only 10 items at a time.
Instead of rendering all 100,000 items in the DOM (which would crash the browser),
virtual scrolling only renders the items that are VISIBLE on screen.

Think of it like a window in a tall building:
- You only see what's in the window
- As you scroll, the window "moves" and shows different items
- Items outside the window are not rendered (saves memory)

Example: If you have 100,000 records but only see 10 at a time,
Angular only creates 10-20 DOM elements (not 100,000!)
```

**2. Debounced Search (RxJS debounceTime) - What is it?**
```
When a user types in a search box, instead of making an API call for EVERY keystroke,
we wait until the user STOPS typing for a moment (e.g., 300ms).

Without debouncing:
User types "john" → API calls: j → jo → joh → john (4 API calls!)

With debouncing:
User types "john" → Wait 300ms after last keystroke → API call: "john" (1 API call!)

This saves server resources and improves performance.
```

**3. Infinite Scroll or Pagination Controls - What is it?**
```
Two ways to load more data:

Infinite Scroll:
- User scrolls to bottom → Automatically loads next page
- Like Facebook/Twitter feed
- User never clicks "Next" button

Pagination Controls:
- User clicks "Next" or "Page 2" button
- Like Google search results
- User controls when to load next page

Both load data in chunks (e.g., 50 records at a time) instead of all at once.
```

**4. Loading States and Error Handling - What is it?**
```
Loading States:
- Show a spinner/loader while data is being fetched
- User knows something is happening
- Prevents confusion when API is slow

Error Handling:
- If API fails, show a friendly error message
- Don't crash the app
- Maybe retry or show "Try again" button

Example:
- Loading: "Loading users..." with spinner
- Success: Show the data
- Error: "Failed to load. Please try again."
```

### Patterns Used

- **Repository Pattern** - Abstract data access
- **CQRS** - Separate read/write models (read optimized)
- **Specification Pattern** - Dynamic filter building

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: Load all records
[HttpGet]
public async Task<List<User>> GetUsers()
{
    return await _context.Users.ToListAsync(); // Loads 100k records!
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Server-side pagination
[HttpGet]
public async Task<PagedResult<UserDto>> GetUsers(
    [FromQuery] int pageNo = 1,
    [FromQuery] int pageSize = 50,
    [FromQuery] string sortBy = "name",
    [FromQuery] string sortOrder = "asc",
    [FromQuery] string search = "")
{
    var query = _context.Users.AsQueryable();
    
    // Apply search filter
    if (!string.IsNullOrEmpty(search))
    {
        query = query.Where(u => u.Name.Contains(search));
    }
    
    // Apply sorting
    query = sortOrder == "asc" 
        ? query.OrderBy(GetSortExpression(sortBy))
        : query.OrderByDescending(GetSortExpression(sortBy));
    
    // Get total count
    var totalCount = await query.CountAsync();
    
    // Apply pagination
    var data = await query
        .Skip((pageNo - 1) * pageSize)
        .Take(pageSize)
        .Select(u => new UserDto { Id = u.Id, Name = u.Name })
        .ToListAsync();
    
    return new PagedResult<UserDto>
    {
        Data = data,
        TotalCount = totalCount,
        PageNo = pageNo,
        PageSize = pageSize
    };
}
```

**Angular Virtual Scroll:**
```typescript
// Virtual scrolling component
<cdk-virtual-scroll-viewport itemSize="50" class="viewport">
  <div *cdkVirtualFor="let user of users$ | async">
    {{ user.name }}
  </div>
</cdk-virtual-scroll-viewport>

// Debounced search
this.searchControl.valueChanges
  .pipe(debounceTime(300), distinctUntilChanged())
  .subscribe(search => this.loadUsers(search));
```

### Scalability Explanation

- **Database**: Indexes on filtered/sorted columns
- **Memory**: Only 50 records in DOM at a time
- **Network**: Small payload per request
- **Performance**: Smooth scrolling even with millions of records

---

## 3️⃣ Clean Architecture – Order Management

### Scenario

> Build Order module that should survive future changes (DB, UI, cloud).

### Expected Thinking

- ✅ Dependency rule (dependencies point inward)
- ✅ No EF in Domain layer
- ✅ Interface-driven design
- ✅ Business logic in Domain
- ✅ Infrastructure is pluggable

### PoC Structure

```
OrderManagement/
├── Domain/
│   ├── Entities/
│   │   └── Order.cs
│   ├── ValueObjects/
│   │   └── Money.cs
│   ├── Interfaces/
│   │   └── IOrderRepository.cs
│   └── Exceptions/
│       └── OrderDomainException.cs
├── Application/
│   ├── Commands/
│   │   └── CreateOrderCommand.cs
│   ├── Queries/
│   │   └── GetOrderQuery.cs
│   ├── DTOs/
│   │   └── OrderDto.cs
│   └── Interfaces/
│       └── IOrderService.cs
├── Infrastructure/
│   ├── Data/
│   │   └── OrderRepository.cs (implements IOrderRepository)
│   └── Persistence/
│       └── ApplicationDbContext.cs
└── API/
    ├── Controllers/
    │   └── OrdersController.cs
    └── Program.cs
```

### Interview Focus

**Dependency Rule:**
- Domain has NO dependencies
- Application depends on Domain
- Infrastructure depends on Application and Domain
- API depends on all layers

**No EF in Domain:**
```csharp
// ✅ GOOD: Domain entity (no EF attributes)
public class Order
{
    public int Id { get; private set; }
    public Money TotalAmount { get; private set; }
    public OrderStatus Status { get; private set; }
    
    // Business logic
    public void AddItem(OrderItem item)
    {
        // Domain logic here
    }
}

// ❌ BAD: EF attributes in Domain
[Table("Orders")]
public class Order
{
    [Key]
    public int Id { get; set; } // Don't do this!
}
```

### Patterns Used

- **Clean Architecture** - Separation of concerns
- **Dependency Inversion** - Depend on abstractions
- **Repository Pattern** - Abstract data access

### Scalability Explanation

- **Database Change**: Only Infrastructure layer changes
- **UI Change**: Only API layer changes
- **Cloud Migration**: Swap Infrastructure implementation
- **Business Logic**: Centralized in Domain, easy to test

---

## 4️⃣ CQRS – Product Catalog

### Scenario

> Read traffic is 10x write traffic.

### Expected Thinking

- ✅ Separate read/write models
- ✅ Optimize read side (denormalized, indexed)
- ✅ Optimize write side (normalized, validated)
- ✅ Eventual consistency acceptable
- ✅ Cache read side only

### PoC Design

**Command Side (Write):**
- `CreateProductCommand` - Add new product
- `UpdateProductCommand` - Update product
- Normalized database schema
- Validation and business rules

**Query Side (Read):**
- `GetProductListQuery` - Get products
- `GetProductByIdQuery` - Get single product
- Denormalized view/table
- Dapper for performance
- Cached results

**Synchronization:**
- Event-driven sync (ProductCreated → Update Read Model)
- Or scheduled sync job

### Patterns Used

- **CQRS** - Command Query Responsibility Segregation
- **Event Sourcing** (optional) - Store events
- **Materialized View** - Pre-computed read model

### Implementation Approach

**Command Side:**
```csharp
// Write model (normalized)
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
    public int CategoryId { get; set; }
    public Category Category { get; set; }
}

[HttpPost]
public async Task<IActionResult> CreateProduct(CreateProductCommand command)
{
    var product = new Product { Name = command.Name, Price = command.Price };
    _context.Products.Add(product);
    await _context.SaveChangesAsync();
    
    // Publish event to update read model
    await _eventBus.PublishAsync(new ProductCreatedEvent(product.Id));
    
    return Ok(product.Id);
}
```

**Query Side:**
```csharp
// Read model (denormalized)
public class ProductListView
{
    public int Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
    public string CategoryName { get; set; } // Denormalized
}

[HttpGet]
public async Task<List<ProductListView>> GetProducts()
{
    // Use Dapper for fast reads
    var sql = @"
        SELECT p.Id, p.Name, p.Price, c.Name as CategoryName
        FROM ProductViews p
        WHERE p.IsActive = 1
        ORDER BY p.Name";
    
    return await _dapper.QueryAsync<ProductListView>(sql);
}
```

### Scalability Explanation

- **Read Scaling**: Multiple read replicas, heavy caching
- **Write Scaling**: Optimized write path, eventual consistency
- **Performance**: Read side 10x faster (no joins, cached)
- **Flexibility**: Can optimize read/write independently

---

## 5️⃣ Repository + Unit of Work – Transaction Safety

### Scenario

> Place order → Save Order + Payment + Inventory atomically.

### Expected Thinking

- ✅ Single transaction boundary
- ✅ All or nothing (rollback on failure)
- ✅ Repository abstracts data access
- ✅ Unit of Work manages transaction

### PoC Design

**Repository Pattern:**
- `IOrderRepository` - Order data access
- `IPaymentRepository` - Payment data access
- `IInventoryRepository` - Inventory data access

**Unit of Work:**
- `IUnitOfWork` - Transaction management
- `BeginTransaction()` - Start transaction
- `Commit()` - Save all changes
- `Rollback()` - Undo all changes

### Patterns Used

- **Repository Pattern** - Data access abstraction
- **Unit of Work Pattern** - Transaction boundary
- **Transaction Script** - Business logic in service

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: No transaction, can fail partially
[HttpPost]
public async Task<IActionResult> PlaceOrder(OrderDto order)
{
    _context.Orders.Add(order);
    await _context.SaveChangesAsync(); // Commits here!
    
    _context.Payments.Add(payment);
    await _context.SaveChangesAsync(); // What if this fails?
    
    _context.Inventory.Update(inventory);
    await _context.SaveChangesAsync(); // Order saved but payment failed!
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Unit of Work pattern
public interface IUnitOfWork
{
    IOrderRepository Orders { get; }
    IPaymentRepository Payments { get; }
    IInventoryRepository Inventory { get; }
    
    Task BeginTransactionAsync();
    Task CommitAsync();
    Task RollbackAsync();
}

[HttpPost]
public async Task<IActionResult> PlaceOrder(OrderDto order)
{
    await _unitOfWork.BeginTransactionAsync();
    
    try
    {
        // All operations in single transaction
        await _unitOfWork.Orders.AddAsync(order);
        await _unitOfWork.Payments.AddAsync(payment);
        await _unitOfWork.Inventory.UpdateAsync(inventory);
        
        await _unitOfWork.CommitAsync(); // All or nothing
        return Ok();
    }
    catch
    {
        await _unitOfWork.RollbackAsync(); // Undo everything
        throw;
    }
}
```

### Expected Answer

> **Repository** = Data access abstraction (hides EF/SQL)
> **Unit of Work** = Transaction boundary (ensures atomicity)

### Scalability Explanation

- **Consistency**: ACID guarantees
- **Reliability**: No partial updates
- **Maintainability**: Clear transaction boundaries
- **Testability**: Mock repositories easily

---

## 6️⃣ Factory Pattern – Payment Gateway

### Scenario

> Support Razorpay, Stripe, PayPal tomorrow.

### Expected Thinking

- ✅ Interface-based design
- ✅ Factory creates implementation
- ✅ Zero controller change when adding new gateway
- ✅ Open/Closed Principle

### PoC Design

**Interface:**
```csharp
public interface IPaymentProcessor
{
    Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request);
    Task<PaymentStatus> GetPaymentStatusAsync(string transactionId);
}
```

**Implementations:**
- `RazorpayPaymentProcessor`
- `StripePaymentProcessor`
- `PayPalPaymentProcessor`

**Factory:**
```csharp
public interface IPaymentProcessorFactory
{
    IPaymentProcessor Create(string gatewayName);
}
```

### Patterns Used

- **Factory Pattern** - Create objects without exposing creation logic
- **Strategy Pattern** - Interchangeable algorithms
- **Dependency Injection** - Loose coupling

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: Hard-coded, violates Open/Closed Principle
[HttpPost]
public async Task<IActionResult> ProcessPayment(PaymentRequest request)
{
    if (request.Gateway == "Razorpay")
    {
        // Razorpay logic
    }
    else if (request.Gateway == "Stripe")
    {
        // Stripe logic
    }
    // Adding PayPal requires changing this method!
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Factory pattern
public class PaymentProcessorFactory : IPaymentProcessorFactory
{
    private readonly IServiceProvider _serviceProvider;
    
    public IPaymentProcessor Create(string gatewayName)
    {
        return gatewayName.ToLower() switch
        {
            "razorpay" => _serviceProvider.GetRequiredService<RazorpayPaymentProcessor>(),
            "stripe" => _serviceProvider.GetRequiredService<StripePaymentProcessor>(),
            "paypal" => _serviceProvider.GetRequiredService<PayPalPaymentProcessor>(),
            _ => throw new NotSupportedException($"Gateway {gatewayName} not supported")
        };
    }
}

[HttpPost]
public async Task<IActionResult> ProcessPayment(PaymentRequest request)
{
    var processor = _factory.Create(request.Gateway);
    var result = await processor.ProcessPaymentAsync(request);
    return Ok(result);
    // Adding new gateway: Just implement IPaymentProcessor and register!
}
```

### Scalability Explanation

- **Extensibility**: Add new gateways without changing existing code
- **Testability**: Mock factory easily
- **Maintainability**: Each gateway isolated
- **Flexibility**: Switch gateways at runtime

---

## 7️⃣ Rate Limiting – Public API Protection

### Scenario

> API abused by clients → system slows down.

### Expected Thinking

- ✅ Limit requests per IP/User
- ✅ Sliding window or fixed window
- ✅ Return 429 Too Many Requests
- ✅ Configurable limits
- ✅ Redis for distributed rate limiting

### PoC Design

**Middleware Approach:**
- Custom middleware checks rate limit
- Store request count in memory or Redis
- Return 429 with Retry-After header

**Configuration:**
- Per endpoint limits
- Per IP limits
- Per user limits (if authenticated)

### Patterns Used

- **Middleware Pattern** - Request pipeline
- **Strategy Pattern** - Different rate limit algorithms
- **Decorator Pattern** - Add rate limiting to endpoints

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: No rate limiting
[HttpGet]
public async Task<IActionResult> GetData()
{
    // Anyone can call this 1000 times/second!
    return Ok(await _service.GetDataAsync());
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Rate limiting middleware
public class RateLimitMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IRateLimitStore _store;
    
    public async Task InvokeAsync(HttpContext context)
    {
        var key = GetClientKey(context); // IP or UserId
        var limit = 100; // requests per minute
        
        var count = await _store.IncrementAsync(key, TimeSpan.FromMinutes(1));
        
        if (count > limit)
        {
            context.Response.StatusCode = 429;
            context.Response.Headers.Add("Retry-After", "60");
            await context.Response.WriteAsync("Rate limit exceeded");
            return;
        }
        
        await _next(context);
    }
}

// Usage
app.UseMiddleware<RateLimitMiddleware>();
```

**Redis Implementation:**
```csharp
public class RedisRateLimitStore : IRateLimitStore
{
    private readonly IDatabase _database;
    
    public async Task<int> IncrementAsync(string key, TimeSpan window)
    {
        var count = await _database.StringIncrementAsync(key);
        if (count == 1)
        {
            await _database.KeyExpireAsync(key, window);
        }
        return (int)count;
    }
}
```

### Scalability Explanation

- **Protection**: Prevents abuse and DDoS
- **Fairness**: All users get equal access
- **Performance**: Redis for distributed systems
- **Configurability**: Different limits per endpoint/user

---

## 8️⃣ Idempotency – Avoid Duplicate Orders

### Scenario

> Client retries payment API → duplicate orders created.

### Expected Thinking

- ✅ Idempotency key (client provides unique key)
- ✅ Store request hash/result
- ✅ Return cached response for duplicate requests
- ✅ Idempotency window (expire after time)

### PoC Design

**Client Side:**
- Generate unique idempotency key (GUID)
- Send in header: `Idempotency-Key: {guid}`
- Retry with same key if request fails

**Server Side:**
- Check if key exists in cache/DB
- If exists, return cached response
- If not, process request and cache result

### Patterns Used

- **Idempotency Pattern** - Safe retries
- **Cache-Aside Pattern** - Store results

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: No idempotency, duplicate orders possible
[HttpPost]
public async Task<IActionResult> CreateOrder(OrderRequest request)
{
    var order = new Order { ... };
    await _context.Orders.AddAsync(order);
    await _context.SaveChangesAsync();
    return Ok(order.Id);
    // Client retries → duplicate order!
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Idempotency middleware
public class IdempotencyMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        var idempotencyKey = context.Request.Headers["Idempotency-Key"].FirstOrDefault();
        
        if (string.IsNullOrEmpty(idempotencyKey))
        {
            await _next(context);
            return;
        }
        
        // Check cache
        var cachedResponse = await _cache.GetAsync(idempotencyKey);
        if (cachedResponse != null)
        {
            context.Response.StatusCode = 200;
            await context.Response.WriteAsync(cachedResponse);
            return; // Return cached response
        }
        
        // Process request
        var originalBodyStream = context.Response.Body;
        using var responseBody = new MemoryStream();
        context.Response.Body = responseBody;
        
        await _next(context);
        
        // Cache response
        var responseBodyText = await GetResponseBodyAsync(responseBody);
        await _cache.SetAsync(idempotencyKey, responseBodyText, TimeSpan.FromHours(24));
        
        await responseBody.CopyToAsync(originalBodyStream);
    }
}

[HttpPost]
[Idempotent] // Custom attribute
public async Task<IActionResult> CreateOrder(OrderRequest request)
{
    // This will only execute once per idempotency key
    var order = new Order { ... };
    await _context.Orders.AddAsync(order);
    await _context.SaveChangesAsync();
    return Ok(order.Id);
}
```

### Scalability Explanation

- **Reliability**: Safe retries without duplicates
- **Performance**: Cached responses are instant
- **User Experience**: No duplicate charges/orders
- **Network Resilience**: Handles network failures gracefully

---

## 9️⃣ Async Processing – Email / SMS

### Scenario

> Order placed → send email without slowing API.

### Expected Thinking

- ✅ Fire and forget (don't wait for email)
- ✅ Background job processing
- ✅ Retry mechanism for failures
- ✅ Dead letter queue for failed jobs
- ✅ Outbox pattern (optional - ensure delivery)

### PoC Design

**API Side:**
- Publish event/message to queue
- Return immediately
- Don't wait for email

**Background Worker:**
- Consume messages from queue
- Send email/SMS
- Retry on failure
- Log failures

**Queue Options:**
- Azure Service Bus
- AWS SQS
- RabbitMQ
- Hangfire (in-process)

### Patterns Used

- **Publisher-Subscriber Pattern** - Decouple producers/consumers
- **Outbox Pattern** - Ensure message delivery
- **Retry Pattern** - Handle transient failures

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: Synchronous email, slows API
[HttpPost]
public async Task<IActionResult> PlaceOrder(OrderRequest request)
{
    var order = new Order { ... };
    await _context.Orders.AddAsync(order);
    await _context.SaveChangesAsync();
    
    // This blocks the API response!
    await _emailService.SendOrderConfirmationAsync(order);
    
    return Ok(order.Id);
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Async processing with queue
[HttpPost]
public async Task<IActionResult> PlaceOrder(OrderRequest request)
{
    var order = new Order { ... };
    await _context.Orders.AddAsync(order);
    await _context.SaveChangesAsync();
    
    // Publish event, don't wait
    await _messageBus.PublishAsync(new OrderPlacedEvent
    {
        OrderId = order.Id,
        CustomerEmail = order.CustomerEmail
    });
    
    return Ok(order.Id); // Returns immediately
}

// Background worker
public class EmailWorker : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var message = await _queue.ReceiveAsync();
            
            try
            {
                await _emailService.SendAsync(message);
                await _queue.DeleteMessageAsync(message);
            }
            catch (Exception ex)
            {
                // Retry logic
                await _retryService.RetryAsync(message, ex);
            }
        }
    }
}
```

**Outbox Pattern (Bonus):**
```csharp
// Ensure message delivery even if service crashes
public async Task PlaceOrder(OrderRequest request)
{
    using var transaction = await _context.Database.BeginTransactionAsync();
    
    var order = new Order { ... };
    await _context.Orders.AddAsync(order);
    
    // Save to outbox in same transaction
    var outboxMessage = new OutboxMessage
    {
        EventType = "OrderPlaced",
        Payload = JsonSerializer.Serialize(new OrderPlacedEvent { ... })
    };
    await _context.OutboxMessages.AddAsync(outboxMessage);
    
    await _context.SaveChangesAsync();
    await transaction.CommitAsync();
    
    // Background job processes outbox
}
```

### Scalability Explanation

- **Performance**: API responds immediately
- **Reliability**: Retry mechanism handles failures
- **Scalability**: Multiple workers can process queue
- **Resilience**: System continues even if email service is down

---

## 🔟 Caching Strategy – Heavy Read APIs

### Scenario

> Product list API slow under load.

### Expected Thinking

- ✅ Cache-aside pattern
- ✅ Cache invalidation on update
- ✅ Sliding vs absolute expiry
- ✅ Cache warming (pre-populate)
- ✅ Distributed cache (Redis)

### PoC Design

**Cache-Aside Pattern:**
1. Check cache
2. If miss, load from DB
3. Store in cache
4. Return data

**Invalidation:**
- On update/delete, remove from cache
- Or use cache tags for bulk invalidation

**Expiry:**
- Sliding: Reset timer on access
- Absolute: Fixed expiration time

### Patterns Used

- **Cache-Aside Pattern** - Application manages cache
- **Write-Through Pattern** (optional) - Write to cache and DB
- **Cache-Aside with TTL** - Time-based expiration

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: No caching, hits DB every time
[HttpGet]
public async Task<List<Product>> GetProducts()
{
    return await _context.Products.ToListAsync(); // Slow!
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Cache-aside pattern
[HttpGet]
public async Task<List<Product>> GetProducts()
{
    var cacheKey = "products:list";
    
    // Check cache
    var cached = await _cache.GetAsync<List<Product>>(cacheKey);
    if (cached != null)
    {
        return cached; // Return from cache
    }
    
    // Cache miss - load from DB
    var products = await _context.Products.ToListAsync();
    
    // Store in cache
    await _cache.SetAsync(cacheKey, products, TimeSpan.FromMinutes(10));
    
    return products;
}

[HttpPut("{id}")]
public async Task<IActionResult> UpdateProduct(int id, Product product)
{
    await _context.SaveChangesAsync();
    
    // Invalidate cache
    await _cache.RemoveAsync("products:list");
    await _cache.RemoveAsync($"products:{id}");
    
    return Ok();
}
```

**Redis Implementation:**
```csharp
public class RedisCacheService : ICacheService
{
    private readonly IDatabase _database;
    
    public async Task<T> GetAsync<T>(string key)
    {
        var value = await _database.StringGetAsync(key);
        return value.HasValue ? JsonSerializer.Deserialize<T>(value) : default;
    }
    
    public async Task SetAsync<T>(string key, T value, TimeSpan expiry)
    {
        var json = JsonSerializer.Serialize(value);
        await _database.StringSetAsync(key, json, expiry);
    }
}
```

### Scalability Explanation

- **Performance**: 10-100x faster than DB queries
- **Load Reduction**: Reduces database load significantly
- **Scalability**: Redis can handle millions of requests
- **Cost**: Reduces database costs

---

## 1️⃣1️⃣ Soft Delete + Audit

### Scenario

> Data should not be deleted permanently.

### Expected Thinking

- ✅ `IsDeleted` flag instead of DELETE
- ✅ `DeletedOn` timestamp
- ✅ `DeletedBy` user tracking
- ✅ Global query filter (EF Core)
- ✅ Audit fields (CreatedOn, ModifiedOn, CreatedBy, ModifiedBy)

### PoC Design

**Base Entity:**
```csharp
public abstract class AuditableEntity
{
    public int Id { get; set; }
    public bool IsDeleted { get; set; }
    public DateTime? DeletedOn { get; set; }
    public string DeletedBy { get; set; }
    public DateTime CreatedOn { get; set; }
    public string CreatedBy { get; set; }
    public DateTime? ModifiedOn { get; set; }
    public string ModifiedBy { get; set; }
}
```

**Global Query Filter:**
```csharp
modelBuilder.Entity<User>()
    .HasQueryFilter(u => !u.IsDeleted);
```

**Soft Delete:**
```csharp
public async Task DeleteAsync(int id)
{
    var entity = await _context.Users.FindAsync(id);
    entity.IsDeleted = true;
    entity.DeletedOn = DateTime.UtcNow;
    entity.DeletedBy = _currentUser.Id;
    await _context.SaveChangesAsync();
}
```

### Patterns Used

- **Soft Delete Pattern** - Logical deletion
- **Audit Trail Pattern** - Track changes
- **Global Query Filter** - Automatic filtering

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: Hard delete, data lost forever
[HttpDelete("{id}")]
public async Task<IActionResult> DeleteUser(int id)
{
    var user = await _context.Users.FindAsync(id);
    _context.Users.Remove(user);
    await _context.SaveChangesAsync();
    return Ok();
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Soft delete with audit
public abstract class AuditableEntity
{
    public int Id { get; set; }
    public bool IsDeleted { get; set; }
    public DateTime? DeletedOn { get; set; }
    public string DeletedBy { get; set; }
    public DateTime CreatedOn { get; set; }
    public string CreatedBy { get; set; }
    public DateTime? ModifiedOn { get; set; }
    public string ModifiedBy { get; set; }
}

public class User : AuditableEntity
{
    public string Name { get; set; }
    public string Email { get; set; }
}

// DbContext configuration
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<User>()
        .HasQueryFilter(u => !u.IsDeleted);
    
    // Auto-set audit fields
    foreach (var entityType in modelBuilder.Model.GetEntityTypes())
    {
        if (typeof(AuditableEntity).IsAssignableFrom(entityType.ClrType))
        {
            modelBuilder.Entity(entityType.ClrType)
                .Property(nameof(AuditableEntity.CreatedOn))
                .HasDefaultValueSql("GETUTCDATE()");
        }
    }
}

// Soft delete
[HttpDelete("{id}")]
public async Task<IActionResult> DeleteUser(int id)
{
    var user = await _context.Users.FindAsync(id);
    user.IsDeleted = true;
    user.DeletedOn = DateTime.UtcNow;
    user.DeletedBy = _currentUser.Id;
    await _context.SaveChangesAsync();
    return Ok();
}
```

### Scalability Explanation

- **Data Recovery**: Can restore deleted records
- **Compliance**: Meets audit requirements
- **Safety**: Prevents accidental data loss
- **History**: Track who deleted what and when

---

## 1️⃣2️⃣ Global Exception Handling

### Scenario

> API should never expose stack trace.

### Expected Thinking

- ✅ Centralized exception handling
- ✅ Custom exception middleware
- ✅ Correlation ID for tracking
- ✅ Standard error response format
- ✅ Logging all exceptions
- ✅ Different handling for different exception types

### PoC Design

**Exception Middleware:**
- Catch all exceptions
- Log with correlation ID
- Return standardized error response
- Never expose stack trace in production

**Error Response:**
```json
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An error occurred",
    "correlationId": "abc-123-def"
  }
}
```

### Patterns Used

- **Middleware Pattern** - Request pipeline
- **Exception Handling Pattern** - Centralized error handling
- **Correlation ID Pattern** - Request tracking

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: Exceptions bubble up, expose stack trace
[HttpGet]
public async Task<IActionResult> GetUser(int id)
{
    var user = await _context.Users.FindAsync(id);
    if (user == null)
        throw new Exception("User not found"); // Exposes stack trace!
    return Ok(user);
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Global exception handling
public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;
    
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }
    
    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var correlationId = context.TraceIdentifier;
        _logger.LogError(exception, "Error occurred. CorrelationId: {CorrelationId}", correlationId);
        
        context.Response.StatusCode = exception switch
        {
            NotFoundException => 404,
            ValidationException => 400,
            UnauthorizedException => 401,
            _ => 500
        };
        
        context.Response.ContentType = "application/json";
        
        var errorResponse = new ErrorResponse
        {
            Error = new ErrorDetail
            {
                Code = GetErrorCode(exception),
                Message = GetErrorMessage(exception),
                CorrelationId = correlationId
            }
        };
        
        // Never expose stack trace in production
        if (_environment.IsDevelopment())
        {
            errorResponse.Error.StackTrace = exception.StackTrace;
        }
        
        await context.Response.WriteAsync(JsonSerializer.Serialize(errorResponse));
    }
}

// Usage
app.UseMiddleware<GlobalExceptionMiddleware>();
```

### Scalability Explanation

- **Security**: No sensitive information leaked
- **Debugging**: Correlation ID helps track issues
- **User Experience**: Consistent error format
- **Monitoring**: All errors logged centrally

---

## 1️⃣3️⃣ Concurrency Handling

### Scenario

> Two users update same record.

### Expected Thinking

- ✅ Optimistic concurrency (RowVersion/Timestamp)
- ✅ Pessimistic concurrency (locks)
- ✅ Conflict detection
- ✅ Retry logic
- ✅ Last-write-wins vs first-write-wins

### PoC Design

**Optimistic Concurrency:**
- Add `RowVersion` (byte[]) or `Timestamp` column
- EF Core checks version on update
- Throws `DbUpdateConcurrencyException` on conflict
- Client retries with latest data

**Conflict Resolution:**
- Last-write-wins (default)
- First-write-wins (reject later writes)
- Merge strategy (combine changes)

### Patterns Used

- **Optimistic Concurrency Control** - Version-based conflict detection
- **Retry Pattern** - Handle conflicts
- **ETag Pattern** - HTTP concurrency control

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: No concurrency control, last write wins silently
[HttpPut("{id}")]
public async Task<IActionResult> UpdateUser(int id, UserDto dto)
{
    var user = await _context.Users.FindAsync(id);
    user.Name = dto.Name; // Overwrites without checking!
    await _context.SaveChangesAsync();
    return Ok();
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Optimistic concurrency
public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    [Timestamp] // EF Core concurrency token
    public byte[] RowVersion { get; set; }
}

[HttpPut("{id}")]
public async Task<IActionResult> UpdateUser(int id, UserDto dto)
{
    try
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) return NotFound();
        
        // Check if version matches (from If-Match header)
        var ifMatch = Request.Headers["If-Match"].FirstOrDefault();
        if (ifMatch != null && Convert.FromBase64String(ifMatch) != user.RowVersion)
        {
            return Conflict(new { message = "Record was modified" });
        }
        
        user.Name = dto.Name;
        await _context.SaveChangesAsync();
        
        // Return new version in ETag
        Response.Headers["ETag"] = Convert.ToBase64String(user.RowVersion);
        return Ok(user);
    }
    catch (DbUpdateConcurrencyException)
    {
        return Conflict(new { message = "Concurrency conflict. Please refresh and retry." });
    }
}

// Client retry logic
public async Task UpdateUserWithRetry(int id, UserDto dto, int maxRetries = 3)
{
    for (int i = 0; i < maxRetries; i++)
    {
        try
        {
            var user = await GetUserAsync(id);
            dto.RowVersion = user.RowVersion; // Get latest version
            return await UpdateUserAsync(id, dto);
        }
        catch (ConflictException)
        {
            if (i == maxRetries - 1) throw;
            await Task.Delay(100); // Wait before retry
        }
    }
}
```

### Scalability Explanation

- **Performance**: No locks, better throughput
- **Consistency**: Detects conflicts
- **User Experience**: Clear conflict messages
- **Scalability**: Works in distributed systems

---

## 1️⃣4️⃣ Search Optimization

### Scenario

> Search on name, phone, email with 1M rows.

### Expected Thinking

- ✅ Indexed columns (name, phone, email)
- ✅ StartsWith vs Contains (performance)
- ✅ Full-text search (SQL Server)
- ✅ Search ranking
- ✅ Pagination for results

### PoC Design

**Database:**
- Indexes on searchable columns
- Full-text index for text search
- Computed columns for search optimization

**API:**
- Search endpoint with filters
- Pagination support
- Ranking/scoring

**SQL Optimization:**
- Avoid `LIKE '%term%'` (can't use index)
- Prefer `LIKE 'term%'` (can use index)
- Use full-text search for complex queries

### Patterns Used

- **Index Pattern** - Database optimization
- **Full-Text Search** - Advanced text matching
- **Specification Pattern** - Dynamic query building

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: Contains with no index, slow on 1M rows
[HttpGet("search")]
public async Task<List<User>> SearchUsers(string term)
{
    return await _context.Users
        .Where(u => u.Name.Contains(term) || 
                   u.Email.Contains(term) || 
                   u.Phone.Contains(term))
        .ToListAsync(); // Very slow!
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Indexed search with optimization
// Database: Create indexes
CREATE INDEX IX_Users_Name ON Users(Name);
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_Users_Phone ON Users(Phone);

// Full-text index
CREATE FULLTEXT CATALOG ftCatalog;
CREATE FULLTEXT INDEX ON Users(Name, Email) KEY INDEX PK_Users;

[HttpGet("search")]
public async Task<PagedResult<User>> SearchUsers(
    string term,
    int pageNo = 1,
    int pageSize = 20)
{
    // Use StartsWith for indexed search (faster)
    var query = _context.Users.AsQueryable();
    
    if (!string.IsNullOrEmpty(term))
    {
        // For exact/prefix matches (uses index)
        query = query.Where(u => 
            u.Name.StartsWith(term) || 
            u.Email.StartsWith(term) ||
            u.Phone.StartsWith(term));
        
        // Or use full-text search for complex matching
        // query = query.Where(u => 
        //     EF.Functions.Contains(u.Name, term) ||
        //     EF.Functions.Contains(u.Email, term));
    }
    
    var totalCount = await query.CountAsync();
    var users = await query
        .OrderBy(u => u.Name)
        .Skip((pageNo - 1) * pageSize)
        .Take(pageSize)
        .ToListAsync();
    
    return new PagedResult<User>
    {
        Data = users,
        TotalCount = totalCount,
        PageNo = pageNo,
        PageSize = pageSize
    };
}
```

**Full-Text Search:**
```csharp
// Advanced full-text search
[HttpGet("search-advanced")]
public async Task<List<User>> AdvancedSearch(string term)
{
    return await _context.Users
        .Where(u => EF.Functions.Contains(u.Name, $"\"{term}*\""))
        .OrderByDescending(u => 
            EF.Functions.Contains(u.Name, term) ? 1 : 0) // Ranking
        .ToListAsync();
}
```

### Scalability Explanation

- **Performance**: Indexes make searches 100x faster
- **Scalability**: Handles millions of rows
- **User Experience**: Fast search results
- **Database Load**: Reduced query time

---

## 1️⃣5️⃣ Feature Toggle

### Scenario

> Enable feature only for few users.

### Expected Thinking

- ✅ Database or config-based toggle
- ✅ Per-user, per-role, or percentage-based
- ✅ Zero redeploy to enable/disable
- ✅ A/B testing support
- ✅ Gradual rollout

### PoC Design

**Feature Toggle Service:**
- Check if feature enabled for user
- Support multiple strategies:
  - All users
  - Specific users (whitelist)
  - Percentage of users
  - User roles
  - Date-based

**Storage:**
- Database table for feature flags
- Or configuration file
- Or Azure App Configuration / AWS Parameter Store

### Patterns Used

- **Feature Toggle Pattern** - Runtime feature control
- **Strategy Pattern** - Different toggle strategies
- **Configuration Pattern** - Externalized configuration

### Implementation Approach

**Naive Approach (What NOT to do):**
```csharp
// ❌ BAD: Hard-coded, requires redeploy
[HttpGet("new-feature")]
public async Task<IActionResult> NewFeature()
{
    // Can't enable/disable without redeploy!
    if (false) // Hard-coded
    {
        return Ok("New feature");
    }
    return NotFound();
}
```

**Optimized Solution:**
```csharp
// ✅ GOOD: Feature toggle service
public interface IFeatureToggleService
{
    Task<bool> IsEnabledAsync(string featureName, string userId = null);
}

public class FeatureToggleService : IFeatureToggleService
{
    private readonly ApplicationDbContext _context;
    
    public async Task<bool> IsEnabledAsync(string featureName, string userId = null)
    {
        var feature = await _context.FeatureToggles
            .FirstOrDefaultAsync(f => f.Name == featureName);
        
        if (feature == null || !feature.IsEnabled)
            return false;
        
        // Check user-specific rules
        if (feature.TargetUsers != null && userId != null)
        {
            return feature.TargetUsers.Contains(userId);
        }
        
        // Check percentage rollout
        if (feature.Percentage > 0 && userId != null)
        {
            var hash = userId.GetHashCode();
            return (hash % 100) < feature.Percentage;
        }
        
        return feature.IsEnabled;
    }
}

// Usage
[HttpGet("new-feature")]
public async Task<IActionResult> NewFeature()
{
    var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    
    if (!await _featureToggle.IsEnabledAsync("NewFeature", userId))
    {
        return NotFound();
    }
    
    return Ok("New feature enabled for you!");
}

// Database table
public class FeatureToggle
{
    public int Id { get; set; }
    public string Name { get; set; }
    public bool IsEnabled { get; set; }
    public int Percentage { get; set; } // 0-100
    public string TargetUsers { get; set; } // Comma-separated user IDs
    public DateTime? EnabledUntil { get; set; }
}
```

**Azure App Configuration (Alternative):**
```csharp
// Use Azure App Configuration for feature flags
public class AzureFeatureToggleService : IFeatureToggleService
{
    private readonly IConfiguration _configuration;
    
    public async Task<bool> IsEnabledAsync(string featureName, string userId = null)
    {
        return await _configuration.GetFeatureFlagAsync(featureName);
    }
}
```

### Scalability Explanation

- **Flexibility**: Enable/disable without code changes
- **Risk Reduction**: Gradual rollout to users
- **A/B Testing**: Test features with subset of users
- **Operational Control**: Non-developers can manage features

---

## 🎯 How to Practice (Interview-Ready Method)

For **each PoC**, prepare:

### 1. Problem Statement
- Understand the business requirement
- Identify the challenge
- Recognize the naive approach pitfalls

### 2. Naive Approach (What NOT to do)
- Show you understand the problem
- Demonstrate you know what doesn't work
- Explain why it fails

### 3. Optimized Solution
- Design the architecture
- Choose appropriate patterns
- Implement with code examples
- Explain trade-offs

### 4. Patterns Used
- Name the design patterns
- Explain why each pattern fits
- Show pattern implementation

### 5. Scalability Explanation
- How it handles scale
- Performance improvements
- Cost implications
- Maintenance benefits

### 6. Real-World Considerations
- Error handling
- Monitoring
- Testing strategy
- Deployment considerations

---

## 📝 Practice Checklist

For each scenario, ensure you can:

- [ ] Explain the problem clearly
- [ ] Identify the naive approach and its issues
- [ ] Design the optimized solution
- [ ] Write code examples
- [ ] Explain patterns used
- [ ] Discuss scalability
- [ ] Handle edge cases
- [ ] Consider error scenarios
- [ ] Explain monitoring needs
- [ ] Discuss testing approach

---

## 🚀 Quick Reference: Pattern Summary

| Scenario | Key Patterns |
|----------|-------------|
| File Upload | Factory, Clean Architecture, Strategy |
| Large Dataset | Repository, CQRS, Specification |
| Clean Architecture | Dependency Inversion, Repository |
| CQRS | Command/Query Separation, Event Sourcing |
| Transaction Safety | Repository, Unit of Work |
| Payment Gateway | Factory, Strategy, DI |
| Rate Limiting | Middleware, Strategy |
| Idempotency | Idempotency Pattern, Cache-Aside |
| Async Processing | Pub-Sub, Outbox, Retry |
| Caching | Cache-Aside, Write-Through |
| Soft Delete | Soft Delete Pattern, Audit Trail |
| Exception Handling | Middleware, Correlation ID |
| Concurrency | Optimistic Concurrency, Retry |
| Search | Index Pattern, Full-Text Search |
| Feature Toggle | Feature Toggle, Strategy |

---

## 💡 Interview Tips

1. **Start with the problem** - Show you understand the requirement
2. **Explain the naive approach** - Demonstrates critical thinking
3. **Design before coding** - Architecture first, code second
4. **Use patterns appropriately** - Don't over-engineer
5. **Consider trade-offs** - Every solution has pros/cons
6. **Think about scale** - Always consider scalability
7. **Handle errors** - Show you think about failure scenarios
8. **Be practical** - Real-world solutions, not academic

---

*Remember: Interviews focus on **thinking process**, **architecture decisions**, and **practical problem-solving**, not just code syntax. Practice explaining your decisions!*
