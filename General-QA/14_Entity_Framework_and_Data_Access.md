# Entity Framework & Data Access - Interview Guide

## What is Entity Framework?

**Entity Framework (EF) Core** is an Object-Relational Mapping (ORM) framework for .NET. It allows you to work with databases using .NET objects instead of writing SQL directly.

**Benefits:**
- Write code, not SQL
- Type-safe queries
- Automatic change tracking
- Database migrations
- Works with multiple databases (SQL Server, PostgreSQL, MySQL, etc.)

---

## 1. EF Core Basics

### DbContext Lifecycle

**DbContext:**
- Main class for interacting with database
- Represents a session with the database
- Should be short-lived (per request in web apps)

**Creating DbContext:**
```csharp
public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }
    
    public DbSet<User> Users { get; set; }
    public DbSet<Order> Orders { get; set; }
}
```

**Registration (ASP.NET Core):**
```csharp
// Program.cs or Startup.cs
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));
```

**Lifetime:**
- **Scoped**: One instance per HTTP request (recommended)
- **Transient**: New instance every time (not recommended)
- **Singleton**: One instance for entire app (not recommended)

**Disposal:**
- Automatically disposed at end of request
- Or use `using` statement:
```csharp
using (var context = new ApplicationDbContext(options))
{
    // Use context
} // Automatically disposed
```

---

### LINQ Queries

**LINQ to Entities:**
- Write queries using LINQ syntax
- EF translates to SQL

**Query Syntax:**
```csharp
var users = from u in context.Users
            where u.Age >= 18
            select u;
```

**Method Syntax (More Common):**
```csharp
var users = context.Users
    .Where(u => u.Age >= 18)
    .ToList();
```

**Common LINQ Methods:**
```csharp
// Filtering
var adults = context.Users.Where(u => u.Age >= 18);

// Projection (select specific fields)
var names = context.Users.Select(u => u.Name);

// Ordering
var sorted = context.Users.OrderBy(u => u.Name);
var desc = context.Users.OrderByDescending(u => u.CreatedDate);

// First/Single
var first = context.Users.FirstOrDefault(u => u.Id == 1);
var single = context.Users.SingleOrDefault(u => u.Email == "test@example.com");

// Aggregation
var count = context.Users.Count();
var maxAge = context.Users.Max(u => u.Age);
var avgAge = context.Users.Average(u => u.Age);

// Grouping
var grouped = context.Users
    .GroupBy(u => u.City)
    .Select(g => new { City = g.Key, Count = g.Count() });
```

**Deferred Execution:**
- Queries execute when enumerated (ToList, First, etc.)
- Can build queries incrementally

```csharp
// Query not executed yet
var query = context.Users.Where(u => u.Age >= 18);

// Add more conditions
if (filterByCity)
{
    query = query.Where(u => u.City == city);
}

// Now executes
var results = query.ToList();
```

---

### Change Tracking

**Purpose**: EF tracks changes to entities automatically

**How It Works:**
- Entities loaded from database are tracked
- Changes detected automatically
- SaveChanges() persists changes

**Example:**
```csharp
// Load entity (tracked)
var user = context.Users.Find(1);

// Modify
user.Name = "New Name";
user.Email = "newemail@example.com";

// EF detects changes automatically
context.SaveChanges(); // Updates database
```

**Tracking States:**
- **Added**: New entity, not in database
- **Modified**: Entity changed
- **Deleted**: Entity marked for deletion
- **Unchanged**: No changes
- **Detached**: Not tracked

**Checking State:**
```csharp
var entry = context.Entry(user);
Console.WriteLine(entry.State); // Modified, Added, etc.
```

**AsNoTracking():**
- Disable tracking for read-only queries
- Better performance
- Use when you won't modify entities

```csharp
var users = context.Users
    .AsNoTracking()
    .ToList(); // Not tracked, faster
```

---

### SaveChanges and Transactions

**SaveChanges():**
- Persists all tracked changes to database
- Returns number of rows affected

```csharp
context.Users.Add(new User { Name = "John" });
context.Orders.Add(new Order { UserId = 1 });
int rowsAffected = context.SaveChanges(); // Returns 2
```

**Transactions:**
- Multiple operations as single unit
- All succeed or all fail (atomicity)

**Automatic Transaction:**
```csharp
// SaveChanges() is already transactional
context.Users.Add(user1);
context.Users.Add(user2);
context.SaveChanges(); // Both saved or both fail
```

**Explicit Transaction:**
```csharp
using (var transaction = context.Database.BeginTransaction())
{
    try
    {
        context.Users.Add(user);
        context.SaveChanges();
        
        context.Orders.Add(order);
        context.SaveChanges();
        
        transaction.Commit(); // All succeed
    }
    catch
    {
        transaction.Rollback(); // All fail
        throw;
    }
}
```

**Database.EnsureCreated() / EnsureDeleted():**
```csharp
// Create database if not exists (development only)
context.Database.EnsureCreated();

// Delete database if exists
context.Database.EnsureDeleted();
```

---

## 2. Advanced EF

### Migrations

**Purpose**: Version control for database schema

**Creating Migration:**
```bash
dotnet ef migrations add InitialCreate
```

**What It Does:**
- Compares current model to database
- Generates migration file with Up() and Down() methods
- Up(): Apply changes
- Down(): Revert changes

**Migration File:**
```csharp
public partial class InitialCreate : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "Users",
            columns: table => new
            {
                Id = table.Column<int>(nullable: false)
                    .Annotation("SqlServer:ValueGenerationStrategy", ...),
                Name = table.Column<string>(nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Users", x => x.Id);
            });
    }
    
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "Users");
    }
}
```

**Applying Migrations:**
```bash
# Update database to latest migration
dotnet ef database update

# Update to specific migration
dotnet ef database update MigrationName

# Rollback one migration
dotnet ef database update PreviousMigrationName
```

**In Code:**
```csharp
// Program.cs
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    context.Database.Migrate(); // Apply pending migrations
}
```

**Migrations Best Practices:**
- Create migration for each schema change
- Review migration SQL before applying
- Test migrations on staging first
- Keep migrations small and focused

---

### Raw SQL Queries

**When to Use:**
- Complex queries EF can't generate
- Performance-critical queries
- Stored procedures
- Bulk operations

**FromSqlRaw:**
```csharp
var users = context.Users
    .FromSqlRaw("SELECT * FROM Users WHERE Age > {0}", 18)
    .ToList();
```

**Parameterized (Recommended):**
```csharp
var age = 18;
var users = context.Users
    .FromSqlRaw("SELECT * FROM Users WHERE Age > {0}", age)
    .ToList();
```

**With LINQ:**
```csharp
var users = context.Users
    .FromSqlRaw("SELECT * FROM Users")
    .Where(u => u.Age > 18)
    .ToList();
```

**ExecuteSqlRaw (Non-query):**
```csharp
context.Database.ExecuteSqlRaw(
    "UPDATE Users SET Status = 'Active' WHERE CreatedDate > {0}",
    DateTime.Now.AddDays(-30));
```

**Stored Procedures:**
```csharp
var users = context.Users
    .FromSqlRaw("EXEC GetUsersByCity {0}", city)
    .ToList();
```

**⚠️ Security:**
- Always use parameters (prevents SQL injection)
- Validate input
- Prefer LINQ when possible

---

### Stored Procedures

**Calling Stored Procedures:**
```csharp
// With return data
var users = context.Users
    .FromSqlRaw("EXEC GetUsers @City = {0}", city)
    .ToList();

// Without return data
context.Database.ExecuteSqlRaw(
    "EXEC UpdateUserStatus @UserId = {0}, @Status = {1}",
    userId, status);
```

**Mapping to Entity:**
```csharp
// Stored procedure must return columns matching entity
var users = context.Users
    .FromSqlRaw("EXEC GetActiveUsers")
    .AsNoTracking()
    .ToList();
```

---

### Performance Optimization

**Async Queries:**
```csharp
// Synchronous (blocks thread)
var users = context.Users.ToList();

// Asynchronous (non-blocking)
var users = await context.Users.ToListAsync();
```

**Async Methods:**
- `ToListAsync()`
- `FirstOrDefaultAsync()`
- `CountAsync()`
- `SaveChangesAsync()`

**Compiled Queries:**
- Cache query plan
- Faster for repeated queries

```csharp
private static readonly Func<ApplicationDbContext, int, Task<User>> GetUserById =
    EF.CompileAsyncQuery((ApplicationDbContext context, int id) =>
        context.Users.FirstOrDefault(u => u.Id == id));

// Usage
var user = await GetUserById(context, 1);
```

**Include (Eager Loading):**
```csharp
// Load related data in single query
var users = context.Users
    .Include(u => u.Orders)
    .ThenInclude(o => o.Items)
    .ToList();
```

**Select Specific Fields:**
```csharp
// Only load needed fields
var users = context.Users
    .Select(u => new { u.Id, u.Name, u.Email })
    .ToList();
```

**Pagination:**
```csharp
var page = 1;
var pageSize = 10;

var users = context.Users
    .Skip((page - 1) * pageSize)
    .Take(pageSize)
    .ToList();
```

**Bulk Operations:**
```csharp
// AddRange (more efficient than multiple Add)
context.Users.AddRange(userList);
context.SaveChanges();

// For large bulk operations, consider:
// - EF Core Extensions (BulkInsert, BulkUpdate)
// - Raw SQL
// - SqlBulkCopy
```

---

### Connection String Management

**appsettings.json:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MyDb;Trusted_Connection=True;"
  }
}
```

**Accessing:**
```csharp
var connectionString = builder.Configuration
    .GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));
```

**Azure Key Vault:**
```csharp
var keyVaultUrl = builder.Configuration["KeyVault:Url"];
var client = new SecretClient(new Uri(keyVaultUrl), new DefaultAzureCredential());
var connectionString = await client.GetSecretAsync("DatabaseConnectionString");

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString.Value.Value));
```

**Environment-Specific:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "#{ConnectionString}#" // Replace in deployment
  }
}
```

---

## Interview Questions to Prepare

1. **What is Entity Framework? What are its benefits?**
2. **Explain the DbContext lifecycle.**
3. **What is change tracking? How does it work?**
4. **What are migrations? How do you create and apply them?**
5. **When would you use raw SQL queries?**
6. **How do you optimize EF Core queries?**
7. **Explain the difference between synchronous and asynchronous queries.**
8. **What is eager loading? How do you use Include()?**
9. **How do you handle transactions in EF Core?**
10. **What is deferred execution in LINQ?**

