# Microservices Interview Answers - Performance & Optimization (Questions 321-340)

## 321. How do you optimize performance in microservices?

**Performance Optimization:**

1. **Caching**
   - Response caching
   - Database caching
   - CDN for static content

2. **Database Optimization**
   - Query optimization
   - Indexing
   - Connection pooling

3. **Async Communication**
   - Async messaging
   - Event-driven
   - Non-blocking

4. **Load Balancing**
   - Distribute load
   - Health-based routing
   - Geographic distribution

5. **Compression**
   - Response compression
   - gzip, brotli
   - Reduce payload

**Best Practices:**
- Implement caching
- Optimize databases
- Use async when possible
- Load balancing
- Compression
- Monitor performance

---

## 322. What is the difference between synchronous and asynchronous communication performance?

**Synchronous:**
- **Latency**: Higher (waiting)
- **Throughput**: Lower (blocking)
- **Resource**: Blocked threads
- **Use Case**: Immediate response needed

**Asynchronous:**
- **Latency**: Lower (non-blocking)
- **Throughput**: Higher (parallel)
- **Resource**: Efficient
- **Use Case**: Can tolerate delay

**Comparison:**

| Aspect | Synchronous | Asynchronous |
|--------|-------------|--------------|
| **Latency** | Higher | Lower |
| **Throughput** | Lower | Higher |
| **Resource** | Blocked | Efficient |
| **Use Case** | Immediate | Can delay |

**Best Practices:**
- Use async for performance
- Sync for immediate response
- Balance based on needs
- Monitor performance

---

## 323. How do you handle caching in microservices?

**Caching Strategies:**

1. **Response Caching**
   - Cache API responses
   - API Gateway caching
   - Reduce backend load

2. **Database Caching**
   - Cache queries
   - Redis, Memcached
   - Reduce database load

3. **CDN**
   - Static content
   - Geographic distribution
   - Edge caching

4. **Cache-Aside**
   - Check cache first
   - Load from DB if miss
   - Update cache

**Best Practices:**
- Implement caching
- Cache at multiple levels
- Set appropriate TTL
- Cache invalidation
- Monitor cache hit rates

---

## 324. What is the difference between distributed cache and local cache?

**Distributed Cache:**
- **Location**: Shared across services
- **Consistency**: Shared state
- **Scalability**: Scales with cluster
- **Examples**: Redis, Memcached

**Local Cache:**
- **Location**: In-process
- **Consistency**: Per service
- **Scalability**: Per instance
- **Examples**: In-memory cache

**Comparison:**

| Aspect | Distributed | Local |
|--------|-------------|-------|
| **Location** | Shared | In-process |
| **Consistency** | Shared | Per service |
| **Scalability** | Cluster | Instance |

**Best Practices:**
- Distributed for shared data
- Local for service-specific
- Combine both
- Choose based on needs

---

## 325. How do you implement caching strategies in microservices?

**Caching Strategies:**

1. **Cache-Aside**
   - Check cache
   - Load from DB if miss
   - Update cache

2. **Write-Through**
   - Write to cache and DB
   - Always consistent
   - Higher write latency

3. **Write-Behind**
   - Write to cache
   - Async write to DB
   - Lower write latency

4. **Refresh-Ahead**
   - Prefetch before expiry
   - Always fresh
   - Higher load

**Best Practices:**
- Cache-aside for reads
- Write-through for consistency
- Write-behind for performance
- Choose based on needs
- Monitor cache performance

---

## 326. What is the difference between cache-aside and write-through cache?

**Cache-Aside:**
- **Read**: Check cache → DB if miss → Update cache
- **Write**: Write to DB → Invalidate cache
- **Consistency**: Eventually consistent
- **Performance**: Good for reads

**Write-Through:**
- **Read**: Check cache → DB if miss
- **Write**: Write to cache and DB
- **Consistency**: Always consistent
- **Performance**: Higher write latency

**Comparison:**

| Aspect | Cache-Aside | Write-Through |
|--------|-------------|---------------|
| **Consistency** | Eventually | Always |
| **Write Latency** | Lower | Higher |
| **Complexity** | Lower | Higher |

**Best Practices:**
- Cache-aside for most cases
- Write-through for critical data
- Choose based on needs
- Monitor consistency

---

## 327. How do you handle cache invalidation in microservices?

**Cache Invalidation:**

1. **Time-Based**
   - TTL (Time To Live)
   - Automatic expiry
   - Simple

2. **Event-Based**
   - Invalidate on events
   - Data change events
   - More accurate

3. **Manual**
   - Explicit invalidation
   - API calls
   - Full control

4. **Versioning**
   - Cache keys with versions
   - Version updates invalidate
   - Pattern-based

**Best Practices:**
- Use TTL for safety
- Event-based for accuracy
- Monitor invalidation
- Test invalidation logic
- Document strategy

---

## 328. What is the difference between cache invalidation and cache expiration?

**Cache Invalidation:**
- **Type**: Explicit removal
- **Trigger**: Manual or event
- **Control**: Full control
- **Use Case**: Data changed

**Cache Expiration:**
- **Type**: Automatic removal
- **Trigger**: Time-based (TTL)
- **Control**: Time-based
- **Use Case**: Time-based freshness

**Comparison:**

| Aspect | Invalidation | Expiration |
|--------|--------------|------------|
| **Type** | Explicit | Automatic |
| **Trigger** | Manual/event | Time |
| **Control** | Full | Time-based |

**Best Practices:**
- Use expiration for safety
- Use invalidation for accuracy
- Combine both
- Monitor cache behavior

---

## 329. How do you optimize database queries in microservices?

**Database Optimization:**

1. **Indexing**
   - Proper indexes
   - Query optimization
   - Performance improvement

2. **Query Optimization**
   - Efficient queries
   - Avoid N+1
   - Use joins appropriately

3. **Connection Pooling**
   - Reuse connections
   - Reduce overhead
   - Better performance

4. **Read Replicas**
   - Scale reads
   - Reduce load on master
   - Geographic distribution

**Best Practices:**
- Proper indexing
- Optimize queries
- Connection pooling
- Read replicas
- Monitor query performance

---

## 330. What is the difference between database connection pooling and connection per request?

**Connection Pooling:**
- **Approach**: Reuse connections
- **Performance**: Better
- **Resource**: Efficient
- **Use Case**: Production

**Connection Per Request:**
- **Approach**: New connection per request
- **Performance**: Lower
- **Resource**: Inefficient
- **Use Case**: Not recommended

**Comparison:**

| Aspect | Pooling | Per Request |
|--------|---------|-------------|
| **Performance** | Better | Lower |
| **Resource** | Efficient | Inefficient |
| **Use Case** | Production | Not recommended |

**Best Practices:**
- Always use connection pooling
- Configure pool size
- Monitor pool usage
- Avoid per-request connections

---

## 331. How do you handle connection pooling in microservices?

**Connection Pooling:**

1. **Configure Pool Size**
   - Min connections
   - Max connections
   - Based on load

2. **Pool Management**
   - Connection timeout
   - Idle timeout
   - Health checks

3. **Monitoring**
   - Pool usage
   - Connection wait time
   - Pool exhaustion alerts

**Configuration:**
```properties
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000
```

**Best Practices:**
- Configure appropriately
- Monitor pool usage
- Alert on exhaustion
- Test pool behavior
- Document configuration

---

## 332. What is the difference between connection pooling and connection multiplexing?

**Connection Pooling:**
- **Approach**: Reuse connections
- **Scope**: Per service
- **Use Case**: Traditional

**Connection Multiplexing:**
- **Approach**: Share connections
- **Scope**: Across requests
- **Use Case**: HTTP/2, gRPC

**Comparison:**

| Aspect | Pooling | Multiplexing |
|--------|---------|--------------|
| **Approach** | Reuse | Share |
| **Scope** | Per service | Across requests |
| **Protocol** | HTTP/1.1 | HTTP/2, gRPC |

**Best Practices:**
- Use pooling for HTTP/1.1
- Use multiplexing for HTTP/2/gRPC
- Choose based on protocol
- Monitor connection usage

---

## 333. How do you optimize network communication in microservices?

**Network Optimization:**

1. **Protocol Choice**
   - HTTP/2 for multiplexing
   - gRPC for performance
   - Choose based on needs

2. **Compression**
   - Response compression
   - gzip, brotli
   - Reduce payload

3. **Connection Reuse**
   - HTTP keep-alive
   - Connection pooling
   - Reduce overhead

4. **Batch Operations**
   - Batch requests
   - Reduce round trips
   - More efficient

**Best Practices:**
- Use HTTP/2 or gRPC
- Enable compression
- Connection reuse
- Batch when possible
- Monitor network performance

---

## 334. What is the difference between HTTP/1.1 and HTTP/2 in microservices?

**HTTP/1.1:**
- **Multiplexing**: No
- **Headers**: Uncompressed
- **Performance**: Lower
- **Use Case**: Legacy

**HTTP/2:**
- **Multiplexing**: Yes
- **Headers**: Compressed
- **Performance**: Higher
- **Use Case**: Modern

**Comparison:**

| Aspect | HTTP/1.1 | HTTP/2 |
|--------|----------|--------|
| **Multiplexing** | No | Yes |
| **Headers** | Uncompressed | Compressed |
| **Performance** | Lower | Higher |

**Best Practices:**
- Use HTTP/2 when possible
- Better performance
- Multiplexing benefits
- Modern standard

---

## 335. How do you handle compression in microservices?

**Compression:**

1. **Response Compression**
   - gzip, brotli
   - API Gateway
   - Reduce payload

2. **Configuration**
   - Enable compression
   - Choose algorithm
   - Set threshold

3. **Monitoring**
   - Compression ratio
   - CPU usage
   - Performance impact

**Configuration:**
```yaml
server:
  compression:
    enabled: true
    mime-types: application/json,application/xml
    min-response-size: 1024
```

**Best Practices:**
- Enable compression
- Use brotli when supported
- Monitor performance
- Set appropriate threshold
- Test compression impact

---

## 336. What is the difference between gzip and brotli compression?

**gzip:**
- **Algorithm**: DEFLATE
- **Compression**: Good
- **CPU**: Lower
- **Support**: Universal

**brotli:**
- **Algorithm**: Brotli
- **Compression**: Better
- **CPU**: Higher
- **Support**: Modern browsers

**Comparison:**

| Aspect | gzip | brotli |
|--------|------|--------|
| **Compression** | Good | Better |
| **CPU** | Lower | Higher |
| **Support** | Universal | Modern |

**Best Practices:**
- Use brotli when supported
- Fallback to gzip
- Monitor performance
- Choose based on support

---

## 337. How do you optimize serialization in microservices?

**Serialization Optimization:**

1. **Format Choice**
   - JSON: Human-readable
   - Protocol Buffers: Binary, faster
   - Choose based on needs

2. **Schema Evolution**
   - Versioned schemas
   - Backward compatibility
   - Efficient updates

3. **Library Optimization**
   - Efficient libraries
   - Native serialization
   - Performance tuning

**Best Practices:**
- Use Protocol Buffers for performance
- JSON for compatibility
- Optimize serialization
- Monitor performance
- Choose based on needs

---

## 338. What is the difference between JSON and Protocol Buffers?

**JSON:**
- **Format**: Text-based
- **Size**: Larger
- **Performance**: Slower
- **Human-readable**: Yes
- **Use Case**: APIs, web

**Protocol Buffers:**
- **Format**: Binary
- **Size**: Smaller
- **Performance**: Faster
- **Human-readable**: No
- **Use Case**: Internal services

**Comparison:**

| Aspect | JSON | Protocol Buffers |
|--------|------|------------------|
| **Format** | Text | Binary |
| **Size** | Larger | Smaller |
| **Performance** | Slower | Faster |
| **Readable** | Yes | No |

**Best Practices:**
- JSON for external APIs
- Protocol Buffers for internal
- Choose based on needs
- Performance vs readability

---

## 339. How do you handle batch processing in microservices?

**Batch Processing:**

1. **Batch API**
   - Accept batch requests
   - Process together
   - Return batch response

2. **Queue-Based**
   - Queue batches
   - Process asynchronously
   - Better throughput

3. **Optimization**
   - Reduce overhead
   - Efficient processing
   - Parallel processing

**Best Practices:**
- Batch when possible
- Queue-based processing
- Optimize batch size
- Monitor performance
- Handle failures

---

## 340. What is the difference between batch processing and stream processing?

**Batch Processing:**
- **Approach**: Process in batches
- **Latency**: Higher
- **Throughput**: High
- **Use Case**: Bulk operations

**Stream Processing:**
- **Approach**: Process continuously
- **Latency**: Lower
- **Throughput**: High
- **Use Case**: Real-time

**Comparison:**

| Aspect | Batch | Stream |
|--------|-------|--------|
| **Latency** | Higher | Lower |
| **Approach** | Batches | Continuous |
| **Use Case** | Bulk | Real-time |

**Best Practices:**
- Batch for bulk operations
- Stream for real-time
- Choose based on needs
- Monitor performance

