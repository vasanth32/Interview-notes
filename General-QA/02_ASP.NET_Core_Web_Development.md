# ASP.NET Core Web Development - Interview Guide

## 1. ASP.NET Core Fundamentals

### Middleware Pipeline
- Request flows through middleware in order
- Each middleware can process request/response
- Order matters!

```csharp
public void Configure(IApplicationBuilder app)
{
    app.UseExceptionHandler();      // 1. Handle exceptions
    app.UseHttpsRedirection();      // 2. Redirect HTTP to HTTPS
    app.UseStaticFiles();           // 3. Serve static files
    app.UseRouting();               // 4. Enable routing
    app.UseAuthentication();        // 5. Authentication
    app.UseAuthorization();         // 6. Authorization
    app.UseEndpoints();             // 7. Map endpoints
}
```

### Request/Response Lifecycle
1. HTTP Request arrives
2. Middleware processes (in order)
3. Routing matches URL to controller/action
4. Model binding
5. Action execution
6. Response generation
7. Middleware processes response (reverse order)

### Dependency Injection Container
- Built-in IoC container
- Service lifetimes:
  - **Singleton**: One instance for entire app lifetime
  - **Scoped**: One instance per HTTP request
  - **Transient**: New instance every time

```csharp
// Startup.cs or Program.cs
services.AddSingleton<ICacheService, CacheService>();
services.AddScoped<IUserService, UserService>();
services.AddTransient<IEmailService, EmailService>();
```

---

## 2. Configuration

### appsettings.json
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=..."
  },
  "Logging": {
    "LogLevel": "Default": "Information"
  },
  "AppSettings": {
    "ApiKey": "value"
  }
}
```

### Accessing Configuration
```csharp
// In Startup.cs
var apiKey = Configuration["AppSettings:ApiKey"];

// Inject IConfiguration
public class MyService
{
    private readonly IConfiguration _config;
    public MyService(IConfiguration config)
    {
        _config = config;
    }
}
```

### Options Pattern (Recommended)
```csharp
// appsettings.json
{
  "EmailSettings": {
    "SmtpServer": "smtp.example.com",
    "Port": 587
  }
}

// Class
public class EmailSettings
{
    public string SmtpServer { get; set; }
    public int Port { get; set; }
}

// Register
services.Configure<EmailSettings>(
    Configuration.GetSection("EmailSettings"));

// Use
public class EmailService
{
    private readonly EmailSettings _settings;
    public EmailService(IOptions<EmailSettings> options)
    {
        _settings = options.Value;
    }
}
```

---

## 3. MVC Pattern

### Controllers
- Handle HTTP requests
- Return views or data
- Convention: `[ControllerName]Controller.cs`

```csharp
public class HomeController : Controller
{
    public IActionResult Index()
    {
        return View();  // Returns view
    }
    
    public IActionResult GetData()
    {
        return Json(new { data = "value" });  // Returns JSON
    }
}
```

### Actions
- Public methods in controllers
- Return `IActionResult` or `ActionResult<T>`
- Can be synchronous or asynchronous

### Model Binding
- Automatically maps HTTP request data to action parameters
- Sources: Route data, Query string, Form data, Request body

```csharp
// GET /users/123?name=John
public IActionResult GetUser(int id, string name)
{
    // id = 123, name = "John" (automatic binding)
}
```

### Validation
```csharp
public class UserModel
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(50)]
    public string Name { get; set; }
    
    [EmailAddress]
    public string Email { get; set; }
    
    [Range(18, 100)]
    public int Age { get; set; }
}

[HttpPost]
public IActionResult Create(UserModel model)
{
    if (!ModelState.IsValid)
    {
        return View(model);  // Return with errors
    }
    // Process valid model
}
```

---

## 4. Routing

### Conventional Routing
```csharp
app.UseEndpoints(endpoints =>
{
    endpoints.MapControllerRoute(
        name: "default",
        pattern: "{controller=Home}/{action=Index}/{id?}");
});
// Matches: /Home/Index, /Users/Details/123
```

### Attribute Routing
```csharp
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    [HttpGet("{id}")]
    public IActionResult Get(int id) { }
    
    [HttpPost("create")]
    public IActionResult Create([FromBody] User user) { }
}
```

### Route Constraints
```csharp
[HttpGet("{id:int}")]  // Only integers
[HttpGet("{id:min(1)}")]  // Minimum value
[HttpGet("{name:alpha}")]  // Only letters
```

---

## 5. Web API

### RESTful Principles
- **GET**: Retrieve data (idempotent, safe)
- **POST**: Create new resource
- **PUT**: Update entire resource (idempotent)
- **PATCH**: Partial update
- **DELETE**: Remove resource (idempotent)

### Status Codes
- `200 OK` - Success
- `201 Created` - Resource created
- `204 No Content` - Success, no body
- `400 Bad Request` - Client error
- `401 Unauthorized` - Not authenticated
- `403 Forbidden` - Not authorized
- `404 Not Found`
- `500 Internal Server Error`

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    public ActionResult<IEnumerable<Product>> Get()
    {
        return Ok(products);
    }
    
    [HttpPost]
    public ActionResult<Product> Create(Product product)
    {
        // Create logic
        return CreatedAtAction(nameof(Get), 
            new { id = product.Id }, product);
    }
}
```

### Content Negotiation
- Client specifies Accept header: `application/json`, `application/xml`
- Server returns appropriate format
- Configure in `Startup.cs`: `services.AddControllers().AddXmlSerializerFormatters();`

---

## 6. Authentication & Authorization

### JWT Authentication
```csharp
services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = Configuration["Jwt:Issuer"],
            ValidAudience = Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(Configuration["Jwt:Key"]))
        };
    });
```

### Authorization Attributes
```csharp
[Authorize]  // Requires authentication
public class SecureController : Controller
{
    [Authorize(Roles = "Admin")]  // Requires Admin role
    public IActionResult AdminOnly() { }
    
    [AllowAnonymous]  // Skip authorization
    public IActionResult Public() { }
}
```

---

## 7. CORS Configuration

### Enable CORS
```csharp
// Startup.cs
services.AddCors(options =>
{
    options.AddPolicy("AllowSpecificOrigin",
        builder => builder.WithOrigins("https://example.com")
                         .AllowAnyMethod()
                         .AllowAnyHeader());
});

app.UseCors("AllowSpecificOrigin");
```

### Common Scenarios
- Allow all origins: `AllowAnyOrigin()`
- Allow specific methods: `WithMethods("GET", "POST")`
- Allow credentials: `AllowCredentials()`

---

## 8. Custom Middleware

```csharp
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;
    
    public RequestLoggingMiddleware(
        RequestDelegate next, 
        ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        _logger.LogInformation($"Request: {context.Request.Path}");
        
        await _next(context);  // Call next middleware
        
        _logger.LogInformation($"Response: {context.Response.StatusCode}");
    }
}

// Register
app.UseMiddleware<RequestLoggingMiddleware>();
```

---

## 9. Background Services

```csharp
public class EmailService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            // Do work
            await ProcessEmails();
            await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
        }
    }
}

// Register
services.AddHostedService<EmailService>();
```

---

## Interview Questions to Prepare

1. Explain the middleware pipeline. What happens if you change the order?
2. What are the differences between Singleton, Scoped, and Transient lifetimes?
3. How does model binding work? What are the binding sources?
4. Explain the difference between `[FromBody]`, `[FromQuery]`, and `[FromRoute]`.
5. What is the Options pattern? Why use it instead of IConfiguration?
6. How do you handle errors globally in ASP.NET Core?
7. Explain the difference between Authentication and Authorization.
8. What is CORS? How do you configure it?
9. How does routing work? Conventional vs Attribute routing?
10. What is the difference between `IActionResult` and `ActionResult<T>`?

