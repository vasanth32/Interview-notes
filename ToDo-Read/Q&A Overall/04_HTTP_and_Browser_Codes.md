# HTTP & Browser Codes - Interview Guide

## 1. HTTP Status Codes

### Understanding Status Codes

HTTP status codes are 3-digit numbers returned by servers to indicate the result of a request. They're grouped into 5 categories:

---

### 1xx Informational (Rarely Used)

**100 Continue**: Server received request headers, client should send body  
**101 Switching Protocols**: Server agrees to switch protocols (e.g., HTTP to WebSocket)

**Interview Note**: Rarely seen in web development, mainly for protocol negotiations.

---

### 2xx Success

**200 OK**: Request succeeded. Most common success response.

```http
HTTP/1.1 200 OK
Content-Type: application/json
{"status": "success", "data": {...}}
```

**201 Created**: Resource successfully created. Used after POST requests.

```http
HTTP/1.1 201 Created
Location: /api/users/123
```

**204 No Content**: Success but no response body. Used for DELETE or updates that don't return data.

**206 Partial Content**: Used for range requests (downloading part of a file).

**Interview Tip**: Use 201 for POST, 204 for DELETE, 200 for GET.

---

### 3xx Redirection

**301 Moved Permanently**: Resource permanently moved to new URL. Search engines update their index.

```http
HTTP/1.1 301 Moved Permanently
Location: https://www.example.com/new-page
```

**302 Found (Temporary Redirect)**: Resource temporarily at different URL. Browser should use original URL for future requests.

**304 Not Modified**: Resource not modified since last request. Browser uses cached version. Used with ETags and Last-Modified headers.

**Interview Question**: "301 vs 302?"  
- **301**: Permanent, SEO updates, use for domain changes  
- **302**: Temporary, maintains original URL ranking

---

### 4xx Client Errors

**400 Bad Request**: Malformed request syntax. Client sent invalid data.

```http
HTTP/1.1 400 Bad Request
{"error": "Invalid JSON format"}
```

**401 Unauthorized**: Authentication required or failed. Client must authenticate.

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer
```

**403 Forbidden**: Server understood request but refuses to authorize. Different from 401 (not authenticated vs not authorized).

**404 Not Found**: Resource doesn't exist. Most common error.

**405 Method Not Allowed**: HTTP method not allowed for this resource (e.g., POST on read-only endpoint).

**408 Request Timeout**: Server didn't receive complete request in time.

**409 Conflict**: Request conflicts with current state (e.g., duplicate email).

**422 Unprocessable Entity**: Valid syntax but semantic errors (validation failures).

**429 Too Many Requests**: Rate limit exceeded.

**Interview Tip**: 401 = "Who are you?", 403 = "I know who you are, but you can't do this"

---

### 5xx Server Errors

**500 Internal Server Error**: Generic server error. Something went wrong on server side.

```http
HTTP/1.1 500 Internal Server Error
{"error": "An unexpected error occurred"}
```

**502 Bad Gateway**: Server acting as gateway received invalid response from upstream server.

**503 Service Unavailable**: Server temporarily unavailable (overloaded, maintenance).

```http
HTTP/1.1 503 Service Unavailable
Retry-After: 3600
```

**504 Gateway Timeout**: Gateway didn't receive timely response from upstream server.

**Interview Note**: 5xx errors indicate server problems, not client problems.

---

## 2. Browser-Specific Error Codes

### Common Browser Error Codes

**501301 (Internet Explorer/Edge)**:  
- **Meaning**: Certificate error or SSL/TLS issue
- **Common Causes**: 
  - Expired certificate
  - Certificate not trusted
  - Mismatched domain name
  - Self-signed certificate

**ERR_CERT_AUTHORITY_INVALID (Chrome)**:  
- Certificate authority not trusted

**ERR_CONNECTION_REFUSED**:  
- Server refused connection (not running, firewall blocking)

**ERR_NAME_NOT_RESOLVED**:  
- DNS resolution failed (domain doesn't exist)

**ERR_SSL_PROTOCOL_ERROR**:  
- SSL/TLS handshake failed

**ERR_TOO_MANY_REDIRECTS**:  
- Redirect loop detected

### Network Errors

**CORS Errors**:  
- `Access-Control-Allow-Origin` header missing
- Preflight request failed
- Credentials not allowed

**Mixed Content**:  
- HTTPS page loading HTTP resources (blocked by browser)

---

## 3. Browser DevTools for Troubleshooting

### Network Tab

**Purpose**: Inspect all HTTP requests/responses

**Key Information:**
- **Status**: HTTP status code
- **Type**: Document, XHR, JS, CSS, etc.
- **Size**: Response size
- **Time**: Request duration
- **Waterfall**: Visual timeline

**How to Use:**
1. Open DevTools (F12)
2. Click "Network" tab
3. Reload page (Ctrl+R)
4. Click any request to see:
   - **Headers**: Request/Response headers
   - **Preview**: Formatted response
   - **Response**: Raw response body
   - **Timing**: Breakdown of request phases

**Common Checks:**
- Status codes (look for 4xx, 5xx)
- Response time (slow requests)
- Failed requests (red entries)
- Request payload (for POST)

### Console Tab

**Purpose**: JavaScript errors and logs

**Error Types:**
- **Syntax Errors**: Code mistakes
- **Runtime Errors**: Errors during execution
- **Network Errors**: Failed requests
- **CORS Errors**: Cross-origin issues

**How to Use:**
- Errors appear in red
- Click error to see stack trace
- Use `console.log()` for debugging

### Application Tab

**Purpose**: Inspect storage and application data

**Sections:**
- **Local Storage**: Key-value storage
- **Session Storage**: Temporary storage
- **Cookies**: HTTP cookies
- **Service Workers**: PWA workers
- **Cache Storage**: Cached resources

---

## 4. F12 Developer Mode

### Opening DevTools

**Methods:**
- Press `F12`
- Right-click → "Inspect" or "Inspect Element"
- `Ctrl+Shift+I` (Chrome/Edge)
- `Ctrl+Shift+K` (Firefox)

### Key Features

**Elements Tab**:  
- Inspect HTML structure
- Modify CSS in real-time
- See computed styles

**Console Tab**:  
- Run JavaScript commands
- View logs and errors
- Test API calls

**Network Tab**:  
- Monitor all requests
- Filter by type (XHR, JS, CSS)
- Throttle network speed (test slow connections)

**Sources Tab**:  
- View source files
- Set breakpoints
- Debug JavaScript

**Performance Tab**:  
- Record page load
- Identify bottlenecks
- Analyze rendering

---

## 5. Network Request Analysis

### Request Headers (Important)

**User-Agent**: Browser and OS information  
**Accept**: Content types client accepts  
**Accept-Language**: Preferred languages  
**Authorization**: Credentials (Bearer token, Basic auth)  
**Content-Type**: Request body format (application/json, application/xml)  
**Cookie**: Stored cookies  
**Referer**: Previous page URL

### Response Headers (Important)

**Content-Type**: Response format  
**Set-Cookie**: Server setting cookies  
**Location**: Redirect URL (for 3xx)  
**Cache-Control**: Caching instructions  
**Access-Control-Allow-Origin**: CORS header  
**X-Frame-Options**: Clickjacking protection  
**Strict-Transport-Security**: Force HTTPS

### Analyzing Failed Requests

**Steps:**
1. Open Network tab
2. Find failed request (red, status 4xx/5xx)
3. Check **Headers** tab:
   - Request URL correct?
   - Request method correct (GET/POST)?
   - Headers present (Authorization, Content-Type)?
4. Check **Payload** tab (for POST):
   - Data format correct?
   - Required fields present?
5. Check **Response** tab:
   - Error message from server
   - Stack trace (if development mode)

---

## 6. Common Troubleshooting Scenarios

### Scenario 1: 404 Not Found

**Check:**
- URL spelling
- Route configuration
- File exists on server
- Case sensitivity

### Scenario 2: 500 Internal Server Error

**Check:**
- Server logs (IIS logs, application logs)
- Database connection
- Configuration errors
- Exception details (if in dev mode)

### Scenario 3: CORS Error

**Check:**
- `Access-Control-Allow-Origin` header
- Preflight request (OPTIONS) handling
- Credentials configuration

### Scenario 4: SSL Certificate Error

**Check:**
- Certificate expiration date
- Domain name matches certificate
- Certificate chain valid
- Browser trust store

---

## Interview Questions to Prepare

1. **What's the difference between 401 and 403?**
2. **When would you return 201 vs 200?**
3. **Explain 301 vs 302 redirects.**
4. **What does status code 304 mean?**
5. **How do you debug a failed API request using browser DevTools?**
6. **What causes a CORS error? How do you fix it?**
7. **What information can you get from the Network tab?**
8. **How do you identify slow requests?**
9. **What is a preflight request?**
10. **How do you test your application on slow network connections?**

