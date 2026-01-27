# Security & Secure Coding - Interview Guide

## 1. Secure Coding Practices

### Input Validation and Sanitization

**Principle**: Never trust user input

**Why Validate?**
- Prevent injection attacks
- Ensure data integrity
- Improve user experience

**Validation Techniques:**

**Client-Side Validation:**
```html
<!-- HTML5 validation -->
<input type="email" required pattern="[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$" />
```

**Server-Side Validation (Required!):**
```csharp
[Required(ErrorMessage = "Email is required")]
[EmailAddress(ErrorMessage = "Invalid email format")]
[StringLength(100, MinimumLength = 5)]
public string Email { get; set; }

// In controller
if (!ModelState.IsValid)
{
    return BadRequest(ModelState);
}
```

**Sanitization:**
```csharp
// Remove HTML tags
string sanitized = Regex.Replace(input, "<.*?>", string.Empty);

// Use HTML encoding
string encoded = HttpUtility.HtmlEncode(userInput);

// For rich text, use whitelist approach
// Allow only specific HTML tags
```

**Best Practices:**
- Validate on both client and server (server is mandatory)
- Whitelist approach (allow only known good values)
- Reject invalid input, don't try to "fix" it
- Validate length, format, type, range

### Parameterized Queries (SQL Injection Prevention)

**❌ Vulnerable Code:**
```csharp
string query = $"SELECT * FROM Users WHERE Username = '{username}'";
// If username = "admin' OR '1'='1", this becomes:
// SELECT * FROM Users WHERE Username = 'admin' OR '1'='1'
// Returns all users!
```

**✅ Secure Code - Parameterized Queries:**
```csharp
string query = "SELECT * FROM Users WHERE Username = @Username";
using (var command = new SqlCommand(query, connection))
{
    command.Parameters.AddWithValue("@Username", username);
    // SQL injection impossible - username is treated as data, not code
}
```

**Entity Framework (Safe by Default):**
```csharp
// EF uses parameterized queries automatically
var user = context.Users
    .Where(u => u.Username == username)
    .FirstOrDefault();
```

**Stored Procedures:**
```csharp
using (var command = new SqlCommand("GetUser", connection))
{
    command.CommandType = CommandType.StoredProcedure;
    command.Parameters.AddWithValue("@Username", username);
}
```

**Key Point**: Never concatenate user input into SQL strings!

### Authentication and Authorization Best Practices

**Authentication**: Verifying who the user is  
**Authorization**: Verifying what the user can do

**Password Storage:**
```csharp
// ❌ NEVER store plain text passwords
// ❌ NEVER use MD5, SHA1 (too fast, vulnerable to rainbow tables)

// ✅ Use bcrypt, Argon2, or PBKDF2
using BCrypt.Net;
string hashedPassword = BCrypt.HashPassword(password, BCrypt.GenerateSalt());

// Verify
bool isValid = BCrypt.Verify(password, hashedPassword);
```

**ASP.NET Core Identity:**
```csharp
// Built-in secure password hashing
var user = new IdentityUser { UserName = username };
var result = await _userManager.CreateAsync(user, password);
// Password automatically hashed with PBKDF2
```

**Session Management:**
```csharp
// Use secure, HttpOnly cookies
services.AddSession(options =>
{
    options.Cookie.HttpOnly = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always; // HTTPS only
    options.Cookie.SameSite = SameSiteMode.Strict;
    options.IdleTimeout = TimeSpan.FromMinutes(30);
});
```

**Token-Based Authentication (JWT):**
```csharp
// Set short expiration
var tokenDescriptor = new SecurityTokenDescriptor
{
    Expires = DateTime.UtcNow.AddMinutes(15), // Short-lived
    SigningCredentials = credentials
};
```

**Authorization:**
```csharp
[Authorize(Roles = "Admin")]
public IActionResult AdminPanel() { }

// Resource-based authorization
if (user.Id != resource.OwnerId && !user.IsAdmin)
{
    return Forbid();
}
```

### Secure Session Management

**Session Security:**
- Use HTTPS only (Secure flag)
- HttpOnly cookies (prevent JavaScript access)
- SameSite attribute (prevent CSRF)
- Short timeout
- Regenerate session ID after login

**ASP.NET Core:**
```csharp
services.AddSession(options =>
{
    options.Cookie.Name = ".MyApp.Session";
    options.Cookie.HttpOnly = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    options.Cookie.SameSite = SameSiteMode.Strict;
    options.IdleTimeout = TimeSpan.FromMinutes(20);
});
```

**Session Fixation Prevention:**
```csharp
// Regenerate session ID after login
await HttpContext.SignInAsync(principal);
// Session ID automatically regenerated
```

---

## 2. Common Vulnerabilities

### Cross-Site Scripting (XSS)

**Definition**: Injecting malicious scripts into web pages viewed by others

**Types:**

**1. Reflected XSS:**
- Malicious script in URL or form input
- Reflected back to user immediately
- Example: `https://site.com/search?q=<script>alert('XSS')</script>`

**2. Stored XSS:**
- Malicious script stored in database
- Displayed to all users viewing that content
- More dangerous (affects all users)

**3. DOM-based XSS:**
- Client-side JavaScript manipulation
- Malicious script in URL fragment
- Example: `https://site.com/#<script>alert('XSS')</script>`

**Prevention:**
```csharp
// ✅ HTML Encode output
@Html.DisplayFor(model => model.UserComment)
// Automatically encoded

// Manual encoding
string safe = HttpUtility.HtmlEncode(userInput);

// For rich text, use whitelist
// Allow only specific HTML tags (e.g., <b>, <i>)
```

**Content Security Policy (CSP):**
```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("Content-Security-Policy",
        "default-src 'self'; script-src 'self' 'unsafe-inline';");
    await next();
});
```

### Cross-Site Request Forgery (CSRF)

**Definition**: Forcing user to execute unwanted actions on authenticated site

**Attack Scenario:**
1. User logged into `bank.com`
2. User visits malicious site
3. Malicious site sends request to `bank.com/transfer?to=attacker&amount=1000`
4. Browser includes cookies (user is authenticated)
5. Transfer executes without user's knowledge

**Prevention - Anti-Forgery Tokens:**
```csharp
// In form
@Html.AntiForgeryToken()

// In controller
[HttpPost]
[ValidateAntiForgeryToken]
public IActionResult Transfer(TransferModel model)
{
    // Token validated automatically
}
```

**ASP.NET Core (Automatic):**
```csharp
// Automatically validates for POST/PUT/DELETE
services.AddControllersWithViews(options =>
{
    options.Filters.Add(new AutoValidateAntiforgeryTokenAttribute());
});
```

### SQL Injection

**Already covered in Parameterized Queries section**

**Key Points:**
- Use parameterized queries
- Use ORM (Entity Framework - safe by default)
- Use stored procedures
- Never concatenate user input into SQL

### Insecure Direct Object References (IDOR)

**Definition**: Accessing objects user shouldn't have access to

**Vulnerable Code:**
```csharp
// ❌ No authorization check
[HttpGet("{id}")]
public IActionResult GetOrder(int id)
{
    var order = _db.Orders.Find(id);
    return Ok(order); // User can access any order!
}
```

**Secure Code:**
```csharp
[HttpGet("{id}")]
[Authorize]
public IActionResult GetOrder(int id)
{
    var userId = User.FindFirst(ClaimTypes.NameIdentifier).Value;
    var order = _db.Orders
        .FirstOrDefault(o => o.Id == id && o.UserId == userId);
    
    if (order == null)
        return NotFound();
    
    return Ok(order);
}
```

**Best Practices:**
- Always verify user has permission
- Use indirect references (map IDs)
- Check ownership before returning data

### Security Misconfiguration

**Common Issues:**
- Default passwords
- Unnecessary features enabled
- Error messages revealing information
- Missing security headers
- Outdated software

**Prevention:**
```csharp
// Remove server header
app.Use(async (context, next) =>
{
    context.Response.Headers.Remove("Server");
    await next();
});

// Custom error pages (don't reveal stack traces in production)
if (!env.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
}

// Security headers
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Add("X-Frame-Options", "DENY");
    context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
    await next();
});
```

---

## 3. Security Headers

### Content-Security-Policy (CSP)

**Purpose**: Prevent XSS by controlling which resources can be loaded

**Example:**
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';
```

**Directives:**
- `default-src`: Default policy
- `script-src`: Allowed script sources
- `style-src`: Allowed stylesheet sources
- `img-src`: Allowed image sources
- `connect-src`: Allowed AJAX/fetch sources

**Implementation:**
```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("Content-Security-Policy",
        "default-src 'self'; script-src 'self' https://cdn.example.com;");
    await next();
});
```

### X-Frame-Options

**Purpose**: Prevent clickjacking (embedding site in iframe)

**Values:**
- `DENY`: Never allow framing
- `SAMEORIGIN`: Allow framing from same origin
- `ALLOW-FROM uri`: Allow from specific URI (deprecated)

**Implementation:**
```csharp
context.Response.Headers.Add("X-Frame-Options", "DENY");
```

### X-Content-Type-Options

**Purpose**: Prevent MIME type sniffing

**Value:** `nosniff`

**Implementation:**
```csharp
context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
```

### Strict-Transport-Security (HSTS)

**Purpose**: Force HTTPS connections

**Example:**
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

**Implementation:**
```csharp
if (context.Request.IsHttps)
{
    context.Response.Headers.Add("Strict-Transport-Security",
        "max-age=31536000; includeSubDomains");
}
```

**ASP.NET Core Middleware:**
```csharp
app.UseHsts(); // Adds HSTS header
```

---

## 4. Penetration Testing Knowledge

### OWASP Top 10

**2021 Edition:**
1. **A01: Broken Access Control** - Unauthorized access
2. **A02: Cryptographic Failures** - Weak encryption
3. **A03: Injection** - SQL, XSS, command injection
4. **A04: Insecure Design** - Design flaws
5. **A05: Security Misconfiguration** - Default configs, missing patches
6. **A06: Vulnerable Components** - Outdated libraries
7. **A07: Authentication Failures** - Weak authentication
8. **A08: Software and Data Integrity** - CI/CD vulnerabilities
9. **A09: Security Logging Failures** - Insufficient logging
10. **A10: Server-Side Request Forgery** - SSRF attacks

### Security Testing Methodologies

**Static Application Security Testing (SAST):**
- Analyze source code
- Tools: SonarQube, Veracode, Checkmarx

**Dynamic Application Security Testing (DAST):**
- Test running application
- Tools: OWASP ZAP, Burp Suite

**Penetration Testing:**
- Manual security testing
- Simulate real attacks
- Identify vulnerabilities

**Vulnerability Assessment:**
- Automated scanning
- Identify known vulnerabilities
- Regular scans recommended

---

## Interview Questions to Prepare

1. **What is SQL injection? How do you prevent it?**
2. **Explain XSS attacks. What are the different types?**
3. **What is CSRF? How do you prevent it?**
4. **How should you store passwords?**
5. **What is the difference between authentication and authorization?**
6. **What security headers should you implement?**
7. **What is the OWASP Top 10?**
8. **How do you prevent IDOR vulnerabilities?**
9. **What is input validation? Why is it important?**
10. **How do you secure session management?**

