# Web API Security & Advanced - Interview Questions & Answers

## 1. How do you secure your Web API?

### Answer

Securing a Web API involves multiple layers of protection. Here are the key strategies:

### 1. Authentication & Authorization

```csharp
[Authorize] // Require authentication
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    [AllowAnonymous] // Public endpoint
    public IActionResult GetPublicProducts()
    {
        return Ok();
    }
    
    [HttpPost]
    [Authorize] // Require authentication
    public IActionResult CreateProduct(Product product)
    {
        return Ok();
    }
    
    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")] // Require Admin role
    public IActionResult DeleteProduct(int id)
    {
        return Ok();
    }
}
```

### 2. HTTPS Only

```csharp
public void Configure(IApplicationBuilder app)
{
    app.UseHttpsRedirection(); // Redirect HTTP to HTTPS
    app.UseRouting();
}
```

### 3. API Key Authentication

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
        if (!context.Request.Headers.TryGetValue(API_KEY_HEADER, out var extractedApiKey))
        {
            context.Response.StatusCode = 401;
            await context.Response.WriteAsync("API Key was not provided");
            return;
        }
        
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

### 4. Rate Limiting

```csharp
// Install Microsoft.AspNetCore.RateLimiting

services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("Fixed", opt =>
    {
        opt.Window = TimeSpan.FromSeconds(10);
        opt.PermitLimit = 5; // 5 requests per 10 seconds
    });
});

app.UseRateLimiter();

[EnableRateLimiting("Fixed")]
[HttpGet]
public IActionResult GetProducts()
{
    return Ok();
}
```

### 5. Input Validation

```csharp
[ApiController] // Enables automatic validation
public class ProductsController : ControllerBase
{
    [HttpPost]
    public IActionResult CreateProduct(Product product)
    {
        // Validation happens automatically
        return Ok();
    }
}
```

### 6. SQL Injection Prevention

```csharp
// ✅ Use parameterized queries (Entity Framework does this automatically)
var products = _context.Products
    .Where(p => p.Name == name) // Safe
    .ToList();

// ❌ Never do this
var sql = $"SELECT * FROM Products WHERE Name = '{name}'"; // Vulnerable!
```

### 7. CORS Configuration

```csharp
services.AddCors(options =>
{
    options.AddPolicy("AllowSpecificOrigin", builder =>
    {
        builder.WithOrigins("https://trusted-domain.com")
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});
```

### 8. Security Headers

```csharp
public class SecurityHeadersMiddleware
{
    private readonly RequestDelegate _next;
    
    public SecurityHeadersMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
        context.Response.Headers.Add("X-Frame-Options", "DENY");
        context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
        context.Response.Headers.Add("Strict-Transport-Security", "max-age=31536000");
        
        await _next(context);
    }
}
```

### 9. Sensitive Data Protection

```csharp
// Never log sensitive data
_logger.LogInformation("User {UserId} logged in", userId); // ✅ OK
_logger.LogInformation("Password: {Password}", password); // ❌ Never!

// Encrypt sensitive data at rest
services.AddDataProtection();
```

### 10. Dependency Injection for Security

```csharp
// Register security services
services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options => { /* JWT config */ });

services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
});
```

---

## 2. Steps to implement JWT Token?

### Answer

JWT (JSON Web Token) is a popular authentication mechanism. Here's how to implement it:

### Step 1: Install NuGet Packages

```bash
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package System.IdentityModel.Tokens.Jwt
```

### Step 2: Configure JWT in Startup.cs

```csharp
public void ConfigureServices(IServiceCollection services)
{
    // JWT Configuration
    var jwtSettings = Configuration.GetSection("JwtSettings");
    var secretKey = jwtSettings["SecretKey"];
    
    services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings["Issuer"],
            ValidAudience = jwtSettings["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey))
        };
    });
    
    services.AddControllers();
}

public void Configure(IApplicationBuilder app)
{
    app.UseAuthentication(); // Must be before UseAuthorization
    app.UseAuthorization();
    app.UseEndpoints(endpoints => endpoints.MapControllers());
}
```

### Step 3: Configure appsettings.json

```json
{
  "JwtSettings": {
    "SecretKey": "YourSuperSecretKeyThatIsAtLeast32CharactersLong!",
    "Issuer": "https://localhost:5001",
    "Audience": "https://localhost:5001",
    "ExpirationMinutes": 60
  }
}
```

### Step 4: Create Token Service

```csharp
public interface ITokenService
{
    string GenerateToken(User user);
}

public class TokenService : ITokenService
{
    private readonly IConfiguration _configuration;
    
    public TokenService(IConfiguration configuration)
    {
        _configuration = configuration;
    }
    
    public string GenerateToken(User user)
    {
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var secretKey = jwtSettings["SecretKey"];
        var issuer = jwtSettings["Issuer"];
        var audience = jwtSettings["Audience"];
        var expirationMinutes = int.Parse(jwtSettings["ExpirationMinutes"]);
        
        var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
        var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);
        
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role)
        };
        
        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expirationMinutes),
            signingCredentials: credentials
        );
        
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}

// Register service
services.AddScoped<ITokenService, TokenService>();
```

### Step 5: Create Login Endpoint

```csharp
[ApiController]
[Route("api/[controller]")]
[AllowAnonymous] // Public endpoint
public class AuthController : ControllerBase
{
    private readonly ITokenService _tokenService;
    private readonly IUserService _userService;
    
    public AuthController(ITokenService tokenService, IUserService userService)
    {
        _tokenService = tokenService;
        _userService = userService;
    }
    
    [HttpPost("login")]
    public IActionResult Login([FromBody] LoginRequest request)
    {
        // Validate user credentials
        var user = _userService.ValidateUser(request.Username, request.Password);
        if (user == null)
        {
            return Unauthorized(new { message = "Invalid credentials" });
        }
        
        // Generate JWT token
        var token = _tokenService.GenerateToken(user);
        
        return Ok(new
        {
            token = token,
            expiresIn = 3600, // seconds
            user = new { id = user.Id, username = user.Username, role = user.Role }
        });
    }
}

public class LoginRequest
{
    [Required]
    public string Username { get; set; }
    
    [Required]
    public string Password { get; set; }
}
```

### Step 6: Protect Endpoints

```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize] // Require authentication
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts()
    {
        // Get current user from token
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var username = User.FindFirst(ClaimTypes.Name)?.Value;
        var role = User.FindFirst(ClaimTypes.Role)?.Value;
        
        return Ok(new { message = "Protected endpoint", userId, username, role });
    }
    
    [HttpPost]
    [Authorize(Roles = "Admin")] // Require Admin role
    public IActionResult CreateProduct(Product product)
    {
        return Ok();
    }
}
```

### Step 7: Client Usage

```javascript
// Login
const response = await fetch('https://api.example.com/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username: 'user', password: 'pass' })
});

const { token } = await response.json();

// Use token in subsequent requests
const productsResponse = await fetch('https://api.example.com/api/products', {
    headers: {
        'Authorization': `Bearer ${token}`
    }
});
```

### Complete Example:

```csharp
// Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    var jwtSettings = Configuration.GetSection("JwtSettings");
    var secretKey = jwtSettings["SecretKey"];
    
    services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = jwtSettings["Issuer"],
                ValidAudience = jwtSettings["Audience"],
                IssuerSigningKey = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(secretKey))
            };
        });
    
    services.AddScoped<ITokenService, TokenService>();
    services.AddControllers();
}

// AuthController.cs
[HttpPost("login")]
[AllowAnonymous]
public IActionResult Login(LoginRequest request)
{
    var user = _userService.ValidateUser(request.Username, request.Password);
    if (user == null) return Unauthorized();
    
    var token = _tokenService.GenerateToken(user);
    return Ok(new { token });
}

// ProductsController.cs
[HttpGet]
[Authorize]
public IActionResult GetProducts()
{
    return Ok(_productService.GetAll());
}
```

---

## 3. How do you implement authentication and authorization in ASP.NET Web API?

### Answer

Authentication verifies who the user is, while authorization determines what they can do.

### Authentication Methods:

#### 1. JWT Bearer Token (Most Common)

```csharp
// Already covered in previous question
services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options => { /* Configuration */ });
```

#### 2. Cookie Authentication

```csharp
services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/Login";
        options.AccessDeniedPath = "/Account/AccessDenied";
        options.ExpireTimeSpan = TimeSpan.FromMinutes(60);
    });
```

#### 3. API Key Authentication

**What is API Key Authentication?**
API Key authentication is a simple authentication mechanism where clients include a secret key (API key) in their requests, typically in HTTP headers. This method is commonly used for:
- Server-to-server communication
- API access control without user authentication
- Third-party integrations
- Rate limiting and tracking API usage

**How it works:**
1. Client sends API key in request header (e.g., `X-API-Key`)
2. Server validates the key against stored valid keys
3. If valid, server creates an authenticated principal with claims
4. If invalid or missing, request is rejected

**Implementation:**

```csharp
// Custom authentication handler that validates API keys
public class ApiKeyAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    // Constructor: Receives required dependencies for authentication handling
    // - options: Configuration options for the authentication scheme
    // - logger: For logging authentication events
    // - encoder: URL encoder for encoding/decoding
    public ApiKeyAuthenticationHandler(
        IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder) : base(options, logger, encoder)
    {
    }
    
    // Core method: Handles the authentication process
    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        // Step 1: Check if API key header exists in the request
        // Header name: "X-API-Key" (custom header convention)
        if (!Request.Headers.TryGetValue("X-API-Key", out var apiKeyHeaderValues))
        {
            // No API key provided - authentication fails
            return Task.FromResult(AuthenticateResult.Fail("API Key was not provided"));
        }
        
        // Step 2: Extract the API key from header values
        // Headers can have multiple values, so we take the first one
        var providedApiKey = apiKeyHeaderValues.FirstOrDefault();
        
        // Step 3: Get the valid API key from configuration (appsettings.json)
        // This should be stored securely (e.g., Azure Key Vault, AWS Secrets Manager)
        var validApiKey = Configuration["ApiSettings:ApiKey"];
        
        // Step 4: Compare provided key with valid key
        // Note: In production, use secure comparison to prevent timing attacks
        if (providedApiKey != validApiKey)
        {
            // Invalid API key - authentication fails
            return Task.FromResult(AuthenticateResult.Fail("Invalid API Key"));
        }
        
        // Step 5: Create claims for authenticated user
        // Claims represent information about the authenticated entity
        var claims = new[] { new Claim(ClaimTypes.Name, "API User") };
        
        // Step 6: Create identity from claims
        // Identity represents the authenticated user's identity
        var identity = new ClaimsIdentity(claims, Scheme.Name);
        
        // Step 7: Create principal from identity
        // Principal represents the security context of the user
        var principal = new ClaimsPrincipal(identity);
        
        // Step 8: Create authentication ticket
        // Ticket contains the principal and authentication scheme name
        var ticket = new AuthenticationTicket(principal, Scheme.Name);
        
        // Step 9: Return success with the authentication ticket
        return Task.FromResult(AuthenticateResult.Success(ticket));
    }
}

// Register the custom authentication handler in Startup.cs or Program.cs
services.AddAuthentication("ApiKey")
    .AddScheme<AuthenticationSchemeOptions, ApiKeyAuthenticationHandler>(
        "ApiKey", options => { });

// Usage in Controller:
// [Authorize(AuthenticationSchemes = "ApiKey")]
// public class ProductsController : ControllerBase { }
```

**Security Considerations:**
- **Store API keys securely**: Never hardcode keys; use configuration, environment variables, or secret management services
- **Use HTTPS**: Always transmit API keys over encrypted connections
- **Rotate keys regularly**: Implement key rotation policies
- **Use secure comparison**: For production, use `CryptographicOperations.FixedTimeEquals()` to prevent timing attacks
- **Rate limiting**: Implement rate limiting per API key
- **Key validation**: Consider validating key format before comparison
- **Logging**: Log authentication failures (but not the actual keys)

**Example Request:**
```http
GET /api/products HTTP/1.1
Host: api.example.com
X-API-Key: your-secret-api-key-here
```

**Configuration (appsettings.json):**
```json
{
  "ApiSettings": {
    "ApiKey": "your-secret-api-key-here"
  }
}
```

### Authorization:

#### 1. Role-Based Authorization

```csharp
[Authorize(Roles = "Admin")]
[HttpDelete("{id}")]
public IActionResult DeleteProduct(int id)
{
    return Ok();
}

// Multiple roles
[Authorize(Roles = "Admin,Manager")]
[HttpPut("{id}")]
public IActionResult UpdateProduct(int id, Product product)
{
    return Ok();
}
```

#### 2. Policy-Based Authorization

```csharp
// Define policy in Startup.cs
services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
    
    options.AddPolicy("MinimumAge", policy =>
        policy.RequireClaim("Age", "18", "21", "25"));
    
    options.AddPolicy("CanEditProduct", policy =>
        policy.RequireAssertion(context =>
            context.User.IsInRole("Admin") || 
            context.User.HasClaim("Permission", "EditProduct")));
});

// Use policy
[Authorize(Policy = "CanEditProduct")]
[HttpPut("{id}")]
public IActionResult UpdateProduct(int id, Product product)
{
    return Ok();
}
```

#### 3. Resource-Based Authorization

```csharp
public class ProductAuthorizationHandler : 
    AuthorizationHandler<OperationRequirement, Product>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        OperationRequirement requirement,
        Product resource)
    {
        // User can only edit their own products
        if (requirement.Name == "Edit" && 
            resource.OwnerId == context.User.FindFirstValue(ClaimTypes.NameIdentifier))
        {
            context.Succeed(requirement);
        }
        
        return Task.CompletedTask;
    }
}

// Register
services.AddAuthorization(options =>
{
    options.AddPolicy("CanEditProduct", policy =>
        policy.Requirements.Add(new OperationRequirement("Edit")));
});

services.AddScoped<IAuthorizationHandler, ProductAuthorizationHandler>();

// Usage
[HttpPut("{id}")]
[Authorize(Policy = "CanEditProduct")]
public IActionResult UpdateProduct(int id, Product product, 
    [FromServices] IAuthorizationService authorizationService)
{
    var existingProduct = _productService.GetById(id);
    
    var authResult = await authorizationService.AuthorizeAsync(
        User, existingProduct, "CanEditProduct");
    
    if (!authResult.Succeeded)
    {
        return Forbid();
    }
    
    return Ok();
}
```

### Complete Example:

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    [AllowAnonymous] // Public
    public IActionResult GetProducts()
    {
        return Ok();
    }
    
    [HttpGet("{id}")]
    [Authorize] // Requires authentication
    public IActionResult GetProduct(int id)
    {
        return Ok();
    }
    
    [HttpPost]
    [Authorize] // Requires authentication
    public IActionResult CreateProduct(Product product)
    {
        return Ok();
    }
    
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin,Manager")] // Requires role
    public IActionResult UpdateProduct(int id, Product product)
    {
        return Ok();
    }
    
    [HttpDelete("{id}")]
    [Authorize(Policy = "AdminOnly")] // Requires policy
    public IActionResult DeleteProduct(int id)
    {
        return Ok();
    }
}
```

---

## 4. Web API Versioning

### Answer

API versioning allows you to maintain multiple versions of your API simultaneously.

### Method 1: URL Path Versioning

```csharp
// Install Microsoft.AspNetCore.Mvc.Versioning

services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
    options.ApiVersionReader = ApiVersionReader.Combine(
        new UrlSegmentApiVersionReader(),
        new QueryStringApiVersionReader("version"),
        new HeaderApiVersionReader("X-Version")
    );
});

// Usage
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
[ApiController]
public class ProductsV1Controller : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts()
    {
        return Ok(new { version = "1.0", message = "V1 API" });
    }
}

[ApiVersion("2.0")]
[Route("api/v{version:apiVersion}/[controller]")]
[ApiController]
public class ProductsV2Controller : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts()
    {
        return Ok(new { version = "2.0", message = "V2 API" });
    }
}
```

### Method 2: Query String Versioning

```csharp
services.AddApiVersioning(options =>
{
    options.ApiVersionReader = new QueryStringApiVersionReader("v");
});

[ApiVersion("1.0")]
[Route("api/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts()
    {
        return Ok(new { version = "1.0" });
    }
}

// Access: /api/products?v=1.0
```

### Method 3: Header Versioning

```csharp
services.AddApiVersioning(options =>
{
    options.ApiVersionReader = new HeaderApiVersionReader("X-API-Version");
});

// Client sends: X-API-Version: 1.0
```

### Method 4: Media Type Versioning

```csharp
services.AddApiVersioning(options =>
{
    options.ApiVersionReader = new MediaTypeApiVersionReader("v");
});

// Client sends: Accept: application/json;v=2.0
```

### Complete Example:

```csharp
services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
});

[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts()
    {
        return Ok(new { version = "1.0", products = new[] { "Product1", "Product2" } });
    }
}

[ApiVersion("2.0")]
[Route("api/v{version:apiVersion}/[controller]")]
[ApiController]
public class ProductsV2Controller : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts()
    {
        return Ok(new { version = "2.0", data = new { products = new[] { "Product1", "Product2" } } });
    }
}
```

---

## 5. Describe how you would implement logging in an ASP.NET Web API application.

### Answer

ASP.NET Core has built-in logging that can be extended with third-party providers.

### Built-in Logging:

```csharp
public class ProductsController : ControllerBase
{
    private readonly ILogger<ProductsController> _logger;
    
    public ProductsController(ILogger<ProductsController> logger)
    {
        _logger = logger;
    }
    
    [HttpGet]
    public IActionResult GetProducts()
    {
        _logger.LogInformation("Getting all products");
        
        try
        {
            var products = _productService.GetAll();
            _logger.LogInformation("Retrieved {Count} products", products.Count);
            return Ok(products);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving products");
            return StatusCode(500, "An error occurred");
        }
    }
}
```

### Log Levels:

```csharp
_logger.LogTrace("Very detailed information");
_logger.LogDebug("Debug information");
_logger.LogInformation("General information");
_logger.LogWarning("Warning message");
_logger.LogError("Error message");
_logger.LogCritical("Critical error");
```

### Configuration in appsettings.json:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information",
      "MyApp.Controllers": "Debug"
    }
  }
}
```

### Structured Logging:

```csharp
_logger.LogInformation(
    "User {UserId} created product {ProductId} at {Timestamp}",
    userId, productId, DateTime.UtcNow);
```

### Custom Logging Middleware:

```csharp
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
        var startTime = DateTime.UtcNow;
        var correlationId = Guid.NewGuid().ToString();
        
        using (_logger.BeginScope(new Dictionary<string, object>
        {
            ["CorrelationId"] = correlationId,
            ["RequestPath"] = context.Request.Path,
            ["RequestMethod"] = context.Request.Method
        }))
        {
            _logger.LogInformation("Request started");
            
            try
            {
                await _next(context);
                
                var duration = DateTime.UtcNow - startTime;
                _logger.LogInformation(
                    "Request completed in {Duration}ms with status {StatusCode}",
                    duration.TotalMilliseconds, context.Response.StatusCode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Request failed");
                throw;
            }
        }
    }
}
```

### Third-Party Logging (Serilog):

```csharp
// Install Serilog.AspNetCore

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .WriteTo.File("logs/app-.txt", rollingInterval: RollingInterval.Day)
    .CreateLogger();

services.AddSerilog();

// Usage
_logger.LogInformation("Using Serilog");
```

---

## 6. What are filters in ASP.NET Web API and how do you create a custom filter?

### Answer

**Filters** allow you to run code before or after specific stages in the request pipeline.

### Filter Types:

1. **Authorization Filters** - Run first, determine if user is authorized
2. **Resource Filters** - Run after authorization, can short-circuit pipeline
3. **Action Filters** - Run before/after action execution
4. **Exception Filters** - Handle exceptions
5. **Result Filters** - Run before/after result execution

### Custom Action Filter:

```csharp
public class LogActionFilter : IActionFilter
{
    private readonly ILogger<LogActionFilter> _logger;
    
    public LogActionFilter(ILogger<LogActionFilter> logger)
    {
        _logger = logger;
    }
    
    public void OnActionExecuting(ActionExecutingContext context)
    {
        _logger.LogInformation(
            "Action {ActionName} executing with parameters: {Parameters}",
            context.ActionDescriptor.DisplayName,
            JsonSerializer.Serialize(context.ActionArguments));
    }
    
    public void OnActionExecuted(ActionExecutedContext context)
    {
        _logger.LogInformation(
            "Action {ActionName} executed with result: {Result}",
            context.ActionDescriptor.DisplayName,
            context.Result);
    }
}

// Usage
[ServiceFilter(typeof(LogActionFilter))]
[HttpGet]
public IActionResult GetProducts()
{
    return Ok();
}
```

### Custom Authorization Filter:

```csharp
public class ApiKeyAuthorizationFilter : IAuthorizationFilter
{
    private const string API_KEY_HEADER = "X-API-Key";
    
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        if (!context.HttpContext.Request.Headers.TryGetValue(API_KEY_HEADER, out var apiKey))
        {
            context.Result = new UnauthorizedResult();
            return;
        }
        
        var configuration = context.HttpContext.RequestServices
            .GetRequiredService<IConfiguration>();
        var validApiKey = configuration["ApiSettings:ApiKey"];
        
        if (apiKey != validApiKey)
        {
            context.Result = new UnauthorizedResult();
        }
    }
}

// Usage
[TypeFilter(typeof(ApiKeyAuthorizationFilter))]
[HttpGet]
public IActionResult GetProducts()
{
    return Ok();
}
```

### Register Filters Globally:

```csharp
services.AddControllers(options =>
{
    options.Filters.Add<LogActionFilter>();
    options.Filters.Add<ApiExceptionFilter>();
});
```

---

## Summary

- **Securing Web API**: Multiple layers - authentication, authorization, HTTPS, rate limiting, input validation, CORS, security headers
- **JWT Implementation**: Configure authentication, create token service, implement login endpoint, protect endpoints with [Authorize]
- **Authentication/Authorization**: JWT, cookies, API keys; role-based, policy-based, resource-based authorization
- **API Versioning**: URL path, query string, header, or media type versioning
- **Logging**: Built-in ILogger with structured logging, custom middleware, third-party providers like Serilog
- **Filters**: Action, authorization, exception, result filters for cross-cutting concerns

