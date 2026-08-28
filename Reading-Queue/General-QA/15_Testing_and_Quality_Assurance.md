# Testing & Quality Assurance - Interview Guide

## 1. Unit Testing

### What is Unit Testing?

**Definition**: Testing individual units (methods, classes) in isolation

**Purpose:**
- Verify code works correctly
- Catch bugs early
- Enable refactoring with confidence
- Document expected behavior

**Characteristics:**
- Fast execution
- Isolated (no dependencies)
- Repeatable
- Automated

---

### Testing Frameworks

**xUnit (Most Popular for .NET Core):**
```csharp
// Install: dotnet add package xunit
// Install: dotnet add package xunit.runner.visualstudio

public class CalculatorTests
{
    [Fact]
    public void Add_ShouldReturnSum_WhenGivenTwoNumbers()
    {
        // Arrange
        var calculator = new Calculator();
        
        // Act
        var result = calculator.Add(2, 3);
        
        // Assert
        Assert.Equal(5, result);
    }
}
```

**NUnit:**
```csharp
[TestFixture]
public class CalculatorTests
{
    [Test]
    public void Add_ShouldReturnSum_WhenGivenTwoNumbers()
    {
        var calculator = new Calculator();
        var result = calculator.Add(2, 3);
        Assert.AreEqual(5, result);
    }
}
```

**MSTest:**
```csharp
[TestClass]
public class CalculatorTests
{
    [TestMethod]
    public void Add_ShouldReturnSum_WhenGivenTwoNumbers()
    {
        var calculator = new Calculator();
        var result = calculator.Add(2, 3);
        Assert.AreEqual(5, result);
    }
}
```

**Test Naming Convention:**
```
MethodName_Scenario_ExpectedBehavior
```

---

### Test Structure (AAA Pattern)

**Arrange:**
- Set up test data
- Create objects
- Prepare dependencies

**Act:**
- Execute the code being tested
- Call the method

**Assert:**
- Verify the result
- Check expected outcome

**Example:**
```csharp
[Fact]
public void GetUser_ShouldReturnUser_WhenUserExists()
{
    // Arrange
    var userId = 1;
    var expectedUser = new User { Id = 1, Name = "John" };
    var repository = new UserRepository();
    repository.Add(expectedUser);
    
    // Act
    var result = repository.GetUser(userId);
    
    // Assert
    Assert.NotNull(result);
    Assert.Equal(expectedUser.Id, result.Id);
    Assert.Equal(expectedUser.Name, result.Name);
}
```

---

### Mocking Frameworks (Moq)

**Purpose**: Create fake objects (mocks) to isolate code under test

**Install:**
```bash
dotnet add package Moq
```

**Basic Mocking:**
```csharp
// Create mock
var mockRepository = new Mock<IUserRepository>();

// Setup return value
mockRepository.Setup(r => r.GetUser(1))
    .Returns(new User { Id = 1, Name = "John" });

// Verify calls
mockRepository.Verify(r => r.GetUser(1), Times.Once);
```

**Example:**
```csharp
public class UserServiceTests
{
    [Fact]
    public void GetUser_ShouldReturnUser_WhenExists()
    {
        // Arrange
        var mockRepository = new Mock<IUserRepository>();
        var expectedUser = new User { Id = 1, Name = "John" };
        
        mockRepository.Setup(r => r.GetUser(1))
            .Returns(expectedUser);
        
        var service = new UserService(mockRepository.Object);
        
        // Act
        var result = service.GetUser(1);
        
        // Assert
        Assert.Equal(expectedUser, result);
        mockRepository.Verify(r => r.GetUser(1), Times.Once);
    }
}
```

**Common Moq Methods:**
```csharp
// Setup return value
mock.Setup(x => x.Method()).Returns(value);

// Setup for any parameter
mock.Setup(x => x.Method(It.IsAny<int>())).Returns(value);

// Setup with condition
mock.Setup(x => x.Method(It.Is<int>(i => i > 0))).Returns(value);

// Setup async method
mock.Setup(x => x.MethodAsync()).ReturnsAsync(value);

// Setup to throw exception
mock.Setup(x => x.Method()).Throws<Exception>();

// Verify method was called
mock.Verify(x => x.Method(), Times.Once);
mock.Verify(x => x.Method(), Times.Never);
```

---

### Test-Driven Development (TDD)

**Process:**
1. **Red**: Write failing test
2. **Green**: Write minimal code to pass
3. **Refactor**: Improve code while keeping tests green

**Benefits:**
- Better design (testable code)
- Comprehensive test coverage
- Confidence in refactoring
- Documentation through tests

**Example:**
```csharp
// 1. Write failing test
[Fact]
public void IsValidEmail_ShouldReturnTrue_WhenEmailIsValid()
{
    var validator = new EmailValidator();
    var result = validator.IsValidEmail("test@example.com");
    Assert.True(result);
}

// 2. Write minimal code
public class EmailValidator
{
    public bool IsValidEmail(string email)
    {
        return email.Contains("@");
    }
}

// 3. Refactor and add more tests
[Fact]
public void IsValidEmail_ShouldReturnFalse_WhenEmailIsInvalid()
{
    var validator = new EmailValidator();
    Assert.False(validator.IsValidEmail("invalid"));
}
```

---

### Code Coverage

**Definition**: Percentage of code executed by tests

**Tools:**
- Visual Studio Code Coverage
- Coverlet (cross-platform)
- dotCover

**Measuring Coverage:**
```bash
# Install Coverlet
dotnet add package coverlet.msbuild

# Run tests with coverage
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
```

**Coverage Metrics:**
- **Line Coverage**: Lines executed
- **Branch Coverage**: Branches (if/else) executed
- **Method Coverage**: Methods called

**Target Coverage:**
- Aim for 80%+ coverage
- Focus on critical business logic
- Don't obsess over 100% (hard to achieve)

**What to Test:**
- Business logic
- Edge cases
- Error handling
- Complex algorithms

**What Not to Test:**
- Simple getters/setters
- Framework code
- Third-party libraries
- Trivial code

---

## 2. Integration Testing

### Testing ASP.NET Core Applications

**Purpose**: Test application components working together

**Test Server:**
```csharp
public class IntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    
    public IntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }
    
    [Fact]
    public async Task GetUsers_ShouldReturnUsers()
    {
        // Arrange
        var client = _factory.CreateClient();
        
        // Act
        var response = await client.GetAsync("/api/users");
        
        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var users = JsonSerializer.Deserialize<List<User>>(content);
        Assert.NotEmpty(users);
    }
}
```

**Customizing Test Server:**
```csharp
var factory = new WebApplicationFactory<Program>()
    .WithWebHostBuilder(builder =>
    {
        builder.ConfigureServices(services =>
        {
            // Replace services with test doubles
            services.RemoveAll(typeof(DbContextOptions<AppDbContext>));
            services.AddDbContext<AppDbContext>(options =>
            {
                options.UseInMemoryDatabase("TestDb");
            });
        });
    });
```

---

### Database Testing

**In-Memory Database:**
```csharp
services.AddDbContext<AppDbContext>(options =>
{
    options.UseInMemoryDatabase("TestDb");
});
```

**SQLite (In-Memory):**
```csharp
services.AddDbContext<AppDbContext>(options =>
{
    options.UseSqlite("DataSource=:memory:");
});
```

**Test Database:**
```csharp
public class DatabaseTests : IDisposable
{
    private readonly AppDbContext _context;
    
    public DatabaseTests()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        
        _context = new AppDbContext(options);
    }
    
    [Fact]
    public void AddUser_ShouldSaveToDatabase()
    {
        // Arrange
        var user = new User { Name = "John" };
        
        // Act
        _context.Users.Add(user);
        _context.SaveChanges();
        
        // Assert
        var savedUser = _context.Users.First();
        Assert.Equal("John", savedUser.Name);
    }
    
    public void Dispose()
    {
        _context.Dispose();
    }
}
```

---

### API Testing

**Testing Web API:**
```csharp
[Fact]
public async Task CreateUser_ShouldReturnCreatedUser()
{
    // Arrange
    var client = _factory.CreateClient();
    var newUser = new { Name = "John", Email = "john@example.com" };
    var content = new StringContent(
        JsonSerializer.Serialize(newUser),
        Encoding.UTF8,
        "application/json");
    
    // Act
    var response = await client.PostAsync("/api/users", content);
    
    // Assert
    response.EnsureSuccessStatusCode();
    Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    
    var responseContent = await response.Content.ReadAsStringAsync();
    var user = JsonSerializer.Deserialize<User>(responseContent);
    Assert.Equal("John", user.Name);
}
```

**Testing Authentication:**
```csharp
[Fact]
public async Task GetProtectedResource_ShouldRequireAuthentication()
{
    var client = _factory.CreateClient();
    var response = await client.GetAsync("/api/protected");
    Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
}

[Fact]
public async Task GetProtectedResource_ShouldSucceed_WhenAuthenticated()
{
    var client = _factory.CreateClient();
    client.DefaultRequestHeaders.Authorization = 
        new AuthenticationHeaderValue("Bearer", "test-token");
    
    var response = await client.GetAsync("/api/protected");
    response.EnsureSuccessStatusCode();
}
```

---

## Best Practices

### Test Organization

**Structure:**
```
Tests/
  UnitTests/
    Services/
      UserServiceTests.cs
    Controllers/
      UsersControllerTests.cs
  IntegrationTests/
    ApiTests.cs
    DatabaseTests.cs
```

**Naming:**
- Test class: `[ClassUnderTest]Tests`
- Test method: `MethodName_Scenario_ExpectedBehavior`

### Test Independence

- Tests should not depend on each other
- Each test should be able to run in isolation
- Use setup/teardown for common initialization

### Test Data

- Use realistic test data
- Avoid magic numbers (use constants)
- Consider using builders for complex objects

```csharp
public class UserBuilder
{
    private string _name = "Default Name";
    private string _email = "default@example.com";
    
    public UserBuilder WithName(string name)
    {
        _name = name;
        return this;
    }
    
    public User Build()
    {
        return new User { Name = _name, Email = _email };
    }
}

// Usage
var user = new UserBuilder()
    .WithName("John")
    .Build();
```

---

## Interview Questions to Prepare

1. **What is unit testing? What are its benefits?**
2. **Explain the AAA pattern (Arrange, Act, Assert).**
3. **What is mocking? When would you use it?**
4. **What is Test-Driven Development (TDD)?**
5. **What is code coverage? What's a good target?**
6. **What is the difference between unit tests and integration tests?**
7. **How do you test an ASP.NET Core Web API?**
8. **How do you test database operations?**
9. **What testing frameworks are available for .NET?**
10. **How do you handle dependencies in unit tests?**

