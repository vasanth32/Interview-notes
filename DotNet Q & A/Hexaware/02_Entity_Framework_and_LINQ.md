# Entity Framework & LINQ - Interview Questions & Answers

## 1. What is late binding and early binding in Entity Framework?

### Answer

**Binding** refers to when Entity Framework determines which database provider and SQL to use. There are two approaches:

### Early Binding (Compile-Time)

**Definition**: The database provider and query structure are determined at **compile time**. Uses strongly-typed LINQ queries.

#### Characteristics:
- ✅ Type-safe (compile-time checking)
- ✅ IntelliSense support
- ✅ Better performance (query optimization at compile time)
- ✅ Easier to refactor

#### Example:

```csharp
// Early binding - strongly typed
public class ProductService
{
    private readonly ApplicationDbContext _context;
    
    public ProductService(ApplicationDbContext context)
    {
        _context = context;
    }
    
    // Early binding: Query structure known at compile time
    public List<Product> GetProductsByCategory(string category)
    {
        return _context.Products
            .Where(p => p.Category == category && p.IsActive)
            .OrderBy(p => p.Name)
            .ToList();
    }
    
    // Early binding with includes
    public Product GetProductWithOrders(int productId)
    {
        return _context.Products
            .Include(p => p.Orders)
            .ThenInclude(o => o.Customer)
            .FirstOrDefault(p => p.Id == productId);
    }
}
```

### Late Binding (Runtime)

**Definition**: The database provider and query structure are determined at **runtime**. Uses dynamic queries or string-based queries.

#### Characteristics:
- ⚠️ Less type-safe
- ⚠️ No IntelliSense
- ✅ More flexible (can build queries dynamically)
- ⚠️ Runtime errors possible

#### Example:

```csharp
// Late binding - dynamic queries
public class DynamicProductService
{
    private readonly ApplicationDbContext _context;
    
    public DynamicProductService(ApplicationDbContext context)
    {
        _context = context;
    }
    
    // Late binding: Query built at runtime
    public List<Product> GetProductsDynamic(string propertyName, object value)
    {
        var query = _context.Products.AsQueryable();
        
        // Building query dynamically at runtime
        var parameter = Expression.Parameter(typeof(Product), "p");
        var property = Expression.Property(parameter, propertyName);
        var constant = Expression.Constant(value);
        var condition = Expression.Equal(property, constant);
        var lambda = Expression.Lambda<Func<Product, bool>>(condition, parameter);
        
        query = query.Where(lambda);
        return query.ToList();
    }
    
    // Late binding with FromSqlRaw (raw SQL)
    public List<Product> GetProductsByRawSql(string category)
    {
        // SQL determined at runtime
        return _context.Products
            .FromSqlRaw("SELECT * FROM Products WHERE Category = {0}", category)
            .ToList();
    }
}
```

### When to Use Each:

#### Use Early Binding When:
- ✅ You know the query structure at compile time
- ✅ You want type safety and IntelliSense
- ✅ Performance is critical
- ✅ You're following standard CRUD patterns

#### Use Late Binding When:
- ✅ Building dynamic queries based on user input
- ✅ Need to support multiple database providers
- ✅ Creating generic query builders
- ✅ Working with stored procedures

### Best Practice:

**Prefer early binding** for most scenarios. Use late binding only when you need dynamic query building capabilities.

---

## 2. How do you solve N+1 problem in Entity Framework?

### Answer

The **N+1 problem** occurs when you execute one query to fetch a list of entities, then execute N additional queries (one per entity) to fetch related data. This results in **N+1 database round trips** instead of a single optimized query.

### The Problem:

#### ❌ N+1 Problem Example:

```csharp
// This causes N+1 problem
public List<Order> GetOrdersWithCustomers()
{
    var orders = _context.Orders.ToList(); // 1 query - gets all orders
    
    foreach (var order in orders)
    {
        // N queries - one for each order's customer
        var customer = _context.Customers.Find(order.CustomerId);
        order.Customer = customer;
    }
    
    return orders; // Total: 1 + N queries
}

// If you have 100 orders, this executes 101 queries!
```

### Solutions:

#### **Solution 1: Eager Loading with Include()**

Load related data in a single query:

```csharp
// ✅ Eager loading - single query
public List<Order> GetOrdersWithCustomers()
{
    return _context.Orders
        .Include(o => o.Customer)  // Loads customer in same query
        .Include(o => o.OrderItems) // Can include multiple relationships
        .ThenInclude(oi => oi.Product) // Nested includes
        .ToList(); // Only 1 query executed
}
```

#### **Solution 2: Projection (Select)**

Select only needed data:

```csharp
// ✅ Projection - only fetches needed data
public List<OrderDto> GetOrdersWithCustomers()
{
    return _context.Orders
        .Select(o => new OrderDto
        {
            OrderId = o.Id,
            OrderDate = o.OrderDate,
            CustomerName = o.Customer.Name,  // Fetched in same query
            CustomerEmail = o.Customer.Email,
            TotalAmount = o.OrderItems.Sum(oi => oi.Price)
        })
        .ToList(); // Single optimized query
}
```

#### **Solution 3: Explicit Loading**

Load related data when needed, but efficiently:

```csharp
// ✅ Explicit loading - controlled loading
public Order GetOrderWithCustomer(int orderId)
{
    var order = _context.Orders.Find(orderId);
    
    // Load related data explicitly
    _context.Entry(order)
        .Reference(o => o.Customer)
        .Load();
    
    _context.Entry(order)
        .Collection(o => o.OrderItems)
        .Load();
    
    return order; // All loaded efficiently
}
```

#### **Solution 4: Split Queries (EF Core 5+)**

Split complex queries into multiple queries automatically:

```csharp
// ✅ Split queries - EF Core handles optimization
public List<Order> GetOrdersWithCustomers()
{
    return _context.Orders
        .Include(o => o.Customer)
        .Include(o => o.OrderItems)
            .ThenInclude(oi => oi.Product)
        .AsSplitQuery() // Splits into optimized queries
        .ToList();
}
```

### Real-World Example:

#### ❌ Before (N+1 Problem):

```csharp
[HttpGet]
public IActionResult GetOrders()
{
    var orders = _context.Orders.ToList(); // Query 1
    
    foreach (var order in orders)
    {
        order.Customer = _context.Customers.Find(order.CustomerId); // Query 2, 3, 4...
        order.OrderItems = _context.OrderItems
            .Where(oi => oi.OrderId == order.Id)
            .ToList(); // More queries...
    }
    
    return Ok(orders); // 100 orders = 201+ queries!
}
```

#### ✅ After (Optimized):

```csharp
[HttpGet]
public IActionResult GetOrders()
{
    var orders = _context.Orders
        .Include(o => o.Customer)
        .Include(o => o.OrderItems)
            .ThenInclude(oi => oi.Product)
        .ToList(); // Single query with joins
    
    return Ok(orders); // Only 1 query!
}
```

### Performance Comparison:

```
N+1 Problem (100 orders):
- Query 1: SELECT * FROM Orders
- Query 2: SELECT * FROM Customers WHERE Id = 1
- Query 3: SELECT * FROM Customers WHERE Id = 2
- ...
- Query 101: SELECT * FROM Customers WHERE Id = 100
Total: 101 database round trips

Optimized (Eager Loading):
- Query 1: SELECT o.*, c.* FROM Orders o 
           LEFT JOIN Customers c ON o.CustomerId = c.Id
Total: 1 database round trip
```

### Best Practices:

1. **Always use Include()** for known relationships
2. **Use projection** when you only need specific fields
3. **Monitor queries** using logging: `optionsBuilder.LogTo(Console.WriteLine)`
4. **Use AsSplitQuery()** for complex queries with multiple collections
5. **Avoid lazy loading** in web APIs (can cause N+1)

### Detecting N+1 Problems:

```csharp
// Enable query logging
protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
{
    optionsBuilder
        .UseSqlServer(connectionString)
        .LogTo(Console.WriteLine, LogLevel.Information); // Log all queries
}
```

---

## 3. How do you handle pagination in LINQ?

### Answer

**Pagination** is the process of dividing data into discrete pages. In LINQ, you use `Skip()` and `Take()` methods.

### Basic Pagination:

```csharp
public class ProductService
{
    private readonly ApplicationDbContext _context;
    
    public ProductService(ApplicationDbContext context)
    {
        _context = context;
    }
    
    // Basic pagination
    public List<Product> GetProducts(int pageNumber, int pageSize)
    {
        return _context.Products
            .OrderBy(p => p.Name)
            .Skip((pageNumber - 1) * pageSize) // Skip previous pages
            .Take(pageSize)                      // Take only page size
            .ToList();
    }
}
```

### Pagination with Total Count:

```csharp
public class PagedResult<T>
{
    public List<T> Items { get; set; }
    public int TotalCount { get; set; }
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
    public bool HasPreviousPage => PageNumber > 1;
    public bool HasNextPage => PageNumber < TotalPages;
}

public PagedResult<Product> GetProductsPaged(int pageNumber, int pageSize)
{
    var query = _context.Products.OrderBy(p => p.Name);
    
    var totalCount = query.Count(); // Get total before pagination
    
    var items = query
        .Skip((pageNumber - 1) * pageSize)
        .Take(pageSize)
        .ToList();
    
    return new PagedResult<Product>
    {
        Items = items,
        TotalCount = totalCount,
        PageNumber = pageNumber,
        PageSize = pageSize
    };
}
```

### Web API Pagination Example:

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    
    public ProductsController(IProductService productService)
    {
        _productService = productService;
    }
    
    [HttpGet]
    public async Task<ActionResult<PagedResult<ProductDto>>> GetProducts(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 10)
    {
        if (pageNumber < 1) pageNumber = 1;
        if (pageSize < 1 || pageSize > 100) pageSize = 10;
        
        var result = await _productService.GetProductsPagedAsync(pageNumber, pageSize);
        
        // Add pagination headers
        Response.Headers.Add("X-Total-Count", result.TotalCount.ToString());
        Response.Headers.Add("X-Page-Number", result.PageNumber.ToString());
        Response.Headers.Add("X-Page-Size", result.PageSize.ToString());
        Response.Headers.Add("X-Total-Pages", result.TotalPages.ToString());
        
        return Ok(result);
    }
}
```

### Advanced Pagination with Filtering:

```csharp
public PagedResult<Product> GetProductsPaged(
    int pageNumber, 
    int pageSize,
    string searchTerm = null,
    string category = null,
    decimal? minPrice = null,
    decimal? maxPrice = null)
{
    var query = _context.Products.AsQueryable();
    
    // Apply filters
    if (!string.IsNullOrEmpty(searchTerm))
    {
        query = query.Where(p => p.Name.Contains(searchTerm) || 
                                 p.Description.Contains(searchTerm));
    }
    
    if (!string.IsNullOrEmpty(category))
    {
        query = query.Where(p => p.Category == category);
    }
    
    if (minPrice.HasValue)
    {
        query = query.Where(p => p.Price >= minPrice.Value);
    }
    
    if (maxPrice.HasValue)
    {
        query = query.Where(p => p.Price <= maxPrice.Value);
    }
    
    // Get total count after filtering
    var totalCount = query.Count();
    
    // Apply pagination
    var items = query
        .OrderBy(p => p.Name)
        .Skip((pageNumber - 1) * pageSize)
        .Take(pageSize)
        .ToList();
    
    return new PagedResult<Product>
    {
        Items = items,
        TotalCount = totalCount,
        PageNumber = pageNumber,
        PageSize = pageSize
    };
}
```

### Cursor-Based Pagination (For Large Datasets):

```csharp
// Better for very large datasets (avoids Skip() performance issues)
public class CursorPagedResult<T>
{
    public List<T> Items { get; set; }
    public string NextCursor { get; set; }
    public bool HasMore { get; set; }
}

public CursorPagedResult<Product> GetProductsCursor(
    string cursor = null,
    int pageSize = 10)
{
    var query = _context.Products.OrderBy(p => p.Id);
    
    if (!string.IsNullOrEmpty(cursor))
    {
        var cursorId = int.Parse(cursor);
        query = query.Where(p => p.Id > cursorId);
    }
    
    var items = query
        .Take(pageSize + 1) // Take one extra to check if more exists
        .ToList();
    
    var hasMore = items.Count > pageSize;
    if (hasMore)
    {
        items = items.Take(pageSize).ToList();
    }
    
    return new CursorPagedResult<Product>
    {
        Items = items,
        NextCursor = items.Any() ? items.Last().Id.ToString() : null,
        HasMore = hasMore
    };
}
```

### Performance Considerations:

#### ❌ Inefficient (Loading All):

```csharp
// ❌ Loads all data into memory
var allProducts = _context.Products.ToList();
var paged = allProducts.Skip((page - 1) * size).Take(size);
```

#### ✅ Efficient (Database-Level):

```csharp
// ✅ Pagination happens in database
var paged = _context.Products
    .OrderBy(p => p.Name)
    .Skip((page - 1) * size)
    .Take(size)
    .ToList();
```

### Best Practices:

1. **Always order before pagination** - Results are unpredictable without ordering
2. **Use database-level pagination** - Don't load all data then paginate
3. **Set maximum page size** - Prevent loading too much data (e.g., max 100)
4. **Include total count only when needed** - It can be expensive
5. **Consider cursor-based pagination** for very large datasets
6. **Cache total counts** if they don't change frequently

### Example Response:

```json
{
  "items": [
    { "id": 1, "name": "Product 1" },
    { "id": 2, "name": "Product 2" }
  ],
  "totalCount": 150,
  "pageNumber": 1,
  "pageSize": 10,
  "totalPages": 15,
  "hasPreviousPage": false,
  "hasNextPage": true
}
```

---

## Summary

- **Early Binding**: Compile-time query determination, type-safe, better performance
- **Late Binding**: Runtime query determination, more flexible but less type-safe
- **N+1 Problem**: Solved using `Include()`, projection, explicit loading, or split queries
- **Pagination**: Use `Skip()` and `Take()` with proper ordering, include total count for UI, consider cursor-based for large datasets

