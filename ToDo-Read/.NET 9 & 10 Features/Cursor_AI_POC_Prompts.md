# Cursor AI POC Prompts - Quick Reference

This file contains ready-to-use prompts for creating POCs with Cursor AI.

---

## POC 1: LINQ CountBy and AggregateBy

```
Create a .NET 9 console application that demonstrates LINQ CountBy and AggregateBy methods.

Requirements:
1. Create a Student class with properties: Id, Name, Grade, SchoolId
2. Create a Payment class with properties: StudentId, Amount, Status, Date
3. Create sample data with at least 20 students and 50 payments
4. Use CountBy to count students by Grade
5. Use AggregateBy to sum payment amounts by StudentId
6. Display results in a formatted table
7. Include comments explaining each LINQ operation
8. Use primary constructors for classes
9. Use collection expressions for sample data

Create the project structure:
- Program.cs (main entry point)
- Models/Student.cs
- Models/Payment.cs
- Services/StudentService.cs (for data generation)
```

---

## POC 2: Minimal APIs with Route Groups

```
Create a .NET 9 Web API application using Minimal APIs with route groups.

Requirements:
1. Create a Student API with CRUD operations using route groups
2. Create a Payment API with route groups
3. Use primary constructors for DTOs
4. Implement GET, POST, PUT, DELETE endpoints
5. Add Swagger/OpenAPI documentation
6. Use in-memory data store (List<T>)
7. Add validation using FluentValidation or Data Annotations
8. Include error handling middleware
9. Add logging for all operations
10. Use collection expressions for sample data

Project structure:
- Program.cs (API setup)
- Models/Student.cs
- Models/Payment.cs
- DTOs/StudentDto.cs
- DTOs/CreateStudentDto.cs
- DTOs/UpdateStudentDto.cs
- Services/IStudentService.cs
- Services/StudentService.cs
- Middleware/ErrorHandlingMiddleware.cs
```

---

## POC 3: Primary Constructors and Collection Expressions

```
Create a .NET 9 console application demonstrating primary constructors and collection expressions.

Requirements:
1. Create classes using primary constructors:
   - Student(int id, string name, string email, int schoolId)
   - School(int id, string name, string address)
   - Enrollment(int studentId, int activityId, DateTime enrolledDate)
2. Use collection expressions to create sample data
3. Demonstrate spreading collections: [..existingCollection, newItems]
4. Create methods that use primary constructor parameters
5. Show inheritance with primary constructors
6. Display all data in formatted output
7. Include examples of:
   - Arrays with collection expressions
   - Lists with collection expressions
   - Spreading collections
   - Nested collections

Project structure:
- Program.cs
- Models/Student.cs (with primary constructor)
- Models/School.cs (with primary constructor)
- Models/Enrollment.cs (with primary constructor)
- Services/DataGenerator.cs
```

---

## POC 4: Enhanced Web API with JSON Serialization

```
Create a .NET 9 Web API with enhanced JSON serialization features.

Requirements:
1. Create a Student API with minimal APIs
2. Configure System.Text.Json with:
   - Camel case naming
   - Ignore null values
   - Custom converters
   - Source generation
3. Create DTOs with different serialization scenarios
4. Add endpoints that demonstrate:
   - Serialization of complex objects
   - Custom JSON converters
   - Ignoring properties conditionally
5. Add Swagger documentation
6. Include examples of:
   - Serializing dates in custom format
   - Serializing enums as strings
   - Ignoring properties based on conditions
7. Add performance comparison (optional)

Project structure:
- Program.cs (with JSON configuration)
- Models/Student.cs
- DTOs/StudentDto.cs
- Converters/DateOnlyJsonConverter.cs
- Converters/EnumStringConverter.cs
```

---

## POC 5: LINQ Index and ChunkBy Methods

```
Create a .NET 9 console application demonstrating LINQ Index and ChunkBy methods.

Requirements:
1. Create Activity class with properties: Id, Name, Status, Capacity
2. Create sample data with activities in different statuses
3. Use Index() method to add indices to activities
4. Use ChunkBy() to group consecutive activities by status
5. Display:
   - Activities with their indices
   - Chunked groups by status
6. Include real-world scenarios:
   - Processing items with their position
   - Grouping consecutive similar items
7. Add performance notes comparing to traditional approaches

Project structure:
- Program.cs
- Models/Activity.cs
- Services/ActivityService.cs
- Examples/IndexExamples.cs
- Examples/ChunkByExamples.cs
```

---

## POC 6: Complete Microservice with .NET 9 Features

```
Create a complete .NET 9 microservice demonstrating all new features.

Requirements:
1. Create a Student Enrollment Service using Minimal APIs
2. Use primary constructors for all models and DTOs
3. Use collection expressions for sample data
4. Implement LINQ operations:
   - CountBy (count enrollments by status)
   - AggregateBy (sum fees by student)
   - Index (enrollment positions)
5. Use route groups for API organization
6. Configure enhanced JSON serialization
7. Add Swagger/OpenAPI documentation
8. Include:
   - Error handling middleware
   - Logging
   - Validation
   - In-memory data store
9. Use alias types for complex types
10. Demonstrate pattern matching

Project structure:
- Program.cs
- Models/Student.cs
- Models/Enrollment.cs
- Models/Fee.cs
- DTOs/ (all DTOs with primary constructors)
- Services/IEnrollmentService.cs
- Services/EnrollmentService.cs
- Middleware/ErrorHandlingMiddleware.cs
- Extensions/ServiceCollectionExtensions.cs
```

---

## POC 7: Performance Comparison - Old vs New LINQ

```
Create a .NET 9 console application that compares performance of old vs new LINQ methods.

Requirements:
1. Generate large dataset (100,000+ records)
2. Compare:
   - GroupBy().Count() vs CountBy()
   - GroupBy().Aggregate() vs AggregateBy()
   - Select((item, index) => ...) vs Index()
3. Measure execution time for each approach
4. Display performance metrics
5. Include memory usage comparison
6. Add comments explaining performance differences
7. Use BenchmarkDotNet or simple Stopwatch

Project structure:
- Program.cs
- Models/Student.cs
- Services/PerformanceTestService.cs
- Results/PerformanceResults.cs
```

---

## POC 8: Web API with Native AOT

```
Create a .NET 9 Web API optimized for Native AOT compilation.

Requirements:
1. Create a minimal API for Student management
2. Configure for Native AOT compilation
3. Use source generators where possible
4. Avoid reflection-heavy libraries
5. Test deployment size and startup time
6. Compare with regular compilation
7. Document limitations and workarounds
8. Include deployment instructions

Project structure:
- Program.cs
- Models/Student.cs
- DTOs/StudentDto.cs
- Services/StudentService.cs
- README.md (with AOT notes)
```

---

## Usage Tips

1. **Copy the prompt** you want to use
2. **Paste into Cursor AI** chat
3. **Let Cursor generate** the project structure
4. **Review and refine** the generated code
5. **Test and experiment** with the features
6. **Modify prompts** to add your specific requirements

---

## Customization Tips

Add these to any prompt for better results:

- "Include unit tests using xUnit"
- "Add comprehensive error handling"
- "Include logging using ILogger"
- "Add validation using FluentValidation"
- "Include XML documentation comments"
- "Add example requests/responses"
- "Include performance benchmarks"

---

## Example: Enhanced Prompt

```
Create a .NET 9 Web API application using Minimal APIs with route groups.

[Original requirements...]

Additional requirements:
- Include unit tests using xUnit
- Add comprehensive error handling with custom exceptions
- Include logging using ILogger for all operations
- Add validation using FluentValidation
- Include XML documentation comments for all public APIs
- Add example requests/responses in Swagger
- Include performance benchmarks comparing old vs new approaches
- Add Docker support for containerization
- Include GitHub Actions CI/CD pipeline
```

---

## Additional POC Prompts

For more advanced features like Rate Limiting, Output Caching, Health Checks, Keyed Services, Entity Framework Core JSON columns, and Background Services, see:

**[Additional_NET_9_10_Features.md](./Additional_NET_9_10_Features.md)**

That document contains 7 additional POC prompts covering:
- POC 1: Rate Limiting Implementation
- POC 2: Output Caching with Tag-Based Invalidation
- POC 3: Health Checks with Custom Checks
- POC 4: Keyed Services and Dependency Injection
- POC 5: Entity Framework Core JSON Columns
- POC 6: Background Services with Scheduled Tasks
- POC 7: Complete Microservice with All Features

**Total: 15 POC Prompts Available!**

