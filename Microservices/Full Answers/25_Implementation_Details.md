# Microservices Interview Answers - Implementation Details (Questions 481-500)

## 481. How do you implement idempotency in microservices?

**Idempotency Implementation:**

1. **Idempotency Keys**
   - Client provides key
   - Store processed keys
   - Check before processing

2. **Version Numbers**
   - Include version in request
   - Reject older versions
   - Process only latest

3. **State Checks**
   - Check current state
   - Skip if already done
   - Return existing result

**Example:**
```java
@Service
public class OrderService {
    @Autowired
    private IdempotencyStore idempotencyStore;
    
    public Order createOrder(OrderRequest request) {
        String idempotencyKey = request.getIdempotencyKey();
        
        // Check if already processed
        Order existing = idempotencyStore.get(idempotencyKey);
        if (existing != null) {
            return existing; // Return existing result
        }
        
        // Process order
        Order order = processOrder(request);
        
        // Store idempotency key
        idempotencyStore.put(idempotencyKey, order);
        
        return order;
    }
}
```

**Best Practices:**
- Use idempotency keys
- Check before processing
- Store processed keys
- Return same result
- Expire keys appropriately

---

## 482. How do you implement distributed locking in microservices?

**Distributed Locking:**

1. **Redis Distributed Lock**
   - Redis SETNX
   - Lock expiration
   - Lock release

2. **Zookeeper Locks**
   - Zookeeper locks
   - Ephemeral nodes
   - Lock management

3. **Database Locks**
   - Database locks
   - Pessimistic locking
   - Transaction locks

**Example - Redis:**
```java
@Service
public class LockService {
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    public boolean acquireLock(String key, int timeoutSeconds) {
        String lockKey = "lock:" + key;
        String value = UUID.randomUUID().toString();
        
        Boolean acquired = redisTemplate.opsForValue()
            .setIfAbsent(lockKey, value, Duration.ofSeconds(timeoutSeconds));
        
        return Boolean.TRUE.equals(acquired);
    }
    
    public void releaseLock(String key, String value) {
        String lockKey = "lock:" + key;
        // Lua script for atomic release
        redisTemplate.execute(new DefaultRedisScript<>(
            "if redis.call('get', KEYS[1]) == ARGV[1] then " +
            "return redis.call('del', KEYS[1]) else return 0 end",
            Long.class
        ), Collections.singletonList(lockKey), value);
    }
}
```

**Best Practices:**
- Use distributed locks sparingly
- Set expiration
- Handle lock failures
- Monitor lock usage
- Consider alternatives

---

## 483. How do you implement leader election in microservices?

**Leader Election:**

1. **Zookeeper**
   - Ephemeral nodes
   - Smallest node wins
   - Watch for changes

2. **etcd**
   - etcd leader election
   - Lease-based
   - Watch for leader

3. **Kubernetes**
   - Leader election API
   - ConfigMap/Lease
   - Built-in support

**Example - Kubernetes:**
```java
@Component
public class LeaderElection {
    @Autowired
    private KubernetesClient kubernetesClient;
    
    public void startLeaderElection() {
        LeaderElector leaderElector = new LeaderElector(
            new LeaderElectionConfig(
                "leader-election",
                "my-service",
                Duration.ofSeconds(15),
                Duration.ofSeconds(10),
                Duration.ofSeconds(2),
                () -> {
                    // On become leader
                    System.out.println("Became leader");
                },
                () -> {
                    // On stop leading
                    System.out.println("Stopped leading");
                }
            )
        );
        
        leaderElector.start();
    }
}
```

**Best Practices:**
- Use for coordination
- Handle leader changes
- Monitor leader status
- Graceful handover
- Test leader election

---

## 484. How do you implement distributed rate limiting?

**Distributed Rate Limiting:**

1. **Redis-Based**
   - Redis counters
   - Sliding window
   - Distributed state

2. **Token Bucket**
   - Tokens per key
   - Refill rate
   - Distributed bucket

3. **Fixed Window**
   - Window per key
   - Counter per window
   - Reset at boundary

**Example - Redis:**
```java
@Service
public class RateLimitService {
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    public boolean isAllowed(String key, int limit, int windowSeconds) {
        String redisKey = "ratelimit:" + key;
        String current = redisTemplate.opsForValue().get(redisKey);
        
        if (current == null) {
            redisTemplate.opsForValue().set(redisKey, "1", 
                Duration.ofSeconds(windowSeconds));
            return true;
        }
        
        int count = Integer.parseInt(current);
        if (count < limit) {
            redisTemplate.opsForValue().increment(redisKey);
            return true;
        }
        
        return false;
    }
}
```

**Best Practices:**
- Use distributed storage
- Sliding window preferred
- Set appropriate limits
- Monitor rate limits
- Alert on abuse

---

## 485. How do you implement distributed caching?

**Distributed Caching:**

1. **Redis Cluster**
   - Redis cluster
   - Distributed cache
   - High availability

2. **Hazelcast**
   - In-memory grid
   - Distributed cache
   - Java-friendly

3. **Memcached**
   - Distributed cache
   - Simple key-value
   - High performance

**Example - Redis:**
```java
@Service
public class CacheService {
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    public void put(String key, Object value, int ttlSeconds) {
        redisTemplate.opsForValue().set(key, value, 
            Duration.ofSeconds(ttlSeconds));
    }
    
    public Object get(String key) {
        return redisTemplate.opsForValue().get(key);
    }
    
    public void evict(String key) {
        redisTemplate.delete(key);
    }
}
```

**Best Practices:**
- Use distributed cache
- Set TTL
- Handle cache misses
- Monitor cache performance
- Eviction strategy

---

## 486. How do you implement service health checks?

**Health Checks:**

1. **Liveness Probe**
   - Is service running?
   - Restart if failed
   - Simple check

2. **Readiness Probe**
   - Is service ready?
   - Check dependencies
   - Remove from load balancer

3. **Startup Probe**
   - Is service started?
   - For slow-starting
   - Kubernetes feature

**Example:**
```java
@RestController
public class HealthController {
    @Autowired
    private DatabaseHealthIndicator databaseHealth;
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "UP");
        return ResponseEntity.ok(status);
    }
    
    @GetMapping("/ready")
    public ResponseEntity<Map<String, String>> readiness() {
        if (databaseHealth.isHealthy()) {
            return ResponseEntity.ok(Map.of("status", "READY"));
        }
        return ResponseEntity.status(503)
            .body(Map.of("status", "NOT_READY"));
    }
}
```

**Best Practices:**
- Implement both probes
- Check dependencies in readiness
- Fast health checks
- Proper status codes
- Monitor health

---

## 487. How do you implement graceful shutdown in microservices?

**Graceful Shutdown:**

1. **Signal Handling**
   - Handle shutdown signals
   - SIGTERM, SIGINT
   - Graceful stop

2. **Stop Accepting Requests**
   - Remove from load balancer
   - Stop accepting new requests
   - Wait for in-flight

3. **Cleanup**
   - Close connections
   - Save state
   - Cleanup resources

**Example:**
```java
@Component
public class GracefulShutdown implements ApplicationListener<ContextClosedEvent> {
    @Autowired
    private TomcatServletWebServerFactory tomcat;
    
    @Override
    public void onApplicationEvent(ContextClosedEvent event) {
        // Stop accepting new requests
        tomcat.getWebServer().stop();
        
        // Wait for in-flight requests
        try {
            Thread.sleep(30000); // Wait 30 seconds
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        // Cleanup
        cleanup();
    }
    
    private void cleanup() {
        // Close connections
        // Save state
        // Cleanup resources
    }
}
```

**Best Practices:**
- Handle shutdown signals
- Stop accepting requests
- Wait for in-flight
- Cleanup resources
- Test shutdown

---

## 488. How do you implement request correlation in microservices?

**Request Correlation:**

1. **Correlation ID Generation**
   - Generate at entry point
   - Unique identifier
   - Propagate to all services

2. **Propagation**
   - HTTP headers
   - gRPC metadata
   - Message headers

3. **Logging**
   - Include in all logs
   - MDC (Mapped Diagnostic Context)
   - Correlation tracking

**Example:**
```java
@Component
public class CorrelationFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, 
            FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String correlationId = httpRequest.getHeader("X-Correlation-ID");
        
        if (correlationId == null) {
            correlationId = UUID.randomUUID().toString();
        }
        
        MDC.put("correlationId", correlationId);
        ((HttpServletResponse) response).setHeader("X-Correlation-ID", correlationId);
        
        try {
            chain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}
```

**Best Practices:**
- Generate at entry point
- Propagate to all services
- Include in logs
- Use MDC
- Track requests

---

## 489. How do you implement distributed tracing?

**Distributed Tracing:**

1. **Instrumentation**
   - Add tracing libraries
   - Automatic instrumentation
   - Manual spans

2. **Context Propagation**
   - Trace context
   - Span context
   - Headers/metadata

3. **Tracer Configuration**
   - Tracer setup
   - Sampling
   - Exporters

**Example - OpenTelemetry:**
```java
@Configuration
public class TracingConfig {
    @Bean
    public Tracer tracer() {
        return OpenTelemetrySdk.builder()
            .setTracerProvider(
                SdkTracerProvider.builder()
                    .addSpanProcessor(BatchSpanProcessor.builder(
                        OtlpGrpcSpanExporter.builder()
                            .setEndpoint("http://jaeger:4317")
                            .build()
                    ).build())
                    .setResource(Resource.getDefault())
                    .build()
            )
            .build()
            .getTracer("order-service");
    }
}

// Usage
@Service
public class OrderService {
    @Autowired
    private Tracer tracer;
    
    public Order createOrder(OrderRequest request) {
        Span span = tracer.spanBuilder("create-order").startSpan();
        try {
            // Business logic
            return processOrder(request);
        } finally {
            span.end();
        }
    }
}
```

**Best Practices:**
- Use OpenTelemetry
- Automatic instrumentation
- Context propagation
- Sampling configuration
- Monitor tracing

---

## 490. How do you implement circuit breaker pattern?

**Circuit Breaker:**

1. **Choose Library**
   - Resilience4j (Java)
   - Polly (.NET)
   - Hystrix (deprecated)

2. **Configuration**
   - Failure threshold
   - Timeout
   - Fallback

3. **Implementation**
   - Wrap service calls
   - Monitor failures
   - Open/close circuit

**Example - Resilience4j:**
```java
@Service
public class PaymentService {
    private final CircuitBreaker circuitBreaker;
    
    public PaymentService() {
        this.circuitBreaker = CircuitBreaker.of("payment-service",
            CircuitBreakerConfig.custom()
                .failureRateThreshold(50)
                .waitDurationInOpenState(Duration.ofSeconds(60))
                .slidingWindowSize(10)
                .build()
        );
    }
    
    public PaymentResult processPayment(PaymentRequest request) {
        return circuitBreaker.executeSupplier(() -> {
            return paymentGateway.process(request);
        });
    }
    
    @CircuitBreaker(name = "payment-service", fallbackMethod = "fallback")
    public PaymentResult processPaymentAnnotated(PaymentRequest request) {
        return paymentGateway.process(request);
    }
    
    public PaymentResult fallback(PaymentRequest request, Exception e) {
        return PaymentResult.failed("Payment service unavailable");
    }
}
```

**Best Practices:**
- Set appropriate thresholds
- Provide fallbacks
- Monitor circuit state
- Test behavior
- Alert on opens

---

## 491. How do you implement retry pattern with exponential backoff?

**Retry with Exponential Backoff:**

1. **Choose Library**
   - Resilience4j
   - Spring Retry
   - Custom implementation

2. **Configuration**
   - Max attempts
   - Base delay
   - Multiplier
   - Max delay

3. **Implementation**
   - Retry logic
   - Exponential delay
   - Jitter

**Example - Resilience4j:**
```java
@Service
public class OrderService {
    private final Retry retry;
    
    public OrderService() {
        this.retry = Retry.of("order-service",
            RetryConfig.custom()
                .maxAttempts(5)
                .waitDuration(Duration.ofSeconds(1))
                .exponentialBackoff(1, 2, 10, TimeUnit.SECONDS)
                .retryOnException(e -> e instanceof RetryableException)
                .build()
        );
    }
    
    public Order createOrder(OrderRequest request) {
        return retry.executeSupplier(() -> {
            return orderRepository.save(convert(request));
        });
    }
    
    @Retryable(value = {RetryableException.class}, 
               maxAttempts = 5,
               backoff = @Backoff(delay = 1000, multiplier = 2, maxDelay = 10000))
    public Order createOrderAnnotated(OrderRequest request) {
        return orderRepository.save(convert(request));
    }
}
```

**Best Practices:**
- Use exponential backoff
- Add jitter
- Set max attempts
- Retry only transient failures
- Monitor retries

---

## 492. How do you implement saga pattern?

**Saga Pattern:**

1. **Choose Type**
   - Choreography-based
   - Orchestration-based
   - Choose based on needs

2. **Define Steps**
   - Break into steps
   - Each step = local transaction
   - Define compensations

3. **Implementation**
   - Execute steps
   - Handle failures
   - Execute compensations

**Example - Orchestration:**
```java
@Service
public class OrderSagaOrchestrator {
    @Autowired
    private OrderService orderService;
    @Autowired
    private InventoryService inventoryService;
    @Autowired
    private PaymentService paymentService;
    
    public OrderResult processOrder(OrderRequest request) {
        Order order = null;
        try {
            // Step 1: Create Order
            order = orderService.createOrder(request);
            
            // Step 2: Reserve Inventory
            inventoryService.reserveInventory(order.getId(), request.getItems());
            
            // Step 3: Process Payment
            paymentService.processPayment(order.getId(), request.getAmount());
            
            return OrderResult.success(order);
        } catch (InventoryException e) {
            // Compensate: Cancel Order
            if (order != null) {
                orderService.cancelOrder(order.getId());
            }
            return OrderResult.failed("Inventory reservation failed");
        } catch (PaymentException e) {
            // Compensate: Release Inventory, Cancel Order
            if (order != null) {
                inventoryService.releaseInventory(order.getId());
                orderService.cancelOrder(order.getId());
            }
            return OrderResult.failed("Payment processing failed");
        }
    }
}
```

**Best Practices:**
- Define steps clearly
- Implement compensations
- Make idempotent
- Handle failures
- Monitor sagas

---

## 493. How do you implement event sourcing?

**Event Sourcing:**

1. **Event Store**
   - Choose event store
   - Append-only log
   - Event storage

2. **Event Publishing**
   - Publish events
   - Event handlers
   - Event processing

3. **State Reconstruction**
   - Replay events
   - Build state
   - Snapshots

**Example:**
```java
@Service
public class OrderService {
    @Autowired
    private EventStore eventStore;
    
    public void createOrder(OrderRequest request) {
        OrderCreatedEvent event = new OrderCreatedEvent(
            UUID.randomUUID().toString(),
            request.getUserId(),
            request.getItems(),
            request.getAmount()
        );
        
        // Store event
        eventStore.append("order", event.getOrderId(), event);
        
        // Publish event
        eventPublisher.publish(event);
    }
    
    public Order getOrder(String orderId) {
        // Replay events to build state
        List<Event> events = eventStore.getEvents("order", orderId);
        Order order = new Order();
        
        for (Event event : events) {
            order.apply(event);
        }
        
        return order;
    }
}
```

**Best Practices:**
- Use event store
- Publish events
- Replay for state
- Use snapshots
- Monitor event store

---

## 494. How do you implement CQRS pattern?

**CQRS Implementation:**

1. **Separate Models**
   - Command model
   - Query model
   - Different databases (optional)

2. **Command Side**
   - Handle writes
   - Domain model
   - Publish events

3. **Query Side**
   - Handle reads
   - Denormalized views
   - Optimized queries

4. **Event Sync**
   - Events sync read models
   - Eventually consistent
   - Async updates

**Example:**
```java
// Command Side
@Service
public class OrderCommandService {
    @Autowired
    private OrderRepository orderRepository;
    @Autowired
    private EventPublisher eventPublisher;
    
    public void createOrder(OrderRequest request) {
        Order order = new Order(request);
        orderRepository.save(order);
        
        // Publish event
        eventPublisher.publish(new OrderCreatedEvent(order));
    }
}

// Query Side
@Service
public class OrderQueryService {
    @Autowired
    private OrderReadRepository readRepository;
    
    public OrderView getOrder(String orderId) {
        return readRepository.findById(orderId);
    }
    
    public List<OrderView> searchOrders(OrderSearchCriteria criteria) {
        return readRepository.search(criteria);
    }
}

// Event Handler - Syncs read model
@EventListener
public class OrderEventHandler {
    @Autowired
    private OrderReadRepository readRepository;
    
    @EventListener
    public void handle(OrderCreatedEvent event) {
        OrderView view = convertToView(event);
        readRepository.save(view);
    }
}
```

**Best Practices:**
- Separate read/write models
- Optimize each
- Sync via events
- Accept eventual consistency
- Monitor sync lag

---

## 495. How do you implement API versioning?

**API Versioning:**

1. **URL Versioning**
   - `/api/v1/users`
   - `/api/v2/users`
   - Simple and explicit

2. **Header Versioning**
   - `Accept: application/vnd.api.v1+json`
   - Keeps URLs clean
   - More RESTful

3. **Implementation**
   - Version in routing
   - Support multiple versions
   - Deprecation strategy

**Example:**
```java
@RestController
@RequestMapping("/api/v1")
public class UserControllerV1 {
    @GetMapping("/users/{id}")
    public UserV1 getUser(@PathVariable String id) {
        return userService.getUser(id);
    }
}

@RestController
@RequestMapping("/api/v2")
public class UserControllerV2 {
    @GetMapping("/users/{id}")
    public UserV2 getUser(@PathVariable String id) {
        return userService.getUser(id);
    }
}

// Header-based
@RestController
@RequestMapping("/api/users")
public class UserController {
    @GetMapping(value = "/{id}", 
                produces = {"application/vnd.api.v1+json", 
                           "application/vnd.api.v2+json"})
    public ResponseEntity<?> getUser(@PathVariable String id,
                                     @RequestHeader("Accept") String accept) {
        if (accept.contains("v2")) {
            return ResponseEntity.ok(userService.getUserV2(id));
        }
        return ResponseEntity.ok(userService.getUserV1(id));
    }
}
```

**Best Practices:**
- Support multiple versions
- Clear deprecation policy
- Backward compatibility
- Version in response
- Monitor version usage

---

## 496. How do you implement service discovery?

**Service Discovery:**

1. **Choose Tool**
   - Eureka, Consul
   - Kubernetes Services
   - Choose based on needs

2. **Service Registration**
   - Register on startup
   - Health checks
   - Metadata

3. **Service Lookup**
   - Query registry
   - Get instances
   - Load balancing

**Example - Eureka:**
```java
@SpringBootApplication
@EnableEurekaClient
public class OrderServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}

// Service lookup
@Service
public class PaymentServiceClient {
    @Autowired
    private DiscoveryClient discoveryClient;
    @Autowired
    private RestTemplate restTemplate;
    
    public PaymentResult processPayment(PaymentRequest request) {
        List<ServiceInstance> instances = 
            discoveryClient.getInstances("payment-service");
        
        ServiceInstance instance = instances.get(0); // Load balance
        String url = "http://" + instance.getHost() + ":" + 
                     instance.getPort() + "/api/payments";
        
        return restTemplate.postForObject(url, request, PaymentResult.class);
    }
}
```

**Best Practices:**
- Use service discovery
- Health checks
- Client-side caching
- Monitor registry
- High availability

---

## 497. How do you implement load balancing?

**Load Balancing:**

1. **Client-Side**
   - Client selects instance
   - Round-robin, random
   - Client implementation

2. **Server-Side**
   - Load balancer selects
   - Centralized
   - Infrastructure

3. **Algorithms**
   - Round-robin
   - Least connections
   - IP hash

**Example - Client-Side:**
```java
@Service
public class LoadBalancer {
    private final List<ServiceInstance> instances;
    private int currentIndex = 0;
    
    public ServiceInstance getNextInstance() {
        if (instances.isEmpty()) {
            throw new NoInstanceAvailableException();
        }
        
        ServiceInstance instance = instances.get(currentIndex);
        currentIndex = (currentIndex + 1) % instances.size();
        return instance;
    }
    
    public ServiceInstance getLeastLoadedInstance() {
        return instances.stream()
            .min(Comparator.comparing(this::getActiveConnections))
            .orElseThrow(NoInstanceAvailableException::new);
    }
}
```

**Best Practices:**
- Use load balancing
- Health-based routing
- Appropriate algorithm
- Monitor load
- Test balancing

---

## 498. How do you implement service mesh?

**Service Mesh:**

1. **Choose Mesh**
   - Istio, Linkerd
   - Consul Connect
   - Choose based on needs

2. **Install**
   - Install control plane
   - Inject sidecars
   - Configure

3. **Configure**
   - Traffic policies
   - Security policies
   - Observability

**Example - Istio:**
```yaml
# Enable sidecar injection
apiVersion: v1
kind: Namespace
metadata:
  name: microservices
  labels:
    istio-injection: enabled

# VirtualService - routing
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
        subset: v1
      weight: 90
    - destination:
        host: order-service
        subset: v2
      weight: 10

# DestinationRule - load balancing
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: order-service
spec:
  host: order-service
  subsets:
  - name: v1
    labels:
      version: v1
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN

# PeerAuthentication - mTLS
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

**Best Practices:**
- Start simple
- Gradual adoption
- Configure policies
- Monitor mesh
- Document configuration

---

## 499. How do you implement API Gateway?

**API Gateway:**

1. **Choose Gateway**
   - Kong, AWS API Gateway
   - Spring Cloud Gateway
   - Choose based on needs

2. **Configure Routing**
   - Route to services
   - Path-based routing
   - Load balancing

3. **Add Features**
   - Authentication
   - Rate limiting
   - Monitoring

**Example - Kong:**
```yaml
# Service
services:
  - name: order-service
    url: http://order-service:8080
    routes:
      - name: order-route
        paths:
          - /api/orders
        methods:
          - GET
          - POST
    plugins:
      - name: jwt
      - name: rate-limiting
        config:
          minute: 100
          hour: 1000
      - name: cors
        config:
          origins:
            - "*"
          methods:
            - GET
            - POST
          headers:
            - Accept
            - Authorization
```

**Example - Spring Cloud Gateway:**
```java
@Configuration
public class GatewayConfig {
    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("order-service", r -> r
                .path("/api/orders/**")
                .filters(f -> f
                    .addRequestHeader("X-Request-Id", UUID.randomUUID().toString())
                    .circuitBreaker(config -> config
                        .setName("order-service")
                        .setFallbackUri("forward:/fallback"))
                )
                .uri("http://order-service:8080"))
            .build();
    }
}
```

**Best Practices:**
- Single gateway for external
- Handle cross-cutting concerns
- Don't put business logic
- Monitor gateway
- Version APIs

---

## 500. How do you implement distributed configuration management?

**Distributed Configuration:**

1. **Configuration Service**
   - Spring Cloud Config
   - Consul
   - etcd

2. **Configuration Storage**
   - Git repository
   - Database
   - Key-value store

3. **Client Implementation**
   - Fetch configuration
   - Refresh mechanism
   - Fallback

**Example - Spring Cloud Config:**
```java
// Config Server
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}

// Config Client
@SpringBootApplication
@EnableConfigClient
public class OrderServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}

// Usage
@RestController
@RefreshScope
public class ConfigController {
    @Value("${app.feature.enabled:false}")
    private boolean featureEnabled;
    
    @GetMapping("/config")
    public Map<String, Object> getConfig() {
        return Map.of("featureEnabled", featureEnabled);
    }
}
```

**Best Practices:**
- Externalize configuration
- Environment-specific
- Secure secrets
- Version control
- Dynamic refresh
- Fallback values

