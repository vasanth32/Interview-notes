# C# Advanced Concepts - Interview Questions & Answers

## How to Use This File

This file is for interview preparation. Each topic starts with a simple explanation, then adds practical examples and deeper interview points.

### Study Order

1. Understand the concept in plain English.
2. Read the code example slowly.
3. Practice explaining the answer without looking.
4. Learn the deeper points for senior-level follow-up questions.

---

## 1. What are delegates in C#?

### Answer

A **delegate** is a type-safe reference to a method. It allows you to pass a method as a parameter, store it in a variable, and call it later.

Beginner-friendly meaning: a delegate is like a variable that holds a method instead of holding a number or string.

### Example

```csharp
public delegate int MathOperation(int a, int b);

public class Calculator
{
    public static int Add(int a, int b) => a + b;
    public static int Multiply(int a, int b) => a * b;
}

MathOperation operation = Calculator.Add;
Console.WriteLine(operation(10, 5)); // 15

operation = Calculator.Multiply;
Console.WriteLine(operation(10, 5)); // 50
```

### Why Delegates Are Useful

- They enable callback methods.
- They are the foundation of events.
- They help implement flexible behavior without hardcoding method calls.
- They support functional programming patterns in C#.

### Interview Deep Point

In modern C#, you often use built-in delegate types instead of creating custom delegates:

```csharp
Func<int, int, int> add = (a, b) => a + b;
Action<string> print = message => Console.WriteLine(message);
Predicate<int> isEven = number => number % 2 == 0;
```

### Easy Examples of `Func`, `Action`, and `Predicate`

#### `Func` - Takes input and returns a value

Use `Func` when your method or lambda returns something. It is not only for small calculations. Small calculations are just the easiest way to understand it.

In real API/backend code, `Func` is commonly used when you want to pass logic as a parameter, such as filtering, selecting data, mapping objects, building reusable helpers, or deciding behavior dynamically.

```csharp
Func<int, int, int> add = (firstNumber, secondNumber) => firstNumber + secondNumber;

int result = add(10, 20);

Console.WriteLine(result); // 30
```

Meaning:

```text
Func<int, int, int>
    |    |    |
    |    |    return type
    |    second input type
    first input type
```

So `Func<int, int, int>` means: take two `int` values and return one `int` value.

#### Real API Uses of `Func`

##### 1. Mapping entity to DTO

In APIs, we often fetch an entity from the database and return a DTO to the client. A `Func` can hold the mapping logic.

```csharp
public class Customer
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}

public class CustomerDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}

Func<Customer, CustomerDto> mapToDto = customer => new CustomerDto
{
    Id = customer.Id,
    Name = customer.Name
};

CustomerDto dto = mapToDto(customer);
```

Meaning:

```text
Func<Customer, CustomerDto>
     input     return
```

It takes a `Customer` object and returns a `CustomerDto` object.

##### 2. Filtering customers in an API

First understand the normal code without `Func`:

```csharp
// Example: GET /api/customers/premium
public List<Customer> GetPremiumCustomers(List<Customer> customers)
{
    List<Customer> premiumCustomers = customers
        .Where(customer => customer.IsPremium)
        .ToList();

    return premiumCustomers;
}
```

This line checks every customer:

```csharp
customer => customer.IsPremium
```

For each customer, it asks:

```text
Is this customer premium?
```

If the answer is `true`, the customer is added to the result. If the answer is `false`, the customer is skipped.

Now we can store that condition in a `Func` variable:

```csharp
Func<Customer, bool> isPremiumCustomer = customer => customer.IsPremium;

List<Customer> premiumCustomers = customers
    .Where(isPremiumCustomer)
    .ToList();
```

So this:

```csharp
Func<Customer, bool> isPremiumCustomer
```

means:

```text
Take one Customer as input.
Return true or false.
```

### Simple API Example

```csharp
// GET /api/customers/active
Func<Customer, bool> isActiveCustomer = customer => customer.IsActive;

List<Customer> activeCustomers = customers
    .Where(isActiveCustomer)
    .ToList();
```

### Beginner-Friendly Interview Answer

```text
Func<Customer, bool> is used when we pass a condition that checks a Customer
and returns true or false. In APIs, this can be used for filtering data,
such as active customers, premium customers, or customers from a city.
```

##### 3. Selecting what data the API should return

```csharp
public List<TResult> GetCustomerData<TResult>(
    List<Customer> customers,
    Func<Customer, TResult> selector)
{
    return customers.Select(selector).ToList();
}

List<string> names = GetCustomerData(customers, customer => customer.Name);
List<int> ids = GetCustomerData(customers, customer => customer.Id);
```

Here, the same method can return customer names, IDs, or any selected value.

##### 4. Retry or wrapper logic

Sometimes APIs use `Func<Task<T>>` to pass an async operation into a reusable helper.

```csharp
public async Task<T> ExecuteWithLoggingAsync<T>(Func<Task<T>> operation)
{
    Console.WriteLine("API operation started");

    T result = await operation();

    Console.WriteLine("API operation completed");

    return result;
}

CustomerDto customer = await ExecuteWithLoggingAsync(async () =>
{
    Customer entity = await customerRepository.GetByIdAsync(10);
    return mapToDto(entity);
});
```

This pattern is useful for logging, retry, caching, validation wrappers, and pipeline-style code.

### Important Interview Point About `Func`

Do not say `Func` is only used for calculations. A better answer is:

```text
Func is used when we want to pass behavior as data and that behavior returns a value.
In API development, it is useful for mapping, filtering, selecting data, reusable wrappers,
and dynamic business rules.
```

#### `Action` - Takes input but does not return a value

Use `Action` when you only want to perform an operation.

It is not only for printing messages. In API/backend code, `Action` is useful when you want to pass a step that performs work but does not need to return data. Common examples are logging, updating an object, applying configuration, or running a notification step.

```csharp
Action<string> printMessage = message => Console.WriteLine(message);

printMessage("Hello from Action");
```

`Action<string>` means: take one `string` input and return nothing.

It is similar to a `void` method, but it is not the same thing.

### Then why use `Action` instead of only `void`?

Use `void` when you are creating a normal method.

```csharp
public void PrintMessage(string message)
{
    Console.WriteLine(message);
}
```

Use `Action` when you want to pass a `void` method as a parameter to another method.

```csharp
public void RunAfterSavingCustomer(Action<string> afterSave)
{
    string customerName = "Asha";

    Console.WriteLine("Customer saved");

    afterSave(customerName);
}

RunAfterSavingCustomer(name => Console.WriteLine($"Email sent to {name}"));
```

In this example:

```text
void method = fixed behavior
Action      = behavior passed from outside
```

So the main reason to use `Action` is flexibility. The method `RunAfterSavingCustomer` does not decide what should happen after saving. The caller decides.

Another caller can pass different behavior:

```csharp
RunAfterSavingCustomer(name => Console.WriteLine($"Audit log added for {name}"));
```

### Simple Interview Answer

```text
void is used to define a method that does not return anything.
Action is used to store or pass a method/lambda that does not return anything.
We use Action when the behavior should come from outside, like logging, notification,
callback, or configuration logic.
```

#### Real API Uses of `Action`

##### 1. Logging or notification step

```csharp
public void ProcessOrder(string orderId, Action<string> notify)
{
    Console.WriteLine($"Processing order {orderId}");

    notify(orderId);
}

ProcessOrder("ORD-1001", id => Console.WriteLine($"Notification sent for {id}"));
```

Here, `Action<string>` means: take an order ID and perform some work, but do not return anything.

##### 2. Updating an API response object

```csharp
public class ApiResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
}

public ApiResponse CreateResponse(Action<ApiResponse> configureResponse)
{
    ApiResponse response = new();

    configureResponse(response);

    return response;
}

ApiResponse response = CreateResponse(apiResponse =>
{
    apiResponse.Success = true;
    apiResponse.Message = "Customer created successfully";
});
```

This is useful when a helper method creates an object, but the caller decides how to configure it.

##### 3. Applying setup logic

```csharp
public void ConfigureCustomer(Customer customer, Action<Customer> applyRules)
{
    applyRules(customer);
}

ConfigureCustomer(customer, currentCustomer =>
{
    currentCustomer.Name = currentCustomer.Name.Trim();
    currentCustomer.Email = currentCustomer.Email.ToLower();
});
```

Here, `Action<Customer>` modifies or prepares the customer object without returning a separate value.

### Important Interview Point About `Action`

Do not say `Action` is only for printing. A better answer is:

```text
Action is used when we want to pass behavior as data, but that behavior does not return a value.
In API development, it is useful for logging, notification steps, object configuration,
and applying side-effect operations.
```

#### `Predicate` - Takes input and returns true or false

Use `Predicate` when you want to check a condition.

It is not only for checking if a number is even. In API/backend code, `Predicate` is useful for validation rules, filtering rules, authorization-style checks, and business conditions.

```csharp
Predicate<int> isEven = number => number % 2 == 0;

Console.WriteLine(isEven(10)); // True
Console.WriteLine(isEven(7));  // False
```

`Predicate<int>` means: take one `int` input and return a `bool`.

#### Real API Uses of `Predicate`

##### 1. Validation rule

```csharp
public class CreateCustomerRequest
{
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}

Predicate<CreateCustomerRequest> isValidCustomer = request =>
    !string.IsNullOrWhiteSpace(request.Name) &&
    request.Email.Contains('@');

if (!isValidCustomer(request))
{
    return BadRequest("Invalid customer request");
}
```

Here, `Predicate<CreateCustomerRequest>` means: take a request object and return `true` if it is valid, otherwise return `false`.

##### 2. Business filtering rule

```csharp
Predicate<Customer> isActivePremiumCustomer = customer =>
    customer.IsActive && customer.IsPremium;

List<Customer> activePremiumCustomers = customers
    .Where(customer => isActivePremiumCustomer(customer))
    .ToList();
```

This is useful when business conditions need clear names.

##### 3. Permission check

```csharp
Predicate<User> canAccessAdminReport = user =>
    user.IsActive && user.Role == "Admin";

if (!canAccessAdminReport(currentUser))
{
    return Forbid();
}
```

This makes the condition reusable and easier to explain.

### Important Interview Point About `Predicate`

Do not say `Predicate` is only for simple true/false examples. A better answer is:

```text
Predicate is used when we want to pass a condition as data.
In API development, it is useful for validation, filtering, permission checks,
and business rules that return true or false.
```

### Simple Interview Summary

| Delegate Type | Return Type     | Easy Meaning                        | Example Use                                      |
| ------------- | --------------- | ----------------------------------- | ------------------------------------------------ |
| `Func`        | Returns a value | Pass logic that gives back a result | Mapping entity to DTO, filtering, selecting data |
| `Action`      | Returns nothing | Pass logic that performs work       | Logging, notification, object configuration      |
| `Predicate`   | Returns `bool`  | Pass a true/false condition         | Validation, filtering, permission checks         |

---

## 2. What are events in C#?

### Answer

An **event** is a notification mechanism. One class publishes an event, and other classes subscribe to it.

Beginner-friendly meaning: an event says, "something happened," and interested classes can react.

### Example

```csharp
public class OrderService
{
    public event Action<string>? OrderPlaced;

    public void PlaceOrder(string orderId)
    {
        Console.WriteLine($"Order {orderId} placed.");
        OrderPlaced?.Invoke(orderId);
    }
}

public class EmailService
{
    public void SendConfirmation(string orderId)
    {
        Console.WriteLine($"Email sent for order {orderId}.");
    }
}

var orderService = new OrderService();
var emailService = new EmailService();

orderService.OrderPlaced += emailService.SendConfirmation;
orderService.PlaceOrder("ORD-1001");
```

### Delegate vs Event

| Delegate                                                     | Event                                         |
| ------------------------------------------------------------ | --------------------------------------------- |
| Can be invoked directly by external code if exposed publicly | Can only be raised inside the declaring class |
| Represents a method reference                                | Represents a notification                     |
| More general purpose                                         | Used for publisher-subscriber pattern         |

### Interview Deep Point

Events protect the publisher. Subscribers can add or remove handlers, but they cannot directly raise the event.

---

## 3. What is the difference between `IEnumerable`, `ICollection`, and `IList`?

### Answer

These interfaces represent different levels of collection functionality.

| Interface        | Meaning                                          | Supports                        |
| ---------------- | ------------------------------------------------ | ------------------------------- |
| `IEnumerable<T>` | Read one item at a time                          | Iteration only                  |
| `ICollection<T>` | A collection with count and modification methods | Add, remove, count              |
| `IList<T>`       | A collection with index access                   | Add, remove, index-based access |

### Example

```csharp
IEnumerable<string> names = new List<string> { "Asha", "Ravi", "John" };

foreach (string name in names)
{
    Console.WriteLine(name);
}
```

With `IEnumerable<T>`, you can loop through values, but you cannot directly add or remove items unless you convert or cast to a collection type.

### Beginner-Friendly Example

Think of these interfaces as giving the caller different levels of permission.

```csharp
public class StudentService
{
    private readonly List<string> _students = new()
    {
        "Asha",
        "Ravi",
        "John"
    };

    // 1. Use IEnumerable<T> when the caller only needs to read one by one.
    public IEnumerable<string> GetStudents()
    {
        return _students;
    }

    // 2. Use ICollection<T> when add, remove, or count matters.
    public ICollection<string> GetStudentCollection()
    {
        return _students;
    }

    // 3. Use IList<T> when index access matters.
    public IList<string> GetStudentList()
    {
        return _students;
    }
}

var service = new StudentService();

IEnumerable<string> readableStudents = service.GetStudents();

foreach (string student in readableStudents)
{
    Console.WriteLine(student);
}

// readableStudents.Add("Meena");     // Not allowed: IEnumerable<T> does not expose Add.
// readableStudents.Count;             // Not available as a property on IEnumerable<T>.
// readableStudents[0];                // Not allowed: IEnumerable<T> has no index access.

ICollection<string> editableStudents = service.GetStudentCollection();

editableStudents.Add("Meena");
editableStudents.Remove("John");
Console.WriteLine(editableStudents.Count);

// editableStudents[0];                // Not allowed: ICollection<T> has no index access.

IList<string> indexedStudents = service.GetStudentList();

Console.WriteLine(indexedStudents[0]); // Allowed: IList<T> supports index access.
indexedStudents[1] = "Ravi Kumar";     // Allowed: replace item at a specific index.
indexedStudents.Add("Sara");          // Also allowed because IList<T> includes collection operations.
```

### Simple Rule

| Need from caller's side            | Better return/use type |
| ---------------------------------- | ---------------------- |
| Only loop through the data         | `IEnumerable<T>`       |
| Add, remove, or check `Count`      | `ICollection<T>`       |
| Access or update by position/index | `IList<T>`             |

Example decision:

- If a controller only returns products to display, return `IEnumerable<Product>`.
- If a method builds a cart by adding/removing products, use `ICollection<Product>`.
- If a method must read `products[0]` or update `products[2]`, use `IList<Product>`.

### Interview Deep Point

Use the smallest interface that matches your need:

- Return `IEnumerable<T>` when callers only need to read data.
- Use `ICollection<T>` when add/remove/count operations matter.
- Use `IList<T>` when index access matters.

This improves abstraction and prevents unnecessary dependency on implementation details.

---

## 4. What is deferred execution in LINQ?

### Answer

**Deferred execution** means a LINQ query is not executed when it is created. It executes only when you enumerate it, such as with `foreach`, `ToList()`, `Count()`, or `First()`.

### Example

```csharp
List<int> numbers = new() { 1, 2, 3, 4, 5 };

var evenNumbers = numbers.Where(number => number % 2 == 0);

numbers.Add(6);

foreach (int number in evenNumbers)
{
    Console.WriteLine(number);
}
```

### Output

```text
2
4
6
```

The query includes `6` because it executes during the `foreach`, not when `evenNumbers` was defined.

### How to Execute Immediately

```csharp
var evenNumbers = numbers
    .Where(number => number % 2 == 0)
    .ToList();
```

### Beginner-Friendly Explanation

Think of deferred execution like writing a plan, but not doing the work yet.

```csharp
var query = numbers.Where(number => number % 2 == 0);
```

This line only says: "When somebody asks for the result, filter even numbers." It does not loop through the list immediately.

The work happens here:

```csharp
foreach (int number in query)
{
    Console.WriteLine(number);
}
```

or here:

```csharp
List<int> result = query.ToList();
```

### When to Use Deferred Execution

Use deferred execution when you are still building the query step by step.

```csharp
IQueryable<Product> query = dbContext.Products;

if (onlyActive)
{
    query = query.Where(product => product.IsActive);
}

if (!string.IsNullOrWhiteSpace(category))
{
    query = query.Where(product => product.Category == category);
}

List<Product> products = await query.ToListAsync();
```

This is a good use because Entity Framework sends one final SQL query to the database after all filters are added.

Use deferred execution when:

- You want to add filters conditionally.
- You want the latest data from the source when the query runs.
- You want Entity Framework to build one final database query.
- You may not need the result at all, so you avoid unnecessary work.

### When Not to Use Deferred Execution

Avoid leaving execution deferred when you need a fixed result now.

```csharp
var activeProducts = dbContext.Products
    .Where(product => product.IsActive);

foreach (Product product in activeProducts)
{
    Console.WriteLine(product.Name);
}

foreach (Product product in activeProducts)
{
    Console.WriteLine(product.Price);
}
```

This can hit the database twice because the query is executed each time it is enumerated.

Better:

```csharp
List<Product> activeProducts = await dbContext.Products
    .Where(product => product.IsActive)
    .ToListAsync();

foreach (Product product in activeProducts)
{
    Console.WriteLine(product.Name);
}

foreach (Product product in activeProducts)
{
    Console.WriteLine(product.Price);
}
```

Now the database is called once, and both loops use the in-memory list.

Avoid deferred execution when:

- You will loop over the same query multiple times.
- You need a snapshot of the data at this moment.
- The source collection may change before you use the result.
- You want errors to happen immediately, not later.
- You are returning data from a repository or service and do not want the caller to accidentally trigger database calls.

### Simple Rule

| Situation                         | Prefer                                      |
| --------------------------------- | ------------------------------------------- |
| Still building the query          | Deferred execution                          |
| Need the final result now         | `ToList()`, `ToArray()`, `First()`, `Any()` |
| Database query with async EF Core | `ToListAsync()`, `FirstOrDefaultAsync()`    |
| Same result used multiple times   | Materialize once into a `List<T>`           |

### Interview-Friendly Answer

Deferred execution is useful while composing LINQ queries because it delays work until the result is actually needed. For database calls, it is good when building an `IQueryable<T>` step by step, because EF Core can generate one final SQL query. But once I need the data, especially if I will use it multiple times or return it from a service, I materialize it with `ToListAsync()` or another terminal method to avoid repeated database calls and late surprises.

### Interview Deep Point

Deferred execution is powerful, but it can cause bugs when:

- The source collection changes before enumeration.
- The query hits a database multiple times.
- Exceptions are thrown later than expected.

Use `ToList()` or `ToArray()` when you need a snapshot.

---

## 5. What is the difference between `IEnumerable` and `IQueryable`?

### Answer

`IEnumerable<T>` is mainly for in-memory collections. `IQueryable<T>` is mainly for remote data sources like databases.

### Example

```csharp
IQueryable<Customer> query = dbContext.Customers
    .Where(customer => customer.City == "Chennai");

List<Customer> customers = await query.ToListAsync();
```

With Entity Framework Core, `IQueryable<T>` builds an expression tree that EF converts into SQL.

### Key Difference

| Feature        | `IEnumerable<T>`              | `IQueryable<T>`        |
| -------------- | ----------------------------- | ---------------------- |
| Execution      | In memory                     | Usually remote source  |
| Query logic    | Uses delegates                | Uses expression trees  |
| Example source | `List<T>`                     | EF Core `DbSet<T>`     |
| Filtering      | Happens in application memory | Can happen in database |

### Interview Deep Point

This code can be inefficient:

```csharp
IEnumerable<Customer> customers = dbContext.Customers.ToList();
var filtered = customers.Where(customer => customer.City == "Chennai");
```

The database returns all customers first, then filtering happens in memory. Prefer filtering before materializing:

```csharp
var filtered = await dbContext.Customers
    .Where(customer => customer.City == "Chennai")
    .ToListAsync();
```

---

## 6. What are generics in C#?

### Answer

**Generics** allow you to write reusable, type-safe code without using `object` everywhere.

### Example Without Generics

```csharp
public class Box
{
    public object Value { get; set; } = default!;
}

var box = new Box();
box.Value = "Hello";

string value = (string)box.Value;
```

This requires casting and can fail at runtime.

### Example With Generics

```csharp
public class Box<T>
{
    public T Value { get; set; }

    public Box(T value)
    {
        Value = value;
    }
}

var stringBox = new Box<string>("Hello");
string value = stringBox.Value;
```

### Interview Deep Point

Generics provide:

- Compile-time type safety.
- Better performance by avoiding boxing for value types.
- Reusable classes, methods, interfaces, and delegates.

### Generic Constraints

```csharp
public class Repository<T> where T : class
{
    public void Add(T entity)
    {
        Console.WriteLine($"Added {typeof(T).Name}");
    }
}
```

Common constraints:

| Constraint             | Meaning                                        |
| ---------------------- | ---------------------------------------------- |
| `where T : class`      | T must be a reference type                     |
| `where T : struct`     | T must be a value type                         |
| `where T : new()`      | T must have a public parameterless constructor |
| `where T : BaseClass`  | T must inherit from BaseClass                  |
| `where T : IInterface` | T must implement the interface                 |

---

## 7. What are covariance and contravariance?

### Answer

Covariance and contravariance describe how generic types behave with inheritance.

Simple meaning:

- **Covariance** lets you use a more derived type where a base type is expected.
- **Contravariance** lets you use a less derived type where a derived type is expected.

### Covariance Example

```csharp
IEnumerable<string> names = new List<string> { "Asha", "Ravi" };
IEnumerable<object> objects = names;
```

This works because `IEnumerable<out T>` is covariant. It only returns `T`; it does not accept `T` as input.

### Contravariance Example

```csharp
Action<object> printObject = value => Console.WriteLine(value);
Action<string> printString = printObject;

printString("Hello");
```

This works because `Action<in T>` is contravariant. It accepts `T` as input.

### Interview Deep Point

- `out` means the type is returned from members.
- `in` means the type is passed into members.
- Variance works for interfaces and delegates, not classes.

---

## 8. What is the difference between value types and reference types?

### Answer

Value types store the actual value. Reference types store a reference to an object.

| Feature     | Value Type                                       | Reference Type                                       |
| ----------- | ------------------------------------------------ | ---------------------------------------------------- |
| Examples    | `int`, `bool`, `DateTime`, `struct`              | `class`, `string`, arrays, delegates                 |
| Stored      | Usually on stack or inline inside another object | Object data on heap, reference variable points to it |
| Assignment  | Copies the value                                 | Copies the reference                                 |
| Can be null | Only if nullable, like `int?`                    | Yes, unless nullable reference types are enabled     |

### Example

```csharp
int first = 10;
int second = first;
second = 20;

Console.WriteLine(first);  // 10
Console.WriteLine(second); // 20
```

```csharp
public class Person
{
    public string Name { get; set; } = string.Empty;
}

Person first = new() { Name = "Asha" };
Person second = first;
second.Name = "Ravi";

Console.WriteLine(first.Name); // Ravi
```

### Interview Deep Point

Do not say "value types are always stored on stack and reference types are always stored on heap." That is an oversimplification. Storage depends on context, runtime optimization, fields, closures, boxing, and async state machines.

---

## 9. What is boxing and unboxing?

### Answer

**Boxing** converts a value type into an object. **Unboxing** converts the object back into a value type.

### Example

```csharp
int number = 100;
object boxed = number;       // Boxing
int unboxed = (int)boxed;    // Unboxing
```

### Why It Matters

Boxing creates an object on the heap and can hurt performance when it happens repeatedly.

### Example Problem

```csharp
ArrayList numbers = new ArrayList();
numbers.Add(10); // Boxing
numbers.Add(20); // Boxing

int first = (int)numbers[0]; // Unboxing
```

### Better Approach

```csharp
List<int> numbers = new() { 10, 20 };
int first = numbers[0];
```

### Interview Deep Point

Generics help avoid boxing for value types. That is one reason `List<int>` is better than old non-generic collections like `ArrayList`.

---

## 10. What is the difference between `Task`, `Thread`, and `ThreadPool`?

### Answer

| Concept      | Meaning                                                   |
| ------------ | --------------------------------------------------------- |
| `Thread`     | A low-level operating system thread                       |
| `ThreadPool` | A managed pool of reusable background threads             |
| `Task`       | A higher-level abstraction representing asynchronous work |

### Example Using Task

```csharp
Task<int> task = Task.Run(() =>
{
    return 10 + 20;
});

int result = await task;
```

### Interview Deep Point

Use `Task` and `async/await` for most modern C# asynchronous code. Directly creating `Thread` is rare and usually only needed for special long-running or low-level scenarios.

### Important Clarification

`async` does not always mean a new thread is created. For I/O operations like database calls or HTTP calls, the thread is released while waiting.

---

## 11. What is the difference between CPU-bound and I/O-bound work?

### Answer

**CPU-bound work** needs processor time. **I/O-bound work** waits for external resources like database, file system, network, or API calls.

### CPU-Bound Example

```csharp
int result = await Task.Run(() => CalculateLargeReport());
```

Use `Task.Run` when you want to move CPU-heavy work to a background thread.

### I/O-Bound Example

```csharp
Customer customer = await dbContext.Customers
    .FirstAsync(customer => customer.Id == customerId);
```

Do not wrap naturally async I/O calls inside `Task.Run`.

### Interview Deep Point

For ASP.NET Core applications, using `Task.Run` around database or HTTP calls is usually a mistake. It wastes ThreadPool threads and can reduce scalability.

---

## 12. What is a deadlock in async code?

### Answer

A deadlock can happen when code blocks on an async operation using `.Result` or `.Wait()` instead of using `await`.

### Problem Example

```csharp
public string GetCustomerName()
{
    return GetCustomerNameAsync().Result;
}

public async Task<string> GetCustomerNameAsync()
{
    await Task.Delay(1000);
    return "Asha";
}
```

### Better Approach

```csharp
public async Task<string> GetCustomerNameAsync()
{
    await Task.Delay(1000);
    return "Asha";
}
```

Callers should also use `await`:

```csharp
string name = await GetCustomerNameAsync();
```

### Interview Deep Point

The common rule is: async all the way. Avoid mixing blocking calls with asynchronous code.

---

## 13. What is `ConfigureAwait(false)`?

### Answer

`ConfigureAwait(false)` tells the runtime that after an awaited operation completes, it does not need to resume on the original synchronization context.

### Example

```csharp
public async Task<string> GetDataAsync()
{
    HttpResponseMessage response = await httpClient
        .GetAsync("https://example.com")
        .ConfigureAwait(false);

    return await response.Content
        .ReadAsStringAsync()
        .ConfigureAwait(false);
}
```

### Interview Deep Point

- In UI apps, resuming on the UI context may be necessary to update controls.
- In library code, `ConfigureAwait(false)` is commonly used to avoid unnecessary context capture.
- In ASP.NET Core, there is generally no classic synchronization context, so it is less critical than in older ASP.NET or UI apps.

---

## 14. What is cancellation in async programming?

### Answer

Cancellation allows a caller to request that an operation stop early.

### Example

```csharp
public async Task<Order?> GetOrderAsync(
    int orderId,
    CancellationToken cancellationToken)
{
    return await dbContext.Orders
        .FirstOrDefaultAsync(order => order.Id == orderId, cancellationToken);
}
```

### Usage

```csharp
using CancellationTokenSource cts = new();
cts.CancelAfter(TimeSpan.FromSeconds(5));

Order? order = await orderService.GetOrderAsync(1001, cts.Token);
```

### Interview Deep Point

Cancellation is cooperative. Passing a token does not forcefully kill the operation. The called method must observe the token and stop appropriately.

---

## 15. What is the garbage collector in .NET?

### Answer

The **Garbage Collector**, or **GC**, automatically manages memory by removing objects that are no longer reachable.

### How GC Works

1. It finds objects still reachable by the application.
2. It marks unreachable objects as garbage.
3. It reclaims memory.
4. It may compact memory to reduce fragmentation.

### Generations

| Generation        | Meaning                                     |
| ----------------- | ------------------------------------------- |
| Gen 0             | Short-lived objects                         |
| Gen 1             | Objects that survived one collection        |
| Gen 2             | Long-lived objects                          |
| Large Object Heap | Large objects, usually 85,000 bytes or more |

### Interview Deep Point

The GC manages managed memory. It does not automatically release unmanaged resources like file handles, database connections, sockets, or native handles. For those, use `IDisposable` and `using`.

---

## 16. What is `IDisposable` and the `using` statement?

### Answer

`IDisposable` is used to release unmanaged resources or managed objects that hold unmanaged resources.

### Example

```csharp
using StreamReader reader = new("data.txt");
string content = reader.ReadToEnd();
```

The `using` statement automatically calls `Dispose()` when the variable goes out of scope.

### Custom Example

```csharp
public class ReportWriter : IDisposable
{
    private readonly StreamWriter writer;

    public ReportWriter(string path)
    {
        writer = new StreamWriter(path);
    }

    public void Write(string message)
    {
        writer.WriteLine(message);
    }

    public void Dispose()
    {
        writer.Dispose();
    }
}
```

### Interview Deep Point

If your class owns disposable objects, it should usually implement `IDisposable` and dispose them. If it only receives dependencies through dependency injection, it usually should not dispose them manually because the DI container owns their lifetime.

---

## 17. What is reflection in C#?

### Answer

**Reflection** allows code to inspect metadata about assemblies, classes, methods, properties, and attributes at runtime.

### Example

```csharp
Type type = typeof(Customer);

foreach (PropertyInfo property in type.GetProperties())
{
    Console.WriteLine(property.Name);
}
```

### Use Cases

- Dependency injection containers.
- Serialization and deserialization.
- Object mapping.
- Testing frameworks.
- Attribute-based validation.

### Interview Deep Point

Reflection is powerful but slower than direct code. Use it carefully in performance-sensitive paths. Many frameworks use reflection during startup and cache the results.

---

## 18. What are attributes in C#?

### Answer

Attributes add metadata to code elements like classes, methods, properties, or parameters.

### Example

```csharp
[Obsolete("Use NewCalculateTotal instead.")]
public decimal CalculateTotal()
{
    return 0;
}
```

### ASP.NET Core Example

```csharp
[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    [HttpGet("{id}")]
    public IActionResult GetOrder(int id)
    {
        return Ok();
    }
}
```

### Interview Deep Point

Attributes do not usually execute behavior by themselves. Frameworks read attributes using reflection and then apply behavior based on that metadata.

---

## 19. What are expression trees?

### Answer

An **expression tree** represents code as data. Instead of compiling logic directly into executable instructions, C# can represent the logic as a tree structure that another system can inspect and translate.

### Example

```csharp
Expression<Func<Customer, bool>> expression = customer => customer.City == "Chennai";
```

Entity Framework Core can inspect this expression and convert it into SQL.

### Delegate vs Expression Tree

```csharp
Func<Customer, bool> predicate = customer => customer.City == "Chennai";
Expression<Func<Customer, bool>> expression = customer => customer.City == "Chennai";
```

| Type                               | Meaning                        |
| ---------------------------------- | ------------------------------ |
| `Func<Customer, bool>`             | Executable code                |
| `Expression<Func<Customer, bool>>` | Data structure describing code |

### Interview Deep Point

This is why some C# methods cannot be translated by EF Core. EF must understand the expression tree and convert it to SQL. If it cannot translate the expression, the query may fail or move evaluation to memory depending on the EF Core version and query shape.

---

## 20. What is the difference between `ref`, `out`, and `in` parameters?

### Answer

These keywords control how arguments are passed to methods.

| Keyword | Meaning                                                          |
| ------- | ---------------------------------------------------------------- |
| `ref`   | Pass by reference; value must be assigned before the call        |
| `out`   | Pass by reference; method must assign the value before returning |
| `in`    | Pass by readonly reference; method cannot modify it              |

### Examples

```csharp
public void Increase(ref int number)
{
    number++;
}

int value = 10;
Increase(ref value);
Console.WriteLine(value); // 11
```

```csharp
public bool TryParseAge(string input, out int age)
{
    return int.TryParse(input, out age);
}
```

```csharp
public decimal CalculateTax(in decimal amount)
{
    return amount * 0.18m;
}
```

### Interview Deep Point

Use these only when they improve clarity or performance. Overusing them can make APIs harder to understand.

---

## 21. What are records in C#?

### Answer

A **record** is a reference type or value type designed mainly for immutable data models and value-based equality.

### Example

```csharp
public record CustomerDto(int Id, string Name, string Email);

var first = new CustomerDto(1, "Asha", "asha@example.com");
var second = new CustomerDto(1, "Asha", "asha@example.com");

Console.WriteLine(first == second); // True
```

For classes, `==` usually checks reference equality unless overloaded. For records, equality is based on values.

### With Expression

```csharp
var updated = first with { Email = "new@example.com" };
```

### Interview Deep Point

Records are good for DTOs, configuration values, messages, and immutable data. They are not always ideal for entities with identity and lifecycle behavior, such as EF Core domain entities.

---

## 22. What is pattern matching in C#?

### Answer

Pattern matching checks whether a value has a certain shape, type, or condition and then extracts useful data.

### Example

```csharp
public decimal GetDiscount(Customer customer)
{
    return customer switch
    {
        { IsPremium: true, YearsActive: >= 5 } => 0.20m,
        { IsPremium: true } => 0.10m,
        { YearsActive: >= 3 } => 0.05m,
        _ => 0m
    };
}
```

### Type Pattern Example

```csharp
public string GetShapeName(object shape)
{
    return shape switch
    {
        Circle circle => $"Circle radius {circle.Radius}",
        Rectangle rectangle => $"Rectangle {rectangle.Width}x{rectangle.Height}",
        null => "No shape",
        _ => "Unknown shape"
    };
}
```

### Interview Deep Point

Pattern matching can reduce long `if` chains and make business rules easier to read. But very complex switch expressions can become hard to maintain, so keep rules clear.

---

## 23. What is `yield return`?

### Answer

`yield return` lets a method return values one at a time instead of building a full collection first.

### Example

```csharp
public IEnumerable<int> GetEvenNumbers(int max)
{
    for (int number = 1; number <= max; number++)
    {
        if (number % 2 == 0)
        {
            yield return number;
        }
    }
}
```

### Usage

```csharp
foreach (int number in GetEvenNumbers(10))
{
    Console.WriteLine(number);
}
```

### Interview Deep Point

`yield return` creates an iterator. It is lazy, meaning values are produced only when requested. This can save memory for large sequences.

---

## 24. What is `Span<T>`?

### Answer

`Span<T>` represents a contiguous region of memory. It allows efficient slicing and manipulation without copying data.

### Example

```csharp
int[] numbers = { 1, 2, 3, 4, 5 };
Span<int> middle = numbers.AsSpan(1, 3);

middle[0] = 20;

Console.WriteLine(numbers[1]); // 20
```

### Interview Deep Point

`Span<T>` is a `ref struct`, so it has safety restrictions:

- It cannot be stored on the heap.
- It cannot be used as a field in a normal class.
- It cannot cross async or iterator boundaries.

It is useful in high-performance code, parsing, buffers, and avoiding allocations.

---

## 25. What are extension methods?

### Answer

Extension methods allow you to add methods to an existing type without modifying the original type.

### Example

```csharp
public static class StringExtensions
{
    public static bool IsNullOrEmpty(this string? value)
    {
        return string.IsNullOrEmpty(value);
    }
}

string? name = null;
Console.WriteLine(name.IsNullOrEmpty()); // True
```

### Interview Deep Point

Extension methods are static methods called using instance method syntax. LINQ methods like `Where`, `Select`, and `OrderBy` are extension methods.

Use them to improve readability, but avoid hiding important business logic in too many scattered extension methods.

---

## 26. What is the difference between shallow copy and deep copy?

### Answer

A **shallow copy** copies the top-level object but keeps references to nested objects. A **deep copy** copies the object and its nested objects.

### Example

```csharp
public class Address
{
    public string City { get; set; } = string.Empty;
}

public class Employee
{
    public string Name { get; set; } = string.Empty;
    public Address Address { get; set; } = new();
}

Employee original = new()
{
    Name = "Asha",
    Address = new Address { City = "Chennai" }
};

Employee shallowCopy = new()
{
    Name = original.Name,
    Address = original.Address
};

shallowCopy.Address.City = "Bangalore";

Console.WriteLine(original.Address.City); // Bangalore
```

### Interview Deep Point

In a shallow copy, both objects share the same nested `Address`. In a deep copy, the nested `Address` would also be copied.

---

## 27. What is dependency injection in C#?

### Answer

Dependency Injection, or DI, is a design pattern where a class receives its dependencies from outside instead of creating them directly.

### Without DI

```csharp
public class OrderService
{
    private readonly EmailService emailService = new();
}
```

This tightly couples `OrderService` to `EmailService`.

### With DI

```csharp
public interface IEmailService
{
    Task SendAsync(string message);
}

public class OrderService
{
    private readonly IEmailService emailService;

    public OrderService(IEmailService emailService)
    {
        this.emailService = emailService;
    }
}
```

### Interview Deep Point

DI improves testability, maintainability, and separation of concerns. In ASP.NET Core, services are usually registered with lifetimes:

| Lifetime  | Meaning                           |
| --------- | --------------------------------- |
| Singleton | One instance for the application  |
| Scoped    | One instance per request          |
| Transient | New instance every time requested |

Be careful not to inject a scoped service into a singleton because it can cause lifetime issues.

---

## 28. What is the difference between `lock`, `Monitor`, `Mutex`, and `SemaphoreSlim`?

### Answer

These are synchronization tools used to protect shared resources.

| Tool            | Use Case                                         |
| --------------- | ------------------------------------------------ |
| `lock`          | Simple in-process mutual exclusion               |
| `Monitor`       | Lower-level API behind `lock` with more control  |
| `Mutex`         | Can synchronize across processes                 |
| `SemaphoreSlim` | Limits concurrent access, supports async waiting |

### Example With `lock`

```csharp
private readonly object syncRoot = new();
private int counter;

public void Increment()
{
    lock (syncRoot)
    {
        counter++;
    }
}
```

### Async-Friendly Example

```csharp
private readonly SemaphoreSlim semaphore = new(1, 1);

public async Task UpdateAsync()
{
    await semaphore.WaitAsync();
    try
    {
        await SaveChangesAsync();
    }
    finally
    {
        semaphore.Release();
    }
}
```

### Interview Deep Point

Do not use `await` inside a `lock` block. Use `SemaphoreSlim` for async coordination.

---

## 29. What is immutability and why is it useful?

### Answer

An immutable object cannot be changed after it is created.

### Example

```csharp
public class Money
{
    public decimal Amount { get; }
    public string Currency { get; }

    public Money(decimal amount, string currency)
    {
        Amount = amount;
        Currency = currency;
    }
}
```

### Benefits

- Easier to reason about.
- Safer in multi-threaded code.
- Reduces accidental side effects.
- Works well for value objects.

### Interview Deep Point

Records, `init` properties, readonly fields, and immutable collections can help create immutable models.

```csharp
public record Money(decimal Amount, string Currency);
```

---

## 30. What are nullable reference types?

### Answer

Nullable reference types help you express whether a reference can be null.

### Example

```csharp
public class Customer
{
    public string Name { get; set; } = string.Empty;
    public string? MiddleName { get; set; }
}
```

`Name` should not be null. `MiddleName` can be null.

### Interview Deep Point

Nullable reference types are compile-time warnings, not runtime guarantees. They help prevent `NullReferenceException`, but you still need validation for external input such as API requests, database values, and JSON payloads.

---

## Quick Revision Questions

1. Why are delegates type-safe?
2. Why can outside classes subscribe to an event but not raise it?
3. When should you use `IQueryable<T>` instead of `IEnumerable<T>`?
4. Why can deferred LINQ execution cause multiple database calls?
5. How do generics avoid boxing?
6. What does `out` mean in `IEnumerable<out T>`?
7. Why is `.Result` dangerous in async code?
8. Why should you avoid `Task.Run` for database calls in ASP.NET Core?
9. What does the garbage collector not clean up automatically?
10. Why should disposable dependencies from DI usually not be disposed manually?
11. How does EF Core use expression trees?
12. Why should you avoid `await` inside `lock`?
13. What makes a record different from a normal class?
14. Why is immutability useful in multi-threaded code?
15. What problem do nullable reference types help solve?

---

## Final Interview Tips

- Start with a simple definition.
- Give one real project example.
- Mention one common mistake.
- Explain performance or design impact if asked deeper.
- Prefer practical language over memorized definitions.

### Sample Answer Pattern

```text
Concept: What it is.
Use case: Where I used it or where it is useful.
Example: Small code or real scenario.
Deep point: Performance, design tradeoff, or common mistake.
```
