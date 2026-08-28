# C# Fundamentals & OOP - Interview Questions & Answers

## 1. Why do you need a private constructor?

### Answer

A **private constructor** is a constructor that can only be called from within the same class. It's used in several design patterns and scenarios:

### Use Cases:

#### **1. Singleton Pattern**
Prevents external instantiation, ensuring only one instance exists:

```csharp
public class DatabaseConnection
{
    private static DatabaseConnection _instance;
    
    // Private constructor prevents external instantiation
    private DatabaseConnection()
    {
        // Initialize connection
    }
    
    public static DatabaseConnection GetInstance()
    {
        if (_instance == null)
        {
            _instance = new DatabaseConnection();
        }
        return _instance;
    }
}

// Usage
var db = DatabaseConnection.GetInstance(); // ✅ Works
var db2 = new DatabaseConnection();        // ❌ Compile error
```

#### **2. Static Utility Classes**
For classes that only contain static methods and shouldn't be instantiated:

```csharp
public class MathHelper
{
    // Private constructor prevents instantiation
    private MathHelper() { }
    
    public static int Add(int a, int b) => a + b;
    public static int Multiply(int a, int b) => a * b;
}

// Usage
int result = MathHelper.Add(5, 3);  // ✅ Works
var helper = new MathHelper();      // ❌ Compile error
```

#### **3. Factory Pattern**
Control object creation through factory methods:

```csharp
public class Product
{
    private Product() { } // Private constructor
    
    public string Name { get; private set; }
    public decimal Price { get; private set; }
    
    // Factory method controls creation
    public static Product Create(string name, decimal price)
    {
        if (string.IsNullOrEmpty(name))
            throw new ArgumentException("Name cannot be empty");
        if (price < 0)
            throw new ArgumentException("Price cannot be negative");
            
        return new Product { Name = name, Price = price };
    }
}

// Usage
var product = Product.Create("Laptop", 999.99m); // ✅ Works
var product2 = new Product();                     // ❌ Compile error
```

#### **4. Builder Pattern**
Prevent direct instantiation, force use of builder:

```csharp
public class User
{
    private User() { }
    
    public string Name { get; private set; }
    public string Email { get; private set; }
    
    public class Builder
    {
        private User _user = new User();
        
        public Builder WithName(string name)
        {
            _user.Name = name;
            return this;
        }
        
        public Builder WithEmail(string email)
        {
            _user.Email = email;
            return this;
        }
        
        public User Build() => _user;
    }
}

// Usage
var user = new User.Builder()
    .WithName("John")
    .WithEmail("john@example.com")
    .Build();
```

### Key Benefits:
- **Encapsulation**: Controls how objects are created
- **Design Patterns**: Enables Singleton, Factory, Builder patterns
- **Prevents Misuse**: Stops accidental instantiation of utility classes
- **Validation**: Ensures objects are created with valid state

---

## 2. What are async and await in C#?

### Answer

**`async`** and **`await`** are keywords in C# that enable asynchronous programming, allowing your code to perform non-blocking operations without freezing the UI or blocking threads.

### Key Concepts:

#### **async Keyword**
- Marks a method as asynchronous
- Method must return `Task`, `Task<T>`, or `void` (avoid void)
- Allows the method to use `await`

#### **await Keyword**
- Pauses execution until the awaited task completes
- Returns control to the caller
- Doesn't block the thread
- Can only be used in `async` methods

### Example: Synchronous vs Asynchronous

```csharp
// ❌ Synchronous - Blocks the thread
public string GetData()
{
    Thread.Sleep(5000); // Blocks for 5 seconds
    return "Data loaded";
}

// ✅ Asynchronous - Non-blocking
public async Task<string> GetDataAsync()
{
    await Task.Delay(5000); // Doesn't block, returns control
    return "Data loaded";
}
```

### Real-World Example: Web API Controller

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
    
    // Synchronous - Blocks thread
    [HttpGet("sync")]
    public IActionResult GetProductsSync()
    {
        var products = _productService.GetAllProducts(); // Blocks
        return Ok(products);
    }
    
    // Asynchronous - Non-blocking
    [HttpGet("async")]
    public async Task<IActionResult> GetProductsAsync()
    {
        var products = await _productService.GetAllProductsAsync(); // Non-blocking
        return Ok(products);
    }
}
```

### Database Operations Example

```csharp
public class ProductService
{
    private readonly ApplicationDbContext _context;
    
    public ProductService(ApplicationDbContext context)
    {
        _context = context;
    }
    
    // Asynchronous database query
    public async Task<List<Product>> GetAllProductsAsync()
    {
        // This doesn't block the thread while waiting for database
        return await _context.Products.ToListAsync();
    }
    
    // Multiple async operations
    public async Task<ProductDetails> GetProductDetailsAsync(int id)
    {
        var product = await _context.Products.FindAsync(id);
        var reviews = await _context.Reviews
            .Where(r => r.ProductId == id)
            .ToListAsync();
        var images = await _context.Images
            .Where(i => i.ProductId == id)
            .ToListAsync();
            
        return new ProductDetails
        {
            Product = product,
            Reviews = reviews,
            Images = images
        };
    }
}
```

### Parallel Execution Example

```csharp
public async Task<DashboardData> GetDashboardDataAsync()
{
    // Execute multiple operations in parallel
    var productsTask = _productService.GetAllProductsAsync();
    var ordersTask = _orderService.GetRecentOrdersAsync();
    var usersTask = _userService.GetActiveUsersAsync();
    
    // Wait for all to complete
    await Task.WhenAll(productsTask, ordersTask, usersTask);
    
    return new DashboardData
    {
        Products = await productsTask,
        Orders = await ordersTask,
        Users = await usersTask
    };
}
```

### Exception Handling

```csharp
public async Task<string> FetchDataAsync()
{
    try
    {
        var result = await _httpClient.GetStringAsync("https://api.example.com/data");
        return result;
    }
    catch (HttpRequestException ex)
    {
        // Handle HTTP errors
        return $"Error: {ex.Message}";
    }
    catch (TaskCanceledException ex)
    {
        // Handle timeout
        return "Request timed out";
    }
}
```

### Best Practices:

1. **Use async/await for I/O operations** (database, HTTP, file operations)
2. **Avoid async void** - Use `Task` or `Task<T>` instead
3. **Don't block async code** - Never use `.Result` or `.Wait()` on async methods
4. **Configure await** - Use `ConfigureAwait(false)` in library code
5. **Async all the way** - Don't mix sync and async unnecessarily

### Common Mistakes:

```csharp
// ❌ WRONG: Blocking async code
var result = GetDataAsync().Result; // Deadlock risk!

// ❌ WRONG: async void
public async void DoSomething() { } // Use Task instead

// ✅ CORRECT: Proper async usage
var result = await GetDataAsync();
```

---

## 3. Explain the difference between ref and out parameters.

### Answer

Both **`ref`** and **`out`** allow methods to modify variables passed as parameters, but they have important differences:

### Key Differences:

| Feature | `ref` | `out` |
|---------|-------|-------|
| **Initialization** | Variable must be initialized before passing | Variable doesn't need initialization |
| **Assignment** | Method may or may not assign value | Method **must** assign value before returning |
| **Use Case** | Pass value in, may modify it | Return multiple values |
| **Reading** | Can read value before assignment | Cannot read before assignment |

### `ref` Parameter Example

```csharp
public void Increment(ref int number)
{
    number++; // Modifies the original variable
}

// Usage
int value = 10;
Increment(ref value);
Console.WriteLine(value); // Output: 11

// ❌ Error: Must initialize before passing
int uninitialized;
Increment(ref uninitialized); // Compile error!
```

### `out` Parameter Example

```csharp
public bool TryDivide(int dividend, int divisor, out int result)
{
    if (divisor == 0)
    {
        result = 0; // Must assign even on failure
        return false;
    }
    
    result = dividend / divisor; // Must assign before return
    return true;
}

// Usage
int quotient;
if (TryDivide(10, 2, out quotient))
{
    Console.WriteLine($"Result: {quotient}"); // Output: Result: 5
}

// ✅ Works: No initialization needed
int uninitialized;
TryDivide(10, 2, out uninitialized); // ✅ Valid
```

### Real-World Example: Multiple Return Values

```csharp
// Using out parameters to return multiple values
public bool TryParseUser(string input, out string name, out int age, out string email)
{
    name = null;
    age = 0;
    email = null;
    
    var parts = input.Split(',');
    if (parts.Length != 3)
        return false;
    
    name = parts[0];
    if (!int.TryParse(parts[1], out age))
        return false;
    email = parts[2];
    
    return true;
}

// Usage
if (TryParseUser("John,30,john@example.com", out string name, out int age, out string email))
{
    Console.WriteLine($"Name: {name}, Age: {age}, Email: {email}");
}
```

### Modern C# Alternative: Tuples

```csharp
// Modern approach using tuples (C# 7.0+)
public (bool success, string name, int age, string email) ParseUser(string input)
{
    var parts = input.Split(',');
    if (parts.Length != 3 || !int.TryParse(parts[1], out int age))
        return (false, null, 0, null);
    
    return (true, parts[0], age, parts[2]);
}

// Usage
var (success, name, age, email) = ParseUser("John,30,john@example.com");
if (success)
{
    Console.WriteLine($"Name: {name}, Age: {age}, Email: {email}");
}
```

### `ref` for Reference Types

```csharp
public void Swap(ref string a, ref string b)
{
    string temp = a;
    a = b;
    b = temp;
}

// Usage
string first = "Hello";
string second = "World";
Swap(ref first, ref second);
Console.WriteLine($"{first} {second}"); // Output: World Hello
```

### When to Use:

- **Use `ref`**: When you want to pass a value that may be modified, and the variable must be initialized
- **Use `out`**: When you need to return multiple values from a method, or when the variable doesn't need initialization
- **Prefer tuples**: For modern C# (7.0+), consider using tuples instead of `out` parameters

---

## 4. SOLID Principle with examples?

### Answer

**SOLID** is an acronym for five object-oriented design principles that make software more maintainable, flexible, and understandable:

### S - Single Responsibility Principle (SRP)

**Definition**: A class should have only one reason to change (one responsibility).

#### ❌ Violation Example:

```csharp
public class User
{
    public string Name { get; set; }
    public string Email { get; set; }
    
    // ❌ User class handling multiple responsibilities
    public void SaveToDatabase() { /* Database logic */ }
    public void SendEmail() { /* Email logic */ }
    public void GenerateReport() { /* Report logic */ }
    public void ValidateUser() { /* Validation logic */ }
}
```

#### ✅ Correct Example:

```csharp
// Single responsibility: User data
public class User
{
    public string Name { get; set; }
    public string Email { get; set; }
}

// Single responsibility: Database operations
public class UserRepository
{
    public void Save(User user) { /* Database logic */ }
    public User GetById(int id) { /* Database logic */ }
}

// Single responsibility: Email operations
public class EmailService
{
    public void SendEmail(User user, string message) { /* Email logic */ }
}

// Single responsibility: Validation
public class UserValidator
{
    public bool Validate(User user) { /* Validation logic */ }
}
```

---

### O - Open/Closed Principle (OCP)

**Definition**: Software entities should be open for extension but closed for modification.

#### ❌ Violation Example:

```csharp
public class DiscountCalculator
{
    public decimal CalculateDiscount(string customerType, decimal amount)
    {
        // ❌ Must modify this class to add new customer types
        if (customerType == "Regular")
            return amount * 0.1m;
        else if (customerType == "Premium")
            return amount * 0.2m;
        else if (customerType == "VIP")
            return amount * 0.3m;
        // Adding new type requires modifying this method
        return 0;
    }
}
```

#### ✅ Correct Example:

```csharp
// Base class - closed for modification
public abstract class DiscountCalculator
{
    public abstract decimal CalculateDiscount(decimal amount);
}

// Extensions - open for extension
public class RegularCustomerDiscount : DiscountCalculator
{
    public override decimal CalculateDiscount(decimal amount)
        => amount * 0.1m;
}

public class PremiumCustomerDiscount : DiscountCalculator
{
    public override decimal CalculateDiscount(decimal amount)
        => amount * 0.2m;
}

public class VIPCustomerDiscount : DiscountCalculator
{
    public override decimal CalculateDiscount(decimal amount)
        => amount * 0.3m;
}

// Usage - can add new types without modifying existing code
var calculator = new PremiumCustomerDiscount();
var discount = calculator.CalculateDiscount(1000);
```

---

### L - Liskov Substitution Principle (LSP)

**Definition**: Objects of a superclass should be replaceable with objects of its subclasses without breaking the application.

#### ❌ Violation Example:

```csharp
public class Rectangle
{
    public virtual int Width { get; set; }
    public virtual int Height { get; set; }
    
    public int Area => Width * Height;
}

public class Square : Rectangle
{
    // ❌ Violates LSP: Square changes behavior of base class
    public override int Width
    {
        set { base.Width = value; base.Height = value; }
    }
    
    public override int Height
    {
        set { base.Width = value; base.Height = value; }
    }
}

// This breaks expectations
void TestRectangle(Rectangle rect)
{
    rect.Width = 5;
    rect.Height = 4;
    Console.WriteLine(rect.Area); // Expected 20, but Square gives 16!
}
```

#### ✅ Correct Example:

```csharp
// Base interface
public interface IShape
{
    int Area { get; }
}

// Implementations
public class Rectangle : IShape
{
    public int Width { get; set; }
    public int Height { get; set; }
    public int Area => Width * Height;
}

public class Square : IShape
{
    public int Side { get; set; }
    public int Area => Side * Side;
}

// Now both can be used interchangeably
void PrintArea(IShape shape)
{
    Console.WriteLine(shape.Area); // Works for both Rectangle and Square
}
```

---

### I - Interface Segregation Principle (ISP)

**Definition**: Clients should not be forced to depend on interfaces they don't use.

#### ❌ Violation Example:

```csharp
// ❌ Large interface forcing all classes to implement everything
public interface IWorker
{
    void Work();
    void Eat();
    void Sleep();
}

public class Human : IWorker
{
    public void Work() { /* Implementation */ }
    public void Eat() { /* Implementation */ }
    public void Sleep() { /* Implementation */ }
}

public class Robot : IWorker
{
    public void Work() { /* Implementation */ }
    public void Eat() { /* ❌ Robots don't eat! */ }
    public void Sleep() { /* ❌ Robots don't sleep! */ }
}
```

#### ✅ Correct Example:

```csharp
// Segregated interfaces
public interface IWorkable
{
    void Work();
}

public interface IEatable
{
    void Eat();
}

public interface ISleepable
{
    void Sleep();
}

// Classes implement only what they need
public class Human : IWorkable, IEatable, ISleepable
{
    public void Work() { /* Implementation */ }
    public void Eat() { /* Implementation */ }
    public void Sleep() { /* Implementation */ }
}

public class Robot : IWorkable
{
    public void Work() { /* Implementation */ }
    // No need to implement Eat() or Sleep()
}
```

---

### D - Dependency Inversion Principle (DIP)

**Definition**: High-level modules should not depend on low-level modules. Both should depend on abstractions.

#### ❌ Violation Example:

```csharp
// ❌ High-level class depends on concrete low-level class
public class OrderService
{
    private SqlServerDatabase _database; // Direct dependency on concrete class
    
    public OrderService()
    {
        _database = new SqlServerDatabase(); // Tight coupling
    }
    
    public void SaveOrder(Order order)
    {
        _database.Save(order);
    }
}
```

#### ✅ Correct Example:

```csharp
// Abstraction
public interface IDatabase
{
    void Save<T>(T entity);
    T GetById<T>(int id);
}

// Low-level implementation
public class SqlServerDatabase : IDatabase
{
    public void Save<T>(T entity) { /* SQL Server implementation */ }
    public T GetById<T>(int id) { /* SQL Server implementation */ }
}

public class MongoDatabase : IDatabase
{
    public void Save<T>(T entity) { /* MongoDB implementation */ }
    public T GetById<T>(int id) { /* MongoDB implementation */ }
}

// High-level class depends on abstraction
public class OrderService
{
    private readonly IDatabase _database; // Depends on abstraction
    
    public OrderService(IDatabase database) // Dependency injection
    {
        _database = database;
    }
    
    public void SaveOrder(Order order)
    {
        _database.Save(order);
    }
}

// Usage with dependency injection
var sqlDb = new SqlServerDatabase();
var orderService = new OrderService(sqlDb); // Can easily swap implementations
```

### Benefits of SOLID Principles:

1. **Maintainability**: Easier to understand and modify code
2. **Flexibility**: Easy to extend without breaking existing code
3. **Testability**: Easier to write unit tests with dependency injection
4. **Reusability**: Components can be reused in different contexts
5. **Reduced Coupling**: Classes are less dependent on each other

---

## Summary

- **Private Constructor**: Used for Singleton, Factory, Builder patterns, and utility classes
- **async/await**: Enables non-blocking asynchronous programming for I/O operations
- **ref vs out**: `ref` requires initialization, `out` must assign value; use `out` for multiple return values
- **SOLID Principles**: Five principles for better object-oriented design, making code more maintainable and flexible

