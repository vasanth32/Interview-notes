# 03. Networking (Fear Removal) - Part 3

---

## Question 5: Request Flow to .NET API

### 1. Real-world Problem (Without AWS)

A user types `https://api.mycompany.com/products` in their browser. They expect to see a list of products from your ASP.NET Core API.

**Questions:**
- How does the request reach your API?
- What path does it take through AWS?
- Which components are involved?
- How does the response get back to the user?

**The Real Problem:** As a .NET developer, you need to understand the complete request flow to debug issues, optimize performance, and explain architecture.

### 2. Why Understanding Request Flow Matters

Understanding request flow helps you:
- **Debug issues:** Know where to look when requests fail
- **Optimize performance:** Identify bottlenecks
- **Design architecture:** Make informed decisions
- **Explain to stakeholders:** Clear communication

### 3. Basic Explanation (Very Simple Words)

**Request Flow = The journey of a request from user to your API and back**

**Simple Flow:**
```
User Browser
    ↓ (HTTPS request)
Internet
    ↓
AWS (Route 53 DNS, Load Balancer, EC2)
    ↓
Your .NET API
    ↓ (Process request)
Database
    ↓ (Return data)
Your .NET API
    ↓ (HTTP response)
Load Balancer
    ↓
Internet
    ↓
User Browser (sees products)
```

### 4. Internal Working (High-Level)

**Complete Request Flow:**

```
Step 1: DNS Resolution
User types: api.mycompany.com
    ↓
Route 53 (DNS service) resolves to Load Balancer IP
    ↓

Step 2: Internet Gateway
Request reaches AWS VPC via Internet Gateway
    ↓

Step 3: NACL Check (Subnet Level)
Request enters public subnet
    ↓
NACL checks rules (allows HTTPS from internet)
    ↓

Step 4: Security Group Check (Instance Level)
Request reaches Application Load Balancer
    ↓
ALB Security Group checks (allows HTTPS from internet)
    ↓

Step 5: Load Balancer Routing
ALB checks health of EC2 instances
    ↓
ALB routes to healthy EC2 instance (e.g., 10.1.1.50)
    ↓

Step 6: EC2 Security Group Check
Request reaches EC2 instance
    ↓
EC2 Security Group checks (allows HTTP from ALB Security Group)
    ↓

Step 7: .NET API Processing
Request reaches your ASP.NET Core API
    ↓
Kestrel web server receives request
    ↓
Routing middleware matches route: /products
    ↓
ProductsController.GetProducts() executes
    ↓

Step 8: Database Query
API queries database (RDS in private subnet)
    ↓
Request: 10.1.1.50 → 10.1.20.50 (internal VPC routing)
    ↓
Database Security Group checks (allows SQL from API Security Group)
    ↓
RDS processes query, returns data
    ↓

Step 9: Response Flow (Reverse)
API returns JSON response
    ↓
EC2 → ALB → Internet Gateway → Internet → User Browser
```

### 5. .NET Core / C# Real-Time Example

**Complete Architecture:**
```csharp
// DNS: api.mycompany.com → 54.123.45.67 (ALB IP)
// VPC: 10.1.0.0/16
// Public Subnet: 10.1.1.0/24
//   - Application Load Balancer (10.1.1.100)
//   - EC2 API Instance 1 (10.1.1.50)
//   - EC2 API Instance 2 (10.1.1.51)
// Private Subnet: 10.1.10.0/24
//   - (Background services)
// Database Subnet: 10.1.20.0/24
//   - RDS SQL Server (10.1.20.50)
```

**Request Flow in Code:**
```csharp
// Step 1: User makes request
// Browser: GET https://api.mycompany.com/products

// Step 2: Route 53 resolves DNS
// api.mycompany.com → 54.123.45.67 (ALB)

// Step 3: Request reaches ALB
// ALB checks target group health
// Routes to healthy instance: 10.1.1.50

// Step 4: Request reaches your API
public class ProductsController : ControllerBase
{
    private readonly ApplicationDbContext _dbContext;
    
    [HttpGet("products")]
    public async Task<IActionResult> GetProducts()
    {
        // Step 5: API processes request
        // This code runs on EC2 instance 10.1.1.50
        
        // Step 6: Query database
        // Connection: 10.1.1.50 → 10.1.20.50 (internal VPC)
        var products = await _dbContext.Products
            .Where(p => p.IsActive)
            .ToListAsync();
        
        // Step 7: Return response
        return Ok(products);
        // Response: JSON array of products
    }
}

// Step 8: Response flows back
// EC2 (10.1.1.50) → ALB (10.1.1.100) → Internet Gateway → Internet → User Browser
```

**Security Group Configuration:**
```csharp
// ALB Security Group: sg-alb
// Inbound: HTTPS (443) from 0.0.0.0/0
// Outbound: All traffic

// EC2 Security Group: sg-api
// Inbound: HTTP (80) from sg-alb only (not from internet directly!)
// Outbound: All traffic

// RDS Security Group: sg-database
// Inbound: SQL Server (1433) from sg-api only
// Outbound: All traffic
```

**Why EC2 doesn't need public IP:**
```csharp
// EC2 instances are in public subnet but don't need public IP
// Why? Because ALB routes traffic internally
// User → ALB (public IP) → EC2 (private IP, 10.1.1.50)
// EC2 Security Group only allows traffic from ALB Security Group
// More secure: EC2 not directly accessible from internet
```

### 6. Production Usage Scenario

**Scenario: High-Traffic E-commerce API**

**Architecture:**
```
Internet
    ↓
Route 53 (DNS)
    ↓
CloudFront (CDN) - Optional, for static content
    ↓
Application Load Balancer (ALB)
    - Listener: HTTPS (443)
    - Target Group: EC2 instances
    - Health Check: /health endpoint
    ↓
Public Subnet (10.1.1.0/24) - us-east-1a
    - EC2 API Instance 1 (10.1.1.50)
    - EC2 API Instance 2 (10.1.1.51)
    ↓
Public Subnet (10.1.2.0/24) - us-east-1b
    - EC2 API Instance 3 (10.1.2.50)
    - EC2 API Instance 4 (10.1.2.51)
    ↓
Database Subnet (10.1.20.0/24) - us-east-1a
    - RDS Primary (10.1.20.50)
    ↓
Database Subnet (10.1.21.0/24) - us-east-1b
    - RDS Standby (10.1.21.50)
```

**Request Flow:**
```
1. User: GET https://api.mycompany.com/products
2. Route 53: Resolves to ALB IP (54.123.45.67)
3. Internet Gateway: Routes to VPC
4. NACL: Allows HTTPS traffic
5. ALB Security Group: Allows HTTPS from internet
6. ALB: Health check passes, routes to EC2 Instance 1 (10.1.1.50)
7. EC2 Security Group: Allows HTTP from ALB Security Group
8. .NET API: Processes request, queries database
9. Database: Returns data (10.1.1.50 → 10.1.20.50)
10. API: Returns JSON response
11. Response: EC2 → ALB → Internet Gateway → Internet → User
```

**Load Balancing:**
```csharp
// ALB distributes requests across healthy instances
// Request 1 → EC2 Instance 1 (10.1.1.50)
// Request 2 → EC2 Instance 2 (10.1.1.51)
// Request 3 → EC2 Instance 3 (10.1.2.50)
// Request 4 → EC2 Instance 4 (10.1.2.51)
// Request 5 → EC2 Instance 1 (round-robin)

// If Instance 1 becomes unhealthy:
// ALB stops routing to it
// All traffic goes to Instances 2, 3, 4
// Zero downtime
```

### 7. Common Mistakes by .NET Developers

❌ **Mistake 1:** Not understanding why EC2 doesn't need public IP
```csharp
// BAD: Giving EC2 instances public IPs
// Security risk: EC2 directly accessible from internet
// Bypasses ALB security
```
```csharp
// GOOD: EC2 without public IP, behind ALB
// ALB has public IP, EC2 has private IP only
// EC2 Security Group allows traffic from ALB only
// More secure architecture
```

❌ **Mistake 2:** Not configuring health checks
```csharp
// BAD: ALB health check on root path
// Health check: GET /
// If API has authentication on root, health check fails
```
```csharp
// GOOD: Dedicated health check endpoint
[HttpGet("health")]
public IActionResult Health()
{
    return Ok(new { status = "healthy" });
}
// ALB health check: GET /health
// No authentication required
```

❌ **Mistake 3:** Not understanding Security Group references
```csharp
// BAD: EC2 Security Group allows from specific IP
// Inbound: HTTP from 54.123.45.67 (ALB IP)
// If ALB IP changes, connection breaks
```
```csharp
// GOOD: Use Security Group reference
// EC2 Security Group: HTTP from sg-alb (ALB Security Group)
// Works even if ALB IP changes
```

❌ **Mistake 4:** Not logging request flow
```csharp
// BAD: No logging, hard to debug
public IActionResult GetProducts()
{
    return Ok(products);
}
```
```csharp
// GOOD: Log request details
public IActionResult GetProducts()
{
    _logger.LogInformation("Request received from {RemoteIP}", 
        HttpContext.Connection.RemoteIpAddress);
    // Helps debug routing, load balancing issues
    return Ok(products);
}
```

### 8. Interview-Ready Answer

**"Explain the request flow to a .NET API on AWS"**

**Complete Request Flow:**

1. **DNS Resolution:**
   - User types `api.mycompany.com`
   - Route 53 resolves to Application Load Balancer IP

2. **Internet Gateway:**
   - Request enters VPC via Internet Gateway

3. **NACL Check (Subnet Level):**
   - Request enters public subnet
   - NACL allows HTTPS traffic from internet

4. **Application Load Balancer:**
   - ALB receives request
   - ALB Security Group allows HTTPS from internet
   - ALB performs health check on target instances
   - ALB routes to healthy EC2 instance (load balancing)

5. **EC2 Security Group:**
   - Request reaches EC2 instance
   - EC2 Security Group allows HTTP from ALB Security Group (not from internet directly)

6. **.NET API Processing:**
   - Kestrel web server receives request
   - ASP.NET Core middleware pipeline processes request
   - Routing matches controller/action
   - Controller executes business logic

7. **Database Query:**
   - API queries RDS in private subnet
   - Internal VPC routing (no internet involved)
   - Database Security Group allows SQL from API Security Group

8. **Response Flow:**
   - API returns JSON response
   - Response flows: EC2 → ALB → Internet Gateway → Internet → User

**Key Components:**
- **Route 53:** DNS resolution
- **Internet Gateway:** VPC internet access
- **NACL:** Subnet-level firewall
- **Application Load Balancer:** Load balancing, health checks
- **Security Groups:** Instance-level firewall
- **EC2:** Runs .NET API
- **RDS:** Database in private subnet

**Security:**
- EC2 instances don't need public IPs (behind ALB)
- EC2 Security Group allows traffic from ALB only
- Database in private subnet, only accessible from API tier
- Defense in depth: NACL + Security Groups

**For .NET Applications:** This architecture provides high availability (multiple instances), security (private subnets, Security Groups), and scalability (ALB + Auto Scaling).

### 9. Tricky Follow-Up Question

**Q: "What happens if one EC2 instance fails?"**

**A:** 
- ALB health check detects instance is unhealthy
- ALB stops routing traffic to that instance
- Traffic automatically routes to remaining healthy instances
- Zero downtime for users
- Auto Scaling Group can launch replacement instance

**Q: "Can requests bypass the Load Balancer and go directly to EC2?"**

**A:** Not if configured correctly. EC2 Security Group should only allow traffic from ALB Security Group, not from internet. If EC2 has public IP and Security Group allows internet traffic, yes - but this is a security anti-pattern.

**Q: "What's the difference between ALB and NLB (Network Load Balancer)?"**

**A:**
- **ALB:** Layer 7 (HTTP/HTTPS), content-based routing, SSL termination, better for web apps
- **NLB:** Layer 4 (TCP), lower latency, handles millions of requests, better for high-performance apps

**For most .NET APIs:** ALB is recommended (easier, more features).

### 10. One-Line Takeaway

**Request flow: User → Route 53 → Internet Gateway → NACL → ALB → EC2 Security Group → .NET API → Database; understand each step to debug issues and design secure architectures.**

---

