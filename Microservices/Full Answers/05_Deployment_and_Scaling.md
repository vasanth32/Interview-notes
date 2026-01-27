# Microservices Interview Answers - Deployment & Scaling (Questions 81-100)

## 81. What are the different deployment strategies for microservices?

**Deployment Strategies:**

1. **Blue-Green Deployment**
   - Two identical environments
   - Switch traffic instantly
   - Zero downtime
   - Quick rollback

2. **Canary Deployment**
   - Gradual rollout
   - Small percentage first
   - Monitor and expand
   - Risk mitigation

3. **Rolling Deployment**
   - Update instances gradually
   - One at a time or in batches
   - Continuous availability
   - Slower than blue-green

4. **Recreate Deployment**
   - Stop all instances
   - Deploy new version
   - Start new instances
   - Downtime involved

5. **A/B Testing**
   - Multiple versions running
   - Route traffic by criteria
   - Compare performance
   - Data-driven decisions

**Selection Criteria:**
- Downtime tolerance
- Risk tolerance
- Rollback speed needed
- Infrastructure capabilities
- Team expertise

---

## 82. What is blue-green deployment?

**Blue-Green Deployment** maintains two identical production environments (blue and green). One runs current version, other runs new version. Switch traffic instantly.

**How It Works:**

1. **Two Environments**
   - Blue: Current production
   - Green: New version

2. **Deployment Process**
   - Deploy new version to green
   - Test green environment
   - Switch traffic to green
   - Blue becomes standby

3. **Rollback**
   - Switch back to blue
   - Instant rollback
   - No redeployment needed

**Benefits:**
- Zero downtime
- Instant rollback
- Easy testing
- Low risk

**Challenges:**
- Double infrastructure cost
- Database migration complexity
- State management
- Resource requirements

**Use When:**
- Zero downtime critical
- Quick rollback needed
- Can afford double infrastructure
- Simple deployments

**Example:**
```
1. Blue running v1.0 (production traffic)
2. Deploy v2.0 to Green
3. Test Green
4. Switch load balancer to Green
5. Green now production, Blue standby
```

---

## 83. What is canary deployment?

**Canary Deployment** gradually rolls out new version to a small subset of users before full deployment. Named after canary birds used in mines.

**How It Works:**

1. **Small Rollout**
   - Deploy to small percentage (e.g., 5%)
   - Monitor metrics
   - Check for issues

2. **Gradual Expansion**
   - If successful, increase percentage
   - 5% → 25% → 50% → 100%
   - Monitor at each stage

3. **Rollback**
   - If issues detected, rollback
   - Only affects small percentage
   - Quick recovery

**Benefits:**
- Risk mitigation
- Early problem detection
- Gradual rollout
- Real user testing

**Challenges:**
- Monitoring complexity
- Traffic routing complexity
- Feature flag management
- Metrics analysis

**Use When:**
- High-risk changes
- Large user base
- Need gradual rollout
- Can monitor metrics

**Example:**
```
1. Deploy v2.0 to 5% of traffic
2. Monitor error rates, latency
3. If OK, increase to 25%
4. Continue monitoring
5. Gradually reach 100%
```

---

## 84. What is rolling deployment?

**Rolling Deployment** updates instances gradually, one or a few at a time, while keeping service available.

**How It Works:**

1. **Gradual Update**
   - Update instance 1
   - Wait for health check
   - Update instance 2
   - Continue until all updated

2. **Continuous Availability**
   - Service remains available
   - Some instances old, some new
   - Gradual transition

3. **Rollback**
   - Stop updating
   - Rollback updated instances
   - More complex than blue-green

**Benefits:**
- No downtime
- No double infrastructure
- Resource efficient
- Continuous availability

**Challenges:**
- Slower than blue-green
- Version mixing during rollout
- Complex rollback
- Compatibility between versions

**Use When:**
- Resource constraints
- Can tolerate gradual rollout
- Backward compatible changes
- Kubernetes default

**Example:**
```
Instances: [v1, v1, v1, v1]
Update 1:  [v2, v1, v1, v1]
Update 2:  [v2, v2, v1, v1]
Update 3:  [v2, v2, v2, v1]
Update 4:  [v2, v2, v2, v2]
```

---

## 85. What is the difference between blue-green and canary deployment?

| Aspect | Blue-Green | Canary |
|--------|-------------|--------|
| **Traffic Split** | 100% switch | Gradual (5% → 100%) |
| **Infrastructure** | Double (2x) | Single (1x) |
| **Rollout Speed** | Instant | Gradual |
| **Risk** | Lower (tested before switch) | Higher (real users test) |
| **Rollback** | Instant | Gradual |
| **Cost** | Higher (2x infrastructure) | Lower (1x infrastructure) |
| **Use Case** | Zero downtime, quick rollback | Risk mitigation, gradual |

**Blue-Green:**
- Instant switch
- Tested before production
- Double infrastructure
- Quick rollback

**Canary:**
- Gradual rollout
- Real users test
- Single infrastructure
- Risk mitigation

**Choose Blue-Green when:**
- Zero downtime critical
- Quick rollback needed
- Can afford double infrastructure
- Changes tested thoroughly

**Choose Canary when:**
- High-risk changes
- Large user base
- Need gradual validation
- Resource constraints

---

## 86. How do you handle database migrations during deployment?

**Challenges:**
- Schema changes
- Data migration
- Zero downtime
- Rollback capability

**Strategies:**

1. **Backward Compatible Changes**
   - Add columns (nullable)
   - Don't remove immediately
   - Gradual migration

2. **Dual Write Pattern**
   - Write to old and new format
   - Migrate data in background
   - Switch reads gradually
   - Remove old format

3. **Expand-Contract Pattern**
   - Expand: Add new structure
   - Migrate data
   - Contract: Remove old structure

4. **Versioned Migrations**
   - Version migration scripts
   - Tested migrations
   - Rollback scripts
   - Idempotent migrations

5. **Feature Flags**
   - Deploy code with flags
   - Enable gradually
   - Rollback via flags

**Best Practices:**
- Backward compatible changes
- Test migrations
- Idempotent migrations
- Rollback plan
- Monitor closely
- Gradual migration

**Example:**
```
1. Add new column (nullable) - backward compatible
2. Deploy code that writes both
3. Migrate existing data
4. Deploy code that reads new
5. Remove old column (after all reads switched)
```

---

## 87. What is containerization and how does it help microservices?

**Containerization** packages applications with dependencies into containers that run consistently across environments.

**How It Helps Microservices:**

1. **Consistency**
   - Same environment everywhere
   - Dev, test, production
   - No "works on my machine"

2. **Isolation**
   - Each service isolated
   - Independent dependencies
   - No conflicts

3. **Portability**
   - Run anywhere
   - Cloud, on-premise
   - Easy migration

4. **Scalability**
   - Easy to scale
   - Spin up new instances
   - Resource efficient

5. **Deployment**
   - Consistent deployments
   - Version control
   - Rollback capability

6. **Resource Efficiency**
   - Share OS kernel
   - Less overhead than VMs
   - Better utilization

**Benefits:**
- Consistency
- Isolation
- Portability
- Scalability
- Faster deployments
- Resource efficiency

**Tools:**
- Docker (containers)
- Kubernetes (orchestration)
- Docker Compose (local)

---

## 88. What is the difference between Docker and Kubernetes?

| Aspect | Docker | Kubernetes |
|--------|--------|------------|
| **Purpose** | Container runtime | Container orchestration |
| **Scope** | Single host | Cluster of hosts |
| **Function** | Build, run containers | Manage containers at scale |
| **Scaling** | Manual | Automatic |
| **Networking** | Basic | Advanced |
| **Load Balancing** | Basic | Built-in |
| **Self-Healing** | No | Yes |
| **Use Case** | Development, single host | Production, clusters |

**Docker:**
- Container runtime
- Build and run containers
- Single host
- Development tool
- Simple use cases

**Kubernetes:**
- Container orchestration
- Manages containers at scale
- Cluster management
- Production platform
- Complex deployments

**Relationship:**
- Kubernetes uses Docker (or other runtimes)
- Docker creates containers
- Kubernetes manages them
- Complementary technologies

**Use Docker for:**
- Development
- Simple deployments
- Single host
- Learning containers

**Use Kubernetes for:**
- Production
- Large scale
- Multi-host
- Complex orchestration

---

## 89. What is Kubernetes and why is it used for microservices?

**Kubernetes** is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications.

**Why Used for Microservices:**

1. **Service Management**
   - Deploy services easily
   - Manage service lifecycle
   - Health checks
   - Self-healing

2. **Scaling**
   - Auto-scaling
   - Horizontal scaling
   - Based on metrics
   - Resource optimization

3. **Service Discovery**
   - Built-in service discovery
   - DNS-based
   - Automatic
   - No external tools needed

4. **Load Balancing**
   - Built-in load balancing
   - Distribute traffic
   - Health-based routing

5. **Rolling Updates**
   - Rolling deployments
   - Zero downtime
   - Rollback capability
   - Gradual updates

6. **Resource Management**
   - CPU/memory limits
   - Resource quotas
   - Efficient utilization

7. **Networking**
   - Service networking
   - Network policies
   - Isolation

**Benefits:**
- Production-ready
- Scalability
- Reliability
- Automation
- Ecosystem
- Cloud-native

**Perfect for Microservices:**
- Manages many services
- Independent scaling
- Service discovery
- Health management
- Deployment automation

---

## 90. What are Kubernetes pods, services, and deployments?

**Pod:**
- Smallest deployable unit
- One or more containers
- Shared network/storage
- Ephemeral (can be recreated)
- Example: One pod = one microservice instance

**Service:**
- Stable network endpoint
- Abstracts pod IPs
- Load balancing
- Service discovery
- Example: `order-service` → routes to order pods

**Deployment:**
- Manages pod replicas
- Desired state
- Rolling updates
- Rollback
- Example: 3 replicas of order-service

**Relationship:**
```
Deployment → Creates → Pods → Exposed by → Service
```

**Example:**
```yaml
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: order-service
        image: order-service:v1.0

# Service
apiVersion: v1
kind: Service
metadata:
  name: order-service
spec:
  selector:
    app: order-service
  ports:
  - port: 80
```

**Key Concepts:**
- **Pod**: Container instance
- **Service**: Network abstraction
- **Deployment**: Manages pods
- Work together for microservices

---

## 91. How do you scale microservices horizontally?

**Horizontal Scaling** adds more instances of a service to handle increased load.

**Methods:**

1. **Manual Scaling**
   - Add instances manually
   - Update configuration
   - Simple but manual

2. **Auto-Scaling**
   - Automatic based on metrics
   - CPU, memory, requests
   - Dynamic scaling

3. **Scheduled Scaling**
   - Scale based on schedule
   - Predictable patterns
   - Cost optimization

**Metrics for Scaling:**
- CPU utilization
- Memory usage
- Request rate
- Queue depth
- Response time

**Implementation:**

**Kubernetes HPA:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: order-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: order-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

**Best Practices:**
- Set min/max replicas
- Use appropriate metrics
- Test scaling behavior
- Monitor scaling events
- Consider costs

---

## 92. What is auto-scaling and how does it work?

**Auto-Scaling** automatically adjusts the number of service instances based on demand and metrics.

**How It Works:**

1. **Monitor Metrics**
   - Collect metrics (CPU, memory, requests)
   - Evaluate against thresholds
   - Determine if scaling needed

2. **Scale Decision**
   - If metric > threshold → Scale up
   - If metric < threshold → Scale down
   - Check min/max limits

3. **Execute Scaling**
   - Add/remove instances
   - Update load balancer
   - Monitor new instances

4. **Cooldown Period**
   - Wait before next scaling
   - Prevent thrashing
   - Stabilize system

**Types:**

1. **Horizontal Pod Autoscaler (HPA)**
   - Scale pods based on metrics
   - Kubernetes native
   - CPU/memory/custom metrics

2. **Vertical Pod Autoscaler (VPA)**
   - Adjust pod resources
   - CPU/memory limits
   - Less common

3. **Cluster Autoscaler**
   - Add/remove nodes
   - Infrastructure level
   - Node capacity

**Benefits:**
- Automatic scaling
- Cost optimization
- Performance
- Resource efficiency

**Considerations:**
- Scaling delays
- Cold starts
- Cost implications
- Metric selection

---

## 93. What are the different scaling strategies?

**Scaling Strategies:**

1. **Horizontal Scaling (Scale Out)**
   - Add more instances
   - Distribute load
   - Better for microservices
   - Preferred approach

2. **Vertical Scaling (Scale Up)**
   - Increase instance resources
   - More CPU/memory
   - Limited by hardware
   - Simpler but limited

3. **Auto-Scaling**
   - Automatic based on metrics
   - Dynamic adjustment
   - Cost optimization

4. **Manual Scaling**
   - Manual adjustment
   - Predictable patterns
   - Full control

5. **Scheduled Scaling**
   - Based on schedule
   - Predictable patterns
   - Cost optimization

6. **Predictive Scaling**
   - ML-based prediction
   - Anticipate demand
   - Proactive scaling

**Best Practices:**
- Prefer horizontal scaling
- Use auto-scaling
- Set appropriate limits
- Monitor scaling
- Test scaling behavior

**In Microservices:**
- Scale services independently
- Horizontal scaling preferred
- Auto-scaling recommended
- Based on service needs

---

## 94. How do you handle stateful services in microservices?

**Challenge:**
- Stateless services preferred
- Some services need state
- State management complexity

**Strategies:**

1. **Externalize State**
   - Store state externally
   - Database, cache, storage
   - Services remain stateless
   - Preferred approach

2. **Stateful Sets (Kubernetes)**
   - For stateful workloads
   - Stable network identity
   - Persistent storage
   - Ordered deployment

3. **Session Affinity**
   - Route same client to same instance
   - Sticky sessions
   - Load balancer configuration

4. **Shared State Store**
   - Redis, database
   - Centralized state
   - Accessible by all instances

**Best Practices:**
- Prefer stateless services
- Externalize state when needed
- Use StatefulSets for stateful
- Consider stateful service needs
- Design for stateless when possible

**Example - Kubernetes StatefulSet:**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
spec:
  serviceName: database
  replicas: 3
  template:
    spec:
      containers:
      - name: database
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

---

## 95. What is the difference between stateless and stateful services?

| Aspect | Stateless | Stateful |
|--------|-----------|----------|
| **State** | No stored state | Maintains state |
| **Scaling** | Easy | Complex |
| **Load Balancing** | Any instance | Session affinity |
| **Failure** | No data loss | Potential data loss |
| **Deployment** | Simple | Complex |
| **Use Case** | Most microservices | Databases, caches |

**Stateless Services:**
- No stored state
- Any instance can handle request
- Easy to scale
- Preferred for microservices
- Example: REST APIs

**Stateful Services:**
- Maintains state
- Same instance needed
- Harder to scale
- Required for some use cases
- Example: Databases, session stores

**Best Practices:**
- Prefer stateless
- Externalize state
- Use databases for persistence
- Stateless services + external state
- Easier to manage

**In Microservices:**
- Most services stateless
- State in databases/caches
- Easier scaling
- Better resilience

---

## 96. How do you implement health checks in microservices?

**Health Checks** verify service is functioning correctly and ready to handle requests.

**Types:**

1. **Liveness Probe**
   - Is service running?
   - Restart if failed
   - Detects deadlocks

2. **Readiness Probe**
   - Is service ready?
   - Remove from load balancer if failed
   - Detects startup issues

3. **Startup Probe**
   - Is service started?
   - For slow-starting services
   - Kubernetes feature

**Implementation:**

**HTTP Health Check:**
```java
@RestController
public class HealthController {
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        // Check dependencies
        if (isHealthy()) {
            return ResponseEntity.ok("UP");
        }
        return ResponseEntity.status(503).body("DOWN");
    }
}
```

**Kubernetes:**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

**Best Practices:**
- Implement both liveness and readiness
- Check dependencies in readiness
- Fast health checks
- Proper status codes
- Monitor health endpoints

---

## 97. What is the difference between liveness and readiness checks?

| Aspect | Liveness | Readiness |
|--------|----------|-----------|
| **Purpose** | Is service alive? | Is service ready? |
| **Action if Fails** | Restart container | Remove from load balancer |
| **Use Case** | Detect deadlocks | Detect startup issues |
| **Frequency** | Less frequent | More frequent |
| **Dependencies** | Don't check | Check dependencies |

**Liveness Probe:**
- Detects if service is running
- Restarts if failed
- Example: Deadlock detection
- Less frequent checks

**Readiness Probe:**
- Detects if service is ready
- Removes from load balancer if failed
- Example: Database connection check
- More frequent checks

**Example:**
```yaml
# Liveness - restart if deadlocked
livenessProbe:
  httpGet:
    path: /health
  initialDelaySeconds: 30

# Readiness - remove if not ready
readinessProbe:
  httpGet:
    path: /ready
  initialDelaySeconds: 5
```

**Best Practices:**
- Use both probes
- Liveness: Don't check dependencies
- Readiness: Check dependencies
- Different endpoints if needed
- Appropriate delays

---

## 98. How do you handle service dependencies during deployment?

**Challenge:**
- Services depend on each other
- Deployment order matters
- Dependency failures

**Strategies:**

1. **Dependency Health Checks**
   - Check dependencies in readiness probe
   - Don't accept traffic until dependencies ready
   - Graceful startup

2. **Circuit Breaker**
   - Handle dependency failures
   - Fail fast
   - Fallback responses

3. **Dependency Injection**
   - Inject dependencies
   - Mock for testing
   - Loose coupling

4. **Service Mesh**
   - Handle dependencies
   - Retry logic
   - Timeout handling

5. **Deployment Order**
   - Deploy dependencies first
   - Database migrations first
   - Infrastructure first

**Best Practices:**
- Check dependencies in readiness
- Handle dependency failures gracefully
- Use circuit breakers
- Deploy dependencies first
- Monitor dependencies

**Example:**
```java
@Component
public class DependencyHealthCheck {
    public boolean isReady() {
        return database.isConnected() && 
               messageQueue.isConnected() &&
               cache.isConnected();
    }
}
```

---

## 99. What is feature flags and how do you use them in microservices?

**Feature Flags** (Feature Toggles) enable/disable features without code deployment. Control feature rollout via configuration.

**How to Use:**

1. **Gradual Rollout**
   - Enable for small percentage
   - Monitor metrics
   - Gradually increase
   - Rollback if issues

2. **A/B Testing**
   - Test different versions
   - Compare performance
   - Data-driven decisions

3. **Environment Control**
   - Enable in dev/test
   - Disable in production
   - Gradual production rollout

4. **Emergency Kill Switch**
   - Disable feature instantly
   - No deployment needed
   - Quick rollback

**Implementation:**

**Simple Flag:**
```java
if (featureFlag.isEnabled("new-payment-flow")) {
    // New implementation
} else {
    // Old implementation
}
```

**Percentage Rollout:**
```java
if (featureFlag.isEnabledForUser("new-ui", userId, 10)) {
    // Enable for 10% of users
}
```

**Benefits:**
- Gradual rollout
- Quick rollback
- A/B testing
- Risk mitigation
- No deployment needed

**Best Practices:**
- Use feature flag service
- Monitor flag usage
- Clean up old flags
- Document flags
- Test flag behavior

---

## 100. How do you implement zero-downtime deployment?

**Zero-Downtime Deployment** updates services without interrupting service availability.

**Strategies:**

1. **Blue-Green Deployment**
   - Two environments
   - Switch traffic instantly
   - Zero downtime
   - Quick rollback

2. **Rolling Deployment**
   - Update instances gradually
   - Service remains available
   - Some old, some new
   - Continuous availability

3. **Canary Deployment**
   - Gradual rollout
   - Small percentage first
   - Monitor and expand
   - Low risk

4. **Health Checks**
   - Verify new instances healthy
   - Don't route to unhealthy
   - Automatic failover

5. **Load Balancer**
   - Route traffic to healthy instances
   - Remove unhealthy automatically
   - Seamless transition

**Requirements:**
- Multiple instances
- Health checks
- Load balancer
- Backward compatibility
- Database migration strategy

**Example - Kubernetes:**
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0  # Zero downtime
```

**Best Practices:**
- Use rolling deployments
- Health checks mandatory
- Backward compatible changes
- Database migration strategy
- Monitor closely
- Test deployment process

