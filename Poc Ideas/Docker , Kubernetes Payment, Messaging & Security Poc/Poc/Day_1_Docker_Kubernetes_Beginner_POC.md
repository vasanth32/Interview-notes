# Day 1 --- Beginner POC: Docker → Kubernetes

## Goal for Day 1

By the end of Day 1, you will have a small `.NET Web API` running:

``` text
Your .NET API
     ↓
Docker container
     ↓
Kubernetes Pod
     ↓
Kubernetes Deployment (2 Pods)
     ↓
Kubernetes Service
     ↓
Health checks
     ├── Readiness
     └── Liveness
```

You are **not expected to understand Kubernetes completely** today.

The rule is:

> Learn one tiny concept → do the tiny task → test it → answer one
> interview question.

------------------------------------------------------------------------

# 0. What you need before starting

## Install/check these tools

Open PowerShell or Command Prompt and run:

``` powershell
dotnet --version
docker --version
kubectl version --client
```

You should get a version for each.

For Kubernetes locally, use **Docker Desktop Kubernetes**.

Open Docker Desktop:

1.  Start Docker Desktop.
2.  Go to **Settings**.
3.  Find **Kubernetes**.
4.  Enable Kubernetes.
5.  Wait until Kubernetes shows as running.

Then run:

``` powershell
kubectl get nodes
```

You should see one node with status similar to:

``` text
NAME             STATUS   ROLES
docker-desktop   Ready    control-plane
```

If Docker Desktop Kubernetes is unavailable on your machine, do not stop
the learning. Ask for help before moving ahead.

------------------------------------------------------------------------

# 1. Create the POC folder

Create a folder:

``` text
PaymentKubernetesPoc
```

Open a terminal in that folder.

Run:

``` powershell
dotnet new webapi -n Payment.Api
cd Payment.Api
```

Your structure should initially look approximately like:

``` text
PaymentKubernetesPoc/
└── Payment.Api/
    ├── Payment.Api.csproj
    ├── Program.cs
    ├── appsettings.json
    └── ...
```

------------------------------------------------------------------------

# 2. Understand what we are building

We need a very simple API.

It will have:

``` text
GET /api/payments/hello
GET /health
```

The first endpoint proves our API works.

The second endpoint will later be used by Kubernetes to check
application health.

Do not add a database today.

Do not add authentication today.

Do not add Azure today.

Keep the application intentionally simple.

------------------------------------------------------------------------

# 3. Task 1 --- Create the first API endpoint

Open:

``` text
Payment.Api/Program.cs
```

Replace its contents with:

``` csharp
var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/api/payments/hello", () =>
{
    return Results.Ok(new
    {
        message = "Payment API is running",
        status = "success"
    });
});

app.Run();
```

## What does this mean?

This:

``` csharp
app.MapGet("/api/payments/hello", ...)
```

means:

> When somebody sends a GET request to `/api/payments/hello`, execute
> this code.

This:

``` csharp
Results.Ok(...)
```

returns HTTP 200.

------------------------------------------------------------------------

# 4. Run the API locally

Run:

``` powershell
dotnet run
```

You will see something similar to:

``` text
Now listening on: http://localhost:xxxx
```

Use the displayed port.

For example:

``` text
http://localhost:5000/api/payments/hello
```

Open it in the browser.

You should see:

``` json
{
  "message": "Payment API is running",
  "status": "success"
}
```

## Tiny exercise

Change:

``` text
Payment API is running
```

to:

``` text
Payment API Day 1 POC is running
```

Run again and verify it.

------------------------------------------------------------------------

# 5. Interview question #1

Close your editor for a moment and answer this without looking:

> What is an API?

Beginner answer:

> An API is an interface that allows another application to communicate
> with our application using defined requests and responses.

Do not memorize blindly. You just created one.

------------------------------------------------------------------------

# 6. Task 2 --- Add a health endpoint

We need an endpoint that simply tells us whether the application is
alive.

Add this before `app.Run()`:

``` csharp
app.MapGet("/health", () =>
{
    return Results.Ok(new
    {
        status = "Healthy"
    });
});
```

Your `Program.cs` should now contain:

``` csharp
var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/api/payments/hello", () =>
{
    return Results.Ok(new
    {
        message = "Payment API is running",
        status = "success"
    });
});

app.MapGet("/health", () =>
{
    return Results.Ok(new
    {
        status = "Healthy"
    });
});

app.Run();
```

Test:

``` text
http://localhost:xxxx/health
```

Expected:

``` json
{
  "status": "Healthy"
}
```

------------------------------------------------------------------------

# 7. Understand health checks

Imagine our application is running inside a container.

Kubernetes needs to know:

> "Is this application okay?"

Our `/health` endpoint gives Kubernetes a simple answer.

``` text
Kubernetes
     ↓
GET /health
     ↓
200 OK
     ↓
Healthy
```

Later Kubernetes will call this endpoint automatically.

------------------------------------------------------------------------

# 8. Task 3 --- Create a Dockerfile

Stop the API if it is running.

Create this file:

``` text
Payment.Api/Dockerfile
```

Put this inside:

``` dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

COPY ["Payment.Api.csproj", "."]
RUN dotnet restore "Payment.Api.csproj"

COPY . .

RUN dotnet publish "Payment.Api.csproj" \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final

WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 8080

ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "Payment.Api.dll"]
```

> If your installed .NET version is not 10, use the matching SDK/runtime
> version in the Dockerfile.

------------------------------------------------------------------------

# 9. Understand the Dockerfile slowly

Do not memorize it.

Understand the major idea:

``` text
SDK image
   ↓
Build application
   ↓
Publish application
   ↓
Runtime image
   ↓
Run application
```

There are two `FROM` statements.

The first image is used to **build**.

The second image is used to **run**.

This is called a **multi-stage Docker build**.

Why?

Because we do not need the complete SDK inside the final production
container.

------------------------------------------------------------------------

# 10. Task 4 --- Build the Docker image

From the `Payment.Api` folder run:

``` powershell
docker build -t payment-api:day1 .
```

Wait until the build finishes.

Check:

``` powershell
docker images
```

You should see:

``` text
payment-api
```

------------------------------------------------------------------------

# 11. Task 5 --- Run the Docker container

Run:

``` powershell
docker run --name payment-api-container -p 8080:8080 payment-api:day1
```

Understand this command:

``` text
-p 8080:8080
```

means:

``` text
Your computer port 8080
        ↓
Container port 8080
```

Open:

``` text
http://localhost:8080/api/payments/hello
```

Then:

``` text
http://localhost:8080/health
```

Both should work.

------------------------------------------------------------------------

# 12. Tiny Docker exercise

Stop the container:

``` powershell
docker stop payment-api-container
```

Start it again:

``` powershell
docker start payment-api-container
```

Test:

``` text
http://localhost:8080/health
```

Then remove it:

``` powershell
docker stop payment-api-container
docker rm payment-api-container
```

The image remains.

Check:

``` powershell
docker images
```

------------------------------------------------------------------------

# 13. Interview question #2

Answer:

> What is the difference between a Docker image and a Docker container?

Beginner-friendly answer:

> An image is the packaged blueprint containing the application and
> everything required to run it. A container is a running instance of
> that image.

You have now built an image and run a container, so the answer is based
on your POC.

------------------------------------------------------------------------

# 14. Task 6 --- Understand why Kubernetes is needed

Docker can run our container.

But imagine production has:

``` text
Payment API
   ├── Container 1
   ├── Container 2
   ├── Container 3
   ├── Container 4
   └── Container 5
```

Now imagine:

``` text
Container 3 crashes.
```

Who restarts it?

Who maintains the desired number of instances?

Who distributes traffic?

Who performs rolling deployments?

This is where Kubernetes helps.

Simple mental model:

``` text
Docker
= Runs containers

Kubernetes
= Manages containers
```

------------------------------------------------------------------------

# 15. Task 7 --- Create your first Kubernetes Pod

Create:

``` text
Payment.Api/k8s/
```

Inside it create:

``` text
pod.yaml
```

Add:

``` yaml
apiVersion: v1
kind: Pod

metadata:
  name: payment-api-pod

spec:
  containers:
    - name: payment-api
      image: payment-api:day1
      ports:
        - containerPort: 8080
```

------------------------------------------------------------------------

# 16. Understand pod.yaml

This:

``` yaml
kind: Pod
```

means:

> Create a Kubernetes Pod.

This:

``` yaml
image: payment-api:day1
```

means:

> Use the Docker image we created.

This:

``` yaml
containerPort: 8080
```

means:

> The application inside the container listens on port 8080.

------------------------------------------------------------------------

# 17. Make your local Docker image available to Kubernetes

With Docker Desktop Kubernetes, the local Docker image is normally
available to the local cluster.

Apply:

``` powershell
kubectl apply -f k8s/pod.yaml
```

Check:

``` powershell
kubectl get pods
```

You should see:

``` text
payment-api-pod    Running
```

If it says `ImagePullBackOff`, stop here and ask for help; do not
randomly change YAML.

------------------------------------------------------------------------

# 18. Inspect the Pod

Run:

``` powershell
kubectl describe pod payment-api-pod
```

You do not need to understand everything.

Find these concepts:

``` text
Name
Status
Containers
Image
Port
Events
```

Events are especially useful when a Pod fails.

------------------------------------------------------------------------

# 19. Task 8 --- Create a Deployment

Delete the Pod:

``` powershell
kubectl delete pod payment-api-pod
```

Now create:

``` text
k8s/deployment.yaml
```

Add:

``` yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: payment-api

spec:
  replicas: 2

  selector:
    matchLabels:
      app: payment-api

  template:
    metadata:
      labels:
        app: payment-api

    spec:
      containers:
        - name: payment-api
          image: payment-api:day1
          ports:
            - containerPort: 8080
```

Apply:

``` powershell
kubectl apply -f k8s/deployment.yaml
```

Check:

``` powershell
kubectl get deployments
```

Then:

``` powershell
kubectl get pods
```

You should see two Pods.

Example:

``` text
payment-api-xxxxx-aaaaa   Running
payment-api-xxxxx-bbbbb   Running
```

------------------------------------------------------------------------

# 20. Understand Deployment

You told Kubernetes:

``` yaml
replicas: 2
```

You are effectively saying:

> "I want two copies of my application running."

Kubernetes tries to maintain that desired state.

If one Pod dies:

``` text
Pod 1 ❌
Pod 2 ✅
```

Kubernetes creates another Pod:

``` text
Pod 1 ❌
Pod 2 ✅
Pod 3 → starting
```

This is one of the reasons we use Deployments.

------------------------------------------------------------------------

# 21. Tiny experiment --- delete a Pod

Run:

``` powershell
kubectl get pods
```

Copy one Pod name.

Then:

``` powershell
kubectl delete pod <pod-name>
```

Immediately run:

``` powershell
kubectl get pods
```

You should notice Kubernetes creates another Pod.

This is an important experiment.

You just observed Kubernetes maintaining the desired state.

------------------------------------------------------------------------

# 22. Interview question #3

Answer:

> Why use a Kubernetes Deployment instead of creating Pods manually?

Beginner answer:

> A Deployment manages the desired number of Pod replicas and helps
> Kubernetes maintain them during failures and deployments.

------------------------------------------------------------------------

# 23. Task 9 --- Create a Kubernetes Service

We have two Pods.

But their IP addresses can change.

We need a stable way to reach them.

Create:

``` text
k8s/service.yaml
```

Add:

``` yaml
apiVersion: v1
kind: Service

metadata:
  name: payment-api-service

spec:
  selector:
    app: payment-api

  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080

  type: NodePort
```

Apply:

``` powershell
kubectl apply -f k8s/service.yaml
```

Check:

``` powershell
kubectl get services
```

------------------------------------------------------------------------

# 24. Understand Service

Think:

``` text
Client
  ↓
Service
  ↓
Pod 1
Pod 2
```

The Service gives us a stable network endpoint.

The selector:

``` yaml
selector:
  app: payment-api
```

matches:

``` yaml
labels:
  app: payment-api
```

So the Service knows which Pods belong to it.

------------------------------------------------------------------------

# 25. Access the API

Run:

``` powershell
kubectl get service payment-api-service
```

Because this is a NodePort service, you can access the assigned node
port through localhost in Docker Desktop.

If your output shows something such as:

``` text
80:30080/TCP
```

try:

``` text
http://localhost:30080/health
```

If Docker Desktop networking behaves differently on your machine, use:

``` powershell
kubectl port-forward service/payment-api-service 8081:80
```

Then open:

``` text
http://localhost:8081/health
```

------------------------------------------------------------------------

# 26. Task 10 --- Add readiness probe

Now we use the `/health` endpoint.

Update `deployment.yaml`:

``` yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: payment-api

spec:
  replicas: 2

  selector:
    matchLabels:
      app: payment-api

  template:
    metadata:
      labels:
        app: payment-api

    spec:
      containers:
        - name: payment-api
          image: payment-api:day1

          ports:
            - containerPort: 8080

          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
```

Apply:

``` powershell
kubectl apply -f k8s/deployment.yaml
```

Check:

``` powershell
kubectl get pods
```

You should see:

``` text
READY   STATUS
1/1     Running
```

------------------------------------------------------------------------

# 27. What is readiness?

Imagine the application has started but is still loading.

``` text
Container started
      ↓
Application not ready
      ↓
Don't send traffic
```

Once:

``` text
GET /health → 200
```

the Pod becomes ready to receive traffic.

Remember:

> **Readiness = "Can I send traffic to you?"**

------------------------------------------------------------------------

# 28. Task 11 --- Add liveness probe

Now add this below the readiness probe:

``` yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 15
```

Apply:

``` powershell
kubectl apply -f k8s/deployment.yaml
```

------------------------------------------------------------------------

# 29. What is liveness?

Liveness asks:

> "Is this application still alive/healthy enough to keep running?"

Remember:

``` text
Readiness
= Should I send traffic?

Liveness
= Should Kubernetes keep this container running?
```

Do not worry about advanced probe configuration today.

------------------------------------------------------------------------

# 30. Final Day 1 test

Run:

``` powershell
kubectl get pods
kubectl get deployments
kubectl get services
```

Then:

``` powershell
kubectl describe deployment payment-api
```

Then:

``` powershell
kubectl describe pod <one-pod-name>
```

You should be able to explain this picture:

``` text
Deployment
    │
    ├── Pod 1
    │     └── Container
    │
    └── Pod 2
          └── Container

Service
    │
    ├── Pod 1
    └── Pod 2
```

And:

``` text
Pod
 ├── Readiness probe
 └── Liveness probe
```

------------------------------------------------------------------------

# 31. Day 1 interview questions

Do not read the answers first.

Try answering aloud.

### Q1

What is Docker?

### Q2

Image vs container?

### Q3

Why Kubernetes?

### Q4

What is a Pod?

### Q5

What is a Deployment?

### Q6

Why replicas?

### Q7

What is a Kubernetes Service?

### Q8

Readiness vs liveness?

### Q9

What happens if one Pod crashes?

### Q10

How would you deploy a .NET API to Kubernetes?

------------------------------------------------------------------------

# 32. Day 1 completion checklist

Do not move to Day 2 until these are checked.

-   [ ] Created `.NET Web API`
-   [ ] Created `/api/payments/hello`
-   [ ] Created `/health`
-   [ ] Ran API locally
-   [ ] Created Dockerfile
-   [ ] Built Docker image
-   [ ] Ran Docker container
-   [ ] Created Kubernetes Pod
-   [ ] Created Deployment
-   [ ] Ran 2 replicas
-   [ ] Deleted a Pod and watched Kubernetes recreate it
-   [ ] Created Service
-   [ ] Accessed API through Service/port-forward
-   [ ] Added readiness probe
-   [ ] Added liveness probe
-   [ ] Answered the 10 interview questions aloud

------------------------------------------------------------------------

# 33. STOP HERE

Do not start AWS.

Do not start payments.

Do not start Key Vault.

Do not start advanced Kubernetes.

Day 1 is successful if you can explain:

> "I created a .NET API, containerized it using Docker, deployed it to
> Kubernetes using a Deployment, ran two replicas, exposed them through
> a Service, and added readiness and liveness probes."

That sentence alone directly addresses a major weakness from your
previous interview.
