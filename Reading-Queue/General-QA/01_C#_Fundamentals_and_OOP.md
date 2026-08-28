# C# Fundamentals & Object-Oriented Programming - Interview Guide

## 1. Value Types vs Reference Types

### Value Types
- Stored on the **stack** (faster access)
- Directly contain their data
- Examples: `int`, `bool`, `char`, `struct`, `enum`
- Copying creates independent copies
- Default values: 0, false, null (for nullable)

```csharp
int a = 10;
int b = a;  // b gets a copy of a's value
b = 20;     // a is still 10
```

### Reference Types
- Stored on the **heap** (managed by GC)
- Store a reference (memory address) to the data
- Examples: `class`, `interface`, `delegate`, `array`, `string`
- Copying copies the reference, not the object
- Default value: `null`

```csharp
MyClass obj1 = new MyClass();
MyClass obj2 = obj1;  // Both point to same object
obj2.Value = 20;      // obj1.Value is also 20
```

### Interview Points
- **Boxing**: Converting value type to object (heap allocation)
- **Unboxing**: Converting object back to value type (explicit cast required)
- Performance: Value types are faster, but reference types are more flexible

---

## 2. Nullable Types

### Concept
- Value types cannot be `null` by default
- Use `?` suffix to make nullable: `int?`, `bool?`, `DateTime?`
- Underlying type: `Nullable<T>`

```csharp
int? age = null;  // Valid
int age2 = null;  // Compile error

// Null coalescing operator
int result = age ?? 0;  // If age is null, use 0
```

### Common Usage
- Database fields that can be null
- Optional parameters
- Null-conditional operator: `obj?.Property`

---

## 3. Generics

### Purpose
- Write reusable code that works with different types
- Type safety at compile time
- No boxing/unboxing overhead

```csharp
public class Repository<T> where T : class
{
    public void Add(T item) { }
    public T GetById(int id) { return default(T); }
}

// Usage
var userRepo = new Repository<User>();
var productRepo = new Repository<Product>();
```

### Constraints
- `where T : class` - Reference type
- `where T : struct` - Value type
- `where T : new()` - Has parameterless constructor
- `where T : BaseClass` - Inherits from BaseClass
- `where T : IInterface` - Implements interface

---

## 4. Delegates and Events

### Delegates
- Type-safe function pointers
- Can point to methods with matching signature

```csharp
public delegate void MyDelegate(string message);

MyDelegate del = new MyDelegate(MyMethod);
del("Hello");

// Multicast delegate
del += AnotherMethod;  // Can call multiple methods
```

### Events
- Special type of delegate with `event` keyword
- Encapsulation: only class can invoke, external can only subscribe

```csharp
public class Publisher
{
    public event EventHandler<EventArgs> SomethingHappened;
    
    protected virtual void OnSomethingHappened()
    {
        SomethingHappened?.Invoke(this, EventArgs.Empty);
    }
}
```

---

## 5. Lambda Expressions and LINQ

### Lambda Syntax
```csharp
// Expression lambda
Func<int, int> square = x => x * x;

// Statement lambda
Action<string> print = name => 
{
    Console.WriteLine($"Hello {name}");
};

// LINQ with lambda
var adults = people.Where(p => p.Age >= 18)
                   .OrderBy(p => p.Name)
                   .Select(p => p.Name);
```

### LINQ Methods (Common)
- `Where` - Filter
- `Select` - Transform
- `OrderBy/OrderByDescending` - Sort
- `First/FirstOrDefault` - Get first item
- `Any/All` - Check conditions
- `Count/Sum/Average` - Aggregations
- `GroupBy` - Group items
- `Join` - Combine collections

---

## 6. Async/Await

### Purpose
- Non-blocking asynchronous operations
- Improves application responsiveness
- Uses `Task` and `Task<T>` return types

```csharp
public async Task<string> GetDataAsync()
{
    await Task.Delay(1000);  // Simulate async work
    return "Data loaded";
}

// Calling async method
var data = await GetDataAsync();
```

### Key Points
- `async` method must return `Task`, `Task<T>`, or `void` (avoid void)
- `await` pauses execution until task completes
- Don't use `.Result` or `.Wait()` - causes deadlocks
- Use `ConfigureAwait(false)` in library code

---

## 7. Exception Handling

### Try-Catch-Finally
```csharp
try
{
    // Risky code
    int result = 10 / 0;
}
catch (DivideByZeroException ex)
{
    // Handle specific exception
    Logger.LogError(ex);
}
catch (Exception ex)
{
    // Handle any other exception
    Logger.LogError(ex);
}
finally
{
    // Always executes (cleanup code)
    connection.Close();
}
```

### Best Practices
- Catch specific exceptions first
- Don't catch exceptions you can't handle
- Use `throw;` to rethrow preserving stack trace
- Use `throw ex;` to throw new exception (loses stack trace)

---

## 8. Memory Management

### Garbage Collection (GC)
- Automatic memory management
- GC runs when memory pressure occurs
- Generations: Gen0 (new), Gen1, Gen2 (old)

### IDisposable Pattern
```csharp
public class Resource : IDisposable
{
    public void Dispose()
    {
        // Cleanup unmanaged resources
    }
}

// Using statement (automatic disposal)
using (var resource = new Resource())
{
    // Use resource
}  // Dispose called automatically
```

---

## 9. OOP Concepts

### Encapsulation
- Hide internal implementation
- Use `private` for internal, `public` for interface
- Properties with getters/setters

### Inheritance
- `class Child : Parent`
- `sealed` keyword prevents inheritance
- Single inheritance in C# (one base class)

### Polymorphism
- Same interface, different implementations
- `virtual` in base class, `override` in derived
- `new` keyword hides base method (not override)

### Abstraction
- `abstract` class: cannot instantiate, can have implementations
- `interface`: contract only, no implementation (until C# 8.0)

---

## 10. Abstract Classes vs Interfaces

### Abstract Class
- Can have fields, properties, methods (with or without implementation)
- Can have constructors
- Single inheritance
- Use when: Sharing common code among related classes

```csharp
public abstract class Animal
{
    public string Name { get; set; }
    public abstract void MakeSound();  // Must implement
    public virtual void Sleep() { }   // Optional override
}
```

### Interface
- Only method signatures (default implementations in C# 8.0+)
- No fields (properties allowed)
- Multiple inheritance
- Use when: Defining contracts for unrelated classes

```csharp
public interface IFlyable
{
    void Fly();
    int MaxAltitude { get; set; }
}
```

---

## 11. Design Patterns (Common)

### Singleton Pattern
```csharp
public class Singleton
{
    private static Singleton _instance;
    private static readonly object _lock = new object();
    
    private Singleton() { }
    
    public static Singleton Instance
    {
        get
        {
            if (_instance == null)
            {
                lock (_lock)
                {
                    if (_instance == null)
                        _instance = new Singleton();
                }
            }
            return _instance;
        }
    }
}
```

### Repository Pattern
- Abstraction layer between business logic and data access
- Makes code testable and maintainable

### Dependency Injection
- Inversion of Control (IoC)
- Dependencies provided from outside
- Constructor injection (preferred), property injection, method injection

---

## Interview Questions to Prepare

1. What's the difference between `==` and `.Equals()`?
2. Explain boxing and unboxing with examples.
3. When would you use `abstract class` vs `interface`?
4. What is the difference between `virtual`, `override`, and `new`?
5. Explain async/await. What happens under the hood?
6. What are the differences between `List<T>` and `IEnumerable<T>`?
7. Explain the `using` statement and IDisposable pattern.
8. What is a delegate? How is it different from an event?
9. Explain LINQ deferred execution.
10. What is the difference between `StringBuilder` and `string`?

