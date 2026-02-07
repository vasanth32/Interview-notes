# IIS Configuration & Web Server Management - Interview Guide

## What is IIS?

**Internet Information Services (IIS)** is Microsoft's web server software that runs on Windows Server. It hosts websites, web applications, and web services.

---

## 1. Website Setup

### Creating a Website in IIS Manager

**Steps:**
1. Open IIS Manager (inetmgr)
2. Right-click "Sites" → "Add Website"
3. Configure:
   - **Site name**: Unique identifier
   - **Application pool**: Select or create new
   - **Physical path**: Folder containing your application files
   - **Binding**: 
     - Type: HTTP or HTTPS
     - IP address: All Unassigned or specific IP
     - Port: 80 (HTTP) or 443 (HTTPS)
     - Host name: Domain name (optional)

### Application Pools

**Purpose**: Isolate web applications for security and stability

**Key Settings:**
- **.NET CLR Version**: v4.0 or No Managed Code
- **Managed Pipeline Mode**: 
  - **Integrated**: Modern, recommended
  - **Classic**: Legacy mode
- **Identity**: 
  - ApplicationPoolIdentity (default, secure)
  - NetworkService
  - Custom account
- **Recycling**: 
  - Regular time intervals
  - Memory limits
  - Request limits

**Why Multiple App Pools?**
- Isolation: One app crash doesn't affect others
- Different .NET versions
- Different security requirements

### Binding Configurations

**HTTP Binding:**
- Port 80 (default)
- No encryption
- Use for internal sites or redirect to HTTPS

**HTTPS Binding:**
- Port 443 (default)
- Requires SSL certificate
- Encrypted communication

**Multiple Bindings:**
- One website can have multiple bindings
- Example: Same site on HTTP (80) and HTTPS (443)
- Different host names: `example.com` and `www.example.com`

### Virtual Directories

**Purpose**: Map a URL path to a physical folder outside the website root

**Example:**
- Website root: `C:\inetpub\wwwroot\MySite`
- Virtual directory `/Images` → `D:\SharedImages`
- Access: `http://mysite.com/Images/photo.jpg`

**Application vs Virtual Directory:**
- **Application**: Has its own application pool, isolated execution
- **Virtual Directory**: Shares parent app pool, just a folder mapping

---

## 2. URL Rewrite & Redirects

### URL Rewrite Module

**Installation**: Download from Microsoft (separate module)

**Purpose**: 
- Clean URLs (remove .aspx, .html)
- Redirect old URLs to new ones
- Force HTTPS
- Handle trailing slashes

### Redirect Rules (301 Permanent, 302 Temporary)

**301 Redirect (Permanent):**
```xml
<rule name="Redirect to HTTPS" stopProcessing="true">
    <match url="(.*)" />
    <conditions>
        <add input="{HTTPS}" pattern="off" />
    </conditions>
    <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" 
            redirectType="Permanent" />
</rule>
```

**302 Redirect (Temporary):**
- Change `redirectType="Permanent"` to `redirectType="Found"`

**When to Use:**
- **301**: Permanent move (SEO friendly, search engines update)
- **302**: Temporary redirect (maintains original URL ranking)

### Rewrite Rules (Internal, No Redirect)

```xml
<rule name="Remove .aspx extension">
    <match url="^(.*)\.aspx$" />
    <action type="Rewrite" url="{R:1}" />
</rule>
```

**Difference:**
- **Redirect**: Browser sees new URL (301/302 response)
- **Rewrite**: Server internally changes URL, browser doesn't see change

### Pattern Matching

**Regular Expressions:**
- `(.*)` - Match any characters
- `{R:1}` - Reference to first capture group
- `^` - Start of string
- `$` - End of string

**Example:**
```
Pattern: ^products/([0-9]+)$
Matches: /products/123
Capture: R:1 = "123"
```

### Configuration Location

**IIS Manager:**
- Visual interface
- Easy for beginners
- Changes saved to web.config

**web.config:**
- Direct XML editing
- Version control friendly
- More flexible

```xml
<system.webServer>
    <rewrite>
        <rules>
            <!-- Rules here -->
        </rules>
    </rewrite>
</system.webServer>
```

---

## 3. Security & Access Control

### IP Whitelisting/Blacklisting

**Purpose**: Restrict access based on client IP address

**Configuration in IIS:**
1. Select website
2. Double-click "IP Address and Domain Restrictions"
3. Add Allow/Deny rule
4. Enter IP address or range

**web.config:**
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

**Use Cases:**
- Admin panels: Only allow office IPs
- API endpoints: Whitelist partner IPs
- Block malicious IPs

### Request Filtering

**Purpose**: Block dangerous requests

**Settings:**
- File extensions: Block .exe, .bat uploads
- Request limits: Max URL length, query string length
- Hidden segments: Block access to specific folders
- Verbs: Allow only GET, POST

**Configuration:**
```xml
<system.webServer>
    <security>
        <requestFiltering>
            <fileExtensions>
                <remove fileExtension=".exe" />
                <add fileExtension=".exe" allowed="false" />
            </fileExtensions>
            <requestLimits maxAllowedContentLength="10485760" />
        </requestFiltering>
    </security>
</system.webServer>
```

### Authentication Methods

**Anonymous Authentication:**
- No login required
- Default for public websites
- Uses IUSR account

**Windows Authentication:**
- Uses Windows user accounts
- Integrated Windows Authentication (Kerberos/NTLM)
- Good for intranet applications

**Forms Authentication:**
- Custom login page
- Uses cookies/sessions
- Configured in application code

**Basic Authentication:**
- Username/password in HTTP header
- Not secure without HTTPS
- Rarely used

### SSL/TLS Certificates

**Purpose**: Encrypt HTTP traffic (HTTPS)

**Types:**
- **Self-signed**: For testing, browsers show warning
- **CA-signed**: From certificate authority (Let's Encrypt, DigiCert)
- **Wildcard**: Covers *.example.com

**Binding Certificate:**
1. Import certificate to server
2. In website binding, select HTTPS
3. Choose certificate from dropdown
4. Port 443

**Renewal**: Certificates expire (typically 1-3 years), must renew

---

## 4. Rules Engine

### Custom Rules Configuration

**Conditions:**
- Check server variables: `{HTTP_HOST}`, `{REQUEST_URI}`, `{QUERY_STRING}`
- Pattern matching
- Logical operators: AND, OR

**Actions:**
- Redirect
- Rewrite
- Abort request
- Custom response

**Example - Force WWW:**
```xml
<rule name="Force WWW">
    <match url="(.*)" />
    <conditions>
        <add input="{HTTP_HOST}" pattern="^example\.com$" />
    </conditions>
    <action type="Redirect" url="https://www.example.com/{R:1}" />
</rule>
```

### Server Variables

**Common Variables:**
- `{HTTP_HOST}` - Domain name
- `{REQUEST_URI}` - Full path
- `{QUERY_STRING}` - Query parameters
- `{HTTPS}` - on/off
- `{REMOTE_ADDR}` - Client IP
- `{REQUEST_METHOD}` - GET, POST, etc.

### Rule Precedence

- Rules execute **top to bottom**
- `stopProcessing="true"` stops further rules
- Order matters! More specific rules should come first

---

## Common Interview Questions

1. **What is an application pool? Why use multiple pools?**
   - Isolation, different .NET versions, security

2. **Difference between 301 and 302 redirects?**
   - 301 permanent (SEO), 302 temporary

3. **How do you configure IP whitelisting in IIS?**
   - IP Address and Domain Restrictions feature

4. **What is the difference between redirect and rewrite?**
   - Redirect changes URL in browser, rewrite is internal

5. **How do you force HTTPS for all requests?**
   - URL Rewrite rule checking {HTTPS} variable

6. **What is managed pipeline mode?**
   - Integrated (modern) vs Classic (legacy)

7. **How do you handle SSL certificate expiration?**
   - Monitor expiration date, renew before expiry, update binding

8. **What is the difference between application and virtual directory?**
   - Application has own app pool, virtual directory shares parent

