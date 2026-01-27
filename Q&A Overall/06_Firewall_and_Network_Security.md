# Firewall & Network Security - Interview Guide

## What is a Firewall?

**Definition**: Network security system that monitors and controls incoming/outgoing traffic based on security rules.

**Purpose**: 
- Block unauthorized access
- Allow legitimate traffic
- Protect network from attacks

**Types:**
- **Hardware Firewall**: Physical device (router, dedicated appliance)
- **Software Firewall**: Application on computer (Windows Firewall)
- **Cloud Firewall**: Managed service (Azure NSG, AWS Security Groups)

---

## 1. Firewall Configuration Methods

### Windows Firewall (GUI)

**Access**: Control Panel → Windows Defender Firewall

**Basic Configuration:**
1. Click "Advanced settings"
2. Select "Inbound Rules" or "Outbound Rules"
3. Click "New Rule"
4. Choose rule type:
   - **Program**: Allow/block specific application
   - **Port**: Allow/block specific port
   - **Predefined**: Use built-in rule
   - **Custom**: Advanced configuration

**Rule Settings:**
- **Action**: Allow or Block
- **Profile**: Domain, Private, Public
- **Name**: Descriptive name

**Example - Allow Port 80:**
1. New Rule → Port → TCP → Specific local ports: 80
2. Action: Allow the connection
3. Profile: All
4. Name: "Allow HTTP"

### Windows Firewall (PowerShell)

**View Rules:**
```powershell
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*HTTP*"}
```

**Create Inbound Rule:**
```powershell
New-NetFirewallRule -DisplayName "Allow HTTP" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 80 `
    -Action Allow
```

**Block IP Address:**
```powershell
New-NetFirewallRule -DisplayName "Block Malicious IP" `
    -Direction Inbound `
    -RemoteAddress 192.168.1.100 `
    -Action Block
```

**Enable/Disable Rule:**
```powershell
Enable-NetFirewallRule -DisplayName "Allow HTTP"
Disable-NetFirewallRule -DisplayName "Allow HTTP"
```

### Network-Level Firewalls

**Hardware Firewalls:**
- Routers with firewall features
- Enterprise firewalls (Cisco ASA, Palo Alto)
- Managed by network administrators

**Configuration:**
- Web interface or CLI
- Rule-based access control
- VPN support
- Intrusion detection/prevention

**Common Rules:**
- Port forwarding
- Port blocking
- IP whitelisting/blacklisting
- DDoS protection

### Application-Level Filtering

**Definition**: Firewall rules at application level (not just port/IP)

**Examples:**
- **Web Application Firewall (WAF)**: 
  - Inspects HTTP/HTTPS traffic
  - Blocks SQL injection, XSS attacks
  - Azure Application Gateway WAF
  - AWS WAF

- **IIS Request Filtering**:
  - Block file extensions
  - Limit request size
  - Block specific URLs

---

## 2. Whitelisting Implementation

### IIS IP Restrictions

**Purpose**: Allow/deny access based on client IP address

**Configuration in IIS Manager:**
1. Select website
2. Double-click "IP Address and Domain Restrictions"
3. Click "Add Allow Entry" or "Add Deny Entry"
4. Enter:
   - **Specific IPv4 Address**: Single IP
   - **IPv4 Address Range**: IP range with subnet mask
   - **IPv6 Address**: IPv6 address
   - **Domain Name**: Domain name (not recommended, slow)

**Example:**
- Allow: `192.168.1.100` (single IP)
- Allow: `192.168.1.0/255.255.255.0` (entire subnet)
- Deny: `10.0.0.0/8` (entire 10.x.x.x range)

**web.config:**
```xml
<system.webServer>
    <security>
        <ipSecurity>
            <add ipAddress="192.168.1.100" allowed="true" />
            <add ipAddress="10.0.0.0" subnetMask="255.0.0.0" allowed="false" />
            <add ipAddress="192.168.1.0" subnetMask="255.255.255.0" allowed="true" />
        </ipSecurity>
    </security>
</system.webServer>
```

**Use Cases:**
- Admin panel: Only office IPs
- API endpoint: Partner IPs only
- Internal application: Company network only

### Application-Level IP Filtering (Code)

**ASP.NET Core Middleware:**
```csharp
public class IPWhitelistMiddleware
{
    private readonly RequestDelegate _next;
    private readonly string[] _allowedIPs = { "192.168.1.100", "10.0.0.1" };
    
    public IPWhitelistMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        var remoteIP = context.Connection.RemoteIpAddress.ToString();
        
        if (!_allowedIPs.Contains(remoteIP))
        {
            context.Response.StatusCode = 403;
            await context.Response.WriteAsync("Forbidden");
            return;
        }
        
        await _next(context);
    }
}
```

**Action Filter:**
```csharp
public class IPWhitelistAttribute : ActionFilterAttribute
{
    private readonly string[] _allowedIPs = { "192.168.1.100" };
    
    public override void OnActionExecuting(ActionExecutingContext context)
    {
        var ip = context.HttpContext.Connection.RemoteIpAddress.ToString();
        
        if (!_allowedIPs.Contains(ip))
        {
            context.Result = new ForbidResult();
            return;
        }
        
        base.OnActionExecuting(context);
    }
}

// Usage
[IPWhitelist]
public IActionResult AdminPanel() { }
```

**Configuration-Based:**
```csharp
// appsettings.json
{
  "AllowedIPs": ["192.168.1.100", "10.0.0.1"]
}

// Service
public class IPWhitelistService
{
    private readonly IConfiguration _config;
    private readonly List<string> _allowedIPs;
    
    public IPWhitelistService(IConfiguration config)
    {
        _config = config;
        _allowedIPs = _config.GetSection("AllowedIPs").Get<List<string>>();
    }
    
    public bool IsAllowed(string ip) => _allowedIPs.Contains(ip);
}
```

### Network Firewall Rules

**Windows Firewall - Allow Specific IP:**
```powershell
New-NetFirewallRule -DisplayName "Allow Partner IP" `
    -Direction Inbound `
    -RemoteAddress 203.0.113.50 `
    -Action Allow
```

**Block IP Range:**
```powershell
New-NetFirewallRule -DisplayName "Block Malicious Range" `
    -Direction Inbound `
    -RemoteAddress 192.168.100.0/24 `
    -Action Block
```

### Load Balancer IP Whitelisting

**Azure Load Balancer:**
- Configure in Network Security Group (NSG)
- Attach NSG to load balancer subnet
- Define rules for source IP ranges

**AWS Application Load Balancer:**
- Use Security Groups
- Configure source IP restrictions
- WAF integration for advanced rules

### Azure NSG (Network Security Groups)

**Purpose**: Filter network traffic to Azure resources

**Configuration:**
1. Create NSG in Azure Portal
2. Add Inbound/Outbound rules
3. Associate with subnet or network interface

**Rule Components:**
- **Priority**: Lower number = higher priority (100-4096)
- **Name**: Descriptive name
- **Source**: IP address, service tag, or "Any"
- **Destination**: IP, subnet, or "Any"
- **Service**: Port or port range
- **Protocol**: TCP, UDP, or Any
- **Action**: Allow or Deny

**Example Rule:**
```
Name: Allow-HTTP-Inbound
Priority: 1000
Source: Internet
Destination: Any
Service: 80
Protocol: TCP
Action: Allow
```

**PowerShell:**
```powershell
$nsg = Get-AzNetworkSecurityGroup -Name "MyNSG"
$rule = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-HTTP" `
    -Priority 1000 `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 80

$nsg.SecurityRules.Add($rule)
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg
```

---

## 3. Security Best Practices

### Principle of Least Privilege

**Definition**: Grant minimum permissions necessary

**Application:**
- Firewall: Only open required ports
- IP Whitelisting: Only allow necessary IPs
- User accounts: Minimum required access

**Example:**
- Web server: Open ports 80, 443 only
- Database server: Only allow app server IPs
- Admin panel: Only office IPs

### Defense in Depth

**Definition**: Multiple layers of security

**Layers:**
1. **Network Firewall**: Block at network level
2. **Host Firewall**: Block at server level
3. **Application Firewall**: Block at application level (WAF)
4. **IP Restrictions**: Block at IIS/application level
5. **Authentication**: Verify user identity
6. **Authorization**: Verify user permissions

**Why Multiple Layers?**
- If one layer fails, others provide protection
- Different attack vectors require different defenses

### Logging and Monitoring

**Why Log?**
- Detect attacks
- Troubleshoot issues
- Audit compliance
- Forensic analysis

**What to Log:**
- Blocked connection attempts
- Allowed connections
- Source IP addresses
- Timestamps
- Ports/protocols

**Windows Firewall Logging:**
1. Advanced Settings → Windows Firewall Properties
2. Select profile (Domain, Private, Public)
3. Enable logging
4. Configure log file path

**IIS Logging:**
- Enabled by default
- Location: `C:\inetpub\logs\LogFiles\`
- Contains: IP addresses, requests, status codes

**Application Logging:**
```csharp
_logger.LogWarning($"Blocked connection attempt from {ipAddress}");
```

**Monitoring Tools:**
- Event Viewer (Windows)
- Azure Monitor
- SIEM systems (Security Information and Event Management)

---

## Common Interview Questions

1. **What is a firewall? What are the different types?**
2. **How do you configure IP whitelisting in IIS?**
3. **Explain the difference between network-level and application-level firewalls.**
4. **How would you implement IP filtering in code?**
5. **What is the principle of least privilege?**
6. **Explain defense in depth.**
7. **How do you allow a specific port through Windows Firewall?**
8. **What is an NSG? How do you configure it?**
9. **How do you troubleshoot firewall issues?**
10. **What information should you log for security monitoring?**

