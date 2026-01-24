# Kubernetes Infrastructure Explanations

---

# POC-5: AKS Deployment per Service - Infrastructure Explanation

## Overview

POC-5 is your **first real Kubernetes deployment**. This phase teaches you how to package and deploy microservices to Azure Kubernetes Service (AKS) using Kubernetes manifests (YAML files). You'll learn the fundamental Kubernetes resources needed to run applications in production.

---

## What is Kubernetes? (Beginner's Guide)

Think of Kubernetes as a **smart container orchestrator**:

- **Without Kubernetes**: You manually run Docker containers on servers, manage networking, handle failures, scale manually
- **With Kubernetes**: You declare what you want (e.g., "run 2 copies of my app"), and Kubernetes handles the rest automatically

### Key Kubernetes Concepts

#### **1. Pod**
- **What it is**: The smallest deployable unit in Kubernetes
- **Contains**: One or more containers (usually one)
- **Lifecycle**: Pods are created, run, and can be destroyed/recreated
- **Analogy**: A pod is like a "wrapper" around your container

#### **2. Deployment**
- **What it is**: A controller that manages pods
- **Purpose**: Ensures a specified number of pod replicas are running
- **Features**: Auto-restarts failed pods, handles updates, maintains desired state
- **Analogy**: Deployment is like a "manager" that ensures you always have X copies of your app running

#### **3. Service**
- **What it is**: A stable network endpoint to access pods
- **Purpose**: Provides a consistent way to reach your application
- **Problem it solves**: Pods have temporary IPs that change; Services provide a stable address
- **Types**: ClusterIP (internal), LoadBalancer (external), NodePort
- **Analogy**: Service is like a "phone number" that always works, even if you change phones (pods)

#### **4. ConfigMap**
- **What it is**: Stores non-sensitive configuration data
- **Purpose**: Separates configuration from application code
- **Contains**: Environment variables, config files, URLs, feature flags
- **Analogy**: ConfigMap is like a "settings file" you can change without rebuilding your app

#### **5. Secret**
- **What it is**: Stores sensitive data (encrypted at rest)
- **Purpose**: Securely stores passwords, connection strings, API keys
- **Contains**: Database passwords, TLS certificates, API tokens
- **Analogy**: Secret is like a "locked safe" for sensitive information

#### **6. Namespace**
- **What it is**: A virtual cluster within a Kubernetes cluster
- **Purpose**: Organizes and isolates resources
- **Use cases**: Separate environments (dev, staging, prod), team isolation
- **Analogy**: Namespace is like a "folder" that groups related resources together

---

## What You Build in POC-5

For each microservice (ProductService, OrderService, NotificationService), you create:

1. **Deployment** → Runs your application containers
2. **Service** → Provides network access to your pods
3. **ConfigMap** → Stores application configuration
4. **Secret** → Stores sensitive data (database connections)

All organized in a **namespace** called `microservices`.

---

## Understanding Kubernetes Manifests (YAML Files)

Kubernetes uses YAML files (called "manifests") to define resources. Each file describes what you want Kubernetes to create.

### Deployment Manifest Structure

```yaml
apiVersion: apps/v1          # Kubernetes API version
kind: Deployment             # Type of resource
metadata:                    # Identification info
  name: productservice
  namespace: microservices
spec:                        # Desired state
  replicas: 2                # Run 2 copies
  selector:                  # How to find pods
    matchLabels:
      app: productservice
  template:                  # Pod template
    metadata:
      labels:
        app: productservice
    spec:
      containers:
      - name: productservice
        image: acr.azurecr.io/productservice:v1.0.0
        ports:
        - containerPort: 8080
```

**Key Sections Explained:**

- **apiVersion**: Kubernetes API version
- **kind**: Type of resource (Deployment, Service, ConfigMap, etc.)
- **metadata**: Name, namespace, labels (for identification)
- **spec**: The desired configuration (what you want)
- **replicas**: How many pod copies to run
- **selector**: Labels used to find and manage pods
- **template**: The pod specification (what each pod should look like)

### Service Manifest Structure

```yaml
apiVersion: v1
kind: Service
metadata:
  name: productservice
  namespace: microservices
spec:
  type: ClusterIP           # Internal-only access
  ports:
  - port: 80                # Service port (external)
    targetPort: 8080        # Pod port (internal)
  selector:
    app: productservice      # Routes to pods with this label
```

**How Service Works:**

1. Service listens on port 80
2. When traffic arrives, Service finds pods with label `app: productservice`
3. Forwards traffic to pod's port 8080
4. Load balances across multiple pods if they exist

### ConfigMap Manifest Structure

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: productservice-config
  namespace: microservices
data:                       # Key-value pairs
  AppSettings:ApiUrl: "https://api.example.com"
  Logging:Level: "Information"
```

**Usage in Deployment:**

```yaml
env:
- name: ApiUrl
  valueFrom:
    configMapKeyRef:
      name: productservice-config
      key: AppSettings:ApiUrl
```

### Secret Manifest Structure

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: productservice-secret
  namespace: microservices
type: Opaque
data:                       # Base64 encoded values
  ConnectionString: <base64-encoded-value>
```

**Important**: Secrets store base64-encoded values (not encrypted, just encoded). Always use proper secret management in production.

---

## Step-by-Step Deployment Process

### Step 1: Create Namespace

```powershell
kubectl create namespace microservices
```

**What happens**: Kubernetes creates a logical boundary for your resources. All your microservices will live in this namespace.

**Verify**:
```powershell
kubectl get namespaces
```

### Step 2: Apply Manifests Structure

```
infra/k8s/
├── namespaces.yaml
├── productservice/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── secret.yaml
├── orderservice/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── secret.yaml
└── notificationservice/
    ├── deployment.yaml
    ├── service.yaml
    ├── configmap.yaml
    └── secret.yaml
```

### Step 3: Apply Resources

```powershell
# Apply namespace
kubectl apply -f infra/k8s/namespaces.yaml

# Apply each service
kubectl apply -f infra/k8s/productservice/ -n microservices
kubectl apply -f infra/k8s/orderservice/ -n microservices
kubectl apply -f infra/k8s/notificationservice/ -n microservices
```

**What `kubectl apply` does**:
- Reads YAML files
- Creates resources if they don't exist
- Updates resources if they already exist (declarative)
- Applies to specified namespace (`-n microservices`)

### Step 4: Verify Deployment

```powershell
# Check pods (containers)
kubectl get pods -n microservices

# Expected output:
# NAME                              READY   STATUS    RESTARTS   AGE
# productservice-7d8f9c4b5-abc12    1/1     Running   0          2m
# productservice-7d8f9c4b5-xyz34    1/1     Running   0          2m
# orderservice-6a7b8c9d0-def56      1/1     Running   0          2m
```

**Pod Status Meanings**:
- **Running**: Pod is healthy and running
- **Pending**: Pod is being scheduled/created
- **CrashLoopBackOff**: Pod keeps crashing (check logs)
- **Error**: Pod failed to start

```powershell
# Check services
kubectl get services -n microservices

# Expected output:
# NAME              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
# productservice    ClusterIP   10.0.1.100    <none>        80/TCP    2m
# orderservice      ClusterIP   10.0.1.101    <none>        80/TCP    2m
```

```powershell
# Check configmaps
kubectl get configmaps -n microservices

# Check secrets (names only, values hidden)
kubectl get secrets -n microservices
```

### Step 5: Test Your Deployment

```powershell
# Port forward to access service locally
kubectl port-forward -n microservices svc/productservice 5000:80
```

**What this does**:
- Creates a tunnel from your local machine (port 5000) to the Kubernetes service (port 80)
- Allows you to test: `http://localhost:5000/health`

**Access from other pods**:
- Service name becomes a DNS name: `http://productservice:80`
- Other services can call: `http://productservice/health`

---

## Key Configuration Details

### Resource Limits

```yaml
resources:
  limits:
    cpu: 500m        # 0.5 CPU cores (maximum)
    memory: 512Mi    # 512 MB RAM (maximum)
  requests:
    cpu: 250m        # 0.25 CPU cores (guaranteed)
    memory: 256Mi    # 256 MB RAM (guaranteed)
```

**Why important**:
- **Limits**: Prevents a pod from consuming too many resources
- **Requests**: Ensures pod gets minimum resources needed
- Helps Kubernetes schedule pods efficiently

### Replicas

```yaml
replicas: 2
```

**Why 2 replicas**:
- **High availability**: If one pod fails, the other continues serving
- **Load distribution**: Traffic is split between pods
- **Zero downtime updates**: Can update one pod while the other serves traffic

### Port Mapping

```yaml
# In Deployment (container)
ports:
- containerPort: 8080    # Port your app listens on

# In Service
ports:
- port: 80                # Port Service exposes
  targetPort: 8080        # Port to forward to pod
```

**Why different ports**:
- Container port (8080): Your application's actual port
- Service port (80): Standard HTTP port, easier to remember
- Kubernetes handles the mapping automatically

---

## Common Commands Reference

### Viewing Resources

```powershell
# List all pods
kubectl get pods -n microservices

# List with more details
kubectl get pods -n microservices -o wide

# Describe a pod (detailed info)
kubectl describe pod <pod-name> -n microservices

# View pod logs
kubectl logs <pod-name> -n microservices

# Follow logs (like tail -f)
kubectl logs -f <pod-name> -n microservices
```

### Debugging

```powershell
# Execute command in running pod
kubectl exec -it <pod-name> -n microservices -- /bin/sh

# Check events (what's happening)
kubectl get events -n microservices --sort-by='.lastTimestamp'

# View resource YAML
kubectl get deployment productservice -n microservices -o yaml
```

### Updating Resources

```powershell
# Edit resource directly
kubectl edit deployment productservice -n microservices

# Apply updated YAML
kubectl apply -f infra/k8s/productservice/deployment.yaml -n microservices

# Delete resource
kubectl delete deployment productservice -n microservices
```

---

## Troubleshooting Common Issues

### Issue 1: Pods Not Starting

**Symptoms**: Pods stuck in `Pending` or `CrashLoopBackOff`

**Solutions**:
```powershell
# Check pod status
kubectl describe pod <pod-name> -n microservices

# Check logs
kubectl logs <pod-name> -n microservices

# Common causes:
# - Image pull errors (wrong image name/tag)
# - Resource limits too low
# - Configuration errors
```

### Issue 2: Cannot Access Service

**Symptoms**: Port forward works but service doesn't respond

**Solutions**:
```powershell
# Verify service exists
kubectl get svc productservice -n microservices

# Check service endpoints (which pods it routes to)
kubectl get endpoints productservice -n microservices

# Verify pod labels match service selector
kubectl get pods -n microservices --show-labels
```

### Issue 3: Configuration Not Applied

**Symptoms**: Environment variables not set correctly

**Solutions**:
```powershell
# Check ConfigMap exists
kubectl get configmap productservice-config -n microservices

# View ConfigMap contents
kubectl get configmap productservice-config -n microservices -o yaml

# Verify deployment references ConfigMap correctly
kubectl describe deployment productservice -n microservices
```

---

## Best Practices

1. **Use Namespaces**: Organize resources by environment or team
2. **Set Resource Limits**: Prevent resource exhaustion
3. **Use Multiple Replicas**: Ensure high availability
4. **Separate Config from Code**: Use ConfigMaps for configuration
5. **Secure Secrets**: Never commit secrets to Git, use proper secret management
6. **Label Everything**: Use consistent labels for easy resource management
7. **Version Your Images**: Use semantic versioning (v1.0.0, v1.1.0)

---

## Summary

POC-5 teaches you the fundamentals of Kubernetes deployment:
- ✅ Understanding core Kubernetes resources (Pods, Deployments, Services, ConfigMaps, Secrets)
- ✅ Creating and organizing Kubernetes manifests
- ✅ Deploying microservices to AKS
- ✅ Verifying and testing deployments
- ✅ Basic troubleshooting and debugging

This foundation is essential before moving to advanced topics like rolling updates, health probes, and scaling.

---

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

