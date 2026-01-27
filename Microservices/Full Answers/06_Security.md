# Microservices Interview Answers - Security (Questions 101-120)

## 101. What are the security challenges in microservices architecture?

**Security Challenges:**

1. **Increased Attack Surface**
   - More services = more endpoints
   - More entry points
   - Larger attack surface

2. **Inter-Service Communication**
   - Service-to-service auth
   - Network security
   - Message encryption
   - Trust between services

3. **Distributed Authentication**
   - Token validation across services
   - Token propagation
   - Centralized vs distributed auth

4. **API Security**
   - Multiple APIs to secure
   - Rate limiting
   - Input validation
   - API abuse prevention

5. **Secrets Management**
   - Database credentials
   - API keys
   - Certificates
   - Distributed secrets

6. **Network Security**
   - Service mesh security
   - mTLS
   - Network policies
   - Segmentation

7. **Compliance**
   - Audit logging
   - Data privacy
   - Regulatory requirements
   - Cross-service compliance

8. **Configuration Security**
   - Secure configuration
   - Environment variables
   - Configuration management

**Best Practices:**
- Defense in depth
- Zero trust model
- Service mesh for security
- Centralized secrets management
- Regular security audits

---

## 102. How do you implement authentication in microservices?

**Authentication Strategies:**

1. **API Gateway Authentication**
   - Authenticate at gateway
   - Validate tokens
   - Propagate to services
   - Single point of auth

2. **Service-Level Authentication**
   - Each service validates
   - Self-contained
   - More complex
   - Better isolation

3. **JWT Tokens**
   - Stateless tokens
   - Self-contained claims
   - No session store
   - Microservices-friendly

4. **OAuth 2.0**
   - Authorization framework
   - Token-based
   - Industry standard
   - Multiple grant types

5. **mTLS**
   - Mutual TLS
   - Certificate-based
   - Service-to-service
   - Strong security

**Implementation:**

**API Gateway Approach:**
```
Client → API Gateway (Auth) → Services (Trust Gateway)
```

**JWT Validation:**
```java
@Service
public class AuthService {
    public boolean validateToken(String token) {
        try {
            Claims claims = Jwts.parser()
                .setSigningKey(secretKey)
                .parseClaimsJws(token)
                .getBody();
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
```

**Best Practices:**
- Authenticate at gateway
- Use JWT for stateless
- Validate tokens
- Secure token storage
- Token expiration
- Refresh tokens

---

## 103. What is the difference between authentication and authorization?

**Authentication:**
- **What**: Verifying identity
- **Question**: Who are you?
- **Example**: Login, token validation
- **Result**: Identity confirmed

**Authorization:**
- **What**: Verifying permissions
- **Question**: What can you do?
- **Example**: Role check, permission check
- **Result**: Access granted/denied

**Relationship:**
- Authentication comes first
- Then authorization
- Need identity for permissions
- Sequential process

**Example:**
```
1. Authentication: User logs in → Token issued
2. Authorization: User requests /admin → Check if admin role → Grant/Deny
```

**In Microservices:**
- Authenticate at gateway
- Authorize at service level
- Role-based access control
- Permission checks

**Best Practices:**
- Separate concerns
- Authenticate early
- Authorize at resource level
- Principle of least privilege
- Audit both

---

## 104. What is OAuth 2.0 and how is it used in microservices?

**OAuth 2.0** is an authorization framework that enables applications to obtain limited access to user accounts.

**Key Concepts:**

1. **Resource Owner**: User
2. **Client**: Application requesting access
3. **Authorization Server**: Issues tokens
4. **Resource Server**: API being accessed

**Grant Types:**

1. **Authorization Code**: Web apps
2. **Client Credentials**: Service-to-service
3. **Implicit**: Legacy (deprecated)
4. **Password**: Not recommended
5. **Refresh Token**: Token renewal

**In Microservices:**

**Service-to-Service:**
```
Service A → Authorization Server → Access Token
Service A → Service B (with token) → Service B validates
```

**User-to-Service:**
```
User → Authorization Server → Access Token
User → API Gateway (with token) → Gateway validates → Services
```

**Benefits:**
- Industry standard
- Token-based
- Stateless
- Scalable
- Secure

**Implementation:**
- Use authorization server
- Issue access tokens
- Validate tokens
- Refresh tokens
- Token expiration

---

## 105. What is JWT (JSON Web Token) and how does it work?

**JWT** is a compact, URL-safe token format for securely transmitting information between parties.

**Structure:**
```
Header.Payload.Signature
```

**Parts:**

1. **Header**
   - Algorithm (e.g., HS256, RS256)
   - Token type (JWT)

2. **Payload**
   - Claims (user info, roles)
   - Standard claims (iss, exp, sub)
   - Custom claims

3. **Signature**
   - Verify token integrity
   - Prevent tampering
   - HMAC or RSA

**How It Works:**

1. **Token Creation**
   ```
   User logs in → Server creates JWT → Returns to client
   ```

2. **Token Usage**
   ```
   Client sends JWT in header → Server validates → Grants access
   ```

3. **Validation**
   - Verify signature
   - Check expiration
   - Validate claims

**Example:**
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user123",
    "name": "John Doe",
    "roles": ["user", "admin"],
    "exp": 1234567890
  }
}
```

**Benefits:**
- Stateless
- Self-contained
- Compact
- Microservices-friendly
- No session store

**Security:**
- Use HTTPS
- Short expiration
- Secure signing key
- Validate signature
- Check expiration

---

## 106. How do you secure inter-service communication?

**Strategies:**

1. **mTLS (Mutual TLS)**
   - Both sides authenticated
   - Certificate-based
   - Encrypted communication
   - Service mesh provides

2. **API Keys**
   - Service-specific keys
   - Simple but less secure
   - Good for internal services

3. **JWT Tokens**
   - Service-to-service tokens
   - Validate tokens
   - Stateless

4. **Service Mesh**
   - Automatic mTLS
   - Policy enforcement
   - Traffic encryption
   - Istio, Linkerd

5. **Network Policies**
   - Restrict communication
   - Allow only needed
   - Kubernetes network policies

**Implementation:**

**mTLS with Service Mesh:**
```yaml
# Istio - Automatic mTLS
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

**API Key:**
```java
@Service
public class ServiceClient {
    public void callService() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-API-Key", apiKey);
        // Make request
    }
}
```

**Best Practices:**
- Use mTLS for production
- Service mesh for automation
- Network policies
- Least privilege
- Monitor communication

---

## 107. What is mTLS (mutual TLS) and why is it important?

**mTLS (Mutual TLS)** is TLS where both client and server authenticate each other using certificates.

**Difference from TLS:**
- **TLS**: Only server authenticated
- **mTLS**: Both authenticated

**How It Works:**

1. **Certificate Exchange**
   - Client presents certificate
   - Server presents certificate
   - Both validate certificates

2. **Mutual Authentication**
   - Server verifies client
   - Client verifies server
   - Both authenticated

3. **Encrypted Communication**
   - Encrypted channel
   - Data protection
   - Integrity

**Why Important:**

1. **Service Identity**
   - Verify service identity
   - Prevent impersonation
   - Trust between services

2. **Data Protection**
   - Encrypted communication
   - Prevent eavesdropping
   - Data integrity

3. **Zero Trust**
   - Don't trust network
   - Verify everything
   - Defense in depth

4. **Compliance**
   - Regulatory requirements
   - Audit requirements
   - Security standards

**Implementation:**
- Service mesh (automatic)
- Certificate management
- CA (Certificate Authority)
- Certificate rotation

**Service Mesh:**
- Istio, Linkerd provide mTLS
- Automatic certificate management
- Easy to implement
- Production-ready

---

## 108. How do you implement API security in microservices?

**API Security Measures:**

1. **Authentication**
   - API keys
   - JWT tokens
   - OAuth 2.0
   - mTLS

2. **Authorization**
   - Role-based access control
   - Permission checks
   - Resource-level access

3. **Rate Limiting**
   - Limit requests per client
   - Prevent abuse
   - DDoS protection

4. **Input Validation**
   - Validate all inputs
   - Sanitize data
   - Prevent injection attacks

5. **HTTPS/TLS**
   - Encrypt communication
   - Prevent man-in-the-middle
   - Data protection

6. **API Versioning**
   - Version APIs
   - Deprecation strategy
   - Backward compatibility

7. **Monitoring**
   - Log API calls
   - Monitor anomalies
   - Alert on attacks

**Implementation:**

**API Gateway:**
```yaml
# Kong API Gateway
plugins:
  - name: jwt
  - name: rate-limiting
    config:
      minute: 100
  - name: cors
  - name: request-validator
```

**Service Level:**
```java
@RestController
public class ApiController {
    @PreAuthorize("hasRole('USER')")
    @GetMapping("/api/data")
    public ResponseEntity<Data> getData() {
        // Validate input
        // Check permissions
        // Return data
    }
}
```

**Best Practices:**
- Defense in depth
- Authenticate at gateway
- Validate inputs
- Rate limiting
- Monitor and log
- Regular security audits

---

## 109. What is the difference between API key and OAuth token?

| Aspect | API Key | OAuth Token |
|--------|---------|-------------|
| **Type** | Simple string | JWT/OAuth token |
| **Security** | Less secure | More secure |
| **Use Case** | Service-to-service | User authorization |
| **Revocation** | Manual | Automatic (expiration) |
| **Scope** | Full access | Scoped access |
| **User Context** | No | Yes |
| **Refresh** | No | Yes (refresh token) |

**API Key:**
- Simple string identifier
- Service-to-service
- Less secure
- Full access
- Easy to implement

**OAuth Token:**
- Token with claims
- User authorization
- More secure
- Scoped access
- Expiration and refresh

**When to Use:**

**API Key:**
- Service-to-service
- Internal APIs
- Simple use cases
- Less security critical

**OAuth Token:**
- User APIs
- Third-party access
- Scoped access needed
- Higher security

**Best Practices:**
- Use OAuth for user APIs
- Use API keys for service-to-service
- Secure storage
- Rotate keys/tokens
- Monitor usage

---

## 110. How do you handle secrets management in microservices?

**Secrets Management** securely stores and manages sensitive information like passwords, API keys, certificates.

**Challenges:**
- Multiple services
- Distributed secrets
- Rotation
- Access control

**Solutions:**

1. **Secrets Management Tools**
   - HashiCorp Vault
   - AWS Secrets Manager
   - Azure Key Vault
   - Kubernetes Secrets

2. **Best Practices**
   - Centralized storage
   - Encryption at rest
   - Encryption in transit
   - Access control
   - Rotation
   - Audit logging

**Implementation:**

**HashiCorp Vault:**
```java
@Service
public class SecretsService {
    @Autowired
    private VaultTemplate vaultTemplate;
    
    public String getSecret(String path) {
        return vaultTemplate.read(path).getData().get("value");
    }
}
```

**Kubernetes Secrets:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  username: base64encoded
  password: base64encoded
```

**Best Practices:**
- Never commit secrets
- Use secrets management tools
- Encrypt at rest and in transit
- Rotate regularly
- Least privilege access
- Audit access
- Use environment variables carefully

---

## 111. What are the best practices for securing microservices?

**Best Practices:**

1. **Defense in Depth**
   - Multiple security layers
   - Gateway, service, network
   - No single point of failure

2. **Zero Trust Model**
   - Don't trust network
   - Verify everything
   - Authenticate all communication

3. **Service Mesh**
   - Automatic mTLS
   - Policy enforcement
   - Traffic encryption

4. **API Gateway**
   - Centralized auth
   - Rate limiting
   - Input validation

5. **Secrets Management**
   - Centralized storage
   - Encryption
   - Rotation

6. **Network Policies**
   - Restrict communication
   - Least privilege
   - Segmentation

7. **Regular Updates**
   - Patch vulnerabilities
   - Update dependencies
   - Security patches

8. **Monitoring**
   - Log security events
   - Monitor anomalies
   - Alert on attacks

9. **Input Validation**
   - Validate all inputs
   - Sanitize data
   - Prevent injection

10. **Least Privilege**
    - Minimum permissions
    - Role-based access
    - Principle of least privilege

---

## 112. How do you implement role-based access control (RBAC)?

**RBAC** assigns permissions based on roles rather than individual users.

**Components:**

1. **Roles**
   - Collection of permissions
   - Example: Admin, User, Guest

2. **Permissions**
   - Actions allowed
   - Example: Read, Write, Delete

3. **Users**
   - Assigned roles
   - Inherit permissions

**Implementation:**

**Database Schema:**
```
Users → UserRoles → Roles → RolePermissions → Permissions
```

**Code:**
```java
@PreAuthorize("hasRole('ADMIN')")
@DeleteMapping("/api/users/{id}")
public void deleteUser(@PathVariable String id) {
    // Only admins can delete
}

@PreAuthorize("hasPermission(#id, 'User', 'READ')")
@GetMapping("/api/users/{id}")
public User getUser(@PathVariable String id) {
    // Check specific permission
}
```

**JWT Claims:**
```json
{
  "roles": ["ADMIN", "USER"],
  "permissions": ["READ", "WRITE", "DELETE"]
}
```

**Best Practices:**
- Principle of least privilege
- Regular access reviews
- Role hierarchy
- Audit role assignments
- Separate admin roles

---

## 113. What is the principle of least privilege in microservices?

**Principle of Least Privilege** grants minimum permissions necessary to perform a task.

**In Microservices:**

1. **Service Permissions**
   - Minimum database access
   - Only needed tables
   - Read-only when possible

2. **Network Access**
   - Only communicate with needed services
   - Network policies
   - Firewall rules

3. **API Permissions**
   - Minimum API access
   - Scoped tokens
   - Role-based access

4. **Secrets Access**
   - Only needed secrets
   - No unnecessary access
   - Rotate regularly

**Benefits:**
- Reduced attack surface
- Limit damage if compromised
- Better security
- Compliance

**Implementation:**
- Network policies
- RBAC
- Scoped tokens
- Database permissions
- Secrets access control

**Example:**
```
Order Service:
- Can write to orders table
- Can read from products table
- Cannot access users table
- Can call Payment Service API
- Cannot call Admin Service API
```

---

## 114. How do you prevent API abuse in microservices?

**Prevention Strategies:**

1. **Rate Limiting**
   - Limit requests per client
   - Prevent abuse
   - DDoS protection

2. **Authentication**
   - Require authentication
   - Validate tokens
   - Prevent anonymous access

3. **Input Validation**
   - Validate all inputs
   - Sanitize data
   - Prevent injection

4. **Monitoring**
   - Monitor API usage
   - Detect anomalies
   - Alert on abuse

5. **Throttling**
   - Slow down requests
   - Queue requests
   - Prevent overload

6. **IP Blocking**
   - Block abusive IPs
   - Blacklist
   - Temporary blocks

**Implementation:**

**Rate Limiting:**
```yaml
plugins:
  - name: rate-limiting
    config:
      minute: 100
      hour: 1000
      policy: redis
```

**Monitoring:**
- Track request rates
- Monitor error rates
- Detect patterns
- Alert on anomalies

**Best Practices:**
- Implement rate limiting
- Monitor usage
- Validate inputs
- Use WAF (Web Application Firewall)
- Regular security audits

---

## 115. What is rate limiting and how do you implement it?

**Rate Limiting** restricts the number of requests a client can make within a time period.

**Strategies:**

1. **Fixed Window**
   - Limit per time window
   - Reset at boundary
   - Simple but can spike

2. **Sliding Window**
   - Rolling time window
   - More accurate
   - Smoother

3. **Token Bucket**
   - Tokens added at rate
   - Request consumes token
   - Allows bursts

**Implementation:**

**API Gateway:**
```yaml
plugins:
  - name: rate-limiting
    config:
      minute: 100
      hour: 1000
      policy: redis
```

**Service Level:**
```java
@RateLimiter(name = "default")
@GetMapping("/api/data")
public ResponseEntity<Data> getData() {
    // Rate limited
}
```

**Redis-Based:**
```java
@Service
public class RateLimitService {
    public boolean isAllowed(String key, int limit, int window) {
        String count = redis.get(key);
        if (count == null || Integer.parseInt(count) < limit) {
            redis.incr(key);
            redis.expire(key, window);
            return true;
        }
        return false;
    }
}
```

**Best Practices:**
- Set appropriate limits
- Use distributed storage (Redis)
- Return 429 status code
- Include Retry-After header
- Monitor rate limit hits

---

## 116. How do you handle security in service-to-service communication?

**Strategies:**

1. **mTLS**
   - Mutual TLS
   - Certificate-based
   - Encrypted
   - Service mesh provides

2. **Service Mesh**
   - Automatic mTLS
   - Policy enforcement
   - Traffic encryption
   - Istio, Linkerd

3. **API Keys**
   - Service-specific keys
   - Simple authentication
   - Less secure than mTLS

4. **JWT Tokens**
   - Service-to-service tokens
   - Validate tokens
   - Stateless

5. **Network Policies**
   - Restrict communication
   - Allow only needed
   - Kubernetes policies

**Service Mesh Example:**
```yaml
# Istio - Automatic mTLS
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

**Best Practices:**
- Use mTLS for production
- Service mesh for automation
- Network policies
- Least privilege
- Monitor communication
- Regular audits

---

## 117. What is the difference between perimeter security and defense in depth?

**Perimeter Security:**
- **Approach**: Secure boundary
- **Focus**: Edge security
- **Assumption**: Trust internal network
- **Example**: Firewall at edge

**Defense in Depth:**
- **Approach**: Multiple security layers
- **Focus**: Every layer secured
- **Assumption**: Don't trust any layer
- **Example**: Gateway + Service + Network

**Comparison:**

| Aspect | Perimeter | Defense in Depth |
|--------|-----------|-----------------|
| **Layers** | Single (edge) | Multiple |
| **Trust** | Trust internal | Trust nothing |
| **Security** | Edge only | Everywhere |
| **Approach** | Old | Modern (zero trust) |

**Defense in Depth Layers:**
1. API Gateway (auth, rate limiting)
2. Service Mesh (mTLS, policies)
3. Service Level (validation, auth)
4. Network (policies, segmentation)
5. Data (encryption, access control)

**Best Practices:**
- Use defense in depth
- Zero trust model
- Multiple security layers
- Don't trust network
- Secure everything

---

## 118. How do you implement security at the API Gateway level?

**API Gateway Security:**

1. **Authentication**
   - Validate tokens (JWT, OAuth)
   - API key validation
   - Single sign-on

2. **Authorization**
   - Role-based access
   - Permission checks
   - Policy enforcement

3. **Rate Limiting**
   - Limit requests
   - Prevent abuse
   - DDoS protection

4. **Input Validation**
   - Validate requests
   - Sanitize data
   - Prevent injection

5. **SSL/TLS Termination**
   - HTTPS termination
   - Certificate management
   - Encryption

6. **WAF (Web Application Firewall)**
   - Attack detection
   - Pattern matching
   - Block malicious requests

**Implementation:**

**Kong Gateway:**
```yaml
services:
  - name: api-service
    plugins:
      - name: jwt
      - name: rate-limiting
        config:
          minute: 100
      - name: cors
      - name: request-validator
```

**Benefits:**
- Centralized security
- Single point of control
- Consistent policies
- Easier management

**Best Practices:**
- Authenticate at gateway
- Rate limiting
- Input validation
- SSL termination
- Monitor and log
- Regular updates

---

## 119. What are the security implications of service mesh?

**Security Benefits:**

1. **Automatic mTLS**
   - Encrypted communication
   - Certificate management
   - No code changes

2. **Policy Enforcement**
   - Access policies
   - Traffic rules
   - Centralized control

3. **Identity Management**
   - Service identity
   - Certificate-based
   - Automatic

4. **Traffic Encryption**
   - All traffic encrypted
   - Data protection
   - Eavesdropping prevention

**Security Considerations:**

1. **Certificate Management**
   - CA (Certificate Authority)
   - Certificate rotation
   - Expiration handling

2. **Policy Complexity**
   - Complex policies
   - Management overhead
   - Testing needed

3. **Performance**
   - Encryption overhead
   - Latency impact
   - Resource usage

**Best Practices:**
- Use service mesh for mTLS
- Implement policies
- Monitor security
- Regular audits
- Certificate rotation
- Test policies

**Service Mesh Security:**
- Istio: mTLS, policies, RBAC
- Linkerd: Automatic mTLS
- Consul Connect: Service mesh security

---

## 120. How do you handle security in event-driven microservices?

**Security Challenges:**
- Asynchronous communication
- Event validation
- Message encryption
- Access control

**Strategies:**

1. **Message Encryption**
   - Encrypt event payloads
   - TLS for transport
   - End-to-end encryption

2. **Event Authentication**
   - Sign events
   - Verify signatures
   - Prevent tampering

3. **Access Control**
   - Topic-level permissions
   - Producer/consumer auth
   - Role-based access

4. **Message Validation**
   - Validate event schema
   - Sanitize data
   - Prevent injection

5. **Audit Logging**
   - Log all events
   - Track access
   - Compliance

**Implementation:**

**Kafka Security:**
```properties
# SASL authentication
security.protocol=SASL_SSL
sasl.mechanism=PLAIN

# ACLs (Access Control Lists)
# Producer: can write to topic
# Consumer: can read from topic
```

**Event Signing:**
```java
public class EventPublisher {
    public void publish(Event event) {
        String signature = sign(event);
        event.setSignature(signature);
        kafkaTemplate.send(topic, event);
    }
}
```

**Best Practices:**
- Encrypt messages
- Authenticate producers/consumers
- Validate events
- Use TLS
- Audit logging
- Access control

