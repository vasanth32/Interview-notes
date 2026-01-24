# MVC Pattern & Concepts - Interview Questions & Answers

## 1. Can you explain the MVC pattern and its components?

### Answer

**MVC (Model-View-Controller)** is an architectural pattern that separates an application into three main components:

### Components:

#### **1. Model**
- **Purpose**: Represents data and business logic
- **Responsibilities**:
  - Data validation
  - Business rules
  - Data access
  - State management

#### **2. View**
- **Purpose**: User interface (UI)
- **Responsibilities**:
  - Display data to user
  - Receive user input
  - Present information

#### **3. Controller**
- **Purpose**: Handles user input and coordinates between Model and View
- **Responsibilities**:
  - Process user requests
  - Invoke appropriate model methods
  - Select appropriate view
  - Handle routing

### MVC Flow:

```
User Action → Controller → Model → View → User
     ↑                                        ↓
     └────────────────────────────────────────┘
```

### Example:

#### Model:

```csharp
public class Product
{
    public int Id { get; set; }
    
    [Required]
    [StringLength(100)]
    public string Name { get; set; }
    
    [Range(0.01, 10000)]
    public decimal Price { get; set; }
    
    public string Category { get; set; }
}

public interface IProductService
{
    List<Product> GetAllProducts();
    Product GetProductById(int id);
    void CreateProduct(Product product);
    void UpdateProduct(Product product);
    void DeleteProduct(int id);
}
```

#### Controller:

```csharp
public class ProductsController : Controller
{
    private readonly IProductService _productService;
    
    public ProductsController(IProductService productService)
    {
        _productService = productService;
    }
    
    // GET: Products
    public IActionResult Index()
    {
        var products = _productService.GetAllProducts();
        return View(products); // Returns View
    }
    
    // GET: Products/Details/5
    public IActionResult Details(int id)
    {
        var product = _productService.GetProductById(id);
        if (product == null)
        {
            return NotFound();
        }
        return View(product);
    }
    
    // GET: Products/Create
    public IActionResult Create()
    {
        return View();
    }
    
    // POST: Products/Create
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create(Product product)
    {
        if (ModelState.IsValid)
        {
            _productService.CreateProduct(product); // Uses Model
            return RedirectToAction(nameof(Index));
        }
        return View(product);
    }
}
```

#### View:

```razor
@* Views/Products/Index.cshtml *@
@model List<Product>

<h2>Products</h2>

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Price</th>
            <th>Category</th>
        </tr>
    </thead>
    <tbody>
        @foreach (var product in Model)
        {
            <tr>
                <td>@product.Name</td>
                <td>@product.Price.ToString("C")</td>
                <td>@product.Category</td>
            </tr>
        }
    </tbody>
</table>

<a asp-action="Create">Create New</a>
```

### Benefits of MVC:

1. **Separation of Concerns**: Each component has a single responsibility
2. **Testability**: Easy to unit test models and controllers
3. **Maintainability**: Changes to one component don't affect others
4. **Reusability**: Models can be reused across different views
5. **Scalability**: Easy to add new features

---

## 2. How does routing work in ASP.NET MVC?

### Answer

**Routing** maps URLs to controller actions. ASP.NET Core uses convention-based and attribute-based routing.

### Convention-Based Routing:

```csharp
// In Startup.cs
app.UseEndpoints(endpoints =>
{
    endpoints.MapControllerRoute(
        name: "default",
        pattern: "{controller=Home}/{action=Index}/{id?}");
    
    // Custom route
    endpoints.MapControllerRoute(
        name: "products",
        pattern: "products/{category}/{id}",
        defaults: new { controller = "Products", action = "Details" });
});
```

**Route Pattern Explanation:**
- `{controller}` - Controller name (e.g., "Products")
- `{action}` - Action method name (e.g., "Index")
- `{id?}` - Optional parameter

**Examples:**
- `/Products/Index` → `ProductsController.Index()`
- `/Products/Details/5` → `ProductsController.Details(5)`
- `/` → `HomeController.Index()` (default)

### Attribute Routing:

```csharp
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    [Route("")] // GET /api/products
    public IActionResult GetAll()
    {
        return Ok();
    }
    
    [HttpGet("{id}")] // GET /api/products/5
    public IActionResult GetById(int id)
    {
        return Ok();
    }
    
    [HttpPost]
    [Route("create")] // POST /api/products/create
    public IActionResult Create(Product product)
    {
        return Ok();
    }
    
    [HttpGet("category/{category}")] // GET /api/products/category/electronics
    public IActionResult GetByCategory(string category)
    {
        return Ok();
    }
}
```

### Route Constraints:

```csharp
[HttpGet("{id:int}")] // Only accepts integers
public IActionResult GetById(int id)
{
    return Ok();
}

[HttpGet("{name:alpha}")] // Only accepts alphabetic characters
public IActionResult GetByName(string name)
{
    return Ok();
}

[HttpGet("{id:min(1)}")] // Minimum value of 1
public IActionResult GetById(int id)
{
    return Ok();
}

[HttpGet("{id:range(1,100)}")] // Range between 1 and 100
public IActionResult GetById(int id)
{
    return Ok();
}
```

### Route Parameters:

```csharp
[HttpGet("search/{category}/{minPrice?}")]
public IActionResult Search(string category, decimal? minPrice = 0)
{
    // /api/products/search/electronics/100
    // category = "electronics", minPrice = 100
    return Ok();
}

[HttpGet("filter")]
public IActionResult Filter([FromQuery] string category, [FromQuery] decimal? price)
{
    // /api/products/filter?category=electronics&price=100
    return Ok();
}
```

### Custom Route Attributes:

```csharp
[Route("api/v{version:apiVersion}/[controller]")]
[ApiVersion("1.0")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts()
    {
        return Ok();
    }
}
```

### Route Ordering:

```csharp
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    [HttpGet("special")] // More specific route first
    public IActionResult GetSpecial()
    {
        return Ok();
    }
    
    [HttpGet("{id}")] // Generic route after specific
    public IActionResult GetById(int id)
    {
        return Ok();
    }
}
```

---

## 3. What are Action Filters in MVC?

### Answer

**Action Filters** are attributes that allow you to execute code before or after action methods run.

### Types of Action Filters:

1. **Authorization Filters** - `IAuthorizationFilter`
2. **Action Filters** - `IActionFilter`, `IAsyncActionFilter`
3. **Result Filters** - `IResultFilter`, `IAsyncResultFilter`
4. **Exception Filters** - `IExceptionFilter`

### Built-in Action Filters:

```csharp
[Authorize] // Requires authentication
[AllowAnonymous] // Skip authorization
[ValidateAntiForgeryToken] // CSRF protection
[HttpPost] // HTTP method constraint
[RequireHttps] // Require HTTPS
[OutputCache] // Cache output
```

### Custom Action Filter:

```csharp
public class LogActionFilter : ActionFilterAttribute
{
    public override void OnActionExecuting(ActionExecutingContext context)
    {
        // Before action executes
        var controllerName = context.RouteData.Values["controller"];
        var actionName = context.RouteData.Values["action"];
        
        Console.WriteLine($"Executing {controllerName}.{actionName}");
        
        base.OnActionExecuting(context);
    }
    
    public override void OnActionExecuted(ActionExecutedContext context)
    {
        // After action executes
        var result = context.Result;
        Console.WriteLine($"Executed with result: {result}");
        
        base.OnActionExecuted(context);
    }
}

// Usage
[LogActionFilter]
public IActionResult Index()
{
    return View();
}
```

### Async Action Filter:

```csharp
public class AsyncLogActionFilter : IAsyncActionFilter
{
    public async Task OnActionExecutionAsync(
        ActionExecutingContext context,
        ActionExecutionDelegate next)
    {
        // Before action
        var startTime = DateTime.UtcNow;
        Console.WriteLine("Action starting");
        
        // Execute action
        var executedContext = await next();
        
        // After action
        var duration = DateTime.UtcNow - startTime;
        Console.WriteLine($"Action completed in {duration.TotalMilliseconds}ms");
    }
}
```

### Authorization Filter:

```csharp
public class CustomAuthorizeAttribute : Attribute, IAuthorizationFilter
{
    private readonly string _requiredRole;
    
    public CustomAuthorizeAttribute(string requiredRole)
    {
        _requiredRole = requiredRole;
    }
    
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var user = context.HttpContext.User;
        
        if (!user.Identity.IsAuthenticated)
        {
            context.Result = new UnauthorizedResult();
            return;
        }
        
        if (!user.IsInRole(_requiredRole))
        {
            context.Result = new ForbidResult();
        }
    }
}

// Usage
[CustomAuthorize("Admin")]
public IActionResult Delete(int id)
{
    return View();
}
```

### Result Filter:

```csharp
public class CacheResultFilter : IResultFilter
{
    public void OnResultExecuting(ResultExecutingContext context)
    {
        // Before result execution
        context.HttpContext.Response.Headers.Add("Cache-Control", "public, max-age=3600");
    }
    
    public void OnResultExecuted(ResultExecutedContext context)
    {
        // After result execution
    }
}
```

### Exception Filter:

```csharp
public class CustomExceptionFilter : IExceptionFilter
{
    public void OnException(ExceptionContext context)
    {
        if (context.Exception is ArgumentNullException)
        {
            context.Result = new BadRequestObjectResult(
                new { error = context.Exception.Message });
            context.ExceptionHandled = true;
        }
    }
}
```

### Applying Filters:

```csharp
// At action level
[LogActionFilter]
public IActionResult Index()
{
    return View();
}

// At controller level
[Authorize]
public class ProductsController : Controller
{
    // All actions require authorization
}

// Globally
services.AddControllers(options =>
{
    options.Filters.Add<LogActionFilter>();
});
```

---

## 4. How do you manage session state in MVC?

### Answer

**Session state** stores user-specific data on the server between requests.

### Configuration:

```csharp
// In Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    services.AddDistributedMemoryCache(); // For session storage
    
    services.AddSession(options =>
    {
        options.IdleTimeout = TimeSpan.FromMinutes(30);
        options.Cookie.HttpOnly = true;
        options.Cookie.IsEssential = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
    });
    
    services.AddControllersWithViews();
}

public void Configure(IApplicationBuilder app)
{
    app.UseSession(); // Must be before UseRouting
    app.UseRouting();
    app.UseEndpoints(endpoints => endpoints.MapControllers());
}
```

### Using Session:

```csharp
public class CartController : Controller
{
    // Set session value
    [HttpPost]
    public IActionResult AddToCart(int productId)
    {
        var cart = HttpContext.Session.Get<List<CartItem>>("Cart") ?? new List<CartItem>();
        cart.Add(new CartItem { ProductId = productId, Quantity = 1 });
        HttpContext.Session.Set("Cart", cart);
        
        return RedirectToAction("Index");
    }
    
    // Get session value
    public IActionResult Index()
    {
        var cart = HttpContext.Session.Get<List<CartItem>>("Cart");
        return View(cart);
    }
    
    // Remove session
    public IActionResult ClearCart()
    {
        HttpContext.Session.Remove("Cart");
        return RedirectToAction("Index");
    }
    
    // Clear all session
    public IActionResult Logout()
    {
        HttpContext.Session.Clear();
        return RedirectToAction("Login", "Account");
    }
}
```

### Session Extension Methods:

```csharp
public static class SessionExtensions
{
    public static void Set<T>(this ISession session, string key, T value)
    {
        session.SetString(key, JsonSerializer.Serialize(value));
    }
    
    public static T Get<T>(this ISession session, string key)
    {
        var value = session.GetString(key);
        return value == null ? default(T) : JsonSerializer.Deserialize<T>(value);
    }
}
```

### Storing Complex Objects:

```csharp
// Store user info
HttpContext.Session.SetString("UserId", user.Id.ToString());
HttpContext.Session.SetString("UserName", user.Username);

// Store complex object
var userPreferences = new UserPreferences { Theme = "Dark", Language = "en" };
HttpContext.Session.Set("Preferences", userPreferences);

// Retrieve
var userId = HttpContext.Session.GetString("UserId");
var preferences = HttpContext.Session.Get<UserPreferences>("Preferences");
```

### Session vs TempData:

```csharp
// Session - persists until explicitly removed
HttpContext.Session.SetString("Message", "Hello");

// TempData - persists for one request, then removed
TempData["Message"] = "Hello";
TempData.Keep("Message"); // Keep for one more request
```

### Distributed Session (Redis/SQL Server):

```csharp
// Redis
services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = "localhost:6379";
});

services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
});

// SQL Server
services.AddDistributedSqlServerCache(options =>
{
    options.ConnectionString = Configuration.GetConnectionString("DefaultConnection");
    options.SchemaName = "dbo";
    options.TableName = "Sessions";
});
```

---

## 5. Explain the concept of ViewModels in MVC.

### Answer

**ViewModels** are classes specifically designed to pass data from controllers to views. They differ from domain models by containing only the data needed for a specific view.

### Why Use ViewModels?

1. **Separation of Concerns**: Views don't depend on domain models
2. **Security**: Only expose necessary data
3. **Flexibility**: Combine data from multiple sources
4. **Validation**: View-specific validation rules
5. **Performance**: Only load needed data

### Example: Product ViewModel

```csharp
// Domain Model
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
    public string InternalNotes { get; set; } // Should not be exposed
    public DateTime CreatedDate { get; set; }
    public int SupplierId { get; set; }
}

// ViewModel for displaying product
public class ProductViewModel
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string FormattedPrice { get; set; } // Formatted for display
    public string Category { get; set; }
}

// ViewModel for creating product
public class CreateProductViewModel
{
    [Required]
    [StringLength(100)]
    public string Name { get; set; }
    
    [Range(0.01, 10000)]
    public decimal Price { get; set; }
    
    [Required]
    public string Category { get; set; }
    
    public List<SelectListItem> Categories { get; set; } // For dropdown
}
```

### Usage in Controller:

```csharp
public class ProductsController : Controller
{
    private readonly IProductService _productService;
    
    public ProductsController(IProductService productService)
    {
        _productService = productService;
    }
    
    public IActionResult Index()
    {
        var products = _productService.GetAllProducts();
        
        // Map domain models to view models
        var viewModels = products.Select(p => new ProductViewModel
        {
            Id = p.Id,
            Name = p.Name,
            FormattedPrice = p.Price.ToString("C"),
            Category = p.Category
        }).ToList();
        
        return View(viewModels);
    }
    
    [HttpGet]
    public IActionResult Create()
    {
        var viewModel = new CreateProductViewModel
        {
            Categories = new List<SelectListItem>
            {
                new SelectListItem { Value = "Electronics", Text = "Electronics" },
                new SelectListItem { Value = "Clothing", Text = "Clothing" },
                new SelectListItem { Value = "Books", Text = "Books" }
            }
        };
        
        return View(viewModel);
    }
    
    [HttpPost]
    public IActionResult Create(CreateProductViewModel viewModel)
    {
        if (!ModelState.IsValid)
        {
            viewModel.Categories = GetCategories(); // Re-populate dropdown
            return View(viewModel);
        }
        
        // Map view model to domain model
        var product = new Product
        {
            Name = viewModel.Name,
            Price = viewModel.Price,
            Category = viewModel.Category
        };
        
        _productService.CreateProduct(product);
        return RedirectToAction("Index");
    }
}
```

### Complex ViewModel Example:

```csharp
// ViewModel combining multiple domain models
public class ProductDetailsViewModel
{
    public ProductViewModel Product { get; set; }
    public List<ReviewViewModel> Reviews { get; set; }
    public List<RelatedProductViewModel> RelatedProducts { get; set; }
    public bool IsInCart { get; set; }
    public int CartQuantity { get; set; }
}

// Usage
public IActionResult Details(int id)
{
    var product = _productService.GetProductById(id);
    var reviews = _reviewService.GetReviewsByProductId(id);
    var relatedProducts = _productService.GetRelatedProducts(id);
    var isInCart = _cartService.IsProductInCart(id);
    
    var viewModel = new ProductDetailsViewModel
    {
        Product = MapToViewModel(product),
        Reviews = reviews.Select(r => MapToReviewViewModel(r)).ToList(),
        RelatedProducts = relatedProducts.Select(p => MapToRelatedViewModel(p)).ToList(),
        IsInCart = isInCart,
        CartQuantity = isInCart ? _cartService.GetQuantity(id) : 0
    };
    
    return View(viewModel);
}
```

### AutoMapper for ViewModel Mapping:

```csharp
// Install AutoMapper

// Create mapping profile
public class ProductProfile : Profile
{
    public ProductProfile()
    {
        CreateMap<Product, ProductViewModel>()
            .ForMember(dest => dest.FormattedPrice, 
                opt => opt.MapFrom(src => src.Price.ToString("C")));
        
        CreateMap<CreateProductViewModel, Product>();
    }
}

// Register
services.AddAutoMapper(typeof(ProductProfile));

// Usage in controller
public class ProductsController : Controller
{
    private readonly IMapper _mapper;
    
    public ProductsController(IMapper mapper)
    {
        _mapper = mapper;
    }
    
    public IActionResult Index()
    {
        var products = _productService.GetAllProducts();
        var viewModels = _mapper.Map<List<ProductViewModel>>(products);
        return View(viewModels);
    }
}
```

---

## 6. Difference in Middleware and MVC Filters?

### Answer

Both middleware and filters execute code during request processing, but at different stages and with different scopes.

### Comparison:

| Feature | Middleware | Filters |
|---------|-----------|---------|
| **Scope** | Application-wide | Controller/Action specific |
| **Execution** | Early in pipeline | After routing |
| **Access** | HttpContext only | HttpContext + ActionContext |
| **Order** | Registration order | Filter order |
| **Use Case** | Cross-cutting concerns | Action-specific logic |

### Middleware:

```csharp
// Runs for ALL requests, before routing
public class LoggingMiddleware
{
    private readonly RequestDelegate _next;
    
    public LoggingMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        // Executes for every request
        Console.WriteLine($"Request: {context.Request.Path}");
        await _next(context);
    }
}

// Register early in pipeline
app.UseMiddleware<LoggingMiddleware>();
app.UseRouting();
```

**Characteristics:**
- ✅ Runs before routing
- ✅ Executes for all requests
- ✅ Only has access to `HttpContext`
- ✅ Good for: Authentication, logging, CORS, exception handling

### Filters:

```csharp
// Runs only for specific controllers/actions, after routing
public class LogActionFilter : ActionFilterAttribute
{
    public override void OnActionExecuting(ActionExecutingContext context)
    {
        // Executes only for actions with this filter
        var controller = context.RouteData.Values["controller"];
        var action = context.RouteData.Values["action"];
        Console.WriteLine($"Action: {controller}.{action}");
    }
}

// Apply to specific actions
[LogActionFilter]
public IActionResult Index()
{
    return View();
}
```

**Characteristics:**
- ✅ Runs after routing
- ✅ Executes only for filtered actions
- ✅ Has access to `ActionContext` (controller, action, model state)
- ✅ Good for: Action-specific logging, model validation, result transformation

### Execution Order:

```
Request
  ↓
Middleware 1 (Logging)
  ↓
Middleware 2 (Authentication)
  ↓
Routing
  ↓
Authorization Filter
  ↓
Action Filter (OnActionExecuting)
  ↓
Action Method
  ↓
Action Filter (OnActionExecuted)
  ↓
Result Filter
  ↓
Response
```

### When to Use Each:

#### Use Middleware For:
- ✅ Authentication/Authorization (before routing)
- ✅ Request logging (all requests)
- ✅ CORS handling
- ✅ Exception handling (global)
- ✅ Request/Response transformation

#### Use Filters For:
- ✅ Action-specific logging
- ✅ Model validation
- ✅ Result caching
- ✅ Action-specific authorization
- ✅ Response formatting

### Example: Both Working Together

```csharp
// Middleware - logs all requests
public class RequestLoggingMiddleware
{
    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        Console.WriteLine($"Request: {context.Request.Method} {context.Request.Path}");
        await next(context);
    }
}

// Filter - logs specific actions
[LogActionFilter]
public class ProductsController : Controller
{
    [HttpGet]
    public IActionResult Index()
    {
        return View();
    }
}

// Execution:
// 1. RequestLoggingMiddleware executes (logs: "GET /Products")
// 2. Routing happens
// 3. LogActionFilter executes (logs: "Action: Products.Index")
// 4. Index() executes
```

### Key Differences Summary:

1. **Timing**: Middleware runs before routing; Filters run after
2. **Scope**: Middleware is global; Filters are selective
3. **Context**: Middleware has `HttpContext`; Filters have `ActionContext`
4. **Purpose**: Middleware for infrastructure; Filters for application logic

---

## Summary

- **MVC Pattern**: Separates application into Model (data/logic), View (UI), and Controller (coordination)
- **Routing**: Maps URLs to controller actions using convention-based or attribute-based routing
- **Action Filters**: Attributes that execute code before/after actions (authorization, logging, caching)
- **Session State**: Server-side storage for user-specific data between requests
- **ViewModels**: Classes designed for views, containing only necessary data, separate from domain models
- **Middleware vs Filters**: Middleware runs early (global), Filters run after routing (selective); use middleware for infrastructure, filters for application logic

