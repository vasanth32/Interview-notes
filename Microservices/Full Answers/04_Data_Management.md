# Microservices Interview Answers - Data Management (Questions 61-80)

## 61. What is the database per service pattern?

**Database Per Service Pattern** is a fundamental microservices pattern where each microservice has its own private database. Services cannot directly access other services' databases.

**Key Principles:**

1. **Data Ownership**
   - Each service owns its data
   - Encapsulation of data
   - Service controls access

2. **Technology Independence**
   - Different database types per service
   - SQL, NoSQL, specialized databases
   - Choose best fit

3. **Independent Scaling**
   - Scale databases independently
   - Based on service needs
   - Resource optimization

4. **Loose Coupling**
   - Services decoupled at data level
   - No shared database
   - Independent evolution

**Benefits:**
- Service independence
- Technology diversity
- Independent scaling
- Fault isolation
- Team autonomy
- Better performance

**Challenges:**
- Data consistency
- Distributed transactions
- Data duplication
- Querying across services
- Complexity

**Implementation:**
- Each service has own database
- Access via service APIs only
- Use events for synchronization
- Implement eventual consistency

---

## 62. How do you handle data consistency across multiple databases?

**Challenges:**
- No shared database
- Independent databases
- Need consistency
- Distributed system

**Strategies:**

1. **Eventual Consistency** (Most Common)
   - Accept temporary inconsistencies
   - Sync eventually via events
   - Most practical approach

2. **Saga Pattern**
   - Distributed transactions
   - Compensating actions
   - Eventually consistent

3. **Event Sourcing**
   - Store events
   - Derive state from events
   - Natural consistency

4. **CQRS**
   - Separate read/write models
   - Sync read models via events
   - Optimized for each

5. **Two-Phase Commit** (Avoid)
   - Blocking
   - Poor performance
   - Not recommended

**Best Practices:**
- Design for eventual consistency
- Use events for synchronization
- Implement idempotency
- Handle conflicts gracefully
- Monitor consistency
- Use saga for transactions

**Example:**
- Order Service creates order
- Publishes OrderCreated event
- Inventory Service updates inventory
- Payment Service processes payment
- Eventually consistent

---

## 63. What is the shared database anti-pattern?

**Shared Database Anti-Pattern** is when multiple microservices share the same database, violating the database per service principle.

**Why It's an Anti-Pattern:**

1. **Tight Coupling**
   - Services coupled via database
   - Schema changes affect multiple services
   - Violates independence

2. **Scaling Issues**
   - Can't scale databases independently
   - One service affects others
   - Resource contention

3. **Technology Lock-in**
   - All services use same database
   - Can't choose best technology
   - Limits flexibility

4. **Deployment Coupling**
   - Schema changes require coordination
   - Can't deploy independently
   - Deployment complexity

5. **Team Conflicts**
   - Multiple teams modify same schema
   - Conflicts and coordination needed
   - Slows development

**Problems:**
- No service independence
- Deployment coupling
- Scaling limitations
- Technology constraints
- Team coordination overhead

**Solution:**
- Database per service
- Access via APIs
- Use events for sync
- Independent databases

**Migration:**
- Identify service boundaries
- Split database gradually
- Use strangler pattern
- Migrate data carefully

---

## 64. How do you handle transactions across multiple services?

**Challenge:**
- Services have independent databases
- Can't use traditional ACID transactions
- Need consistency

**Approaches:**

1. **Saga Pattern** (Recommended)
   - Series of local transactions
   - Compensating actions
   - Eventually consistent

2. **Two-Phase Commit** (Avoid)
   - Blocking protocol
   - Poor performance
   - Doesn't scale

3. **Eventual Consistency**
   - Accept temporary inconsistencies
   - Sync via events
   - Most practical

4. **TCC (Try-Confirm-Cancel)**
   - Try: Reserve resources
   - Confirm: Commit
   - Cancel: Release

5. **Outbox Pattern**
   - Write to local DB and outbox
   - Publish events from outbox
   - Ensures consistency

**Saga Example:**
```
1. Create Order (Order Service) - Local transaction
2. Reserve Inventory (Inventory Service) - Local transaction
   - If fails → Cancel Order
3. Process Payment (Payment Service) - Local transaction
   - If fails → Release Inventory, Cancel Order
4. Create Shipment (Shipping Service) - Local transaction
   - If fails → Refund, Release Inventory, Cancel Order
```

**Best Practices:**
- Use saga pattern
- Implement compensating actions
- Design for eventual consistency
- Make operations idempotent
- Monitor transactions

---

## 65. What is eventual consistency and how do you achieve it?

**Eventual Consistency** guarantees that if no new updates are made, eventually all reads will return the last updated value. Temporary inconsistencies are acceptable.

**How to Achieve:**

1. **Event-Driven Synchronization**
   - Services publish events
   - Other services subscribe
   - Update their data
   - Eventually consistent

2. **Replication**
   - Replicate data to services
   - Update via events
   - Eventually syncs

3. **CQRS**
   - Separate read/write models
   - Update read models via events
   - Eventually consistent

4. **Saga Pattern**
   - Distributed transactions
   - Eventually consistent
   - Compensating actions

**Example Flow:**
```
1. Order Service creates order → Publishes OrderCreated event
2. Inventory Service subscribes → Reserves inventory
3. Payment Service subscribes → Processes payment
4. All eventually consistent
```

**Best Practices:**
- Use events for synchronization
- Implement idempotency
- Handle conflicts
- Monitor consistency
- Set expectations

**When Acceptable:**
- High availability needed
- Read-heavy workloads
- Non-critical data
- Can tolerate delays

---

## 66. What is CQRS (Command Query Responsibility Segregation)?

**CQRS** separates read and write operations into different models. Commands (writes) and queries (reads) use different models optimized for each.

**Key Concepts:**

1. **Command Side (Write)**
   - Handles writes
   - Optimized for writes
   - Domain model
   - Business logic

2. **Query Side (Read)**
   - Handles reads
   - Optimized for reads
   - Denormalized views
   - Fast queries

3. **Separation**
   - Different models
   - Different databases (optional)
   - Independent scaling
   - Optimized for each

**Benefits:**
- Optimized reads
- Optimized writes
- Independent scaling
- Performance
- Flexibility

**When to Use:**
- Different read/write patterns
- Complex queries
- High read load
- Need performance
- Different data models needed

**Example:**
- Write: Normalized relational model
- Read: Denormalized document model
- Sync via events

---

## 67. How does CQRS help in microservices architecture?

**Benefits in Microservices:**

1. **Performance**
   - Optimized read models
   - Fast queries
   - Better performance

2. **Scalability**
   - Scale reads independently
   - Scale writes independently
   - Resource optimization

3. **Flexibility**
   - Different models per service
   - Technology diversity
   - Best fit for each

4. **Complex Queries**
   - Denormalized read models
   - Complex queries possible
   - No impact on writes

5. **Team Autonomy**
   - Teams optimize independently
   - Different technologies
   - Faster development

**Use Cases:**
- High read load
- Complex queries
- Different read/write needs
- Performance critical
- Multiple read models

**Implementation:**
- Write to command model
- Publish events
- Update read models
- Eventually consistent

---

## 68. What is event sourcing and how does it work?

**Event Sourcing** stores all changes to application state as a sequence of events. Instead of storing current state, store events that led to current state.

**How It Works:**

1. **Store Events**
   - Don't store current state
   - Store events (what happened)
   - Complete history

2. **Replay Events**
   - Replay events to get state
   - Current state = sum of events
   - Time travel possible

3. **Event Store**
   - Append-only log
   - Immutable events
   - Complete audit trail

**Example:**
```
Events:
- OrderCreated (orderId: 123, amount: 100)
- PaymentProcessed (orderId: 123, amount: 100)
- OrderShipped (orderId: 123)

Current State:
- Order 123: Created, Paid, Shipped
```

**Benefits:**
- Complete audit trail
- Time travel
- Debugging
- Replay capability
- Eventual consistency

**Challenges:**
- Event store complexity
- Replay performance
- Event versioning
- Storage requirements

---

## 69. What are the benefits and drawbacks of event sourcing?

**Benefits:**

1. **Complete Audit Trail**
   - Every change recorded
   - Compliance
   - Debugging

2. **Time Travel**
   - Replay to any point
   - Historical analysis
   - Debugging

3. **Eventual Consistency**
   - Natural fit
   - Events sync state
   - Distributed systems

4. **Performance**
   - Append-only writes
   - Fast writes
   - Optimized reads via projections

5. **Flexibility**
   - New read models easy
   - Replay events
   - Adapt to changes

**Drawbacks:**

1. **Complexity**
   - More complex than CRUD
   - Event store needed
   - Replay logic

2. **Storage**
   - More storage needed
   - Event history grows
   - Snapshot strategy needed

3. **Performance**
   - Replay can be slow
   - Need snapshots
   - Query complexity

4. **Learning Curve**
   - Different mindset
   - Team training needed
   - More complex

5. **Event Versioning**
   - Events change over time
   - Migration needed
   - Version handling

**When to Use:**
- Need audit trail
- Event-driven architecture
- Complex domain
- Compliance requirements
- Time travel needed

---

## 70. How do you handle data migration in microservices?

**Challenges:**
- Multiple databases
- Independent services
- Zero downtime
- Data consistency

**Strategies:**

1. **Backward Compatible Changes**
   - Add new columns (nullable)
   - Don't remove columns immediately
   - Gradual migration

2. **Dual Write Pattern**
   - Write to old and new format
   - Migrate existing data
   - Switch reads gradually
   - Remove old format

3. **Event-Driven Migration**
   - Publish migration events
   - Services migrate on events
   - Eventually consistent

4. **Strangler Pattern**
   - New service alongside old
   - Migrate data gradually
   - Switch traffic
   - Remove old

5. **Versioned APIs**
   - Support multiple versions
   - Migrate clients gradually
   - Deprecate old versions

**Best Practices:**
- Plan migration carefully
- Test thoroughly
- Gradual migration
- Monitor closely
- Rollback plan
- Zero downtime

**Example:**
```
1. Add new column (nullable)
2. Update code to write both
3. Migrate existing data
4. Update code to read new
5. Remove old column
```

---

## 71. What is the saga pattern for data consistency?

**Saga Pattern** manages distributed transactions across microservices using local transactions and compensating actions.

**How It Works:**

1. **Break Transaction into Steps**
   - Each step is local transaction
   - Steps execute sequentially
   - If step fails, compensate

2. **Compensating Actions**
   - Undo previous steps
   - Reverse operations
   - Restore state

3. **Eventually Consistent**
   - Not ACID
   - Eventually consistent
   - Acceptable for microservices

**Types:**

1. **Choreography-Based**
   - Services coordinate via events
   - No central coordinator
   - Decentralized

2. **Orchestration-Based**
   - Central orchestrator
   - Coordinates steps
   - Centralized control

**Example:**
```
Order Processing Saga:
1. Create Order → If fails: Nothing to compensate
2. Reserve Inventory → If fails: Cancel Order
3. Process Payment → If fails: Release Inventory, Cancel Order
4. Create Shipment → If fails: Refund, Release Inventory, Cancel Order
```

**Benefits:**
- Distributed transactions
- No blocking
- Scalable
- Eventually consistent

**Challenges:**
- Complexity
- Compensating logic
- Monitoring
- Debugging

---

## 72. How do you handle read and write operations in distributed databases?

**Challenges:**
- Multiple databases
- Consistency requirements
- Performance needs
- Availability needs

**Strategies:**

1. **CQRS**
   - Separate read/write models
   - Optimize each
   - Sync via events

2. **Read Replicas**
   - Master for writes
   - Replicas for reads
   - Eventual consistency

3. **Event Sourcing**
   - Write events
   - Read from projections
   - Optimized for each

4. **Caching**
   - Cache reads
   - Invalidate on writes
   - Improve performance

5. **Database Per Service**
   - Each service has own DB
   - Access via APIs
   - Independent optimization

**Best Practices:**
- Optimize reads separately
- Optimize writes separately
- Use caching
- Accept eventual consistency
- Monitor performance

**Example:**
- Write: Normalized relational DB
- Read: Denormalized document DB
- Sync via events

---

## 73. What is the difference between SQL and NoSQL in microservices context?

| Aspect | SQL | NoSQL |
|--------|-----|-------|
| **Structure** | Relational, schema | Flexible, schema-less |
| **ACID** | Strong ACID | Eventually consistent |
| **Scaling** | Vertical, limited horizontal | Horizontal scaling |
| **Queries** | SQL, complex queries | Simple queries, limited |
| **Relationships** | Foreign keys, joins | Denormalized, no joins |
| **Use Case** | Structured data, transactions | Unstructured, high volume |
| **Consistency** | Strong consistency | Eventual consistency |

**SQL Best For:**
- Structured data
- ACID transactions
- Complex queries
- Relationships
- Financial data

**NoSQL Best For:**
- Unstructured data
- High volume
- Horizontal scaling
- Simple queries
- Document storage

**In Microservices:**
- Choose based on service needs
- Different services, different databases
- Technology diversity
- Best fit for each

---

## 74. When would you choose NoSQL over SQL for a microservice?

**Choose NoSQL when:**

1. **Unstructured Data**
   - Documents, JSON
   - Flexible schema
   - Schema evolution

2. **High Volume**
   - Millions of records
   - High write throughput
   - Horizontal scaling needed

3. **Simple Queries**
   - Key-value lookups
   - Document queries
   - No complex joins

4. **Horizontal Scaling**
   - Need to scale out
   - Distributed system
   - Partitioning

5. **Performance**
   - Low latency needed
   - High throughput
   - Caching use case

6. **Eventual Consistency Acceptable**
   - Can tolerate delays
   - Not transactional
   - High availability priority

**Examples:**
- User profiles (document)
- Session data (key-value)
- Logs (time-series)
- Product catalog (document)
- Analytics (columnar)

**Choose SQL when:**
- Structured data
- ACID transactions
- Complex queries
- Relationships
- Strong consistency

---

## 75. How do you handle data replication in microservices?

**Data Replication** copies data from one database to another for availability, performance, or geographic distribution.

**Strategies:**

1. **Master-Slave Replication**
   - Master for writes
   - Slaves for reads
   - Async replication
   - Eventual consistency

2. **Master-Master Replication**
   - Multiple masters
   - Writes to any master
   - Conflict resolution
   - More complex

3. **Event-Driven Replication**
   - Publish events
   - Services replicate on events
   - Eventually consistent
   - Microservices-friendly

4. **Read Replicas**
   - Scale reads
   - Reduce load on master
   - Geographic distribution

**In Microservices:**
- Each service replicates its data
- Use events for cross-service replication
- Independent replication strategies
- Eventually consistent

**Best Practices:**
- Use events for replication
- Accept eventual consistency
- Monitor replication lag
- Handle conflicts
- Geographic distribution

---

## 76. What is the difference between master-slave and master-master replication?

| Aspect | Master-Slave | Master-Master |
|--------|--------------|---------------|
| **Writes** | Master only | Any master |
| **Reads** | Master + Slaves | Any master |
| **Consistency** | Eventually consistent | Eventually consistent |
| **Complexity** | Simpler | More complex |
| **Conflict Resolution** | Not needed | Needed |
| **Use Case** | Read scaling | Geographic distribution |
| **Failure** | Single point (master) | No single point |

**Master-Slave:**
- One master, multiple slaves
- Writes to master only
- Slaves replicate from master
- Simpler
- Single point of failure (master)

**Master-Master:**
- Multiple masters
- Writes to any master
- Masters replicate to each other
- More complex
- Conflict resolution needed
- No single point of failure

**Choose Master-Slave when:**
- Read scaling needed
- Simple setup
- Single write location acceptable

**Choose Master-Master when:**
- Geographic distribution
- No single point of failure
- Writes from multiple locations

---

## 77. How do you ensure data integrity in a distributed system?

**Challenges:**
- Multiple databases
- No shared transactions
- Network failures
- Partial failures

**Strategies:**

1. **Referential Integrity**
   - Can't use foreign keys across services
   - Use application-level checks
   - Validate via APIs

2. **Eventual Consistency**
   - Accept temporary inconsistencies
   - Sync eventually
   - Monitor consistency

3. **Saga Pattern**
   - Distributed transactions
   - Compensating actions
   - Eventually consistent

4. **Idempotency**
   - Prevent duplicates
   - Safe retries
   - Idempotency keys

5. **Validation**
   - Validate at service boundaries
   - Input validation
   - Business rules

6. **Monitoring**
   - Monitor data integrity
   - Alert on inconsistencies
   - Regular checks

**Best Practices:**
- Design for eventual consistency
- Implement idempotency
- Validate at boundaries
- Monitor integrity
- Handle conflicts

---

## 78. What is the difference between ACID and BASE properties?

**ACID (Traditional Databases):**
- **Atomicity**: All or nothing
- **Consistency**: Valid state always
- **Isolation**: Concurrent transactions don't interfere
- **Durability**: Committed data persists

**BASE (NoSQL/Distributed):**
- **Basically Available**: System available most of the time
- **Soft State**: State may change over time
- **Eventually Consistent**: Will be consistent eventually

**Comparison:**

| Aspect | ACID | BASE |
|--------|------|------|
| **Consistency** | Strong, immediate | Eventual |
| **Availability** | May sacrifice | Prioritized |
| **Performance** | Lower | Higher |
| **Use Case** | Transactions | Distributed systems |
| **Complexity** | Simpler | More complex |

**ACID:**
- Strong consistency
- Immediate consistency
- Better for transactions
- Financial systems

**BASE:**
- Eventual consistency
- High availability
- Better for distributed
- Web scale

**In Microservices:**
- Use ACID within service
- Use BASE across services
- Choose based on needs
- Balance consistency and availability

---

## 79. How do you handle data partitioning in microservices?

**Data Partitioning** splits data across multiple databases or partitions for scalability and performance.

**Strategies:**

1. **Horizontal Partitioning (Sharding)**
   - Split by rows
   - Distribute across partitions
   - Based on key (user ID, region)

2. **Vertical Partitioning**
   - Split by columns
   - Different tables/DBs
   - Based on access patterns

3. **Functional Partitioning**
   - Split by function
   - Database per service
   - Natural microservices fit

**Partitioning Keys:**
- User ID
- Geographic region
- Time period
- Hash of key
- Range-based

**Challenges:**
- Cross-partition queries
- Data distribution
- Rebalancing
- Complexity

**Best Practices:**
- Partition by service (natural)
- Choose good partition key
- Monitor distribution
- Plan for rebalancing
- Handle cross-partition queries

---

## 80. What is the difference between horizontal and vertical partitioning?

| Aspect | Horizontal Partitioning | Vertical Partitioning |
|--------|------------------------|----------------------|
| **Split** | By rows | By columns |
| **Use Case** | Scale out | Optimize access |
| **Example** | Users by region | User profile vs preferences |
| **Queries** | Cross-partition complex | Simpler |
| **Scaling** | Horizontal scaling | Limited |

**Horizontal Partitioning (Sharding):**
- Split data by rows
- Distribute across partitions
- Scale horizontally
- Example: Users by user ID hash

**Vertical Partitioning:**
- Split data by columns
- Different tables/DBs
- Optimize access patterns
- Example: User profile vs user preferences

**In Microservices:**
- Natural horizontal partitioning (service boundaries)
- Each service partitions its data
- Independent partitioning strategies
- Optimize per service

