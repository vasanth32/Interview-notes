# Interview Focused Answers - Critical Topics

## 🔥 2️⃣ IIS + Production Hosting (VERY IMPORTANT)

### IIS vs Kestrel (Simple Difference)

**Kestrel:**
- **What**: Cross-platform web server built into ASP.NET Core
- **Purpose**: Development and lightweight hosting
- **Platform**: Windows, Linux, macOS
- **Performance**: Fast, lightweight
- **Limitations**: Not production-ready alone (needs reverse proxy)

**IIS (Internet Information Services):**
- **What**: Microsoft's full-featured web server for Windows
- **Purpose**: Production hosting on Windows Server
- **Platform**: Windows only
- **Features**: 
  - Advanced security
  - Load balancing
  - Application pools
  - URL rewriting
  - Request filtering
  - Built-in monitoring

**Key Difference:**
- **Kestrel**: Development server, fast but basic
- **IIS**: Production server, feature-rich, enterprise-grade
- **Common Setup**: Kestrel behind IIS (IIS as reverse proxy)

**Interview Answer:**
> "Kestrel is the cross-platform web server built into ASP.NET Core, great for development. IIS is Microsoft's production web server for Windows that provides enterprise features like application pools, URL rewriting, and advanced security. In production, we typically run Kestrel behind IIS, where IIS acts as a reverse proxy."

---

### Application Pool (Why Separate)

**What is an Application Pool?**
- Isolated environment for running web applications
- Each pool has its own worker process (w3wp.exe)
- Separate memory space and configuration

**Why Use Separate Application Pools?**

1. **Isolation**
   - One app crash doesn't affect others
   - Memory leaks contained
   - Process recycling independent

2. **Different .NET Versions**
   - App Pool 1: .NET Framework 4.8
   - App Pool 2: .NET Core 6.0
   - Each can run different runtime

3. **Security**
   - Different identity (user account)
   - Different permissions
   - Principle of least privilege

4. **Performance**
   - Independent resource limits
   - Separate recycling schedules
   - Better resource management

5. **Maintenance**
   - Update one app without affecting others
   - Restart one app pool independently
   - Deploy without downtime for other apps

**Interview Answer:**
> "Application pools provide isolation between web applications. If one application crashes or has a memory leak, it doesn't affect others. We also use separate pools for different .NET versions, security requirements, and to allow independent updates and restarts without affecting other applications."

---

### URL Rewrite (HTTP → HTTPS)

**Purpose**: Automatically redirect HTTP traffic to HTTPS for security

**Why Needed:**
- Force encrypted connections
- Protect user data
- SEO benefits
- Security compliance

**Implementation in IIS:**

**Method 1: IIS Manager**
1. Install URL Rewrite module
2. Select website
3. Double-click "URL Rewrite"
4. Add rule → Blank rule
5. Configure:
   - **Name**: Redirect to HTTPS
   - **Pattern**: `(.*)`
   - **Conditions**: `{HTTPS}` off
   - **Action**: Redirect
   - **URL**: `https://{HTTP_HOST}/{R:1}`
   - **Type**: Permanent (301)

**Method 2: web.config**
```xml
<system.webServer>
    <rewrite>
        <rules>
            <rule name="Redirect to HTTPS" stopProcessing="true">
                <match url="(.*)" />
                <conditions>
                    <add input="{HTTPS}" pattern="off" />
                </conditions>
                <action type="Redirect" 
                        url="https://{HTTP_HOST}/{R:1}" 
                        redirectType="Permanent" />
            </rule>
        </rules>
    </rewrite>
</system.webServer>
```

**Interview Answer:**
> "We use URL Rewrite module in IIS to automatically redirect all HTTP requests to HTTPS. This ensures all traffic is encrypted. The rule checks if HTTPS is off, and if so, redirects to the same URL but with HTTPS protocol using a 301 permanent redirect."

---

### IP Whitelisting (Where & Why)

**Where to Implement:**

1. **IIS IP Restrictions** (Recommended for web apps)
   - Location: IIS Manager → Website → IP Address and Domain Restrictions
   - **web.config**:
   ```xml
   <system.webServer>
       <security>
           <ipSecurity>
               <add ipAddress="192.168.1.100" allowed="true" />
               <add ipAddress="10.0.0.0" subnetMask="255.0.0.0" allowed="false" />
           </ipSecurity>
       </security>
   </system.webServer>
   ```

2. **Application Code** (Middleware/Filter)
   ```csharp
   public class IPWhitelistMiddleware
   {
       private readonly string[] _allowedIPs = { "192.168.1.100" };
       
       public async Task InvokeAsync(HttpContext context)
       {
           var ip = context.Connection.RemoteIpAddress.ToString();
           if (!_allowedIPs.Contains(ip))
           {
               context.Response.StatusCode = 403;
               return;
           }
           await _next(context);
       }
   }
   ```

3. **Windows Firewall**
   - Network-level blocking
   - PowerShell: `New-NetFirewallRule`

4. **Azure NSG** (Cloud)
   - Network Security Groups
   - Filter at network level

**Why Use IP Whitelisting:**

1. **Admin Panels**
   - Only allow office IPs
   - Prevent unauthorized access

2. **API Endpoints**
   - Partner integrations
   - Specific client IPs only

3. **Internal Applications**
   - Company network only
   - VPN access required

4. **Security**
   - Reduce attack surface
   - Block malicious IPs
   - Compliance requirements

**Interview Answer:**
> "IP whitelisting restricts access to specific IP addresses. We implement it in IIS for web applications, in application code using middleware for programmatic control, or in Windows Firewall for network-level security. Common use cases include admin panels, partner API endpoints, and internal applications where we only want specific IPs to access the system."

---

### Basic IIS Logs Location

**Default Location:**
```
C:\inetpub\logs\LogFiles\W3SVC[SiteID]\
```

**Finding Your Site ID:**
1. IIS Manager → Sites
2. Select your website
3. Look at "ID" column (e.g., 1, 2, 3)

**Log File Naming:**
- Format: `u_ex[YYMMDD].log`
- Example: `u_ex240115.log` (January 15, 2024)
- One file per day

**Important Fields:**
- **date, time**: When request occurred
- **c-ip**: Client IP address
- **cs-method**: HTTP method (GET, POST)
- **cs-uri-stem**: Requested URL
- **sc-status**: HTTP status code (200, 404, 500)
- **time-taken**: Request duration (milliseconds)

**Viewing Logs:**
```powershell
# View recent 404 errors
Get-Content C:\inetpub\logs\LogFiles\W3SVC1\u_ex*.log | 
    Select-String " 404 "

# Find slow requests (>1000ms)
Get-Content C:\inetpub\logs\LogFiles\W3SVC1\u_ex*.log | 
    Select-String " [0-9]{4,} "
```

**Interview Answer:**
> "IIS logs are stored in `C:\inetpub\logs\LogFiles\W3SVC[SiteID]\` where SiteID is the website ID from IIS Manager. Log files are named `u_ex[YYMMDD].log` with one file per day. Key fields include client IP, HTTP method, requested URL, status code, and response time. I use these logs to troubleshoot 404 errors, identify slow requests, and investigate security incidents."

---

## 🔥 3️⃣ HTTP Status Codes + Browser Debugging

### HTTP Status Codes (Memorize These)

**200 OK**
- Request succeeded
- Most common success response
- **Use**: Successful GET, PUT requests

**201 Created**
- Resource successfully created
- **Use**: After POST requests creating new resources
- **Response**: Should include `Location` header with new resource URL

**400 Bad Request**
- Client sent invalid request
- **Common Causes**:
  - Model validation failed
  - Invalid JSON format
  - Missing required fields
- **Interview Example**: "When model validation fails in ASP.NET Core, we return 400 with validation errors."

**401 Unauthorized**
- Authentication required or failed
- **Meaning**: "Who are you?" - Not authenticated
- **Response**: Should include `WWW-Authenticate` header
- **Use**: Missing/invalid credentials, expired token

**403 Forbidden**
- Server understood but refuses to authorize
- **Meaning**: "I know who you are, but you can't do this"
- **Use**: User authenticated but lacks permission
- **Key Difference from 401**: User is authenticated, just not authorized

**404 Not Found**
- Resource doesn't exist
- **Common Causes**:
  - Wrong URL
  - Resource deleted
  - Routing misconfiguration
- **Use**: File not found, route not matched

**500 Internal Server Error**
- Generic server error
- **Meaning**: Something went wrong on server
- **Use**: Unhandled exceptions, server misconfiguration
- **Important**: Don't expose stack traces in production

**502 Bad Gateway**
- Gateway received invalid response from upstream
- **Meaning**: Problem with upstream server (not your app)
- **Use**: Load balancer can't reach app server, app server crashed

**503 Service Unavailable**
- Server temporarily unavailable
- **Common Causes**:
  - Server overloaded
  - Maintenance mode
  - Database connection lost
- **Response**: Should include `Retry-After` header
- **Use**: Planned maintenance, high load

**Interview Quick Reference:**
- **2xx**: Success
- **4xx**: Client error (their fault)
- **5xx**: Server error (our fault)
- **401**: Not authenticated
- **403**: Not authorized
- **404**: Not found
- **500**: Server error

---

### Browser Debugging

**Network Tab**

**Purpose**: Inspect all HTTP requests and responses

**How to Use:**
1. Open DevTools (F12)
2. Click "Network" tab
3. Reload page (Ctrl+R)
4. Click any request to see details

**Key Information:**
- **Status**: HTTP status code (look for 4xx, 5xx)
- **Type**: Request type (XHR, Document, JS, CSS)
- **Size**: Response size
- **Time**: Request duration
- **Waterfall**: Visual timeline

**What to Check:**
- **Failed Requests**: Red entries (4xx, 5xx)
- **Slow Requests**: Long time values
- **Request Headers**: Authorization, Content-Type
- **Response**: Error messages, data format
- **Timing**: Where time is spent (DNS, connection, waiting, receiving)

**Interview Answer:**
> "I use the Network tab to see all HTTP requests. I look for failed requests in red, check status codes, examine request/response headers, and identify slow requests. The waterfall view shows timing breakdown, helping me identify if delays are from DNS, connection, or server response time."

---

**Console Errors**

**Purpose**: JavaScript errors and warnings

**How to Use:**
1. Open DevTools (F12)
2. Click "Console" tab
3. Errors appear in red

**Common Errors:**
- **Syntax Errors**: Code mistakes
- **Runtime Errors**: Errors during execution
- **Network Errors**: Failed API calls
- **CORS Errors**: Cross-origin issues

**What to Look For:**
- Red error messages
- Stack traces (click to see)
- Line numbers
- Error types (TypeError, ReferenceError, etc.)

**Interview Answer:**
> "The Console tab shows JavaScript errors in red. I check for syntax errors, runtime errors, and network failures. Clicking an error shows the stack trace and line number, helping me identify where the problem occurred in the code."

---

**CORS Error Meaning**

**What is CORS?**
- Cross-Origin Resource Sharing
- Browser security feature
- Prevents websites from making requests to different domains

**CORS Error:**
```
Access to fetch at 'https://api.example.com/data' from origin 
'https://mysite.com' has been blocked by CORS policy: 
No 'Access-Control-Allow-Origin' header is present.
```

**What It Means:**
- Browser blocked the request
- Server didn't send proper CORS headers
- Different origin (domain, port, or protocol)

**How to Fix (Server-Side):**
```csharp
// ASP.NET Core
services.AddCors(options =>
{
    options.AddPolicy("AllowSpecificOrigin",
        builder => builder.WithOrigins("https://mysite.com")
                         .AllowAnyMethod()
                         .AllowAnyHeader());
});

app.UseCors("AllowSpecificOrigin");
```

**Interview Answer:**
> "CORS errors occur when a browser blocks requests to a different domain for security. The server must send `Access-Control-Allow-Origin` header to allow the request. This is a browser security feature preventing malicious sites from accessing your API. I fix it by configuring CORS on the server to allow specific origins."

---

## 🔥 4️⃣ SQL (Production-Level Only)

### Joins

**INNER JOIN**
- Returns rows with matching values in both tables
- **Use**: Get related data from multiple tables
```sql
SELECT u.Username, o.OrderDate
FROM Users u
INNER JOIN Orders o ON u.UserID = o.UserID;
```

**LEFT JOIN (LEFT OUTER JOIN)**
- Returns all rows from left table, matching from right
- NULL for non-matching right rows
- **Use**: Get all users, even if they have no orders
```sql
SELECT u.Username, o.OrderID
FROM Users u
LEFT JOIN Orders o ON u.UserID = o.UserID;
```

**RIGHT JOIN**
- Returns all rows from right table, matching from left
- **Use**: Less common, usually use LEFT JOIN instead

**FULL OUTER JOIN**
- Returns all rows from both tables
- NULL for non-matching rows

**Interview Answer:**
> "INNER JOIN returns only matching rows from both tables. LEFT JOIN returns all rows from the left table with matching rows from the right, using NULL for non-matches. I use INNER JOIN when I need related data, and LEFT JOIN when I want all records from one table regardless of matches."

---

### Index Basics

**What is an Index?**
- Database structure that speeds up data retrieval
- Like an index in a book - points to data location

**Types:**
- **Clustered Index**: Physical order of data (one per table, usually primary key)
- **Non-Clustered Index**: Separate structure pointing to data (multiple allowed)

**When to Create:**
- Foreign keys
- Frequently queried columns
- Columns in WHERE clauses
- Columns in JOIN conditions
- Columns in ORDER BY

**Trade-offs:**
- ✅ Faster SELECT queries
- ❌ Slower INSERT/UPDATE/DELETE (indexes must be updated)
- ❌ Additional storage space

**Example:**
```sql
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_Orders_UserID ON Orders(UserID);
```

**Interview Answer:**
> "Indexes speed up data retrieval by creating a structure that points to data locations. I create indexes on foreign keys, frequently queried columns, and columns used in WHERE/JOIN clauses. The trade-off is faster reads but slower writes, as indexes must be maintained."

---

### Stored Procedures (When to Use)

**What is a Stored Procedure?**
- Precompiled SQL code stored in database
- Can accept parameters
- Can return results

**When to Use:**

1. **Performance**
   - Precompiled (faster execution)
   - Reduced network traffic
   - Execution plan cached

2. **Security**
   - Parameterized (prevents SQL injection)
   - Control access (grant execute permission)
   - Hide database structure

3. **Business Logic**
   - Complex operations
   - Multiple statements
   - Transactions

4. **Reusability**
   - Used by multiple applications
   - Centralized logic
   - Easier maintenance

**Example:**
```sql
CREATE PROCEDURE GetUserOrders
    @UserID INT
AS
BEGIN
    SELECT * FROM Orders WHERE UserID = @UserID;
END;
```

**When NOT to Use:**
- Simple queries (use ORM instead)
- Rapidly changing requirements
- Need database portability

**Interview Answer:**
> "I use stored procedures for performance-critical queries, complex business logic, and security. They're precompiled for faster execution, use parameters to prevent SQL injection, and centralize logic. However, for simple CRUD operations, I prefer using an ORM like Entity Framework for better maintainability."

---

### Transactions

**What is a Transaction?**
- Group of operations executed as single unit
- All succeed or all fail (atomicity)

**ACID Properties:**
- **Atomicity**: All or nothing
- **Consistency**: Database remains valid
- **Isolation**: Concurrent transactions don't interfere
- **Durability**: Committed changes persist

**Example:**
```sql
BEGIN TRANSACTION;

BEGIN TRY
    UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 1;
    UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 2;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH
```

**Use Cases:**
- Money transfers
- Order processing (create order + update inventory)
- Data consistency requirements

**Interview Answer:**
> "Transactions ensure multiple operations execute as a single unit - all succeed or all fail. I use them for operations requiring data consistency, like money transfers or order processing where multiple tables must be updated together. If any operation fails, I roll back all changes."

---

### Deadlocks (What & Why)

**What is a Deadlock?**
- Two transactions waiting for each other's locks
- Neither can proceed
- Database automatically detects and kills one

**Example Scenario:**
```
Transaction 1: Locks Table A, needs Table B
Transaction 2: Locks Table B, needs Table A
→ Deadlock! Both waiting forever
```

**Why Deadlocks Occur:**
- Multiple transactions accessing same resources
- Different lock order
- Long-running transactions
- High concurrency

**How Database Handles:**
- Automatically detects deadlock
- Chooses victim transaction (usually shorter one)
- Rolls back victim transaction
- Other transaction proceeds

**Prevention:**
- Access tables in same order
- Keep transactions short
- Use appropriate isolation levels
- Avoid user interaction in transactions

**Interview Answer:**
> "A deadlock occurs when two transactions are waiting for each other's locks, creating a circular dependency. The database automatically detects this, kills one transaction (the victim), and allows the other to proceed. I prevent deadlocks by accessing tables in consistent order, keeping transactions short, and avoiding user interaction within transactions."

---

## 🔥 5️⃣ Security (Must-Say Keywords)

### SQL Injection

**What**: Attack where malicious SQL is injected into queries

**Vulnerable Code:**
```csharp
string query = $"SELECT * FROM Users WHERE Username = '{username}'";
// If username = "admin' OR '1'='1"
// Becomes: SELECT * FROM Users WHERE Username = 'admin' OR '1'='1'
// Returns all users!
```

**Prevention:**
- **Parameterized Queries** (always!)
```csharp
string query = "SELECT * FROM Users WHERE Username = @Username";
command.Parameters.AddWithValue("@Username", username);
```
- **ORM** (Entity Framework - safe by default)
- **Input Validation**
- **Least Privilege** (database user permissions)

**Interview Answer:**
> "SQL injection is when attackers inject malicious SQL into queries. I prevent it by always using parameterized queries, which treat user input as data not code. Entity Framework also prevents this automatically. I also validate input and use database accounts with minimal permissions."

---

### XSS (Cross-Site Scripting)

**What**: Injecting malicious scripts into web pages

**Types:**
- **Reflected XSS**: Script in URL, reflected to user
- **Stored XSS**: Script stored in database, shown to all users
- **DOM-based XSS**: Client-side manipulation

**Example:**
```html
<!-- User input: <script>alert('XSS')</script> -->
<div>User comment: <script>alert('XSS')</script></div>
```

**Prevention:**
- **HTML Encoding** (always encode output)
```csharp
@Html.DisplayFor(model => model.Comment) // Auto-encoded
string safe = HttpUtility.HtmlEncode(userInput);
```
- **Content Security Policy (CSP)** header
- **Input Validation**
- **Whitelist** approach for rich text

**Interview Answer:**
> "XSS is injecting malicious JavaScript into web pages. I prevent it by HTML encoding all user input when displaying it, using Content Security Policy headers, and validating input. For rich text, I use a whitelist approach allowing only safe HTML tags."

---

### CSRF (Cross-Site Request Forgery)

**What**: Forcing user to execute unwanted actions on authenticated site

**Attack Scenario:**
1. User logged into bank.com
2. Visits malicious site
3. Malicious site sends request to bank.com/transfer
4. Browser includes cookies (user authenticated)
5. Transfer executes without user's knowledge

**Prevention:**
- **Anti-Forgery Tokens**
```csharp
@Html.AntiForgeryToken()
[ValidateAntiForgeryToken]
public IActionResult Transfer() { }
```
- **SameSite Cookie** attribute
- **Check Referer** header

**Interview Answer:**
> "CSRF forces authenticated users to execute unwanted actions. I prevent it using anti-forgery tokens that validate requests come from my site, and by setting SameSite cookie attributes. ASP.NET Core automatically validates these tokens for POST/PUT/DELETE requests."

---

### HTTPS

**What**: HTTP over SSL/TLS encryption

**Why:**
- **Encryption**: Data encrypted in transit
- **Authentication**: Verifies server identity
- **Integrity**: Detects tampering
- **Trust**: Users see padlock icon

**How It Works:**
1. Client requests HTTPS connection
2. Server sends SSL certificate
3. Client verifies certificate
4. Encrypted connection established
5. All data encrypted

**Implementation:**
- SSL/TLS certificate required
- Configure in IIS binding
- Force HTTPS redirect (URL Rewrite)

**Interview Answer:**
> "HTTPS encrypts data in transit using SSL/TLS, preventing interception and tampering. It requires an SSL certificate and verifies server identity. I always force HTTPS redirects in production to ensure all traffic is encrypted, protecting user data and credentials."

---

### JWT Token Expiration

**What is JWT?**
- JSON Web Token
- Stateless authentication token
- Contains user claims (ID, roles, etc.)

**Expiration:**
- Tokens should expire for security
- Short expiration = more secure
- Long expiration = better UX

**Typical Expiration:**
- **Access Token**: 15 minutes to 1 hour
- **Refresh Token**: 7-30 days

**Why Expire:**
- **Security**: Stolen token becomes useless
- **Limit Exposure**: Shorter window if compromised
- **Force Re-authentication**: Verify user still valid

**Implementation:**
```csharp
var tokenDescriptor = new SecurityTokenDescriptor
{
    Expires = DateTime.UtcNow.AddMinutes(15), // Short-lived
    SigningCredentials = credentials
};
```

**Refresh Token Pattern:**
- Access token expires quickly
- Use refresh token to get new access token
- Refresh token stored securely, longer expiration

**Interview Answer:**
> "JWT tokens should expire to limit security exposure. I typically set access tokens to expire in 15-60 minutes. If a token is stolen, it becomes useless after expiration. For better UX, I use refresh tokens that last longer, allowing users to get new access tokens without re-logging in."

---

## 🔥 6️⃣ Support / Investigation Flow (CRITICAL)

### Investigation Flow (Memorize This)

**1. Check Logs**

**Where to Look:**
- **IIS Logs**: `C:\inetpub\logs\LogFiles\W3SVC[SiteID]\`
- **Application Logs**: Application log files, Event Viewer
- **Database Logs**: SQL Server error logs
- **Browser Console**: Client-side errors

**What to Check:**
- Error messages
- Stack traces
- Timestamps (when did it start?)
- Frequency (how often?)
- Affected users/IPs

**Tools:**
- Log analysis tools
- PowerShell: `Get-Content` with filtering
- Application Insights
- Event Viewer

---

**2. Identify Scope**

**Questions to Answer:**
- **Who is affected?** (All users? Specific users?)
- **What is affected?** (Entire site? Specific feature?)
- **When did it start?** (Recent deployment? Specific time?)
- **How often?** (Every request? Intermittent?)

**Determine:**
- Is it widespread or isolated?
- Is it consistent or intermittent?
- Is it related to recent changes?

**Document:**
- Number of affected users
- Error rate
- Time pattern
- Geographic pattern (if applicable)

---

**3. Temporary Fix / Rollback**

**Options:**
- **Rollback Deployment**: Revert to previous version
- **Disable Feature**: Turn off problematic feature
- **Restart Application Pool**: Clear memory issues
- **Scale Up**: Add resources if overloaded
- **Maintenance Mode**: Show message while fixing

**Quick Actions:**
```powershell
# Restart app pool
Restart-WebAppPool -Name "MyAppPool"

# Disable feature (app setting)
# Set FeatureFlag = false

# Rollback (if using deployment slots)
# Swap staging back to production
```

**Priority:**
- Restore service quickly
- Minimize user impact
- Buy time for root cause analysis

---

**4. Root Cause**

**Investigation Steps:**
1. **Reproduce**: Can you reproduce the issue?
2. **Compare**: What changed? (Code, config, environment)
3. **Analyze**: Review logs, stack traces, error messages
4. **Test**: Test hypotheses
5. **Verify**: Confirm root cause

**Common Causes:**
- Code bug (recent deployment)
- Configuration error
- Database connection issues
- Resource exhaustion (memory, CPU)
- External dependency failure
- Network issues

**Tools:**
- Debugging
- Code review
- Database query analysis
- Performance profiling
- Network diagnostics

---

**5. Prevent Recurrence**

**Actions:**
- **Fix Root Cause**: Permanent solution
- **Add Monitoring**: Alerts for similar issues
- **Add Logging**: Better visibility
- **Improve Error Handling**: Graceful degradation
- **Document**: Update runbooks
- **Review Process**: How did this get to production?

**Prevention Measures:**
- Better testing (unit, integration)
- Code review process
- Staging environment testing
- Monitoring and alerting
- Incident post-mortem

**Long-term:**
- Update development practices
- Improve deployment process
- Enhance monitoring
- Training and documentation

---

### Complete Flow Example

**Scenario: Users reporting 500 errors on login page**

**1. Check Logs:**
```powershell
# Check IIS logs for 500 errors
Get-Content C:\inetpub\logs\LogFiles\W3SVC1\u_ex*.log | 
    Select-String " 500 " | 
    Select-String "login"

# Check application logs
Get-Content C:\App\Logs\app.log | 
    Select-String "ERROR" | 
    Select-String "login"
```

**2. Identify Scope:**
- All users or specific users?
- Started 30 minutes ago (after deployment?)
- 100% of login attempts failing

**3. Temporary Fix:**
- Rollback to previous deployment
- Or restart application pool
- Restore service quickly

**4. Root Cause:**
- Review deployment changes
- Check error: "Database connection timeout"
- Found: Connection string changed incorrectly

**5. Prevent Recurrence:**
- Fix connection string
- Add connection string validation in deployment
- Add database health check
- Set up alerting for connection failures
- Update deployment checklist

---

**Interview Answer:**
> "My investigation flow is: First, check logs - IIS logs, application logs, and browser console to understand the error. Second, identify scope - who's affected, when it started, how widespread. Third, implement a temporary fix like rolling back deployment or restarting the app pool to restore service quickly. Fourth, investigate root cause by analyzing logs, reviewing recent changes, and reproducing the issue. Finally, prevent recurrence by fixing the root cause, adding monitoring, improving error handling, and updating processes to catch similar issues earlier."

---

## Quick Reference Checklist

### IIS + Hosting
- [ ] IIS vs Kestrel difference
- [ ] Application pool isolation benefits
- [ ] URL Rewrite for HTTPS redirect
- [ ] IP whitelisting locations and use cases
- [ ] IIS logs location and key fields

### HTTP Status Codes
- [ ] 200, 201 (success)
- [ ] 400 (bad request, validation)
- [ ] 401 vs 403 (auth vs authorization)
- [ ] 404 (not found)
- [ ] 500 (server error)
- [ ] 502, 503 (gateway, unavailable)

### Browser Debugging
- [ ] Network tab usage
- [ ] Console errors
- [ ] CORS error understanding

### SQL Production
- [ ] INNER vs LEFT JOIN
- [ ] Index basics and when to use
- [ ] Stored procedures (when/why)
- [ ] Transactions (ACID)
- [ ] Deadlocks (what/why)

### Security Keywords
- [ ] SQL Injection prevention
- [ ] XSS prevention
- [ ] CSRF prevention
- [ ] HTTPS importance
- [ ] JWT expiration

### Investigation Flow
- [ ] Check logs
- [ ] Identify scope
- [ ] Temporary fix/rollback
- [ ] Root cause analysis
- [ ] Prevent recurrence

