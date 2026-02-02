# .NET 9 & 10 Features - Quick Reference

A quick reference guide for all .NET 9 and .NET 10 features.

---

## LINQ Features

| Feature | Description | Use Case |
|---------|-------------|----------|
| **CountBy** | Count elements by key in single operation | Count students by grade, payments by status |
| **AggregateBy** | Group and aggregate in single operation | Sum payments by student, average scores by class |
| **Index** | Add index to each element | Process items with their position |
| **ChunkBy** | Group consecutive elements by key | Group consecutive status changes |

---

## Web API / REST API Features

| Feature | Description | Use Case |
|---------|-------------|----------|
| **Route Groups** | Organize related endpoints | Group student endpoints, payment endpoints |
| **Enhanced OpenAPI** | Better Swagger documentation | Auto-generate API docs |
| **JSON Serialization** | Improved System.Text.Json | Faster serialization, better options |
| **Native AOT** | Ahead-of-time compilation | Smaller, faster microservices |
| **Rate Limiting** | Built-in API rate limiting | Prevent abuse, protect resources |
| **Output Caching** | Response caching with tags | Cache API responses, reduce load |
| **Minimal APIs** | API without controllers | Simple endpoints, microservices |

---

## C# Language Features

| Feature | Description | Use Case |
|---------|-------------|----------|
| **Primary Constructors** | Constructor in class declaration | Reduce boilerplate for DTOs |
| **Collection Expressions** | Unified syntax `[1, 2, 3]` | Consistent collection initialization |
| **Type Aliases** | Alias any type | Simplify complex types |
| **Pattern Matching** | Enhanced switch expressions | Cleaner conditional logic |

---

## Performance Features

| Feature | Description | Benefit |
|---------|-------------|---------|
| **JIT Improvements** | Better just-in-time compilation | Faster startup, better runtime |
| **GC Enhancements** | Improved garbage collection | Lower memory, reduced pauses |
| **SIMD Support** | Vector processing | Faster math operations |

---

## Entity Framework Core

| Feature | Description | Use Case |
|---------|-------------|----------|
| **JSON Columns** | Store and query JSON | Flexible data structures |
| **Complex Types** | Value objects support | Better domain modeling |
| **Bulk Operations** | Efficient bulk insert/update | Data migration, imports |

---

## Dependency Injection

| Feature | Description | Use Case |
|---------|-------------|----------|
| **Keyed Services** | Register services with keys | Multiple implementations |
| **Scoped Keyed** | Scoped lifetime for keyed | Per-request implementations |

---

## Background Processing

| Feature | Description | Use Case |
|---------|-------------|----------|
| **Background Services** | Enhanced hosted services | Long-running tasks |
| **Scheduled Tasks** | Cron-like scheduling | Daily reminders, reports |

---

## Monitoring & Observability

| Feature | Description | Use Case |
|---------|-------------|----------|
| **Health Checks** | Comprehensive health monitoring | Service availability |
| **Structured Logging** | Better logging support | Log analysis, debugging |
| **Enhanced Metrics** | Better metrics support | Performance monitoring |

---

## Security Features

| Feature | Description | Use Case |
|---------|-------------|----------|
| **Enhanced Identity** | Better ASP.NET Core Identity | User authentication |
| **Policy Authorization** | Improved policy-based auth | Fine-grained permissions |
| **Rate Limiting** | API protection | Prevent abuse |

---

## Configuration & Options

| Feature | Description | Use Case |
|---------|-------------|----------|
| **Options Pattern** | Enhanced options support | Application configuration |
| **Configuration Sources** | More configuration sources | Flexible configuration |

---

## Serialization

| Feature | Description | Use Case |
|---------|-------------|----------|
| **System.Text.Json** | Improved JSON serialization | Faster, more features |
| **Source Generation** | Compile-time code generation | Better performance |
| **Type Support** | Better type support | DateOnly, TimeOnly, etc. |

---

## Blazor Features

| Feature | Description | Use Case |
|---------|-------------|----------|
| **Server-Side Rendering** | Enhanced SSR | Fast initial loads |
| **Streaming Rendering** | Progressive content | Long-running pages |

---

## SignalR & gRPC

| Feature | Description | Use Case |
|---------|-------------|----------|
| **SignalR Improvements** | Better connection management | Real-time apps |
| **gRPC Performance** | Faster gRPC | Microservices communication |

---

## Quick Comparison: Old vs New

### LINQ

**Old:**
```csharp
var counts = items.GroupBy(x => x.Key).Select(g => new { Key = g.Key, Count = g.Count() });
```

**New:**
```csharp
var counts = items.CountBy(x => x.Key);
```

### Constructors

**Old:**
```csharp
public class Student
{
    public int Id { get; }
    public Student(int id) { Id = id; }
}
```

**New:**
```csharp
public class Student(int id)
{
    public int Id { get; } = id;
}
```

### Collections

**Old:**
```csharp
var numbers = new int[] { 1, 2, 3 };
```

**New:**
```csharp
int[] numbers = [1, 2, 3];
```

### Rate Limiting

**Old:**
```csharp
// Required custom middleware or third-party library
```

**New:**
```csharp
builder.Services.AddRateLimiter(options => { /* config */ });
app.UseRateLimiter();
```

### Output Caching

**Old:**
```csharp
// Required custom middleware or third-party library
```

**New:**
```csharp
builder.Services.AddOutputCache();
app.UseOutputCache();
app.MapGet("/api/students", GetStudents).CacheOutput();
```

---

## Feature Priority for Migration

### High Priority (Immediate Benefits)
1. ✅ **CountBy/AggregateBy** - Performance improvement
2. ✅ **Rate Limiting** - Security and protection
3. ✅ **Output Caching** - Performance improvement
4. ✅ **Primary Constructors** - Code quality

### Medium Priority (Nice to Have)
5. ✅ **Route Groups** - Code organization
6. ✅ **Health Checks** - Observability
7. ✅ **Keyed Services** - DI flexibility
8. ✅ **Collection Expressions** - Code consistency

### Low Priority (When Needed)
9. ✅ **EF Core JSON Columns** - If using JSON
10. ✅ **Background Services** - If using background tasks
11. ✅ **Blazor Features** - If using Blazor

---

## Learning Resources

1. **Main Guide**: [.NET_9_10_Features_Guide.md](./.NET_9_10_Features_Guide.md)
2. **Additional Features**: [Additional_NET_9_10_Features.md](./Additional_NET_9_10_Features.md)
3. **POC Prompts**: [Cursor_AI_POC_Prompts.md](./Cursor_AI_POC_Prompts.md)
4. **Migration Guide**: [Migration_Checklist_NET8_to_NET9.md](./Migration_Checklist_NET8_to_NET9.md)

---

## Quick Start Commands

### Create New .NET 9 Project
```bash
dotnet new webapi -n MyApi -f net9.0
```

### Update Existing Project
```xml
<TargetFramework>net9.0</TargetFramework>
```

### Install Required Packages
```bash
dotnet add package Microsoft.AspNetCore.OpenApi
```

---

**Use this as a quick reference when deciding which features to implement!**

