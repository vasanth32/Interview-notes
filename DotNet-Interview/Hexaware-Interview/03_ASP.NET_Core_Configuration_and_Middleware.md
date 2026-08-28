# ASP.NET Core Configuration & Middleware - Interview Questions & Answers

## 1. How do you fetch connection string from .NET Core?

### Answer

In .NET Core, connection strings are typically stored in `appsettings.json` and accessed through the **Configuration API** or **Options Pattern**.

### Method 1: Direct Configuration Access

#### Step 1: Store in appsettings.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MyDb;User Id=sa;Password=YourPassword;",
    "SecondaryConnection": "Server=server2;Database=MyDb2;Integrated Security=true;"
  }
}
```

#### Step 2: Access in Code

```csharp
public class Startup
{
    private readonly IConfiguration _configuration;
    
    public Startup(IConfiguration configuration)
    {
        _configuration = configuration;
    }
    
    public void ConfigureServices(IServiceCollection services)
    {
        // Method 1: Direct access
        var connectionString = _configuration.GetConnectionString("DefaultConnection");
        
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(connectionString));
    }
}
```

### Method 2: Using Options Pattern

```csharp
// Define options class
public class DatabaseOptions
{
    public string DefaultConnection { get; set; }
    public string SecondaryConnection { get; set; }
}

// In Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    // Bind configuration to options
    services.Configure<DatabaseOptions>(
        _configuration.GetSection("ConnectionStrings"));
    
    // Access via IOptions
    services.AddDbContext<ApplicationDbContext>((serviceProvider, options) =>
    {
        var dbOptions = serviceProvider.GetRequiredService<IOptions<DatabaseOptions>>();
        options.UseSqlServer(dbOptions.Value.DefaultConnection);
    });
}

// Usage in controller/service
public class ProductService
{
    private readonly DatabaseOptions _options;
    
    public ProductService(IOptions<DatabaseOptions> options)
    {
        _options = options.Value;
    }
    
    public void DoSomething()
    {
        var connectionString = _options.DefaultConnection;
    }
}
```

### Method 3: Using IConfiguration Directly

```csharp
public class MyService
{
    private readonly IConfiguration _configuration;
    
    public MyService(IConfiguration configuration)
    {
        _configuration = configuration;
    }
    
    public string GetConnectionString()
    {
        return _configuration.GetConnectionString("DefaultConnection");
        // Or
        return _configuration["ConnectionStrings:DefaultConnection"];
    }
}
```

### Method 4: Environment-Specific Configuration

```json
// appsettings.Development.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MyDb_Dev;..."
  }
}

// appsettings.Production.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=prod-server;Database=MyDb_Prod;..."
  }
}
```

.NET Core automatically loads the correct file based on `ASPNETCORE_ENVIRONMENT`.

### Method 5: From User Secrets (Development)

```bash
# Set user secret
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=localhost;..."
```

```csharp
// In Startup.cs (Development only)
if (Environment.IsDevelopment())
{
    builder.Configuration.AddUserSecrets<Program>();
}
```

### Method 6: From Environment Variables

```bash
# Set environment variable
export ConnectionStrings__DefaultConnection="Server=prod;Database=MyDb;..."
```

Environment variables override `appsettings.json values.

### Best Practice: Complete Example

```csharp
public class Startup
{
    public Startup(IConfiguration configuration, IWebHostEnvironment environment)
    {
        Configuration = configuration;
        Environment = environment;
    }
    
    public IConfiguration Configuration { get; }
    public IWebHostEnvironment Environment { get; }
    
    public void ConfigureServices(IServiceCollection services)
    {
        // Get connection string
        var connectionString = Configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string not found");
        
        // Register DbContext
        services.AddDbContext<ApplicationDbContext>(options =>
        {
            options.UseSqlServer(connectionString);
            
            // Enable sensitive data logging in development
            if (Environment.IsDevelopment())
            {
                options.EnableSensitiveDataLogging();
                options.LogTo(Console.WriteLine, LogLevel.Information);
            }
        });
    }
}
```

---

## 2. You need to configure your .NET Core application to use different connection strings for development, staging, and production environments. How do you achieve this?

### Answer

.NET Core provides multiple ways to handle environment-specific configuration. Here are the best approaches:

### Method 1: Environment-Specific appsettings Files (Recommended)

#### File Structure:

```
appsettings.json                 (Base configuration)
appsettings.Development.json    (Development overrides)
appsettings.Staging.json         (Staging overrides)
appsettings.Production.json      (Production overrides)
```

#### appsettings.json (Base):

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MyDb;..."
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information"
    }
  }
}
```

#### appsettings.Development.json:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MyDb_Dev;User Id=dev;Password=dev123;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Debug"
    }
  }
}
```

#### appsettings.Staging.json:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=staging-server;Database=MyDb_Staging;User Id=staging;Password=staging123;"
  }
}
```

#### appsettings.Production.json:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=prod-server;Database=MyDb_Prod;User Id=prod;Password=***;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Warning"
    }
  }
}
```

#### How It Works:

.NET Core automatically loads files in this order (later files override earlier ones):
1. `appsettings.json`
2. `appsettings.{Environment}.json`
3. Environment variables
4. Command-line arguments

### Method 2: Using Environment Variables

Set the environment variable to specify which environment:

```bash
# Windows PowerShell
$env:ASPNETCORE_ENVIRONMENT = "Production"

# Linux/Mac
export ASPNETCORE_ENVIRONMENT=Production

# In launchSettings.json (for local development)
{
  "profiles": {
    "Development": {
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

### Method 3: Azure App Service Configuration

In Azure Portal → App Service → Configuration:

```
ConnectionStrings__DefaultConnection = Server=prod;Database=MyDb;...
```

### Method 4: Using IWebHostEnvironment

```csharp
public class Startup
{
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _environment;
    
    public Startup(IConfiguration configuration, IWebHostEnvironment environment)
    {
        _configuration = configuration;
        _environment = environment;
    }
    
    public void ConfigureServices(IServiceCollection services)
    {
        string connectionString;
        
        if (_environment.IsDevelopment())
        {
            connectionString = _configuration.GetConnectionString("DefaultConnection")
                ?? "Server=localhost;Database=DevDb;...";
        }
        else if (_environment.IsStaging())
        {
            connectionString = _configuration.GetConnectionString("DefaultConnection")
                ?? "Server=staging;Database=StagingDb;...";
        }
        else // Production
        {
            connectionString = _configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Production connection string required");
        }
        
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(connectionString));
    }
}
```

### Method 5: Using Options Pattern with Environment-Specific Binding

```csharp
public class DatabaseSettings
{
    public string DevelopmentConnection { get; set; }
    public string StagingConnection { get; set; }
    public string ProductionConnection { get; set; }
}

// In Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
    var connectionStringKey = environment switch
    {
        "Development" => "DevelopmentConnection",
        "Staging" => "StagingConnection",
        "Production" => "ProductionConnection",
        _ => "DevelopmentConnection"
    };
    
    var settings = Configuration.GetSection("DatabaseSettings").Get<DatabaseSettings>();
    var connectionString = typeof(DatabaseSettings)
        .GetProperty(connectionStringKey)
        ?.GetValue(settings)?.ToString();
    
    services.AddDbContext<ApplicationDbContext>(options =>
        options.UseSqlServer(connectionString));
}
```

### Complete Example with All Methods:

```csharp
public class Program
{
    public static void Main(string[] args)
    {
        CreateHostBuilder(args).Build().Run();
    }
    
    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureAppConfiguration((context, config) =>
            {
                var env = context.HostingEnvironment;
                
                // Load base configuration
                config.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);
                
                // Load environment-specific configuration
                config.AddJsonFile($"appsettings.{env.EnvironmentName}.json", 
                    optional: true, reloadOnChange: true);
                
                // Load user secrets in development
                if (env.IsDevelopment())
                {
                    config.AddUserSecrets<Program>();
                }
                
                // Environment variables override everything
                config.AddEnvironmentVariables();
                
                // Command-line arguments override everything
                if (args != null)
                {
                    config.AddCommandLine(args);
                }
            })
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>();
            });
}
```

### Best Practices:

1. ✅ **Use environment-specific appsettings files** for most scenarios
2. ✅ **Never commit production secrets** to source control
3. ✅ **Use Azure Key Vault** or similar for production secrets
4. ✅ **Use User Secrets** for local development
5. ✅ **Set environment variables** in deployment pipelines
6. ✅ **Validate connection strings** at startup

---

## 3. What is Middleware?

### Answer

**Middleware** in ASP.NET Core is software components that are assembled into the application pipeline to handle requests and responses. Each middleware component can:
- Choose whether to pass the request to the next component
- Perform work before and after the next component
- Modify the request or response

### Middleware Pipeline:

```
Request → Middleware 1 → Middleware 2 → Middleware 3 → ... → Application → Response
```

### Built-in Middleware Examples:

```csharp
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    // Exception handling (should be first)
    if (env.IsDevelopment())
    {
        app.UseDeveloperExceptionPage();
    }
    else
    {
        app.UseExceptionHandler("/Error");
    }
    
    // HTTPS redirection
    app.UseHttpsRedirection();
    
    // Static files
    app.UseStaticFiles();
    
    // Routing
    app.UseRouting();
    
    // Authentication
    app.UseAuthentication();
    
    // Authorization
    app.UseAuthorization();
    
    // Endpoints
    app.UseEndpoints(endpoints =>
    {
        endpoints.MapControllers();
    });
}
```

### How Middleware Works:

1. **Request comes in** → First middleware receives it
2. **Middleware processes** → Can modify request, perform logging, etc.
3. **Calls next middleware** → Using `next()` delegate
4. **Response flows back** → Each middleware can modify response
5. **Response sent** → Back to client

---

## 4. How do you create custom middleware?

### Answer

You can create custom middleware using three approaches:

### Method 1: Inline Middleware (Simple)

```csharp
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    app.Use(async (context, next) =>
    {
        // Before next middleware
        var startTime = DateTime.UtcNow;
        
        // Call next middleware
        await next();
        
        // After next middleware
        var duration = DateTime.UtcNow - startTime;
        context.Response.Headers.Add("X-Response-Time", duration.TotalMilliseconds.ToString());
    });
    
    app.UseRouting();
    app.UseEndpoints(endpoints => endpoints.MapControllers());
}
```

### Method 2: Middleware Class (Recommended)

```csharp
// Custom middleware class
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;
    
    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        // Before next middleware
        var requestPath = context.Request.Path;
        var requestMethod = context.Request.Method;
        _logger.LogInformation($"Request: {requestMethod} {requestPath}");
        
        var startTime = DateTime.UtcNow;
        
        // Call next middleware
        await _next(context);
        
        // After next middleware
        var duration = DateTime.UtcNow - startTime;
        _logger.LogInformation($"Response: {requestMethod} {requestPath} - {duration.TotalMilliseconds}ms");
    }
}

// Extension method for easy registration
public static class RequestLoggingMiddlewareExtensions
{
    public static IApplicationBuilder UseRequestLogging(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RequestLoggingMiddleware>();
    }
}

// Usage in Startup.cs
public void Configure(IApplicationBuilder app)
{
    app.UseRequestLogging(); // Clean and readable
    app.UseRouting();
    app.UseEndpoints(endpoints => endpoints.MapControllers());
}
```

### Method 3: Middleware with Dependency Injection

```csharp
public class CustomHeaderMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IConfiguration _configuration;
    
    public CustomHeaderMiddleware(RequestDelegate next, IConfiguration configuration)
    {
        _next = next;
        _configuration = configuration;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        // Add custom header from configuration
        var appName = _configuration["AppSettings:ApplicationName"];
        context.Response.Headers.Add("X-Application-Name", appName);
        
        await _next(context);
    }
}

public static class CustomHeaderMiddlewareExtensions
{
    public static IApplicationBuilder UseCustomHeaders(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<CustomHeaderMiddleware>();
    }
}
```

### Real-World Example: API Key Authentication Middleware

```csharp
public class ApiKeyMiddleware
{
    private readonly RequestDelegate _next;
    private const string API_KEY_HEADER = "X-API-Key";
    
    public ApiKeyMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context, IConfiguration configuration)
    {
        // Skip authentication for certain paths
        if (context.Request.Path.StartsWithSegments("/health"))
        {
            await _next(context);
            return;
        }
        
        // Check for API key
        if (!context.Request.Headers.TryGetValue(API_KEY_HEADER, out var extractedApiKey))
        {
            context.Response.StatusCode = 401;
            await context.Response.WriteAsync("API Key was not provided");
            return;
        }
        
        // Validate API key
        var apiKey = configuration["ApiSettings:ApiKey"];
        if (!apiKey.Equals(extractedApiKey))
        {
            context.Response.StatusCode = 401;
            await context.Response.WriteAsync("Invalid API Key");
            return;
        }
        
        await _next(context);
    }
}
```

---

## 5. How do you pass value from one middleware to another?

### Answer

You can pass values between middleware using the **HttpContext.Items** dictionary or by setting values on the **HttpContext** itself.

### Method 1: Using HttpContext.Items (Recommended)

```csharp
// Middleware 1: Sets value
public class CorrelationIdMiddleware
{
    private readonly RequestDelegate _next;
    
    public CorrelationIdMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        // Generate or get correlation ID
        var correlationId = context.Request.Headers["X-Correlation-Id"].FirstOrDefault()
            ?? Guid.NewGuid().ToString();
        
        // Store in Items dictionary
        context.Items["CorrelationId"] = correlationId;
        
        // Add to response header
        context.Response.Headers.Add("X-Correlation-Id", correlationId);
        
        await _next(context);
    }
}

// Middleware 2: Reads value
public class LoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<LoggingMiddleware> _logger;
    
    public LoggingMiddleware(RequestDelegate next, ILogger<LoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        // Retrieve correlation ID from Items
        var correlationId = context.Items["CorrelationId"]?.ToString();
        
        _logger.LogInformation($"Request {correlationId}: {context.Request.Path}");
        
        await _next(context);
        
        _logger.LogInformation($"Response {correlationId}: {context.Response.StatusCode}");
    }
}

// Usage
public void Configure(IApplicationBuilder app)
{
    app.UseMiddleware<CorrelationIdMiddleware>();
    app.UseMiddleware<LoggingMiddleware>();
    app.UseRouting();
}
```

### Method 2: Using Extension Methods on HttpContext

```csharp
// Extension methods for type-safe access
public static class HttpContextExtensions
{
    private const string CorrelationIdKey = "CorrelationId";
    private const string UserIdKey = "UserId";
    
    public static void SetCorrelationId(this HttpContext context, string correlationId)
    {
        context.Items[CorrelationIdKey] = correlationId;
    }
    
    public static string GetCorrelationId(this HttpContext context)
    {
        return context.Items[CorrelationIdKey]?.ToString();
    }
    
    public static void SetUserId(this HttpContext context, string userId)
    {
        context.Items[UserIdKey] = userId;
    }
    
    public static string GetUserId(this HttpContext context)
    {
        return context.Items[UserIdKey]?.ToString();
    }
}

// Usage in middleware
public class AuthenticationMiddleware
{
    private readonly RequestDelegate _next;
    
    public AuthenticationMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        // Authenticate user and set user ID
        var userId = await AuthenticateUser(context);
        context.SetUserId(userId);
        
        await _next(context);
    }
    
    private async Task<string> AuthenticateUser(HttpContext context)
    {
        // Authentication logic
        return "user123";
    }
}

// Usage in controller
[ApiController]
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts()
    {
        var userId = HttpContext.GetUserId(); // Type-safe access
        var correlationId = HttpContext.GetCorrelationId();
        
        return Ok(new { UserId = userId, CorrelationId = correlationId });
    }
}
```

### Method 3: Using Custom Properties (Advanced)

```csharp
// Create custom feature
public interface IRequestContextFeature
{
    string CorrelationId { get; set; }
    string UserId { get; set; }
    DateTime RequestStartTime { get; set; }
}

public class RequestContextFeature : IRequestContextFeature
{
    public string CorrelationId { get; set; }
    public string UserId { get; set; }
    public DateTime RequestStartTime { get; set; }
}

// Middleware that sets feature
public class RequestContextMiddleware
{
    private readonly RequestDelegate _next;
    
    public RequestContextMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        var feature = new RequestContextFeature
        {
            CorrelationId = Guid.NewGuid().ToString(),
            RequestStartTime = DateTime.UtcNow
        };
        
        context.Features.Set<IRequestContextFeature>(feature);
        
        await _next(context);
    }
}

// Access in other middleware or controller
public class SomeMiddleware
{
    private readonly RequestDelegate _next;
    
    public SomeMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        var feature = context.Features.Get<IRequestContextFeature>();
        var correlationId = feature?.CorrelationId;
        
        await _next(context);
    }
}
```

### Complete Example: Request Context Pipeline

```csharp
// 1. Set correlation ID
app.UseMiddleware<CorrelationIdMiddleware>();

// 2. Authenticate and set user
app.UseAuthentication();
app.Use(async (context, next) =>
{
    if (context.User.Identity.IsAuthenticated)
    {
        context.Items["UserId"] = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    }
    await next();
});

// 3. Logging middleware uses both values
app.UseMiddleware<LoggingMiddleware>();

// 4. Controller can access all values
[ApiController]
public class OrdersController : ControllerBase
{
    [HttpPost]
    public IActionResult CreateOrder(OrderDto order)
    {
        var correlationId = HttpContext.Items["CorrelationId"]?.ToString();
        var userId = HttpContext.Items["UserId"]?.ToString();
        
        // Use values for logging, tracking, etc.
        return Ok(new { OrderId = 123, CorrelationId = correlationId });
    }
}
```

### Best Practices:

1. ✅ **Use HttpContext.Items** for simple value passing
2. ✅ **Create extension methods** for type-safe access
3. ✅ **Use Features** for complex, structured data
4. ✅ **Document what values** each middleware sets/expects
5. ✅ **Use consistent naming** conventions for keys

---

## Summary

- **Connection Strings**: Use `IConfiguration.GetConnectionString()`, environment-specific appsettings files, or Options pattern
- **Environment Configuration**: Use `appsettings.{Environment}.json` files with `ASPNETCORE_ENVIRONMENT` variable
- **Middleware**: Components in the request pipeline that can process requests/responses
- **Custom Middleware**: Create classes implementing `RequestDelegate` with `InvokeAsync` method
- **Passing Values**: Use `HttpContext.Items` dictionary or extension methods for type-safe access

