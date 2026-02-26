# C# REST API .NET Core - Coding Standards & Best Practices

## Table of Contents

1. [Performance & Time Efficiency](#performance--time-efficiency)
2. [Memory Management](#memory-management)
3. [Null Handling Best Practices](#null-handling-best-practices)
4. [API Design Patterns](#api-design-patterns)
5. [Database & Data Access](#database--data-access)
6. [Async/Await Best Practices](#asyncawait-best-practices)
7. [Exception Handling](#exception-handling)
8. [Security Standards](#security-standards)
9. [Logging & Monitoring](#logging--monitoring)
10. [Code Quality & Maintainability](#code-quality--maintainability)

---

## Performance & Time Efficiency

### ✅ DO: Use Async/Await for I/O Operations

```csharp
// ✅ GOOD - Non-blocking I/O
public async Task<IActionResult> GetUsersAsync()
{
    var users = await _dbContext.Users.ToListAsync();
    return Ok(users);
}

// ❌ BAD - Blocks thread
public IActionResult GetUsers()
{
    var users = _dbContext.Users.ToList();
    return Ok(users);
}
```

### ✅ DO: Use ValueTask for Hot Paths

```csharp
// ✅ GOOD - Reduces allocations when cached results are common
public async ValueTask<User> GetUserFromCacheAsync(int id)
{
    if (_cache.TryGetValue(id, out User user))
        return user; // No Task allocation

    user = await _repository.GetUserAsync(id);
    _cache.Set(id, user);
    return user;
}
```

### ✅ DO: Avoid Unnecessary LINQ Chains

```csharp
// ✅ GOOD - Single pass
var result = users
    .Where(u => u.IsActive && u.Age > 18)
    .Select(u => new UserDto { Id = u.Id, Name = u.Name })
    .ToList();

// ❌ BAD - Multiple iterations
var result = users
    .Where(u => u.IsActive)
    .ToList()
    .Where(u => u.Age > 18)
    .ToList()
    .Select(u => new UserDto { Id = u.Id, Name = u.Name })
    .ToList();
```

### ✅ DO: Use Span<T> and Memory<T> for Performance-Critical Code

```csharp
// ✅ GOOD - Zero allocation string manipulation
public string ProcessData(ReadOnlySpan<char> input)
{
    Span<char> buffer = stackalloc char[100];
    // Process without heap allocations
    return new string(buffer);
}
```

### ✅ DO: Cache Compiled Regular Expressions

```csharp
// ✅ GOOD - Compiled and cached
private static readonly Regex EmailRegex =
    new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$", RegexOptions.Compiled);

// ❌ BAD - Recompiled every time
public bool IsValidEmail(string email)
{
    return Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$");
}
```

---

## Memory Management

### ✅ DO: Use Object Pooling for Frequently Created Objects

```csharp
// ✅ GOOD - Reuse objects
public class MyService
{
    private static readonly ObjectPool<StringBuilder> _stringBuilderPool =
        ObjectPool.Create<StringBuilder>();

    public string BuildMessage(List<string> parts)
    {
        var sb = _stringBuilderPool.Get();
        try
        {
            foreach (var part in parts)
                sb.Append(part);
            return sb.ToString();
        }
        finally
        {
            sb.Clear();
            _stringBuilderPool.Return(sb);
        }
    }
}
```

### ✅ DO: Use ArrayPool for Temporary Buffers

```csharp
// ✅ GOOD - Rent from pool
public async Task ProcessLargeDataAsync(Stream stream)
{
    var buffer = ArrayPool<byte>.Shared.Rent(4096);
    try
    {
        await stream.ReadAsync(buffer, 0, buffer.Length);
        // Process buffer
    }
    finally
    {
        ArrayPool<byte>.Shared.Return(buffer);
    }
}

// ❌ BAD - Allocates every time
public async Task ProcessLargeDataAsync(Stream stream)
{
    var buffer = new byte[4096];
    await stream.ReadAsync(buffer, 0, buffer.Length);
}
```

### ✅ DO: Dispose IDisposable Resources Properly

```csharp
// ✅ GOOD - Using declaration (C# 8.0+)
public async Task<string> ReadFileAsync(string path)
{
    using var reader = new StreamReader(path);
    return await reader.ReadToEndAsync();
}

// ✅ GOOD - Traditional using statement
public async Task<string> ReadFileAsync(string path)
{
    using (var reader = new StreamReader(path))
    {
        return await reader.ReadToEndAsync();
    }
}
```

### ✅ DO: Use Struct for Small, Immutable Data

```csharp
// ✅ GOOD - Value type, no heap allocation
public readonly struct Point
{
    public int X { get; }
    public int Y { get; }

    public Point(int x, int y) => (X, Y) = (x, y);
}

// ❌ BAD for small data - Reference type, heap allocation
public class Point
{
    public int X { get; set; }
    public int Y { get; set; }
}
```

### ✅ DO: Avoid Boxing/Unboxing

```csharp
// ✅ GOOD - Generic constraint
public void Process<T>(T value) where T : struct
{
    // No boxing
}

// ❌ BAD - Boxing occurs
public void Process(object value)
{
    int number = (int)value; // Unboxing
}
```

---

## Null Handling Best Practices

### ✅ DO: Use Nullable Reference Types (C# 8.0+)

```csharp
// Enable in .csproj
// <Nullable>enable</Nullable>

// ✅ GOOD - Explicit nullability
public class UserService
{
    private readonly IUserRepository _repository; // Never null

    public UserService(IUserRepository repository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }

    // Returns non-null or throws
    public async Task<User> GetUserAsync(int id)
    {
        return await _repository.FindAsync(id)
            ?? throw new NotFoundException($"User {id} not found");
    }

    // Explicitly nullable return
    public async Task<User?> FindUserAsync(int id)
    {
        return await _repository.FindAsync(id);
    }
}
```

### ✅ DO: Avoid Unnecessary Null Checks

```csharp
// ✅ GOOD - Constructor injection guarantees non-null
public class OrderController : ControllerBase
{
    private readonly IOrderService _orderService;

    public OrderController(IOrderService orderService)
    {
        _orderService = orderService; // DI container ensures non-null
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetOrder(int id)
    {
        // No need to check _orderService for null
        var order = await _orderService.GetOrderAsync(id);
        return Ok(order);
    }
}

// ❌ BAD - Unnecessary null checks
public async Task<IActionResult> GetOrder(int id)
{
    if (_orderService == null) // Unnecessary - DI guarantees non-null
        return StatusCode(500);

    var order = await _orderService.GetOrderAsync(id);

    if (order == null) // This should be handled by service layer
        return NotFound();

    return Ok(order);
}
```

### ✅ DO: Use Pattern Matching for Cleaner Null Checks

```csharp
// ✅ GOOD - Pattern matching
public IActionResult ProcessUser(User? user)
{
    return user switch
    {
        null => NotFound(),
        { IsActive: false } => BadRequest("User is inactive"),
        _ => Ok(user)
    };
}

// ✅ GOOD - Null-coalescing
var name = user?.Name ?? "Unknown";

// ✅ GOOD - Null-conditional with early return
if (user?.IsActive != true)
    return BadRequest();
```

### ✅ DO: Validate Inputs at API Boundary Only

```csharp
// ✅ GOOD - Validate once at controller
[ApiController]
public class ProductController : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> CreateProduct([FromBody] CreateProductDto dto)
    {
        // ModelState validation already done by [ApiController]

        var product = await _productService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, product);
    }
}

// Service layer trusts validated input
public class ProductService
{
    public async Task<Product> CreateAsync(CreateProductDto dto)
    {
        // No need to re-validate dto properties
        var product = new Product
        {
            Name = dto.Name, // Trust it's not null
            Price = dto.Price
        };
        await _repository.AddAsync(product);
        return product;
    }
}
```

---

## API Design Patterns

### ✅ DO: Use DTOs for API Contracts

```csharp
// ✅ GOOD - Separate concerns
public record CreateUserRequest(
    string Email,
    string Name,
    string Password
);

public record UserResponse(
    int Id,
    string Email,
    string Name,
    DateTime CreatedAt
);

[HttpPost]
public async Task<ActionResult<UserResponse>> CreateUser([FromBody] CreateUserRequest request)
{
    var user = await _userService.CreateAsync(request);
    return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
}

// ❌ BAD - Exposing domain entities
[HttpPost]
public async Task<ActionResult<User>> CreateUser([FromBody] User user)
{
    return await _userService.CreateAsync(user);
}
```

### ✅ DO: Use Records for Immutable DTOs

```csharp
// ✅ GOOD - Immutable, concise
public record UserDto(int Id, string Name, string Email);

// ❌ BAD - Verbose, mutable
public class UserDto
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
}
```

### ✅ DO: Use ActionResult<T> for Type Safety

```csharp
// ✅ GOOD - Type-safe return
[HttpGet("{id}")]
public async Task<ActionResult<UserDto>> GetUser(int id)
{
    var user = await _userService.GetUserAsync(id);
    return user is null ? NotFound() : Ok(user);
}

// ❌ BAD - Type information lost
[HttpGet("{id}")]
public async Task<IActionResult> GetUser(int id)
{
    var user = await _userService.GetUserAsync(id);
    return user is null ? NotFound() : Ok(user);
}
```

### ✅ DO: Implement Proper HTTP Status Codes

```csharp
[HttpGet("{id}")]
public async Task<ActionResult<OrderDto>> GetOrder(int id)
{
    var order = await _orderService.GetOrderAsync(id);
    return order is null ? NotFound() : Ok(order);
}

[HttpPost]
public async Task<ActionResult<OrderDto>> CreateOrder([FromBody] CreateOrderDto dto)
{
    var order = await _orderService.CreateAsync(dto);
    return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
}

[HttpPut("{id}")]
public async Task<IActionResult> UpdateOrder(int id, [FromBody] UpdateOrderDto dto)
{
    await _orderService.UpdateAsync(id, dto);
    return NoContent();
}

[HttpDelete("{id}")]
public async Task<IActionResult> DeleteOrder(int id)
{
    await _orderService.DeleteAsync(id);
    return NoContent();
}
```

---

## Database & Data Access

### ✅ DO: Use AsNoTracking for Read-Only Queries

```csharp
// ✅ GOOD - No tracking overhead
public async Task<List<UserDto>> GetUsersAsync()
{
    return await _dbContext.Users
        .AsNoTracking()
        .Select(u => new UserDto(u.Id, u.Name, u.Email))
        .ToListAsync();
}

// ❌ BAD - Unnecessary tracking
public async Task<List<UserDto>> GetUsersAsync()
{
    return await _dbContext.Users
        .Select(u => new UserDto(u.Id, u.Name, u.Email))
        .ToListAsync();
}
```

### ✅ DO: Project to DTOs in Database Query

```csharp
// ✅ GOOD - Projects in SQL, transfers less data
public async Task<List<UserDto>> GetUsersAsync()
{
    return await _dbContext.Users
        .Where(u => u.IsActive)
        .Select(u => new UserDto(u.Id, u.Name, u.Email))
        .ToListAsync();
}

// ❌ BAD - Loads all columns, maps in memory
public async Task<List<UserDto>> GetUsersAsync()
{
    var users = await _dbContext.Users
        .Where(u => u.IsActive)
        .ToListAsync();

    return users.Select(u => new UserDto(u.Id, u.Name, u.Email)).ToList();
}
```

### ✅ DO: Use Pagination for Large Result Sets

```csharp
// ✅ GOOD - Paginated results
public record PagedResult<T>(List<T> Items, int TotalCount, int Page, int PageSize);

public async Task<PagedResult<UserDto>> GetUsersAsync(int page = 1, int pageSize = 20)
{
    var query = _dbContext.Users.AsNoTracking();

    var totalCount = await query.CountAsync();

    var items = await query
        .OrderBy(u => u.Id)
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .Select(u => new UserDto(u.Id, u.Name, u.Email))
        .ToListAsync();

    return new PagedResult<UserDto>(items, totalCount, page, pageSize);
}
```

### ✅ DO: Use Compiled Queries for Hot Paths

```csharp
// ✅ GOOD - Compiled once, reused
private static readonly Func<AppDbContext, int, Task<User?>> GetUserByIdQuery =
    EF.CompileAsyncQuery((AppDbContext context, int id) =>
        context.Users.FirstOrDefault(u => u.Id == id));

public async Task<User?> GetUserAsync(int id)
{
    return await GetUserByIdQuery(_dbContext, id);
}
```

### ✅ DO: Avoid N+1 Query Problems

```csharp
// ✅ GOOD - Eager loading
public async Task<List<OrderDto>> GetOrdersWithItemsAsync()
{
    return await _dbContext.Orders
        .Include(o => o.OrderItems)
        .ThenInclude(oi => oi.Product)
        .Select(o => new OrderDto
        {
            Id = o.Id,
            Items = o.OrderItems.Select(oi => new OrderItemDto
            {
                ProductName = oi.Product.Name,
                Quantity = oi.Quantity
            }).ToList()
        })
        .ToListAsync();
}

// ❌ BAD - N+1 queries
public async Task<List<OrderDto>> GetOrdersWithItemsAsync()
{
    var orders = await _dbContext.Orders.ToListAsync();
    foreach (var order in orders)
    {
        order.OrderItems = await _dbContext.OrderItems
            .Where(oi => oi.OrderId == order.Id)
            .ToListAsync(); // Separate query for each order
    }
    return orders.Select(o => MapToDto(o)).ToList();
}
```

---

## Async/Await Best Practices

### ✅ DO: Use ConfigureAwait(false) in Libraries

```csharp
// ✅ GOOD - In library/service code
public async Task<User> GetUserAsync(int id)
{
    var response = await _httpClient.GetAsync($"/users/{id}")
        .ConfigureAwait(false);

    return await response.Content.ReadFromJsonAsync<User>()
        .ConfigureAwait(false);
}

// ℹ️ NOT needed in ASP.NET Core controllers/MVC (no SynchronizationContext)
[HttpGet("{id}")]
public async Task<IActionResult> GetUser(int id)
{
    var user = await _userService.GetUserAsync(id); // No ConfigureAwait needed
    return Ok(user);
}
```

### ✅ DO: Avoid Async Void (Except Event Handlers)

```csharp
// ✅ GOOD
public async Task ProcessDataAsync()
{
    await DoWorkAsync();
}

// ❌ BAD - Can't catch exceptions
public async void ProcessData()
{
    await DoWorkAsync();
}
```

### ✅ DO: Use Task.WhenAll for Parallel Operations

```csharp
// ✅ GOOD - Parallel execution
public async Task<(User user, List<Order> orders, List<Payment> payments)>
    GetUserDataAsync(int userId)
{
    var userTask = _userService.GetUserAsync(userId);
    var ordersTask = _orderService.GetUserOrdersAsync(userId);
    var paymentsTask = _paymentService.GetUserPaymentsAsync(userId);

    await Task.WhenAll(userTask, ordersTask, paymentsTask);

    return (userTask.Result, ordersTask.Result, paymentsTask.Result);
}

// ❌ BAD - Sequential execution
public async Task<(User, List<Order>, List<Payment>)> GetUserDataAsync(int userId)
{
    var user = await _userService.GetUserAsync(userId);
    var orders = await _orderService.GetUserOrdersAsync(userId);
    var payments = await _paymentService.GetUserPaymentsAsync(userId);

    return (user, orders, payments);
}
```

### ❌ DON'T: Use .Result or .Wait()

```csharp
// ❌ BAD - Can cause deadlocks
public User GetUser(int id)
{
    return _userService.GetUserAsync(id).Result;
}

// ✅ GOOD - Async all the way
public async Task<User> GetUserAsync(int id)
{
    return await _userService.GetUserAsync(id);
}
```

---

## Exception Handling

### ✅ DO: Use Exception Filters/Middleware

```csharp
// ✅ GOOD - Global exception handling
public class GlobalExceptionHandler : IExceptionHandler
{
    private readonly ILogger<GlobalExceptionHandler> _logger;

    public GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger)
    {
        _logger = logger;
    }

    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        _logger.LogError(exception, "An unhandled exception occurred");

        var (status, message) = exception switch
        {
            NotFoundException => (StatusCodes.Status404NotFound, exception.Message),
            ValidationException => (StatusCodes.Status400BadRequest, exception.Message),
            UnauthorizedException => (StatusCodes.Status401Unauthorized, "Unauthorized"),
            _ => (StatusCodes.Status500InternalServerError, "An error occurred")
        };

        httpContext.Response.StatusCode = status;
        await httpContext.Response.WriteAsJsonAsync(new { error = message }, cancellationToken);

        return true;
    }
}

// Register in Program.cs
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
```

### ✅ DO: Use Custom Exceptions for Business Logic

```csharp
// ✅ GOOD - Domain-specific exceptions
public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message) { }
}

public class ValidationException : Exception
{
    public ValidationException(string message) : base(message) { }
}

// Usage
public async Task<Order> GetOrderAsync(int id)
{
    var order = await _repository.FindAsync(id);
    if (order is null)
        throw new NotFoundException($"Order {id} not found");

    return order;
}
```

### ❌ DON'T: Catch and Ignore Exceptions

```csharp
// ❌ BAD - Swallowing exceptions
try
{
    await ProcessDataAsync();
}
catch { } // Silent failure

// ✅ GOOD - Log and handle appropriately
try
{
    await ProcessDataAsync();
}
catch (Exception ex)
{
    _logger.LogError(ex, "Failed to process data");
    throw; // or handle appropriately
}
```

---

## Security Standards

### ✅ DO: Validate Input with Data Annotations

```csharp
public record CreateUserRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; init; } = string.Empty;

    [Required]
    [StringLength(100, MinimumLength = 2)]
    public string Name { get; init; } = string.Empty;

    [Required]
    [StringLength(100, MinimumLength = 8)]
    [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*$")]
    public string Password { get; init; } = string.Empty;
}
```

### ✅ DO: Use Authorization Policies

```csharp
// ✅ GOOD - Policy-based authorization
[Authorize(Policy = "AdminOnly")]
[HttpDelete("{id}")]
public async Task<IActionResult> DeleteUser(int id)
{
    await _userService.DeleteAsync(id);
    return NoContent();
}

// Program.cs
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin"));
});
```

### ✅ DO: Store Secrets Securely

```csharp
// ✅ GOOD - Use configuration/key vault
public class EmailService
{
    private readonly string _apiKey;

    public EmailService(IConfiguration configuration)
    {
        _apiKey = configuration["EmailService:ApiKey"]
            ?? throw new InvalidOperationException("API key not configured");
    }
}

// ❌ BAD - Hardcoded secrets
private const string ApiKey = "sk-1234567890"; // Never do this!
```

### ✅ DO: Use HTTPS and HSTS

```csharp
// Program.cs
if (!app.Environment.IsDevelopment())
{
    app.UseHsts();
}

app.UseHttpsRedirection();
```

---

## Logging & Monitoring

### ✅ DO: Use Structured Logging

```csharp
// ✅ GOOD - Structured logging
_logger.LogInformation(
    "User {UserId} created order {OrderId} with amount {Amount:C}",
    userId, orderId, amount);

// ❌ BAD - String concatenation
_logger.LogInformation($"User {userId} created order {orderId} with amount {amount}");
```

### ✅ DO: Use Appropriate Log Levels

```csharp
// Trace - Very detailed, typically only in development
_logger.LogTrace("Entering method {MethodName}", nameof(ProcessOrder));

// Debug - Internal system events
_logger.LogDebug("Cache hit for key {CacheKey}", key);

// Information - General flow
_logger.LogInformation("User {UserId} logged in successfully", userId);

// Warning - Abnormal or unexpected events
_logger.LogWarning("Retry attempt {Attempt} for operation {Operation}", attempt, operation);

// Error - Errors and exceptions
_logger.LogError(ex, "Failed to process payment for order {OrderId}", orderId);

// Critical - Critical failures
_logger.LogCritical(ex, "Database connection failed");
```

### ✅ DO: Add Health Checks

```csharp
// Program.cs
builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>()
    .AddUrlGroup(new Uri("https://api.external.com/health"), "External API");

app.MapHealthChecks("/health");
```

---

## Code Quality & Maintainability

### ✅ DO: Keep Methods Small and Focused

```csharp
// ✅ GOOD - Single responsibility
[HttpPost]
public async Task<ActionResult<OrderDto>> CreateOrder([FromBody] CreateOrderDto dto)
{
    var order = await _orderService.CreateAsync(dto);
    return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
}

// Service handles business logic
public async Task<OrderDto> CreateAsync(CreateOrderDto dto)
{
    ValidateOrder(dto);
    var order = MapToEntity(dto);
    await _repository.AddAsync(order);
    await _emailService.SendOrderConfirmationAsync(order);
    return MapToDto(order);
}
```

### ✅ DO: Use Dependency Injection

```csharp
// ✅ GOOD
public class OrderService : IOrderService
{
    private readonly IOrderRepository _repository;
    private readonly IEmailService _emailService;

    public OrderService(IOrderRepository repository, IEmailService emailService)
    {
        _repository = repository;
        _emailService = emailService;
    }
}

// Register services
builder.Services.AddScoped<IOrderService, OrderService>();
```

### ✅ DO: Use Constants for Magic Numbers/Strings

```csharp
// ✅ GOOD
public static class CacheKeys
{
    public const string UserPrefix = "user:";
    public const string OrderPrefix = "order:";
}

public static class CacheExpiration
{
    public static readonly TimeSpan Short = TimeSpan.FromMinutes(5);
    public static readonly TimeSpan Medium = TimeSpan.FromMinutes(30);
    public static readonly TimeSpan Long = TimeSpan.FromHours(1);
}

// Usage
_cache.Set($"{CacheKeys.UserPrefix}{userId}", user, CacheExpiration.Medium);
```

### ✅ DO: Use Expression-Bodied Members

```csharp
// ✅ GOOD - Concise for simple operations
public class UserDto
{
    public int Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public string Email { get; init; } = string.Empty;

    public string DisplayName => $"{Name} <{Email}>";
    public bool IsValid => !string.IsNullOrEmpty(Email);
}
```

### ✅ DO: Use XML Documentation for Public APIs

```csharp
/// <summary>
/// Gets a user by their unique identifier.
/// </summary>
/// <param name="id">The user's unique identifier.</param>
/// <returns>The user if found; otherwise, null.</returns>
/// <exception cref="NotFoundException">Thrown when the user is not found.</exception>
[HttpGet("{id}")]
public async Task<ActionResult<UserDto>> GetUser(int id)
{
    var user = await _userService.GetUserAsync(id);
    return Ok(user);
}
```

---

## Performance Checklist

- [ ] Use `async`/`await` for I/O operations
- [ ] Enable response compression
- [ ] Implement response caching where appropriate
- [ ] Use `AsNoTracking()` for read-only queries
- [ ] Project to DTOs in database queries
- [ ] Implement pagination for large datasets
- [ ] Use connection pooling
- [ ] Minimize allocations with `Span<T>`, `ArrayPool<T>`, `ObjectPool<T>`
- [ ] Cache compiled regex and EF queries
- [ ] Use `ValueTask<T>` for frequently synchronous paths
- [ ] Avoid N+1 query problems
- [ ] Use `Task.WhenAll()` for parallel operations

## Memory Efficiency Checklist

- [ ] Dispose `IDisposable` resources properly
- [ ] Use `using` declarations/statements
- [ ] Avoid unnecessary object allocations
- [ ] Use structs for small, immutable data
- [ ] Use `ArrayPool<T>` and `ObjectPool<T>`
- [ ] Be careful with closure allocations in LINQ
- [ ] Avoid boxing/unboxing
- [ ] Use `StringBuilder` for string concatenation in loops

## Code Quality Checklist

- [ ] Enable nullable reference types
- [ ] Use records for immutable DTOs
- [ ] Validate input only at API boundary
- [ ] Avoid unnecessary null checks
- [ ] Use pattern matching for cleaner null handling
- [ ] Return `ActionResult<T>` from controller actions
- [ ] Use custom exceptions for domain logic
- [ ] Implement global exception handling
- [ ] Use structured logging
- [ ] Add health checks
- [ ] Document public APIs with XML comments

---

## Summary

**Key Principles:**

1. **Be Async** - Use async/await for all I/O operations
2. **Be Efficient** - Minimize allocations, use pooling, avoid wasteful operations
3. **Be Safe** - Use nullable reference types, validate at boundaries
4. **Be Clear** - Write readable code, use DTOs, follow SOLID principles
5. **Be Secure** - Validate input, use authorization, protect secrets
6. **Be Observable** - Log appropriately, add health checks, monitor performance

Follow these standards to build performant, maintainable, and scalable REST APIs in .NET Core.
