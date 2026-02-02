# Migration Checklist: .NET 8 to .NET 9

## Pre-Migration Checklist

### 1. Review Current Codebase
- [ ] Identify all LINQ operations using `GroupBy().Count()`
- [ ] Identify all LINQ operations using `GroupBy().Aggregate()`
- [ ] List all classes with simple constructors (candidates for primary constructors)
- [ ] Identify all collection initializations
- [ ] Review Web API endpoints (candidates for route groups)
- [ ] Check JSON serialization configurations

### 2. Update Development Environment
- [ ] Install .NET 9 SDK
- [ ] Update Visual Studio / VS Code / Rider to latest version
- [ ] Update NuGet packages to .NET 9 compatible versions
- [ ] Review breaking changes in .NET 9 release notes

---

## Migration Steps

### Step 1: Update Project Files

#### Update Target Framework
```xml
<!-- Before -->
<TargetFramework>net8.0</TargetFramework>

<!-- After -->
<TargetFramework>net9.0</TargetFramework>
```

#### Update Language Version (if needed)
```xml
<LangVersion>13.0</LangVersion>
```

- [ ] Update all `.csproj` files
- [ ] Update `global.json` if using version pinning
- [ ] Verify all projects compile

---

### Step 2: Update NuGet Packages

```bash
# Update all packages
dotnet list package --outdated
dotnet add package <PackageName> --version <LatestVersion>

# Or update all at once
dotnet add package Microsoft.AspNetCore.OpenApi
```

- [ ] Update ASP.NET Core packages
- [ ] Update Entity Framework Core (if used)
- [ ] Update other third-party packages
- [ ] Test after each package update

---

### Step 3: Refactor LINQ Operations

#### Replace GroupBy().Count() with CountBy()

**Before:**
```csharp
var gradeCounts = students
    .GroupBy(s => s.Grade)
    .Select(g => new { Grade = g.Key, Count = g.Count() });
```

**After:**
```csharp
var gradeCounts = students.CountBy(s => s.Grade);
```

- [ ] Find all `GroupBy().Count()` patterns
- [ ] Replace with `CountBy()`
- [ ] Test functionality
- [ ] Measure performance improvement (optional)

#### Replace GroupBy().Aggregate() with AggregateBy()

**Before:**
```csharp
var totals = payments
    .GroupBy(p => p.StudentId)
    .Select(g => new 
    { 
        StudentId = g.Key, 
        Total = g.Aggregate(0m, (sum, p) => sum + p.Amount) 
    });
```

**After:**
```csharp
var totals = payments.AggregateBy(
    keySelector: p => p.StudentId,
    seed: 0m,
    (sum, payment) => sum + payment.Amount
);
```

- [ ] Find all `GroupBy().Aggregate()` patterns
- [ ] Replace with `AggregateBy()`
- [ ] Test functionality
- [ ] Verify aggregation logic

#### Replace Select with Index when needed

**Before:**
```csharp
var indexed = students.Select((student, index) => new 
{ 
    Index = index, 
    Student = student 
});
```

**After:**
```csharp
var indexed = students.Index();
```

- [ ] Find all `Select((item, index) => ...)` patterns
- [ ] Replace with `Index()` where appropriate
- [ ] Test functionality

---

### Step 4: Refactor to Primary Constructors

#### Identify Candidates
- [ ] Classes with only constructor parameter assignments
- [ ] Simple DTOs
- [ ] Value objects
- [ ] Record types (already have primary constructors)

#### Refactor Example

**Before:**
```csharp
public class Student
{
    public int Id { get; }
    public string Name { get; }
    public string Email { get; }
    
    public Student(int id, string name, string email)
    {
        Id = id;
        Name = name;
        Email = email;
    }
}
```

**After:**
```csharp
public class Student(int id, string name, string email)
{
    public int Id { get; } = id;
    public string Name { get; } = name;
    public string Email { get; } = email;
}
```

- [ ] Refactor simple classes first
- [ ] Test each refactored class
- [ ] Update unit tests if needed
- [ ] Be careful with classes that have complex constructor logic

---

### Step 5: Update Collection Initializations

#### Replace with Collection Expressions

**Before:**
```csharp
var numbers = new int[] { 1, 2, 3, 4, 5 };
var names = new List<string> { "Alice", "Bob" };
```

**After:**
```csharp
int[] numbers = [1, 2, 3, 4, 5];
List<string> names = ["Alice", "Bob"];
```

- [ ] Find all array initializations
- [ ] Find all List initializations
- [ ] Replace with collection expressions
- [ ] Use spreading where appropriate: `[..existing, newItems]`
- [ ] Test functionality

---

### Step 6: Organize Web APIs with Route Groups

#### Refactor Minimal APIs

**Before:**
```csharp
app.MapGet("/api/students", () => "Get all students");
app.MapGet("/api/students/{id}", (int id) => $"Get student {id}");
app.MapPost("/api/students", () => "Create student");
```

**After:**
```csharp
var studentGroup = app.MapGroup("/api/students")
    .WithTags("Students")
    .WithOpenApi();

studentGroup.MapGet("/", () => "Get all students");
studentGroup.MapGet("/{id}", (int id) => $"Get student {id}");
studentGroup.MapPost("/", () => "Create student");
```

- [ ] Identify related endpoints
- [ ] Group them using `MapGroup()`
- [ ] Add tags for Swagger
- [ ] Test all endpoints
- [ ] Verify Swagger documentation

---

### Step 7: Update JSON Serialization

#### Configure System.Text.Json

```csharp
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    options.SerializerOptions.WriteIndented = true;
    options.SerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
});
```

- [ ] Review current JSON configuration
- [ ] Update to use new options
- [ ] Test serialization/deserialization
- [ ] Update custom converters if needed

---

### Step 8: Update Pattern Matching

#### Use Enhanced Pattern Matching

**Before:**
```csharp
if (status == EnrollmentStatus.Pending)
    return "Pending";
else if (status == EnrollmentStatus.Approved)
    return "Approved";
// ...
```

**After:**
```csharp
return status switch
{
    EnrollmentStatus.Pending => "Pending",
    EnrollmentStatus.Approved => "Approved",
    EnrollmentStatus.Rejected => "Rejected",
    _ => "Unknown"
};
```

- [ ] Find if-else chains checking enum/type
- [ ] Replace with switch expressions
- [ ] Test all branches

---

## Testing Checklist

### Unit Tests
- [ ] Run all existing unit tests
- [ ] Update tests for refactored code
- [ ] Add tests for new LINQ methods
- [ ] Test primary constructor classes
- [ ] Test collection expressions

### Integration Tests
- [ ] Test all API endpoints
- [ ] Test route groups
- [ ] Test JSON serialization
- [ ] Test error handling

### Performance Tests
- [ ] Compare CountBy vs GroupBy().Count() performance
- [ ] Compare AggregateBy vs GroupBy().Aggregate() performance
- [ ] Measure startup time improvements
- [ ] Check memory usage

---

## Post-Migration Checklist

### Code Quality
- [ ] Run code analysis tools
- [ ] Fix any warnings
- [ ] Update code documentation
- [ ] Review code with team

### Documentation
- [ ] Update README with .NET 9 requirements
- [ ] Document new features used
- [ ] Update API documentation
- [ ] Update deployment guides

### Deployment
- [ ] Update CI/CD pipelines
- [ ] Update Docker images
- [ ] Test deployment in staging
- [ ] Plan production deployment

---

## Common Issues and Solutions

### Issue 1: Primary Constructor Parameters Not Available

**Problem:** Trying to use primary constructor parameters in places where they're not available.

**Solution:** Primary constructor parameters are available in:
- Property initializers
- Field initializers
- Methods
- Not available in: nested types, static members (without instance)

### Issue 2: Collection Expressions Type Inference

**Problem:** Type inference issues with collection expressions.

**Solution:** Explicitly specify type when needed:
```csharp
List<int> numbers = [1, 2, 3]; // Explicit type
```

### Issue 3: Breaking Changes in LINQ

**Problem:** Some LINQ operations behave differently.

**Solution:** Review .NET 9 breaking changes document and test thoroughly.

---

## Rollback Plan

If issues arise:

1. **Revert Project Files**
   - Change `net9.0` back to `net8.0`
   - Revert package versions

2. **Revert Code Changes**
   - Use Git to revert specific commits
   - Or manually revert refactored code

3. **Test Rollback**
   - Verify application works with .NET 8
   - Fix any issues

---

## Benefits Summary

After migration, you should see:

- ✅ **Better Performance**: CountBy, AggregateBy are faster
- ✅ **Less Code**: Primary constructors reduce boilerplate
- ✅ **Better Organization**: Route groups improve API structure
- ✅ **Modern Syntax**: Collection expressions are cleaner
- ✅ **Better Documentation**: Enhanced OpenAPI support

---

## Resources

- [.NET 9 Migration Guide](https://learn.microsoft.com/dotnet/core/whats-new/dotnet-9)
- [Breaking Changes in .NET 9](https://learn.microsoft.com/dotnet/core/compatibility/9.0)
- [C# 13 Language Reference](https://learn.microsoft.com/dotnet/csharp/language-reference/)
- [ASP.NET Core 9 Migration](https://learn.microsoft.com/aspnet/core/migration/9.0)

---

## Notes

- Migrate incrementally, one feature at a time
- Test thoroughly after each change
- Keep backups before major refactoring
- Document decisions and changes
- Get team review before production deployment

