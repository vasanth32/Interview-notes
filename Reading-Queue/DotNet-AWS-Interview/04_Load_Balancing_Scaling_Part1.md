# 04. Load Balancing & Scaling - Part 1

---

## Question 1: Why Single Server Fails

### 1. Real-world Problem (Without AWS)

You deployed your ASP.NET Core API on a single EC2 instance. Everything works great... until:

**Problems:**
- **Traffic spike:** 1000 requests/second → Server overloads, crashes
- **Server failure:** Hardware failure → Entire API is down
- **Deployment:** Updating code → API goes down during deployment
- **Maintenance:** Windows Update → API unavailable during reboot
- **Single point of failure:** One server = One failure point

**The Real Problem:** A single server cannot handle production workloads reliably. You need redundancy and distribution.

### 2. Why AWS Created Load Balancing & Auto Scaling

AWS said: *"What if you run multiple servers and distribute traffic among them? If one fails, others continue. If traffic spikes, automatically add more servers."*

**Load Balancing = Distribute traffic across multiple servers**
**Auto Scaling = Automatically add/remove servers based on demand**

### 3. Basic Explanation (Very Simple Words)

**Single Server Problems:**
- **Traffic overload:** Too many requests → Server crashes
- **Hardware failure:** Server breaks → Everything down
- **Deployment downtime:** Update server → Service unavailable
- **No redundancy:** One server = One failure point

**Solution: Multiple Servers + Load Balancer**
- **Multiple servers:** If one fails, others work
- **Load balancer:** Distributes traffic evenly
- **Auto scaling:** Adds servers when traffic spikes, removes when low

**Analogy:**
- **Single server = One cashier** (long lines, if sick → store closed)
- **Multiple servers + Load balancer = Multiple cashiers** (fast service, if one sick → others work)

### 4. Internal Working (High-Level)

**Single Server Architecture:**
```
Internet → Single EC2 Instance → Database
(If server fails → Everything down)
```

**Load Balanced Architecture:**
```
Internet
    ↓
Application Load Balancer (ALB)
    ↓
EC2 Instance 1 (Healthy)
EC2 Instance 2 (Healthy)
EC2 Instance 3 (Unhealthy - ALB stops routing to it)
    ↓
Database
(If one instance fails → Others continue, zero downtime)
```

**Auto Scaling:**
```
Traffic: 100 requests/min
    ↓
Auto Scaling: 2 instances (enough)
    ↓
Traffic spikes: 1000 requests/min
    ↓
CloudWatch detects high CPU
    ↓
Auto Scaling launches 5 more instances
    ↓
Now: 7 instances handling traffic
    ↓
Traffic drops: 200 requests/min
    ↓
Auto Scaling removes 4 instances
    ↓
Now: 3 instances (cost optimized)
```

### 5. .NET Core / C# Real-Time Example

**Single Server (Vulnerable):**
```csharp
// One EC2 instance running your API
public class ProductsController : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetProducts()
    {
        // If this server crashes, entire API is down
        // If traffic > server capacity, requests fail
        var products = await dbContext.Products.ToListAsync();
        return Ok(products);
    }
}

// Problems:
// - Single point of failure
// - Can't handle traffic spikes
// - Downtime during deployment
```

**Load Balanced (Resilient):**
```csharp
// Multiple EC2 instances behind ALB
// Architecture:
// ALB → EC2 Instance 1 (10.1.1.50)
//     → EC2 Instance 2 (10.1.1.51)
//     → EC2 Instance 3 (10.1.2.50)

public class ProductsController : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetProducts()
    {
        // Request might hit Instance 1, 2, or 3
        // ALB distributes evenly (round-robin)
        // If Instance 1 crashes, ALB routes to 2 and 3
        // Zero downtime
        
        var products = await dbContext.Products.ToListAsync();
        return Ok(products);
    }
    
    [HttpGet("health")]
    public IActionResult Health()
    {
        // ALB health check endpoint
        // ALB calls this every 30 seconds
        // If returns non-200, ALB marks instance unhealthy
        return Ok(new { status = "healthy", instance = Environment.MachineName });
    }
}
```

**Auto Scaling Configuration:**
```csharp
// Auto Scaling Group Configuration
// Min: 2 instances (always have redundancy)
// Desired: 3 instances (normal traffic)
// Max: 10 instances (handle traffic spikes)

// Scaling Policies:
// - Scale up: CPU > 70% for 5 minutes → Add 2 instances
// - Scale down: CPU < 30% for 15 minutes → Remove 1 instance

// CloudWatch Alarms:
// - Alarm: CPUUtilization > 70%
//   Action: Add 2 instances
// - Alarm: CPUUtilization < 30%
//   Action: Remove 1 instance
```

### 6. Production Usage Scenario

**Scenario: E-commerce API with Variable Traffic**

**Single Server Approach:**
- 1 EC2 instance (t3.large)
- Cost: $60/month
- **Problems:**
  - Black Friday: 5000 requests/min → Server crashes → Lost revenue
  - Server failure: 2 hours downtime → Lost customers
  - Deployment: 10 minutes downtime → User complaints
- **Uptime:** ~95% (downtime during failures, deployments, maintenance)

**Load Balanced + Auto Scaling Approach:**
- Application Load Balancer: $16/month
- Auto Scaling Group: 2-10 instances (t3.medium)
- Average: 3 instances = $90/month
- Peak: 8 instances = $240/month
- **Benefits:**
  - Black Friday: Auto Scaling adds 5 instances → Handles 5000 requests/min → No crashes
  - Server failure: ALB routes to other instances → Zero downtime
  - Deployment: Deploy to new instances, then switch ALB → Zero downtime
- **Uptime:** ~99.9% (high availability)
- **Total Cost:** ~$106/month average (vs $60, but 99.9% vs 95% uptime)

**Cost-Benefit:**
- **77% more cost** but **99.9% vs 95% uptime**
- **Zero downtime deployments**
- **Handles traffic spikes automatically**
- **Worth it for production!**

### 7. Common Mistakes by .NET Developers

❌ **Mistake 1:** Using single server for production
```csharp
// BAD: One EC2 instance for production API
// Single point of failure
// Can't handle traffic spikes
// Downtime during deployment
```
```csharp
// GOOD: Always use Load Balancer + Auto Scaling for production
// Redundancy, scalability, high availability
```

❌ **Mistake 2:** Not configuring health checks properly
```csharp
// BAD: Health check on authenticated endpoint
[HttpGet("health")]
[Authorize] // Requires authentication
public IActionResult Health() { ... }
// ALB health check fails (no auth), marks instance unhealthy
```
```csharp
// GOOD: Health check without authentication
[HttpGet("health")]
public IActionResult Health()
{
    // Check database connection, dependencies
    var dbHealthy = _dbContext.Database.CanConnect();
    return dbHealthy 
        ? Ok(new { status = "healthy" })
        : StatusCode(503, new { status = "unhealthy" });
}
```

❌ **Mistake 3:** Not using sticky sessions when needed
```csharp
// BAD: Stateless API, but using in-memory session
// User logs in on Instance 1
// Next request goes to Instance 2
// Session lost (not shared between instances)
```
```csharp
// GOOD: Use stateless authentication (JWT)
// Or use distributed cache (Redis/ElastiCache) for sessions
// Or enable ALB sticky sessions (if really needed)
```

❌ **Mistake 4:** Not monitoring instance health
```csharp
// BAD: No monitoring
// Don't know when instances are unhealthy
// Don't know when to scale
```
```csharp
// GOOD: CloudWatch metrics
// - CPU utilization
// - Memory utilization
// - Request count
// - Error rate
// Set up alarms for auto scaling
```

### 8. Interview-Ready Answer

**"Why does a single server fail in production?"**

**Single Server Limitations:**

1. **Traffic Overload:**
   - Server has limited capacity (CPU, memory, network)
   - Traffic spike exceeds capacity → Server crashes or becomes unresponsive

2. **Hardware Failure:**
   - Server hardware can fail (disk, memory, CPU)
   - Single server = Single point of failure
   - No redundancy → Complete downtime

3. **Deployment Downtime:**
   - Updating code requires restarting server
   - During restart, service is unavailable
   - Users experience downtime

4. **Maintenance:**
   - OS updates, security patches require reboot
   - During reboot, service unavailable

5. **No Scalability:**
   - Can't handle traffic growth
   - Must manually upgrade server (expensive, downtime)

**Solution: Load Balancing + Auto Scaling**

**Load Balancing:**
- Distributes traffic across multiple servers
- If one server fails, traffic routes to others
- Zero downtime during server failures

**Auto Scaling:**
- Automatically adds servers when traffic spikes
- Automatically removes servers when traffic drops
- Cost-optimized (pay only for what you need)

**Architecture:**
```
Internet → Application Load Balancer → Multiple EC2 Instances (Auto Scaled)
```

**Benefits:**
- **High Availability:** 99.9%+ uptime (vs 95% with single server)
- **Scalability:** Handles traffic spikes automatically
- **Zero-Downtime Deployments:** Deploy to new instances, then switch
- **Cost Optimization:** Scale down during low traffic

**For .NET Applications:** Always use Application Load Balancer + Auto Scaling Group for production APIs. Single server is acceptable only for development/testing.

### 9. Tricky Follow-Up Question

**Q: "Can I use a single server if I make it very powerful?"**

**A:** Still not recommended because:
- **Single point of failure:** Even powerful servers can fail
- **Deployment downtime:** Still need to restart for updates
- **Cost:** One powerful server might cost more than multiple smaller servers
- **Scalability:** Can't scale horizontally (add more servers)

**Better approach:** Multiple smaller servers behind load balancer (cheaper, more reliable, scalable).

**Q: "What's the minimum number of servers for high availability?"**

**A:** At least 2 servers in different Availability Zones. This provides:
- Redundancy (if one AZ fails, other works)
- Zero-downtime deployments (deploy to one, then other)
- Load distribution

**Best practice:** Auto Scaling Group with Min=2, across multiple AZs.

### 10. One-Line Takeaway

**Single server fails due to traffic overload, hardware failure, deployment downtime, and no redundancy; solution = Load Balancer + Auto Scaling with multiple servers for high availability and scalability.**

---

## Question 2: Application Load Balancer Basics

### 1. Real-world Problem (Without AWS)

You have 3 EC2 instances running your API. How do you distribute traffic among them?

**Problems:**
- Users can't know which instance IP to use
- If one instance fails, users hitting that IP get errors
- Manual distribution is impossible
- SSL certificates need to be on each instance (complex)

**The Real Problem:** You need a single entry point that automatically distributes traffic and handles failures.

### 2. Why AWS Created Application Load Balancer

AWS said: *"What if we provide a managed service that automatically distributes traffic, handles SSL, performs health checks, and routes intelligently?"*

**Application Load Balancer (ALB) = Managed load balancer for HTTP/HTTPS traffic**
- Distributes traffic across multiple targets
- Handles SSL termination
- Performs health checks
- Provides single DNS endpoint

### 3. Basic Explanation (Very Simple Words)

**Application Load Balancer = Traffic director for your servers**

**Real-Life Analogy:**
- **ALB = Reception desk at a company**
- **Multiple employees (EC2 instances) = Handle requests**
- **Receptionist (ALB) = Routes visitors to available employees**
- **If employee is busy/sick (unhealthy) = Routes to others**

**Key Features:**
- **Single endpoint:** Users access one URL (ALB DNS name)
- **Traffic distribution:** ALB routes to healthy instances
- **Health checks:** ALB monitors instance health
- **SSL termination:** ALB handles HTTPS, forwards HTTP to instances
- **Path-based routing:** Route /api/* to API servers, /admin/* to admin servers

### 4. Internal Working (High-Level)

**ALB Architecture:**
```
Internet
    ↓
Application Load Balancer (ALB)
    - DNS: my-api-123456789.us-east-1.elb.amazonaws.com
    - IP: 54.123.45.67 (managed by AWS)
    ↓
Target Group (group of EC2 instances)
    - EC2 Instance 1 (10.1.1.50) - Healthy
    - EC2 Instance 2 (10.1.1.51) - Healthy
    - EC2 Instance 3 (10.1.2.50) - Unhealthy (ALB stops routing)
```

**Request Flow:**
```
User Request → ALB
    ↓
ALB checks health of instances
    ↓
ALB routes to healthy instance (round-robin or least connections)
    ↓
Instance processes request
    ↓
Response → ALB → User
```

**Health Checks:**
```
ALB sends: GET /health every 30 seconds
    ↓
Instance responds: 200 OK → Marked healthy
Instance responds: 503 or timeout → Marked unhealthy
    ↓
If unhealthy: ALB stops routing traffic to that instance
    ↓
If becomes healthy again: ALB resumes routing
```

**SSL Termination:**
```
User: HTTPS request to ALB
    ↓
ALB terminates SSL (decrypts)
    ↓
ALB forwards HTTP to EC2 (internal, secure)
    ↓
EC2 processes request
    ↓
Response: EC2 → ALB (HTTP)
    ↓
ALB encrypts (SSL) → User (HTTPS)
```

### 5. .NET Core / C# Real-Time Example

**ALB Setup:**
```csharp
// ALB Configuration
// Listener: HTTPS (443)
// Target Group: EC2 instances running .NET API
// Health Check: GET /health (every 30 seconds)

// EC2 Instances:
// - Instance 1: 10.1.1.50 (port 5000)
// - Instance 2: 10.1.1.51 (port 5000)
// - Instance 3: 10.1.2.50 (port 5000)
```

**Your .NET API:**
```csharp
public class ProductsController : ControllerBase
{
    [HttpGet("products")]
    public async Task<IActionResult> GetProducts()
    {
        // Request comes from ALB (not directly from user)
        // ALB forwards: User → ALB → This instance
        
        // Log which instance handled request (useful for debugging)
        _logger.LogInformation("Request handled by instance: {InstanceId}", 
            Environment.MachineName);
        
        var products = await dbContext.Products.ToListAsync();
        return Ok(products);
    }
    
    [HttpGet("health")]
    public IActionResult Health()
    {
        // ALB health check endpoint
        // Called every 30 seconds by ALB
        // Must return 200 OK for instance to be healthy
        
        try
        {
            // Check database connection
            var canConnect = dbContext.Database.CanConnect();
            
            if (!canConnect)
            {
                return StatusCode(503, new { status = "unhealthy", reason = "database" });
            }
            
            return Ok(new { 
                status = "healthy", 
                instance = Environment.MachineName,
                timestamp = DateTime.UtcNow
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Health check failed");
            return StatusCode(503, new { status = "unhealthy", error = ex.Message });
        }
    }
}
```

**ALB Target Group Configuration:**
```json
{
  "TargetGroupName": "api-targets",
  "Protocol": "HTTP",
  "Port": 5000,
  "HealthCheckPath": "/health",
  "HealthCheckIntervalSeconds": 30,
  "HealthyThresholdCount": 2,
  "UnhealthyThresholdCount": 3,
  "Targets": [
    { "Id": "i-1234567890abcdef0", "Port": 5000 },
    { "Id": "i-0987654321fedcba0", "Port": 5000 },
    { "Id": "i-abcdef1234567890", "Port": 5000 }
  ]
}
```

**User Access:**
```csharp
// User doesn't know about individual instances
// User accesses: https://api.mycompany.com/products
// (This is ALB DNS name, not EC2 IP)

// ALB automatically routes to healthy instances
// If Instance 1 is busy, ALB routes to Instance 2 or 3
// Load is distributed evenly
```

### 6. Production Usage Scenario

**Scenario: High-Traffic API**

**Architecture:**
```
Internet
    ↓
Route 53: api.mycompany.com → ALB DNS
    ↓
Application Load Balancer
    - Listener: HTTPS (443) with SSL certificate
    - Target Group: api-servers
    ↓
Auto Scaling Group (3-10 instances)
    - us-east-1a: Instance 1, Instance 2
    - us-east-1b: Instance 3, Instance 4
    - us-east-1c: Instance 5
    ↓
RDS Database (Multi-AZ)
```

**Traffic Distribution:**
```
Request 1 → ALB → Instance 1 (10.1.1.50)
Request 2 → ALB → Instance 2 (10.1.1.51)
Request 3 → ALB → Instance 3 (10.1.2.50)
Request 4 → ALB → Instance 4 (10.1.2.51)
Request 5 → ALB → Instance 5 (10.1.3.50)
Request 6 → ALB → Instance 1 (round-robin)
```

**Health Check Flow:**
```
ALB: GET /health → Instance 1 → 200 OK → Healthy ✓
ALB: GET /health → Instance 2 → 200 OK → Healthy ✓
ALB: GET /health → Instance 3 → 503 → Unhealthy ✗
    ↓
ALB stops routing to Instance 3
    ↓
All traffic goes to Instances 1, 2, 4, 5
    ↓
Instance 3 recovers, health check passes
    ↓
ALB resumes routing to Instance 3
```

**SSL Termination:**
```
User: HTTPS → ALB (SSL certificate on ALB)
    ↓
ALB: Decrypts, forwards HTTP → EC2
    ↓
EC2: Processes request (no SSL needed internally)
    ↓
EC2: Returns response → ALB
    ↓
ALB: Encrypts, sends HTTPS → User
```

### 7. Common Mistakes by .NET Developers

❌ **Mistake 1:** Not implementing health check endpoint
```csharp
// BAD: No /health endpoint
// ALB can't check instance health
// Unhealthy instances still receive traffic
```
```csharp
// GOOD: Implement /health endpoint
[HttpGet("health")]
public IActionResult Health()
{
    // Check dependencies (database, cache, etc.)
    return Ok(new { status = "healthy" });
}
```

❌ **Mistake 2:** Health check requires authentication
```csharp
// BAD: Health check behind authentication
[HttpGet("health")]
[Authorize] // ALB can't authenticate
public IActionResult Health() { ... }
// ALB health check fails → Instance marked unhealthy
```
```csharp
// GOOD: Health check without authentication
[HttpGet("health")]
public IActionResult Health() { ... }
// ALB can check without credentials
```

❌ **Mistake 3:** Not understanding ALB vs EC2 IPs
```csharp
// BAD: Users access EC2 IP directly
// http://54.123.45.67:5000/products
// Bypasses ALB, no load balancing
```
```csharp
// GOOD: Users access ALB DNS
// https://api.mycompany.com/products
// ALB distributes traffic
```

❌ **Mistake 4:** Not configuring SSL on ALB
```csharp
// BAD: HTTP only on ALB
// Security risk, browsers show "not secure"
```
```csharp
// GOOD: HTTPS on ALB
// Use AWS Certificate Manager (free SSL certificates)
// ALB handles SSL termination
```

### 8. Interview-Ready Answer

**"Explain Application Load Balancer"**

Application Load Balancer (ALB) is AWS's managed load balancer for HTTP/HTTPS traffic. It distributes incoming requests across multiple targets (EC2 instances, containers, IP addresses).

**Key Features:**

1. **Load Distribution:**
   - Distributes traffic across healthy targets
   - Algorithms: Round-robin, least connections
   - Automatically avoids unhealthy targets

2. **Health Checks:**
   - Periodically checks target health (default: every 30 seconds)
   - Health check path (e.g., `/health`)
   - If target fails health check, stops routing to it
   - Resumes routing when target becomes healthy

3. **SSL Termination:**
   - Handles SSL/TLS certificates
   - Decrypts HTTPS requests, forwards HTTP to targets
   - Encrypts responses before sending to users
   - Use AWS Certificate Manager for free SSL certificates

4. **Path-Based Routing:**
   - Route `/api/*` to API targets
   - Route `/admin/*` to admin targets
   - Route `/static/*` to static file servers

5. **High Availability:**
   - Automatically spans multiple Availability Zones
   - If one AZ fails, routes to other AZs

**Architecture:**
```
Internet → ALB (single DNS endpoint) → Target Group → Multiple EC2 Instances
```

**For .NET Applications:**
- Configure ALB listener on HTTPS (443)
- Create target group pointing to EC2 instances (port 5000 for Kestrel)
- Implement `/health` endpoint (no authentication) for health checks
- ALB distributes traffic, handles SSL, performs health checks
- EC2 instances don't need public IPs (behind ALB)

**Benefits:**
- **High Availability:** Automatic failover to healthy instances
- **Scalability:** Works with Auto Scaling Groups
- **SSL Management:** Centralized SSL termination
- **Monitoring:** CloudWatch metrics for requests, latency, errors

**Cost:** ~$16/month + $0.008 per LCU-hour (varies by region).

### 9. Tricky Follow-Up Question

**Q: "What's the difference between ALB, NLB, and CLB?"**

**A:**
- **ALB (Application Load Balancer):** Layer 7 (HTTP/HTTPS), content-based routing, SSL termination, best for web apps
- **NLB (Network Load Balancer):** Layer 4 (TCP), lower latency, handles millions of requests, best for high-performance apps
- **CLB (Classic Load Balancer):** Legacy, use ALB or NLB instead

**For most .NET APIs:** ALB is recommended.

**Q: "Can ALB route to different ports on same instance?"**

**A:** Yes! You can configure target group to route to specific ports. However, typically each target group routes to one port. For multiple ports, use multiple target groups with path-based routing.

### 10. One-Line Takeaway

**Application Load Balancer = Managed HTTP/HTTPS load balancer that distributes traffic, performs health checks, handles SSL termination; provides single endpoint, high availability, and works with Auto Scaling.**

---

