# Hexaware Interview Questions - Answers

## 1) What's delegate and why need it?

**Answer:**

A **delegate** in C# is a type-safe function pointer that holds references to methods with a specific signature. It's similar to function pointers in C/C++ but type-safe.

### Key Points:
- **Type-safe**: Ensures the method signature matches the delegate signature
- **Can hold multiple methods**: Multicast delegates can invoke multiple methods
- **Used for callbacks**: Enables passing methods as parameters
- **Event handling**: Foundation for events in C#

### Why we need delegates:
1. **Callback mechanism**: Pass methods as parameters to other methods
2. **Event-driven programming**: Foundation for events
3. **Decoupling**: Allows loose coupling between components
4. **Flexibility**: Can change method behavior at runtime
5. **LINQ**: Used extensively in LINQ operations

### Example:
```csharp
// Define delegate
public delegate void Notify(string message);

// Use delegate
public class Publisher
{
    public Notify OnNotify;
    
    public void DoSomething()
    {
        OnNotify?.Invoke("Task completed");
    }
}

// Usage
var pub = new Publisher();
pub.OnNotify = (msg) => Console.WriteLine(msg);
pub.DoSomething();
```

---

## 2) Abstract class have constructor? If yes then you cannot create an instance of an abstract class, then how the constructor will call?

**Answer:**

**Yes, abstract classes can have constructors**, even though you cannot directly instantiate an abstract class.

### How it works:
1. **Called by derived classes**: When a derived class is instantiated, the abstract class constructor is called automatically
2. **Initialization**: Used to initialize fields/properties defined in the abstract class
3. **Constructor chaining**: Part of the constructor chain when creating derived class instances

### Example:
```csharp
public abstract class Animal
{
    protected string Name;
    
    // Abstract class constructor
    public Animal(string name)
    {
        Name = name;
        Console.WriteLine($"Animal constructor called: {Name}");
    }
    
    public abstract void MakeSound();
}

public class Dog : Animal
{
    public Dog(string name) : base(name) // Calls abstract class constructor
    {
        Console.WriteLine($"Dog constructor called: {Name}");
    }
    
    public override void MakeSound()
    {
        Console.WriteLine($"{Name} barks");
    }
}

// Usage
var dog = new Dog("Buddy");
// Output:
// Animal constructor called: Buddy
// Dog constructor called: Buddy
```

### Why it's needed:
- Initialize base class fields/properties
- Set up common state for all derived classes
- Enforce initialization requirements

---

## 3) LINQ is a lazy loading?

**Answer:**

**Yes, LINQ uses deferred execution (lazy evaluation)**, but not all LINQ operations are lazy.

### Lazy Evaluation (Deferred Execution):
- **Query is not executed** until the result is enumerated
- Query definition doesn't execute immediately
- Execution happens when you iterate (foreach, ToList(), etc.)

### Example:
```csharp
var numbers = new List<int> { 1, 2, 3, 4, 5 };

// This doesn't execute yet - lazy
var query = numbers.Where(n => n > 2).Select(n => n * 2);

// Execution happens here
foreach (var item in query)
{
    Console.WriteLine(item); // 6, 8, 10
}

// Or with ToList() - forces immediate execution
var result = query.ToList(); // Executes here
```

### Eager Evaluation (Immediate Execution):
Some LINQ methods execute immediately:
- `ToList()`, `ToArray()`, `ToDictionary()`
- `Count()`, `First()`, `Last()`, `Single()`
- `Max()`, `Min()`, `Sum()`, `Average()`

### Benefits of Lazy Loading:
- **Performance**: Only processes data when needed
- **Efficiency**: Can optimize queries before execution
- **Flexibility**: Can modify query before execution

---

## 4) What's the FirstOrDefault and SingleOrDefault? How it works? LINQ

**Answer:**

Both are LINQ methods to retrieve a single element, but with different behaviors:

### FirstOrDefault():
- Returns the **first element** that matches the condition
- Returns **default value** (null for reference types, 0 for int, etc.) if no match found
- **No exception** if multiple matches exist - just returns the first one
- **No exception** if no matches - returns default

### SingleOrDefault():
- Returns the **single element** that matches the condition
- Returns **default value** if no match found
- **Throws InvalidOperationException** if multiple matches exist
- **No exception** if no matches - returns default

### Example:
```csharp
var numbers = new List<int> { 1, 2, 3, 4, 5, 2 };

// FirstOrDefault - returns first match, no exception for multiple
var first = numbers.FirstOrDefault(x => x == 2); // Returns 2 (first occurrence)
var firstNotFound = numbers.FirstOrDefault(x => x == 10); // Returns 0 (default)

// SingleOrDefault - throws exception if multiple matches
var single = numbers.SingleOrDefault(x => x == 3); // Returns 3 (only one)
var singleNotFound = numbers.SingleOrDefault(x => x == 10); // Returns 0 (default)
// var singleMultiple = numbers.SingleOrDefault(x => x == 2); // Throws InvalidOperationException
```

### When to use:
- **FirstOrDefault**: When you want the first match and don't care if there are more
- **SingleOrDefault**: When you expect exactly 0 or 1 match and want to ensure uniqueness

---

## 5) Background services in .NET Core? How it works

**Answer:**

**Background services** in .NET Core are long-running services that execute independently of HTTP requests.

### Key Points:
- **Long-running tasks**: Execute continuously in the background
- **Independent of requests**: Not tied to HTTP request lifecycle
- **Hosted services**: Run as part of the application host
- **Lifecycle management**: Automatically started/stopped with the application

### How it works:
1. Implement `IHostedService` or inherit from `BackgroundService`
2. Register in dependency injection
3. ASP.NET Core host manages the lifecycle
4. Starts when application starts
5. Stops gracefully when application shuts down

### Example:
```csharp
public class MyBackgroundService : BackgroundService
{
    private readonly ILogger<MyBackgroundService> _logger;
    
    public MyBackgroundService(ILogger<MyBackgroundService> logger)
    {
        _logger = logger;
    }
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            _logger.LogInformation("Background service running at: {time}", DateTimeOffset.Now);
            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
        }
    }
}
```

### Use Cases:
- Scheduled tasks (cron jobs)
- Processing queues
- Cache refresh
- Health checks
- Data synchronization

---

## 6) How you worked with background services? How to register it?

**Answer:**

### Implementation Steps:

#### 1. Create Background Service:
```csharp
public class EmailNotificationService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<EmailNotificationService> _logger;
    
    public EmailNotificationService(
        IServiceProvider serviceProvider,
        ILogger<EmailNotificationService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using (var scope = _serviceProvider.CreateScope())
                {
                    var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();
                    await emailService.SendPendingEmails();
                }
                
                await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in email notification service");
                await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
            }
        }
    }
}
```

#### 2. Register in Program.cs or Startup.cs:
```csharp
// In Program.cs (.NET 6+)
builder.Services.AddHostedService<EmailNotificationService>();

// Or in Startup.cs (.NET 5 and earlier)
public void ConfigureServices(IServiceCollection services)
{
    services.AddHostedService<EmailNotificationService>();
}
```

#### 3. Alternative: Using IHostedService directly:
```csharp
public class MyHostedService : IHostedService
{
    public Task StartAsync(CancellationToken cancellationToken)
    {
        // Start logic
        return Task.CompletedTask;
    }
    
    public Task StopAsync(CancellationToken cancellationToken)
    {
        // Cleanup logic
        return Task.CompletedTask;
    }
}
```

### Registration:
```csharp
builder.Services.AddHostedService<MyHostedService>();
```

---

## 7) Transient Scope and Singleton in service register? Explain

**Answer:**

These are **dependency injection lifetime scopes** in .NET Core that control when instances are created and how long they live.

### Transient:
- **New instance** created every time the service is requested
- **Shortest lifetime** - created and disposed per request
- **Use for**: Lightweight, stateless services
- **Thread-safe**: Each request gets its own instance

### Singleton:
- **Single instance** created once for the entire application lifetime
- **Longest lifetime** - lives for the entire application
- **Use for**: Expensive to create, stateless, shared resources
- **Thread-safety**: Must be thread-safe (shared across all requests)

### Example:
```csharp
// Transient - new instance every time
builder.Services.AddTransient<IUserService, UserService>();

// Singleton - one instance for entire app
builder.Services.AddSingleton<ICacheService, CacheService>();

// Scoped - one instance per HTTP request (not asked but important)
builder.Services.AddScoped<IDbContext, AppDbContext>();
```

### Comparison:

| Scope | Instance Created | Lifetime | Use Case |
|-------|-----------------|----------|----------|
| **Transient** | Every time requested | Per request | Lightweight services, utilities |
| **Scoped** | Once per HTTP request | Per request | DbContext, per-request services |
| **Singleton** | Once for app | Application lifetime | Caching, configuration, logging |

### Example Usage:
```csharp
public class MyController : ControllerBase
{
    private readonly ITransientService _transient; // New instance each time
    private readonly ISingletonService _singleton; // Same instance always
    
    public MyController(
        ITransientService transient,
        ISingletonService singleton)
    {
        _transient = transient;
        _singleton = singleton;
    }
}
```

### Important Notes:
- **Singleton must be thread-safe** (shared across all threads/requests)
- **Transient can cause performance issues** if service is expensive to create
- **Scoped** is the default for Entity Framework DbContext

---

## 8) Can we use POST to get data? At what scenario we can use?

**Answer:**

**Yes, technically you can use POST to get data**, though it's not RESTful best practice. However, there are valid scenarios where POST is used for data retrieval.

### When to use POST for getting data:

#### 1. **Complex Query Parameters**:
- When query string becomes too long (URL length limitations)
- Complex filtering/search criteria
- Multiple nested parameters

```csharp
[HttpPost("search")]
public IActionResult Search([FromBody] SearchRequest request)
{
    // Complex search with many filters
    var results = _service.Search(request);
    return Ok(results);
}
```

#### 2. **Sensitive Data**:
- When you don't want search criteria in URL (browser history, logs)
- Security/privacy concerns

```csharp
[HttpPost("secure-search")]
public IActionResult SecureSearch([FromBody] SecureSearchRequest request)
{
    // Search criteria not visible in URL
    return Ok(_service.Search(request));
}
```

#### 3. **GraphQL-like Queries**:
- When client specifies exactly what data to return
- Dynamic field selection

```csharp
[HttpPost("query")]
public IActionResult Query([FromBody] GraphQLQuery query)
{
    return Ok(_service.ExecuteQuery(query));
}
```

#### 4. **Bulk Operations**:
- When retrieving multiple records by IDs
- POST body contains array of IDs

```csharp
[HttpPost("bulk-get")]
public IActionResult BulkGet([FromBody] int[] ids)
{
    return Ok(_service.GetByIds(ids));
}
```

### RESTful Best Practice:
- **GET** for retrieving data (idempotent, cacheable)
- **POST** for creating resources or complex operations
- Use POST for "get" operations only when necessary

---

## 9) What are the parts of JWT token?

**Answer:**

A **JWT (JSON Web Token)** consists of **three parts** separated by dots (`.`):

### Structure: `header.payload.signature`

#### 1. **Header**:
- Contains token type and signing algorithm
- Base64Url encoded JSON

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

#### 2. **Payload** (Claims):
- Contains the actual data (claims)
- Base64Url encoded JSON
- Three types of claims:
  - **Registered claims**: Standard claims (iss, exp, sub, etc.)
  - **Public claims**: Custom claims (can be defined)
  - **Private claims**: Custom claims (agreed upon between parties)

```json
{
  "sub": "1234567890",
  "name": "John Doe",
  "email": "john@example.com",
  "iat": 1516239022,
  "exp": 1516242622,
  "role": "Admin"
}
```

#### 3. **Signature**:
- Used to verify token integrity
- Created using: `HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), secret)`

### Complete Example:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

### Parts Breakdown:
1. **Header**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`
2. **Payload**: `eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ`
3. **Signature**: `SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c`

### Common Claims:
- `iss` (issuer): Who issued the token
- `sub` (subject): User ID
- `aud` (audience): Who the token is intended for
- `exp` (expiration): Token expiration time
- `iat` (issued at): When token was issued
- `nbf` (not before): Token not valid before this time

---

## 10) Abstract design pattern? Have you worked?

**Answer:**

The **Abstract Factory Pattern** is a creational design pattern that provides an interface for creating families of related or dependent objects without specifying their concrete classes.

### Key Concepts:
- **Factory of factories**: Creates factories that create objects
- **Family of products**: Groups related products together
- **Interface-based**: Works with interfaces, not concrete classes
- **Encapsulation**: Hides object creation logic

### Structure:
```
AbstractFactory (interface)
    ├── ConcreteFactory1
    └── ConcreteFactory2

AbstractProductA (interface)
    ├── ProductA1
    └── ProductA2

AbstractProductB (interface)
    ├── ProductB1
    └── ProductB2
```

### Example:
```csharp
// Abstract Products
public interface IButton
{
    void Render();
}

public interface ITextBox
{
    void Render();
}

// Concrete Products - Windows
public class WindowsButton : IButton
{
    public void Render() => Console.WriteLine("Windows Button");
}

public class WindowsTextBox : ITextBox
{
    public void Render() => Console.WriteLine("Windows TextBox");
}

// Concrete Products - Mac
public class MacButton : IButton
{
    public void Render() => Console.WriteLine("Mac Button");
}

public class MacTextBox : ITextBox
{
    public void Render() => Console.WriteLine("Mac TextBox");
}

// Abstract Factory
public interface IUIFactory
{
    IButton CreateButton();
    ITextBox CreateTextBox();
}

// Concrete Factories
public class WindowsUIFactory : IUIFactory
{
    public IButton CreateButton() => new WindowsButton();
    public ITextBox CreateTextBox() => new WindowsTextBox();
}

public class MacUIFactory : IUIFactory
{
    public IButton CreateButton() => new MacButton();
    public ITextBox CreateTextBox() => new MacTextBox();
}

// Client
public class Application
{
    private readonly IUIFactory _factory;
    
    public Application(IUIFactory factory)
    {
        _factory = factory;
    }
    
    public void RenderUI()
    {
        var button = _factory.CreateButton();
        var textBox = _factory.CreateTextBox();
        
        button.Render();
        textBox.Render();
    }
}
```

### When to use:
- System needs to be independent of how products are created
- Need to support multiple families of products
- Products in a family are designed to work together
- Want to provide a library of products and reveal only interfaces

### Real-world usage:
- UI frameworks (Windows/Mac/Linux components)
- Database providers (SQL Server/Oracle/MySQL)
- Cross-platform development
- Plugin architectures

---

## 11) What's wrong with this registration? How will it work?

```csharp
builder.Services.AddTransient<IMessageService, EmailService>();
builder.Services.AddTransient<IMessageService, SmsService>();
```

**Answer:**

### The Problem:
When you register **multiple implementations** of the same interface, the **last registration wins**. The first registration (`EmailService`) is effectively **overwritten** by the second (`SmsService`).

### How it works:
- When `IMessageService` is injected, it will resolve to **`SmsService`** (the last one registered)
- `EmailService` registration is **ignored/overwritten**
- You **cannot inject both** - only one implementation is available

### Solutions:

#### 1. **Use Different Interfaces**:
```csharp
public interface IEmailService : IMessageService { }
public interface ISmsService : IMessageService { }

builder.Services.AddTransient<IEmailService, EmailService>();
builder.Services.AddTransient<ISmsService, SmsService>();
```

#### 2. **Use Factory Pattern**:
```csharp
builder.Services.AddTransient<EmailService>();
builder.Services.AddTransient<SmsService>();
builder.Services.AddTransient<Func<MessageType, IMessageService>>(sp => 
    type => type switch
    {
        MessageType.Email => sp.GetService<EmailService>(),
        MessageType.Sms => sp.GetService<SmsService>(),
        _ => throw new NotSupportedException()
    });
```

#### 3. **Use IEnumerable to Get All**:
```csharp
builder.Services.AddTransient<IMessageService, EmailService>();
builder.Services.AddTransient<IMessageService, SmsService>();

// Inject all implementations
public class NotificationService
{
    private readonly IEnumerable<IMessageService> _services;
    
    public NotificationService(IEnumerable<IMessageService> services)
    {
        _services = services; // Contains both EmailService and SmsService
    }
}
```

#### 4. **Use Named Registrations** (with third-party libraries):
```csharp
// Using Scrutor or similar library
builder.Services.AddTransient<EmailService>();
builder.Services.AddTransient<SmsService>();
builder.Services.AddTransient<IMessageService>(sp => 
    sp.GetService<EmailService>()); // Named or keyed
```

### Best Practice:
- Register only **one implementation per interface** for DI
- Use **factory pattern** or **strategy pattern** if you need multiple implementations
- Use **IEnumerable<T>** if you need all implementations

---

## 12) There are many middlewares, if one failed next one will execute? If not how we can handle?

**Answer:**

**No, by default if a middleware throws an exception, subsequent middlewares in the pipeline will NOT execute.** The exception propagates up and stops the pipeline.

### Default Behavior:
- Exception in middleware **stops the pipeline**
- Subsequent middlewares **don't execute**
- Exception bubbles up to the host
- Request fails with error response

### How to Handle:

#### 1. **Try-Catch in Middleware**:
```csharp
public class MyMiddleware
{
    private readonly RequestDelegate _next;
    
    public MyMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            // Handle exception, but continue pipeline
            context.Response.StatusCode = 500;
            await context.Response.WriteAsync("Error occurred");
            // Don't rethrow if you want to continue
        }
    }
}
```

#### 2. **Exception Handling Middleware** (Recommended):
```csharp
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;
    
    public ExceptionHandlingMiddleware(
        RequestDelegate next,
        ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An error occurred");
            await HandleExceptionAsync(context, ex);
        }
    }
    
    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = 500;
        
        return context.Response.WriteAsync(new ErrorDetails
        {
            StatusCode = 500,
            Message = "Internal Server Error"
        }.ToString());
    }
}
```

#### 3. **Built-in Exception Middleware**:
```csharp
// In Program.cs or Startup.cs
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/Error");
}

// Or with custom handler
app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        context.Response.StatusCode = 500;
        await context.Response.WriteAsync("An error occurred");
    });
});
```

#### 4. **Middleware Order Matters**:
```csharp
// Exception handling should be early in pipeline
app.UseExceptionHandler(); // First
app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.UseMiddleware<MyMiddleware>(); // Your custom middleware
app.MapControllers();
```

### Best Practices:
1. **Place exception middleware early** in the pipeline
2. **Log exceptions** before handling
3. **Don't swallow exceptions** unless you have a good reason
4. **Use built-in exception middleware** for standard scenarios
5. **Return appropriate HTTP status codes**

### To Continue Pipeline After Error:
If you want subsequent middlewares to execute even after an error:
- Catch the exception in your middleware
- Set error response
- **Don't rethrow** the exception
- Call `await _next(context)` in finally block or after handling

---

## 13) What's Azure Functions? Have you working? When we go for it?

**Answer:**

**Azure Functions** is a serverless compute service that allows you to run code on-demand without managing infrastructure.

### Key Features:
- **Serverless**: No server management
- **Event-driven**: Triggered by events (HTTP, queue, timer, etc.)
- **Pay-per-use**: Only pay for execution time
- **Auto-scaling**: Automatically scales based on demand
- **Multiple languages**: C#, JavaScript, Python, Java, etc.

### How it works:
1. Write function code
2. Define trigger (HTTP, Timer, Queue, etc.)
3. Deploy to Azure
4. Function executes when trigger fires
5. Azure manages infrastructure automatically

### Example:
```csharp
[FunctionName("HttpTriggerFunction")]
public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] 
    HttpRequest req,
    ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");
    
    string name = req.Query["name"];
    
    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    dynamic data = JsonConvert.DeserializeObject(requestBody);
    name = name ?? data?.name;
    
    return name != null
        ? (ActionResult)new OkObjectResult($"Hello, {name}")
        : new BadRequestObjectResult("Please pass a name");
}
```

### When to use Azure Functions:

#### 1. **Event-Driven Tasks**:
- Process messages from queues (Service Bus, Storage Queue)
- React to blob storage events
- Handle database changes (Cosmos DB triggers)

#### 2. **Scheduled Tasks**:
- Cron jobs, scheduled maintenance
- Data cleanup, reports generation

#### 3. **API Endpoints**:
- Microservices
- Webhooks
- REST APIs

#### 4. **Lightweight Processing**:
- Image processing
- File conversion
- Data transformation

#### 5. **Integration**:
- Connect different services
- Workflow automation
- Event processing

### When NOT to use:
- **Long-running processes** (15+ minutes timeout)
- **CPU-intensive tasks** (better with VMs or App Service)
- **Stateful applications** (stateless by design)
- **Complex applications** (better with App Service or Container Apps)

### Triggers:
- **HTTP**: REST API endpoints
- **Timer**: Scheduled execution (cron)
- **Queue**: Azure Storage Queue, Service Bus
- **Blob**: Blob storage events
- **Cosmos DB**: Database change feed
- **Event Hub**: Event streaming
- **Event Grid**: Event routing

### Pricing:
- **Consumption Plan**: Pay per execution (free tier available)
- **Premium Plan**: Pre-warmed instances, VNet integration
- **Dedicated Plan**: App Service Plan hosting

---

## 14) Have you worked with deployments?

**Answer:**

Yes, I have worked with various deployment strategies and platforms. Here are common deployment approaches:

### Deployment Methods:

#### 1. **Azure App Service Deployment**:
```bash
# Using Azure CLI
az webapp up --name myapp --resource-group mygroup

# Using Visual Studio
# Right-click project -> Publish -> Azure App Service

# Using GitHub Actions
- name: Deploy to Azure
  uses: azure/webapps-deploy@v2
  with:
    app-name: 'myapp'
    publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
```

#### 2. **Docker Container Deployment**:
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY . .
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

```bash
# Build and push to Azure Container Registry
docker build -t myapp .
docker tag myapp myregistry.azurecr.io/myapp:latest
docker push myregistry.azurecr.io/myapp:latest

# Deploy to Azure Container Instances or AKS
az container create --resource-group mygroup --name myapp --image myregistry.azurecr.io/myapp:latest
```

#### 3. **CI/CD Pipelines**:

**Azure DevOps**:
```yaml
trigger:
- main

pool:
  vmImage: 'windows-latest'

steps:
- task: DotNetCoreCLI@2
  inputs:
    command: 'publish'
    publishWebProjects: true

- task: AzureWebApp@1
  inputs:
    azureSubscription: 'my-subscription'
    appName: 'myapp'
    package: '$(System.DefaultWorkingDirectory)/**/*.zip'
```

**GitHub Actions**:
```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Setup .NET
      uses: actions/setup-dotnet@v1
    - name: Publish
      run: dotnet publish -c Release
    - name: Deploy
      uses: azure/webapps-deploy@v2
      with:
        app-name: 'myapp'
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
```

#### 4. **Deployment Slots** (Blue-Green Deployment):
```bash
# Create staging slot
az webapp deployment slot create --name myapp --resource-group mygroup --slot staging

# Deploy to staging
az webapp deployment source config --name myapp --resource-group mygroup --slot staging --repo-url https://github.com/user/repo

# Swap slots
az webapp deployment slot swap --name myapp --resource-group mygroup --slot staging --target-slot production
```

#### 5. **Kubernetes Deployment**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myregistry.azurecr.io/myapp:latest
        ports:
        - containerPort: 80
```

### Deployment Strategies:
- **Blue-Green**: Zero-downtime deployment using slots
- **Rolling Update**: Gradually update instances
- **Canary**: Deploy to small subset first
- **Feature Flags**: Control feature rollout

### Configuration Management:
- **App Settings**: Environment-specific configuration
- **Key Vault**: Secrets management
- **Configuration Files**: appsettings.json per environment

---

## 15) If a request is failed? How to can re-try it? Without returning failed response.

**Answer:**

There are several ways to implement retry logic without returning a failed response to the client:

### 1. **Polly Retry Policy** (Recommended):

```csharp
// Install: Microsoft.Extensions.Http.Polly

// In Program.cs
builder.Services.AddHttpClient<IMyService, MyService>()
    .AddPolicyHandler(GetRetryPolicy());

static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .OrResult(msg => msg.StatusCode == System.Net.HttpStatusCode.TooManyRequests)
        .WaitAndRetryAsync(
            retryCount: 3,
            sleepDurationProvider: retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
            onRetry: (outcome, timespan, retryCount, context) =>
            {
                Console.WriteLine($"Retry {retryCount} after {timespan}");
            });
}
```

### 2. **Custom Retry Middleware**:

```csharp
public class RetryMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RetryMiddleware> _logger;
    
    public RetryMiddleware(RequestDelegate next, ILogger<RetryMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        int maxRetries = 3;
        int retryCount = 0;
        
        while (retryCount < maxRetries)
        {
            try
            {
                await _next(context);
                
                // If successful, break out of retry loop
                if (context.Response.StatusCode < 500)
                {
                    break;
                }
            }
            catch (Exception ex)
            {
                retryCount++;
                _logger.LogWarning(ex, $"Request failed. Retry {retryCount}/{maxRetries}");
                
                if (retryCount >= maxRetries)
                {
                    // After all retries, return error or queue for later
                    context.Response.StatusCode = 500;
                    await context.Response.WriteAsync("Service temporarily unavailable");
                    return;
                }
                
                // Exponential backoff
                await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, retryCount)));
            }
        }
    }
}
```

### 3. **Queue-Based Retry** (Best for Background Processing):

```csharp
public class RetryableService
{
    private readonly IMessageQueue _queue;
    
    public async Task ProcessRequestAsync(Request request)
    {
        try
        {
            await ProcessRequest(request);
        }
        catch (Exception ex)
        {
            // Queue for retry instead of failing
            await _queue.EnqueueAsync(new RetryRequest
            {
                Request = request,
                RetryCount = 0,
                MaxRetries = 3
            });
            
            // Return success to client (request queued)
            return new Response { Status = "Queued", MessageId = Guid.NewGuid() };
        }
    }
    
    // Background processor
    public async Task ProcessRetryQueueAsync()
    {
        var retryRequest = await _queue.DequeueAsync<RetryRequest>();
        
        try
        {
            await ProcessRequest(retryRequest.Request);
        }
        catch (Exception ex)
        {
            retryRequest.RetryCount++;
            
            if (retryRequest.RetryCount < retryRequest.MaxRetries)
            {
                // Re-queue with delay
                await _queue.EnqueueAsync(retryRequest, delay: TimeSpan.FromMinutes(5));
            }
            else
            {
                // Send to dead letter queue
                await _deadLetterQueue.EnqueueAsync(retryRequest);
            }
        }
    }
}
```

### 4. **Circuit Breaker Pattern**:

```csharp
// Using Polly
var circuitBreakerPolicy = Policy
    .Handle<HttpRequestException>()
    .CircuitBreakerAsync(
        handledEventsAllowedBeforeBreaking: 5,
        durationOfBreak: TimeSpan.FromSeconds(30)
    );

// Wrap your call
await circuitBreakerPolicy.ExecuteAsync(async () =>
{
    await MakeHttpRequest();
});
```

### 5. **Background Job with Hangfire**:

```csharp
// Install: Hangfire

// In Program.cs
builder.Services.AddHangfire(config => config
    .UseSqlServerStorage(connectionString));
builder.Services.AddHangfireServer();

// In controller
public async Task<IActionResult> ProcessRequest([FromBody] Request request)
{
    // Queue job for background processing with retry
    BackgroundJob.Enqueue(() => ProcessWithRetry(request));
    
    // Return immediately to client
    return Accepted(new { JobId = BackgroundJob.LastBackgroundJobId });
}

// Job with automatic retry
[AutomaticRetry(Attempts = 3, DelaysInSeconds = new[] { 10, 30, 60 })]
public async Task ProcessWithRetry(Request request)
{
    await ProcessRequest(request);
}
```

### 6. **Response Caching with Retry**:

```csharp
public class RetryableController : ControllerBase
{
    [HttpPost("process")]
    public async Task<IActionResult> Process([FromBody] Request request)
    {
        // Try to process
        try
        {
            var result = await _service.ProcessAsync(request);
            return Ok(result);
        }
        catch (Exception ex)
        {
            // Queue for background retry
            _backgroundJobClient.Enqueue(() => RetryProcess(request));
            
            // Return accepted (202) - request is being processed
            return Accepted(new 
            { 
                Message = "Request queued for processing",
                RequestId = request.Id
            });
        }
    }
}
```

### Best Practices:
1. **Exponential backoff**: Increase delay between retries
2. **Max retry limit**: Prevent infinite retries
3. **Idempotency**: Ensure retries are safe (same request multiple times)
4. **Logging**: Log all retry attempts
5. **Dead letter queue**: Handle permanently failed requests
6. **Circuit breaker**: Stop retrying if service is down
7. **Return 202 Accepted**: For async processing scenarios

### When to use each approach:
- **Polly**: For HTTP calls, external API calls
- **Queue-based**: For long-running or critical operations
- **Hangfire**: For scheduled/background jobs
- **Middleware**: For application-wide retry logic
- **Circuit Breaker**: When service might be down

