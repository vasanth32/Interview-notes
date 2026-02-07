# 03. Networking (Fear Removal) - Part 2

---

## Question 3: Internet Gateway & NAT Gateway

### 1. Real-world Problem (Without AWS)

You have EC2 instances in your VPC:
- **API Server:** Needs to be accessible from internet (users need to call it)
- **Background Service:** Needs to download packages from internet, but shouldn't be accessible from internet
- **Database:** Should never access internet, should never be accessible from internet

**The Problem:** How do you control internet access? Some resources need inbound internet access, some need outbound only, some need none.

### 2. Why AWS Created Internet Gateway & NAT Gateway

AWS said: *"What if we provide two gateways: one for public access (Internet Gateway) and one for private outbound access (NAT Gateway)?"*

**Internet Gateway = Two-way door to internet** (public subnet)
- Allows inbound (internet → your resources)
- Allows outbound (your resources → internet)

**NAT Gateway = One-way door to internet** (private subnet)
- Allows outbound only (your resources → internet)
- Blocks inbound (internet cannot reach your resources)

### 3. Basic Explanation (Very Simple Words)

**Internet Gateway = Front door of your office building**
- People from outside can come in (inbound)
- People inside can go out (outbound)
- **Use for:** Resources that need to be accessible from internet (API servers)

**NAT Gateway = Back door of your office building**
- People inside can go out (outbound - for updates, downloads)
- People from outside cannot come in (no inbound)
- **Use for:** Resources that need internet access but shouldn't be accessible (background services, databases that need updates)

**Analogy:**
- **Internet Gateway = Reception desk** (public access)
- **NAT Gateway = Service exit** (employees can leave, but public can't enter)

### 4. Internal Working (High-Level)

**Internet Gateway (Public Subnet):**
```
Internet Request → Internet Gateway → Public Subnet → EC2 Instance
EC2 Instance → Internet Gateway → Internet Response
(Two-way communication)
```

**Route Table (Public Subnet):**
```
Destination        Target
10.1.0.0/16       Local
0.0.0.0/0         Internet Gateway
```

**NAT Gateway (Private Subnet):**
```
EC2 Instance (Private) → NAT Gateway → Internet Gateway → Internet
Internet → (Blocked, cannot reach private instance)
(One-way communication, outbound only)
```

**Route Table (Private Subnet):**
```
Destination        Target
10.1.0.0/16       Local
0.0.0.0/0         NAT Gateway
```

**NAT Gateway Architecture:**
```
Internet Gateway (VPC level)
    ↓
NAT Gateway (in Public Subnet, has Elastic IP)
    ↓
Private Subnet (EC2 instances route through NAT Gateway)
```

### 5. .NET Core / C# Real-Time Example

**Public Subnet with Internet Gateway:**
```csharp
// EC2 in Public Subnet (10.1.1.0/24)
// Route Table: 0.0.0.0/0 → Internet Gateway
// Public IP: 54.123.45.67

public class ProductsController : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetProducts()
    {
        // Inbound: Internet users can access this API
        // http://54.123.45.67:5000/products
        
        // Outbound: API can call external services
        var httpClient = new HttpClient();
        var response = await httpClient.GetAsync("https://api.external-service.com/data");
        // Traffic: 10.1.1.50 → Internet Gateway → Internet
        
        return Ok(products);
    }
}
```

**Private Subnet with NAT Gateway:**
```csharp
// EC2 in Private Subnet (10.1.10.0/24)
// Route Table: 0.0.0.0/0 → NAT Gateway
// No Public IP

public class BackgroundJobService
{
    public async Task ProcessJobs()
    {
        // Outbound: Can access internet via NAT Gateway
        // Download NuGet packages, call external APIs
        
        // Install package from NuGet
        // dotnet add package Newtonsoft.Json
        // Traffic: 10.1.10.50 → NAT Gateway → Internet Gateway → Internet
        
        // Call external API
        var httpClient = new HttpClient();
        var response = await httpClient.GetAsync("https://api.payment-gateway.com/process");
        // Traffic: 10.1.10.50 → NAT Gateway → Internet Gateway → Internet
        
        // Inbound: Internet CANNOT access this service
        // If someone tries: http://10.1.10.50:5000 → BLOCKED (no route from internet)
    }
}
```

**Database Subnet (No Gateway):**
```csharp
// RDS in Database Subnet (10.1.20.0/24)
// Route Table: 10.1.0.0/16 → Local only (no internet route)

// Connection from API (in public subnet)
var connectionString = "Server=my-db.abc123.us-east-1.rds.amazonaws.com;Database=MyDB;";
// Traffic: 10.1.1.50 → 10.1.20.50 (internal VPC only)

// Database cannot access internet
// Database cannot be accessed from internet
// Maximum security
```

**NAT Gateway Setup:**
```csharp
// NAT Gateway must be in Public Subnet
// NAT Gateway has Elastic IP (static public IP)

// Public Subnet: 10.1.1.0/24
//   - Internet Gateway attached
//   - NAT Gateway: 10.1.1.100 (Elastic IP: 54.123.45.100)

// Private Subnet: 10.1.10.0/24
//   - Route Table: 0.0.0.0/0 → NAT Gateway (10.1.1.100)
//   - EC2: 10.1.10.50 (no public IP)

// When EC2 (10.1.10.50) accesses internet:
// 1. Traffic goes to NAT Gateway (10.1.1.100)
// 2. NAT Gateway translates source IP to its Elastic IP (54.123.45.100)
// 3. NAT Gateway forwards to Internet Gateway
// 4. Internet Gateway sends to internet
// 5. Response comes back to NAT Gateway's Elastic IP
// 6. NAT Gateway routes back to EC2 (10.1.10.50)
```

### 6. Production Usage Scenario

**Scenario: 3-Tier Architecture**

```
Internet
    ↓
Internet Gateway
    ↓
Public Subnet (10.1.1.0/24)
    - Internet Gateway attached
    - NAT Gateway (10.1.1.100, Elastic IP: 54.123.45.100)
    - EC2 API Instance (10.1.1.50, Public IP: 54.123.45.67)
    ↓
Private Subnet (10.1.10.0/24)
    - Route: 0.0.0.0/0 → NAT Gateway
    - EC2 Background Service (10.1.10.50, No Public IP)
    ↓
Database Subnet (10.1.20.0/24)
    - Route: 10.1.0.0/16 → Local only
    - RDS Database (10.1.20.50, No Public IP)
```

**Traffic Flows:**

1. **User → API (Inbound):**
   ```
   Internet → Internet Gateway → Public Subnet → EC2 API (10.1.1.50)
   ```

2. **API → External Service (Outbound):**
   ```
   EC2 API (10.1.1.50) → Internet Gateway → Internet
   ```

3. **Background Service → External API (Outbound via NAT):**
   ```
   EC2 Background (10.1.10.50) → NAT Gateway → Internet Gateway → Internet
   ```

4. **Internet → Background Service (Blocked):**
   ```
   Internet → (No route, BLOCKED)
   ```

5. **API → Database (Internal):**
   ```
   EC2 API (10.1.1.50) → Local Route → RDS (10.1.20.50)
   ```

### 7. Common Mistakes by .NET Developers

❌ **Mistake 1:** Putting NAT Gateway in private subnet
```csharp
// BAD: NAT Gateway in private subnet
// NAT Gateway needs internet access, must be in public subnet
```
```csharp
// GOOD: NAT Gateway in public subnet
// Public Subnet: Has Internet Gateway
//   - NAT Gateway here
// Private Subnet: Routes to NAT Gateway
```

❌ **Mistake 2:** Not understanding NAT Gateway cost
- NAT Gateway costs ~$32/month + data transfer
- For development/testing, consider NAT Instance (cheaper, but less reliable)
- **Fix:** Use NAT Gateway for production, NAT Instance for dev/test

❌ **Mistake 3:** Thinking private subnet resources can't access internet
```csharp
// BAD: Assuming private subnet = no internet access
// Background service can't download packages, call external APIs
```
```csharp
// GOOD: Private subnet with NAT Gateway
// Can access internet (outbound), but can't be accessed (inbound)
```

❌ **Mistake 4:** Not using Elastic IP for NAT Gateway
```csharp
// BAD: NAT Gateway without Elastic IP
// If NAT Gateway is recreated, IP changes, route tables break
```
```csharp
// GOOD: NAT Gateway with Elastic IP
// Static IP, route tables always work
```

### 8. Interview-Ready Answer

**"Explain Internet Gateway and NAT Gateway"**

**Internet Gateway:**
- Connects your VPC to the internet
- Provides two-way communication (inbound and outbound)
- Must be attached to VPC (one per VPC)
- Used in public subnets for resources that need internet access
- **Route:** 0.0.0.0/0 → Internet Gateway

**NAT Gateway:**
- Allows outbound internet access from private subnets
- Blocks inbound access (internet cannot reach private resources)
- Must be placed in public subnet (needs internet access via Internet Gateway)
- Requires Elastic IP (static public IP)
- **Route:** 0.0.0.0/0 → NAT Gateway (in private subnet route table)

**Key Differences:**
- **Internet Gateway:** Two-way (inbound + outbound), for public resources
- **NAT Gateway:** One-way (outbound only), for private resources that need internet access

**Use Cases:**
- **Internet Gateway:** API servers, web servers (need to be accessible from internet)
- **NAT Gateway:** Background services, databases that need updates (need internet access but shouldn't be accessible)

**Architecture:**
```
Internet Gateway (VPC level)
    ↓
Public Subnet
    - Internet Gateway route (for public resources)
    - NAT Gateway (for private subnet outbound access)
    ↓
Private Subnet
    - NAT Gateway route (outbound only)
```

**For .NET Applications:**
- **API Tier:** Public subnet with Internet Gateway (users can access)
- **Background Services:** Private subnet with NAT Gateway (can download packages, call APIs, but not accessible)
- **Databases:** Isolated subnet, no gateway (maximum security)

**Cost:** Internet Gateway is free. NAT Gateway costs ~$32/month + data transfer.

### 9. Tricky Follow-Up Question

**Q: "Can I have multiple NAT Gateways?"**

**A:** Yes! You typically create one NAT Gateway per Availability Zone for high availability. If NAT Gateway in us-east-1a fails, private subnet in us-east-1b can still use its NAT Gateway.

**Q: "What's the difference between NAT Gateway and NAT Instance?"**

**A:**
- **NAT Gateway:** Managed service, highly available, scales automatically, ~$32/month
- **NAT Instance:** EC2 instance you manage, cheaper (~$15/month), but you handle patching, scaling, availability

**For production:** Use NAT Gateway (managed, reliable).
**For dev/test:** NAT Instance is acceptable (cheaper).

**Q: "Do I need NAT Gateway if my private subnet resources don't need internet access?"**

**A:** No! If your private subnet resources (like databases) don't need internet access, don't add NAT Gateway route. Keep them completely isolated (local route only).

### 10. One-Line Takeaway

**Internet Gateway = Two-way internet access (public resources); NAT Gateway = One-way outbound internet access (private resources); place NAT Gateway in public subnet, use for private subnets that need updates/downloads.**

---

## Question 4: Security Group vs NACL

### 1. Real-world Problem (Without AWS)

You have an EC2 instance running your API. You want to control who can access it.

**Questions:**
- Should you allow HTTP (port 80) from anywhere?
- Should you allow RDP (port 3389) from anywhere? (Security risk!)
- Should you allow database port (1433) from anywhere? (Definitely not!)
- How do you block specific IP addresses?
- How do you allow traffic from specific subnets only?

**The Real Problem:** You need firewall rules, but AWS has two types: Security Groups and NACLs. Which one to use? What's the difference?

### 2. Why AWS Created Security Groups & NACLs

AWS said: *"What if we provide two layers of security: one at the instance level (Security Group) and one at the subnet level (NACL)?"*

**Security Group = Firewall for individual resources** (instance-level, stateful)
**NACL = Firewall for entire subnet** (subnet-level, stateless)

**Both work together for defense in depth.**

### 3. Basic Explanation (Very Simple Words)

**Security Group = Personal bodyguard for your EC2 instance**
- Attached to individual resources (EC2, RDS, etc.)
- **Stateful:** If you allow inbound, outbound is automatically allowed
- **Default:** Deny all inbound, allow all outbound
- **Evaluate all rules:** If any rule allows, traffic is allowed

**NACL (Network ACL) = Building security guard**
- Attached to entire subnet
- **Stateless:** Must explicitly allow both inbound and outbound
- **Default:** Allow all traffic
- **Evaluate in order:** First matching rule wins

**Analogy:**
- **Security Group = Your apartment door lock** (protects your apartment)
- **NACL = Building entrance security** (protects entire building)

### 4. Internal Working (High-Level)

**Security Group (Stateful):**
```
Inbound Request → Security Group checks rules
    ↓
Rule allows? → YES → Allow traffic
    ↓
Response automatically allowed (stateful - remembers connection)
```

**NACL (Stateless):**
```
Inbound Request → NACL checks rules (in order)
    ↓
First matching rule → Allow/Deny
    ↓
Outbound Response → NACL checks rules again (stateless - doesn't remember)
    ↓
Must have explicit outbound rule
```

**Evaluation Order:**

**Security Group:**
- Checks ALL rules
- If ANY rule allows → Allow
- If NO rule allows → Deny

**NACL:**
- Checks rules in order (rule number matters)
- First matching rule → Apply (Allow/Deny)
- If no match → Default (Allow all for custom NACL)

**Traffic Flow:**
```
Internet Request
    ↓
NACL (Subnet level) - First check
    ↓ (if allowed)
Security Group (Instance level) - Second check
    ↓ (if allowed)
EC2 Instance
```

### 5. .NET Core / C# Real-Time Example

**Security Group Configuration:**
```csharp
// Security Group: sg-api-server
// Attached to: EC2 API Instance

// Inbound Rules:
// - HTTP (80) from 0.0.0.0/0 (anywhere)
// - HTTPS (443) from 0.0.0.0/0 (anywhere)
// - RDP (3389) from 203.0.113.0/24 (your office IP only)

// Outbound Rules:
// - All traffic to 0.0.0.0/0 (automatically allowed, stateful)

// Your API
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts()
    {
        // Inbound: Allowed by Security Group (HTTP from anywhere)
        // Outbound: Automatically allowed (stateful)
        return Ok(products);
    }
}
```

**NACL Configuration:**
```csharp
// NACL: nacl-public-subnet
// Attached to: Public Subnet (10.1.1.0/24)

// Inbound Rules (evaluated in order):
// Rule 100: Allow HTTP (80) from 0.0.0.0/0
// Rule 200: Allow HTTPS (443) from 0.0.0.0/0
// Rule 300: Allow RDP (3389) from 203.0.113.0/24 (your office)
// Rule 400: Deny all from 192.0.2.0/24 (block specific IP range)
// Rule *: Allow all (default)

// Outbound Rules (must explicitly allow):
// Rule 100: Allow all to 0.0.0.0/0
// Rule *: Allow all (default)

// Traffic Flow:
// 1. Request comes in → NACL checks (Rule 100 allows HTTP)
// 2. Security Group checks (allows HTTP from anywhere)
// 3. Request reaches EC2
// 4. Response goes out → NACL checks outbound (Rule 100 allows)
// 5. Response sent to internet
```

**Database Security Group:**
```csharp
// Security Group: sg-database
// Attached to: RDS SQL Server

// Inbound Rules:
// - SQL Server (1433) from sg-api-server only (not from internet!)
// - No other inbound rules

// Outbound Rules:
// - All traffic (but database doesn't initiate connections anyway)

// Connection from API
var connectionString = "Server=my-db.abc123.us-east-1.rds.amazonaws.com;Database=MyDB;";
// Security Group allows: Source = sg-api-server, Port = 1433
// Traffic: EC2 (with sg-api-server) → RDS (with sg-database)
```

**Blocking Specific IP with NACL:**
```csharp
// NACL Rules:
// Rule 100: Deny all from 192.0.2.100 (malicious IP)
// Rule 200: Allow HTTP from 0.0.0.0/0
// Rule *: Allow all

// If request comes from 192.0.2.100:
// - NACL Rule 100 matches → DENY (blocked at subnet level)
// - Never reaches Security Group or EC2
```

### 6. Production Usage Scenario

**Scenario: E-commerce API with Database**

**Architecture:**
```
Public Subnet (10.1.1.0/24)
    - NACL: nacl-public (attached to subnet)
    - EC2 API Instance
        - Security Group: sg-api (attached to instance)

Database Subnet (10.1.20.0/24)
    - NACL: nacl-database (attached to subnet)
    - RDS SQL Server
        - Security Group: sg-database (attached to RDS)
```

**Security Group: sg-api**
```
Inbound:
  - HTTP (80) from 0.0.0.0/0
  - HTTPS (443) from 0.0.0.0/0
  - RDP (3389) from 203.0.113.0/24 (office IP)

Outbound:
  - All traffic (automatic, stateful)
```

**Security Group: sg-database**
```
Inbound:
  - SQL Server (1433) from sg-api only (not IP, but Security Group reference!)

Outbound:
  - All traffic
```

**NACL: nacl-public**
```
Inbound:
  - Rule 100: Allow HTTP from 0.0.0.0/0
  - Rule 200: Allow HTTPS from 0.0.0.0/0
  - Rule 300: Deny all from 192.0.2.0/24 (blocked IP range)
  - Rule *: Allow all

Outbound:
  - Rule 100: Allow all
```

**NACL: nacl-database**
```
Inbound:
  - Rule 100: Allow all from 10.1.0.0/16 (VPC internal only)

Outbound:
  - Rule 100: Allow all
```

**Traffic Flow Example:**
```
User Request (HTTP) → nacl-public (Rule 100 allows) → sg-api (allows) → EC2 API
EC2 API → RDS → nacl-database (Rule 100 allows) → sg-database (allows from sg-api) → RDS
```

### 7. Common Mistakes by .NET Developers

❌ **Mistake 1:** Using Security Group IPs instead of Security Group references
```csharp
// BAD: Database Security Group allows from specific IP
// Inbound: SQL Server (1433) from 54.123.45.67
// If EC2 IP changes, connection breaks
```
```csharp
// GOOD: Use Security Group reference
// Inbound: SQL Server (1433) from sg-api (Security Group ID)
// Works even if EC2 IP changes, more secure
```

❌ **Mistake 2:** Opening database port to internet
```csharp
// BAD: Database Security Group
// Inbound: SQL Server (1433) from 0.0.0.0/0
// Anyone on internet can try to connect!
```
```csharp
// GOOD: Database Security Group
// Inbound: SQL Server (1433) from sg-api only
// Only API servers can connect
```

❌ **Mistake 3:** Not understanding stateful vs stateless
```csharp
// BAD: Thinking NACL works like Security Group
// NACL: Allow inbound HTTP
// Forgot to allow outbound HTTP response
// Result: Requests work, but responses blocked!
```
```csharp
// GOOD: Understand stateless nature
// NACL: Allow inbound HTTP AND outbound HTTP (explicitly)
```

❌ **Mistake 4:** Using NACL for everything
```csharp
// BAD: Using NACL for fine-grained access control
// NACL is for subnet-level rules, not instance-level
```
```csharp
// GOOD: Use Security Groups for instance-level rules
// Use NACL for subnet-level rules (block IP ranges, etc.)
```

### 8. Interview-Ready Answer

**"What's the difference between Security Groups and NACLs?"**

**Security Groups:**
- **Level:** Instance/resource level (attached to EC2, RDS, etc.)
- **State:** Stateful (if inbound allowed, outbound automatically allowed)
- **Default:** Deny all inbound, allow all outbound
- **Evaluation:** All rules evaluated, if any allows → allow
- **Use Case:** Primary firewall for resources, fine-grained access control

**NACLs (Network ACLs):**
- **Level:** Subnet level (attached to entire subnet)
- **State:** Stateless (must explicitly allow inbound AND outbound)
- **Default:** Allow all traffic (for custom NACLs)
- **Evaluation:** Rules evaluated in order, first match wins
- **Use Case:** Subnet-level firewall, block IP ranges, additional security layer

**Key Differences:**
1. **Scope:** Security Group = instance, NACL = subnet
2. **State:** Security Group = stateful, NACL = stateless
3. **Default:** Security Group = deny inbound, NACL = allow all
4. **Evaluation:** Security Group = all rules, NACL = first match

**Best Practices:**
- **Use Security Groups** as primary firewall (easier, stateful, instance-level)
- **Use NACLs** for subnet-level rules (block IP ranges, additional layer)
- **Reference Security Groups** in rules (not IPs) for flexibility
- **Defense in depth:** Use both (NACL as first line, Security Group as second line)

**For .NET Applications:**
- **API Security Group:** Allow HTTP/HTTPS from internet, RDP from office IP
- **Database Security Group:** Allow SQL Server port from API Security Group only
- **NACL:** Block known malicious IP ranges, allow VPC internal traffic

**Traffic Flow:** Internet → NACL (subnet) → Security Group (instance) → Resource

### 9. Tricky Follow-Up Question

**Q: "Can I use Security Groups to block traffic?"**

**A:** Security Groups are "allow-only" - they can't explicitly deny. If no rule allows, traffic is denied. To block specific traffic, use NACL (which can explicitly deny).

**Q: "What happens if both Security Group and NACL deny traffic?"**

**A:** Traffic is denied. Both must allow for traffic to pass. NACL is checked first (subnet level), then Security Group (instance level).

**Q: "Can I attach multiple Security Groups to one EC2 instance?"**

**A:** Yes! You can attach up to 5 Security Groups per network interface. Useful for combining rules (e.g., one SG for HTTP, one for RDP).

### 10. One-Line Takeaway

**Security Group = Instance-level stateful firewall (primary defense); NACL = Subnet-level stateless firewall (additional layer); use Security Groups for fine-grained control, NACLs for subnet-level blocking.**

---

