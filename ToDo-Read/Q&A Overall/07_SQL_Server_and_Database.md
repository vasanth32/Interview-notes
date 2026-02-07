# SQL Server & Database - Interview Guide

## 1. Database Design

### Normalization

**Purpose**: Eliminate data redundancy and ensure data integrity

**First Normal Form (1NF):**
- Each column contains atomic (indivisible) values
- No repeating groups
- Each row is unique

**Example - Violates 1NF:**
```
CustomerID | Name    | Phone
1          | John    | 555-1234, 555-5678
```

**1NF Compliant:**
```
CustomerID | Name    | Phone
1          | John    | 555-1234
1          | John    | 555-5678
```

**Second Normal Form (2NF):**
- Must be in 1NF
- All non-key attributes fully dependent on primary key
- No partial dependencies

**Third Normal Form (3NF):**
- Must be in 2NF
- No transitive dependencies (non-key attribute depends on another non-key attribute)

### Primary Keys

**Definition**: Unique identifier for each row

**Characteristics:**
- Must be unique
- Cannot be NULL
- One per table (can be composite)

**Example:**
```sql
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100)
);
```

### Foreign Keys

**Definition**: References primary key in another table

**Purpose**: Maintain referential integrity

**Example:**
```sql
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    OrderDate DATETIME
);
```

**Cascade Options:**
- `ON DELETE CASCADE`: Delete related rows
- `ON DELETE SET NULL`: Set foreign key to NULL
- `ON DELETE NO ACTION`: Prevent deletion if references exist

### Indexes

**Purpose**: Speed up data retrieval

**Types:**
- **Clustered Index**: Physical order of data (one per table, usually primary key)
- **Non-Clustered Index**: Separate structure pointing to data (multiple allowed)

**When to Index:**
- Frequently queried columns
- Foreign keys
- Columns in WHERE, JOIN, ORDER BY clauses

**Example:**
```sql
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE NONCLUSTERED INDEX IX_Orders_UserID ON Orders(UserID);
```

**Trade-offs:**
- Faster SELECT queries
- Slower INSERT/UPDATE/DELETE (indexes must be updated)

### Relationships

**One-to-One:**
- One row in Table A relates to one row in Table B
- Example: User → UserProfile

**One-to-Many:**
- One row in Table A relates to many rows in Table B
- Example: Customer → Orders

**Many-to-Many:**
- Requires junction table
- Example: Students ↔ Courses (via Enrollment table)

---

## 2. SQL Queries

### SELECT Statements

**Basic:**
```sql
SELECT * FROM Users;
SELECT UserID, Username, Email FROM Users;
```

**Filtering:**
```sql
SELECT * FROM Users WHERE Age >= 18;
SELECT * FROM Users WHERE Email LIKE '%@gmail.com';
SELECT * FROM Users WHERE CreatedDate BETWEEN '2024-01-01' AND '2024-12-31';
```

**Sorting:**
```sql
SELECT * FROM Users ORDER BY Name ASC;
SELECT * FROM Users ORDER BY CreatedDate DESC, Name ASC;
```

### JOINs

**INNER JOIN:**
- Returns rows with matching values in both tables

```sql
SELECT u.Username, o.OrderID, o.OrderDate
FROM Users u
INNER JOIN Orders o ON u.UserID = o.UserID;
```

**LEFT JOIN (LEFT OUTER JOIN):**
- Returns all rows from left table, matching rows from right
- NULL for non-matching right rows

```sql
SELECT u.Username, o.OrderID
FROM Users u
LEFT JOIN Orders o ON u.UserID = o.UserID;
-- Returns all users, even if they have no orders
```

**RIGHT JOIN:**
- Returns all rows from right table, matching rows from left

**FULL OUTER JOIN:**
- Returns all rows from both tables
- NULL for non-matching rows

**Self JOIN:**
- Join table to itself

```sql
SELECT e1.Name AS Employee, e2.Name AS Manager
FROM Employees e1
LEFT JOIN Employees e2 ON e1.ManagerID = e2.EmployeeID;
```

### Subqueries

**Scalar Subquery (returns single value):**
```sql
SELECT Username, 
       (SELECT COUNT(*) FROM Orders WHERE UserID = Users.UserID) AS OrderCount
FROM Users;
```

**Correlated Subquery:**
- References outer query
- Executed for each row

**EXISTS:**
```sql
SELECT * FROM Users u
WHERE EXISTS (
    SELECT 1 FROM Orders o 
    WHERE o.UserID = u.UserID
);
```

### Common Table Expressions (CTEs)

**Purpose**: Temporary named result set

```sql
WITH HighValueOrders AS (
    SELECT UserID, SUM(Total) AS TotalSpent
    FROM Orders
    GROUP BY UserID
    HAVING SUM(Total) > 1000
)
SELECT u.Username, hvo.TotalSpent
FROM Users u
INNER JOIN HighValueOrders hvo ON u.UserID = hvo.UserID;
```

**Recursive CTE:**
```sql
WITH EmployeeHierarchy AS (
    -- Anchor
    SELECT EmployeeID, Name, ManagerID, 0 AS Level
    FROM Employees
    WHERE ManagerID IS NULL
    
    UNION ALL
    
    -- Recursive
    SELECT e.EmployeeID, e.Name, e.ManagerID, eh.Level + 1
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT * FROM EmployeeHierarchy;
```

### Aggregate Functions

**Common Functions:**
- `COUNT(*)` - Count rows
- `SUM(column)` - Sum numeric values
- `AVG(column)` - Average
- `MIN(column)` - Minimum value
- `MAX(column)` - Maximum value

**GROUP BY:**
```sql
SELECT UserID, COUNT(*) AS OrderCount, SUM(Total) AS TotalSpent
FROM Orders
GROUP BY UserID;
```

**HAVING:**
- Filter groups (WHERE filters rows)

```sql
SELECT UserID, COUNT(*) AS OrderCount
FROM Orders
GROUP BY UserID
HAVING COUNT(*) > 5;
```

### Window Functions

**Purpose**: Perform calculations across rows without grouping

```sql
SELECT Username, OrderDate, Total,
       SUM(Total) OVER (PARTITION BY UserID) AS UserTotal,
       ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY OrderDate) AS OrderNumber
FROM Orders o
INNER JOIN Users u ON o.UserID = u.UserID;
```

**Common Functions:**
- `ROW_NUMBER()` - Sequential number
- `RANK()` - Rank with gaps
- `DENSE_RANK()` - Rank without gaps
- `LAG()` / `LEAD()` - Previous/next row value

---

## 3. INSERT, UPDATE, DELETE

### INSERT

**Single Row:**
```sql
INSERT INTO Users (Username, Email, Age)
VALUES ('john_doe', 'john@example.com', 25);
```

**Multiple Rows:**
```sql
INSERT INTO Users (Username, Email)
VALUES 
    ('user1', 'user1@example.com'),
    ('user2', 'user2@example.com'),
    ('user3', 'user3@example.com');
```

**From SELECT:**
```sql
INSERT INTO ArchivedUsers (UserID, Username, Email)
SELECT UserID, Username, Email
FROM Users
WHERE CreatedDate < '2020-01-01';
```

### UPDATE

**Single Column:**
```sql
UPDATE Users
SET Email = 'newemail@example.com'
WHERE UserID = 1;
```

**Multiple Columns:**
```sql
UPDATE Users
SET Email = 'newemail@example.com',
    LastLoginDate = GETDATE()
WHERE UserID = 1;
```

**With JOIN:**
```sql
UPDATE o
SET o.Status = 'Cancelled'
FROM Orders o
INNER JOIN Users u ON o.UserID = u.UserID
WHERE u.Email = 'inactive@example.com';
```

### DELETE

**Delete Rows:**
```sql
DELETE FROM Users WHERE UserID = 1;
```

**Delete All:**
```sql
DELETE FROM Users;  -- Deletes all rows
-- vs
TRUNCATE TABLE Users;  -- Faster, resets identity
```

**With JOIN:**
```sql
DELETE o
FROM Orders o
INNER JOIN Users u ON o.UserID = u.UserID
WHERE u.Email = 'inactive@example.com';
```

---

## 4. Stored Procedures

### Creating Stored Procedures

**Basic:**
```sql
CREATE PROCEDURE GetUserOrders
    @UserID INT
AS
BEGIN
    SELECT * FROM Orders WHERE UserID = @UserID;
END;
```

**Execution:**
```sql
EXEC GetUserOrders @UserID = 1;
-- or
EXECUTE GetUserOrders 1;
```

### Parameters

**Input Parameters:**
```sql
CREATE PROCEDURE CreateUser
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @Age INT = NULL  -- Optional parameter with default
AS
BEGIN
    INSERT INTO Users (Username, Email, Age)
    VALUES (@Username, @Email, @Age);
END;
```

**Output Parameters:**
```sql
CREATE PROCEDURE GetUserCount
    @Count INT OUTPUT
AS
BEGIN
    SELECT @Count = COUNT(*) FROM Users;
END;

-- Execution
DECLARE @Result INT;
EXEC GetUserCount @Count = @Result OUTPUT;
SELECT @Result;
```

**Return Value:**
```sql
CREATE PROCEDURE CheckUserExists
    @UserID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID)
        RETURN 1;
    ELSE
        RETURN 0;
END;

-- Execution
DECLARE @Exists INT;
EXEC @Exists = CheckUserExists @UserID = 1;
```

### Error Handling (TRY-CATCH)

```sql
CREATE PROCEDURE SafeDeleteUser
    @UserID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM Orders WHERE UserID = @UserID;
        DELETE FROM Users WHERE UserID = @UserID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
```

### Dynamic SQL

**Purpose**: Build SQL statements dynamically

```sql
CREATE PROCEDURE SearchUsers
    @SearchColumn NVARCHAR(50),
    @SearchValue NVARCHAR(100)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 'SELECT * FROM Users WHERE ' + 
               QUOTENAME(@SearchColumn) + ' = @Value';
    
    EXEC sp_executesql @SQL, 
         N'@Value NVARCHAR(100)', 
         @Value = @SearchValue;
END;
```

**⚠️ Security Warning**: 
- Risk of SQL injection
- Use parameterized queries
- Validate input
- Consider alternatives (ORM, parameterized queries)

### Performance Considerations

**Best Practices:**
- Use parameters (not string concatenation)
- Avoid dynamic SQL when possible
- Use SET NOCOUNT ON (reduces network traffic)
- Index columns used in WHERE/JOIN
- Avoid cursors (use set-based operations)

---

## 5. Performance Optimization

### Query Execution Plans

**View Plan:**
- SQL Server Management Studio: Include Actual Execution Plan
- Or: `SET SHOWPLAN_ALL ON`

**What to Look For:**
- Table scans (bad - should use index)
- Index seeks (good)
- High cost operations
- Missing indexes

### Indexing Strategies

**When to Create:**
- Foreign keys
- Frequently filtered columns
- Columns in JOIN conditions
- Columns in ORDER BY

**Composite Indexes:**
```sql
CREATE INDEX IX_Orders_UserID_Date 
ON Orders(UserID, OrderDate);
-- Order matters! Most selective first
```

**Covering Index:**
- Includes all columns needed by query
- Avoids key lookups

```sql
CREATE INDEX IX_Orders_Covering
ON Orders(UserID) INCLUDE (OrderDate, Total);
```

---

## Interview Questions to Prepare

1. **Explain normalization (1NF, 2NF, 3NF) with examples.**
2. **What's the difference between INNER JOIN and LEFT JOIN?**
3. **When would you use a subquery vs a JOIN?**
4. **Explain the difference between WHERE and HAVING.**
5. **What are stored procedures? What are their advantages?**
6. **How do you handle errors in stored procedures?**
7. **What is an index? When should you create one?**
8. **Explain the difference between clustered and non-clustered indexes.**
9. **How do you optimize a slow query?**
10. **What is SQL injection? How do you prevent it?**

