# 02. Compute (From Zero) - Part 1

---

## Question 1: What is a Server?

### 1. Real-world Problem (Without AWS)

You wrote a beautiful ASP.NET Core API:
```csharp
public class WeatherController : ControllerBase
{
    [HttpGet]
    public IActionResult GetWeather() => Ok("Sunny, 25°C");
}
```

**The Problem:** Your code runs on YOUR laptop. Only YOU can access it via `http://localhost:5000`. Your users can't access it because it's on your local machine.

**What You Need:** A computer that:
- Runs 24/7 (not your laptop that you turn off)
- Has a public IP address (so users can reach it)
- Can handle multiple requests simultaneously
- Is secure and reliable

**That computer = A SERVER**

### 2. Why AWS Introduced EC2 (Elastic Compute Cloud)

AWS said: *"Instead of buying a physical server, what if we give you a virtual server in minutes? You can start it, stop it, resize it, all via API calls."*

**Traditional Way:**
- Buy physical server: $5,000
- Wait 2-3 weeks for delivery
- Install OS, configure: 1-2 days
- If you need more power: Buy another server

**AWS Way:**
- Launch virtual server: 2 minutes
- Resize it: 5 minutes (change instance type)
- If you need more: Launch 10 servers in 2 minutes
- Pay only when running

### 3. Basic Explanation (Very Simple Words)

**Server = A computer that runs your application 24/7 and serves requests over the internet**

**Physical Server:**
- A real computer in a data center
- Has CPU, RAM, hard disk, network card
- You can touch it (if you're in the data center)

**Virtual Server (EC2):**
- A "slice" of a physical server
- AWS takes one powerful physical server
- Divides it into multiple virtual servers
- Each virtual server acts like its own computer
- You can't touch it (it's in AWS's data center)

**Analogy:**
- **Physical Server = An entire apartment building**
- **Virtual Server (EC2) = One apartment in that building**
- You rent the apartment, not the whole building

### 4. Internal Working (High-Level)

**When You Launch an EC2 Instance:**

1. **You Request:** "I want a server with 2 CPU, 4 GB RAM, Windows Server 2022"

2. **AWS's Hypervisor (Virtualization Software):**
   - Finds a physical server with available resources
   - Creates a "virtual machine" (VM) on that physical server
   - Allocates: 2 virtual CPUs, 4 GB virtual RAM, virtual disk
   - Installs Windows Server 2022 on the VM

3. **AWS Gives You:**
   - Public IP address (e.g., 54.123.45.67)
   - Private IP address (e.g., 10.0.1.50)
   - Credentials (username/password or key pair)
   - Ability to connect via RDP (Windows) or SSH (Linux)

4. **You Connect and Deploy:**
   ```powershell
   # Connect via RDP
   # Install .NET 8 Runtime
   # Deploy your API
   ```

5. **Your API is Now Live:**
   - Users access: `http://54.123.45.67:5000`
   - EC2 instance runs your API
   - AWS monitors the physical server health

**Behind the Scenes:**
- One physical server can run 10-50 virtual servers (depending on size)
- AWS uses **virtualization** (like VMware, Hyper-V)
- If physical server fails, AWS automatically moves your VM to another server

### 5. .NET Core / C# Real-Time Example

**Step 1: Launch EC2 Instance (via AWS Console or CLI)**
```bash
# AWS CLI command (or use Console)
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t3.medium \
  --key-name my-keypair \
  --security-group-ids sg-12345678
```

**Step 2: Connect to EC2 (RDP for Windows)**
```powershell
# Get public IP from AWS Console
# Connect via RDP: 54.123.45.67
# Login with Administrator credentials
```

**Step 3: Install .NET 8 Runtime**
```powershell
# On EC2 Windows Server
# Download .NET 8 Runtime installer
# Install it
```

**Step 4: Deploy Your API**
```csharp
// Your API code (already built)
// Copy to EC2 (via RDP file share or SCP)

// On EC2, run:
dotnet MyApi.dll --urls "http://0.0.0.0:5000"

// Or use Windows Service / IIS
```

**Step 5: Access Your API**
```csharp
// From anywhere on internet:
var client = new HttpClient();
var response = await client.GetAsync("http://54.123.45.67:5000/weather");
// ✅ Your API is live!
```

### 6. Production Usage Scenario

**Scenario:** E-commerce API serving 1000 requests/minute

**Single EC2 Instance (t3.medium):**
- 2 vCPU, 4 GB RAM
- Handles ~500 requests/minute comfortably
- **Problem:** At 1000 requests/minute, server overloads

**Solution: Multiple EC2 Instances + Load Balancer:**
- Launch 3 EC2 instances (t3.medium each)
- Put them behind Application Load Balancer (ALB)
- ALB distributes traffic: 333 requests/minute per instance
- **Result:** All requests handled smoothly

**If Traffic Spikes to 5000 requests/minute:**
- Auto Scaling Group detects high CPU
- Automatically launches 5 more EC2 instances
- Now 8 instances total, each handling ~625 requests/minute
- **Zero manual intervention**

### 7. Common Mistakes by .NET Developers

❌ **Mistake 1:** Thinking EC2 = Your laptop
```csharp
// BAD: Assuming localhost behavior
var connectionString = "Server=localhost;Database=MyDB;";
// On EC2, "localhost" refers to the EC2 instance itself, not your machine
```
```csharp
// GOOD: Use environment variables or configuration
var connectionString = Configuration["ConnectionStrings:DefaultConnection"];
// Or use RDS endpoint: mydb.abc123.us-east-1.rds.amazonaws.com
```

❌ **Mistake 2:** Not securing the server
```csharp
// BAD: Opening port 5000 to entire internet
// Security Group: Allow 0.0.0.0/0 on port 5000
// Anyone can access your API, DDoS attacks possible
```
```csharp
// GOOD: Restrict access
// Security Group: Allow only your office IP or Load Balancer
// Or use Application Load Balancer (ALB) with WAF
```

❌ **Mistake 3:** Hardcoding IP addresses
```csharp
// BAD
var apiUrl = "http://54.123.45.67:5000";
// If you stop/start EC2, IP changes!
```
```csharp
// GOOD: Use Elastic IP or Load Balancer DNS
var apiUrl = Configuration["ApiBaseUrl"];
// Or: http://my-api-123456789.us-east-1.elb.amazonaws.com
```

❌ **Mistake 4:** Not monitoring the server
- Assuming "it just works"
- **Reality:** Servers can fail, run out of memory, disk space
- **Fix:** Use CloudWatch to monitor CPU, memory, disk

### 8. Interview-Ready Answer

**"What is a Server?"**

A server is a computer that runs applications 24/7 and serves requests over the internet. Unlike your development laptop, a server is designed for:
- **Availability:** Runs continuously without interruption
- **Public Access:** Has a public IP address so users can reach it
- **Concurrent Requests:** Handles multiple users simultaneously
- **Reliability:** Built with redundancy and monitoring

**Physical vs Virtual Servers:**
- **Physical Server:** A real computer in a data center (you own/rent the hardware)
- **Virtual Server (EC2):** A virtualized "slice" of a physical server (you rent computing resources)

**AWS EC2 (Elastic Compute Cloud):**
- Provides virtual servers in the cloud
- Launch in minutes, resize on-demand
- Pay only when running
- Automatically backed by AWS's global infrastructure

**For .NET Applications:** EC2 allows you to deploy ASP.NET Core APIs, Windows Services, or any .NET application on virtual Windows or Linux servers, with the ability to scale horizontally (add more instances) as traffic grows.

### 9. Tricky Follow-Up Question

**Q: "What's the difference between a server and a container?"**

**A:** 
- **Server (EC2):** Full virtual machine with its own OS (Windows Server or Linux). You manage the OS, install software, configure it.
- **Container (Docker on ECS/EKS):** Lightweight package that includes your app + dependencies, but shares the host OS. Faster to start, more efficient, but less isolation.

**For .NET:** You can run .NET apps on EC2 (traditional) or containerize with Docker and run on ECS/EKS (modern, cloud-native).

**Q: "Can I run Windows Server on EC2?"**

**A:** Yes! AWS provides Windows Server AMIs (Amazon Machine Images) with Windows Server 2019, 2022, etc. You pay for the EC2 instance + Windows Server license (included in the price). Perfect for .NET Framework apps that require Windows.

### 10. One-Line Takeaway

**Server = A computer that runs your app 24/7 and serves users over the internet; EC2 = Virtual servers you can launch in minutes, resize on-demand, pay-as-you-go.**

---

## Question 2: EC2 Explained from Scratch

### 1. Real-world Problem (Without AWS)

You need to deploy your ASP.NET Core API. You have two options:

**Option 1: Buy Physical Server**
- Cost: $5,000 upfront
- Time: 2-3 weeks delivery + 2 days setup
- Flexibility: Fixed hardware, can't resize easily
- Maintenance: You handle everything

**Option 2: Use AWS EC2**
- Cost: $30/month (pay-as-you-go)
- Time: 2 minutes to launch
- Flexibility: Resize in 5 minutes, launch 10 servers instantly
- Maintenance: AWS handles hardware, you handle OS/app

**The Problem:** As a developer, you want Option 2, but you need to understand HOW it works.

### 2. Why AWS Created EC2

AWS realized: *"Developers don't want to buy servers. They want computing power on-demand, like turning on a light switch."*

EC2 (Elastic Compute Cloud) = Virtual servers that you can:
- Launch in minutes
- Stop/start on-demand
- Resize (change instance type)
- Scale horizontally (launch multiple instances)
- Pay only when running

**"Elastic"** = Can expand/contract based on demand (like elastic band)

### 3. Basic Explanation (Very Simple Words)

**EC2 = Virtual servers in the cloud**

**Key Concepts:**

1. **Instance:** One virtual server (like one computer)
2. **Instance Type:** The "size" of the server (CPU, RAM)
   - `t3.micro`: 2 vCPU, 1 GB RAM (free tier, testing)
   - `t3.medium`: 2 vCPU, 4 GB RAM (small APIs)
   - `m5.large`: 2 vCPU, 8 GB RAM (medium workloads)
   - `c5.xlarge`: 4 vCPU, 8 GB RAM (CPU-intensive)
3. **AMI (Amazon Machine Image):** Pre-configured OS template
   - Windows Server 2022, Ubuntu, Amazon Linux, etc.
4. **Security Group:** Virtual firewall (controls inbound/outbound traffic)
5. **Key Pair:** SSH/RDP credentials (like a password, but more secure)

**Simple Flow:**
1. Choose AMI (OS) → 2. Choose instance type (size) → 3. Configure security → 4. Launch → 5. Connect & deploy

### 4. Internal Working (High-Level)

**When You Launch an EC2 Instance:**

```
Step 1: You Click "Launch Instance"
    ↓
Step 2: AWS Hypervisor Finds Available Physical Server
    ↓
Step 3: AWS Creates Virtual Machine (VM)
    - Allocates CPU cores (virtual)
    - Allocates RAM (virtual)
    - Creates virtual disk (EBS volume)
    - Attaches virtual network interface
    ↓
Step 4: AWS Installs OS from AMI
    - Copies OS files to virtual disk
    - Configures network
    - Sets up initial user
    ↓
Step 5: AWS Assigns IP Addresses
    - Private IP: 10.0.1.50 (internal AWS network)
    - Public IP: 54.123.45.67 (internet-accessible)
    ↓
Step 6: AWS Applies Security Group Rules
    - Allows RDP (port 3389) from your IP
    - Allows HTTP (port 80) from anywhere
    ↓
Step 7: Instance is "Running"
    - You can connect via RDP/SSH
    - You can deploy your application
```

**Instance Lifecycle:**
- **Pending:** AWS is setting it up
- **Running:** Instance is live, you can use it
- **Stopped:** Instance is paused, you don't pay for compute (but pay for storage)
- **Terminated:** Instance is deleted, you pay nothing

### 5. .NET Core / C# Real-Time Example

**Launching EC2 Instance (AWS Console):**

1. **Choose AMI:**
   - Search: "Windows Server 2022"
   - Select: "Microsoft Windows Server 2022 Base"

2. **Choose Instance Type:**
   ```csharp
   // For small API: t3.medium (2 vCPU, 4 GB RAM)
   // Cost: ~$0.0416/hour = $30/month
   
   // For production: t3.large (2 vCPU, 8 GB RAM)
   // Cost: ~$0.0832/hour = $60/month
   ```

3. **Configure Security Group:**
   ```csharp
   // Inbound Rules:
   // - RDP (3389) from My IP only
   // - HTTP (80) from 0.0.0.0/0 (or Load Balancer only)
   // - HTTPS (443) from 0.0.0.0/0
   ```

4. **Launch & Connect:**
   ```powershell
   # Get public IP from AWS Console
   # Connect via RDP: 54.123.45.67
   # Login with Administrator / your key pair password
   ```

5. **Install .NET 8:**
   ```powershell
   # On EC2 Windows Server
   # Download .NET 8 Runtime from Microsoft
   # Install it
   ```

6. **Deploy Your API:**
   ```csharp
   // Copy your published API to EC2
   // C:\app\MyApi\
   
   // Run it
   dotnet MyApi.dll --urls "http://0.0.0.0:5000"
   
   // Or configure as Windows Service
   // Or use IIS
   ```

7. **Test Your API:**
   ```csharp
   // From your local machine
   var client = new HttpClient();
   var response = await client.GetAsync("http://54.123.45.67:5000/weather");
   var content = await response.Content.ReadAsStringAsync();
   Console.WriteLine(content); // "Sunny, 25°C"
   ```

### 6. Production Usage Scenario

**Scenario:** ASP.NET Core API with variable traffic

**Development/Testing:**
- Instance: `t3.micro` (free tier eligible)
- Cost: $0/month (if within free tier limits)
- Use: Local development, testing

**Staging:**
- Instance: `t3.small` (2 vCPU, 2 GB RAM)
- Cost: ~$15/month
- Use: Pre-production testing

**Production:**
- Instances: 3 × `t3.medium` (behind Load Balancer)
- Cost: ~$90/month
- Auto Scaling: 2-10 instances based on traffic
- **Peak hours (9 AM - 5 PM):** 5-8 instances running
- **Off-peak (nights/weekends):** 2-3 instances running
- **Average cost:** ~$120/month (vs $270/month if always 5 instances)

**High-Traffic Production:**
- Instances: `m5.large` (2 vCPU, 8 GB RAM)
- Cost: ~$0.096/hour = $70/month per instance
- Auto Scaling: 5-20 instances
- **Peak:** 15 instances = $1,050/month
- **Off-peak:** 5 instances = $350/month

### 7. Common Mistakes by .NET Developers

❌ **Mistake 1:** Choosing wrong instance type
```csharp
// BAD: Using m5.xlarge (4 vCPU, 16 GB RAM) for simple API
// Cost: $0.192/hour = $140/month
// Your API only uses 10% CPU, 2 GB RAM
// WASTE: Paying for unused resources

// GOOD: Use t3.medium (2 vCPU, 4 GB RAM)
// Cost: $0.0416/hour = $30/month
// t3 instances are "burstable" - perfect for variable traffic
```

❌ **Mistake 2:** Not using Auto Scaling
```csharp
// BAD: Fixed 5 instances running 24/7
// Cost: 5 × $30 = $150/month
// During nights: 4 instances idle (waste $120/month)

// GOOD: Auto Scaling Group
// Min: 2, Desired: 3, Max: 10
// Scale up during peak, down during off-peak
// Average cost: $90/month (40% savings)
```

❌ **Mistake 3:** Exposing RDP to entire internet
```csharp
// BAD: Security Group allows RDP (3389) from 0.0.0.0/0
// Anyone can try to brute-force your server
// RISK: Security breach

// GOOD: Security Group allows RDP only from your office IP
// Or use AWS Systems Manager Session Manager (no RDP needed)
```

❌ **Mistake 4:** Not using Elastic IP
```csharp
// BAD: Using public IP that changes on stop/start
// Your API URL: http://54.123.45.67:5000
// If you stop instance, IP changes to 54.123.45.68
// DNS breaks, users can't access

// GOOD: Use Elastic IP (static IP)
// Associate Elastic IP to instance
// IP never changes, even after stop/start
```

### 8. Interview-Ready Answer

**"Explain EC2"**

EC2 (Elastic Compute Cloud) is AWS's service for virtual servers in the cloud. It allows you to launch, configure, and manage virtual machines (instances) on-demand.

**Key Components:**

1. **Instance:** A virtual server with CPU, RAM, storage, and networking
2. **Instance Types:** Different configurations (t3.micro for testing, m5.large for production)
3. **AMI (Amazon Machine Image):** Pre-configured OS templates (Windows Server, Linux)
4. **Security Groups:** Virtual firewalls controlling inbound/outbound traffic
5. **Key Pairs:** SSH/RDP authentication credentials
6. **EBS Volumes:** Persistent block storage (like hard drives)

**Key Features:**
- **Elasticity:** Launch/terminate instances in minutes
- **Scalability:** Launch multiple instances, use Auto Scaling
- **Flexibility:** Choose OS, instance size, storage
- **Pay-as-you-go:** Pay only when instances are running

**For .NET Applications:** EC2 allows deployment of ASP.NET Core APIs, Windows Services, or any .NET application on Windows Server or Linux instances. You can use Auto Scaling Groups to handle traffic spikes and Application Load Balancer for high availability.

**Best Practices:**
- Use multiple Availability Zones for redundancy
- Implement Auto Scaling for cost optimization
- Use Security Groups to restrict access
- Associate Elastic IPs for static public IPs
- Enable CloudWatch monitoring

### 9. Tricky Follow-Up Question

**Q: "What's the difference between stopping and terminating an EC2 instance?"**

**A:**
- **Stopping:** Instance is paused, you don't pay for compute, but you pay for EBS storage. Instance ID, IP (if Elastic IP), and configuration are preserved. You can start it again.
- **Terminating:** Instance is permanently deleted. You don't pay for compute or storage. Instance ID is gone. You cannot start it again.

**Use Case:** Stop instances for temporary cost savings (dev/test). Terminate when you no longer need the instance.

**Q: "Can I change the instance type of a running EC2?"**

**A:** Not directly. You must:
1. Stop the instance
2. Change instance type (in Console or CLI)
3. Start the instance

**Note:** This causes downtime. For production, use Auto Scaling Groups or launch new instances with desired type and replace old ones.

### 10. One-Line Takeaway

**EC2 = Virtual servers you can launch in minutes, resize on-demand, scale horizontally; pay only when running, perfect for deploying .NET applications in the cloud.**

---

## Question 3: Running ASP.NET Core API on EC2

### 1. Real-world Problem (Without AWS)

You built an ASP.NET Core API:
```csharp
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts() => Ok(products);
}
```

**The Problem:** It runs on `localhost:5000` on your laptop. How do you make it accessible to users worldwide?

**Options:**
1. **Port forwarding on your router** → Security risk, your laptop must be on 24/7
2. **Deploy to company server** → Takes days, requires IT approval
3. **Deploy to AWS EC2** → Takes 10 minutes, professional, scalable

### 2. Why Deploy .NET Apps on EC2

EC2 provides:
- **Public IP address** → Users can reach your API
- **24/7 availability** → Server runs continuously
- **Scalability** → Launch multiple instances for high traffic
- **Professional infrastructure** → AWS handles hardware, networking, security

**For .NET Developers:** EC2 supports both Windows Server (for .NET Framework) and Linux (for .NET Core/.NET 5+), giving you flexibility.

### 3. Basic Explanation (Very Simple Words)

**Deploying .NET API on EC2 = Moving your API from your laptop to a cloud server**

**Steps:**
1. **Launch EC2 instance** (virtual server)
2. **Install .NET Runtime** on that server
3. **Copy your API files** to the server
4. **Run your API** on the server
5. **Users access** via the server's public IP

**Result:** Your API is live on the internet, accessible 24/7.

### 4. Internal Working (High-Level)

**Deployment Flow:**

```
Your Laptop (Development)
    ↓ (Build & Publish)
Published API Files (.dll, .exe, dependencies)
    ↓ (Copy to EC2)
EC2 Instance (Windows Server or Linux)
    ↓ (Install .NET Runtime)
    ↓ (Run API)
    ↓
API Listens on Port 5000
    ↓
Security Group Allows Port 5000
    ↓
Users Access: http://54.123.45.67:5000
    ↓
EC2 Routes Request to Your API
    ↓
API Processes Request, Returns Response
```

**Options for Running API on EC2:**

1. **Self-Hosted (Kestrel):**
   ```bash
   dotnet MyApi.dll --urls "http://0.0.0.0:5000"
   ```
   - Simple, direct
   - Good for development/testing

2. **Windows Service:**
   - Install as Windows Service
   - Runs automatically on boot
   - Better for production

3. **IIS (Internet Information Services):**
   - Windows web server
   - Handles load balancing, SSL
   - Best for production Windows deployments

4. **Docker Container:**
   - Package API in Docker image
   - Run on ECS/EKS
   - Modern, cloud-native approach

### 5. .NET Core / C# Real-Time Example

**Step 1: Build & Publish Your API**
```csharp
// Your API (Program.cs)
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
var app = builder.Build();
app.MapControllers();
app.Run("http://0.0.0.0:5000");
```

```bash
# On your laptop, publish
dotnet publish -c Release -o ./publish

# Output: ./publish/MyApi.dll
```

**Step 2: Launch EC2 Instance**
```bash
# AWS Console or CLI
# - AMI: Windows Server 2022 or Amazon Linux 2023
# - Instance Type: t3.medium
# - Security Group: Allow HTTP (80), HTTPS (443), RDP/SSH (your IP)
```

**Step 3: Connect to EC2**
```powershell
# Windows Server: RDP
# Get public IP: 54.123.45.67
# Connect via RDP, login as Administrator

# Linux: SSH
ssh -i my-key.pem ec2-user@54.123.45.67
```

**Step 4: Install .NET Runtime (Windows)**
```powershell
# On EC2 Windows Server
# Download .NET 8 Runtime from Microsoft
# Install: dotnet-runtime-8.0.x-win-x64.exe
```

**Step 5: Copy API Files to EC2**
```powershell
# Option 1: RDP file share (Windows)
# Copy ./publish folder to EC2 C:\app\

# Option 2: SCP (Linux)
scp -i my-key.pem -r ./publish ec2-user@54.123.45.67:/app/

# Option 3: S3 (Best for production)
# Upload to S3, download on EC2
aws s3 cp s3://my-bucket/api/publish.zip ./
```

**Step 6: Run Your API**
```powershell
# Windows
cd C:\app\publish
dotnet MyApi.dll

# Or as Windows Service (production)
# Use NSSM (Non-Sucking Service Manager) or sc.exe
```

```bash
# Linux
cd /app/publish
dotnet MyApi.dll
```

**Step 7: Test Your API**
```csharp
// From your laptop or browser
var client = new HttpClient();
var response = await client.GetAsync("http://54.123.45.67:5000/products");
var products = await response.Content.ReadAsStringAsync();
Console.WriteLine(products);
```

**Step 8: Make it Production-Ready (Windows Service)**
```csharp
// Install as Windows Service using NSSM
// nssm install MyApiService "C:\Program Files\dotnet\dotnet.exe" "C:\app\publish\MyApi.dll"
// nssm start MyApiService

// Now API runs automatically on boot, restarts on crash
```

### 6. Production Usage Scenario

**Scenario:** E-commerce API serving 1000 requests/minute

**Architecture:**
```
Internet
    ↓
Application Load Balancer (ALB)
    ↓
3 × EC2 Instances (t3.medium, Windows Server 2022)
    - Instance 1: 10.0.1.10 (runs API on port 5000)
    - Instance 2: 10.0.1.11 (runs API on port 5000)
    - Instance 3: 10.0.1.12 (runs API on port 5000)
    ↓
RDS SQL Server (database)
```

**Deployment Process:**

1. **Build & Package:**
   ```bash
   dotnet publish -c Release -o ./publish
   # Package as ZIP
   Compress-Archive -Path ./publish -DestinationPath api.zip
   ```

2. **Upload to S3:**
   ```bash
   aws s3 cp api.zip s3://my-deployment-bucket/api/v1.0.0/api.zip
   ```

3. **Deploy to EC2 (via User Data or deployment script):**
   ```powershell
   # On each EC2 instance (automated)
   # Download from S3
   aws s3 cp s3://my-deployment-bucket/api/v1.0.0/api.zip C:\app\api.zip
   
   # Extract
   Expand-Archive -Path C:\app\api.zip -DestinationPath C:\app\api -Force
   
   # Stop existing service
   Stop-Service MyApiService
   
   # Copy new files
   Copy-Item -Path C:\app\api\* -Destination C:\app\publish -Recurse -Force
   
   # Start service
   Start-Service MyApiService
   ```

4. **Health Check:**
   - ALB checks: `http://10.0.1.10:5000/health`
   - If unhealthy, ALB stops routing traffic to that instance

### 7. Common Mistakes by .NET Developers

❌ **Mistake 1:** Running API in foreground (terminal)
```csharp
// BAD: Running in PowerShell window
dotnet MyApi.dll
// If you close RDP session, API stops
// If EC2 reboots, API doesn't start automatically
```
```csharp
// GOOD: Run as Windows Service
// API runs in background, starts on boot, restarts on crash
```

❌ **Mistake 2:** Binding to localhost only
```csharp
// BAD
app.Run("http://localhost:5000");
// Only accessible from EC2 itself, not from internet
```
```csharp
// GOOD
app.Run("http://0.0.0.0:5000");
// 0.0.0.0 = listen on all network interfaces
// Accessible from internet (if Security Group allows)
```

❌ **Mistake 3:** Not handling graceful shutdown
```csharp
// BAD: No shutdown handling
// When you stop service, active requests are killed
```
```csharp
// GOOD: Handle shutdown gracefully
var app = builder.Build();
var lifetime = app.Services.GetRequiredService<IHostApplicationLifetime>();
lifetime.ApplicationStopping.Register(() =>
{
    // Wait for active requests to complete
    Thread.Sleep(5000);
});
```

❌ **Mistake 4:** Hardcoding configuration
```csharp
// BAD
var connectionString = "Server=localhost;Database=MyDB;";
// Hardcoded, can't change without redeploy
```
```csharp
// GOOD: Use environment variables or AWS Systems Manager
var connectionString = Environment.GetEnvironmentVariable("DB_CONNECTION_STRING");
// Or: Configuration["ConnectionStrings:DefaultConnection"]
// Set via AWS Systems Manager Parameter Store
```

### 8. Interview-Ready Answer

**"How do you deploy an ASP.NET Core API on EC2?"**

**Steps:**

1. **Build & Publish:**
   ```bash
   dotnet publish -c Release -o ./publish
   ```

2. **Launch EC2 Instance:**
   - Choose AMI (Windows Server 2022 or Linux)
   - Choose instance type (t3.medium for small APIs)
   - Configure Security Group (allow HTTP/HTTPS, RDP/SSH)

3. **Install .NET Runtime:**
   - Windows: Download and install .NET Runtime
   - Linux: `sudo yum install dotnet-runtime-8.0`

4. **Deploy Application:**
   - Copy published files to EC2 (via SCP, S3, or RDP)
   - Place in directory like `C:\app\` or `/app/`

5. **Run Application:**
   - **Development:** `dotnet MyApi.dll --urls "http://0.0.0.0:5000"`
   - **Production:** Install as Windows Service or systemd service
   - Ensure it binds to `0.0.0.0` (not `localhost`) to accept external traffic

6. **Configure for Production:**
   - Use Application Load Balancer for high availability
   - Set up Auto Scaling Group
   - Enable CloudWatch logging
   - Use IAM roles (not hardcoded credentials)
   - Store configuration in AWS Systems Manager Parameter Store

**Best Practices:**
- Use Windows Service (Windows) or systemd (Linux) for automatic startup
- Implement health check endpoint (`/health`)
- Use environment variables or AWS Parameter Store for configuration
- Enable HTTPS (use AWS Certificate Manager)
- Set up centralized logging (CloudWatch Logs)

### 9. Tricky Follow-Up Question

**Q: "Should I use Windows Server or Linux for .NET Core API?"**

**A:** 
- **Linux:** Cheaper (~40% less), faster startup, better for containers, modern choice for .NET Core/.NET 5+
- **Windows Server:** Required for .NET Framework, familiar for Windows developers, more expensive

**For .NET Core/.NET 5+:** Linux is recommended (cost-effective, cloud-native).

**Q: "How do you handle zero-downtime deployments on EC2?"**

**A:** 
1. **Blue-Green Deployment:**
   - Deploy new version to new EC2 instances (green)
   - Test green environment
   - Switch Load Balancer from blue (old) to green (new)
   - Terminate blue instances

2. **Rolling Update (Auto Scaling Group):**
   - Launch new instances with new version
   - Wait for health checks to pass
   - Terminate old instances one by one
   - ALB automatically routes to healthy instances

3. **Use Elastic Beanstalk or ECS:** Handles zero-downtime deployments automatically.

### 10. One-Line Takeaway

**Deploying .NET API on EC2 = Build, publish, copy to EC2, install runtime, run as service; use Load Balancer + Auto Scaling for production, bind to 0.0.0.0 for external access.**

---

