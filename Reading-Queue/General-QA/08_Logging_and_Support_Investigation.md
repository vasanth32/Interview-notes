# Logging & Support Investigation - Interview Guide

## 1. Logging Frameworks

### ASP.NET Core ILogger

**Purpose**: Built-in logging abstraction for .NET applications

**Registration:**
```csharp
// Program.cs or Startup.cs
builder.Services.AddLogging(builder =>
{
    builder.AddConsole();
    builder.AddDebug();
    builder.AddEventSourceLogger();
});
```

**Usage:**
```csharp
public class UserService
{
    private readonly ILogger<UserService> _logger;
    
    public UserService(ILogger<UserService> logger)
    {
        _logger = logger;
    }
    
    public void ProcessUser(int userId)
    {
        _logger.LogInformation("Processing user {UserId}", userId);
        
        try
        {
            // Process user
            _logger.LogDebug("User processing completed");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing user {UserId}", userId);
        }
    }
}
```

### Log Levels

**Hierarchy (lowest to highest):**
1. **Trace**: Very detailed, development only
2. **Debug**: Detailed information for debugging
3. **Information**: General informational messages
4. **Warning**: Warning messages (non-critical issues)
5. **Error**: Error messages (exceptions, failures)
6. **Critical**: Critical failures requiring immediate attention

**Configuration:**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information",
      "MyApp.UserService": "Debug"
    }
  }
}
```

**When to Use Each Level:**
- **Trace**: Method entry/exit, variable values
- **Debug**: Flow control, intermediate results
- **Information**: Important business events (user login, order created)
- **Warning**: Deprecated API usage, performance issues
- **Error**: Exceptions, failed operations
- **Critical**: System failures, data corruption

### Structured Logging

**Purpose**: Log data in structured format (JSON) for better querying

**Benefits:**
- Easy to search and filter
- Can extract specific fields
- Better for log aggregation tools

**Example:**
```csharp
// Simple logging
_logger.LogInformation("User {UserId} logged in from {IPAddress}", 
    userId, ipAddress);

// Structured (with properties)
_logger.LogInformation("User logged in. {UserId} {IPAddress} {Timestamp}", 
    userId, ipAddress, DateTime.UtcNow);
```

**Output (JSON):**
```json
{
  "Timestamp": "2024-01-15T10:30:00Z",
  "Level": "Information",
  "Message": "User logged in.",
  "UserId": 123,
  "IPAddress": "192.168.1.100"
}
```

### Log Providers

**Console Provider:**
```csharp
builder.Logging.AddConsole();
```
- Outputs to console
- Good for development
- Not suitable for production

**Debug Provider:**
```csharp
builder.Logging.AddDebug();
```
- Outputs to Debug window in Visual Studio
- Development only

**File Provider (NLog/Serilog):**
```csharp
// Using Serilog
Log.Logger = new LoggerConfiguration()
    .WriteTo.File("logs/app.log", rollingInterval: RollingInterval.Day)
    .CreateLogger();
```

**Application Insights:**
```csharp
builder.Logging.AddApplicationInsights();
```
- Cloud-based logging and monitoring
- Real-time analytics
- Exception tracking

**Event Log (Windows):**
```csharp
builder.Logging.AddEventLog();
```

---

## 2. Investigation Techniques

### Reading IIS Logs

**Location:**
- Default: `C:\inetpub\logs\LogFiles\W3SVC[SiteID]\`
- Format: W3C Extended Log File Format

**Log File Naming:**
- Format: `u_ex[YYMMDD].log`
- Example: `u_ex240115.log` (January 15, 2024)

**Important Fields:**
- **date**: Request date
- **time**: Request time
- **s-ip**: Server IP
- **cs-method**: HTTP method (GET, POST)
- **cs-uri-stem**: Requested URL
- **cs-uri-query**: Query string
- **s-port**: Server port
- **cs-username**: Username (if authenticated)
- **c-ip**: Client IP address
- **cs(User-Agent)**: Browser/client
- **sc-status**: HTTP status code
- **sc-substatus**: Sub-status code
- **sc-win32-status**: Windows status code
- **time-taken**: Request duration (milliseconds)

**Example Log Entry:**
```
2024-01-15 10:30:45 192.168.1.1 GET /api/users/123 - 80 - 192.168.1.100 Mozilla/5.0 200 0 0 45
```

**Tools for Analysis:**
- **Log Parser Studio**: Microsoft tool for querying IIS logs
- **PowerShell**: Parse with `Get-Content` and filtering
- **Excel**: Import and filter
- **Third-party tools**: Log analysis software

**Common Queries:**
```powershell
# Find 404 errors
Get-Content u_ex*.log | Select-String " 404 "

# Find slow requests (>1000ms)
Get-Content u_ex*.log | Select-String " [0-9]{4,} " 

# Find requests from specific IP
Get-Content u_ex*.log | Select-String "192.168.1.100"
```

### Application Logs Analysis

**Log File Locations:**
- Application root: `logs/` folder
- Windows Event Log: Event Viewer
- Application Insights: Azure Portal

**What to Look For:**
- **Error messages**: Exception details, stack traces
- **Warning messages**: Performance issues, deprecated usage
- **Correlation IDs**: Track requests across services
- **Timestamps**: Identify when issues occurred
- **User context**: User ID, session ID

**Searching Logs:**
```csharp
// Add correlation ID
var correlationId = Guid.NewGuid().ToString();
_logger.LogInformation("Request started. {CorrelationId}", correlationId);

// Use in all related logs
_logger.LogError(ex, "Error occurred. {CorrelationId}", correlationId);
```

**Log Aggregation Tools:**
- **ELK Stack** (Elasticsearch, Logstash, Kibana)
- **Splunk**
- **Application Insights**
- **Seq** (for .NET)

### Event Viewer

**Purpose**: Windows system and application event logs

**Access**: `eventvwr.msc` or Control Panel → Administrative Tools

**Log Categories:**
- **Application**: Application events
- **System**: System events
- **Security**: Security audit events
- **Custom**: Application-specific logs

**Common Events:**
- **Information**: Normal operations
- **Warning**: Potential problems
- **Error**: Problems that need attention
- **Critical**: Serious failures

**Filtering:**
- By event level
- By source (application name)
- By date/time range
- By event ID

### Performance Counters

**Purpose**: Monitor system and application performance

**Common Counters:**
- **CPU Usage**: `\Processor(_Total)\% Processor Time`
- **Memory**: `\Memory\Available MBytes`
- **ASP.NET Requests**: `\ASP.NET Applications(__Total__)\Requests/Sec`
- **IIS Requests**: `\Web Service(_Total)\Current Connections`

**Access:**
- Performance Monitor (`perfmon.exe`)
- Task Manager → Performance tab
- PowerShell: `Get-Counter`

**Application Insights:**
- Automatically collects performance counters
- View in Azure Portal
- Set up alerts

### Browser DevTools

**Network Tab:**
- See all HTTP requests
- Check status codes
- View request/response headers
- Analyze timing
- Identify failed requests

**Console Tab:**
- JavaScript errors
- Console logs
- Network errors
- CORS errors

**Application Tab:**
- Local/Session storage
- Cookies
- Service workers
- Cache

**Steps for Investigation:**
1. Open DevTools (F12)
2. Reproduce issue
3. Check Console for errors
4. Check Network tab for failed requests
5. Inspect request/response details
6. Check Application tab for storage issues

### Network Packet Analysis

**Tools:**
- **Wireshark**: Capture and analyze network packets
- **Fiddler**: HTTP/HTTPS proxy
- **Network Monitor**: Microsoft tool

**Use Cases:**
- Debug network connectivity issues
- Analyze HTTP/HTTPS traffic
- Identify slow network requests
- Debug SSL/TLS issues

**Fiddler Usage:**
1. Install Fiddler
2. Configure browser to use proxy
3. Capture traffic
4. Inspect requests/responses
5. Set breakpoints to modify requests

---

## 3. Debugging

### Breakpoints and Debugging

**Visual Studio:**
- Set breakpoint: Click left margin or F9
- Start debugging: F5
- Step over: F10
- Step into: F11
- Step out: Shift+F11
- Continue: F5

**Conditional Breakpoints:**
- Right-click breakpoint → Conditions
- Break when variable equals value
- Break when hit count reaches number

**Watch Window:**
- Monitor variable values
- Evaluate expressions
- View object properties

### Remote Debugging

**Purpose**: Debug application running on different machine

**Setup:**
1. Install Remote Tools on target machine
2. Start Remote Debugger
3. In Visual Studio: Debug → Attach to Process
4. Select remote machine and process

**Use Cases:**
- Production issues (careful!)
- Staging environment debugging
- Server-side debugging

### Production Debugging Techniques

**⚠️ Important**: Be careful in production!

**Techniques:**
1. **Logging**: Comprehensive logging (preferred)
2. **Application Insights**: Real-time monitoring
3. **Remote Debugging**: Only for critical issues
4. **Memory Dumps**: Capture process state
5. **Performance Profiling**: Identify bottlenecks

**Memory Dumps:**
```powershell
# Create dump file
Get-Process -Name "MyApp" | Out-File dump.dmp
```

**Best Practices:**
- Don't debug production during business hours
- Use logging instead of breakpoints
- Set up monitoring and alerts
- Use staging environment for debugging

### Error Tracking Tools

**Application Insights:**
- Automatic exception tracking
- Performance monitoring
- User analytics
- Real-time alerts

**Sentry:**
- Error tracking
- Performance monitoring
- Release tracking

**ELK Stack:**
- Centralized logging
- Search and analysis
- Dashboards

**Custom Solutions:**
- Database logging
- File-based logging
- Email alerts

---

## Common Investigation Scenarios

### Scenario 1: Application Crashes

**Steps:**
1. Check Event Viewer for application errors
2. Review application logs for exceptions
3. Check IIS logs for HTTP 500 errors
4. Review performance counters (memory, CPU)
5. Check for recent deployments/changes

### Scenario 2: Slow Performance

**Steps:**
1. Check performance counters (CPU, memory, disk)
2. Review slow query logs (database)
3. Analyze IIS logs for slow requests
4. Use Application Insights performance data
5. Profile application code

### Scenario 3: User Reports Error

**Steps:**
1. Get user details (user ID, timestamp, action)
2. Search logs for user ID and timestamp
3. Check for exceptions in that time range
4. Review related requests in IIS logs
5. Reproduce issue in test environment

### Scenario 4: 404 Errors

**Steps:**
1. Check IIS logs for 404 entries
2. Verify URL spelling
3. Check routing configuration
4. Verify file exists on server
5. Check URL rewrite rules

---

## Interview Questions to Prepare

1. **What are the different log levels? When would you use each?**
2. **How do you implement structured logging?**
3. **How do you read and analyze IIS logs?**
4. **What information is important in IIS logs?**
5. **How do you debug a production issue without affecting users?**
6. **What is a correlation ID? Why is it useful?**
7. **How do you investigate a slow application?**
8. **What tools do you use for log analysis?**
9. **How do you set up remote debugging?**
10. **What is the difference between logging and debugging?**

