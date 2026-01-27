# Azure Cloud Services - Interview Guide

## What is Azure?

**Microsoft Azure** is a cloud computing platform providing infrastructure, platform, and software services. It offers virtual machines, databases, storage, networking, and more.

**Key Concepts:**
- **IaaS** (Infrastructure as a Service): VMs, storage, networking
- **PaaS** (Platform as a Service): App Service, databases (managed)
- **SaaS** (Software as a Service): Office 365, Dynamics

---

## 1. Core Services

### Azure App Service (Web Apps)

**Purpose**: Host web applications without managing infrastructure

**Supported Frameworks:**
- .NET, .NET Core
- Node.js
- Python
- Java
- PHP

**Features:**
- Automatic scaling
- SSL certificates
- Deployment slots (staging/production)
- Continuous deployment (GitHub, Azure DevOps)
- Built-in load balancing

**Creating Web App:**
1. Azure Portal → Create Resource → Web App
2. Configure:
   - **Name**: Unique name (e.g., `myapp.azurewebsites.net`)
   - **Runtime Stack**: .NET 6, .NET 8, etc.
   - **Operating System**: Windows or Linux
   - **App Service Plan**: Pricing tier (Free, Basic, Standard, Premium)
3. Deploy code (FTP, Git, ZIP deploy, Azure DevOps)

**Configuration:**
- **Application Settings**: Environment variables, connection strings
- **Configuration → Application Settings**
- Access in code: `Configuration["SettingName"]`

**Deployment Slots:**
- **Production**: Live site
- **Staging**: Test before swapping
- **Swap**: Switch staging to production (zero downtime)

**Scaling:**
- **Scale Up**: Change pricing tier (more CPU/memory)
- **Scale Out**: Add more instances (horizontal scaling)
- **Auto-scale**: Automatically scale based on metrics (CPU, memory, requests)

### Azure SQL Database

**Purpose**: Managed SQL Server database in cloud

**Features:**
- Automatic backups
- High availability (99.99% SLA)
- Automatic patching
- Built-in security
- Elastic pools (share resources across databases)

**Service Tiers:**
- **Basic**: Low cost, limited performance
- **Standard**: Balanced performance
- **Premium**: High performance, more features
- **Hyperscale**: Very large databases

**Creating SQL Database:**
1. Azure Portal → Create Resource → SQL Database
2. Configure:
   - **Database name**
   - **Server**: Create new or use existing
   - **Compute + storage**: DTU or vCore model
   - **Backup**: Geo-redundant backup
3. Set firewall rules (allow Azure services, specific IPs)

**Connection String:**
```
Server=tcp:myserver.database.windows.net,1433;
Database=mydb;
User ID=myuser;
Password=mypassword;
Encrypt=True;
```

**Firewall Rules:**
- Allow Azure Services: Enable for App Services
- Add client IP: Your current IP
- Virtual network rules: Allow from VNet

### Azure Storage

**Blob Storage:**
- Store unstructured data (images, videos, documents)
- **Access Tiers**: Hot (frequent), Cool (infrequent), Archive (rarely accessed)
- **Containers**: Like folders
- **Blobs**: Files

**Table Storage:**
- NoSQL key-value store
- Fast, scalable
- Good for structured data

**Queue Storage:**
- Message queue for async processing
- Decouple components
- Reliable message delivery

**Example - Blob Storage:**
```csharp
// Install: Azure.Storage.Blobs
var connectionString = "DefaultEndpointsProtocol=https;AccountName=...";
var containerName = "images";

var blobServiceClient = new BlobServiceClient(connectionString);
var containerClient = blobServiceClient.GetBlobContainerClient(containerName);

// Upload
var blobClient = containerClient.GetBlobClient("photo.jpg");
await blobClient.UploadAsync(stream);

// Download
var download = await blobClient.DownloadAsync();
```

### Azure Key Vault

**Purpose**: Securely store secrets, keys, certificates

**What to Store:**
- Connection strings
- API keys
- Passwords
- SSL certificates
- Storage account keys

**Benefits:**
- Centralized secret management
- Access control (RBAC)
- Audit logging
- Automatic rotation (for some secrets)

**Using Key Vault:**
```csharp
// Install: Azure.Security.KeyVault.Secrets
var keyVaultUrl = "https://myvault.vault.azure.net/";
var client = new SecretClient(new Uri(keyVaultUrl), new DefaultAzureCredential());

// Get secret
var secret = await client.GetSecretAsync("DatabaseConnectionString");
string connectionString = secret.Value.Value;
```

**Managed Identity:**
- App Service can access Key Vault without storing credentials
- Enable in App Service → Identity → System assigned

### Azure Application Insights

**Purpose**: Application performance monitoring and diagnostics

**Features:**
- Performance monitoring
- Exception tracking
- User analytics
- Custom events and metrics
- Real-time alerts

**Setup:**
1. Create Application Insights resource
2. Get Instrumentation Key
3. Add to application:
   ```csharp
   // In Program.cs
   builder.Services.AddApplicationInsightsTelemetry();
   ```

**Viewing Data:**
- Azure Portal → Application Insights
- **Live Metrics**: Real-time data
- **Performance**: Slow requests
- **Failures**: Exceptions
- **Users**: User analytics

**Custom Telemetry:**
```csharp
var telemetryClient = new TelemetryClient();
telemetryClient.TrackEvent("UserLoggedIn", new Dictionary<string, string>
{
    { "UserId", userId.ToString() }
});
```

---

## 2. Networking

### Virtual Networks (VNet)

**Purpose**: Isolated network in Azure

**Components:**
- **Subnets**: Segments within VNet
- **Network Security Groups (NSG)**: Firewall rules
- **Route Tables**: Custom routing

**Use Cases:**
- Connect VMs securely
- Connect to on-premises (VPN)
- Isolate resources

**Creating VNet:**
1. Azure Portal → Create Resource → Virtual Network
2. Configure:
   - **Address Space**: e.g., `10.0.0.0/16`
   - **Subnet**: e.g., `10.0.1.0/24`
   - **Region**: Location

### Network Security Groups (NSG)

**Purpose**: Filter network traffic (firewall rules)

**Rule Components:**
- **Priority**: 100-4096 (lower = higher priority)
- **Name**: Descriptive name
- **Source**: IP, service tag, or "Any"
- **Destination**: IP, subnet, or "Any"
- **Port**: Single port or range
- **Protocol**: TCP, UDP, or Any
- **Action**: Allow or Deny

**Default Rules:**
- Allow VNet inbound/outbound
- Allow Azure Load Balancer inbound
- Deny all internet inbound
- Allow internet outbound

**Example Rule:**
```
Name: Allow-HTTP-Inbound
Priority: 1000
Source: Internet
Destination: Any
Port: 80
Protocol: TCP
Action: Allow
```

### Azure Load Balancer

**Purpose**: Distribute traffic across multiple VMs

**Types:**
- **Public Load Balancer**: Internet-facing
- **Internal Load Balancer**: Internal traffic only

**Load Balancing Methods:**
- **Round Robin**: Distribute evenly
- **Source IP Affinity**: Same client to same server

**Health Probes:**
- Check if backend is healthy
- Unhealthy instances removed from pool

### Application Gateway

**Purpose**: Layer 7 (HTTP/HTTPS) load balancer

**Features:**
- **WAF** (Web Application Firewall): Protect from attacks
- **SSL Termination**: Handle SSL at gateway
- **URL-based Routing**: Route based on URL path
- **Cookie-based Affinity**: Session stickiness

**Use Cases:**
- Multiple web apps behind one IP
- WAF protection
- SSL offloading

### Azure DNS

**Purpose**: Host DNS domains in Azure

**Features:**
- Fast DNS resolution
- High availability
- Private DNS zones (for VNets)

**Creating DNS Zone:**
1. Azure Portal → Create Resource → DNS Zone
2. Enter domain name (e.g., `example.com`)
3. Add records (A, CNAME, MX, etc.)

**Delegation:**
- Update nameservers at domain registrar
- Point domain to Azure DNS nameservers

---

## 3. Deployment & DevOps

### Azure DevOps Pipelines

**Purpose**: CI/CD (Continuous Integration/Continuous Deployment)

**Pipeline Structure:**
1. **Trigger**: Code push, schedule, manual
2. **Build**: Compile, test, package
3. **Release**: Deploy to environments

**YAML Pipeline Example:**
```yaml
trigger:
- main

pool:
  vmImage: 'windows-latest'

steps:
- task: DotNetCoreCLI@2
  inputs:
    command: 'build'
    projects: '**/*.csproj'

- task: DotNetCoreCLI@2
  inputs:
    command: 'publish'
    projects: '**/*.csproj'
    arguments: '--output $(Build.ArtifactStagingDirectory)'

- task: AzureWebApp@1
  inputs:
    azureSubscription: 'MySubscription'
    appName: 'myapp'
    package: '$(Build.ArtifactStagingDirectory)/**/*.zip'
```

### ARM Templates

**Purpose**: Infrastructure as Code (IaC)

**Definition**: JSON files defining Azure resources

**Benefits:**
- Version control
- Repeatable deployments
- Consistent environments

**Example:**
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Web/sites",
      "apiVersion": "2021-02-01",
      "name": "myapp",
      "location": "[resourceGroup().location]",
      "properties": {
        "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', 'myplan')]"
      }
    }
  ]
}
```

### Azure CLI

**Command-line tool for Azure management**

**Installation:**
```bash
# Windows
winget install -e --id Microsoft.AzureCLI

# Or download from Microsoft
```

**Common Commands:**
```bash
# Login
az login

# List resource groups
az group list

# Create resource group
az group create --name myRG --location eastus

# Create web app
az webapp create --resource-group myRG --name myapp --plan myplan

# Deploy code
az webapp deployment source config-zip --resource-group myRG --name myapp --src app.zip
```

### Deployment Slots

**Purpose**: Test deployment before going live

**Process:**
1. Deploy to staging slot
2. Test staging site
3. Swap staging with production (zero downtime)

**Swap Types:**
- **Swap**: Staging → Production
- **Auto-swap**: Automatic after deployment

**Configuration:**
- Slot-specific app settings
- Connection strings can be slot-specific

### Scaling

**Scale Up (Vertical):**
- Change App Service Plan tier
- More CPU, memory, features
- Requires restart

**Scale Out (Horizontal):**
- Add more instances
- Better for high traffic
- No downtime

**Auto-scale:**
- Automatically add/remove instances
- Based on metrics (CPU, memory, requests)
- Set min/max instances

**Configuration:**
```
App Service → Scale up (App Service plan)
App Service → Scale out (App Service plan)
```

---

## 4. Security

### Managed Identities

**Purpose**: Authenticate to Azure services without storing credentials

**Types:**
- **System-assigned**: Tied to specific resource
- **User-assigned**: Standalone, can be assigned to multiple resources

**Enable:**
```
App Service → Identity → System assigned → On
```

**Use:**
```csharp
// No connection string needed!
var credential = new DefaultAzureCredential();
var client = new SecretClient(new Uri(keyVaultUrl), credential);
```

### Azure AD Integration

**Purpose**: Single Sign-On (SSO) for applications

**Setup:**
1. Register app in Azure AD
2. Configure authentication in App Service
3. Users sign in with Microsoft account

**Benefits:**
- Centralized user management
- Multi-factor authentication
- Conditional access policies

### Key Vault for Secrets

**Best Practice**: Never store secrets in code or config files

**Store in Key Vault:**
- Connection strings
- API keys
- Certificates
- Passwords

**Access from App Service:**
- Use Managed Identity
- Reference in App Settings: `@Microsoft.KeyVault(SecretUri=...)`

### SSL/TLS Certificates

**Types:**
- **App Service Managed Certificate**: Free, auto-renewal
- **Upload Certificate**: Bring your own
- **Key Vault Certificate**: Store in Key Vault

**Binding:**
```
App Service → TLS/SSL settings → Private Key Certificates
Add certificate → Bind to custom domain
```

---

## Interview Questions to Prepare

1. **What is Azure App Service? What are its benefits?**
2. **Explain the difference between Scale Up and Scale Out.**
3. **What are deployment slots? How do you use them?**
4. **What is Azure Key Vault? Why use it?**
5. **Explain Network Security Groups (NSG).**
6. **What is the difference between Load Balancer and Application Gateway?**
7. **How do you set up CI/CD with Azure DevOps?**
8. **What are Managed Identities? Why use them?**
9. **How do you secure an Azure App Service?**
10. **What is Application Insights? What can you monitor?**

