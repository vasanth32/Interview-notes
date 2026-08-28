# Microservices Interview Answers - Monitoring & Observability Part 2 (Questions 141-145)

## 141. How do you implement error tracking in microservices?

**Error Tracking** captures, aggregates, and analyzes errors across microservices.

**Implementation:**

1. **Error Collection**
   - Capture exceptions
   - Log errors
   - Send to error tracking service

2. **Error Aggregation**
   - Group similar errors
   - Deduplication
   - Pattern recognition

3. **Error Analysis**
   - Stack traces
   - Context information
   - Frequency analysis

**Tools:**
- Sentry
- Rollbar
- Bugsnag
- Datadog Error Tracking

**Implementation:**

**Sentry Integration:**
```java
@Configuration
public class SentryConfig {
    @PostConstruct
    public void init() {
        Sentry.init(options -> {
            options.setDsn("your-sentry-dsn");
            options.setEnvironment("production");
        });
    }
}

// Usage
try {
    // Code
} catch (Exception e) {
    Sentry.captureException(e);
    throw e;
}
```

**Best Practices:**
- Capture all exceptions
- Include context
- Correlation IDs
- Alert on new errors
- Regular analysis

---

## 142. What is the difference between errors and exceptions in monitoring?

**Errors:**
- **Type**: Application errors
- **Severity**: Can be handled
- **Example**: Validation errors, business logic errors
- **Monitoring**: Track error rates

**Exceptions:**
- **Type**: Runtime exceptions
- **Severity**: Unhandled
- **Example**: NullPointerException, IOException
- **Monitoring**: Track exception rates

**Key Differences:**

| Aspect | Errors | Exceptions |
|--------|--------|------------|
| **Handling** | Expected, handled | Unexpected, unhandled |
| **Severity** | Lower | Higher |
| **Example** | Validation error | NullPointerException |
| **Monitoring** | Error rate | Exception rate |

**In Monitoring:**
- Track both separately
- Different alert thresholds
- Error: Business logic
- Exception: Technical issues

**Best Practices:**
- Distinguish errors and exceptions
- Track separately
- Different alerting
- Handle appropriately
- Monitor both

---

## 143. How do you track performance bottlenecks in microservices?

**Performance Bottleneck Tracking:**

1. **Distributed Tracing**
   - Trace request flow
   - Identify slow services
   - Latency per service

2. **APM Tools**
   - Code-level performance
   - Method-level timing
   - Database query analysis

3. **Metrics Analysis**
   - Response time metrics
   - P95, P99 latencies
   - Percentile analysis

4. **Profiling**
   - CPU profiling
   - Memory profiling
   - Identify hotspots

**Tools:**
- Jaeger/Zipkin (tracing)
- New Relic/Datadog (APM)
- Prometheus (metrics)
- Profiling tools

**Implementation:**

**Tracing:**
```java
Span span = tracer.nextSpan()
    .name("process-order")
    .start();
try {
    // Business logic
    processOrder(order);
} finally {
    span.tag("duration", System.currentTimeMillis() - start);
    span.end();
}
```

**Best Practices:**
- Use distributed tracing
- Monitor percentiles
- Profile regularly
- Set performance baselines
- Alert on degradation

---

## 144. What is the difference between latency and throughput?

**Latency:**
- **Definition**: Time to complete request
- **Unit**: Milliseconds, seconds
- **Focus**: Individual request time
- **Example**: 100ms response time

**Throughput:**
- **Definition**: Requests processed per unit time
- **Unit**: Requests per second
- **Focus**: Volume of work
- **Example**: 1000 requests/second

**Key Differences:**

| Aspect | Latency | Throughput |
|--------|---------|------------|
| **Measure** | Time | Volume |
| **Unit** | ms, s | req/s, ops/s |
| **Focus** | Speed | Capacity |
| **Optimization** | Reduce time | Increase volume |

**Relationship:**
- Lower latency → Higher throughput (usually)
- But not always
- Can optimize independently

**In Microservices:**
- Monitor both
- Latency: User experience
- Throughput: System capacity
- Balance both

**Best Practices:**
- Track both metrics
- Optimize based on needs
- Set targets for both
- Monitor trends

---

## 145. How do you implement custom metrics in microservices?

**Custom Metrics** are application-specific metrics beyond standard system metrics.

**Types:**

1. **Business Metrics**
   - Orders per minute
   - Revenue
   - User signups

2. **Application Metrics**
   - Cache hit rate
   - Queue depth
   - Processing time

**Implementation:**

**Prometheus:**
```java
@Component
public class OrderMetrics {
    private final Counter ordersCreated;
    private final Histogram orderProcessingTime;
    
    public OrderMetrics(MeterRegistry registry) {
        ordersCreated = Counter.builder("orders.created")
            .description("Total orders created")
            .register(registry);
            
        orderProcessingTime = Histogram.builder("orders.processing.time")
            .description("Order processing time")
            .register(registry);
    }
    
    public void recordOrderCreated() {
        ordersCreated.increment();
    }
    
    public void recordProcessingTime(double seconds) {
        orderProcessingTime.observe(seconds);
    }
}
```

**Micrometer:**
```java
@RestController
public class OrderController {
    @Autowired
    private MeterRegistry registry;
    
    @PostMapping("/orders")
    public Order createOrder(@RequestBody Order order) {
        Timer.Sample sample = Timer.start(registry);
        try {
            Order created = orderService.create(order);
            registry.counter("orders.created", "status", "success").increment();
            return created;
        } catch (Exception e) {
            registry.counter("orders.created", "status", "error").increment();
            throw e;
        } finally {
            sample.stop(registry.timer("orders.processing.time"));
        }
    }
}
```

**Best Practices:**
- Define meaningful metrics
- Use appropriate types
- Label properly
- Document metrics
- Monitor custom metrics
- Set up alerts

