# POC-6: Rolling Updates with Health Probes - Infrastructure Explanation

## Overview

POC-6 focuses on implementing **zero-downtime deployments** and **automatic recovery** in Kubernetes through health probes and rolling update strategies. This phase ensures your microservices can be updated safely without disrupting user traffic, and unhealthy pods are automatically detected and replaced.

---

## Core Concepts

### 1. Health Probes

Health probes are Kubernetes mechanisms that periodically check if your application containers are functioning correctly. There are three types:

#### **Liveness Probe**
- **Purpose**: Determines if the container is **alive** and running
- **Action on Failure**: Kubernetes kills the container and restarts it (according to restart policy)
- **Use Case**: Detect deadlocks, infinite loops, or frozen applications
- **Example**: A service that stops responding but the process is still running

#### **Readiness Probe**
- **Purpose**: Determines if the container is **ready** to accept traffic
- **Action on Failure**: Kubernetes removes the pod from Service endpoints (stops sending traffic)
- **Use Case**: Check if dependencies (database, external APIs) are available
- **Example**: A service that's running but can't connect to its database

#### **Startup Probe** (Optional)
- **Purpose**: Determines if the container has **started** successfully
- **Use Case**: For slow-starting applications (Java apps, legacy systems)
- **Note**: Not used in this POC but worth mentioning

---

## Implementation Details

### Health Check Endpoints

Your .NET services expose two endpoints:

```
GET /health/live   → Liveness check (is service alive?)
GET /health/ready  → Readiness check (can service handle requests?)
```

#### Liveness Endpoint (`/health/live`)
- **Checks**: Basic service functionality
- **Returns**: HTTP 200 if service is alive, 503 if dead
- **Implementation**: Simple check that the application process is responsive

#### Readiness Endpoint (`/health/ready`)
- **Checks**: 
  - Database connectivity
  - External service dependencies
  - Any critical resources needed to serve requests
- **Returns**: HTTP 200 if ready, 503 if not ready
- **Implementation**: Validates all dependencies are accessible

### Health Probe Configuration

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 80
  initialDelaySeconds: 30    # Wait 30s before first check
  periodSeconds: 10          # Check every 10 seconds
  timeoutSeconds: 5   # Timeout after 5 seconds
  failureThreshold: 3 # Restart after 3 consecutive failures

readinessProbe:
  httpGet:
    path: /health/ready
    port: 80
  initialDelaySeconds: 10    # Wait 10s before first check
  periodSeconds: 5           # Check every 5 seconds
  timeoutSeconds: 3          # Timeout after 3 seconds
  failureThreshold: 3        # Remove from service after 3 failures
```

#### Configuration Parameters Explained

- **initialDelaySeconds**: Time to wait before the first probe. Gives the app time to start.
- **periodSeconds**: How often to perform the probe check.
- **timeoutSeconds**: Maximum time to wait for a response.
- **failureThreshold**: Number of consecutive failures before taking action.
- **successThreshold**: (Default: 1) Number of successes needed to mark as healthy.

---

## Rolling Update Strategy

### What is a Rolling Update?

A rolling update gradually replaces old pod instances with new ones, ensuring:
- **Zero downtime**: At least one pod is always serving traffic
- **Gradual migration**: Old and new versions run simultaneously during transition
- **Automatic rollback**: Can revert if new version fails health checks

### Rolling Update Configuration

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # Can create 1 extra pod during update
    maxUnavailable: 0  # Must keep all pods available (0 downtime)
```

#### Parameters Explained

- **maxSurge**: Maximum number of pods that can be created above the desired replica count during an update.
  - `maxSurge: 1` means if you have 3 replicas, Kubernetes can temporarily have 4 pods during update
  - Allows new pods to start before old ones terminate

- **maxUnavailable**: Maximum number of pods that can be unavailable during an update.
  - `maxUnavailable: 0` means all pods must remain available (zero downtime)
  - Alternative: `maxUnavailable: 1` allows 1 pod to be down during update (faster but brief downtime)

### Rolling Update Process Flow

1. **Trigger Update**: You update the deployment image tag (e.g., v1.0.0 → v1.1.0)

2. **Create New Pod**: Kubernetes creates a new pod with the new image
   - New pod goes through startup → liveness → readiness checks
   - Once ready, it's added to the Service load balancer

3. **Terminate Old Pod**: Once new pod is healthy, Kubernetes terminates an old pod
   - Traffic shifts from old pod to new pod
   - Old pod is gracefully terminated (SIGTERM → SIGKILL after grace period)

4. **Repeat**: Steps 2-3 repeat until all pods are updated

5. **Complete**: All pods are running the new version

---

## Rollback Capability

### Why Rollback is Important

If a new version has bugs or fails health checks, you need to quickly revert to the previous working version.

### Kubernetes Rollout History

Kubernetes automatically maintains a history of deployments:

```powershell
# View rollout history
kubectl rollout history deployment/productservice -n microservices

# Output shows:
# REVISION  CHANGE-CAUSE
# 1         <none>
# 2         <none>
```

### Rollback Commands

```powershell
# Rollback to previous version
kubectl rollout undo deployment/productservice -n microservices

# Rollback to specific revision
kubectl rollout undo deployment/productservice --to-revision=1 -n microservices

# Watch rollback progress
kubectl rollout status deployment/productservice -n microservices
```

### How Rollback Works

1. Kubernetes identifies the previous working revision
2. Applies the previous deployment configuration
3. Performs a rolling update in reverse (new pods use old image)
4. Gradually replaces failed pods with working ones

---

## Complete Update Workflow

### Step-by-Step Process

1. **Build New Image**
   ```powershell
   docker build -t <acr-name>.azurecr.io/productservice:v1.1.0 .
   docker push <acr-name>.azurecr.io/productservice:v1.1.0
   ```

2. **Update Deployment Manifest**
   - Change image tag in `deployment.yaml` from `v1.0.0` to `v1.1.0`
   - Apply the updated manifest

3. **Apply Deployment**
   ```powershell
   kubectl apply -f infra/k8s/productservice/deployment.yaml -n microservices
   ```

4. **Monitor Rolling Update**
   ```powershell
   # Watch update progress
   kubectl rollout status deployment/productservice -n microservices
   
   # Watch pods in real-time
   kubectl get pods -n microservices -w
   ```

5. **Verify Health**
   - Check that all pods are in `Running` state
   - Verify new pods pass health checks
   - Test application functionality

6. **Rollback if Needed**
   ```powershell
   kubectl rollout undo deployment/productservice -n microservices
   ```

---

## Benefits of This Approach

### 1. **Zero Downtime Deployments**
- Users never experience service interruption
- Critical for production environments

### 2. **Automatic Failure Detection**
- Unhealthy pods are automatically replaced
- No manual intervention needed

### 3. **Safe Updates**
- New version is tested before old version is removed
- Can rollback instantly if issues are detected

### 4. **Gradual Migration**
- Traffic gradually shifts to new version
- Allows monitoring and validation before full cutover

### 5. **Resource Efficiency**
- Only creates necessary pods during update
- No need for blue-green deployment infrastructure

---

## Best Practices

### Health Check Design

1. **Keep Liveness Checks Simple**
   - Should only verify the process is alive
   - Avoid external dependencies (database, APIs)
   - Fast response time (< 1 second)

2. **Make Readiness Checks Comprehensive**
   - Verify all critical dependencies
   - Check database connectivity
   - Validate external service availability
   - Return detailed status information

3. **Set Appropriate Timeouts**
   - Liveness: Longer timeout (5-10s) to avoid false positives
   - Readiness: Shorter timeout (3-5s) for faster failure detection

4. **Configure Initial Delays**
   - Give application time to start (30s+ for .NET apps)
   - Prevents premature restarts during startup

### Rolling Update Configuration

1. **Production**: Use `maxUnavailable: 0` for zero downtime
2. **Development**: Use `maxUnavailable: 1` for faster updates
3. **Large Deployments**: Consider `maxSurge: 2` for faster rollouts

### Monitoring During Updates

1. Watch pod status: `kubectl get pods -w`
2. Monitor application logs: `kubectl logs -f <pod-name>`
3. Check health endpoints directly
4. Monitor application metrics (response times, error rates)

---

## Common Issues and Solutions

### Issue 1: Pods Stuck in CrashLoopBackOff
**Cause**: Liveness probe failing repeatedly
**Solution**: 
- Check application logs
- Verify health endpoint is accessible
- Increase `initialDelaySeconds` if app needs more startup time

### Issue 2: Pods Not Receiving Traffic
**Cause**: Readiness probe failing
**Solution**:
- Check database connectivity
- Verify external dependencies are available
- Review readiness endpoint implementation

### Issue 3: Rolling Update Takes Too Long
**Cause**: Health checks timing out or failing
**Solution**:
- Optimize health check response time
- Reduce `periodSeconds` for faster checks
- Ensure dependencies are ready before deployment

### Issue 4: Rollback Not Working
**Cause**: No deployment history
**Solution**:
- Ensure `revisionHistoryLimit` is set in deployment
- Check that previous revisions exist

---

## Summary

POC-6 implements a production-ready deployment strategy that ensures:
- ✅ Zero-downtime updates through rolling deployments
- ✅ Automatic health monitoring via liveness and readiness probes
- ✅ Quick rollback capability for failed deployments
- ✅ Gradual, safe migration to new application versions

This foundation is essential for maintaining high availability and reliability in production Kubernetes environments.

