# Microservices Interview Answers - Service Discovery & API Gateway (Questions 41-60)

## 41. What is service discovery and why is it needed?

**Service Discovery** is the automatic detection of services and their network locations in a microservices architecture. It allows services to find and communicate with each other without hardcoding addresses.

**Why Needed:**

1. **Dynamic Environments**
   - Services start/stop frequently
   - IP addresses change
   - Containers get new IPs
   - Can't hardcode addresses

2. **Scalability**
   - Multiple instances of services
   - Load distribution
   - Auto-scaling
   - Need to find available instances

3. **Resilience**
   - Services fail and recover
   - New instances replace failed ones
   - Automatic reconnection
   - Health monitoring

4. **Cloud-Native**
   - Containers in Kubernetes
   - Pods get new IPs
   - Services need to discover each other
   - Dynamic orchestration

**How It Works:**
1. Services register themselves
2. Registry stores service locations
3. Clients query registry
4. Registry returns available instances
5. Client connects to instance

**Benefits:**
- No hardcoded addresses
- Automatic failover
- Load balancing
- Health monitoring
- Dynamic scaling

---

## 42. What are the types of service discovery patterns?

**Two Main Patterns:**

### 1. Client-Side Service Discovery

**How It Works:**
- Client queries service registry
- Registry returns list of instances
- Client selects instance (load balancing)
- Client connects directly to instance

**Components:**
- Service Registry (e.g., Consul, Eureka)
- Service instances register themselves
- Client queries registry

**Pros:**
- Simple registry
- Client controls load balancing
- No additional network hop

**Cons:**
- Client complexity
- Client must implement load balancing
- Coupling to registry

**Example:**
- Netflix Eureka
- HashiCorp Consul

### 2. Server-Side Service Discovery

**How It Works:**
- Client makes request to load balancer
- Load balancer queries registry
- Load balancer routes to instance
- Client doesn't know about registry

**Components:**
- Service Registry
- Load Balancer/API Gateway
- Service instances

**Pros:**
- Client simplicity
- Centralized load balancing
- Decouples client from registry

**Cons:**
- Additional network hop
- Load balancer complexity
- Single point of failure (if not HA)

**Example:**
- Kubernetes Services
- AWS ELB
- API Gateway

**Hybrid Approach:**
- Use both patterns
- Client-side for internal services
- Server-side for external clients

---

## 43. What is client-side service discovery?

**Client-Side Service Discovery** is a pattern where the client is responsible for querying the service registry and selecting which service instance to call.

**How It Works:**

1. **Service Registration**
   - Service instances register with registry
   - Provide service name, IP, port, health status

2. **Client Query**
   - Client queries registry for service
   - Registry returns list of healthy instances

3. **Load Balancing**
   - Client selects instance (round-robin, random, etc.)
   - Client implements load balancing logic

4. **Direct Connection**
   - Client connects directly to selected instance
   - No intermediary

**Example Flow:**
```
1. Order Service starts → Registers with Eureka
2. Payment Service needs Order Service
3. Payment Service queries Eureka → Gets list of Order Service instances
4. Payment Service selects instance (load balancing)
5. Payment Service calls Order Service directly
```

**Implementation:**
- Netflix Eureka (Java)
- HashiCorp Consul
- etcd
- Zookeeper

**Pros:**
- No additional network hop
- Client controls load balancing
- Simple registry (just stores info)
- Direct communication

**Cons:**
- Client complexity (must implement discovery)
- Coupling to registry
- Load balancing logic in client
- Must handle registry failures

**Use When:**
- Internal service-to-service communication
- Need direct connections
- Want client control
- High performance requirements

---

## 44. What is server-side service discovery?

**Server-Side Service Discovery** is a pattern where a load balancer or API Gateway queries the service registry and routes requests to service instances. The client doesn't interact with the registry directly.

**How It Works:**

1. **Service Registration**
   - Service instances register with registry
   - Provide service name, IP, port

2. **Client Request**
   - Client makes request to load balancer/gateway
   - Client doesn't know about registry

3. **Registry Query**
   - Load balancer queries registry
   - Gets list of healthy instances

4. **Request Routing**
   - Load balancer selects instance
   - Routes request to instance
   - Returns response to client

**Example Flow:**
```
1. Order Service instances register with registry
2. Client calls API Gateway: GET /api/orders
3. API Gateway queries registry → Gets Order Service instances
4. API Gateway routes to selected instance
5. Response returned to client
```

**Implementation:**
- Kubernetes Services
- AWS Application Load Balancer
- API Gateway (Kong, AWS API Gateway)
- Service Mesh (Istio)

**Pros:**
- Client simplicity (just calls gateway)
- Centralized load balancing
- Decouples client from registry
- Single entry point
- Can add cross-cutting concerns (auth, rate limiting)

**Cons:**
- Additional network hop
- Load balancer complexity
- Potential bottleneck
- Single point of failure (if not HA)

**Use When:**
- External clients
- Need centralized control
- Want to add cross-cutting concerns
- Simpler client requirements

---

## 45. What is the difference between service registry and service discovery?

**Service Registry:**
- **What**: Database/storage of service instances
- **Function**: Stores service metadata (name, IP, port, health)
- **Type**: Component/infrastructure
- **Examples**: Eureka Server, Consul, etcd, Zookeeper

**Service Discovery:**
- **What**: Process/pattern of finding services
- **Function**: Mechanism to locate services
- **Type**: Pattern/process
- **Examples**: Client-side discovery, Server-side discovery

**Relationship:**
- Service Discovery **uses** Service Registry
- Registry is the **storage**
- Discovery is the **process**

**Analogy:**
- Registry = Phone book (stores information)
- Discovery = Looking up a number (process)

**In Practice:**
- Eureka = Service Registry
- Querying Eureka = Service Discovery
- Consul = Service Registry
- Consul DNS/HTTP API = Service Discovery mechanism

**Key Point:**
- Registry is the infrastructure
- Discovery is how you use it
- Often used together
- Discovery pattern determines how registry is accessed

---

## 46. What are popular service discovery tools?

**Popular Tools:**

1. **Netflix Eureka**
   - Java-based
   - Client-side discovery
   - Self-registration
   - REST API
   - Good for Spring Boot

2. **HashiCorp Consul**
   - Multi-purpose (service discovery, config, health)
   - Client and server-side
   - DNS and HTTP API
   - Health checking
   - Key-value store

3. **etcd**
   - Distributed key-value store
   - Used by Kubernetes
   - Strong consistency
   - Watch API
   - CoreOS project

4. **Apache Zookeeper**
   - Distributed coordination
   - Used by Kafka, Hadoop
   - Strong consistency
   - More complex
   - Good for coordination

5. **Kubernetes Services**
   - Built-in service discovery
   - DNS-based
   - Server-side discovery
   - Automatic
   - Cloud-native

6. **Consul Connect**
   - Service mesh integration
   - mTLS
   - Service discovery + security
   - HashiCorp

7. **AWS Cloud Map**
   - Managed service discovery
   - AWS integration
   - DNS and API-based
   - Pay-per-use

8. **Azure Service Fabric**
   - Microsoft's platform
   - Built-in discovery
   - Service mesh capabilities

**Selection Criteria:**
- Language/framework
- Cloud provider
- Complexity needs
- Features required
- Managed vs self-hosted

---

## 47. How does Consul handle service discovery?

**Consul** is a multi-purpose tool that provides service discovery, health checking, and configuration management.

**How It Works:**

1. **Service Registration**
   ```json
   {
     "ID": "order-service-1",
     "Name": "order-service",
     "Tags": ["v1", "production"],
     "Address": "10.0.1.5",
     "Port": 8080,
     "Check": {
       "HTTP": "http://10.0.1.5:8080/health",
       "Interval": "10s"
     }
   }
   ```

2. **Service Discovery Methods**
   - **DNS**: `order-service.service.consul`
   - **HTTP API**: `GET /v1/health/service/order-service`
   - **gRPC**: Native gRPC support

3. **Health Checking**
   - Automatic health checks
   - Removes unhealthy instances
   - Multiple check types (HTTP, TCP, Script)

4. **Features**
   - Service catalog
   - Health monitoring
   - Key-value store
   - Multi-datacenter
   - ACLs for security

**Architecture:**
- **Agents**: Run on each node
- **Servers**: Maintain state (3-5 recommended)
- **Clients**: Query agents

**Example Usage:**
```bash
# Register service
consul services register order-service.json

# Discover via DNS
dig @127.0.0.1 -p 8600 order-service.service.consul

# Discover via HTTP API
curl http://localhost:8500/v1/health/service/order-service
```

**Benefits:**
- Multiple discovery methods
- Built-in health checking
- Multi-datacenter support
- Configuration management
- Service mesh integration

---

## 48. How does Eureka handle service discovery?

**Eureka** is Netflix's service discovery tool, popular in Spring Boot applications.

**How It Works:**

1. **Eureka Server**
   - Central registry
   - Stores service instances
   - Provides REST API
   - Replicates between servers

2. **Service Registration**
   - Services register on startup
   - Send heartbeats (renewal)
   - Self-registration
   - Self-preservation mode

3. **Service Discovery**
   - Clients query Eureka Server
   - Get list of instances
   - Client-side load balancing
   - Caching for performance

**Architecture:**
- **Eureka Server**: Registry server
- **Eureka Client**: Service instances and clients
- **Peer Replication**: Multiple servers replicate

**Registration Flow:**
```
1. Service starts → Registers with Eureka Server
2. Eureka Server stores registration
3. Service sends heartbeats every 30s
4. If no heartbeat for 90s → Mark as down
```

**Discovery Flow:**
```
1. Client queries Eureka Server
2. Eureka returns list of instances
3. Client caches results (30s default)
4. Client selects instance (Ribbon load balancing)
5. Client calls service directly
```

**Features:**
- Self-preservation mode
- Zone awareness
- REST API
- Spring Cloud integration
- Client-side caching

**Example - Spring Boot:**
```java
@SpringBootApplication
@EnableEurekaClient
public class OrderService {
    // Auto-registers with Eureka
}

@LoadBalanced
@Bean
public RestTemplate restTemplate() {
    return new RestTemplate();
}
```

**Benefits:**
- Simple to use
- Spring Boot integration
- Client-side caching
- Zone awareness
- Self-preservation

---

## 49. What is API Gateway and what are its responsibilities?

**API Gateway** is a single entry point for all client requests in a microservices architecture. It acts as a reverse proxy that routes requests to appropriate microservices.

**Responsibilities:**

1. **Request Routing**
   - Route requests to correct service
   - URL-based routing
   - Path rewriting
   - Load balancing

2. **Authentication & Authorization**
   - Validate tokens (JWT, OAuth)
   - Check permissions
   - Single sign-on (SSO)
   - API keys

3. **Rate Limiting**
   - Limit requests per client
   - Prevent abuse
   - Throttling
   - Quota management

4. **Request/Response Transformation**
   - Transform request format
   - Aggregate responses
   - Data format conversion
   - Protocol translation

5. **Load Balancing**
   - Distribute requests
   - Health checks
   - Circuit breaking
   - Failover

6. **Monitoring & Logging**
   - Request logging
   - Metrics collection
   - Performance monitoring
   - Analytics

7. **Caching**
   - Cache responses
   - Reduce backend load
   - Improve performance
   - Cache invalidation

8. **Security**
   - SSL/TLS termination
   - DDoS protection
   - Input validation
   - Security headers

9. **Versioning**
   - API versioning
   - Backward compatibility
   - Deprecation handling

10. **Documentation**
    - API documentation
    - OpenAPI/Swagger
    - Developer portal

**Benefits:**
- Single entry point
- Centralized cross-cutting concerns
- Client simplification
- Security enforcement
- Performance optimization

---

## 50. What are the benefits of using an API Gateway?

**Benefits:**

1. **Single Entry Point**
   - One URL for all services
   - Simplified client code
   - Easier to manage
   - Consistent interface

2. **Security Centralization**
   - Single place for auth
   - Consistent security policies
   - Easier to audit
   - Reduced attack surface

3. **Decoupling**
   - Clients don't know service locations
   - Services can change internally
   - Independent service evolution
   - Hide complexity

4. **Cross-Cutting Concerns**
   - Rate limiting in one place
   - Logging centralized
   - Monitoring unified
   - Caching strategy

5. **Performance**
   - Response caching
   - Request aggregation
   - Compression
   - Protocol optimization

6. **Reliability**
   - Circuit breaking
   - Retry logic
   - Timeout handling
   - Failover

7. **Developer Experience**
   - API documentation
   - Developer portal
   - SDK generation
   - Testing tools

8. **Operational Benefits**
   - Centralized monitoring
   - Easier debugging
   - Traffic analysis
   - Cost tracking

9. **Versioning**
   - API version management
   - Backward compatibility
   - Gradual migration

10. **Compliance**
    - Audit logging
    - Access control
    - Data privacy
    - Regulatory compliance

**Trade-offs:**
- Additional hop (latency)
- Potential bottleneck
- Single point of failure (mitigate with HA)
- Additional complexity

---

## 51. What is the difference between API Gateway and service mesh?

| Aspect | API Gateway | Service Mesh |
|--------|-------------|--------------|
| **Layer** | North-South traffic (client to services) | East-West traffic (service to service) |
| **Scope** | External API access | Internal service communication |
| **Placement** | Edge of system | Between all services |
| **Traffic** | Ingress traffic | Inter-service traffic |
| **Implementation** | Centralized gateway | Sidecar proxies |
| **Control** | Centralized | Distributed |
| **Use Case** | External clients | Internal services |
| **Features** | Auth, rate limiting, routing | mTLS, observability, traffic management |

**API Gateway:**
- Handles external traffic
- Single entry point
- Client-facing
- API management
- Example: Kong, AWS API Gateway

**Service Mesh:**
- Handles internal traffic
- Every service has sidecar
- Service-to-service
- Infrastructure layer
- Example: Istio, Linkerd

**Can Use Both:**
- API Gateway for external access
- Service Mesh for internal communication
- Complementary technologies
- Different concerns

**Example Architecture:**
```
Client → API Gateway → Service Mesh → Microservices
         (External)      (Internal)
```

---

## 52. How does API Gateway handle authentication and authorization?

**Authentication Methods:**

1. **API Keys**
   - Simple key-based auth
   - Header: `X-API-Key: abc123`
   - Quick validation
   - Good for simple use cases

2. **JWT (JSON Web Tokens)**
   - Stateless tokens
   - Contains user claims
   - Signature verification
   - Expiration handling

3. **OAuth 2.0**
   - Authorization framework
   - Token validation
   - Refresh tokens
   - Multiple grant types

4. **Basic Authentication**
   - Username/password
   - Base64 encoded
   - Simple but less secure

5. **mTLS (Mutual TLS)**
   - Certificate-based
   - Strong security
   - Service-to-service

**Authorization:**

1. **Role-Based Access Control (RBAC)**
   - Roles assigned to users
   - Permissions per role
   - Policy enforcement

2. **Attribute-Based Access Control (ABAC)**
   - Policies based on attributes
   - Fine-grained control
   - Context-aware

3. **API-Level Authorization**
   - Endpoint permissions
   - Method restrictions
   - Resource-level access

**Implementation Flow:**
```
1. Client sends request with credentials
2. Gateway validates credentials
3. Gateway checks authorization policies
4. If authorized → Route to service
5. If not → Return 401/403
```

**Best Practices:**
- Validate tokens
- Cache validation results
- Use HTTPS
- Implement rate limiting
- Log authentication events
- Handle token expiration

**Example - Kong:**
```yaml
plugins:
  - name: jwt
    config:
      secret_is_base64: false
  - name: acl
    config:
      whitelist: ["admin", "user"]
```

---

## 53. What is API Gateway routing and load balancing?

**Routing:**

**Purpose:** Route requests to correct backend service

**Routing Methods:**

1. **Path-Based Routing**
   ```
   /api/users → User Service
   /api/orders → Order Service
   /api/products → Product Service
   ```

2. **Host-Based Routing**
   ```
   users.api.example.com → User Service
   orders.api.example.com → Order Service
   ```

3. **Method-Based Routing**
   ```
   GET /api/data → Read Service
   POST /api/data → Write Service
   ```

4. **Header-Based Routing**
   ```
   X-Service-Version: v1 → v1 Service
   X-Service-Version: v2 → v2 Service
   ```

**Load Balancing:**

**Purpose:** Distribute requests across multiple instances

**Algorithms:**

1. **Round Robin**
   - Distribute sequentially
   - Equal distribution
   - Simple

2. **Least Connections**
   - Route to instance with fewest connections
   - Better for long connections
   - Dynamic

3. **IP Hash**
   - Hash client IP
   - Same client → same instance
   - Session affinity

4. **Weighted Round Robin**
   - Assign weights to instances
   - Route more to higher weight
   - Capacity-based

5. **Health-Based**
   - Route only to healthy instances
   - Remove unhealthy
   - Automatic failover

**Implementation:**
- Gateway maintains service registry
- Queries registry for instances
- Selects instance using algorithm
- Routes request
- Monitors health

**Example - Kong:**
```yaml
services:
  - name: user-service
    url: http://user-service:8080
    routes:
      - paths: ["/api/users"]
    healthchecks:
      active:
        healthy:
          interval: 10
        unhealthy:
          interval: 10
```

---

## 54. How does API Gateway handle rate limiting?

**Rate Limiting** restricts the number of requests a client can make within a time period.

**Strategies:**

1. **Fixed Window**
   - Limit per time window (e.g., 100 requests/hour)
   - Reset at window boundary
   - Simple but can have spikes

2. **Sliding Window**
   - Rolling time window
   - More accurate
   - Smoother distribution

3. **Token Bucket**
   - Tokens added at rate
   - Request consumes token
   - Allows bursts
   - Flexible

4. **Leaky Bucket**
   - Requests added to bucket
   - Processed at fixed rate
   - Prevents bursts
   - Smooths traffic

**Implementation:**

1. **Per Client**
   - Limit by API key
   - Limit by IP address
   - Limit by user ID

2. **Per Endpoint**
   - Different limits per endpoint
   - Protect expensive operations
   - Granular control

3. **Global**
   - System-wide limit
   - Protect infrastructure
   - Overall capacity

**Storage:**
- In-memory (fast, not distributed)
- Redis (distributed, shared state)
- Database (persistent, slower)

**Response:**
- HTTP 429 (Too Many Requests)
- Retry-After header
- Custom error message

**Example - Kong:**
```yaml
plugins:
  - name: rate-limiting
    config:
      minute: 100
      hour: 1000
      policy: redis
      redis:
        host: redis
        port: 6379
```

**Best Practices:**
- Set appropriate limits
- Use distributed storage
- Return clear error messages
- Monitor rate limit hits
- Differentiate by client tier

---

## 55. What is the difference between API Gateway and reverse proxy?

**Reverse Proxy:**
- Generic proxy server
- Sits in front of servers
- Forwards requests
- Basic functionality
- Example: Nginx, HAProxy

**API Gateway:**
- Specialized reverse proxy
- API-specific features
- Rich functionality
- Microservices-focused
- Example: Kong, AWS API Gateway

**Key Differences:**

| Aspect | Reverse Proxy | API Gateway |
|--------|---------------|-------------|
| **Purpose** | General proxying | API management |
| **Features** | Basic routing, load balancing | Auth, rate limiting, transformation |
| **API Focus** | No | Yes |
| **Transformation** | Limited | Rich (request/response) |
| **Documentation** | No | Yes (OpenAPI) |
| **Developer Portal** | No | Often yes |
| **Use Case** | Simple routing | API management |

**API Gateway Includes:**
- Everything reverse proxy does
- Plus API-specific features
- Authentication/authorization
- Rate limiting
- API versioning
- Documentation
- Analytics

**When to Use:**

**Reverse Proxy:**
- Simple routing needs
- Basic load balancing
- SSL termination
- No API management needed

**API Gateway:**
- API management needed
- Multiple APIs
- Need auth, rate limiting
- API documentation
- Developer experience important

**Evolution:**
- Reverse proxy → API Gateway
- API Gateway is enhanced reverse proxy
- Specialized for APIs
- More features

---

## 56. How do you handle API versioning at the gateway level?

**Versioning Strategies:**

1. **URL Path Versioning**
   ```
   /api/v1/users
   /api/v2/users
   ```
   - Route based on path
   - Clear and explicit
   - Easy to implement

2. **Header Versioning**
   ```
   Accept: application/vnd.api.v1+json
   ```
   - Keep URLs clean
   - More RESTful
   - Header-based routing

3. **Query Parameter**
   ```
   /api/users?version=1
   ```
   - Simple
   - Less RESTful
   - Easy to implement

4. **Subdomain Versioning**
   ```
   v1.api.example.com
   v2.api.example.com
   ```
   - Clear separation
   - DNS-based routing
   - More complex

**Gateway Implementation:**

**Kong Example:**
```yaml
services:
  - name: user-service-v1
    url: http://user-service-v1:8080
    routes:
      - paths: ["/api/v1/users"]
  
  - name: user-service-v2
    url: http://user-service-v2:8080
    routes:
      - paths: ["/api/v2/users"]
```

**Header-Based:**
```yaml
routes:
  - name: users-v1
    paths: ["/api/users"]
    headers:
      Accept: ["application/vnd.api.v1+json"]
    service: user-service-v1
  
  - name: users-v2
    paths: ["/api/users"]
    headers:
      Accept: ["application/vnd.api.v2+json"]
    service: user-service-v2
```

**Best Practices:**
- Support multiple versions
- Default to latest version
- Deprecation warnings
- Version in response headers
- Clear deprecation timeline
- Monitor version usage

---

## 57. What is circuit breaker pattern in API Gateway?

**Circuit Breaker** prevents cascading failures by stopping requests to a failing service and providing fallback responses.

**States:**

1. **Closed (Normal)**
   - Requests pass through
   - Monitoring failures
   - Normal operation

2. **Open (Failure Detected)**
   - Requests fail fast
   - Return error immediately
   - Don't call failing service
   - Prevents overload

3. **Half-Open (Testing)**
   - Allow test requests
   - Check if service recovered
   - Transition based on results

**How It Works:**
```
1. Monitor request failures
2. If failure rate > threshold → Open circuit
3. Return error immediately (fail fast)
4. After timeout → Half-open
5. Test request → If success → Close, If fail → Open
```

**Benefits:**
- Prevents cascading failures
- Fails fast
- Gives service time to recover
- Protects system
- Better user experience

**Implementation in Gateway:**
- Monitor backend responses
- Track failure rates
- Open circuit on threshold
- Return cached response or error
- Retry after timeout

**Example - Kong:**
```yaml
plugins:
  - name: circuit-breaker
    config:
      timeout: 5
      max_ failures: 5
      reset_timeout: 60
```

**Best Practices:**
- Set appropriate thresholds
- Provide fallback responses
- Monitor circuit state
- Alert on circuit opens
- Test recovery

---

## 58. How does API Gateway handle request aggregation?

**Request Aggregation** combines multiple backend requests into a single client request.

**Problem:**
- Client needs data from multiple services
- Multiple round trips
- High latency
- Poor performance

**Solution:**
- Gateway aggregates requests
- Single client request
- Parallel backend calls
- Combined response

**Example:**
```
Client Request: GET /api/user-dashboard/123

Gateway:
  - Calls User Service: GET /users/123
  - Calls Order Service: GET /orders?userId=123
  - Calls Notification Service: GET /notifications/123
  - Aggregates responses
  - Returns combined response
```

**Implementation:**

1. **Parallel Calls**
   - Make requests in parallel
   - Wait for all responses
   - Combine results

2. **Error Handling**
   - Handle partial failures
   - Return partial data
   - Error in response

3. **Caching**
   - Cache individual responses
   - Reduce backend calls
   - Improve performance

**Benefits:**
- Reduced latency
- Fewer round trips
- Better performance
- Simplified client

**Trade-offs:**
- Gateway complexity
- Coupling to multiple services
- Potential bottleneck

**Use When:**
- Client needs multiple data sources
- Performance critical
- Worth complexity

**Example Implementation:**
```javascript
// Gateway aggregation logic
async function getUserDashboard(userId) {
  const [user, orders, notifications] = await Promise.all([
    userService.getUser(userId),
    orderService.getOrders(userId),
    notificationService.getNotifications(userId)
  ]);
  
  return {
    user,
    orders,
    notifications
  };
}
```

---

## 59. What is the difference between edge gateway and internal gateway?

**Edge Gateway:**
- **Location**: Edge of network (internet-facing)
- **Traffic**: External client traffic
- **Security**: Strong security (DDoS, WAF)
- **Features**: Auth, rate limiting, SSL termination
- **Scale**: High scale (many clients)
- **Example**: Kong, AWS API Gateway

**Internal Gateway:**
- **Location**: Inside network (internal-facing)
- **Traffic**: Internal service-to-service
- **Security**: Less strict (trusted network)
- **Features**: Routing, load balancing, monitoring
- **Scale**: Lower scale (fewer services)
- **Example**: Internal API Gateway, Service Mesh

**Comparison:**

| Aspect | Edge Gateway | Internal Gateway |
|--------|--------------|-----------------|
| **Clients** | External | Internal services |
| **Security** | High (WAF, DDoS) | Moderate (mTLS) |
| **Rate Limiting** | Per client | Per service |
| **Authentication** | Strong (OAuth, JWT) | Service-to-service |
| **Scale** | Very high | Moderate |
| **Latency** | Higher (more processing) | Lower |

**Architecture:**
```
Internet → Edge Gateway → Internal Gateway → Microservices
          (External)      (Internal)
```

**Benefits of Separation:**
- Different security policies
- Independent scaling
- Specialized features
- Clear boundaries
- Better performance

**Use Both:**
- Edge for external access
- Internal for service communication
- Layered security
- Optimal performance

---

## 60. How do you implement service mesh with API Gateway?

**Combined Architecture:**

**Components:**
1. **API Gateway** (Edge)
   - External traffic
   - Authentication
   - Rate limiting
   - API management

2. **Service Mesh** (Internal)
   - Service-to-service
   - mTLS
   - Observability
   - Traffic management

**Integration:**

**Option 1: Gateway → Mesh**
```
Client → API Gateway → Service Mesh → Services
```
- Gateway routes to mesh
- Mesh handles internal traffic
- Clear separation

**Option 2: Gateway as Mesh Entry**
```
Client → API Gateway (Mesh Entry) → Mesh → Services
```
- Gateway is part of mesh
- Unified control plane
- Consistent policies

**Implementation:**

**Istio + Kong:**
```yaml
# Kong Gateway
services:
  - name: order-service
    url: http://order-service.istio-system.svc.cluster.local
    routes:
      - paths: ["/api/orders"]

# Istio Service Mesh
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: order-service
spec:
  hosts:
  - order-service
  http:
  - route:
    - destination:
        host: order-service
```

**Benefits:**
- External security (Gateway)
- Internal security (Mesh)
- Unified observability
- Consistent policies
- Best of both worlds

**Best Practices:**
- Use Gateway for external
- Use Mesh for internal
- Consistent security policies
- Unified monitoring
- Clear boundaries

