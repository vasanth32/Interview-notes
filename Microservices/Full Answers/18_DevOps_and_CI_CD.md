# Microservices Interview Answers - DevOps & CI/CD (Questions 341-360)

## 341. How do you implement CI/CD for microservices?

**CI/CD Implementation:**

1. **Pipeline Per Service**
   - Independent pipelines
   - Service-specific
   - Fast feedback

2. **Automated Testing**
   - Unit tests
   - Integration tests
   - Contract tests

3. **Automated Deployment**
   - Deploy to environments
   - Rolling deployments
   - Zero downtime

4. **Monitoring**
   - Deployment monitoring
   - Health checks
   - Rollback on failure

**Best Practices:**
- Pipeline per service
- Automated testing
- Automated deployment
- Monitoring
- Fast feedback loops

---

## 342. What is the difference between CI/CD for monolith and microservices?

**Monolith CI/CD:**
- **Pipelines**: Single pipeline
- **Deployment**: All or nothing
- **Testing**: Full application
- **Complexity**: Lower

**Microservices CI/CD:**
- **Pipelines**: Multiple pipelines
- **Deployment**: Independent
- **Testing**: Per service
- **Complexity**: Higher

**Comparison:**

| Aspect | Monolith | Microservices |
|--------|----------|---------------|
| **Pipelines** | Single | Multiple |
| **Deployment** | All or nothing | Independent |
| **Complexity** | Lower | Higher |

**Best Practices:**
- Multiple pipelines for microservices
- Independent deployments
- Service-specific testing
- Automation
- Monitoring

---

## 343. How do you handle independent deployment of microservices?

**Independent Deployment:**

1. **Separate Pipelines**
   - Pipeline per service
   - Independent builds
   - Independent deployments

2. **Versioning**
   - Semantic versioning
   - Service versions
   - API versioning

3. **Deployment Strategy**
   - Rolling deployments
   - Canary deployments
   - Zero downtime

4. **Monitoring**
   - Deployment monitoring
   - Health checks
   - Rollback capability

**Best Practices:**
- Separate pipelines
- Independent deployments
- Versioning
- Monitoring
- Rollback capability

---

## 344. What is the difference between continuous deployment and continuous delivery?

**Continuous Delivery:**
- **Deployment**: Manual approval
- **Automation**: Up to production
- **Control**: Human approval
- **Use Case**: Production control

**Continuous Deployment:**
- **Deployment**: Automatic
- **Automation**: Full automation
- **Control**: Automated
- **Use Case**: Fast iteration

**Comparison:**

| Aspect | Continuous Delivery | Continuous Deployment |
|--------|-------------------|----------------------|
| **Deployment** | Manual approval | Automatic |
| **Control** | Human | Automated |
| **Speed** | Slower | Faster |

**Best Practices:**
- Continuous delivery for production
- Continuous deployment for dev/test
- Choose based on needs
- Safety vs speed

---

## 345. How do you implement blue-green deployment in CI/CD?

**Blue-Green in CI/CD:**

1. **Pipeline Steps**
   - Build → Test → Deploy Green
   - Test Green
   - Switch traffic
   - Monitor

2. **Infrastructure**
   - Two environments
   - Load balancer
   - Traffic switching

3. **Automation**
   - Automated deployment
   - Automated switching
   - Automated rollback

**Pipeline:**
```
Build → Test → Deploy Green → Test → Switch Traffic → Monitor
```

**Best Practices:**
- Automate blue-green
- Test before switch
- Monitor closely
- Quick rollback
- Zero downtime

---

## 346. What is the difference between blue-green and canary deployment in CI/CD?

**Blue-Green:**
- **Traffic**: 100% switch
- **Speed**: Instant
- **Risk**: Lower (tested)
- **CI/CD**: Deploy → Test → Switch

**Canary:**
- **Traffic**: Gradual (5% → 100%)
- **Speed**: Gradual
- **Risk**: Higher (real users)
- **CI/CD**: Deploy → Route → Monitor → Expand

**Comparison:**

| Aspect | Blue-Green | Canary |
|--------|-----------|--------|
| **Traffic** | 100% switch | Gradual |
| **CI/CD** | Deploy → Switch | Deploy → Route → Expand |

**Best Practices:**
- Blue-green for tested changes
- Canary for high-risk changes
- Automate in CI/CD
- Monitor closely

---

## 347. How do you handle database migrations in CI/CD?

**Database Migrations:**

1. **Migration Scripts**
   - Versioned migrations
   - Idempotent
   - Rollback scripts

2. **Migration Strategy**
   - Backward compatible
   - Dual write
   - Gradual migration

3. **CI/CD Integration**
   - Run migrations in pipeline
   - Test migrations
   - Rollback on failure

**Best Practices:**
- Versioned migrations
- Idempotent migrations
- Backward compatible
- Test migrations
- Rollback capability

---

## 348. What is the difference between database migration and schema migration?

**Database Migration:**
- **Scope**: Full database
- **Content**: Data + schema
- **Complexity**: Higher
- **Use Case**: Complete migration

**Schema Migration:**
- **Scope**: Schema only
- **Content**: Structure
- **Complexity**: Lower
- **Use Case**: Structure changes

**Comparison:**

| Aspect | Database Migration | Schema Migration |
|--------|-------------------|------------------|
| **Scope** | Full | Schema |
| **Content** | Data + schema | Schema |
| **Complexity** | Higher | Lower |

**Best Practices:**
- Schema migration for structure
- Database migration for data
- Choose based on needs
- Test thoroughly

---

## 349. How do you implement feature flags in CI/CD?

**Feature Flags in CI/CD:**

1. **Flag Configuration**
   - Store flags
   - Environment-specific
   - Dynamic updates

2. **Pipeline Integration**
   - Deploy code with flags
   - Enable gradually
   - Monitor

3. **Rollout**
   - Enable for percentage
   - Monitor metrics
   - Expand gradually

**Best Practices:**
- Use feature flag service
- Deploy with flags
- Gradual rollout
- Monitor usage
- Clean up flags

---

## 350. What is the difference between feature flags and environment variables?

**Feature Flags:**
- **Purpose**: Feature control
- **Scope**: Features
- **Dynamic**: Can change runtime
- **Use Case**: Feature rollout

**Environment Variables:**
- **Purpose**: Configuration
- **Scope**: Configuration
- **Dynamic**: Requires restart
- **Use Case**: Configuration

**Comparison:**

| Aspect | Feature Flags | Environment Variables |
|--------|--------------|----------------------|
| **Purpose** | Features | Configuration |
| **Dynamic** | Runtime | Restart needed |
| **Use Case** | Rollout | Config |

**Best Practices:**
- Feature flags for features
- Environment variables for config
- Use appropriately
- Don't mix purposes

---

## 351. How do you handle versioning in CI/CD?

**Versioning:**

1. **Semantic Versioning**
   - Major.Minor.Patch
   - Clear meaning
   - Industry standard

2. **Automated Versioning**
   - Git tags
   - Build numbers
   - Automated

3. **API Versioning**
   - Version APIs
   - Backward compatibility
   - Deprecation

**Best Practices:**
- Semantic versioning
- Automated versioning
- API versioning
- Document versions
- Version in artifacts

---

## 352. What is the difference between semantic versioning and date-based versioning?

**Semantic Versioning:**
- **Format**: Major.Minor.Patch
- **Meaning**: Clear meaning
- **Use Case**: APIs, libraries
- **Example**: 1.2.3

**Date-Based Versioning:**
- **Format**: YYYY.MM.DD
- **Meaning**: Date-based
- **Use Case**: Releases
- **Example**: 2024.01.15

**Comparison:**

| Aspect | Semantic | Date-Based |
|--------|----------|------------|
| **Format** | Major.Minor.Patch | YYYY.MM.DD |
| **Meaning** | Clear | Date |
| **Use Case** | APIs | Releases |

**Best Practices:**
- Semantic for APIs
- Date-based for releases
- Choose based on needs
- Consistent approach

---

## 353. How do you implement rollback in CI/CD?

**Rollback:**

1. **Automated Rollback**
   - Health check failures
   - Error thresholds
   - Automatic rollback

2. **Manual Rollback**
   - Manual trigger
   - Previous version
   - Quick recovery

3. **Rollback Strategy**
   - Keep previous version
   - Quick switch
   - Data compatibility

**Best Practices:**
- Automated rollback
- Manual rollback option
- Keep previous versions
- Test rollback
- Quick recovery

---

## 354. What is the difference between rollback and rollforward?

**Rollback:**
- **Direction**: Backward
- **Action**: Revert to previous
- **Use Case**: Failure recovery
- **Risk**: Lower

**Rollforward:**
- **Direction**: Forward
- **Action**: Fix and deploy
- **Use Case**: Quick fix
- **Risk**: Higher

**Comparison:**

| Aspect | Rollback | Rollforward |
|--------|----------|-------------|
| **Direction** | Backward | Forward |
| **Action** | Revert | Fix |
| **Risk** | Lower | Higher |

**Best Practices:**
- Rollback for failures
- Rollforward for quick fixes
- Choose based on situation
- Test both strategies

---

## 355. How do you handle testing in CI/CD pipeline?

**Testing in CI/CD:**

1. **Test Pyramid**
   - Many unit tests
   - Fewer integration tests
   - Minimal E2E tests

2. **Test Stages**
   - Unit tests (fast)
   - Integration tests (slower)
   - E2E tests (slowest)

3. **Parallel Testing**
   - Run tests in parallel
   - Faster feedback
   - Efficient

**Best Practices:**
- Test pyramid
- Fast feedback
- Parallel testing
- Fail fast
- Comprehensive coverage

---

## 356. What is the difference between unit tests and integration tests in CI/CD?

**Unit Tests:**
- **Speed**: Fast
- **Scope**: Single unit
- **Dependencies**: Mocked
- **CI/CD**: Run early

**Integration Tests:**
- **Speed**: Slower
- **Scope**: Multiple components
- **Dependencies**: Real/test doubles
- **CI/CD**: Run after unit

**Comparison:**

| Aspect | Unit | Integration |
|--------|------|-------------|
| **Speed** | Fast | Slower |
| **CI/CD** | Early | After unit |
| **Count** | Many | Fewer |

**Best Practices:**
- More unit tests
- Fewer integration tests
- Run in order
- Fast feedback
- Fail fast

---

## 357. How do you implement security scanning in CI/CD?

**Security Scanning:**

1. **Static Analysis**
   - Code scanning
   - Dependency scanning
   - Early detection

2. **Dynamic Analysis**
   - Runtime scanning
   - Vulnerability testing
   - Production-like

3. **Container Scanning**
   - Image scanning
   - Vulnerability detection
   - Before deployment

**Best Practices:**
- Static analysis early
- Dependency scanning
- Container scanning
- Dynamic analysis
- Fix before deploy

---

## 358. What is the difference between static and dynamic security scanning?

**Static Scanning:**
- **Type**: Code analysis
- **Timing**: Before runtime
- **Scope**: Code, dependencies
- **Speed**: Fast

**Dynamic Scanning:**
- **Type**: Runtime analysis
- **Timing**: During runtime
- **Scope**: Running application
- **Speed**: Slower

**Comparison:**

| Aspect | Static | Dynamic |
|--------|--------|---------|
| **Timing** | Before runtime | During runtime |
| **Scope** | Code | Running app |
| **Speed** | Fast | Slower |

**Best Practices:**
- Static for code
- Dynamic for runtime
- Use both
- Comprehensive security

---

## 359. How do you handle configuration management in CI/CD?

**Configuration Management:**

1. **Configuration as Code**
   - Version controlled
   - Infrastructure as code
   - Reproducible

2. **Environment-Specific**
   - Dev, test, prod
   - Separate configs
   - Secure secrets

3. **Secrets Management**
   - Secrets manager
   - Encrypted
   - Access controlled

**Best Practices:**
- Configuration as code
- Environment-specific
- Secrets management
- Version controlled
- Secure handling

---

## 360. What is the difference between configuration as code and configuration as data?

**Configuration as Code:**
- **Type**: Code/scripts
- **Versioning**: Version controlled
- **Automation**: Automated
- **Examples**: Terraform, Ansible

**Configuration as Data:**
- **Type**: Data files
- **Versioning**: Version controlled
- **Automation**: Can be automated
- **Examples**: YAML, JSON

**Comparison:**

| Aspect | As Code | As Data |
|--------|---------|---------|
| **Type** | Code | Data |
| **Automation** | Automated | Can be automated |
| **Examples** | Terraform | YAML |

**Best Practices:**
- Configuration as code preferred
- Version controlled
- Automated
- Reproducible
- Documented

