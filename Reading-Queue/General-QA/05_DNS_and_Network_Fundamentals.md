# DNS & Network Fundamentals - Interview Guide

## What is DNS?

**DNS (Domain Name System)** translates human-readable domain names (like `example.com`) into IP addresses (like `192.0.2.1`) that computers use to communicate.

**Why DNS?**  
- Humans remember names better than numbers
- IP addresses can change, domain names stay the same
- Load balancing: One domain can map to multiple IPs

---

## 1. DNS Record Types

### A Record (Address Record)

**Purpose**: Maps domain name to IPv4 address

**Example:**
```
example.com    A    192.0.2.1
www.example.com A   192.0.2.1
```

**Use Case**: Pointing `example.com` to a web server's IP address

**TTL**: Time To Live (how long DNS servers cache this record)

---

### AAAA Record (IPv6 Address Record)

**Purpose**: Maps domain name to IPv6 address

**Example:**
```
example.com    AAAA    2001:0db8:85a3::1
```

**Use Case**: IPv6 support (newer standard, longer addresses)

**Note**: IPv6 addresses are 128-bit (vs IPv4's 32-bit)

---

### CNAME Record (Canonical Name)

**Purpose**: Creates an alias pointing to another domain name

**Example:**
```
www.example.com    CNAME    example.com
blog.example.com   CNAME    example.com
```

**Use Case**: 
- Multiple subdomains pointing to same server
- CDN integration (point to CDN domain)

**Important**: 
- Cannot have other records (A, MX) on same name as CNAME
- CNAME points to another name, not IP address

---

### MX Record (Mail Exchange)

**Purpose**: Specifies mail server for domain

**Example:**
```
example.com    MX    10    mail.example.com
example.com    MX    20    mail2.example.com
```

**Priority Numbers**:
- Lower number = higher priority
- If `mail.example.com` fails, try `mail2.example.com`

**Use Case**: Email delivery (tells senders where to send email)

---

### TXT Record (Text Record)

**Purpose**: Store text information

**Common Uses**:
- **SPF (Sender Policy Framework)**: Email authentication
  ```
  example.com    TXT    "v=spf1 include:_spf.google.com ~all"
  ```
- **DKIM**: Email signing
- **Domain verification**: Proving domain ownership
- **DMARC**: Email policy

**Example:**
```
example.com    TXT    "v=spf1 mx ~all"
```

---

### NS Record (Name Server)

**Purpose**: Specifies authoritative DNS servers for domain

**Example:**
```
example.com    NS    ns1.example.com
example.com    NS    ns2.example.com
```

**Use Case**: 
- Delegating DNS management
- Pointing to DNS provider (Cloudflare, AWS Route 53)

**Note**: NS records tell the internet which servers have DNS authority for your domain

---

### PTR Record (Pointer - Reverse DNS)

**Purpose**: Maps IP address to domain name (reverse of A record)

**Example:**
```
1.2.0.192.in-addr.arpa    PTR    example.com
```

**Use Case**: 
- Email server verification
- Security checks
- Troubleshooting

**Note**: Less common, mainly for email and security

---

## 2. DNS Resolution Process

### How DNS Lookup Works

**Step-by-Step:**

1. **User types URL**: `www.example.com`

2. **Browser checks cache**: 
   - Browser cache (recent lookups)
   - OS cache (hosts file, DNS cache)

3. **Query Recursive DNS Server** (usually ISP's DNS):
   - Your computer asks: "What's the IP for www.example.com?"
   - Recursive server doesn't know, asks root servers

4. **Root Servers** (13 worldwide):
   - "I don't know, but ask .com nameservers"

5. **.com Nameservers**:
   - "I don't know, but ask example.com nameservers"

6. **Authoritative Nameservers** (for example.com):
   - "www.example.com is 192.0.2.1"

7. **Response flows back**:
   - Recursive server caches result
   - Returns IP to your computer
   - Browser connects to IP

**Visual Flow:**
```
Your Computer → ISP DNS → Root Server → .com Server → example.com NS → IP Address
```

### DNS Caching

**Purpose**: Speed up lookups, reduce DNS server load

**Cache Locations:**
- Browser cache (minutes to hours)
- OS cache (hours)
- ISP DNS cache (hours to days, based on TTL)

**TTL (Time To Live)**:
- How long record can be cached
- Example: TTL=3600 means cache for 1 hour
- Lower TTL = faster changes propagate
- Higher TTL = less DNS queries, faster lookups

---

## 3. DNS Zones

### What is a DNS Zone?

**Definition**: Portion of DNS namespace managed by specific organization

**Example:**
- Zone: `example.com`
- Contains: All records for example.com and subdomains

### Zone Files

**Contains:**
- All DNS records for the zone
- SOA (Start of Authority) record
- NS records
- A, AAAA, CNAME, MX, TXT records

**Example Zone File:**
```
$TTL 3600
example.com.    IN    SOA    ns1.example.com. admin.example.com. (
                                2024010101    ; Serial
                                3600          ; Refresh
                                1800          ; Retry
                                604800        ; Expire
                                86400         ; Minimum TTL
                            )
example.com.    IN    NS     ns1.example.com.
example.com.    IN    NS     ns2.example.com.
example.com.    IN    A      192.0.2.1
www             IN    A      192.0.2.1
mail            IN    A      192.0.2.10
example.com.    IN    MX     10 mail.example.com.
```

---

## 4. Subdomains

### What are Subdomains?

**Definition**: Part of domain before main domain

**Examples:**
- `www.example.com` - `www` is subdomain
- `blog.example.com` - `blog` is subdomain
- `api.example.com` - `api` is subdomain

### Creating Subdomains

**Method 1: A Record**
```
blog.example.com    A    192.0.2.2
```

**Method 2: CNAME**
```
blog.example.com    CNAME    example.com
```

**Use Cases:**
- Separate services (blog, api, admin)
- Different servers
- CDN integration

---

## 5. DNS Propagation

### What is Propagation?

**Definition**: Time it takes for DNS changes to spread across internet

**Why it takes time:**
- DNS servers cache records (respect TTL)
- Different ISPs update at different times
- Can take 24-48 hours (usually faster, minutes to hours)

### Factors Affecting Propagation

- **TTL Value**: Lower TTL = faster propagation
- **DNS Provider**: Some update faster
- **Geographic Location**: Different regions see changes at different times

### Checking Propagation

**Tools:**
- `whatsmydns.net` - Check DNS globally
- `dnschecker.org` - Worldwide DNS lookup
- `nslookup` command

---

## 6. Network Troubleshooting Commands

### nslookup

**Purpose**: Query DNS servers

**Basic Usage:**
```bash
nslookup example.com
```

**Query Specific DNS Server:**
```bash
nslookup example.com 8.8.8.8
```

**Output:**
```
Server:  dns-server
Address:  192.168.1.1

Name:    example.com
Address:  192.0.2.1
```

### dig (Linux/Mac)

**Purpose**: More detailed DNS queries

**Usage:**
```bash
dig example.com
dig example.com MX    # Query MX records
dig @8.8.8.8 example.com    # Use specific DNS server
```

### ping

**Purpose**: Test connectivity to host

**Usage:**
```bash
ping example.com
ping 192.0.2.1
```

**What it shows:**
- Response time
- Packet loss
- If host is reachable

### tracert (Windows) / traceroute (Linux)

**Purpose**: Show route packets take to destination

**Usage:**
```bash
tracert example.com
```

**Shows:**
- Each hop (router) along the way
- Response time for each hop
- Where delays occur

---

## 7. DNS Cache Clearing

### Why Clear Cache?

- DNS changes not reflecting
- Troubleshooting DNS issues
- Testing new DNS records

### Windows

**Clear DNS Cache:**
```powershell
ipconfig /flushdns
```

**View DNS Cache:**
```powershell
ipconfig /displaydns
```

### Linux

```bash
sudo systemd-resolve --flush-caches
# or
sudo service network-manager restart
```

### Browser Cache

- Chrome: Settings → Privacy → Clear browsing data → Cached images
- Firefox: Settings → Privacy → Clear Data → Cached Web Content

---

## 8. Hosts File Configuration

### What is hosts file?

**Definition**: Local file that overrides DNS lookups

**Location:**
- Windows: `C:\Windows\System32\drivers\etc\hosts`
- Linux/Mac: `/etc/hosts`

### Format

```
127.0.0.1    localhost
192.0.2.1    example.com
192.0.2.1    www.example.com
```

**Use Cases:**
- Testing: Point domain to local server
- Blocking: Point malicious domains to 127.0.0.1
- Development: Local domain testing

**Important**: 
- Requires administrator privileges to edit
- Takes precedence over DNS
- Useful for development/testing

---

## Interview Questions to Prepare

1. **What is DNS? Why do we need it?**
2. **Explain the difference between A record and CNAME.**
3. **What is an MX record used for?**
4. **Explain the DNS resolution process step by step.**
5. **What is TTL? How does it affect DNS?**
6. **What is DNS propagation? Why does it take time?**
7. **How do you troubleshoot DNS issues?**
8. **What is the difference between recursive and authoritative DNS servers?**
9. **When would you use a CNAME vs an A record?**
10. **How do you check if DNS changes have propagated?**

