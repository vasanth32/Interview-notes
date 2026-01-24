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

---

# POC-7: Microservice Routing (Ingress) - Infrastructure Explanation

## Overview

POC-7 introduces **Ingress** - a way to expose your microservices to the outside world through a single entry point. Instead of managing multiple external IPs or port-forwarding, you use an Ingress Controller to route traffic to the right service based on the URL path. Think of it as a "smart traffic director" that sits in front of your services.

---

## The Problem: Why Do We Need Ingress?

### Without Ingress:

Imagine you have 3 microservices running in Kubernetes:
- ProductService (internal service)
- OrderService (internal service)
- NotificationService (internal service)

**Problem 1: No External Access**
- Services are only accessible inside the cluster (ClusterIP)
- You'd need to use `kubectl port-forward` for each service
- Not practical for production

**Problem 2: Multiple External IPs**
- If you use LoadBalancer for each service, you get 3 separate IPs
- Users need to remember: `http://ip1/products`, `http://ip2/orders`, `http://ip3/notifications`
- Expensive (each LoadBalancer costs money)

**Problem 3: No URL-Based Routing**
- Can't route based on path (`/products`, `/orders`)
- Can't use domain names easily
- Can't handle SSL/TLS termination centrally

### With Ingress:

✅ **Single Entry Point**: One external IP for all services
✅ **Path-Based Routing**: `/products/*` → ProductService, `/orders/*` → OrderService
✅ **Domain Names**: Use one domain like `api.example.com`
✅ **SSL/TLS**: Handle HTTPS certificates in one place
✅ **Cost Effective**: One LoadBalancer instead of many

---

## What is Ingress?

**Ingress** is a Kubernetes resource that defines rules for routing external HTTP/HTTPS traffic to services inside your cluster.

### Components:

1. **Ingress Resource** (YAML file)
   - Defines routing rules
   - Specifies which paths go to which services
   - Like a "routing table"

2. **Ingress Controller** (Running software)
   - Actually implements the routing
   - Listens for incoming traffic
   - Routes based on Ingress rules
   - Common options: NGINX, Traefik, Azure Application Gateway

### Analogy:

Think of Ingress like a **receptionist at a building**:
- **Ingress Controller** = The receptionist (person doing the work)
- **Ingress Resource** = The directory/instructions (what the receptionist follows)
- **External Traffic** = Visitors coming to the building
- **Services** = Different offices in the building

When someone asks "Where is the Products department?", the receptionist (Ingress Controller) checks the directory (Ingress Resource) and directs them to the right office (Service).

---

## How Ingress Works

### Step-by-Step Flow:

```
1. User Request
   ↓
   http://api.example.com/products/123
   
2. DNS Resolution
   ↓
   Resolves to Ingress Controller's External IP
   
3. Ingress Controller Receives Request
   ↓
   Checks Ingress rules to find matching path
   
4. Routing Decision
   ↓
   Path "/products/*" matches → Route to productservice:80
   
5. Service Routes to Pod
   ↓
   productservice Service → ProductService Pod
   
6. Response
   ↓
   Pod → Service → Ingress Controller → User
```

### Visual Representation:

```
Internet
   │
   │ http://api.example.com/products/123
   ↓
┌─────────────────────────────────────┐
│   Ingress Controller (NGINX)        │
│   External IP: 20.123.45.67         │
│                                      │
│   Routing Rules:                    │
│   /products/* → productservice      │
│   /orders/* → orderservice           │
│   /notifications/* → notificationservice│
└─────────────────────────────────────┘
   │
   ├─→ productservice:80 (ClusterIP)
   │      │
   │      └─→ ProductService Pod
   │
   ├─→ orderservice:80 (ClusterIP)
   │      │
   │      └─→ OrderService Pod
   │
   └─→ notificationservice:80 (ClusterIP)
          │
          └─→ NotificationService Pod
```

---

## NGINX Ingress Controller

### What is NGINX?

**NGINX** (pronounced "engine-x") is a popular web server and reverse proxy. The NGINX Ingress Controller is a special version that runs in Kubernetes and implements Ingress rules.

### Why NGINX?

- ✅ **Popular**: Most widely used Ingress Controller
- ✅ **Feature-Rich**: SSL termination, rate limiting, path rewriting
- ✅ **Well-Documented**: Lots of examples and community support
- ✅ **Azure Compatible**: Works well with Azure Load Balancer

### How It's Deployed:

The NGINX Ingress Controller runs as:
- **Deployment**: The actual NGINX pods
- **Service (LoadBalancer)**: Gets an external IP from Azure
- **ConfigMap**: NGINX configuration
- **ServiceAccount**: Permissions to read Ingress resources

---

## Ingress Resource Structure

### Basic Ingress YAML:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices-ingress
  namespace: microservices
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /products
        pathType: Prefix
        backend:
          service:
            name: productservice
            port:
              number: 80
      - path: /orders
        pathType: Prefix
        backend:
          service:
            name: orderservice
            port:
              number: 80
      - path: /notifications
        pathType: Prefix
        backend:
          service:
            name: notificationservice
            port:
              number: 80
```

### Key Sections Explained:

#### **metadata.annotations**
- **ssl-redirect**: Automatically redirect HTTP to HTTPS
- **rate-limit**: Limit requests per minute
- **rewrite-target**: Modify the path before forwarding

#### **spec.rules**
- Defines routing rules
- Each rule has a `path` and `backend` (service to route to)

#### **pathType**
- **Prefix**: Matches paths starting with `/products` (e.g., `/products`, `/products/123`)
- **Exact**: Matches exactly `/products` (not `/products/123`)
- **ImplementationSpecific**: Depends on Ingress Controller

#### **backend**
- Which service to route to
- Service name and port number

---

## Path-Based Routing Explained

### Example Requests:

```
Request: http://20.123.45.67/products/health
  ↓
Ingress Controller checks rules:
  - /products matches? ✅ Yes
  ↓
Routes to: productservice:80
  ↓
Service forwards to: ProductService Pod
  ↓
Response: {"status": "healthy"}
```

```
Request: http://20.123.45.67/orders/123
  ↓
Ingress Controller checks rules:
  - /orders matches? ✅ Yes
  ↓
Routes to: orderservice:80
  ↓
Service forwards to: OrderService Pod
  ↓
Response: Order details
```

```
Request: http://20.123.45.67/unknown
  ↓
Ingress Controller checks rules:
  - No match found
  ↓
Returns: 404 Not Found
```

### Path Matching Priority:

NGINX Ingress matches paths in order:
1. **Longest path first** (most specific)
2. **Exact matches** before prefix matches

Example:
```yaml
paths:
- path: /products/special    # More specific - checked first
  pathType: Prefix
- path: /products             # Less specific - checked second
  pathType: Prefix
```

---

## TLS/SSL Termination

### What is TLS Termination?

**TLS Termination** means the Ingress Controller handles HTTPS encryption/decryption, and forwards unencrypted HTTP to your services inside the cluster.

### Why Terminate at Ingress?

✅ **Performance**: Services don't need to handle SSL overhead
✅ **Centralized**: Manage certificates in one place
✅ **Simpler**: Services just use HTTP internally
✅ **Cost**: One certificate instead of many

### Flow with TLS:

```
1. User sends HTTPS request
   https://api.example.com/products
   ↓
2. Ingress Controller receives (encrypted)
   ↓
3. Ingress Controller decrypts using certificate
   ↓
4. Forwards as HTTP to service (inside cluster is safe)
   http://productservice:80/products
   ↓
5. Service responds with HTTP
   ↓
6. Ingress Controller encrypts response
   ↓
7. Sends HTTPS response to user
```

### TLS Configuration:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices-ingress
spec:
  tls:
  - hosts:
    - api.example.com
    secretName: tls-secret  # Certificate stored in Kubernetes Secret
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /products
        backend:
          service:
            name: productservice
            port:
              number: 80
```

---

## Step-by-Step Implementation

### Step 1: Install NGINX Ingress Controller

```powershell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

**What this does:**
- Creates `ingress-nginx` namespace
- Deploys NGINX Ingress Controller pods
- Creates a LoadBalancer service
- Azure automatically assigns an external IP

**Verify installation:**
```powershell
# Check pods are running
kubectl get pods -n ingress-nginx

# Check service (wait for EXTERNAL-IP)
kubectl get service ingress-nginx-controller -n ingress-nginx
```

### Step 2: Create Ingress Rules

Create `ingress-rules.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices-ingress
  namespace: microservices
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"  # Set to true when you have SSL
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /products
        pathType: Prefix
        backend:
          service:
            name: productservice
            port:
              number: 80
      - path: /orders
        pathType: Prefix
        backend:
          service:
            name: orderservice
            port:
              number: 80
      - path: /notifications
        pathType: Prefix
        backend:
          service:
            name: notificationservice
            port:
              number: 80
```

**Apply the rules:**
```powershell
kubectl apply -f infra/k8s/ingress/ingress-rules.yaml
```

### Step 3: Get External IP

```powershell
# Get the external IP
$EXTERNAL_IP = (kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Display it
Write-Host "Ingress External IP: $EXTERNAL_IP"
```

**Note**: It may take 2-3 minutes for Azure to assign the IP.

### Step 4: Test Routing

```powershell
# Test ProductService
curl http://$EXTERNAL_IP/products/health

# Test OrderService
curl http://$EXTERNAL_IP/orders/health

# Test NotificationService
curl http://$EXTERNAL_IP/notifications/health
```

**Expected Results:**
- Each request should reach the correct service
- You get responses from the appropriate microservice
- All requests go through the same IP address

---

## Path Rewriting

### The Problem:

Your services might expect paths like:
- ProductService: `/api/products`
- OrderService: `/api/orders`

But Ingress receives:
- `/products/*`
- `/orders/*`

### Solution: Path Rewriting

```yaml
annotations:
  nginx.ingress.kubernetes.io/rewrite-target: /api$2
  nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  rules:
  - http:
      paths:
      - path: /products(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: productservice
            port:
              number: 80
```

**What happens:**
- Request: `/products/123`
- Rewritten to: `/api/products/123`
- Forwarded to ProductService

---

## Common Annotations

### SSL Redirect:

```yaml
annotations:
  nginx.ingress.kubernetes.io/ssl-redirect: "true"
```
Forces all HTTP traffic to HTTPS.

### Rate Limiting:

```yaml
annotations:
  nginx.ingress.kubernetes.io/limit-rps: "100"
```
Limits to 100 requests per second per IP.

### CORS:

```yaml
annotations:
  nginx.ingress.kubernetes.io/enable-cors: "true"
  nginx.ingress.kubernetes.io/cors-allow-origin: "https://example.com"
```
Enables Cross-Origin Resource Sharing.

### Authentication:

```yaml
annotations:
  nginx.ingress.kubernetes.io/auth-type: basic
  nginx.ingress.kubernetes.io/auth-secret: basic-auth
```
Adds basic authentication.

---

## Troubleshooting

### Issue 1: No External IP

**Symptoms**: `EXTERNAL-IP` shows `<pending>`

**Solutions**:
```powershell
# Check if LoadBalancer is provisioning
kubectl describe service ingress-nginx-controller -n ingress-nginx

# Check Azure Load Balancer in Azure Portal
# May take 2-5 minutes

# Verify AKS has proper permissions
```

### Issue 2: 404 Not Found

**Symptoms**: Requests return 404

**Solutions**:
```powershell
# Check Ingress rules are applied
kubectl get ingress -n microservices

# Check Ingress details
kubectl describe ingress microservices-ingress -n microservices

# Verify services exist
kubectl get services -n microservices

# Check NGINX logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

### Issue 3: Wrong Service Responding

**Symptoms**: `/products` goes to OrderService

**Solutions**:
```powershell
# Check path matching order
kubectl get ingress microservices-ingress -n microservices -o yaml

# Verify pathType is correct (Prefix vs Exact)
# Check if paths overlap incorrectly
```

### Issue 4: 502 Bad Gateway

**Symptoms**: Ingress receives request but service doesn't respond

**Solutions**:
```powershell
# Check if pods are running
kubectl get pods -n microservices

# Check service endpoints
kubectl get endpoints productservice -n microservices

# Verify service port matches
kubectl describe service productservice -n microservices
```

---

## Best Practices

1. **Use Path Prefixes**: Use `pathType: Prefix` for flexible routing
2. **Centralize SSL**: Handle TLS at Ingress, not in services
3. **Use Annotations**: Leverage NGINX features (rate limiting, CORS)
4. **Monitor Ingress**: Watch Ingress Controller logs and metrics
5. **Test Paths**: Verify all routes work before production
6. **Use DNS**: Point domain names to Ingress IP for better UX
7. **Health Checks**: Ensure services have health endpoints for monitoring

---

## Real-World Example

### Complete Setup:

```yaml
# ingress-rules.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: microservices
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/cors-allow-origin: "https://myapp.com"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.mycompany.com
    secretName: tls-certificate
  rules:
  - host: api.mycompany.com
    http:
      paths:
      - path: /products
        pathType: Prefix
        backend:
          service:
            name: productservice
            port:
              number: 80
      - path: /orders
        pathType: Prefix
        backend:
          service:
            name: orderservice
            port:
              number: 80
```

**User Experience:**
- User visits: `https://api.mycompany.com/products/123`
- DNS resolves to Ingress IP
- Ingress routes to ProductService
- Gets product details
- All through one domain, one IP, one certificate

---

## Summary

POC-7 introduces Ingress as the gateway to your microservices:
- ✅ **Single Entry Point**: One external IP for all services
- ✅ **Path-Based Routing**: Route traffic based on URL paths
- ✅ **TLS Termination**: Handle HTTPS at the edge
- ✅ **Cost Effective**: One LoadBalancer instead of many
- ✅ **Feature-Rich**: Rate limiting, CORS, authentication via annotations

Ingress is essential for exposing microservices in a production-ready, scalable way. It's the "front door" to your Kubernetes cluster.

---

# POC-8: Secure Inter-Service Access - Infrastructure Explanation

## Overview

POC-8 focuses on **security** - protecting your secrets (passwords, connection strings, API keys) and securing communication between services. This phase introduces Azure Key Vault for secret management and JWT authentication for secure API access. Think of it as adding "locks and keys" to your microservices architecture.

---

## The Security Problem

### The Problem: Where to Store Secrets?

Your microservices need sensitive information:
- **Database connection strings** (with passwords)
- **API keys** for external services
- **JWT signing keys**
- **Service Bus connection strings**

### ❌ Bad Approaches:

#### **1. Hardcoded in Code**
```csharp
// ❌ NEVER DO THIS!
var connectionString = "Server=db;Database=MyDb;User=admin;Password=SuperSecret123!";
```
**Problems:**
- Secrets visible in source code
- Committed to Git (permanent exposure)
- Can't change without redeploying
- Anyone with code access sees secrets

#### **2. In appsettings.json**
```json
// ❌ STILL BAD!
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=db;Password=SuperSecret123!"
  }
}
```
**Problems:**
- Committed to Git repositories
- Visible in file system
- No access control
- No audit trail

#### **3. Environment Variables**
```yaml
# ❌ BETTER BUT NOT IDEAL
env:
- name: ConnectionString
  value: "Server=db;Password=SuperSecret123!"
```
**Problems:**
- Visible in Kubernetes manifests
- Logged in various places
- Hard to rotate secrets
- No centralized management

### ✅ The Solution: Azure Key Vault

**Azure Key Vault** is a cloud service for securely storing and accessing secrets, keys, and certificates.

**Benefits:**
- ✅ **Encrypted at rest**: Secrets are encrypted
- ✅ **Access Control**: Only authorized services can read
- ✅ **Audit Trail**: Logs who accessed what and when
- ✅ **Secret Rotation**: Update secrets without code changes
- ✅ **Centralized**: All secrets in one place
- ✅ **Versioning**: Track secret versions

---

## What is Azure Key Vault?

### Analogy:

Think of Azure Key Vault like a **high-security bank vault**:
- **Secrets** = Valuables stored in the vault
- **Access Policies** = Who has keys to the vault
- **Audit Logs** = Security camera recordings
- **Managed Identity** = Your ID badge that grants access

### Key Vault Components:

1. **Secrets**: Passwords, connection strings, API keys
2. **Keys**: Cryptographic keys for encryption
3. **Certificates**: SSL/TLS certificates
4. **Access Policies**: Who can read/write secrets

### How It Works:

```
Your Service
   │
   │ "I need the database connection string"
   │
   ↓
Azure Key Vault
   │
   │ "Who are you? Let me check your identity..."
   │
   │ ✅ Identity verified (Managed Identity)
   │ ✅ Access policy allows "get" operation
   │
   ↓
Returns encrypted secret
   │
   ↓
Service decrypts and uses it
```

---

## Managed Identity: The Key to Key Vault

### What is Managed Identity?

**Managed Identity** is an Azure feature that gives your services an identity (like a username) without you having to manage passwords or certificates.

### Why Managed Identity?

**Without Managed Identity:**
```csharp
// ❌ You need to store credentials to authenticate
var clientId = "your-client-id";
var clientSecret = "your-client-secret"; // Another secret to manage!
var credential = new ClientSecretCredential(tenantId, clientId, clientSecret);
```

**Problems:**
- Need to store client ID and secret somewhere
- Secrets expire and need rotation
- More secrets to manage = more risk

**With Managed Identity:**
```csharp
// ✅ No credentials needed!
var credential = new DefaultAzureCredential(); // Automatically uses Managed Identity
```

**Benefits:**
- ✅ No passwords to manage
- ✅ Automatically rotated by Azure
- ✅ No credentials in code or config
- ✅ Works seamlessly in Azure

### Types of Managed Identity:

1. **System-Assigned** (What we use)
   - Created automatically for AKS
   - Tied to the AKS cluster lifecycle
   - Unique to that resource

2. **User-Assigned** (Alternative)
   - Created separately
   - Can be assigned to multiple resources
   - More flexible for complex scenarios

---

## How Managed Identity Works with Key Vault

### Step-by-Step Flow:

```
1. AKS Cluster Created
   ↓
2. Azure automatically creates Managed Identity
   ↓
3. Identity gets a unique ID (Principal ID)
   ↓
4. Grant Key Vault access to this Principal ID
   ↓
5. Pods in AKS use this identity automatically
   ↓
6. When pod requests secret from Key Vault:
   - Key Vault checks: "Is this Principal ID allowed?"
   - ✅ Yes → Returns secret
   - ❌ No → Returns 403 Forbidden
```

### Visual Representation:

```
┌─────────────────────────────────────┐
│   AKS Cluster                        │
│   Managed Identity: abc-123-xyz      │
│                                      │
│   ┌─────────────────────────────┐   │
│   │ ProductService Pod           │   │
│   │                              │   │
│   │ Requests:                    │   │
│   │ "Get secret:                 │   │
│   │  ConnectionString"           │   │
│   │                              │   │
│   │ Uses Managed Identity        │   │
│   │ automatically                │   │
│   └─────────────────────────────┘   │
└─────────────────────────────────────┘
           │
           │ Authenticates as: abc-123-xyz
           ↓
┌─────────────────────────────────────┐
│   Azure Key Vault                    │
│                                      │
│   Access Policy:                     │
│   - Principal: abc-123-xyz           │
│   - Permissions: get, list           │
│                                      │
│   Secrets:                           │
│   - ConnectionString: "Server=..."   │
│   - ApiKey: "key-123"                │
└─────────────────────────────────────┘
```

---

## Secret Naming Convention

### How Secrets are Named:

Key Vault uses a **hierarchical naming** that maps to .NET configuration:

```
Secret Name: ProductService--ConnectionStrings--DefaultConnection
                │              │                  │
                │              │                  └─ Configuration key
                │              └─ Configuration section
                └─ Service name (optional prefix)
```

**Maps to .NET Configuration:**
```json
{
  "ProductService": {
    "ConnectionStrings": {
      "DefaultConnection": "<value from Key Vault>"
    }
  }
}
```

### Example Secrets:

```
Key Vault Secret Name → .NET Configuration Path

ProductService--ConnectionStrings--DefaultConnection
  → ProductService:ConnectionStrings:DefaultConnection

OrderService--ServiceBus--ConnectionString
  → OrderService:ServiceBus:ConnectionString

Shared--JwtSettings--SecretKey
  → Shared:JwtSettings:SecretKey
```

---

## JWT Authentication: Securing API Access

### What is JWT?

**JWT (JSON Web Token)** is a way to securely transmit information between parties. It's like a "temporary ID card" that proves who you are.

### JWT Structure:

A JWT has three parts separated by dots:

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
   │                              │                                                              │
   │                              │                                                              └─ Signature (verifies token)
   │                              └─ Payload (user info, claims)
   └─ Header (algorithm, token type)
```

### How JWT Authentication Works:

```
1. User Logs In
   ↓
2. Authentication Server validates credentials
   ↓
3. Server creates JWT token with user info
   ↓
4. Token returned to user
   ↓
5. User includes token in API requests:
   Authorization: Bearer <token>
   ↓
6. API validates token:
   - Is signature valid?
   - Is token expired?
   - Does user have permission?
   ↓
7. If valid → Process request
   If invalid → Return 401 Unauthorized
```

### JWT Claims:

**Standard Claims:**
- `sub` (subject): User ID
- `exp` (expiration): When token expires
- `iat` (issued at): When token was created
- `iss` (issuer): Who created the token

**Custom Claims:**
- `role`: User's role (Admin, User)
- `email`: User's email
- `permissions`: What user can do

### Example JWT Payload:

```json
{
  "sub": "user123",
  "name": "John Doe",
  "email": "john@example.com",
  "role": "Admin",
  "iat": 1516239022,
  "exp": 1516242622
}
```

---

## Complete Security Flow

### End-to-End Example:

```
┌─────────────┐
│   User      │
│  (Browser)  │
└──────┬──────┘
       │
       │ 1. POST /api/auth/login
       │    { username, password }
       ↓
┌─────────────────────────────────────┐
│   Authentication Service             │
│                                      │
│   - Validates credentials            │
│   - Creates JWT token                │
│   - Signs with secret from Key Vault │
│                                      │
│   Returns: { token: "eyJ..." }      │
└─────────────────────────────────────┘
       │
       │ 2. Token returned
       ↓
┌─────────────┐
│   User       │
│  Stores token│
└──────┬───────┘
       │
       │ 3. GET /api/products
       │    Authorization: Bearer eyJ...
       ↓
┌─────────────────────────────────────┐
│   Ingress Controller                 │
│   (NGINX)                            │
│                                      │
│   - Extracts JWT from header         │
│   - Validates token                  │
│   - Checks expiration                │
│   - Extracts user claims             │
│                                      │
│   ✅ Valid → Forward to service      │
│   ❌ Invalid → Return 401            │
└─────────────────────────────────────┘
       │
       │ 4. Request with user context
       ↓
┌─────────────────────────────────────┐
│   ProductService                     │
│                                      │
│   - Gets connection string from     │
│     Key Vault (using Managed ID)    │
│   - Processes request                │
│   - Returns data                     │
└─────────────────────────────────────┘
```

---

## Implementation Details

### Step 1: Enable Managed Identity for AKS

```powershell
az aks update --resource-group rg-microservices-poc --name aks-microservices-poc --enable-managed-identity
```

**What this does:**
- Creates a system-assigned managed identity for AKS
- This identity can be used by all pods in the cluster
- No passwords or certificates needed

**Verify:**
```powershell
az aks show --resource-group rg-microservices-poc --name aks-microservices-poc --query identity
```

### Step 2: Create Key Vault

```powershell
az keyvault create --name mykeyvault-poc --resource-group rg-microservices-poc --location eastus
```

**What this creates:**
- A secure vault for storing secrets
- Encrypted storage
- Access control system

### Step 3: Grant AKS Access to Key Vault

```powershell
# Get the Managed Identity Principal ID
$AKS_IDENTITY = (az aks show --resource-group rg-microservices-poc --name aks-microservices-poc --query identity.principalId -o tsv)

# Grant access
az keyvault set-policy --name mykeyvault-poc --object-id $AKS_IDENTITY --secret-permissions get list
```

**What this does:**
- Allows AKS's Managed Identity to read secrets
- Only `get` and `list` permissions (can't modify)
- Principle of least privilege

### Step 4: Add Secrets to Key Vault

```powershell
az keyvault secret set --vault-name mykeyvault-poc --name "ProductService--ConnectionStrings--DefaultConnection" --value "Server=myserver;Database=ProductDb;User=admin;Password=Secret123!"
```

**Secret naming:**
- Use `--` (double dash) to separate hierarchy levels
- Maps to .NET configuration structure
- Can be read as: `ProductService:ConnectionStrings:DefaultConnection`

### Step 5: Configure Service to Use Key Vault

**In Program.cs:**

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add Key Vault as configuration source
var keyVaultUrl = builder.Configuration["KeyVault:VaultUrl"];
if (!string.IsNullOrEmpty(keyVaultUrl))
{
    builder.Configuration.AddAzureKeyVault(
        new Uri(keyVaultUrl),
        new DefaultAzureCredential() // Uses Managed Identity automatically
    );
}

var app = builder.Build();
```

**What happens:**
1. Service starts up
2. `DefaultAzureCredential()` automatically uses Managed Identity
3. Fetches secrets from Key Vault
4. Merges with existing configuration
5. Secrets available via `IConfiguration` like normal config

**Usage in code:**
```csharp
// Works exactly like appsettings.json!
var connectionString = _configuration.GetConnectionString("DefaultConnection");
// This value comes from Key Vault, not appsettings.json
```

---

## JWT Authentication Implementation

### Step 1: Configure JWT in Service

**In Program.cs:**

```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        var jwtSettings = builder.Configuration.GetSection("JwtSettings");
        var secretKey = jwtSettings["SecretKey"]; // From Key Vault!
        
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings["Issuer"],
            ValidAudience = jwtSettings["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(secretKey))
        };
    });

builder.Services.AddAuthorization();
```

### Step 2: Protect Endpoints

```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize] // Requires valid JWT token
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IActionResult GetProducts()
    {
        // Get user info from token
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var role = User.FindFirst(ClaimTypes.Role)?.Value;
        
        return Ok(_productService.GetAll());
    }
}
```

### Step 3: Validate Token at Ingress (Optional)

You can also validate JWT at the Ingress level using NGINX annotations:

```yaml
annotations:
  nginx.ingress.kubernetes.io/auth-url: "https://auth-service/validate"
  nginx.ingress.kubernetes.io/auth-signin: "https://auth-service/login"
```

---

## Security Best Practices

### 1. Principle of Least Privilege

**Grant minimum required permissions:**
```powershell
# ✅ Good: Only get and list
az keyvault set-policy --secret-permissions get list

# ❌ Bad: Full access
az keyvault set-policy --secret-permissions all
```

### 2. Secret Rotation

**Regularly rotate secrets:**
```powershell
# Update secret in Key Vault
az keyvault secret set --name "ConnectionString" --value "new-value"

# Services automatically pick up new value on next request
# No code changes needed!
```

### 3. Separate Secrets by Service

**Don't share secrets across services:**
```
✅ Good:
- ProductService--ConnectionString
- OrderService--ConnectionString

❌ Bad:
- Shared--ConnectionString (all services use same)
```

### 4. Use Short-Lived JWT Tokens

**Set reasonable expiration:**
```csharp
// ✅ Good: 1 hour
expires: DateTime.UtcNow.AddHours(1)

// ❌ Bad: 30 days
expires: DateTime.UtcNow.AddDays(30)
```

### 5. Monitor Access

**Enable Key Vault logging:**
```powershell
az monitor diagnostic-settings create --name keyvault-logs --resource <keyvault-id> --logs '[{"category":"AuditEvent","enabled":true}]'
```

---

## Troubleshooting

### Issue 1: "Access Denied" from Key Vault

**Symptoms**: Service can't read secrets

**Solutions:**
```powershell
# Check Managed Identity is enabled
az aks show --query identity

# Verify access policy
az keyvault show --name mykeyvault-poc --query properties.accessPolicies

# Check service is using Managed Identity
kubectl describe pod <pod-name> -n microservices
# Look for AZURE_CLIENT_ID environment variable
```

### Issue 2: Secret Not Found

**Symptoms**: Configuration key returns null

**Solutions:**
```powershell
# Verify secret exists
az keyvault secret list --vault-name mykeyvault-poc

# Check secret name matches configuration path
# Secret: "ProductService--ConnectionStrings--DefaultConnection"
# Config: "ProductService:ConnectionStrings:DefaultConnection"

# Check service logs
kubectl logs deployment/productservice -n microservices
```

### Issue 3: JWT Validation Fails

**Symptoms**: 401 Unauthorized even with valid token

**Solutions:**
```csharp
// Check token is being sent
// Header: Authorization: Bearer <token>

// Verify secret key matches
// Issuer and audience must match

// Check token expiration
// Token might be expired

// Enable detailed logging
builder.Services.AddAuthentication()
    .AddJwtBearer(options =>
    {
        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                _logger.LogError(context.Exception, "JWT validation failed");
                return Task.CompletedTask;
            }
        };
    });
```

---

## Real-World Example

### Complete Setup:

**1. Key Vault Secrets:**
```
mykeyvault-poc/
  ├── ProductService--ConnectionStrings--DefaultConnection
  ├── OrderService--ConnectionStrings--DefaultConnection
  ├── Shared--JwtSettings--SecretKey
  └── Shared--JwtSettings--Issuer
```

**2. Service Configuration:**
```csharp
// Program.cs
builder.Configuration.AddAzureKeyVault(
    new Uri("https://mykeyvault-poc.vault.azure.net/"),
    new DefaultAzureCredential()
);

// All secrets automatically available
var connectionString = builder.Configuration
    .GetConnectionString("DefaultConnection");
```

**3. JWT Authentication:**
```csharp
// User gets token from /api/auth/login
// Token stored in browser/localStorage

// Subsequent requests include:
// Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

// Service validates and processes request
```

---

## Summary

POC-8 implements comprehensive security for your microservices:
- ✅ **Azure Key Vault**: Centralized, encrypted secret storage
- ✅ **Managed Identity**: Passwordless authentication to Key Vault
- ✅ **JWT Authentication**: Secure API access with tokens
- ✅ **Access Control**: Fine-grained permissions
- ✅ **Audit Trail**: Track who accessed what secrets
- ✅ **Secret Rotation**: Update secrets without code changes

This security foundation ensures your microservices are production-ready and follow security best practices. Secrets are protected, access is controlled, and authentication is properly implemented.

---

# POC-9: Database Isolation - Infrastructure Explanation

## Overview

POC-9 implements **database per service** pattern - each microservice gets its own dedicated database. This is a fundamental principle of microservices architecture that ensures services are truly independent and can scale, deploy, and fail independently. Think of it as giving each service its own "private filing cabinet" instead of sharing one big cabinet.

---

## The Database Problem in Microservices

### The Problem: Shared Database

**Traditional Monolithic Approach:**
```
┌─────────────────────────────────────┐
│   Single Database                    │
│                                      │
│   Tables:                            │
│   - Products                         │
│   - Orders                           │
│   - Notifications                    │
│   - Users                            │
│   - All services share this!         │
└─────────────────────────────────────┘
         ↑         ↑         ↑
         │         │         │
    ProductService OrderService NotificationService
```

**Problems with Shared Database:**

1. **Tight Coupling**
   - Services depend on the same database schema
   - Changes to one service's tables affect others
   - Can't deploy services independently

2. **Scaling Issues**
   - Can't scale databases independently
   - One service's load affects all services
   - Database becomes a bottleneck

3. **Failure Isolation**
   - If database fails, all services fail
   - Can't isolate failures to one service

4. **Data Ownership**
   - Unclear who owns which data
   - Multiple services modifying same tables
   - Data consistency issues

5. **Technology Lock-in**
   - All services must use same database type
   - Can't choose best database for each service

### ✅ The Solution: Database per Service

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ ProductService   │    │ OrderService     │    │ NotificationService│
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ ProductDb   │ │    │ │ OrderDb     │ │    │ │ NotificationDb│
│ │ (SQL Server)│ │    │ │ (SQL Server)│ │    │ │ (Cosmos DB) │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Benefits:**
- ✅ **Independence**: Each service owns its data
- ✅ **Independent Scaling**: Scale databases separately
- ✅ **Technology Choice**: Use best DB for each service
- ✅ **Failure Isolation**: One DB failure doesn't affect others
- ✅ **Independent Deployment**: Deploy services without coordination

---

## What is Database Isolation?

### Analogy:

Think of database isolation like **separate bank accounts**:
- **Shared Database** = Joint bank account (everyone can access, conflicts possible)
- **Database per Service** = Individual bank accounts (each person manages their own)

### Key Principles:

1. **Data Ownership**: Each service owns and manages its own data
2. **No Direct Access**: Services cannot directly access other services' databases
3. **Communication via APIs**: Services communicate through APIs, not databases
4. **Schema Independence**: Each service can change its schema without affecting others

---

## Entity Framework Core: The Bridge to Databases

### What is Entity Framework Core (EF Core)?

**Entity Framework Core** is an Object-Relational Mapping (ORM) framework that lets you work with databases using .NET objects instead of writing SQL queries directly.

### Why Use EF Core?

**Without EF Core:**
```csharp
// ❌ Raw SQL - error-prone, hard to maintain
var sql = "SELECT * FROM Products WHERE Id = @id";
var product = connection.Query<Product>(sql, new { id = 1 });
```

**With EF Core:**
```csharp
// ✅ Type-safe, IntelliSense support
var product = await _context.Products.FindAsync(1);
```

**Benefits:**
- ✅ **Type Safety**: Compile-time checking
- ✅ **LINQ Support**: Query using C# LINQ
- ✅ **Migrations**: Version control for database schema
- ✅ **Change Tracking**: Automatic updates
- ✅ **Database Agnostic**: Works with SQL Server, PostgreSQL, MySQL, etc.

---

## Database Setup: Step by Step

### Step 1: Create Separate Databases

**In Azure SQL:**

```powershell
# Create ProductService database
az sql db create \
  --resource-group rg-microservices-poc \
  --server mysqlserver \
  --name ProductDb \
  --service-objective Basic

# Create OrderService database
az sql db create \
  --resource-group rg-microservices-poc \
  --server mysqlserver \
  --name OrderDb \
  --service-objective Basic
```

**What this creates:**
- Two separate databases on the same SQL Server
- Each database is isolated
- Can have different schemas, users, permissions

### Step 2: Configure Firewall Rules

```powershell
# Allow Azure services to access
az sql server firewall-rule create \
  --resource-group rg-microservices-poc \
  --server mysqlserver \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

**Why needed:**
- Azure SQL blocks all connections by default
- Firewall rules specify which IPs can connect
- `0.0.0.0` allows all Azure services (AKS pods)

### Step 3: Store Connection Strings in Key Vault

```powershell
# Get connection string
$connString = az sql db show-connection-string \
  --server mysqlserver \
  --name ProductDb \
  --client ado.net

# Store in Key Vault
az keyvault secret set \
  --vault-name mykeyvault-poc \
  --name "ProductService--ConnectionStrings--DefaultConnection" \
  --value $connString
```

**Connection String Format:**
```
Server=mysqlserver.database.windows.net;Database=ProductDb;User Id=admin;Password=***;Encrypt=True;
```

---

## Entity Framework Core Implementation

### Step 1: Install EF Core Packages

```powershell
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.EntityFrameworkCore.Design
```

### Step 2: Create DbContext

**ProductDbContext.cs:**

```csharp
using Microsoft.EntityFrameworkCore;

public class ProductDbContext : DbContext
{
    public ProductDbContext(DbContextOptions<ProductDbContext> options)
        : base(options)
    {
    }
    
    public DbSet<Product> Products { get; set; }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Configure entity relationships, constraints, etc.
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Price).HasColumnType("decimal(18,2)");
        });
    }
}
```

**What DbContext Does:**
- Represents a session with the database
- Tracks changes to entities
- Executes queries and saves changes
- Manages database connections

### Step 3: Create Entity Model

**Product.cs:**

```csharp
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public decimal Price { get; set; }
    public int Stock { get; set; }
    public string Category { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
```

### Step 4: Register DbContext in Program.cs

```csharp
var builder = WebApplication.CreateBuilder(args);

// Get connection string from Key Vault (via configuration)
var connectionString = builder.Configuration
    .GetConnectionString("DefaultConnection");

// Register DbContext
builder.Services.AddDbContext<ProductDbContext>(options =>
    options.UseSqlServer(connectionString));

var app = builder.Build();
```

**What this does:**
- Registers DbContext as a scoped service
- Configures SQL Server provider
- Connection string comes from Key Vault automatically

### Step 5: Use DbContext in Controllers

**ProductsController.cs:**

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly ProductDbContext _context;
    
    public ProductsController(ProductDbContext context)
    {
        _context = context;
    }
    
    [HttpGet]
    public async Task<ActionResult<List<Product>>> GetProducts()
    {
        return await _context.Products.ToListAsync();
    }
    
    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        var product = await _context.Products.FindAsync(id);
        if (product == null)
        {
            return NotFound();
        }
        return product;
    }
    
    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct(Product product)
    {
        _context.Products.Add(product);
        await _context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetProduct), 
            new { id = product.Id }, product);
    }
}
```

---

## Database Migrations

### What are Migrations?

**Migrations** are version control for your database schema. They track changes to your database structure over time.

### Why Migrations?

**Without Migrations:**
- Manual SQL scripts
- Hard to track changes
- Difficult to apply to different environments
- No rollback capability

**With Migrations:**
- ✅ Version controlled
- ✅ Repeatable across environments
- ✅ Can rollback changes
- ✅ Team collaboration

### Creating Migrations

```powershell
# Create initial migration
dotnet ef migrations add InitialCreate --project ProductService

# This creates:
# Migrations/
#   └── 20240115120000_InitialCreate.cs
```

**Migration File Structure:**

```csharp
public partial class InitialCreate : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "Products",
            columns: table => new
            {
                Id = table.Column<int>(type: "int", nullable: false)
                    .Annotation("SqlServer:Identity", "1, 1"),
                Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                // ... other columns
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Products", x => x.Id);
            });
    }
    
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "Products");
    }
}
```

**What this does:**
- `Up()`: Applies the migration (creates table)
- `Down()`: Rolls back the migration (drops table)

### Applying Migrations

**Option 1: Manual (Development)**

```powershell
dotnet ef database update --project ProductService
```

**Option 2: Automatic (Production)**

**In Program.cs:**

```csharp
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var context = services.GetRequiredService<ProductDbContext>();
    
    // Apply pending migrations on startup
    context.Database.Migrate();
}
```

**When to use each:**
- **Manual**: Development, testing migrations
- **Automatic**: Production, CI/CD pipelines

---

## Connection Pooling

### What is Connection Pooling?

**Connection Pooling** is a technique where database connections are reused instead of creating new ones for each request.

### Why Connection Pooling?

**Without Pooling:**
```
Request 1 → Create connection → Use → Close
Request 2 → Create connection → Use → Close
Request 3 → Create connection → Use → Close
```
**Problems:**
- Slow (creating connections is expensive)
- Resource intensive
- Can hit connection limits

**With Pooling:**
```
Request 1 → Get connection from pool → Use → Return to pool
Request 2 → Get connection from pool → Use → Return to pool
Request 3 → Get connection from pool → Use → Return to pool
```
**Benefits:**
- ✅ Fast (reuse existing connections)
- ✅ Efficient resource usage
- ✅ Better performance

### How EF Core Handles Pooling

**EF Core automatically pools connections:**

```csharp
// Connection string includes pooling settings
Server=myserver;Database=ProductDb;...;Max Pool Size=100;Min Pool Size=0;
```

**Default Behavior:**
- Creates pool of connections
- Reuses connections when possible
- Closes idle connections after timeout
- Maximum pool size: 100 (default)

**Configuration:**

```csharp
builder.Services.AddDbContext<ProductDbContext>(options =>
    options.UseSqlServer(connectionString, sqlOptions =>
    {
        sqlOptions.MaxBatchSize(100);
        sqlOptions.CommandTimeout(30);
    }));
```

---

## Private Endpoints (Advanced)

### What are Private Endpoints?

**Private Endpoints** allow you to access Azure services (like SQL Database) over a private IP address within your virtual network, instead of using public endpoints.

### Why Private Endpoints?

**Without Private Endpoint:**
```
AKS Pod → Internet → Azure SQL (Public IP)
```
**Issues:**
- Traffic goes over internet
- Public IP exposure
- Potential security risk

**With Private Endpoint:**
```
AKS Pod → Private Network → Azure SQL (Private IP)
```
**Benefits:**
- ✅ Traffic stays within Azure network
- ✅ No public IP exposure
- ✅ Better security
- ✅ Lower latency

### Configuration (Optional for POC):

```powershell
# Create private endpoint
az network private-endpoint create \
  --name sql-private-endpoint \
  --resource-group rg-microservices-poc \
  --vnet-name aks-vnet \
  --subnet aks-subnet \
  --private-connection-resource-id /subscriptions/.../sqlServers/myserver \
  --group-id sqlServer \
  --connection-name sql-connection
```

**Note**: For POC, public endpoints with firewall rules are sufficient. Private endpoints are for production hardening.

---

## Data Access Patterns

### Repository Pattern

**Why use Repository Pattern?**

- ✅ Abstracts data access logic
- ✅ Easier to test (mock repository)
- ✅ Can swap data sources easily

**Implementation:**

```csharp
public interface IProductRepository
{
    Task<Product> GetByIdAsync(int id);
    Task<List<Product>> GetAllAsync();
    Task<Product> CreateAsync(Product product);
    Task UpdateAsync(Product product);
    Task DeleteAsync(int id);
}

public class ProductRepository : IProductRepository
{
    private readonly ProductDbContext _context;
    
    public ProductRepository(ProductDbContext context)
    {
        _context = context;
    }
    
    public async Task<Product> GetByIdAsync(int id)
    {
        return await _context.Products.FindAsync(id);
    }
    
    public async Task<List<Product>> GetAllAsync()
    {
        return await _context.Products.ToListAsync();
    }
    
    public async Task<Product> CreateAsync(Product product)
    {
        _context.Products.Add(product);
        await _context.SaveChangesAsync();
        return product;
    }
    
    // ... other methods
}

// Register in Program.cs
builder.Services.AddScoped<IProductRepository, ProductRepository>();

// Use in Controller
public class ProductsController : ControllerBase
{
    private readonly IProductRepository _repository;
    
    public ProductsController(IProductRepository repository)
    {
        _repository = repository;
    }
    
    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        var product = await _repository.GetByIdAsync(id);
        if (product == null) return NotFound();
        return product;
    }
}
```

---

## Testing Database Isolation

### Verify Isolation:

**Test 1: ProductService can access ProductDb**
```powershell
# Create product via API
curl -X POST http://api/products -d '{"name":"Laptop","price":999}'

# Verify in database
az sql db query \
  --server mysqlserver \
  --database ProductDb \
  --query "SELECT * FROM Products"
```

**Test 2: OrderService cannot access ProductDb**
```csharp
// Try to access ProductDb from OrderService (should fail)
// OrderService only has connection to OrderDb
```

**Test 3: Services communicate via API, not database**
```csharp
// OrderService needs product info
// ✅ Correct: Call ProductService API
var product = await _httpClient.GetAsync("http://productservice/api/products/1");

// ❌ Wrong: Direct database access
// var product = _productDb.Products.Find(1); // Can't do this!
```

---

## Best Practices

### 1. One Database per Service

**✅ Good:**
```
ProductService → ProductDb
OrderService → OrderDb
NotificationService → NotificationDb
```

**❌ Bad:**
```
All Services → SharedDb
```

### 2. No Cross-Database Queries

**❌ Never do this:**
```sql
-- Don't join across databases
SELECT o.*, p.Name 
FROM OrderDb.Orders o
JOIN ProductDb.Products p ON o.ProductId = p.Id
```

**✅ Instead:**
```csharp
// Fetch data via API calls
var order = await GetOrderFromOrderService(id);
var product = await GetProductFromProductService(order.ProductId);
```

### 3. Use Migrations for Schema Changes

**✅ Good:**
```powershell
dotnet ef migrations add AddCategoryColumn
dotnet ef database update
```

**❌ Bad:**
```sql
-- Manual SQL changes
ALTER TABLE Products ADD Category VARCHAR(50);
```

### 4. Connection String Security

**✅ Good:**
- Store in Key Vault
- Use Managed Identity
- Rotate regularly

**❌ Bad:**
- Hardcoded in code
- In appsettings.json (committed to Git)
- Shared across services

### 5. Connection Pooling

**✅ Good:**
- Let EF Core handle pooling automatically
- Configure appropriate pool size
- Monitor connection usage

**❌ Bad:**
- Creating connections manually
- Not closing connections
- Too many concurrent connections

---

## Troubleshooting

### Issue 1: Cannot Connect to Database

**Symptoms**: `SqlException: Cannot open server`

**Solutions:**
```powershell
# Check firewall rules
az sql server firewall-rule list --server mysqlserver

# Verify connection string
az keyvault secret show --name "ProductService--ConnectionStrings--DefaultConnection"

# Test connection
az sql db show-connection-string --server mysqlserver --name ProductDb
```

### Issue 2: Migration Fails

**Symptoms**: `Migration failed to apply`

**Solutions:**
```powershell
# Check migration status
dotnet ef migrations list

# Check database state
dotnet ef database update --dry-run

# Rollback if needed
dotnet ef database update <previous-migration-name>
```

### Issue 3: Connection Pool Exhausted

**Symptoms**: `Timeout expired. The timeout period elapsed`

**Solutions:**
```csharp
// Increase pool size in connection string
Max Pool Size=200;

// Ensure connections are disposed
using (var context = new ProductDbContext())
{
    // Use context
} // Automatically disposed
```

---

## Real-World Example

### Complete Setup:

**1. Databases:**
```
Azure SQL Server: mysqlserver.database.windows.net
├── ProductDb (for ProductService)
├── OrderDb (for OrderService)
└── NotificationDb (for NotificationService)
```

**2. Connection Strings in Key Vault:**
```
ProductService--ConnectionStrings--DefaultConnection
OrderService--ConnectionStrings--DefaultConnection
NotificationService--ConnectionStrings--DefaultConnection
```

**3. Service Configuration:**
```csharp
// Each service has its own DbContext
ProductService → ProductDbContext → ProductDb
OrderService → OrderDbContext → OrderDb
```

**4. Data Flow:**
```
User → API → Service → DbContext → Database
                ↓
         (Isolated, independent)
```

---

## Summary

POC-9 implements database isolation, a core microservices principle:
- ✅ **Database per Service**: Each service has its own database
- ✅ **Entity Framework Core**: Type-safe database access
- ✅ **Migrations**: Version-controlled schema changes
- ✅ **Connection Pooling**: Efficient connection management
- ✅ **Isolation**: Services cannot access each other's databases
- ✅ **Independence**: Services can scale and deploy independently

This foundation ensures your microservices are truly decoupled and can evolve independently. Each service owns its data and communicates through APIs, not databases.

---

# POC-10: Distributed Observability - Infrastructure Explanation

## Overview

POC-10 implements **distributed observability** - the ability to see what's happening across all your microservices in real-time. When a user makes a request that flows through multiple services, you need to track that request end-to-end, understand performance bottlenecks, and quickly identify issues. Think of it as adding "GPS tracking and dashboards" to your microservices architecture.

---

## The Observability Problem

### The Problem: What's Happening in Production?

**In a Monolithic Application:**
```
Single Application
  ↓
All logs in one place
All metrics together
Easy to see what's happening
```

**In Microservices:**
```
Request flows through:
User → Ingress → ProductService → OrderService → NotificationService → Database
  ↓         ↓              ↓              ↓                  ↓
Each service has its own logs
Each service has its own metrics
How do you track one request across all services?
```

### Challenges:

1. **Request Tracing**
   - A request goes through 3-5 services
   - How do you follow it?
   - Which service is slow?
   - Where did it fail?

2. **Log Correlation**
   - Logs scattered across services
   - How do you find all logs for one request?
   - Which logs belong together?

3. **Performance Monitoring**
   - Which service is the bottleneck?
   - What's the end-to-end latency?
   - Where are errors occurring?

4. **Dependency Mapping**
   - Which services call which?
   - What's the dependency chain?
   - What happens if one service fails?

### ✅ The Solution: Distributed Observability

**Observability** = The ability to understand what's happening inside your system by examining its outputs (logs, metrics, traces).

**Three Pillars:**
1. **Logs**: What happened (events, errors, information)
2. **Metrics**: How much, how often (counters, gauges, histograms)
3. **Traces**: How requests flow through services (distributed tracing)

---

## What is Application Insights?

### Analogy:

Think of **Application Insights** like a **black box recorder** for your microservices:
- **Logs** = Flight data recorder (what happened)
- **Metrics** = Dashboard gauges (speed, altitude, fuel)
- **Traces** = GPS tracking (where the plane went)

### What Application Insights Does:

1. **Automatic Instrumentation**
   - Tracks HTTP requests automatically
   - Monitors dependencies (database, HTTP calls)
   - Captures exceptions and errors

2. **Performance Monitoring**
   - Response times
   - Request rates
   - Error rates
   - Dependency performance

3. **Distributed Tracing**
   - Follows requests across services
   - Shows dependency map
   - Identifies bottlenecks

4. **Smart Alerts**
   - Notifies when errors spike
   - Alerts on performance degradation
   - Detects anomalies

### How It Works:

```
Your Service
   │
   │ Sends telemetry
   ↓
Application Insights SDK
   │
   │ Collects: logs, metrics, traces
   ↓
Azure Application Insights
   │
   │ Stores and analyzes
   ↓
Dashboards, Alerts, Queries
```

---

## Correlation IDs: The Thread That Ties Everything Together

### What is a Correlation ID?

A **Correlation ID** is a unique identifier assigned to each request that flows through your system. It's like a "tracking number" that lets you follow a request across all services.

### Why Correlation IDs?

**Without Correlation ID:**
```
Request: GET /orders/123

ProductService logs:
[2024-01-15 10:00:01] Getting product 456
[2024-01-15 10:00:02] Product found

OrderService logs:
[2024-01-15 10:00:01] Getting order 123
[2024-01-15 10:00:03] Order found

How do you know these logs are for the same request?
```

**With Correlation ID:**
```
Request: GET /orders/123
Correlation ID: abc-123-xyz

ProductService logs:
[2024-01-15 10:00:01] [abc-123-xyz] Getting product 456
[2024-01-15 10:00:02] [abc-123-xyz] Product found

OrderService logs:
[2024-01-15 10:00:01] [abc-123-xyz] Getting order 123
[2024-01-15 10:00:03] [abc-123-xyz] Order found

Now you can search for "abc-123-xyz" and see all related logs!
```

### How Correlation IDs Flow:

```
1. User Request
   ↓
   Correlation ID: abc-123-xyz (generated or from header)
   
2. Ingress Controller
   ↓
   Adds to request header: X-Correlation-ID: abc-123-xyz
   
3. ProductService
   ↓
   Reads X-Correlation-ID header
   Logs with correlation ID
   Calls OrderService with same correlation ID in header
   
4. OrderService
   ↓
   Reads X-Correlation-ID header
   Logs with correlation ID
   Calls Database (correlation ID in query context)
   
5. All logs have same correlation ID
   ↓
   Can trace entire request flow!
```

---

## Distributed Tracing: Following Requests Across Services

### What is Distributed Tracing?

**Distributed Tracing** tracks a request as it travels through multiple services, showing you the complete path and timing.

### Visual Example:

**Without Distributed Tracing:**
```
You see:
- ProductService: 200ms
- OrderService: 150ms
- NotificationService: 100ms

But you don't know:
- Are these for the same request?
- What's the total time?
- Which service called which?
```

**With Distributed Tracing:**
```
Request Timeline:

User Request (0ms)
  │
  ├─→ Ingress (5ms)
  │     │
  │     ├─→ ProductService (50ms)
  │     │     │
  │     │     ├─→ Database Query (30ms)
  │     │     │
  │     │     └─→ HTTP Call to OrderService (20ms)
  │     │           │
  │     │           ├─→ OrderService Processing (80ms)
  │     │           │     │
  │     │           │     ├─→ Database Query (50ms)
  │     │           │     │
  │     │           │     └─→ Service Bus Publish (30ms)
  │     │           │
  │     │           └─→ Response (10ms)
  │     │
  │     └─→ Response to User (15ms)
  │
Total: 150ms

Now you can see:
- Complete request flow
- Time spent in each service
- Dependencies between services
- Bottlenecks (Database Query: 50ms)
```

### Trace Structure:

A **trace** consists of:
- **Spans**: Individual operations (HTTP request, database query)
- **Parent-Child Relationships**: Which operation called which
- **Timing**: How long each operation took

**Example Trace:**
```
Trace ID: trace-abc-123
├─ Span 1: HTTP GET /orders/123 (150ms)
   ├─ Span 2: ProductService.GetProduct() (50ms)
   │  └─ Span 3: Database Query (30ms)
   └─ Span 4: OrderService.GetOrder() (80ms)
      └─ Span 5: Database Query (50ms)
```

---

## Implementation: Application Insights

### Step 1: Install Application Insights

```powershell
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```

### Step 2: Configure in Program.cs

```csharp
var builder = WebApplication.CreateBuilder(args);

// Get instrumentation key from Key Vault
var instrumentationKey = builder.Configuration
    ["ApplicationInsights:InstrumentationKey"];

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    options.ConnectionString = $"InstrumentationKey={instrumentationKey}";
});

// Enable dependency tracking
builder.Services.AddApplicationInsightsTelemetryProcessor<CustomTelemetryProcessor>();

var app = builder.Build();
```

### Step 3: Automatic Tracking

Application Insights automatically tracks:
- HTTP requests
- Database calls (via EF Core)
- HTTP client calls
- Exceptions
- Performance counters

**No code changes needed for basic tracking!**

### Step 4: Custom Telemetry

**Add custom properties:**

```csharp
public class ProductsController : ControllerBase
{
    private readonly TelemetryClient _telemetry;
    
    public ProductsController(TelemetryClient telemetry)
    {
        _telemetry = telemetry;
    }
    
    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        // Track custom event
        _telemetry.TrackEvent("ProductViewed", new Dictionary<string, string>
        {
            ["ProductId"] = id.ToString(),
            ["UserId"] = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
        });
        
        var product = await _productService.GetByIdAsync(id);
        return Ok(product);
    }
}
```

---

## Implementation: Correlation ID Middleware

### Step 1: Create Correlation ID Middleware

```csharp
public class CorrelationIdMiddleware
{
    private readonly RequestDelegate _next;
    private const string CorrelationIdHeader = "X-Correlation-ID";
    
    public CorrelationIdMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        // Get correlation ID from header, or generate new one
        var correlationId = context.Request.Headers[CorrelationIdHeader].FirstOrDefault()
            ?? Guid.NewGuid().ToString();
        
        // Store in HttpContext for later use
        context.Items["CorrelationId"] = correlationId;
        
        // Add to response header
        context.Response.Headers[CorrelationIdHeader] = correlationId;
        
        // Add to logging scope
        using (context.RequestServices
            .GetRequiredService<ILoggerFactory>()
            .CreateLogger("CorrelationId")
            .BeginScope(new Dictionary<string, object>
            {
                ["CorrelationId"] = correlationId
            }))
        {
            await _next(context);
        }
    }
}
```

### Step 2: Propagate to Downstream Services

**When calling other services:**

```csharp
public class OrderService
{
    private readonly HttpClient _httpClient;
    private readonly IHttpContextAccessor _httpContextAccessor;
    
    public async Task<Product> GetProductAsync(int productId)
    {
        var request = new HttpRequestMessage(HttpMethod.Get, 
            $"http://productservice/api/products/{productId}");
        
        // Get correlation ID from current request
        var correlationId = _httpContextAccessor.HttpContext?
            .Items["CorrelationId"]?.ToString();
        
        if (!string.IsNullOrEmpty(correlationId))
        {
            // Propagate to downstream service
            request.Headers.Add("X-Correlation-ID", correlationId);
        }
        
        var response = await _httpClient.SendAsync(request);
        return await response.Content.ReadFromJsonAsync<Product>();
    }
}
```

### Step 3: Include in Logs

**Structured logging with correlation ID:**

```csharp
public class ProductService
{
    private readonly ILogger<ProductService> _logger;
    private readonly IHttpContextAccessor _httpContextAccessor;
    
    public async Task<Product> GetProductAsync(int id)
    {
        var correlationId = _httpContextAccessor.HttpContext?
            .Items["CorrelationId"]?.ToString();
        
        _logger.LogInformation(
            "Getting product {ProductId} for request {CorrelationId}",
            id, correlationId);
        
        try
        {
            var product = await _repository.GetByIdAsync(id);
            
            _logger.LogInformation(
                "Product {ProductId} found for request {CorrelationId}",
                id, correlationId);
            
            return product;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Error getting product {ProductId} for request {CorrelationId}",
                id, correlationId);
            throw;
        }
    }
}
```

---

## Structured Logging

### What is Structured Logging?

**Structured Logging** stores logs as structured data (JSON) instead of plain text, making them easier to search and analyze.

### Traditional Logging (Unstructured):

```csharp
_logger.LogInformation("User John logged in at 10:00 AM");
_logger.LogInformation("User Jane logged in at 10:01 AM");
```

**Problems:**
- Hard to search ("find all logs for user John")
- Can't filter by fields
- Difficult to analyze

### Structured Logging:

```csharp
_logger.LogInformation(
    "User {UserId} logged in at {LoginTime}",
    userId, loginTime);
```

**Output (JSON):**
```json
{
  "Timestamp": "2024-01-15T10:00:00Z",
  "Level": "Information",
  "Message": "User 123 logged in at 2024-01-15T10:00:00Z",
  "UserId": "123",
  "LoginTime": "2024-01-15T10:00:00Z",
  "CorrelationId": "abc-123-xyz"
}
```

**Benefits:**
- ✅ Easy to search: `UserId == "123"`
- ✅ Can filter by any field
- ✅ Easy to create dashboards
- ✅ Better for Application Insights

### Implementation with Serilog:

```csharp
// Install Serilog
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.ApplicationInsights

// Configure in Program.cs
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .WriteTo.ApplicationInsights(
        serviceProvider.GetRequiredService<TelemetryClient>(),
        TelemetryConverter.Traces)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("Application", "ProductService")
    .CreateLogger();

builder.Host.UseSerilog();
```

---

## Centralized Dashboards

### What is a Dashboard?

A **Dashboard** is a visual representation of your system's health, performance, and activity.

### Key Metrics to Monitor:

1. **Request Rate**
   - How many requests per second?
   - Per service breakdown

2. **Response Time**
   - Average response time
   - P95, P99 percentiles
   - Per endpoint breakdown

3. **Error Rate**
   - Percentage of failed requests
   - Error types
   - Per service breakdown

4. **Dependency Health**
   - Database response times
   - External API response times
   - Service Bus message processing

5. **Resource Usage**
   - CPU usage
   - Memory usage
   - Connection pool usage

### Creating Dashboards in Application Insights:

**Azure Portal → Application Insights → Workbooks**

**Example Dashboard:**

```
┌─────────────────────────────────────────┐
│   Microservices Dashboard                │
├─────────────────────────────────────────┤
│                                          │
│   Request Rate (last hour)               │
│   ┌─────────────────────────────────┐   │
│   │ ProductService: 500 req/min     │   │
│   │ OrderService: 300 req/min       │   │
│   │ NotificationService: 200 req/min│   │
│   └─────────────────────────────────┘   │
│                                          │
│   Average Response Time                  │
│   ┌─────────────────────────────────┐   │
│   │ ProductService: 50ms            │   │
│   │ OrderService: 80ms               │   │
│   │ NotificationService: 30ms        │   │
│   └─────────────────────────────────┘   │
│                                          │
│   Error Rate                             │
│   ┌─────────────────────────────────┐   │
│   │ ProductService: 0.1%            │   │
│   │ OrderService: 0.2%               │   │
│   │ NotificationService: 0.05%      │   │
│   └─────────────────────────────────┘   │
│                                          │
│   Dependency Map                         │
│   ┌─────────────────────────────────┐   │
│   │ User → Ingress → ProductService │   │
│   │              → OrderService      │   │
│   │              → NotificationService│ │
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

---

## Distributed Tracing in Action

### Example: Order Creation Flow

**User Request:**
```
POST /api/orders
{
  "productId": 123,
  "quantity": 2,
  "customerEmail": "user@example.com"
}
```

**Trace Flow:**

```
1. Ingress receives request
   Trace ID: trace-abc-123
   Span: HTTP POST /api/orders (starts)
   
2. Routes to OrderService
   Span: OrderService.CreateOrder() (starts)
   
3. OrderService calls ProductService
   Span: HTTP GET /api/products/123 (starts)
   ├─ ProductService.GetProduct() (50ms)
   │  └─ Database Query (30ms)
   └─ Response received (20ms)
   
4. OrderService creates order
   Span: Database Insert (40ms)
   
5. OrderService publishes to Service Bus
   Span: ServiceBus.Publish() (10ms)
   
6. NotificationService processes message
   Span: NotificationService.SendEmail() (100ms)
   └─ Email API Call (80ms)
   
7. Response to user
   Span: HTTP POST /api/orders (ends, total: 200ms)
```

**In Application Insights, you see:**
- Complete timeline
- Time spent in each service
- Dependencies (OrderService → ProductService)
- Bottlenecks (Email API: 80ms)

---

## Best Practices

### 1. Always Include Correlation ID

**✅ Good:**
```csharp
_logger.LogInformation(
    "Processing order {OrderId} for request {CorrelationId}",
    orderId, correlationId);
```

**❌ Bad:**
```csharp
_logger.LogInformation($"Processing order {orderId}");
// No correlation ID!
```

### 2. Propagate Correlation ID

**✅ Good:**
```csharp
// Always forward correlation ID to downstream services
request.Headers.Add("X-Correlation-ID", correlationId);
```

**❌ Bad:**
```csharp
// Forgetting to propagate
// Downstream services can't correlate logs
```

### 3. Use Structured Logging

**✅ Good:**
```csharp
_logger.LogInformation(
    "User {UserId} created order {OrderId}",
    userId, orderId);
```

**❌ Bad:**
```csharp
_logger.LogInformation($"User {userId} created order {orderId}");
// String interpolation loses structure
```

### 4. Set Appropriate Log Levels

**✅ Good:**
- **Trace**: Very detailed (disabled in production)
- **Debug**: Development debugging
- **Information**: General flow
- **Warning**: Something unexpected but handled
- **Error**: Exceptions and failures
- **Critical**: System failures

### 5. Monitor Key Metrics

**Always track:**
- Request rate
- Response time (avg, P95, P99)
- Error rate
- Dependency health
- Resource usage

---

## Troubleshooting

### Issue 1: No Traces in Application Insights

**Symptoms**: Requests not showing up

**Solutions:**
```csharp
// Verify instrumentation key is set
var key = builder.Configuration["ApplicationInsights:InstrumentationKey"];
if (string.IsNullOrEmpty(key))
{
    throw new InvalidOperationException("Instrumentation key not configured");
}

// Check connection
var telemetryClient = serviceProvider.GetRequiredService<TelemetryClient>();
telemetryClient.TrackEvent("TestEvent");
```

### Issue 2: Correlation ID Not Propagating

**Symptoms**: Can't trace requests across services

**Solutions:**
```csharp
// Verify middleware is registered
app.UseMiddleware<CorrelationIdMiddleware>();

// Check headers are being forwarded
var correlationId = context.Request.Headers["X-Correlation-ID"];
```

### Issue 3: Too Much Data / High Costs

**Symptoms**: Application Insights costs too much

**Solutions:**
```csharp
// Filter telemetry
builder.Services.AddApplicationInsightsTelemetryProcessor<FilterTelemetryProcessor>();

public class FilterTelemetryProcessor : ITelemetryProcessor
{
    public void Process(ITelemetry telemetry)
    {
        // Filter out health check requests
        if (telemetry is RequestTelemetry request &&
            request.Url.AbsolutePath.Contains("/health"))
        {
            return; // Don't send to Application Insights
        }
        
        _next.Process(telemetry);
    }
}
```

---

## Real-World Example

### Complete Observability Setup:

**1. Application Insights per Service:**
```
ProductService → AppInsights-ProductService
OrderService → AppInsights-OrderService
NotificationService → AppInsights-NotificationService
```

**2. Correlation ID Flow:**
```
User Request → X-Correlation-ID: abc-123
  ↓
Ingress → Forwards header
  ↓
OrderService → Reads header, logs with ID, forwards to ProductService
  ↓
ProductService → Reads header, logs with ID
  ↓
All logs have: CorrelationId: abc-123
```

**3. Dashboard Queries:**
```kusto
// Find all logs for a correlation ID
traces
| where customDimensions.CorrelationId == "abc-123"

// Find slow requests
requests
| where duration > 1000
| project timestamp, name, duration, url

// Error rate by service
requests
| summarize errorRate = countif(success == false) * 100.0 / count()
    by bin(timestamp, 5m), cloud_RoleName
```

---

## Summary

POC-10 implements comprehensive observability for your microservices:
- ✅ **Application Insights**: Automatic telemetry collection and analysis
- ✅ **Correlation IDs**: Track requests across all services
- ✅ **Distributed Tracing**: See complete request flows
- ✅ **Structured Logging**: Searchable, analyzable logs
- ✅ **Centralized Dashboards**: Visualize system health
- ✅ **Smart Alerts**: Get notified of issues automatically

This observability foundation ensures you can monitor, debug, and optimize your microservices architecture effectively. You'll always know what's happening, where issues are, and how to fix them quickly.

