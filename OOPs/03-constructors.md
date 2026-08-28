# Constructors in C#

> A beginner-friendly, practical guide for .NET developer interviews

## What Problem Does a Constructor Solve?

Imagine creating a new employee in a company system. An employee should not exist without an employee id and name. If we create the object first and fill in its values later, someone might forget a value or enter an invalid one.

A constructor solves this problem by giving an object a **safe starting point**.

```csharp
var employee = new Employee("E-100", "Asha");
```

After this line, the program has an `Employee` object with its required information already set.

A constructor helps us:

- Create an object.
- Set its starting values.
- Check that required values are valid.
- Prepare dependencies or other internal state.
- Prevent incomplete objects from being used.

Think of a constructor as the **setup process that runs when a new object is born**.

---

## 1. What Is a Constructor?

### Simple explanation

A constructor is a special block of code that runs when an object is created. Its main job is to prepare the new object for use.

A constructor:

- Has the same name as the class.
- Has no return type, not even `void`.
- Runs automatically when we use `new`.
- Can receive input values.
- Can be written more than once with different parameters.

### Small example

```csharp
public class Employee
{
    public string Name { get; }

    public Employee(string name)
    {
        Name = name;
    }
}
```

### Line-by-line explanation

- `public class Employee`: defines a class named `Employee`.
- `public string Name { get; }`: stores the employee's name and allows it to be read.
- `public Employee(string name)`: declares the constructor. It has the same name as the class and accepts a name.
- `Name = name;`: copies the constructor input into the object's property.
- The closing braces end the constructor and class.

### Using the constructor

```csharp
var employee = new Employee("Asha");
Console.WriteLine(employee.Name); // Asha
```

- `new Employee("Asha")`: creates an object and calls the constructor.
- The constructor stores `"Asha"` in `Name`.
- `employee`: holds a reference to the new object.
- `employee.Name`: reads the initialized value.

### Real project use

An ASP.NET Core application might create an `Employee` domain object from a command received by an API. The constructor can make sure the employee id and name are present before the object is saved to a database.

### Problem it solves

It prevents the application from creating an object that is missing required information.

---

## 2. When Is a Constructor Called?

### Simple explanation

A constructor is called when an object is created with `new`.

```csharp
var account = new BankAccount("BA-101", 500m);
```

The order is roughly:

```text
new BankAccount(...)
        |
        v
Create object space
        |
        v
Run initialization
        |
        v
Run BankAccount constructor
        |
        v
Return the ready object
```

### Small example

```csharp
public class BankAccount
{
    public string AccountNumber { get; }

    public BankAccount(string accountNumber)
    {
        Console.WriteLine("Constructor is running.");
        AccountNumber = accountNumber;
    }
}

var account = new BankAccount("BA-101");
Console.WriteLine(account.AccountNumber);
```

### Output

```text
Constructor is running.
BA-101
```

### Line-by-line explanation

- The class contains one property and one constructor.
- The `WriteLine` inside the constructor runs during object creation.
- `new BankAccount("BA-101")` calls the constructor automatically.
- The final line reads the value stored by the constructor.

### Important point

A constructor is normally called once for each object creation:

```csharp
var first = new Employee("Asha");
var second = new Employee("Ravi");
```

These two statements create two objects and call the constructor twice.

### Real project use

When an ASP.NET Core service is created by dependency injection, the service constructor is called by the DI container. The container supplies dependencies such as repositories and loggers.

### Problem it solves

It gives the object a predictable setup moment instead of requiring every caller to remember several separate initialization steps.

---

## 3. Why Is a Constructor Useful?

### Simple explanation

A constructor is useful because it creates a valid object immediately.

Without a constructor that validates input:

```csharp
var claim = new InsuranceClaim();
claim.ClaimNumber = "";
claim.Amount = -100;
```

The object exists, but its data does not make sense. This is an invalid object.

With a constructor:

```csharp
var claim = new InsuranceClaim("CLM-10", 1000m);
```

The class can reject invalid input before the claim is used.

### Small example

```csharp
public class InsuranceClaim
{
    public string ClaimNumber { get; }
    public decimal Amount { get; }

    public InsuranceClaim(string claimNumber, decimal amount)
    {
        if (string.IsNullOrWhiteSpace(claimNumber))
            throw new ArgumentException("Claim number is required.", nameof(claimNumber));

        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        ClaimNumber = claimNumber;
        Amount = amount;
    }
}
```

### Line-by-line explanation

- The two read-only properties contain the required claim data.
- The constructor receives the claim number and amount.
- `IsNullOrWhiteSpace` rejects a missing or blank claim number.
- `ArgumentException` explains that the caller supplied invalid text.
- `amount <= 0` rejects zero and negative amounts.
- `ArgumentOutOfRangeException` explains that the number is outside the allowed range.
- The final two assignments run only after validation succeeds.

### Real project use

An insurance service can create an `InsuranceClaim` from an API request. Invalid claims fail at the boundary instead of travelling through validation, payment, and reporting code.

### Problem it solves

It protects object rules, often called **invariants**. An invariant is something that must always be true, such as “an amount must be positive.”

---

## 4. Default Constructor

### Simple explanation

A default constructor is a constructor with no parameters. It creates an object without requiring input.

```csharp
public class Employee
{
    public string Name { get; set; } = "Unknown";
}

var employee = new Employee();
```

### What C# does automatically

If you do not write any instance constructor, C# supplies a public parameterless constructor for a class.

```csharp
public class Order
{
    public int Quantity { get; set; }
}

var order = new Order();
```

This works because the compiler supplies the constructor.

### Important rule

If you write any instance constructor, C# does not add the automatic one.

```csharp
public class Order
{
    public Order(int quantity)
    {
        Quantity = quantity;
    }

    public int Quantity { get; }
}

// var order = new Order(); // Compile error: no parameterless constructor.
var order = new Order(2);
```

If both forms are needed, write the default constructor yourself:

```csharp
public class Order
{
    public int Quantity { get; }

    public Order()
    {
        Quantity = 1;
    }

    public Order(int quantity)
    {
        Quantity = quantity;
    }
}
```

### Line-by-line explanation

- `Order()`: defines a parameterless constructor.
- `Quantity = 1`: gives a new order a default quantity.
- `Order(int quantity)`: defines another way to create the order.
- Each constructor sets the property so every object has a known starting value.

### Real project use

A parameterless constructor can be useful for serializers, object mappers, UI binding, or Entity Framework Core, depending on configuration. It is not always the best choice for a domain object that requires values.

### Problem it solves

It provides a simple creation path when sensible defaults exist. Do not add one if it allows invalid or incomplete objects.

---

## 5. Parameterized Constructor

### Simple explanation

A parameterized constructor requires information when the object is created.

```csharp
public class Employee
{
    public int Id { get; }
    public string Name { get; }

    public Employee(int id, string name)
    {
        Id = id;
        Name = name;
    }
}

var employee = new Employee(10, "Asha");
```

### Line-by-line explanation

- `Id` and `Name` describe the employee's required starting data.
- The constructor receives `id` and `name` from the caller.
- `Id = id` stores the numeric id in the object.
- `Name = name` stores the name in the object.
- `new Employee(10, "Asha")` supplies both required values.

### Improved version with validation

```csharp
public class Employee
{
    public int Id { get; }
    public string Name { get; }

    public Employee(int id, string name)
    {
        if (id <= 0)
            throw new ArgumentOutOfRangeException(nameof(id));
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name is required.", nameof(name));

        Id = id;
        Name = name;
    }
}
```

### Real project use

A school management application can require `StudentId` and `CourseId` when creating an `Enrollment`. This makes it harder to create an enrollment that cannot be connected to a student or course.

### Problem it solves

It makes required data visible at the call site and prevents callers from forgetting it.

---

## 6. Multiple Constructors

### Simple explanation

A class can offer more than one constructor when there are several sensible ways to create it.

```csharp
public class Order
{
    public string OrderNumber { get; }
    public decimal Total { get; }

    public Order(string orderNumber)
    {
        OrderNumber = orderNumber;
        Total = 0m;
    }

    public Order(string orderNumber, decimal total)
    {
        OrderNumber = orderNumber;
        Total = total;
    }
}
```

Now both calls are valid:

```csharp
var emptyOrder = new Order("ORD-1");
var existingOrder = new Order("ORD-2", 250m);
```

### Line-by-line explanation

- The class has two constructors with different parameter lists.
- The first creates a new order with a zero total.
- The second creates an order with an existing total.
- The caller chooses the constructor that matches the situation.

### Design warning

Multiple constructors are useful when each one has a clear meaning. Too many constructors can confuse callers. If a class needs ten optional settings, consider an options object or a factory method.

### Real project use

An order might be created as a new cart with no total, or rebuilt from stored data with an order number and total. These are different creation scenarios.

### Problem it solves

It supports legitimate creation scenarios while keeping required values explicit.

---

## 7. Constructor Overloading

### Simple explanation

Constructor overloading means creating multiple constructors in one class with different parameter lists.

The parameter list must differ by one or more of these:

- Number of parameters.
- Parameter types.
- Parameter order, when the types differ.

The return type is not used because constructors do not have return types.

### Example

```csharp
public class BankAccount
{
    public string AccountNumber { get; }
    public decimal Balance { get; }

    public BankAccount(string accountNumber)
        : this(accountNumber, 0m)
    {
    }

    public BankAccount(string accountNumber, decimal openingBalance)
    {
        if (string.IsNullOrWhiteSpace(accountNumber))
            throw new ArgumentException("Account number is required.", nameof(accountNumber));
        if (openingBalance < 0)
            throw new ArgumentOutOfRangeException(nameof(openingBalance));

        AccountNumber = accountNumber;
        Balance = openingBalance;
    }
}
```

### Line-by-line explanation

- The first constructor accepts only an account number.
- `: this(accountNumber, 0m)` calls the second constructor with a zero opening balance.
- The second constructor accepts both the account number and opening balance.
- Validation is written once in the main constructor.
- Both creation paths produce a valid `BankAccount`.

### Real project use

A bank account may be opened with no initial deposit or with an opening deposit. Both are meaningful business operations, so overloaded constructors can represent them.

### Problem it solves

It offers simple and detailed creation paths without duplicating initialization rules.

---

## 8. Constructor Chaining

### Simple explanation

Constructor chaining means one constructor calls another constructor. This prevents the same setup code from being copied into several constructors.

There are two common keywords:

- `this(...)`: call another constructor in the same class.
- `base(...)`: call a constructor in the parent class.

### Chaining with `this()`

```csharp
public class Order
{
    public string Number { get; }
    public string Status { get; }

    public Order(string number)
        : this(number, "New")
    {
    }

    public Order(string number, string status)
    {
        Number = number;
        Status = status;
    }
}
```

### Line-by-line explanation

- `Order(string number)`: is the shorter creation option.
- `: this(number, "New")`: calls the other constructor in the same class.
- The empty body is intentional because the other constructor does the setup.
- The two-parameter constructor receives both values and assigns the properties.
- An order created with only a number automatically starts with status `New`.

### Chaining with `base()`

```csharp
public class AuditedOrder : Order
{
    public string CreatedBy { get; }

    public AuditedOrder(string number, string createdBy)
        : base(number, "New")
    {
        CreatedBy = createdBy;
    }
}
```

### Line-by-line explanation

- `AuditedOrder : Order`: says the new class derives from `Order`.
- `CreatedBy`: stores information added by the child class.
- `base(number, "New")`: calls the two-parameter constructor in `Order`.
- The child constructor then sets `CreatedBy`.
- The parent initializes parent data; the child initializes child data.

### Real project use

An order base class may initialize common order information, while a specialized order class initializes channel-specific information such as marketplace or store data.

### Problem it solves

Chaining keeps initialization in one place and makes inheritance initialization predictable.

---

## 9. The `this()` Constructor

### Simple explanation

`this()` means “use another constructor from this same class.” It is not referring to the current object in this context; it is selecting another constructor.

```csharp
public class Employee
{
    public int Id { get; }
    public string Name { get; }
    public string Department { get; }

    public Employee(int id, string name)
        : this(id, name, "Unassigned")
    {
    }

    public Employee(int id, string name, string department)
    {
        Id = id;
        Name = name;
        Department = department;
    }
}
```

### What happens?

```csharp
var employee = new Employee(1, "Asha");
```

The two-argument constructor calls the three-argument constructor. The employee receives the default department `Unassigned`.

### Important rules

- A `this(...)` constructor initializer runs before the constructor body.
- The target constructor must be in the same class.
- Constructor chaining must eventually stop; circular chaining is a compile error.
- Use it to avoid duplicated validation and assignments.

### Real project use

When importing employees from an older system, the source may not contain a department. The shorter constructor can supply a safe default while the complete constructor remains the single place for validation.

### Problem it solves

It gives multiple creation options without having multiple copies of the same setup code.

---

## 10. The `base()` Constructor

### Simple explanation

`base()` means “call a constructor in the parent class.” A child object contains the parent part as well as its own part, so the parent must be initialized first.

```csharp
public class Employee
{
    public string Name { get; }

    public Employee(string name)
    {
        Name = name;
    }
}

public class Manager : Employee
{
    public int TeamSize { get; }

    public Manager(string name, int teamSize)
        : base(name)
    {
        TeamSize = teamSize;
    }
}
```

### Line-by-line explanation

- `Employee` is the parent class and requires a name.
- `Manager : Employee` means a manager is also an employee.
- The manager constructor receives both name and team size.
- `base(name)` passes the name to the parent constructor.
- The parent sets `Name`.
- The child then sets `TeamSize`.

### If `base()` is not written

If the parent has a public or protected parameterless constructor, C# may call it automatically. If the parent has only a parameterized constructor, the child must call it explicitly.

```csharp
public class Manager : Employee
{
    public Manager(string name, int teamSize)
        : base(name)
    {
        TeamSize = teamSize;
    }

    public int TeamSize { get; }
}
```

### Real project use

A specialized insurance claim, such as `VehicleClaim`, can call the base `InsuranceClaim` constructor for claim number and amount, then initialize vehicle-specific information.

### Problem it solves

It ensures parent state is initialized by the parent’s own rules instead of being copied or bypassed by the child.

---

## 11. Private Constructor

### Simple explanation

A private constructor can be called only from inside the class. It prevents other code from using `new` directly.

This is useful when the class wants to control how objects are created.

### Factory method example

```csharp
public class InsuranceClaim
{
    public string ClaimNumber { get; }
    public decimal Amount { get; }

    private InsuranceClaim(string claimNumber, decimal amount)
    {
        ClaimNumber = claimNumber;
        Amount = amount;
    }

    public static InsuranceClaim Create(string claimNumber, decimal amount)
    {
        if (string.IsNullOrWhiteSpace(claimNumber))
            throw new ArgumentException("Claim number is required.", nameof(claimNumber));
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        return new InsuranceClaim(claimNumber, amount);
    }
}

var claim = InsuranceClaim.Create("CLM-20", 500m);
// var invalid = new InsuranceClaim("CLM-20", 500m); // Compile error.
```

### Line-by-line explanation

- The private constructor is hidden from outside callers.
- `Create` is a public static factory method.
- The factory validates external input.
- The factory calls the private constructor only after validation succeeds.
- Callers use `InsuranceClaim.Create`, which clearly communicates controlled creation.

### Other uses

Private constructors are also used for:

- Static-only utility classes, although `static class` is usually clearer.
- Factory methods with meaningful names such as `FromDatabase` or `FromExternalRequest`.
- Types that need to guarantee a particular creation process.

Do not choose a private constructor automatically to create a singleton. In ASP.NET Core, dependency injection is usually clearer for managing service lifetimes.

### Real project use

A claim factory can normalize and validate data received from an insurer or partner system before creating a domain claim.

### Problem it solves

It stops callers from bypassing the rules required to create a valid object.

---

## 12. Static Constructor

### Simple explanation

A static constructor prepares information that belongs to the class itself, not to one particular object.

It:

- Has the same name as the class and the keyword `static`.
- Has no parameters.
- Has no access modifier.
- Runs automatically.
- Runs at most once for a type in an application context.
- Cannot be called directly.

### Example

```csharp
public class InsuranceRules
{
    public static decimal MinimumClaimAmount { get; }

    static InsuranceRules()
    {
        MinimumClaimAmount = 100m;
    }
}

Console.WriteLine(InsuranceRules.MinimumClaimAmount); // 100
```

### Line-by-line explanation

- `InsuranceRules` is a class for type-level rules.
- `MinimumClaimAmount` is static, so it belongs to the class rather than an object.
- `static InsuranceRules()` declares the static constructor.
- The static constructor sets the value once.
- Accessing the static property causes the type initialization to happen first.
- There is no `new InsuranceRules()` in this example.

### When does it run?

A static constructor runs automatically before the first use that requires type initialization, such as:

- Accessing a static field or property.
- Calling a static method.
- Creating the first instance, when static initialization is required.

The runtime controls the exact timing. Do not depend on a static constructor running at a particular line earlier than the first required use.

### Example with a static method

```csharp
public class CountryCodes
{
    private static readonly Dictionary<string, string> Codes;

    static CountryCodes()
    {
        Codes = new Dictionary<string, string>
        {
            ["United States"] = "US",
            ["India"] = "IN"
        };
    }

    public static string GetCode(string country)
    {
        return Codes[country];
    }
}

var code = CountryCodes.GetCode("India");
```

The dictionary is prepared automatically before `GetCode` uses it.

### Important caution

A static constructor should be small and reliable. If it throws an exception, the type may remain unusable for the lifetime of the application domain or load context.

For ASP.NET Core configuration, dependency injection and explicit startup configuration are often easier to test and observe than hidden static initialization.

### Real project use

A static constructor can prepare a fixed, immutable lookup table, such as country codes or claim categories. It is usually not the right place to open a database connection or call a remote service.

### Problem it solves

It provides one automatic initialization point for type-level data.

---

## 13. Constructor Execution Order in Inheritance

### Simple explanation

When a child object is created, the parent part must be ready before the child part. Therefore, constructors run from the top of the inheritance tree down to the most specific class.

```text
Create VehicleClaim
        |
        v
Base type static initialization, if required
        |
        v
InsuranceClaim instance initialization and constructor
        |
        v
VehicleClaim instance initialization and constructor
```

### Example

```csharp
public class InsuranceClaim
{
    public InsuranceClaim(string claimNumber)
    {
        Console.WriteLine("InsuranceClaim constructor");
    }
}

public class VehicleClaim : InsuranceClaim
{
    public VehicleClaim(string claimNumber, string registrationNumber)
        : base(claimNumber)
    {
        Console.WriteLine("VehicleClaim constructor");
    }
}

var claim = new VehicleClaim("CLM-30", "ABC-123");
```

### Output

```text
InsuranceClaim constructor
VehicleClaim constructor
```

### Line-by-line explanation

- `VehicleClaim` inherits from `InsuranceClaim`.
- Its constructor uses `base(claimNumber)` to call the parent constructor.
- The parent constructor prints first.
- Control returns to the child constructor.
- The child constructor prints second.

### More complete order

For a normal object creation, remember this simplified order:

1. Static initialization for base types, when required.
2. Static initialization for derived types, when required.
3. Instance fields and initializers for the base type.
4. Base constructor.
5. Instance fields and initializers for the derived type.
6. Derived constructor.

The exact details have runtime and language rules, but the interview-level rule is simple: **base construction completes before derived construction completes**.

### Real project use

A base `InsuranceClaim` can initialize common claim identity and status. A `VehicleClaim` can then initialize registration and vehicle details. The child can safely rely on the base state after `base(...)` returns.

### Problem it solves

It makes sure shared parent state is ready before child-specific code uses it.

---

# Common Interview Confusion

## Is a constructor a method?

**Short answer:** It looks similar to a method, but in C# a constructor is a separate kind of class member.

A constructor has a name, a body, parameters, and access modifiers like a method. However:

- It has no return type.
- It cannot be called like a normal method.
- It initializes an object instead of performing a normal operation.
- It is invoked through object creation or constructor chaining.

An interview-friendly answer is: “A constructor is a special member used to initialize an object. It resembles a method, but technically it is not a normal method because it has no return type and follows constructor-specific rules.”

## Can a constructor return a value?

No. A constructor has no return type and cannot return a value. The `new` expression produces the object reference after construction succeeds.

```csharp
var account = new BankAccount("BA-1");
```

The constructor initializes the account; `new` gives the caller the resulting object reference.

## Can constructors be overloaded?

Yes. A class can have several constructors as long as their parameter lists are different.

```csharp
public Employee() { }
public Employee(string name) { }
public Employee(int id, string name) { }
```

## Can constructors be overridden?

No. Constructors cannot be `virtual`, so they cannot be overridden. A derived class can define its own constructor and call a base constructor with `base(...)`.

Overriding applies to inherited instance methods and properties, not constructors.

## Can constructors be inherited?

No. Constructors belong to the class that declares them. A child class does not automatically inherit the parent's constructors.

A child constructor must explicitly call a suitable parent constructor, or C# tries to call an accessible parameterless parent constructor.

## What happens if no constructor is written?

For a class with no declared instance constructor, C# supplies a public parameterless constructor. If you declare at least one instance constructor, C# does not supply the automatic parameterless constructor.

A `struct` has different default-construction rules, and modern C# also supports explicit parameterless struct constructors. Do not apply class rules blindly to structs.

## When does a static constructor run?

It runs automatically before the type is first used in a way that requires initialization. It runs at most once for the relevant type initialization context and cannot be called directly.

Do not assume it runs when the assembly is loaded or at a specific line before first use. The runtime controls its exact timing.

---

# Common Mistakes

1. **Writing a return type on a constructor**: `public void Employee()` is a method, not a constructor.
2. **Using a different name from the class**: the constructor name must match the class name exactly.
3. **Assuming C# always creates a default constructor**: it does not create one after you declare another instance constructor.
4. **Duplicating validation in every overloaded constructor**: chain to one main constructor with `this(...)`.
5. **Forgetting `base(...)`**: a child must call a parameterized parent constructor explicitly.
6. **Trying to override a constructor**: constructors cannot be overridden.
7. **Calling a static constructor directly**: the runtime calls it automatically.
8. **Doing slow I/O in a constructor**: database and network work makes object creation slow and difficult to test.
9. **Putting too much business workflow in a constructor**: use services or factory methods for multi-step operations.
10. **Using a private constructor to force a singleton**: prefer dependency injection when managing an application service.
11. **Assuming a constructor makes an object immutable**: properties can still be changed unless their setters and methods prevent it.
12. **Ignoring constructor validation**: allowing invalid state often moves the failure to a less obvious place.
13. **Creating too many constructor parameters**: use a focused parameter object or options type when the list becomes difficult to read.
14. **Assuming constructors are called during deserialization in every framework**: serializers and ORMs have their own rules; check the framework behavior.
15. **Using mutable static state without considering threads and servers**: static state is shared within a process, not automatically across all application instances.

---

# Interview Questions

## Beginner Questions

### 1. What is a constructor?

**Expected answer:** A constructor is a special class member that runs when an object is created. It initializes the object's starting state, has the same name as the class, and has no return type.

**Explanation:** It is where required values can be assigned and validated.

**Common wrong answer:** “A constructor is a method that returns the object.”

**Follow-up:** What does the `new` keyword do around the constructor call?

### 2. When is a constructor called?

**Expected answer:** It is called automatically when an instance is created with `new`, or when another constructor chains to it with `this(...)` or `base(...)`.

**Explanation:** Each new object normally causes its instance constructor chain to run.

**Common wrong answer:** “It runs when the class is declared.”

**Follow-up:** When is a static constructor called?

### 3. Why do we use constructors?

**Expected answer:** To initialize objects, validate required input, and ensure the object starts in a valid state.

**Explanation:** This avoids incomplete objects and repeated setup code.

**Common wrong answer:** “Constructors are only needed to allocate memory.”

**Follow-up:** Where should a database call needed for a workflow normally go?

### 4. What is a parameterized constructor?

**Expected answer:** It is a constructor that accepts parameters needed to initialize an object.

**Explanation:** For example, an `Employee` constructor can require an id and name.

**Common wrong answer:** “A parameterized constructor is a static constructor with arguments.”

**Follow-up:** Can a class have both parameterless and parameterized constructors?

## Intermediate Questions

### 5. What happens if you do not write a constructor?

**Expected answer:** For a class, C# supplies a public parameterless constructor if no instance constructor is declared. Once you declare an instance constructor, the automatic one is no longer supplied.

**Explanation:** Add the parameterless constructor explicitly if a framework or caller needs it.

**Common wrong answer:** “C# always supplies a default constructor.”

**Follow-up:** Do structs follow exactly the same rules?

### 6. What is constructor overloading?

**Expected answer:** Defining multiple constructors in the same class with different parameter lists.

**Explanation:** The compiler chooses the matching constructor based on the arguments passed to `new`.

**Common wrong answer:** “Overloading means changing only the return type.”

**Follow-up:** Why can constructors not be overloaded only by return type?

### 7. What is constructor chaining?

**Expected answer:** It is when one constructor calls another constructor. `this(...)` calls a constructor in the same class; `base(...)` calls a parent constructor.

**Explanation:** Chaining keeps validation and initialization in one place.

**Common wrong answer:** “`this()` and `base()` both always call the parent class.”

**Follow-up:** Which constructor runs first in a parent-child relationship?

### 8. Why would you use a private constructor?

**Expected answer:** To stop outside code from creating objects directly and force creation through a factory method or another controlled path.

**Explanation:** This is useful when validation or a named creation operation should always happen first.

**Common wrong answer:** “Private constructors automatically create a singleton.”

**Follow-up:** How would you register a service lifetime in ASP.NET Core instead?

## Tricky Questions

### 9. Can constructors be overridden?

**Expected answer:** No. Constructors are not virtual and cannot be overridden. A derived class defines its own constructor and can call a base constructor.

**Explanation:** Overriding changes inherited behavior; constructors are responsible for each class's own initialization.

**Common wrong answer:** “Yes, add `override` before the constructor.”

**Follow-up:** Can a child class inherit a parent's constructor?

### 10. Can constructors be inherited?

**Expected answer:** No. Constructors are not inherited. The child must declare its own constructors and call a suitable parent constructor.

**Explanation:** The child may use `base(...)`, but that is a call, not inheritance of the constructor itself.

**Common wrong answer:** “All public parent constructors automatically appear on the child.”

**Follow-up:** What happens when the parent has no accessible parameterless constructor?

### 11. Is a constructor a method?

**Expected answer:** It is similar in syntax, but technically it is a separate member kind. It has no return type and initializes an object rather than acting like a normal method.

**Explanation:** This answer shows both practical understanding and language precision.

**Common wrong answer:** “Yes, it is exactly the same as a void method.”

**Follow-up:** Can a constructor be called through an object reference?

### 12. What is the difference between `this()` and `base()`?

**Expected answer:** `this(...)` calls another constructor in the same class. `base(...)` calls a constructor in the parent class.

**Explanation:** Both run before the constructor body and help centralize initialization.

**Common wrong answer:** “`this()` initializes fields and `base()` initializes methods.”

**Follow-up:** Which one would you use in an overloaded `Employee` constructor?

### 13. When does a static constructor run?

**Expected answer:** Automatically before the type is first used in a way that requires static initialization. It runs at most once for the relevant type initialization context and cannot be called directly.

**Explanation:** Use it for small type-level initialization, not hidden network or database workflows.

**Common wrong answer:** “It runs every time a new object is created.”

**Follow-up:** What happens if it throws an exception?

---

# Output Prediction Questions

For each question, predict the output before reading the answer.

## Question 1: Basic constructor order

```csharp
public class Employee
{
    public Employee()
    {
        Console.WriteLine("Employee created");
    }
}

var employee = new Employee();
Console.WriteLine("After new");
```

**Answer:**

```text
Employee created
After new
```

**Why:** The constructor runs as part of `new Employee()` before the next statement executes.

## Question 2: Two objects

```csharp
public class Order
{
    public Order()
    {
        Console.WriteLine("Order");
    }
}

var first = new Order();
var second = new Order();
```

**Answer:**

```text
Order
Order
```

**Why:** Each `new` expression creates a separate object and calls the instance constructor once.

## Question 3: `this()` chaining

```csharp
public class Employee
{
    public Employee() : this("Unknown")
    {
        Console.WriteLine("Parameterless body");
    }

    public Employee(string name)
    {
        Console.WriteLine($"Named body: {name}");
    }
}

var employee = new Employee();
```

**Answer:**

```text
Named body: Unknown
Parameterless body
```

**Why:** The target constructor runs first. Then control returns to the body of the constructor that used `this(...)`.

## Question 4: `base()` chaining

```csharp
public class Employee
{
    public Employee()
    {
        Console.WriteLine("Employee");
    }
}

public class Manager : Employee
{
    public Manager()
    {
        Console.WriteLine("Manager");
    }
}

var manager = new Manager();
```

**Answer:**

```text
Employee
Manager
```

**Why:** The base constructor runs before the derived constructor. C# inserts a call to the accessible parameterless base constructor when no initializer is written.

## Question 5: Static constructor

```csharp
public class BankAccount
{
    static BankAccount()
    {
        Console.WriteLine("Static");
    }

    public BankAccount()
    {
        Console.WriteLine("Instance");
    }
}

var first = new BankAccount();
var second = new BankAccount();
```

**Answer:**

```text
Static
Instance
Instance
```

**Why:** The static constructor runs once before the first instance constructor. The instance constructor runs once for each object.

## Question 6: Static access first

```csharp
public class InsuranceRules
{
    static InsuranceRules()
    {
        Console.WriteLine("Static rules");
    }

    public static int MinimumAmount => 100;
}

Console.WriteLine(InsuranceRules.MinimumAmount);
Console.WriteLine(InsuranceRules.MinimumAmount);
```

**Answer:**

```text
Static rules
100
100
```

**Why:** The static constructor runs once before the first static access. It does not run again for the second access.

## Question 7: Constructor does not return a value

```csharp
public class Order
{
    public Order()
    {
        Console.WriteLine("Created");
    }
}

Order order = new Order();
Console.WriteLine(order is Order);
```

**Answer:**

```text
Created
True
```

**Why:** `new` produces the object reference. The constructor itself does not return a value.

## Question 8: Private constructor

```csharp
public class Claim
{
    private Claim()
    {
    }
}

// var claim = new Claim();
```

**Answer:** The code does not compile because the constructor is private and cannot be called from outside `Claim`.

**Why:** A private constructor limits object creation to code inside the class.

---

# Coding Exercises

Try each problem yourself before looking at the solution.

## Exercise 1: Basic Employee Constructor

### Problem statement

Create an `Employee` class with `Id` and `Name`. Require both values through a constructor.

### Expected approach

Use read-only properties and a parameterized constructor.

### Complete solution

```csharp
public class Employee
{
    public int Id { get; }
    public string Name { get; }

    public Employee(int id, string name)
    {
        Id = id;
        Name = name;
    }
}

var employee = new Employee(1, "Asha");
```

### Explanation

The constructor forces callers to provide the two values when creating an employee.

### Follow-up questions

- How would you reject an id of zero?
- Why use `{ get; }` instead of `{ get; set; }`?
- How would Entity Framework Core materialize this entity?

## Exercise 2: Validated Bank Account

### Problem statement

Create a `BankAccount` that requires a non-empty account number and a non-negative opening balance.

### Expected approach

Validate both constructor parameters before assigning them.

### Complete solution

```csharp
public class BankAccount
{
    public string AccountNumber { get; }
    public decimal Balance { get; }

    public BankAccount(string accountNumber, decimal openingBalance)
    {
        if (string.IsNullOrWhiteSpace(accountNumber))
            throw new ArgumentException("Account number is required.", nameof(accountNumber));
        if (openingBalance < 0)
            throw new ArgumentOutOfRangeException(nameof(openingBalance));

        AccountNumber = accountNumber;
        Balance = openingBalance;
    }
}
```

### Explanation

No assignment occurs until validation succeeds, so every successfully created account has acceptable initial data.

### Follow-up questions

- How would you add `Deposit` behavior?
- Should the balance have a public setter?
- How would you handle money precision?

## Exercise 3: Default and Parameterized Constructors

### Problem statement

Create an `Order` with a default quantity of one and another constructor that accepts a quantity.

### Expected approach

Declare both constructors explicitly and validate the quantity.

### Complete solution

```csharp
public class Order
{
    public int Quantity { get; }

    public Order()
        : this(1)
    {
    }

    public Order(int quantity)
    {
        if (quantity <= 0)
            throw new ArgumentOutOfRangeException(nameof(quantity));

        Quantity = quantity;
    }
}
```

### Explanation

The parameterless constructor chains to the main constructor, so the positive-quantity rule exists in one place.

### Follow-up questions

- What would happen if you removed the parameterless constructor?
- Why is constructor chaining better than repeating `Quantity = 1` logic?
- Could an options object be useful here?

## Exercise 4: Constructor Overloading for Insurance Claims

### Problem statement

Allow a claim to be created with only a claim number or with a claim number and amount. Use zero as the initial amount for the first case.

### Expected approach

Overload the constructors and chain the shorter one to the complete one.

### Complete solution

```csharp
public class InsuranceClaim
{
    public string ClaimNumber { get; }
    public decimal Amount { get; }

    public InsuranceClaim(string claimNumber)
        : this(claimNumber, 0m)
    {
    }

    public InsuranceClaim(string claimNumber, decimal amount)
    {
        if (string.IsNullOrWhiteSpace(claimNumber))
            throw new ArgumentException("Claim number is required.", nameof(claimNumber));
        if (amount < 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        ClaimNumber = claimNumber;
        Amount = amount;
    }
}
```

### Explanation

Both constructors use the same validation and initialization path.

### Follow-up questions

- Is zero a valid claim amount in your domain?
- Would a factory method make the two creation scenarios clearer?
- How would you model a claim that is not yet assessed?

## Exercise 5: `this()` Constructor Chaining

### Problem statement

Create an employee with a default department of `Unassigned` when the caller provides only an id and name.

### Expected approach

Use a shorter constructor that calls a complete constructor with `this(...)`.

### Complete solution

```csharp
public class Employee
{
    public int Id { get; }
    public string Name { get; }
    public string Department { get; }

    public Employee(int id, string name)
        : this(id, name, "Unassigned")
    {
    }

    public Employee(int id, string name, string department)
    {
        Id = id;
        Name = name;
        Department = department;
    }
}
```

### Explanation

The two-argument constructor delegates to the three-argument constructor. The complete constructor owns the assignments.

### Follow-up questions

- Can `this(...)` appear after statements in the constructor body?
- What happens if constructors chain in a circle?
- How would you validate the department?

## Exercise 6: `base()` Constructor

### Problem statement

Create an `InsuranceClaim` base class and a `VehicleClaim` child class. Initialize common claim data in the base constructor and vehicle data in the child constructor.

### Expected approach

Use `base(...)` in the derived constructor.

### Complete solution

```csharp
public class InsuranceClaim
{
    public string ClaimNumber { get; }

    public InsuranceClaim(string claimNumber)
    {
        ClaimNumber = claimNumber;
    }
}

public class VehicleClaim : InsuranceClaim
{
    public string RegistrationNumber { get; }

    public VehicleClaim(string claimNumber, string registrationNumber)
        : base(claimNumber)
    {
        RegistrationNumber = registrationNumber;
    }
}
```

### Explanation

The parent initializes `ClaimNumber`. The child initializes `RegistrationNumber`. Each class owns the state it introduced.

### Follow-up questions

- What if `InsuranceClaim` had only a parameterless constructor?
- Can the child access private fields of the parent?
- Would composition be better than inheritance here?

## Exercise 7: Private Constructor and Factory

### Problem statement

Create a `BankAccount` with a private constructor and a public `Open` factory method that validates the account number.

### Expected approach

Keep the constructor private and perform validation in the factory method.

### Complete solution

```csharp
public class BankAccount
{
    public string AccountNumber { get; }

    private BankAccount(string accountNumber)
    {
        AccountNumber = accountNumber;
    }

    public static BankAccount Open(string accountNumber)
    {
        if (string.IsNullOrWhiteSpace(accountNumber))
            throw new ArgumentException("Account number is required.", nameof(accountNumber));

        return new BankAccount(accountNumber);
    }
}
```

### Explanation

Outside code cannot bypass `Open`. The factory gives the creation operation a meaningful name and a single validation boundary.

### Follow-up questions

- Why might `TryCreate` be useful instead of throwing?
- How would you test the private constructor indirectly?
- Is this automatically a singleton?

## Exercise 8: Static Constructor

### Problem statement

Create a static `InsuranceRules` class member that stores a minimum claim amount and initializes it once.

### Expected approach

Use a static read-only property and a static constructor.

### Complete solution

```csharp
public class InsuranceRules
{
    public static decimal MinimumClaimAmount { get; }

    static InsuranceRules()
    {
        MinimumClaimAmount = 100m;
    }
}

Console.WriteLine(InsuranceRules.MinimumClaimAmount);
```

### Explanation

The static constructor runs before the property is first read. The value belongs to the type, not to an individual `InsuranceRules` object.

### Follow-up questions

- Can you call the static constructor directly?
- How many times does it run?
- Would configuration from a database belong here?

## Exercise 9: Predict Inheritance Constructor Output

### Problem statement

Write base and derived classes whose constructors print their names. Predict the output when creating the derived object.

### Expected approach

Remember that the base constructor runs before the derived constructor.

### Complete solution

```csharp
public class Employee
{
    public Employee()
    {
        Console.WriteLine("Employee");
    }
}

public class Manager : Employee
{
    public Manager()
    {
        Console.WriteLine("Manager");
    }
}

var manager = new Manager();
```

### Explanation

The output is `Employee` followed by `Manager`, because the manager includes an employee part that must be initialized first.

### Follow-up questions

- What changes if `Employee` has only `Employee(string name)`?
- Where would `base(name)` be written?
- When do static constructors run relative to these constructors?

## Exercise 10: Constructor Design Review

### Problem statement

Review this class and improve it:

```csharp
public class Order
{
    public string Number { get; set; } = "";
    public decimal Total { get; set; }

    public void Initialize(string number, decimal total)
    {
        Number = number;
        Total = total;
    }
}
```

The order should not exist without a valid number and non-negative total.

### Expected approach

Move required setup into a constructor, validate input, and restrict direct mutation.

### Complete solution

```csharp
public class Order
{
    public string Number { get; }
    public decimal Total { get; private set; }

    public Order(string number, decimal total)
    {
        if (string.IsNullOrWhiteSpace(number))
            throw new ArgumentException("Order number is required.", nameof(number));
        if (total < 0)
            throw new ArgumentOutOfRangeException(nameof(total));

        Number = number;
        Total = total;
    }
}
```

### Explanation

The original class allows an empty order and requires callers to remember `Initialize`. The improved version creates a valid order in one step and does not allow outside code to replace the order number.

### Follow-up questions

- Should `Total` be changed by a method such as `AddLine`?
- Would an immutable record be suitable here?
- How would an ORM create this object?

---

# Final Revision Summary

## Remember the basics

- A constructor prepares an object when it is created.
- It has the same name as the class and no return type.
- It runs automatically during `new`.
- A parameterized constructor makes required data visible.
- A default constructor has no parameters.
- If no instance constructor is written, C# supplies a public parameterless one for a class.
- Once you write an instance constructor, the automatic parameterless constructor is not supplied.

## Remember the keywords

- `this(...)`: call another constructor in the same class.
- `base(...)`: call a constructor in the parent class.
- `static`: initialize type-level data once through a static constructor.

## Interview-ready answers

```text
Constructor: initializes an object's starting state.
Overloading: multiple constructors with different parameter lists.
Overriding: constructors cannot be overridden.
Inheritance: constructors are not inherited.
Return value: constructors have no return type or return value.
Static constructor: runs automatically once before required first use.
```

## Practical design checklist

Before adding a constructor, ask:

1. What values are required for a valid object?
2. Can invalid values be rejected immediately?
3. Can overloaded constructors chain to one main constructor?
4. Should creation have a meaningful factory method name?
5. Does the child need to call a parent constructor with `base(...)`?
6. Is this setup local initialization, or does it belong in a service?
7. Will a framework such as an ORM or serializer require a parameterless constructor?
8. Could too many parameters be replaced with a focused options or value object?

A good constructor is usually short, validates essential input, initializes the object's own state, and leaves larger workflows to application services.
