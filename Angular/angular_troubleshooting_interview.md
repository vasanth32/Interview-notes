# Angular Troubleshooting – Interview Preparation

## Why Troubleshooting Is Important

For an experienced Angular interview, don't just memorize Angular theory. Be able to explain:

**Problem → How I investigate → Root cause → Fix → Verification**

---

# 1. API Returns 401 Unauthorized

### Problem

Angular calls the .NET API but receives:

```text
401 Unauthorized
```

### How I Troubleshoot

1. Open browser **F12 → Network**.
2. Find the API request.
3. Check the request headers.
4. Verify whether this is present:

```text
Authorization: Bearer <token>
```

5. Check token expiry.
6. Check whether the Angular HTTP interceptor is adding the token.
7. Check backend JWT configuration such as issuer, audience and authentication scheme.

### Example Fix

```typescript
intercept(req: HttpRequest<any>, next: HttpHandler) {

    const token = this.authService.getToken();

    const clonedRequest = req.clone({
        setHeaders: {
            Authorization: `Bearer ${token}`
        }
    });

    return next.handle(clonedRequest);
}
```

### Interview Answer

> "When an Angular API call returns 401, I first check the request in the browser Network tab to verify whether the Authorization header is present. Then I check token expiry and the interceptor. If the request looks correct, I check the backend JWT configuration such as issuer, audience and authentication scheme."

---

# 2. API Returns 500 Internal Server Error

### Problem

```text
Angular
   ↓
GET /api/employees
   ↓
500 Internal Server Error
```

### How I Troubleshoot

Check:

```text
F12
 ↓
Network
 ↓
Request URL
 ↓
Request payload
 ↓
Response body
 ↓
Status code
```

Then test the same API using **Postman or Swagger**.

### If Postman Also Gets 500

The problem is probably on the backend.

Check:

- .NET logs
- Application Insights
- Exception details
- Database connection
- SQL query
- Downstream service

### Interview Answer

> "I isolate whether the issue is frontend or backend. I first inspect the Network tab and response body, then test the same endpoint independently using Swagger or Postman. If it also fails there, I investigate the API logs rather than changing Angular code."

---

# 3. Angular Page Is Very Slow

Suppose:

```text
Employee page
     ↓
takes 8 seconds
```

### How I Troubleshoot

First determine **where the time is spent**.

Use:

```text
Browser DevTools
     ↓
Network
Performance
```

Check:

- API response time
- Number of API calls
- Large response payload
- Unnecessary component rendering
- Large lists
- Expensive functions in templates

### Common Fixes

Use pagination:

```text
Instead of:

GET /employees → 50,000 records

Use:

GET /employees?page=1&pageSize=50
```

Other options:

- Use lazy loading for large features.
- Use `trackBy` for lists.
- Avoid expensive methods in templates.
- Use appropriate Angular change-detection strategies where applicable.

### Interview Answer

> "For a slow Angular page, I first use browser DevTools to determine whether the delay is from API calls, rendering or JavaScript execution. If the API is slow, I investigate the backend or reduce the payload. If rendering is slow, I look for large lists, unnecessary change detection and expensive template operations."

---

# 4. API Is Being Called Multiple Times

### Problem

You expect:

```text
GET /employees → 1 call
```

But Network shows:

```text
GET /employees
GET /employees
GET /employees
```

### How I Troubleshoot

Check:

- `ngOnInit()`
- Component lifecycle
- Multiple subscriptions
- Parent/child components
- Route changes
- Duplicate event handlers
- Services being called from multiple places

### Example

```typescript
ngOnInit() {
    this.loadEmployees();
}

onSearch() {
    this.loadEmployees();
}
```

If an event/search is firing unexpectedly, duplicate requests can occur.

### Possible RxJS Fix

For search boxes, `debounceTime()` can reduce unnecessary API calls:

```typescript
this.searchControl.valueChanges
    .pipe(
        debounceTime(300)
    )
    .subscribe(value => {
        this.searchEmployees(value);
    });
```

---

# 5. Data Is Not Displayed on Screen

API returns:

```json
[
  {
    "id": 101,
    "name": "Vasanth"
  }
]
```

But Angular screen is blank.

### Troubleshooting Flow

Check in this order:

```text
API response
   ↓
Observable
   ↓
subscribe()
   ↓
Component variable
   ↓
HTML binding
```

Example:

```typescript
this.service.getEmployees().subscribe(data => {
    console.log(data);
    this.employees = data;
});
```

HTML:

```html
<div *ngFor="let employee of employees">
    {{ employee.name }}
</div>
```

Check whether the actual response structure matches what the component expects.

For example, API may return:

```json
{
    "data": [...]
}
```

while the component expects:

```typescript
Employee[]
```

This is a common real-world issue.

---

# 6. CORS Error

Browser shows:

```text
Access to XMLHttpRequest has been blocked by CORS policy
```

### Important

Don't try to randomly "fix CORS" in Angular by adding headers.

CORS is primarily a **server-side/browser security policy**.

For a .NET API, configure allowed origins appropriately.

Conceptually:

```text
Angular
http://localhost:4200
       ↓
.NET API
https://localhost:7001
       ↓
CORS policy
       ↓
Allow http://localhost:4200
```

### Interview Answer

> "If I see a CORS error, I first confirm the request is reaching the API and inspect the browser console. CORS needs to be configured on the backend to allow the Angular application's origin. I wouldn't try to solve it by adding arbitrary CORS headers from the Angular client."

---

# 7. Login Works but Protected API Fails

Example:

```text
Login
 ↓
200 OK
 ↓
Token received

Then:

GET /employees
 ↓
403 Forbidden
```

### Remember 401 vs 403

```text
401 → Authentication problem
      "Who are you?"

403 → Authorization problem
      "I know who you are,
       but you're not allowed."
```

Check:

- JWT claims
- Roles
- Permissions
- `[Authorize]`
- `[Authorize(Roles = "...")]`
- Angular route guards
- API authorization policy

This connects well with .NET JWT knowledge.

---

# 8. Memory Leak / Subscriptions Not Cleaned Up

Suppose the user navigates:

```text
Employee
 ↓
Dashboard
 ↓
Employee
 ↓
Dashboard
 ↓
Employee
```

and subscriptions keep accumulating.

You might eventually see:

```text
same API/event firing multiple times
```

Modern Angular provides lifecycle-aware approaches such as `takeUntilDestroyed()`.

Example:

```typescript
this.employeeService.getEmployees()
    .pipe(takeUntilDestroyed())
    .subscribe(data => {
        this.employees = data;
    });
```

### Key Concept

Understand **why subscriptions need lifecycle management**, rather than memorizing only the syntax.

---

# 9. Environment / Configuration Issue

Works locally:

```text
localhost API → works
```

After deployment:

```text
Production API → fails
```

### Check

```text
Development
    ↓
API URL A

Production
    ↓
API URL B
```

Also check:

- API URL
- Authentication configuration
- Environment variables/configuration
- HTTPS
- CORS
- Deployment configuration

---

# 10. UI Doesn't Update After Changing Data

Example:

```typescript
this.employee.name = 'John';
```

But the UI doesn't behave as expected.

### Troubleshoot

Check:

- Is the component holding the expected object?
- Is data being mutated directly?
- Is change detection involved?
- Is the value coming from an Observable?
- Is a parent/child component involved?

For interviews, understand Angular **change detection** rather than memorizing obscure internals.

---

# ⭐ Troubleshooting Formula to Memorize

Whenever an interviewer gives you an Angular production issue, don't jump straight to a fix.

Say:

> **"First I reproduce the issue, then I check the browser console and Network tab. I verify the request, response and status code. Then I isolate whether the issue is in the Angular UI, API communication or backend. Once I identify the root cause, I make the fix and verify the scenario again."**

This is a much stronger answer than:

> "I will check the code and fix it."

---

# 🎯 Practice Scenario

I'll give you troubleshooting scenarios one at a time during interview preparation.

## Scenario 1

You have an Angular employee page.

User clicks **Search**.

Nothing appears on the screen.

But DevTools → Network shows:

```text
GET /api/employees
Status: 200 OK

Response:
{
    "data": [
        { "id": 101, "name": "Vasanth" }
    ]
}
```

### Question

**What would you check next?**

Try to answer using:

**Problem → Investigation → Root Cause → Fix → Verification**
