# OOP Foundations in C#

> A beginner-friendly, practical guide for .NET developer interviews

## How to Use This Note

Read each topic in this order:

1. **Simple explanation**: understand the idea without technical words.
2. **Technical explanation**: learn how C# implements the idea.
3. **Example**: see the idea in code.
4. **Real application**: connect it to an actual .NET project.
5. **Problem it solves**: remember why the idea is useful.

Do not try to memorize every definition on the first reading. First understand the story: a class describes something, an object represents one real thing, and its methods protect and use its data.

## Quick Vocabulary

| Word          | Easy meaning                                            |
| ------------- | ------------------------------------------------------- |
| **Class**     | A design or blueprint for creating objects              |
| **Object**    | One real instance created from a class                  |
| **State**     | The values an object currently stores                   |
| **Behavior**  | The work an object can perform                          |
| **Member**    | A field, property, method, or constructor inside a type |
| **Instance**  | One particular object created from a class              |
| **Reference** | A variable that points to an object                     |
| **Assembly**  | A compiled .NET project, usually a `.dll` or `.exe`     |

### One-sentence summary

OOP keeps **data and the actions that use that data together**, so a large application is easier to understand and change.

## Learning Path

```text
Problem in the real world
        |
        v
Class (blueprint) -----> Object (one real instance)
        |                         |
        |                         +--> state: current data
        +------------------------>+--> behavior: operations
```

This chapter starts with everyday ideas, then connects them to C# and enterprise .NET applications.

---

## 1. What Is Object-Oriented Programming?

### Simple explanation

Object-Oriented Programming (OOP) is a way of organizing software around **objects**. Think of an object as a small worker that owns some information and knows how to perform related tasks.

An object combines:

- **State**: the data it currently holds.
- **Behavior**: the operations it can perform.
- **Identity**: the fact that it is a distinct instance.

A `Policy` object, for example, can remember a policy number and premium, and can check whether the policy is active.

### Technical explanation

In C#, a **class** describes the data and operations that an object will have. An **object** is the actual thing created while the program is running. Several objects can be created from one class.

The important design idea is responsibility: code that owns a piece of data should usually own the rules for changing that data. This is called **encapsulation**. Later chapters introduce abstraction and polymorphism, which help objects work together without exposing unnecessary details.

### Simple C# example

```csharp
public class Policy
{
    public string PolicyNumber { get; }
    public decimal Premium { get; private set; }

    public Policy(string policyNumber, decimal premium)
    {
        PolicyNumber = policyNumber;
        Premium = premium;
    }

    public void ApplyDiscount(decimal percentage)
    {
        Premium -= Premium * percentage / 100;
    }
}
```

### Enterprise example: insurance

In an insurance application, `Policy` could validate changes, calculate premiums, and protect business rules. An API endpoint should not directly change `Premium` to an invalid value; it should call a method that enforces the rule.

### Where it appears in .NET

- Domain entities and value objects in a domain layer.
- Request and response models in ASP.NET Core APIs.
- Services such as `PaymentService` or `ShipmentCalculator`.
- Entity Framework Core entities and configurations.
- Dependency-injected interfaces and implementations.

### Problem it solves

Without OOP, data and the rules for changing it can be scattered across many functions. OOP gives related data and rules a clear owner, which makes mistakes easier to prevent.

---

## 2. Why Was OOP Introduced?

### Simple explanation

Early programs were often written like a recipe: do step 1, then step 2, then step 3. That works for a small task. In a large business system, the recipe can become thousands of steps, and changing one step can unexpectedly affect many others.

OOP lets us group related information and work into understandable units, such as `Student`, `Invoice`, or `Shipment`.

### Technical explanation

Procedural programming organizes code mainly around functions. OOP adds types that group data with the functions that work on it. These groups create boundaries, reduce accidental dependencies, and make responsibilities clearer.

OOP did not replace procedural code. A C# class organizes a responsibility, and the methods inside it still use normal step-by-step procedural logic.

### Enterprise example: school management

A school system might contain students, courses, enrollments, invoices, and payments. Each concept has rules and relationships. A `Enrollment` object can enforce that a student cannot enroll twice, rather than leaving that rule duplicated across controllers, jobs, and scripts.

### Problem it solves

OOP gives a large team a shared way to divide work and manage change. It is not magic: a class can still become too large or too dependent on other classes, so good design still matters.

---

## 3. Problems with Procedural Programming That OOP Helps Solve

| Procedural problem               | OOP response                             | Enterprise benefit             |
| -------------------------------- | ---------------------------------------- | ------------------------------ |
| Data is globally accessible      | Encapsulation and private state          | Fewer invalid updates          |
| Logic is duplicated              | Reusable types and services              | One business rule to maintain  |
| Changes ripple through callers   | Interfaces and stable contracts          | Easier replacement and testing |
| Large conditional blocks grow    | Polymorphism or focused strategies       | New behavior with fewer edits  |
| Responsibilities are unclear     | Cohesive classes                         | Easier code ownership          |
| Shared mutable state causes bugs | Controlled mutation and immutable values | Safer concurrent workflows     |

Procedural code is still appropriate for small transformations, algorithms, and straightforward orchestration. Choose the simplest design that keeps responsibilities clear.

---

## 4. Class and Object

### Simple explanation

A **class** is a blueprint. An **object** is a real thing created from that blueprint.

```text
Class: Car
  - color
  - Start()

Objects:
  car1 = a red Car
  car2 = a blue Car
```

### Technical explanation

A class is a reference type declaration. It defines members and the rules for constructing and using instances. Each object created from the class has its own instance state, although all instances share the same method implementation. A variable of class type normally stores a reference to an object, not the complete object itself.

### C# example

```csharp
public class InventoryItem
{
    public string Sku { get; }
    public int Quantity { get; private set; }

    public InventoryItem(string sku, int quantity)
    {
        Sku = sku;
        Quantity = quantity;
    }

    public void AddStock(int amount) => Quantity += amount;
}

var keyboard = new InventoryItem("KB-100", 10);
var mouse = new InventoryItem("MS-200", 25);
keyboard.AddStock(5);
```

`keyboard` and `mouse` are two different objects. Changing one does not change the other.

### Real-world example

In inventory management, the class is the definition of an inventory item. Each object represents one SKU or stock record. A warehouse service can call `AddStock` after receiving goods.

### Where it appears in .NET

Classes are used for controllers, services, repositories, entities, DTOs, configuration options, middleware, and test doubles.

### Problem it solves

A class gives related data and operations a named, reusable boundary. Objects allow the application to represent many independent business records.

---

## 5. Fields, Properties, Methods, and Constructors

### Fields

A field is storage declared inside a type. It is often private implementation state.

```csharp
private readonly string accountId;
```

### Properties

A property provides controlled access to a value. It may validate, calculate, or restrict writes.

```csharp
public decimal Balance { get; private set; }
```

A property is not automatically a database column, and an auto-property still has compiler-generated backing storage.

### Methods

A method represents an operation or behavior.

```csharp
public void Deposit(decimal amount)
{
    if (amount <= 0) throw new ArgumentOutOfRangeException(nameof(amount));
    Balance += amount;
}
```

### Constructors

A constructor initializes a valid object. It runs when an instance is created and has the same name as the class.

```csharp
public BankAccount(string accountId)
{
    this.accountId = accountId;
}
```

### Enterprise example: payment

A `Payment` may have a private field for an internal id, a read-only property for its public id, methods such as `Authorize()` and `Capture()`, and a constructor that requires an order id and amount.

### Problem it solves

These members separate storage, controlled access, actions, and initialization. That makes the object easier to reason about and prevents callers from performing invalid transitions directly.

---

## 6. Object State and Behavior

### Simple explanation

State is what an object knows now. Behavior is what it can do.

```csharp
public class Shipment
{
    public string TrackingNumber { get; }
    public string Status { get; private set; } = "Created";

    public Shipment(string trackingNumber)
    {
        TrackingNumber = trackingNumber;
    }

    public void Dispatch()
    {
        if (Status != "Created")
            throw new InvalidOperationException("Only a new shipment can be dispatched.");

        Status = "Dispatched";
    }
}
```

The `Status` property is state. `Dispatch` is behavior and protects the valid state transition.

### Technical explanation

An object's state is the set of instance field values at a point in time. Behavior is implemented by methods, properties, and events that can read or change that state. Encapsulation means callers use the public contract rather than depending on internal representation.

### Real-world example: shipping

A shipment should not move from `Delivered` back to `Created` because a random caller assigned a string. A method or state model can enforce valid transitions.

### Where it appears in .NET

Stateful domain entities, workflow handlers, background-job state, and aggregate roots use this pattern. Stateless application services may instead receive state and return a result.

### Problem it solves

It keeps business transitions close to the state they govern and makes invalid operations visible and testable.

---

## 7. Instance Members vs Static Members

### Instance members

Instance members belong to one object. They can access that object's state.

### Static members

Static members belong to the type itself. They are accessed through the type name and do not require an object.

```csharp
public class Order
{
    public string Id { get; }
    public decimal Total { get; private set; }
    public static int CreatedCount { get; private set; }

    public Order(string id, decimal total)
    {
        Id = id;
        Total = total;
        CreatedCount++;
    }

    public void AddCharge(decimal amount) => Total += amount;
}

var first = new Order("ORD-1", 100m);
var second = new Order("ORD-2", 50m);
first.AddCharge(10m);                 // instance member
int count = Order.CreatedCount;       // static member
```

### Technical explanation

Every object has separate instance state. Static state is associated with the type and is shared within the relevant process and load context. Static members cannot directly access instance members because no particular object is implied.

### Enterprise example

A stateless `CurrencyConverter` method with fixed conversion metadata might be static, but application services are commonly instance classes so dependencies such as repositories and loggers can be injected. A mutable static cache can create concurrency, test-isolation, and multi-instance deployment problems.

### Problem it solves

Static members are useful for type-level facts and pure utilities. Instance members model per-request, per-customer, or per-record state. Choosing correctly avoids accidental global state.

---

## 8. C# Access Modifiers

Access modifiers define who can use a type or member.

| Modifier             | Accessible from                                        | Typical use                                                    |
| -------------------- | ------------------------------------------------------ | -------------------------------------------------------------- |
| `public`             | Any accessible caller                                  | API contract or reusable service                               |
| `private`            | Containing type only                                   | Internal state and helpers                                     |
| `protected`          | Containing type and derived types                      | Carefully designed extension points                            |
| `internal`           | Same assembly                                          | Application-layer implementation details                       |
| `protected internal` | Same assembly, or derived types in another assembly    | Framework/library extensibility when both forms are acceptable |
| `private protected`  | Containing type and derived types in the same assembly | Restricted inheritance hook                                    |

```csharp
public class BaseProcessor
{
    public string Name { get; set; } = "Processor";
    private int attempts;
    protected void RecordAttempt() => attempts++;
    internal void RunInternalStep() { }
    protected internal virtual void Extend() { }
    private protected void SameAssemblyExtension() { }
}

public class PaymentProcessor : BaseProcessor
{
    public void Process() => RecordAttempt();
}
```

### Important distinction

`protected internal` means **protected OR internal**. A derived class in another assembly can access it, and any code in the declaring assembly can access it.

`private protected` means **protected AND internal**. Only the declaring type and derived types in the same assembly can access it.

### Enterprise example

A web API may expose DTOs publicly, keep domain helpers private, expose application abstractions internally, and use `internal` to stop other assemblies from depending on implementation details.

### Problem it solves

Access control creates boundaries. It reduces accidental coupling and communicates which parts of a type are stable API versus implementation.

---

## 9. Memory-Level Understanding of Objects and References

Consider:

```csharp
public class Customer
{
    public string Name { get; set; } = "";
}

Customer first = new Customer { Name = "Asha" };
Customer second = first;
second.Name = "Ravi";
```

A simplified picture is:

```text
Stack / local variables              Managed heap
------------------------             -------------------
first  ----------------------------> Customer object
second ---------------------------->   Name = "Ravi"
```

### Simple explanation

`first` and `second` are two references pointing to the same object. Assigning `second = first` does not copy the customer. Changing through either reference changes the same object.

Think of a reference as an address written on a card. Copying the card gives you another card with the same address, not another house.

### Technical explanation

A variable whose type is a class normally contains a managed reference. `new Customer()` creates an object in memory and returns a reference to it. The .NET garbage collector later cleans up objects that the program can no longer reach.

The exact memory location can change because the runtime optimizes storage. The important interview point is this: assigning a class variable copies the reference, so two variables can point to the same object.

```csharp
Customer first = new() { Name = "Asha" };
Customer second = first;
Customer third = new() { Name = "Asha" };

bool sameReference = ReferenceEquals(first, second); // true
bool anotherObject = ReferenceEquals(first, third);  // false
```

A reference can also be `null`, meaning it points to no object:

```csharp
Customer? customer = null;
// customer.Name would throw NullReferenceException.
```

### Enterprise example

An ASP.NET Core request may resolve one tracked `Order` object from Entity Framework Core. Passing it to several application methods passes references to the same in-memory object. Unexpected mutation can therefore affect later logic in the same request.

### Problem it solves

Understanding references prevents accidental shared-state bugs, incorrect assumptions about copying, and null-reference failures.

### Common nuance

The garbage collector is not a manual `delete`. When no reachable references remain, the runtime may reclaim the object later. `IDisposable` is still needed for deterministic release of resources such as files, sockets, and database connections.

---

## 10. Reference Types vs Value Types in OOP

### Reference types

Classes, interfaces, delegates, arrays, and strings are reference types. A variable normally points to an object. Assigning the variable copies that pointer, so both variables can refer to the same object.

### Value types

Structs, enums, and numeric primitives are value types. The variable normally contains the value itself, so assignment makes a separate copy of that value.

```csharp
public class CustomerProfile
{
    public string Name { get; set; } = "";
}

public struct Money
{
    public decimal Amount { get; init; }
    public string Currency { get; init; }
}

var profile1 = new CustomerProfile { Name = "Asha" };
var profile2 = profile1;
profile2.Name = "Ravi"; // profile1.Name is also "Ravi"

var money1 = new Money { Amount = 10m, Currency = "USD" };
var money2 = money1;
money2 = money2 with { Amount = 20m };
// money1.Amount is still 10.
```

### Technical explanation

The key difference is **copy behavior**:

- Copying a class variable copies a reference to the same object.
- Copying a struct variable normally copies the value.
- Converting a value type to `object` is called **boxing**. C# creates an object wrapper for that value.

Do not memorize “classes are always on the heap and structs are always on the stack.” The runtime can store values in different places. For interviews, explain identity and copy behavior instead.

### Enterprise example

A small immutable `Money`, `DateRange`, or `Coordinates` struct can represent a value without identity. A customer, order, or shipment normally needs identity and is better modeled as a class.

### Problem it solves

Choosing value semantics for values and reference semantics for entities makes copying, equality, mutation, and ownership clearer.

---

## 11. What Happens When You Use `new`?

### Simple explanation

`new` asks C# to create a fresh object and gives you a reference to it. The constructor then fills in the object's required starting values.

```csharp
var payment = new Payment("PAY-1", 250m);
```

A simplified sequence is:

```text
1. C# identifies the class to create.
2. The runtime creates space for the object and gives fields default values.
3. Field initializers and base-class initialization run.
4. The constructor validates and sets the required values.
5. Your variable receives a reference to the ready object.
```

The object is not usable as a fully initialized object until construction completes. Constructor validation should reject invalid required input early.

```csharp
public class Payment
{
    public string Id { get; }
    public decimal Amount { get; }

    public Payment(string id, decimal amount)
    {
        if (string.IsNullOrWhiteSpace(id))
            throw new ArgumentException("An id is required.", nameof(id));
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        Id = id;
        Amount = amount;
    }
}
```

### Enterprise example

An order aggregate created from an API command can reject an empty customer id or negative total before it enters a repository or message queue.

### Problem it solves

Construction gives every object a reliable starting point. These rules are called **invariants**: conditions that must be true for a valid object, such as “a payment amount must be greater than zero.”

---

## 12. Constructors in C#

### Default constructor

A default constructor has no parameters. If you do not write any instance constructor, C# supplies a public parameterless one for a class. As soon as you write another instance constructor, C# stops supplying it automatically.

```csharp
public class AuditEntry
{
    public string Message { get; set; } = "";
}

var entry = new AuditEntry();
```

If a parameterless constructor is needed after adding another constructor, declare it explicitly.

### Parameterized constructor

A parameterized constructor receives values needed for a valid object. It is useful when an object should not exist without information such as an id or name.

```csharp
public class Student
{
    public int Id { get; }
    public string Name { get; }

    public Student(int id, string name)
    {
        Id = id;
        Name = name;
    }
}
```

### Constructor chaining

Sometimes a class has more than one way to create an object. Use `this(...)` to make one constructor call another constructor in the same class. Use `base(...)` to pass values to the parent class constructor.

```csharp
public class Product
{
    public string Sku { get; }
    public decimal Price { get; }

    public Product(string sku) : this(sku, 0m) { }

    public Product(string sku, decimal price)
    {
        Sku = sku;
        Price = price;
    }
}

public class DigitalProduct : Product
{
    public string DownloadUrl { get; }

    public DigitalProduct(string sku, decimal price, string downloadUrl)
        : base(sku, price)
    {
        DownloadUrl = downloadUrl;
    }
}
```

### Private constructor

A private constructor means code outside the class cannot call `new` directly. The class can expose a factory method, such as `FromEnvironment`, that controls and validates creation.

```csharp
public class ConnectionSettings
{
    private ConnectionSettings(string connectionString)
    {
        ConnectionString = connectionString;
    }

    public string ConnectionString { get; }

    public static ConnectionSettings FromEnvironment()
    {
        var value = Environment.GetEnvironmentVariable("APP_CONNECTION");
        if (string.IsNullOrWhiteSpace(value))
            throw new InvalidOperationException("Connection setting is missing.");

        return new ConnectionSettings(value);
    }
}
```

Avoid using a singleton merely because a private constructor makes it possible. In ASP.NET Core, dependency injection usually gives clearer lifetime and testing behavior.

### Static constructor

A static constructor prepares static data once, before the type is first used. It has no access modifier, no parameters, and you cannot call it yourself. The runtime calls it automatically.

```csharp
public class TaxTable
{
    private static readonly Dictionary<string, decimal> rates;

    static TaxTable()
    {
        rates = new Dictionary<string, decimal>
        {
            ["US"] = 0.07m,
            ["GB"] = 0.20m
        };
    }

    public static decimal GetRate(string country) => rates[country];
}
```

Use static initialization sparingly. Exceptions from a static constructor can make the type unusable for the lifetime of the application domain/load context. Prefer explicit, observable startup configuration for critical infrastructure.

### Enterprise example

- Parameterized constructors create valid `Order` and `Policy` entities.
- Chaining keeps multiple creation paths consistent.
- Private constructors support factory methods that parse or validate external input.
- Static constructors can initialize immutable lookup tables, though configuration and DI are often better for application services.

---

## 13. Common Beginner Mistakes

1. **Making every property public and settable**: callers can bypass business rules. Prefer private setters or methods where appropriate.
2. **Confusing a class with an object**: the class is the definition; the object is an instance.
3. **Assuming assignment copies a class object**: it copies the reference.
4. **Using static mutable state for shared application data**: this harms test isolation and can create race conditions.
5. **Treating inheritance as the default reuse mechanism**: prefer composition or interfaces when the relationship is not truly “is-a.”
6. **Writing an anemic domain model everywhere**: if an entity has important rules, place those rules near the state.
7. **Creating constructors with too many unrelated parameters**: use focused types, factories, or options where appropriate.
8. **Ignoring nullability**: enable nullable reference types and model optional values explicitly.
9. **Putting I/O in constructors**: constructors should establish state; database calls and network calls make creation hard to test and reason about.
10. **Overusing inheritance and access modifiers**: expose the smallest useful contract.
11. **Thinking OOP means one class per noun**: model responsibilities and behavior, not just vocabulary.
12. **Forgetting lifecycle ownership**: in .NET, let dependency injection manage disposable services and avoid manually creating dependencies inside every class.

---

# Interview Questions

## Beginner Questions

### 1. What is OOP?

**Expected answer:** OOP is a programming paradigm that models software as objects containing state and behavior. In C#, classes define the shape and behavior of objects, while objects are runtime instances.

**Detailed explanation:** OOP provides boundaries around data and operations. Encapsulation, abstraction, inheritance, and polymorphism are common OOP principles, but simply creating classes is not enough; the design should keep responsibilities cohesive.

**Common wrong answer:** “OOP means everything must be a class.”

**Follow-up:** When would a value type or a static method be a better choice than a class instance?

### 2. What is the difference between a class and an object?

**Expected answer:** A class is a type definition or blueprint. An object is an instance created from that type, usually with `new`.

**Detailed explanation:** Multiple objects can be created from one class, and each object normally has independent instance state.

**Common wrong answer:** “A class is stored in the heap and an object is stored on the stack.”

**Follow-up:** What does a variable of class type actually hold?

### 3. What are state and behavior?

**Expected answer:** State is an object's current data; behavior is the operations it exposes to read or change that data.

**Detailed explanation:** Encapsulated methods can enforce legal transitions instead of allowing arbitrary state changes.

**Common wrong answer:** “State means the class fields only, and behavior means only static methods.”

**Follow-up:** How would you prevent an order from being shipped twice?

### 4. What is a constructor?

**Expected answer:** A constructor runs during object creation and initializes the object, often validating required inputs and establishing invariants.

**Detailed explanation:** It has the class name, no return type, and can be overloaded. C# provides a default parameterless constructor only when no instance constructor is declared.

**Common wrong answer:** “A constructor is a method that returns the object.”

**Follow-up:** Explain `this(...)` and `base(...)` constructor chaining.

## Intermediate Questions

### 5. What is encapsulation, and how do you implement it in C#?

**Expected answer:** Encapsulation keeps implementation state protected and exposes controlled operations. C# supports it through access modifiers, properties, methods, and interfaces.

**Detailed explanation:** A `private set` or a method such as `Capture()` can prevent callers from creating invalid payment states.

**Common wrong answer:** “Encapsulation means making all fields private, even when no public behavior is needed.”

**Follow-up:** When would you expose an `IReadOnlyCollection<T>` instead of a mutable list?

### 6. What is the difference between instance and static members?

**Expected answer:** Instance members belong to an object and can use its state. Static members belong to the type and are shared or type-level; they do not require an instance.

**Detailed explanation:** Static mutable data behaves like process-level global state and should be carefully justified in a web application.

**Common wrong answer:** “Static means the value is constant.”

**Follow-up:** Why can a static method not directly access an instance property?

### 7. Explain reference types and value types.

**Expected answer:** Assignment of a reference type copies a reference to the same object. Assignment of a value type normally copies the value. Classes are reference types; structs and enums are value types.

**Detailed explanation:** Storage location is an implementation detail. The important language-level distinction is identity and copy semantics. Boxing can wrap a value type in an object.

**Common wrong answer:** “All classes are always on the heap and all structs are always on the stack.”

**Follow-up:** What happens when a struct is boxed?

### 8. What is the difference between `protected internal` and `private protected`?

**Expected answer:** `protected internal` is accessible from the same assembly or from derived types in another assembly. `private protected` is accessible from the containing type and derived types in the same assembly only.

**Detailed explanation:** The first combines access with OR semantics; the second combines it with AND semantics.

**Common wrong answer:** “They are aliases with different naming styles.”

**Follow-up:** Which modifier would you choose for a library extension point available only to derived types in the library?

## Tricky Questions

### 9. Does `Customer second = first` create a new object?

**Expected answer:** No. It copies the reference, so both variables point to the same object. Use a copy constructor, factory, or explicit mapping if an independent object is required.

**Detailed explanation:** `ReferenceEquals(first, second)` returns true after the assignment.

**Common wrong answer:** “Yes, because both variables have separate names.”

**Follow-up:** What is the difference between a shallow copy and a deep copy?

### 10. Can a static constructor be called directly?

**Expected answer:** No. The runtime invokes it automatically before the type is first used, subject to CLR initialization rules.

**Detailed explanation:** It has no access modifier and no parameters. It initializes static state once per relevant type initialization context.

**Common wrong answer:** “Call it with `TypeName.StaticConstructor()`.”

**Follow-up:** What can happen if a static constructor throws?

### 11. Is a property the same as a field?

**Expected answer:** No. A field is storage; a property is an accessor contract that may use compiler-generated storage or custom logic.

**Detailed explanation:** Properties support access control, validation, calculated values, and framework conventions. They do not automatically provide thread safety or validation.

**Common wrong answer:** “A property is just a public field with nicer syntax.”

**Follow-up:** Why might an ORM or serializer require a property with a setter?

### 12. Is OOP always better than procedural programming?

**Expected answer:** No. OOP is useful for modeling collaborating responsibilities and state, but procedural code can be clearer for small algorithms and transformations. Good C# combines both styles.

**Detailed explanation:** The goal is maintainable design, not maximizing the number of classes or abstractions.

**Common wrong answer:** “Yes, because procedural programming is obsolete.”

**Follow-up:** How would you decide between a class, a record, and a struct for a new domain concept?

---

# Coding Exercises

## Exercise 1: Create a Class and Objects

### Problem statement

Create an `InventoryItem` class with an SKU and quantity. Create two objects and add stock to one of them.

### Expected approach

Use a class with constructor initialization, a private setter for quantity, and a method for the valid stock operation.

### Complete solution

```csharp
public class InventoryItem
{
    public string Sku { get; }
    public int Quantity { get; private set; }

    public InventoryItem(string sku, int quantity)
    {
        if (string.IsNullOrWhiteSpace(sku))
            throw new ArgumentException("SKU is required.", nameof(sku));
        if (quantity < 0)
            throw new ArgumentOutOfRangeException(nameof(quantity));

        Sku = sku;
        Quantity = quantity;
    }

    public void AddStock(int amount)
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        Quantity += amount;
    }
}

var laptop = new InventoryItem("LAP-001", 5);
var monitor = new InventoryItem("MON-002", 10);
laptop.AddStock(3);
Console.WriteLine(laptop.Quantity); // 8
Console.WriteLine(monitor.Quantity); // 10
```

### Explanation

The constructor protects initial validity. `Quantity` cannot be assigned by arbitrary callers, and each object owns separate quantity state.

### Follow-up questions

- How would you prevent stock from going below zero?
- Would you use a struct for `InventoryItem`? Why or why not?
- How would an ASP.NET Core service persist the change?

## Exercise 2: Constructor Chaining

### Problem statement

Create a `Product` with a required SKU and an optional price. The one-argument constructor should reuse the two-argument constructor.

### Expected approach

Use `this(...)` to centralize initialization and validation.

### Complete solution

```csharp
public class Product
{
    public string Sku { get; }
    public decimal Price { get; }

    public Product(string sku) : this(sku, 0m)
    {
    }

    public Product(string sku, decimal price)
    {
        if (string.IsNullOrWhiteSpace(sku))
            throw new ArgumentException("SKU is required.", nameof(sku));
        if (price < 0)
            throw new ArgumentOutOfRangeException(nameof(price));

        Sku = sku;
        Price = price;
    }
}

var unknownPrice = new Product("BOOK-01");
var pricedProduct = new Product("BOOK-02", 19.99m);
```

### Explanation

The one-argument overload delegates to the main constructor. This avoids duplicated validation and keeps all instances consistently initialized.

### Follow-up questions

- What happens to the compiler-provided default constructor here?
- When would a factory method be clearer than many overloaded constructors?
- How could named options improve a constructor with many parameters?

## Exercise 3: Static vs Instance Members

### Problem statement

Track the number of `Order` objects created while allowing each order to calculate its own total.

### Expected approach

Use an instance property for the individual total and a static property for the type-level count.

### Complete solution

```csharp
public class Order
{
    public static int CreatedCount { get; private set; }
    public string Id { get; }
    public decimal Total { get; private set; }

    public Order(string id, decimal total)
    {
        Id = id;
        Total = total;
        CreatedCount++;
    }

    public void AddLine(decimal amount)
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        Total += amount;
    }
}

var first = new Order("ORD-1", 100m);
var second = new Order("ORD-2", 50m);
first.AddLine(25m);
Console.WriteLine(first.Total);       // 125
Console.WriteLine(second.Total);      // 50
Console.WriteLine(Order.CreatedCount); // 2
```

### Explanation

`Total` belongs to each order. `CreatedCount` belongs to the type and is shared. In production, a static counter is not a reliable distributed business metric because multiple application instances have separate process memory.

### Follow-up questions

- How would you track the count reliably across multiple servers?
- Is `CreatedCount++` thread-safe?
- How would dependency injection change this design?

## Exercise 4: Access Modifier Scenario

### Problem statement

Create a base `PaymentProcessor` that allows derived processors to log a protected operation, keeps internal implementation callable only in the assembly, and prevents external callers from changing the payment amount.

### Expected approach

Use a public read-only property, a private field, a protected method, and an internal method. Explain the tradeoffs of `protected` extension points.

### Complete solution

```csharp
public abstract class PaymentProcessor
{
    private readonly string processorName;

    protected PaymentProcessor(string processorName)
    {
        this.processorName = processorName;
    }

    public decimal Amount { get; private set; }

    public void SetAmount(decimal amount)
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        Amount = amount;
    }

    protected void LogProcessing()
    {
        Console.WriteLine($"{processorName} is processing {Amount}.");
    }

    internal void RunSettlementStep()
    {
        // Available to other code in this assembly only.
    }
}

public sealed class CardPaymentProcessor : PaymentProcessor
{
    public CardPaymentProcessor() : base("Card")
    {
    }

    public void Process()
    {
        LogProcessing();
    }
}
```

### Explanation

The public API exposes valid operations. The private field is implementation detail. `protected` allows a derived processor to use the logging hook, while `internal` limits a method to the current assembly.

### Follow-up questions

- Why might an interface be preferable to inheritance here?
- What is the difference between `protected internal` and `private protected`?
- How would you test the processor without performing a real payment?

---

# Final Revision Summary

## Core definitions

- OOP models collaborating objects with state, behavior, and identity.
- A class is a type definition; an object is an instance.
- Fields store implementation data; properties expose controlled access; methods perform behavior; constructors establish valid initial state.
- Instance members belong to objects; static members belong to the type.

## C# memory rules

- A class variable normally holds a reference to an object.
- Assigning one class variable to another copies the reference, not the object.
- Value-type assignment normally copies the value.
- Avoid the oversimplification that classes always live on the heap and structs always live on the stack.
- The garbage collector manages unreachable managed objects; `IDisposable` handles deterministic external-resource cleanup.

## Access modifiers

- `public`: broadly accessible contract.
- `private`: containing type only.
- `protected`: containing type and derived types.
- `internal`: same assembly.
- `protected internal`: same assembly OR derived type.
- `private protected`: same assembly AND derived type.

## Constructor rules

- The compiler adds a public parameterless constructor only when no instance constructor exists.
- Use `this(...)` to chain constructors in the same class.
- Use `base(...)` to initialize the base class.
- Use private constructors for controlled creation, not automatically for singleton designs.
- Static constructors initialize static state automatically and should remain lightweight and reliable.

## Interview-ready answer pattern

When answering an OOP question:

```text
1. Define it in one sentence.
2. Explain the C# mechanism.
3. Show a short example.
4. Connect it to a real enterprise feature.
5. Explain the problem and tradeoff it addresses.
```

The strongest answers discuss both benefits and limits. For example, encapsulation protects rules, but excessive abstraction can make a small feature harder to understand. OOP is a tool for managing responsibility and change, not a requirement to create a class for every line of code.
