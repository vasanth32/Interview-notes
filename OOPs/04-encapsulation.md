# Encapsulation in C#

> A beginner-friendly, practical guide for .NET developer interviews

## A Real Problem First

Look at this class:

```csharp
public class BankAccount
{
    public decimal Balance;
}
```

Anyone using this class can do this:

```csharp
var account = new BankAccount();
account.Balance = -100000;
```

Nothing stops this line from running. The account now has a balance of **negative one hundred thousand**, which makes no real-world sense for a normal savings account.

### Why is this dangerous?

- Any part of the application can set `Balance` to anything, including negative numbers, huge numbers, or accidental typos.
- There is no single place that checks whether a change is valid.
- A bug in one unrelated screen or service could silently corrupt account data.
- Testing becomes harder because the rules for "a valid balance" do not live anywhere in code.
- In a real bank, bank employees do not walk up to a vault and change numbers by hand. There is a controlled process (deposit, withdrawal, approval) that protects the money.

This is exactly the problem **encapsulation** solves: it stops outside code from directly changing important data, and instead forces changes to go through controlled, validated operations.

---

## 1. What Is Encapsulation?

### Simple explanation

Encapsulation means **keeping an object's data safe inside the object, and only allowing changes through controlled operations**.

Think of a medicine capsule: the medicine (data) is sealed inside, and you take it through one proper way (a controlled operation), not by opening the capsule and touching the powder directly.

### Technical explanation

In C#, encapsulation is usually done by:

- Making fields `private`.
- Exposing data through `public` properties or methods.
- Adding validation inside those properties or methods.

The object becomes responsible for protecting its own data, instead of trusting every caller to behave correctly.

### Small example

```csharp
public class BankAccount
{
    private decimal balance;

    public decimal Balance => balance;

    public void Deposit(decimal amount)
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        balance += amount;
    }
}
```

### Line-by-line explanation

- `private decimal balance;`: the real value is hidden from outside code.
- `public decimal Balance => balance;`: gives read-only access to the current balance.
- `public void Deposit(decimal amount)`: the only way to add money.
- `if (amount <= 0) throw ...`: rejects invalid deposit amounts.
- `balance += amount;`: only runs after the amount passes validation.

### Problem it solves

It prevents invalid or unsafe changes to important data by removing direct access and replacing it with controlled operations.

---

## 2. Why Do We Need Encapsulation?

### Simple explanation

Without encapsulation, any code anywhere in a large application can change important data in any way, at any time. As the application grows, this becomes very hard to control.

### Technical explanation

Encapsulation:

- Centralizes validation rules in one place.
- Reduces accidental misuse of internal data.
- Makes classes easier to change internally without breaking other code.
- Makes bugs easier to find, because there are fewer places where a value can change.

### Example: without encapsulation

```csharp
public class InsuranceClaim
{
    public string Status;
}

var claim = new InsuranceClaim();
claim.Status = "Paid";
claim.Status = "New"; // Nothing stops this, even after payment.
```

### Example: with encapsulation

```csharp
public class InsuranceClaim
{
    public string Status { get; private set; } = "New";

    public void Approve()
    {
        if (Status != "New")
            throw new InvalidOperationException("Only a new claim can be approved.");

        Status = "Approved";
    }

    public void Pay()
    {
        if (Status != "Approved")
            throw new InvalidOperationException("Only an approved claim can be paid.");

        Status = "Paid";
    }
}
```

### Problem it solves

It stops a claim from moving backward into an invalid state, such as going from `Paid` back to `New`.

---

## 3. Data Protection

### Simple explanation

Data protection means guarding an object's values so they cannot become invalid or dangerous.

### Example: inventory stock

#### Bad Design

```csharp
public class InventoryItem
{
    public int Quantity;
}

var item = new InventoryItem();
item.Quantity = -50;
```

#### Problem

- Negative stock does not exist physically in a warehouse.
- Reports, invoices, and shipping calculations may break or produce nonsense results.
- Any part of the code can cause this bug, and there is no single place to check for it.

#### Improved Design

```csharp
public class InventoryItem
{
    public int Quantity { get; private set; }

    public void AddStock(int amount)
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        Quantity += amount;
    }

    public void RemoveStock(int amount)
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));
        if (amount > Quantity)
            throw new InvalidOperationException("Not enough stock available.");

        Quantity -= amount;
    }
}
```

#### Why This Is Better

- `Quantity` cannot be set directly to an invalid number.
- `RemoveStock` prevents removing more than what exists.
- All stock rules live in one class instead of being repeated everywhere stock is used.

### Where this appears in .NET

An inventory service in an e-commerce or warehouse application would use this pattern so no controller, background job, or script can push stock below zero by mistake.

---

## 4. Private Fields

### Simple explanation

A private field is a variable that only the class itself can see and use directly.

```csharp
public class Employee
{
    private decimal salary;
}
```

Outside code cannot write `employee.salary`; it does not compile.

### Technical explanation

`private` is the most restrictive access modifier. It keeps implementation details inside the class, which is the starting point of encapsulation.

### Example: employee salary

```csharp
public class Employee
{
    private decimal salary;

    public Employee(decimal salary)
    {
        if (salary <= 0)
            throw new ArgumentOutOfRangeException(nameof(salary));

        this.salary = salary;
    }
}
```

### Line-by-line explanation

- `private decimal salary;`: the real salary value, hidden from outside code.
- The constructor validates the salary before storing it.
- `this.salary = salary;`: `this.salary` refers to the field; `salary` refers to the parameter.

### Problem it solves

It prevents other classes from reading or overwriting sensitive internal data directly.

---

## 5. Public Properties

### Simple explanation

A public property is the "front door" that lets other code safely read or change a private field.

```csharp
public class Employee
{
    private decimal salary;

    public decimal Salary
    {
        get => salary;
        set => salary = value;
    }
}
```

### Technical explanation

A property looks like a field from the outside but is really a pair of methods (`get` and `set`) behind the scenes. This means a property can add logic, while a plain public field cannot.

### Bad Design

```csharp
public class Employee
{
    public decimal Salary { get; set; }
}

var employee = new Employee();
employee.Salary = -5000; // Allowed, but wrong.
```

### Problem

A negative salary makes no sense, but a plain auto-property with a public setter does not stop it.

### Improved Design

```csharp
public class Employee
{
    private decimal salary;

    public decimal Salary
    {
        get => salary;
        set
        {
            if (value <= 0)
                throw new ArgumentOutOfRangeException(nameof(value));

            salary = value;
        }
    }
}
```

### Why This Is Better

The property still looks simple to use (`employee.Salary = 5000;`), but now it rejects invalid values automatically, no matter who sets it.

---

## 6. Getters and Setters

### Simple explanation

- A **getter** (`get`) controls how a value is read.
- A **setter** (`set`) controls how a value is written.

### Example: order status

```csharp
public class Order
{
    private string status = "New";

    public string Status
    {
        get => status;
        set
        {
            if (value != "New" && value != "Shipped" && value != "Delivered")
                throw new ArgumentException("Invalid status.", nameof(value));

            status = value;
        }
    }
}
```

### Line-by-line explanation

- `get => status;`: simply returns the current status.
- `set { ... }`: checks that the new value is one of the allowed statuses.
- `status = value;`: only runs if the value passed validation.

### Real project use

An order-processing service can reject an accidental typo such as `"Shiped"` before it reaches the database.

### Problem it solves

Getters and setters give you a single, controlled place to add rules, instead of scattering `if` checks across the whole application every time someone touches this data.

---

## 7. Validation

### Simple explanation

Validation means checking that a value makes sense **before** accepting it.

### Example: insurance claim amount

#### Bad Design

```csharp
public class InsuranceClaim
{
    public decimal Amount { get; set; }
}

var claim = new InsuranceClaim();
claim.Amount = -500;
```

#### Problem

A negative claim amount could cause incorrect payouts, broken reports, or accounting errors.

#### Improved Design

```csharp
public class InsuranceClaim
{
    private decimal amount;

    public decimal Amount
    {
        get => amount;
        set
        {
            if (value <= 0)
                throw new ArgumentOutOfRangeException(nameof(value), "Claim amount must be positive.");

            amount = value;
        }
    }
}
```

#### Why This Is Better

Now it is impossible to set a claim amount that is zero or negative, because the property itself blocks it.

### Where this appears in .NET

Validation inside properties or constructors is a first line of defense, in addition to model validation attributes used in ASP.NET Core APIs (such as `[Range]`).

---

## 8. Private Setters

### Simple explanation

A private setter means: "Only this class can change this value. Outside code can only read it."

```csharp
public class BankAccount
{
    public decimal Balance { get; private set; }

    public void Deposit(decimal amount)
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        Balance += amount;
    }
}
```

### Line-by-line explanation

- `public decimal Balance { get; private set; }`: anyone can read `Balance`, but only code inside `BankAccount` can assign it.
- `Deposit` is the only public way to increase the balance, and it validates the amount first.
- Outside code cannot write `account.Balance = -100000;` anymore; it will not compile.

### Why this matters

The dangerous line from the very first example, `account.Balance = -100000;`, becomes impossible once `Balance` has a private setter. This is a direct fix for the original problem.

### Where this appears in .NET

Domain entities in Entity Framework Core often use private setters so that only meaningful business methods (`Deposit`, `Withdraw`, `ApplyInterest`) can change important values, while EF Core itself can still materialize the entity through its own mechanisms.

---

## 9. Read-Only Properties

### Simple explanation

A read-only property can be set once, usually in the constructor, and never changed again.

```csharp
public class Employee
{
    public string EmployeeId { get; }

    public Employee(string employeeId)
    {
        if (string.IsNullOrWhiteSpace(employeeId))
            throw new ArgumentException("Employee id is required.", nameof(employeeId));

        EmployeeId = employeeId;
    }
}
```

### Line-by-line explanation

- `public string EmployeeId { get; }`: a property with only a getter; there is no setter at all.
- It can only be assigned inside the constructor (or a field initializer).
- Once the object is created, `EmployeeId` cannot change.

### Real project use

An employee id, order number, or claim number usually should never change after creation. A read-only property enforces this at compile time, not just by convention.

### Problem it solves

It prevents identity-like values from being accidentally reassigned anywhere in the codebase.

---

## 10. `init` Properties

### Simple explanation

An `init` property can be set only while the object is being created, using object initializer syntax. After that, it becomes read-only, just like a `get`-only property.

```csharp
public class InsuranceClaim
{
    public string ClaimNumber { get; init; } = "";
    public decimal Amount { get; init; }
}

var claim = new InsuranceClaim
{
    ClaimNumber = "CLM-1",
    Amount = 500m
};

// claim.Amount = 1000m; // Compile error: init-only property.
```

### Line-by-line explanation

- `get; init;`: allows reading anytime, but allows writing only during object initialization.
- The object initializer (`{ ClaimNumber = "CLM-1", Amount = 500m }`) is allowed to set these values.
- Any later assignment outside initialization fails to compile.

### `init` vs private setter

| Feature                                      | `private set`              | `init`                               |
| -------------------------------------------- | -------------------------- | ------------------------------------ |
| Can be set outside the class                 | No                         | Yes, but only during object creation |
| Can be set through object initializer syntax | No                         | Yes                                  |
| Can change after creation                    | Only through class methods | Never                                |

### Real project use

`init` is useful for simple data-carrying types such as request DTOs or value objects, where the caller should supply all values once, and the object should not change afterward.

---

## 11. Methods Used to Control Changes

### Simple explanation

Sometimes a single property setter is not enough because a change depends on more than one value or needs a specific rule. A method can control the change more precisely than a plain setter.

### Example: order status transitions

#### Bad Design

```csharp
public class Order
{
    public string Status { get; set; } = "New";
}

var order = new Order();
order.Status = "Delivered"; // Skips "Shipped" entirely.
```

#### Problem

The order jumps straight from `New` to `Delivered`, skipping the shipping step. Nothing prevents this invalid jump.

#### Improved Design

```csharp
public class Order
{
    public string Status { get; private set; } = "New";

    public void Ship()
    {
        if (Status != "New")
            throw new InvalidOperationException("Only a new order can be shipped.");

        Status = "Shipped";
    }

    public void Deliver()
    {
        if (Status != "Shipped")
            throw new InvalidOperationException("Only a shipped order can be delivered.");

        Status = "Delivered";
    }
}
```

#### Why This Is Better

Methods such as `Ship()` and `Deliver()` describe **real business actions**, and each one only allows a valid transition. It is no longer possible to skip a step.

### Real project use

This pattern is common for order status, insurance claim workflow, payment processing, and shipment tracking, where each state change follows specific business rules.

---

## 12. Encapsulation vs Data Hiding

### Simple explanation

- **Data hiding** means: hide the internal data (usually with `private`).
- **Encapsulation** means: hide the internal data **and** provide safe, controlled ways to use it.

Data hiding is one tool used to achieve encapsulation, but encapsulation is the bigger idea.

### Example

```csharp
public class BankAccount
{
    private decimal balance; // data hiding

    public decimal Balance => balance; // part of encapsulation: controlled read access

    public void Deposit(decimal amount) // part of encapsulation: controlled write access
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        balance += amount;
    }
}
```

### Simple distinction to remember

```text
Data hiding  = hiding the field (private)
Encapsulation = hiding the field AND controlling access through safe operations
```

You can hide data without truly encapsulating it well (for example, hiding a field but exposing a public setter with no validation at all). Real encapsulation means the object protects its own rules, not just its variable names.

---

# Common Confusions

## Are public properties always encapsulation?

**No.** A public property with an unrestricted `get` and `set` and no validation is barely different from a public field.

```csharp
public class Employee
{
    public decimal Salary { get; set; } // Not real encapsulation.
}
```

This compiles and looks encapsulated because it uses a property, but nothing stops `employee.Salary = -999;`. Real encapsulation requires validation or controlled access, not just the property syntax.

## Why not make everything public?

Making everything public removes the protection encapsulation gives you:

- Any code anywhere can set data to invalid values.
- Business rules end up duplicated in many places instead of one place.
- Refactoring becomes risky because many unrelated parts of the code may depend on internal details.

Public members should represent what a class **allows other code to do**, not simply everything the class happens to contain.

## Encapsulation vs abstraction

- **Encapsulation** hides _how data is stored and protected_, focusing on safe access to state.
- **Abstraction** hides _how something works internally_, focusing on exposing only the essential operations and hiding implementation complexity.

Example: an interface `IPaymentGateway` with a method `Charge(amount)` is abstraction: callers do not know or care how the charge happens internally. Encapsulation is what protects the internal state of the class implementing `Charge`, such as connection details or internal counters.

They often work together: abstraction defines _what_ is exposed, encapsulation protects _how it is implemented and stored_.

## Encapsulation vs data hiding

As covered above: data hiding (using `private`) is one technique. Encapsulation is the overall practice of protecting an object's state through hidden data plus controlled access.

## Can methods provide encapsulation?

**Yes.** Methods are one of the main tools of encapsulation, alongside properties. A method like `Deposit(decimal amount)` or `Ship()` can enforce rules that a simple property setter cannot easily express, especially when a change depends on the current state or multiple values together.

---

# Interview Questions

## Beginner Questions

### 1. What is encapsulation?

**Short answer:** Encapsulation is hiding an object's internal data and only allowing changes through controlled, validated operations.

**Deep explanation:** It usually combines private fields with public properties or methods that enforce rules, so the object protects its own state instead of trusting external code.

**Example:** A `BankAccount` with a private `balance` field and a `Deposit` method that rejects negative amounts.

**Common wrong answer:** "Encapsulation just means using private fields." This misses the second half: controlled access is also required.

### 2. Why do we need encapsulation?

**Short answer:** To prevent invalid or unsafe changes to important data and to keep business rules in one place.

**Deep explanation:** Without it, any code anywhere can corrupt an object's state, and the same validation logic must be repeated everywhere that data is touched.

**Example:** Preventing `order.Status = "Delivered"` from skipping the shipping step.

**Common wrong answer:** "It is only for security against hackers." Encapsulation mainly protects against accidental misuse and bugs within the same application, not external attackers.

### 3. What is the difference between a field and a property?

**Short answer:** A field is raw storage. A property is a controlled access point that can add logic around reading and writing.

**Deep explanation:** A property is compiled into get/set methods, so it can validate, calculate, or restrict access, while a plain public field cannot.

**Example:** `private decimal salary;` (field) versus `public decimal Salary { get; private set; }` (property).

**Common wrong answer:** "They are exactly the same thing with different syntax."

## Intermediate Questions

### 4. What is a private setter, and when would you use it?

**Short answer:** A private setter allows outside code to read a property but only allows the class itself to change it.

**Deep explanation:** It is useful when a value should only change through specific, validated methods, such as `Deposit` or `Ship`, instead of being assigned freely.

**Example:** `public decimal Balance { get; private set; }` with a `Deposit` method controlling changes.

**Common wrong answer:** "A private setter means the property cannot be read either."

### 5. What is the difference between `init` and a private setter?

**Short answer:** `init` allows setting the value only during object creation (including through object initializer syntax); a private setter allows setting the value only from inside the class, at any time.

**Deep explanation:** `init` is useful for simple, immutable data objects created in one step. A private setter is useful when a class needs to change a value later through its own controlled methods.

**Example:** `public decimal Amount { get; init; }` for a claim DTO versus `public decimal Balance { get; private set; }` for a bank account that changes over time.

**Common wrong answer:** "They behave exactly the same in every case."

### 6. Is encapsulation only about making fields private?

**Short answer:** No, private fields are only part of it. Encapsulation also requires exposing safe, validated access.

**Deep explanation:** A class can hide a field but still expose an unrestricted setter with no rules, which does not achieve real protection.

**Example:** `public decimal Salary { get; set; }` looks encapsulated but has no protection at all.

**Common wrong answer:** "If a field is private, the class is automatically encapsulated."

## Tricky Questions

### 7. Are public properties always considered good encapsulation?

**Short answer:** No. A public property without validation offers little more protection than a public field.

**Deep explanation:** The presence of `get`/`set` syntax does not guarantee safety; the protection comes from what logic (if any) runs inside the setter.

**Example:** `public int Quantity { get; set; }` versus a `Quantity` property that rejects negative values.

**Common wrong answer:** "Since it uses a property instead of a field, it must be properly encapsulated."

### 8. Can a method provide better encapsulation than a property in some cases?

**Short answer:** Yes, especially when a change depends on more than one value or a specific business rule.

**Deep explanation:** A method such as `Ship()` can check the current state before making a change, while a plain setter typically only validates the new value in isolation.

**Example:** `Ship()` checks that `Status == "New"` before changing it to `"Shipped"`, something a simple `Status` setter alone would not naturally express as clearly.

**Common wrong answer:** "Properties are always the correct choice for controlling state."

### 9. What is the difference between encapsulation and abstraction?

**Short answer:** Encapsulation protects internal state; abstraction hides internal complexity behind a simpler contract.

**Deep explanation:** Abstraction defines _what_ a caller can do (for example, an interface method). Encapsulation controls _how safely_ the internal state behind that contract is stored and changed.

**Example:** An `IPaymentGateway.Charge(amount)` interface is abstraction. The private fields and validation inside the class implementing it are encapsulation.

**Common wrong answer:** "They are the same concept with two different names."

### 10. If a class only has private fields and no public members at all, is it well encapsulated?

**Short answer:** Not necessarily useful, even though it is technically very "hidden."

**Deep explanation:** Encapsulation is not just about hiding as much as possible; it is about exposing exactly the safe operations a class needs to be useful, while protecting the rest. A class with no public members at all cannot be used by anything.

**Example:** A `BankAccount` with a private `balance` and no public way to deposit, withdraw, or read the balance is hidden but not practically usable.

**Common wrong answer:** "More hidden data always means better encapsulation."

---

# Coding Practice

Try writing each solution yourself before checking the answer.

## Exercise 1: Protect a Bank Balance

### Problem statement

Rewrite a `BankAccount` so the balance cannot be set directly and can only increase through a `Deposit` method that rejects non-positive amounts.

### Complete solution

```csharp
public class BankAccount
{
    public decimal Balance { get; private set; }

    public void Deposit(decimal amount)
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        Balance += amount;
    }
}
```

### Explanation

`Balance` can be read by anyone but changed only inside `BankAccount`, and only through validated deposits.

---

## Exercise 2: Prevent Negative Stock

### Problem statement

Create an `InventoryItem` where `Quantity` cannot be set directly and cannot go below zero.

### Complete solution

```csharp
public class InventoryItem
{
    public int Quantity { get; private set; }

    public void AddStock(int amount)
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));

        Quantity += amount;
    }

    public void RemoveStock(int amount)
    {
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount));
        if (amount > Quantity)
            throw new InvalidOperationException("Not enough stock available.");

        Quantity -= amount;
    }
}
```

### Explanation

`RemoveStock` checks available quantity before subtracting, so `Quantity` can never become negative.

---

## Exercise 3: Validate Employee Salary

### Problem statement

Create an `Employee` whose salary must always be greater than zero, both at creation and when changed later.

### Complete solution

```csharp
public class Employee
{
    private decimal salary;

    public Employee(decimal salary)
    {
        Salary = salary;
    }

    public decimal Salary
    {
        get => salary;
        set
        {
            if (value <= 0)
                throw new ArgumentOutOfRangeException(nameof(value));

            salary = value;
        }
    }
}
```

### Explanation

The constructor reuses the property setter, so validation runs in one place whether the salary is set at creation or later.

---

## Exercise 4: Read-Only Employee Id

### Problem statement

Create an `Employee` whose `EmployeeId` can be set only once, in the constructor.

### Complete solution

```csharp
public class Employee
{
    public string EmployeeId { get; }

    public Employee(string employeeId)
    {
        if (string.IsNullOrWhiteSpace(employeeId))
            throw new ArgumentException("Employee id is required.", nameof(employeeId));

        EmployeeId = employeeId;
    }
}
```

### Explanation

A `get`-only property can be assigned only in the constructor, so `EmployeeId` cannot change afterward.

---

## Exercise 5: `init`-Only Insurance Claim

### Problem statement

Create an `InsuranceClaim` whose `ClaimNumber` and `Amount` can be set only when the object is created.

### Complete solution

```csharp
public class InsuranceClaim
{
    public string ClaimNumber { get; init; } = "";
    public decimal Amount { get; init; }
}

var claim = new InsuranceClaim
{
    ClaimNumber = "CLM-100",
    Amount = 750m
};
```

### Explanation

`init` allows the object initializer syntax to work, but any later attempt to change `ClaimNumber` or `Amount` will not compile.

---

## Exercise 6: Order Status Workflow

### Problem statement

Create an `Order` that can move only from `New` to `Shipped`, and from `Shipped` to `Delivered`, using methods instead of a plain setter.

### Complete solution

```csharp
public class Order
{
    public string Status { get; private set; } = "New";

    public void Ship()
    {
        if (Status != "New")
            throw new InvalidOperationException("Only a new order can be shipped.");

        Status = "Shipped";
    }

    public void Deliver()
    {
        if (Status != "Shipped")
            throw new InvalidOperationException("Only a shipped order can be delivered.");

        Status = "Delivered";
    }
}
```

### Explanation

Each method checks the current status before allowing the next step, so an order cannot skip a stage.

---

## Exercise 7: Reject Invalid Insurance Claim Amount

### Problem statement

Create an `InsuranceClaim` where the `Amount` property rejects zero or negative values.

### Complete solution

```csharp
public class InsuranceClaim
{
    private decimal amount;

    public decimal Amount
    {
        get => amount;
        set
        {
            if (value <= 0)
                throw new ArgumentOutOfRangeException(nameof(value));

            amount = value;
        }
    }
}
```

### Explanation

The setter validates every assignment, whether it happens once or many times during the object's life.

---

## Exercise 8: Encapsulated Password-Style Field

### Problem statement

Create a `UserAccount` class that stores a `Username` publicly but keeps a `passwordHash` completely private, exposing only a `VerifyPassword` method.

### Complete solution

```csharp
public class UserAccount
{
    public string Username { get; }
    private readonly string passwordHash;

    public UserAccount(string username, string passwordHash)
    {
        Username = username;
        this.passwordHash = passwordHash;
    }

    public bool VerifyPassword(string hashToCheck)
    {
        return passwordHash == hashToCheck;
    }
}
```

### Explanation

Outside code can never read the raw `passwordHash`; it can only ask the object to verify a hash, which is a safer and more controlled operation.

---

## Exercise 9: Insurance Claim Approval Flow

### Problem statement

Create an `InsuranceClaim` that can only move from `New` to `Approved`, and from `Approved` to `Paid`, and cannot move backward.

### Complete solution

```csharp
public class InsuranceClaim
{
    public string Status { get; private set; } = "New";

    public void Approve()
    {
        if (Status != "New")
            throw new InvalidOperationException("Only a new claim can be approved.");

        Status = "Approved";
    }

    public void Pay()
    {
        if (Status != "Approved")
            throw new InvalidOperationException("Only an approved claim can be paid.");

        Status = "Paid";
    }
}
```

### Explanation

Each method enforces one valid transition, matching the real-world business process for handling a claim.

---

## Exercise 10: Refactor an Unsafe Class

### Problem statement

Refactor this unsafe class using everything learned in this chapter:

```csharp
public class ShipmentOld
{
    public string Status;
    public int PackageCount;
}
```

Requirements:

- `PackageCount` must never be negative and should be set once at creation.
- `Status` should only move `New -> Dispatched -> Delivered`.

### Complete solution

```csharp
public class Shipment
{
    public int PackageCount { get; }
    public string Status { get; private set; } = "New";

    public Shipment(int packageCount)
    {
        if (packageCount <= 0)
            throw new ArgumentOutOfRangeException(nameof(packageCount));

        PackageCount = packageCount;
    }

    public void Dispatch()
    {
        if (Status != "New")
            throw new InvalidOperationException("Only a new shipment can be dispatched.");

        Status = "Dispatched";
    }

    public void Deliver()
    {
        if (Status != "Dispatched")
            throw new InvalidOperationException("Only a dispatched shipment can be delivered.");

        Status = "Delivered";
    }
}
```

### Explanation

`PackageCount` becomes a validated, read-only value, and `Status` can only progress through valid steps using methods, matching both requirements.

---

# Quick Revision

- Encapsulation hides data and controls how it can be changed.
- A private field alone is not enough; controlled access is also required.
- Public properties are only "real" encapsulation when they include meaningful rules or restricted access.
- Private setters allow reading everywhere but writing only inside the class.
- Read-only (`get`-only) properties can be set once, in the constructor.
- `init` properties can be set once, during object creation, including with object initializer syntax.
- Methods can enforce rules that simple property setters cannot easily express, especially for state transitions.
- Data hiding is a technique; encapsulation is the overall goal that includes controlled access.

# Real-World Examples

| Domain          | What is protected | How encapsulation helps                                            |
| --------------- | ----------------- | ------------------------------------------------------------------ |
| Bank account    | Balance           | Only `Deposit`/`Withdraw` can change it, never a direct assignment |
| Inventory       | Stock quantity    | `AddStock`/`RemoveStock` prevent negative stock                    |
| Employee        | Salary            | Property setter rejects zero or negative salaries                  |
| Order           | Status            | Methods like `Ship()`/`Deliver()` allow only valid transitions     |
| Insurance claim | Amount and status | Validated amount, and controlled `Approve()`/`Pay()` workflow      |

# Interview Cheat Sheet

```text
Encapsulation = hide data + control access

Private field        -> hides the raw value
Public property       -> controlled access point
Getter                -> controls reading
Setter                -> controls writing
Validation            -> rejects invalid values
Private setter        -> read anywhere, write only inside the class
Read-only property    -> set once, in the constructor
init property         -> set once, during object creation
Methods               -> enforce rules across multiple values or states

Data hiding   = private fields only
Encapsulation = private fields + controlled, validated access
Abstraction   = hides *how* something works; exposes only *what* it does
```

One-line interview answer: "Encapsulation means an object protects its own data by hiding it and only allowing changes through controlled, validated operations, instead of letting any code change it directly."
