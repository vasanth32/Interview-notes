# Docker & Kubernetes Basics — Beginner Notes

## 1. Docker

### What is Docker?

Docker is a **containerization platform** that packages an application together with its dependencies and runtime into a container.

The main benefit is that the application can run consistently across different environments without worrying about differences in the environment.

### Simple idea

```text
Application
    +
Dependencies
    +
Runtime / Required files
    ↓
Docker Image
    ↓
Docker Container
    ↓
Running Application
```

### Interview answer

> Docker is a containerization platform that packages an application along with its dependencies into a container. This allows the application to run consistently across different environments.

---

# 2. Docker Image vs Container

## Docker Image

A Docker image is a **read-only package/template** containing the application, dependencies, runtime, libraries, and required filesystem/configuration.

Think:

```text
Image = Blueprint 📦
```

## Docker Container

A container is a **running instance of a Docker image**.

Think:

```text
Container = Running application ▶️
```

### Example

```text
Docker Image
    ↓
    ├── Container 1
    ├── Container 2
    └── Container 3
```

One image can be used to create multiple containers.

### Interview answer

> A Docker image is a read-only package containing the application and its dependencies. A container is a running instance of that image.

---

# 3. Why Kubernetes?

Docker is good for running containers.

But imagine we have:

```text
100 containers
10 applications
Multiple servers
Traffic from thousands of users
```

Managing all of them manually becomes difficult.

Kubernetes helps us manage containerized applications automatically.

### Kubernetes can help with:

- Running multiple instances
- Restarting failed containers
- Maintaining the desired number of Pods
- Scaling applications
- Distributing traffic
- Rolling out application updates
- Managing networking between applications

### Simple comparison

```text
Docker
   ↓
Runs containers

Kubernetes
   ↓
Manages containers at scale
```

### Interview answer

> Kubernetes is used to manage containerized applications at scale. It can automatically handle things like restarting failed workloads, maintaining replicas, scaling, distributing traffic, and application updates.

---

# 4. What is a Pod?

A **Pod is the smallest deployable unit in Kubernetes**.

A Pod can contain:

- One container
- Or multiple containers

Most commonly, an application Pod contains **one application container**.

```text
Pod
 └── .NET API Container
```

A Pod with multiple containers:

```text
Pod
 ├── Application Container
 └── Supporting Container
```

Containers inside the same Pod share the same network and can communicate with each other using `localhost`.

### Multiple Pods

If we need multiple instances:

```text
        Kubernetes
             ↓
    ┌────────┼────────┐
    ↓        ↓        ↓
  Pod 1    Pod 2    Pod 3
```

### Interview answer

> A Pod is the smallest deployable unit in Kubernetes. It can contain one or more containers, and usually we run one application container inside a Pod.

---

# 5. What is a Deployment?

A **Deployment manages Pods** and defines the desired state of our application.

For example:

```yaml
replicas: 3
```

This means we want **3 Pods** running.

```text
Deployment
     ↓
  3 replicas
     ↓
┌────┬────┬────┐
│Pod1│Pod2│Pod3│
└────┴────┴────┘
```

If one Pod disappears, Kubernetes works to create a replacement so the desired number of replicas is maintained.

A Deployment also helps with:

- Managing replicas
- Rolling updates
- Updating application versions
- Replacing failed Pods

### Important relationship

```text
Deployment
    ↓
ReplicaSet
    ↓
Pods
    ↓
Containers
```

For beginner interviews, it is enough to remember:

> Deployment manages the desired number of Pods and helps maintain that state.

### Interview answer

> A Deployment manages how many replicas of our application should be running. For example, if we specify 3 replicas, Kubernetes tries to keep 3 Pods running. If a Pod fails, a replacement Pod is created. Deployment also helps manage application updates.

---

# 6. Why Replicas?

A replica means **another running instance of our application**.

Suppose we have:

```text
3 replicas

Pod 1
Pod 2
Pod 3
```

## Benefit 1 — Availability

If Pod 1 fails:

```text
Pod 1 ❌
Pod 2 ✅
Pod 3 ✅
```

Kubernetes can create a replacement:

```text
Pod 1 ❌
Pod 2 ✅
Pod 3 ✅
Pod 4 ✅
```

The application can continue running.

## Benefit 2 — Handle more traffic

Multiple Pods can handle requests.

```text
             Requests
                 ↓
       ┌─────────┼─────────┐
       ↓         ↓         ↓
     Pod 1     Pod 2     Pod 3
```

### Interview answer

> We use replicas to run multiple instances of our application. This improves availability and allows us to handle more traffic. If one Pod fails, Kubernetes can create a replacement.

---

# 7. What is a Kubernetes Service?

Pods are temporary.

When a Pod is recreated, its IP address can change.

If another application directly communicates with a Pod IP:

```text
Application
     ↓
Pod IP
     ↓
Pod crashes ❌
     ↓
New Pod gets a different IP
```

This creates a problem.

A **Service provides a stable network endpoint** for accessing a group of Pods.

```text
              Service
                 ↓
        ┌────────┼────────┐
        ↓        ↓        ↓
      Pod 1    Pod 2    Pod 3
```

The Service selects the appropriate Pods and can distribute traffic between them.

### Simple memory trick

```text
Pod = Temporary

Service = Stable way to reach Pods
```

### Interview answer

> A Kubernetes Service provides a stable network endpoint to access a group of Pods. Since Pod IP addresses can change when Pods are recreated, a Service provides a stable way for applications or users to communicate with those Pods.

---

# 8. Readiness Probe

Readiness answers:

> **"Can I send traffic to this Pod?"**

When an application starts, it may need time to:

- Start the .NET application
- Connect to a database
- Load configuration
- Initialize dependencies

During this time, the application may be running but **not ready to receive traffic**.

```text
Pod starts
   ↓
Readiness ❌
   ↓
Don't send traffic
   ↓
Application becomes ready
   ↓
Readiness ✅
   ↓
Send traffic
```

### If readiness fails

Kubernetes does **not normally send Service traffic to that Pod**.

### Interview answer

> Readiness checks whether the application is ready to receive traffic. If the readiness check fails, Kubernetes removes the Pod from the Service's available endpoints until it becomes ready.

---

# 9. Liveness Probe

Liveness answers:

> **"Is the application still alive?"**

An application can sometimes become stuck or unhealthy even though its process is still running.

For example:

```text
Application
     ↓
Process is running
     ↓
But application is stuck
     ↓
Liveness ❌
     ↓
Kubernetes can restart the container
```

### Interview answer

> Liveness checks whether the application is still running properly. If the liveness check repeatedly fails, Kubernetes can restart the container.

---

# 10. Readiness vs Liveness

| Probe | Main Question | Failure Result |
|---|---|---|
| Readiness | Can I send traffic? | Pod is removed from available Service endpoints |
| Liveness | Is the application alive? | Container can be restarted |

### Easy memory trick

```text
Readiness → "Can I send traffic?" 🚦

Liveness → "Are you alive?" ❤️
```

---

# 11. What Happens If a Pod Crashes?

Suppose our Deployment wants:

```text
replicas: 3
```

Current state:

```text
Pod 1 ❌
Pod 2 ✅
Pod 3 ✅
```

Kubernetes sees that the desired state is:

```text
3 Pods
```

but only 2 healthy Pods remain.

It creates a replacement:

```text
Pod 1 ❌
Pod 2 ✅
Pod 3 ✅
Pod 4 ✅
```

### Interview answer

> If a Pod crashes, Kubernetes detects that the desired number of replicas is no longer available and creates a replacement Pod to maintain the configured replica count.

---

# 12. How Docker and Kubernetes Work Together

This is one of the most important concepts.

```text
.NET API
   ↓
Dockerfile
   ↓
Docker Image
   ↓
Container Registry
   ↓
Kubernetes Deployment
   ↓
Pods
   ↓
Containers
   ↓
Kubernetes Service
   ↓
Users / Other Applications
```

Example:

```text
                         Kubernetes Cluster
                               │
                         Deployment
                               │
                         replicas: 3
                               │
              ┌────────────────┼────────────────┐
              ↓                ↓                ↓
            Pod 1            Pod 2            Pod 3
              │                │                │
          .NET API         .NET API         .NET API
          Container        Container        Container
              └────────────────┼────────────────┘
                               ↑
                            Service
                               ↑
                            Traffic
```

---

# 13. How to Deploy a .NET API to Kubernetes

A typical flow is:

```text
Step 1
Create .NET API
        ↓
Step 2
Create Dockerfile
        ↓
Step 3
Build Docker Image
        ↓
Step 4
Test Docker Container locally
        ↓
Step 5
Push Image to Container Registry
        ↓
Step 6
Create Kubernetes Deployment YAML
        ↓
Step 7
Configure replica count
        ↓
Step 8
Configure readiness probe
        ↓
Step 9
Configure liveness probe
        ↓
Step 10
Create Kubernetes Service YAML
        ↓
Step 11
Apply YAML to Kubernetes
        ↓
Step 12
Verify Pods and Service
```

### Interview answer

> First, I would containerize the .NET API using a Dockerfile and build a Docker image. I would push the image to a container registry. Then I would create a Kubernetes Deployment specifying the image and replica count. I would create a Service to expose the Pods and configure readiness and liveness probes. Finally, I would apply the Kubernetes configurations and verify that the Pods and Service are running correctly.

---

# 14. Important Kubernetes Objects

For beginner-level understanding, focus on these:

```text
Deployment
    ↓
Manages Pods

Pod
    ↓
Runs containers

Service
    ↓
Provides stable access to Pods

Replica
    ↓
Multiple instances of application

Readiness
    ↓
Controls whether traffic should be sent

Liveness
    ↓
Checks whether application is alive
```

---

# 15. Complete Mental Model

Imagine we have a .NET API.

## Docker side

```text
.NET API
   ↓
Dockerfile
   ↓
Docker Image
   ↓
Container
```

Docker answers:

> **"How do I package and run my application?"**

## Kubernetes side

```text
Deployment
   ↓
Pods
   ↓
Containers
```

Kubernetes answers:

> **"How do I manage my containers in a reliable and scalable way?"**

## Networking

```text
Users
  ↓
Service
  ↓
Pods
  ↓
.NET API
```

Service answers:

> **"How can users/applications reliably reach my Pods?"**

---

# 16. Interview Quick Revision

### Q1. What is Docker?

> Docker is a containerization platform that packages an application with its dependencies so it can run consistently across environments.

### Q2. Image vs Container?

> An image is a read-only package/template. A container is a running instance of that image.

### Q3. Why Kubernetes?

> Kubernetes manages containerized applications at scale and provides automation such as self-healing, scaling, traffic distribution, and rolling updates.

### Q4. What is a Pod?

> A Pod is the smallest deployable unit in Kubernetes and can contain one or more containers.

### Q5. What is a Deployment?

> A Deployment manages the desired number of Pods and helps maintain replicas and perform application updates.

### Q6. Why replicas?

> Replicas provide multiple instances for availability and traffic handling. If one fails, Kubernetes can replace it.

### Q7. What is a Service?

> A Service provides a stable network endpoint for accessing Pods and can distribute traffic between them.

### Q8. Readiness vs Liveness?

> Readiness checks whether a Pod can receive traffic. Liveness checks whether the application is still alive and can trigger a restart when it repeatedly fails.

### Q9. What happens if a Pod crashes?

> Kubernetes works to maintain the desired replica count by creating a replacement Pod.

### Q10. How would you deploy a .NET API?

> Containerize the API with Docker, build and push the image to a registry, create a Kubernetes Deployment with replicas and probes, create a Service, apply the configuration, and verify the deployment.

---

# 17. One-Line Memory Map

```text
Docker
  ↓
Packages application

Image
  ↓
Blueprint/package

Container
  ↓
Running image

Kubernetes
  ↓
Manages containers

Pod
  ↓
Smallest deployable unit

Deployment
  ↓
Manages desired Pods/replicas

Replica
  ↓
Multiple application instances

Service
  ↓
Stable access to Pods

Readiness
  ↓
Can receive traffic?

Liveness
  ↓
Is application alive?
```

# 18. Beginner Interview Rule

Don't try to memorize complicated Kubernetes terminology.

First remember this story:

```text
I have a .NET API
       ↓
I package it with Docker
       ↓
I get a Docker image
       ↓
Kubernetes runs it in Pods
       ↓
Deployment maintains replicas
       ↓
Service provides stable access
       ↓
Readiness controls traffic
       ↓
Liveness checks health
       ↓
Kubernetes replaces failed Pods
```

If you can explain this flow naturally, you have a strong foundation for Docker + Kubernetes basics.
