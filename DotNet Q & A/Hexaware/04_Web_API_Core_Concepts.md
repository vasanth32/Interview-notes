# Web API Core Concepts - Interview Questions & Answers

## 1. What is content negotiation in Web API?

### Answer

**Content negotiation** is the process by which the client and server determine the best representation format (media type) for data exchange. The client specifies what formats it can accept, and the server responds with data in one of those formats.

### How It Works:

1. **Client sends Accept header** with preferred media types
2. **Server examines Accept header** and available formatters
3. **Server selects best match** and formats response accordingly
4. **Server sends Content-Type header** indicating the format used

### Example Request:

```http
GET /api/products/1 HTTP/1.1
Host: localhost:5000
Accept: application/json, application/xml, text/plain
```

### Built-in Formatters:

ASP.NET Core Web API includes these formatters by default:
- **JSON** (`application/json`) - Default
- **XML** (`application/xml`) - If configured

### Configuration:

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddControllers(options =>
    {
        // Add XML formatter
        options.RespectBrowserAcceptHeader = true;
        options.ReturnHttpNotAcceptable = true; // Return 406 if format not supported
    })
    .AddXmlDataContractSerializerFormatters() // Add XML support
    .AddXmlSerializerFormatters();
}
```

### Example Response Based on Accept Header:

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    [HttpGet("{id}")]
    public ActionResult<Product> GetProduct(int id)
    {
        var product = new Product { Id = id, Name = "Laptop", Price = 999.99m };
        
        // Server automatically formats based on Accept header
        return Ok(product);
    }
}
```

**Client Request 1:**
```http
Accept: application/json
```
**Response:** JSON format
```json
{
  "id": 1,
  "name": "Laptop",
  "price": 999.99
}
```

**Client Request 2:**
```http
Accept: application/xml
```
**Response:** XML format
```xml
<Product>
  <Id>1</Id>
  <Name>Laptop</Name>
  <Price>999.99</Price>
</Product>
```

### Custom Content Negotiation:

```csharp
public class CustomOutputFormatter : TextOutputFormatter
{
    public CustomOutputFormatter()
    {
        SupportedMediaTypes.Add("text/csv");
        SupportedEncodings.Add(Encoding.UTF8);
    }
    
    public override async Task WriteResponseBodyAsync(
        OutputFormatterWriteContext context, 
        Encoding selectedEncoding)
    {
        var response = context.HttpContext.Response;
        var buffer = new StringBuilder();
        
        if (context.Object is IEnumerable<Product> products)
        {
            foreach (var product in products)
            {
                buffer.AppendLine($"{product.Id},{product.Name},{product.Price}");
            }
        }
        
        await response.WriteAsync(buffer.ToString());
    }
}

// Register in Startup.cs
services.AddControllers(options =>
{
    options.OutputFormatters.Add(new CustomOutputFormatter());
});
```

---

## 2. What attribute would you use for a Web API parameter to read request from body?

### Answer

Use the **`[FromBody]`** attribute to read data from the request body.

### Example:

```csharp
[HttpPost]
public IActionResult CreateProduct([FromBody] Product product)
{
    // Product is deserialized from request body (JSON/XML)
    _productService.Create(product);
    return Ok(product);
}
```

### Other Parameter Binding Attributes:

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    // [FromBody] - From request body (JSON/XML)
    [HttpPost]
    public IActionResult Create([FromBody] Product product)
    {
        return Ok(product);
    }
    
    // [FromQuery] - From query string
    [HttpGet]
    public IActionResult Search([FromQuery] string name, [FromQuery] decimal? minPrice)
    {
        // GET /api/products?name=Laptop&minPrice=100
        return Ok();
    }
    
    // [FromRoute] - From route parameters
    [HttpGet("{id}")]
    public IActionResult GetById([FromRoute] int id)
    {
        // GET /api/products/1
        return Ok();
    }
    
    // [FromHeader] - From HTTP headers
    [HttpGet]
    public IActionResult GetWithApiKey([FromHeader(Name = "X-API-Key")] string apiKey)
    {
        return Ok();
    }
    
    // [FromForm] - From form data
    [HttpPost("upload")]
    public IActionResult Upload([FromForm] IFormFile file)
    {
        return Ok();
    }
}
```

### [ApiController] Attribute Behavior:

When using `[ApiController]`, Web API automatically infers binding sources:
- **Complex types** → `[FromBody]` (for POST/PUT/PATCH)
- **Simple types** → `[FromQuery]` (for GET)
- **Route parameters** → `[FromRoute]`

```csharp
[ApiController] // Enables automatic inference
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    // Product automatically bound from body (no [FromBody] needed)
    [HttpPost]
    public IActionResult Create(Product product)
    {
        return Ok(product);
    }
    
    // name automatically bound from query string
    [HttpGet]
    public IActionResult Search(string name)
    {
        return Ok();
    }
}
```

---

## 3. What are the advantages of WebHooks?

### Answer

**WebHooks** are HTTP callbacks that allow one application to notify another when an event occurs. Instead of polling, the server pushes data to the client.

### Advantages:

#### **1. Real-Time Notifications**
- Immediate notification when events occur
- No need to poll for updates
- Better user experience

#### **2. Reduced Server Load**
- No constant polling requests
- Server only sends data when events happen
- More efficient resource usage

#### **3. Event-Driven Architecture**
- Decouples systems
- Enables reactive programming
- Better scalability

#### **4. Cost Efficiency**
- Fewer HTTP requests
- Reduced bandwidth usage
- Lower infrastructure costs

### Example Implementation:

```csharp
public class WebhookService
{
    private readonly HttpClient _httpClient;
    
    public WebhookService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }
    
    public async Task NotifySubscribers(string eventType, object payload)
    {
        var subscribers = GetSubscribersForEvent(eventType);
        
        foreach (var subscriber in subscribers)
        {
            try
            {
                var json = JsonSerializer.Serialize(payload);
                var content = new StringContent(json, Encoding.UTF8, "application/json");
                
                // Add signature for security
                var signature = GenerateSignature(json, subscriber.Secret);
                content.Headers.Add("X-Webhook-Signature", signature);
                
                await _httpClient.PostAsync(subscriber.Url, content);
            }
            catch (Exception ex)
            {
                // Log and retry logic
                LogError(subscriber, ex);
            }
        }
    }
}

// Usage in controller
[HttpPost("orders")]
public async Task<IActionResult> CreateOrder(OrderDto order)
{
    var createdOrder = await _orderService.CreateOrder(order);
    
    // Trigger webhook
    await _webhookService.NotifySubscribers("order.created", createdOrder);
    
    return Ok(createdOrder);
}
```

### Common Use Cases:

- Payment processing notifications
- CI/CD pipeline triggers
- Social media integrations
- E-commerce order updates
- Cloud service events (Azure, AWS)

---

## 4. What HTTP error status would be sent if a model is not valid in a CreateProduct endpoint which has a product as parameter?

### Answer

**HTTP 400 Bad Request** is returned when model validation fails.

### Automatic Validation with [ApiController]:

```csharp
[ApiController] // Enables automatic model validation
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    [HttpPost]
    public IActionResult CreateProduct(Product product)
    {
        // If product is invalid, returns 400 automatically
        // No need to check ModelState.IsValid
        
        _productService.Create(product);
        return Ok(product);
    }
}
```

### Example Invalid Request:

```http
POST /api/products HTTP/1.1
Content-Type: application/json

{
  "name": "",  // Invalid: empty name
  "price": -10  // Invalid: negative price
}
```

**Response:**
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Name": ["The Name field is required."],
    "Price": ["The field Price must be greater than 0."]
  }
}
```

### Custom Validation Response:

```csharp
[HttpPost]
public IActionResult CreateProduct(Product product)
{
    if (!ModelState.IsValid)
    {
        return BadRequest(ModelState); // Returns 400 with validation errors
    }
    
    _productService.Create(product);
    return Ok(product);
}
```

### Model with Validation Attributes:

```csharp
public class Product
{
    [Required(ErrorMessage = "Product name is required")]
    [StringLength(100, MinimumLength = 3)]
    public string Name { get; set; }
    
    [Range(0.01, 10000, ErrorMessage = "Price must be between 0.01 and 10000")]
    public decimal Price { get; set; }
    
    [Required]
    [StringLength(500)]
    public string Description { get; set; }
}
```

---

## 5. Difference in SOAP and REST. When would you use SOAP and when REST?

### Answer

### SOAP vs REST Comparison:

| Feature | SOAP | REST |
|---------|------|------|
| **Protocol** | Protocol (XML-based) | Architectural style |
| **Format** | XML only | JSON, XML, HTML, Plain text |
| **Standards** | WSDL, WS-Security, WS-AtomicTransaction | HTTP methods (GET, POST, PUT, DELETE) |
| **State** | Stateful or Stateless | Stateless |
| **Caching** | Not supported | Supported |
| **Performance** | Slower (XML parsing) | Faster (JSON) |
| **Complexity** | More complex | Simpler |
| **Security** | Built-in (WS-Security) | Relies on HTTPS, OAuth, etc. |
| **Use Cases** | Enterprise, Financial, Enterprise integration | Web, Mobile, Microservices |

### When to Use SOAP:

#### ✅ **Use SOAP When:**

1. **Enterprise Integration**
   - Need formal contracts (WSDL)
   - Integration with legacy systems
   - Banking and financial services

2. **Security Requirements**
   - Need WS-Security features
   - ACID transactions required
   - Message-level security

3. **Reliable Messaging**
   - Need guaranteed delivery
   - Complex transactions
   - Two-phase commit scenarios

**Example SOAP Request:**
```xml
<soap:Envelope>
  <soap:Body>
    <GetAccountBalance>
      <AccountNumber>12345</AccountNumber>
    </GetAccountBalance>
  </soap:Body>
</soap:Envelope>
```

### When to Use REST:

#### ✅ **Use REST When:**

1. **Web and Mobile Applications**
   - Public APIs
   - Simple CRUD operations
   - Stateless operations

2. **Microservices**
   - Lightweight communication
   - JSON data format
   - HTTP caching

3. **Performance Critical**
   - Need fast responses
   - High throughput
   - Simple data exchange

**Example REST Request:**
```http
GET /api/accounts/12345/balance HTTP/1.1
Host: api.example.com
Accept: application/json
```

**Response:**
```json
{
  "accountNumber": "12345",
  "balance": 1000.00
}
```

### Modern Recommendation:

**Use REST for most scenarios** (90% of cases). Use SOAP only when:
- Integrating with legacy enterprise systems
- Need formal contracts and standards
- Working in regulated industries (banking, healthcare)

---

## 6. How do you handle exceptions in ASP.NET Web API? Provide an example.

### Answer

Exception handling in Web API can be done using:
1. **Exception Filters**
2. **Middleware**
3. **Global Exception Handler**

### Method 1: Exception Filter (Recommended for API-specific)

```csharp
public class ApiExceptionFilter : IExceptionFilter
{
    private readonly ILogger<ApiExceptionFilter> _logger;
    
    public ApiExceptionFilter(ILogger<ApiExceptionFilter> logger)
    {
        _logger = logger;
    }
    
    public void OnException(ExceptionContext context)
    {
        var exception = context.Exception;
        _logger.LogError(exception, "An unhandled exception occurred");
        
        var response = new ErrorResponse
        {
            Message = exception.Message,
            StatusCode = 500
        };
        
        // Handle specific exception types
        switch (exception)
        {
            case ArgumentNullException argEx:
                response.Message = "Invalid argument provided";
                response.StatusCode = 400;
                context.Result = new BadRequestObjectResult(response);
                break;
                
            case NotFoundException notFoundEx:
                response.Message = notFoundEx.Message;
                response.StatusCode = 404;
                context.Result = new NotFoundObjectResult(response);
                break;
                
            case UnauthorizedAccessException:
                response.Message = "Unauthorized access";
                response.StatusCode = 401;
                context.Result = new UnauthorizedObjectResult(response);
                break;
                
            default:
                response.Message = "An error occurred while processing your request";
                response.StatusCode = 500;
                context.Result = new ObjectResult(response)
                {
                    StatusCode = 500
                };
                break;
        }
        
        context.ExceptionHandled = true;
    }
}

public class ErrorResponse
{
    public string Message { get; set; }
    public int StatusCode { get; set; }
    public string StackTrace { get; set; } // Only in development
}

// Register in Startup.cs
services.AddControllers(options =>
{
    options.Filters.Add<ApiExceptionFilter>();
});
```

### Method 2: Middleware (Global Exception Handling)

```csharp
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;
    private readonly IWebHostEnvironment _environment;
    
    public ExceptionHandlingMiddleware(
        RequestDelegate next,
        ILogger<ExceptionHandlingMiddleware> logger,
        IWebHostEnvironment environment)
    {
        _next = next;
        _logger = logger;
        _environment = environment;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred");
            await HandleExceptionAsync(context, ex);
        }
    }
    
    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = exception switch
        {
            ArgumentNullException => 400,
            NotFoundException => 404,
            UnauthorizedAccessException => 401,
            _ => 500
        };
        
        var response = new ErrorResponse
        {
            Message = exception.Message,
            StatusCode = context.Response.StatusCode
        };
        
        // Include stack trace in development
        if (_environment.IsDevelopment())
        {
            response.StackTrace = exception.StackTrace;
        }
        
        var json = JsonSerializer.Serialize(response);
        await context.Response.WriteAsync(json);
    }
}

// Register in Startup.cs (early in pipeline)
public void Configure(IApplicationBuilder app)
{
    app.UseMiddleware<ExceptionHandlingMiddleware>(); // Add early
    app.UseRouting();
    app.UseEndpoints(endpoints => endpoints.MapControllers());
}
```

### Method 3: Custom Exception Classes

```csharp
// Custom exceptions
public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message) { }
}

public class ValidationException : Exception
{
    public Dictionary<string, string[]> Errors { get; }
    
    public ValidationException(Dictionary<string, string[]> errors) 
        : base("Validation failed")
    {
        Errors = errors;
    }
}

// Usage in service
public class ProductService
{
    public Product GetProduct(int id)
    {
        var product = _repository.GetById(id);
        if (product == null)
        {
            throw new NotFoundException($"Product with ID {id} not found");
        }
        return product;
    }
}

// Exception handler
public class ApiExceptionFilter : IExceptionFilter
{
    public void OnException(ExceptionContext context)
    {
        switch (context.Exception)
        {
            case NotFoundException notFound:
                context.Result = new NotFoundObjectResult(new { message = notFound.Message });
                break;
                
            case ValidationException validation:
                context.Result = new BadRequestObjectResult(validation.Errors);
                break;
        }
        
        context.ExceptionHandled = true;
    }
}
```

### Complete Example:

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    
    public ProductsController(IProductService productService)
    {
        _productService = productService;
    }
    
    [HttpGet("{id}")]
    public IActionResult GetProduct(int id)
    {
        // Exception will be caught by filter/middleware
        var product = _productService.GetProduct(id);
        return Ok(product);
    }
    
    [HttpPost]
    public IActionResult CreateProduct(Product product)
    {
        // Validation exceptions handled automatically
        var created = _productService.Create(product);
        return CreatedAtAction(nameof(GetProduct), new { id = created.Id }, created);
    }
}
```

---

## 7. What is CORS and how do you enable it in ASP.NET Web API?

### Answer

**CORS (Cross-Origin Resource Sharing)** is a security feature that allows web pages to make requests to a different domain than the one serving the web page.

### The Problem:

By default, browsers block requests from `http://localhost:3000` to `http://localhost:5000` (different origins).

### Enable CORS:

#### Method 1: Default Policy (All Origins)

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddCors(options =>
    {
        options.AddDefaultPolicy(builder =>
        {
            builder.AllowAnyOrigin()
                   .AllowAnyMethod()
                   .AllowAnyHeader();
        });
    });
    
    services.AddControllers();
}

public void Configure(IApplicationBuilder app)
{
    app.UseCors(); // Use default policy
    app.UseRouting();
    app.UseEndpoints(endpoints => endpoints.MapControllers());
}
```

#### Method 2: Named Policy (Recommended)

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddCors(options =>
    {
        options.AddPolicy("AllowSpecificOrigin", builder =>
        {
            builder.WithOrigins("http://localhost:3000", "https://myapp.com")
                   .WithMethods("GET", "POST", "PUT", "DELETE")
                   .WithHeaders("Content-Type", "Authorization")
                   .AllowCredentials(); // Allow cookies/auth headers
        });
    });
    
    services.AddControllers();
}

public void Configure(IApplicationBuilder app)
{
    app.UseCors("AllowSpecificOrigin");
    app.UseRouting();
    app.UseEndpoints(endpoints => endpoints.MapControllers());
}
```

#### Method 3: Per-Endpoint Policy

```csharp
[ApiController]
[Route("api/[controller]")]
[EnableCors("AllowSpecificOrigin")] // Apply to specific controller
public class ProductsController : ControllerBase
{
    [HttpGet]
    [EnableCors("AllowSpecificOrigin")] // Or specific action
    public IActionResult GetProducts()
    {
        return Ok();
    }
}
```

### Configuration Options:

```csharp
services.AddCors(options =>
{
    options.AddPolicy("MyPolicy", builder =>
    {
        // Origins
        builder.WithOrigins("http://localhost:3000");
        // Or
        builder.SetIsOriginAllowed(origin => true); // Dynamic origin check
        
        // Methods
        builder.WithMethods("GET", "POST", "PUT", "DELETE");
        // Or
        builder.AllowAnyMethod();
        
        // Headers
        builder.WithHeaders("Content-Type", "Authorization", "X-Custom-Header");
        // Or
        builder.AllowAnyHeader();
        
        // Credentials (cookies, auth headers)
        builder.AllowCredentials();
        
        // Expose headers to client
        builder.WithExposedHeaders("X-Custom-Header");
        
        // Cache preflight for 1 hour
        builder.SetPreflightMaxAge(TimeSpan.FromHours(1));
    });
});
```

### Preflight Requests:

For complex requests, browsers send a **preflight OPTIONS request** first:

```http
OPTIONS /api/products HTTP/1.1
Origin: http://localhost:3000
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type
```

Server responds:
```http
HTTP/1.1 200 OK
Access-Control-Allow-Origin: http://localhost:3000
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type
Access-Control-Max-Age: 3600
```

---

## 8. How do you perform model validation in ASP.NET Web API?

### Answer

Model validation ensures incoming data meets your requirements before processing.

### Automatic Validation with [ApiController]:

```csharp
[ApiController] // Enables automatic validation
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    [HttpPost]
    public IActionResult CreateProduct(Product product)
    {
        // Validation happens automatically
        // Returns 400 if invalid
        
        _productService.Create(product);
        return Ok(product);
    }
}
```

### Validation Attributes:

```csharp
public class Product
{
    [Required(ErrorMessage = "Product name is required")]
    [StringLength(100, MinimumLength = 3, ErrorMessage = "Name must be between 3 and 100 characters")]
    public string Name { get; set; }
    
    [Range(0.01, 10000, ErrorMessage = "Price must be between 0.01 and 10000")]
    [DataType(DataType.Currency)]
    public decimal Price { get; set; }
    
    [Required]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    public string SupplierEmail { get; set; }
    
    [Url(ErrorMessage = "Invalid URL format")]
    public string ImageUrl { get; set; }
    
    [RegularExpression(@"^[A-Z]{2}\d{4}$", ErrorMessage = "SKU must be 2 letters followed by 4 digits")]
    public string SKU { get; set; }
    
    [Compare("ConfirmPassword", ErrorMessage = "Passwords do not match")]
    public string Password { get; set; }
}
```

### Custom Validation:

```csharp
// Custom validation attribute
public class ValidProductNameAttribute : ValidationAttribute
{
    protected override ValidationResult IsValid(object value, ValidationContext validationContext)
    {
        if (value is string name)
        {
            var invalidWords = new[] { "test", "dummy", "sample" };
            if (invalidWords.Any(word => name.Contains(word, StringComparison.OrdinalIgnoreCase)))
            {
                return new ValidationResult("Product name contains invalid words");
            }
        }
        return ValidationResult.Success;
    }
}

// Usage
public class Product
{
    [ValidProductName]
    public string Name { get; set; }
}
```

### Manual Validation:

```csharp
[HttpPost]
public IActionResult CreateProduct(Product product)
{
    if (!ModelState.IsValid)
    {
        return BadRequest(ModelState);
    }
    
    // Additional custom validation
    if (product.Price > 1000 && string.IsNullOrEmpty(product.Description))
    {
        ModelState.AddModelError("Description", "Description required for expensive products");
        return BadRequest(ModelState);
    }
    
    _productService.Create(product);
    return Ok(product);
}
```

### FluentValidation (Third-Party):

```csharp
// Install FluentValidation.AspNetCore

public class ProductValidator : AbstractValidator<Product>
{
    public ProductValidator()
    {
        RuleFor(p => p.Name)
            .NotEmpty().WithMessage("Name is required")
            .Length(3, 100).WithMessage("Name must be between 3 and 100 characters");
        
        RuleFor(p => p.Price)
            .GreaterThan(0).WithMessage("Price must be greater than 0")
            .LessThanOrEqualTo(10000).WithMessage("Price cannot exceed 10000");
        
        RuleFor(p => p.SupplierEmail)
            .EmailAddress().WithMessage("Invalid email format");
    }
}

// Register in Startup.cs
services.AddControllers()
    .AddFluentValidation(fv => fv.RegisterValidatorsFromAssemblyContaining<ProductValidator>());
```

---

## 9. How do you handle large file uploads in ASP.NET Web API?

### Answer

Handling large files requires special configuration to avoid memory issues and timeouts.

### Method 1: Basic File Upload

```csharp
[ApiController]
[Route("api/[controller]")]
public class FilesController : ControllerBase
{
    private readonly IWebHostEnvironment _environment;
    
    public FilesController(IWebHostEnvironment environment)
    {
        _environment = environment;
    }
    
    [HttpPost("upload")]
    [RequestSizeLimit(100_000_000)] // 100 MB limit
    public async Task<IActionResult> UploadFile(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("No file uploaded");
        
        if (file.Length > 100_000_000) // 100 MB
            return BadRequest("File too large");
        
        var uploadsPath = Path.Combine(_environment.WebRootPath, "uploads");
        if (!Directory.Exists(uploadsPath))
            Directory.CreateDirectory(uploadsPath);
        
        var fileName = $"{Guid.NewGuid()}_{file.FileName}";
        var filePath = Path.Combine(uploadsPath, fileName);
        
        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }
        
        return Ok(new { fileName, filePath });
    }
}
```

### Method 2: Streaming for Very Large Files

```csharp
[HttpPost("upload-stream")]
[DisableRequestSizeLimit] // Remove size limit
public async Task<IActionResult> UploadLargeFile()
{
    var request = HttpContext.Request;
    
    if (!request.HasFormContentType)
        return BadRequest("Expected multipart/form-data");
    
    var boundary = request.GetMultipartBoundary();
    var reader = new MultipartReader(boundary, request.Body);
    
    var section = await reader.ReadNextSectionAsync();
    while (section != null)
    {
        var hasContentDisposition = ContentDispositionHeaderValue.TryParse(
            section.ContentDisposition, out var contentDisposition);
        
        if (hasContentDisposition && contentDisposition.IsFileDisposition())
        {
            var fileName = contentDisposition.FileName.Value;
            var filePath = Path.Combine(_environment.WebRootPath, "uploads", fileName);
            
            using (var targetStream = new FileStream(filePath, FileMode.Create))
            {
                await section.Body.CopyToAsync(targetStream);
            }
        }
        
        section = await reader.ReadNextSectionAsync();
    }
    
    return Ok("File uploaded successfully");
}
```

### Configuration for Large Files:

```csharp
// In Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    services.Configure<FormOptions>(options =>
    {
        options.MultipartBodyLengthLimit = 500_000_000; // 500 MB
        options.ValueLengthLimit = int.MaxValue;
        options.MultipartHeadersLengthLimit = int.MaxValue;
    });
    
    services.Configure<KestrelServerOptions>(options =>
    {
        options.Limits.MaxRequestBodySize = 500_000_000; // 500 MB
    });
    
    services.AddControllers();
}
```

### Method 3: Chunked Upload (For Very Large Files)

```csharp
[HttpPost("upload-chunk")]
public async Task<IActionResult> UploadChunk(
    [FromForm] IFormFile chunk,
    [FromForm] string fileName,
    [FromForm] int chunkNumber,
    [FromForm] int totalChunks)
{
    var uploadsPath = Path.Combine(_environment.WebRootPath, "uploads", "chunks");
    if (!Directory.Exists(uploadsPath))
        Directory.CreateDirectory(uploadsPath);
    
    var chunkPath = Path.Combine(uploadsPath, $"{fileName}.part{chunkNumber}");
    
    using (var stream = new FileStream(chunkPath, FileMode.Create))
    {
        await chunk.CopyToAsync(stream);
    }
    
    // If all chunks uploaded, merge them
    if (chunkNumber == totalChunks - 1)
    {
        await MergeChunks(fileName, totalChunks);
    }
    
    return Ok(new { chunkNumber, totalChunks });
}

private async Task MergeChunks(string fileName, int totalChunks)
{
    var chunksPath = Path.Combine(_environment.WebRootPath, "uploads", "chunks");
    var finalPath = Path.Combine(_environment.WebRootPath, "uploads", fileName);
    
    using (var finalStream = new FileStream(finalPath, FileMode.Create))
    {
        for (int i = 0; i < totalChunks; i++)
        {
            var chunkPath = Path.Combine(chunksPath, $"{fileName}.part{i}");
            using (var chunkStream = new FileStream(chunkPath, FileMode.Open))
            {
                await chunkStream.CopyToAsync(finalStream);
            }
            File.Delete(chunkPath);
        }
    }
}
```

### Best Practices:

1. ✅ **Set appropriate size limits** based on your needs
2. ✅ **Use streaming** for files > 100 MB
3. ✅ **Validate file types** (check extension and MIME type)
4. ✅ **Scan for viruses** in production
5. ✅ **Store files outside web root** for security
6. ✅ **Use chunked upload** for very large files (> 500 MB)
7. ✅ **Implement progress tracking** for better UX

---

## 10. What are MediaTypeFormatters?

### Answer

**MediaTypeFormatters** (now called **Input/Output Formatters** in ASP.NET Core) are components that serialize/deserialize data between HTTP messages and .NET objects.

### Built-in Formatters:

1. **JsonInputFormatter / JsonOutputFormatter** - Handles JSON
2. **XmlDataContractSerializerInputFormatter** - Handles XML (DataContract)
3. **XmlSerializerInputFormatter** - Handles XML (XmlSerializer)

### Custom Formatter Example:

```csharp
public class CsvOutputFormatter : TextOutputFormatter
{
    public CsvOutputFormatter()
    {
        SupportedMediaTypes.Add("text/csv");
        SupportedEncodings.Add(Encoding.UTF8);
    }
    
    public override async Task WriteResponseBodyAsync(
        OutputFormatterWriteContext context, 
        Encoding selectedEncoding)
    {
        var response = context.HttpContext.Response;
        var buffer = new StringBuilder();
        
        if (context.Object is IEnumerable<Product> products)
        {
            // Header
            buffer.AppendLine("Id,Name,Price,Category");
            
            // Data rows
            foreach (var product in products)
            {
                buffer.AppendLine($"{product.Id},{product.Name},{product.Price},{product.Category}");
            }
        }
        
        await response.WriteAsync(buffer.ToString(), selectedEncoding);
    }
    
    protected override bool CanWriteType(Type type)
    {
        return typeof(IEnumerable<Product>).IsAssignableFrom(type);
    }
}

// Register in Startup.cs
services.AddControllers(options =>
{
    options.OutputFormatters.Add(new CsvOutputFormatter());
});
```

### Usage:

```csharp
[HttpGet]
[Produces("application/json", "text/csv")] // Support both formats
public IActionResult GetProducts()
{
    var products = _productService.GetAll();
    return Ok(products); // Returns JSON or CSV based on Accept header
}
```

---

## Summary

- **Content Negotiation**: Client specifies Accept header, server responds in matching format
- **[FromBody]**: Attribute to read data from request body
- **WebHooks**: Real-time event notifications, reduces polling
- **HTTP 400**: Returned when model validation fails
- **SOAP vs REST**: SOAP for enterprise/legacy, REST for modern web/mobile
- **Exception Handling**: Use filters or middleware for centralized error handling
- **CORS**: Enable cross-origin requests with policies
- **Model Validation**: Use data annotations, custom validators, or FluentValidation
- **Large File Uploads**: Configure limits, use streaming, implement chunked upload
- **MediaTypeFormatters**: Serialize/deserialize data (JSON, XML, custom formats)

