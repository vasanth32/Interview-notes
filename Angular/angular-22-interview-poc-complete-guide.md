# Angular 22 Interview POC — Complete Beginner-Friendly Guide

## Project: Product Management Portal using DummyJSON

This guide builds one practical Angular 22 application that lets you practice:

- Components vs Services
- Dependency Injection
- Lifecycle hooks
- Reactive Forms
- Template-driven vs Reactive Forms
- Observable
- Subject / BehaviorSubject
- `pipe()`
- `subscribe()`
- `map`
- `filter`
- `tap`
- `switchMap`
- `mergeMap`
- `concatMap`
- `catchError`
- `debounceTime`
- `distinctUntilChanged`
- `shareReplay`
- HTTP Interceptors
- Route Guards
- Lazy Loading
- Change Detection
- Signals
- Zoneless basics
- API integration
- Angular error handling

The application uses the public DummyJSON API instead of a .NET backend. This keeps the focus on Angular while still giving you realistic HTTP, search, authentication, CRUD, loading, errors and routing scenarios.

---

# 1. What We Are Building

We will build a small application called:

**Angular Interview Store**

The application will have:

```text
Login
  |
  v
Dashboard
  |
  +---- Products
  |       |
  |       +---- Product List
  |       +---- Search
  |       +---- Product Details
  |       +---- Add Product
  |       +---- Edit Product
  |
  +---- Users
  |
  +---- Cart
  |
  +---- Admin
```

The learning flow is:

```text
Angular Component
      |
      v
Angular Service
      |
      v
HttpClient
      |
      v
RxJS Observable
      |
      v
HTTP API
      |
      v
DummyJSON
```

DummyJSON provides products, users, carts, posts, todos and authentication endpoints for frontend prototyping. Its product API supports list, search, pagination, categories and simulated POST/PUT/PATCH/DELETE operations. Note that simulated mutations do not permanently change the server data. 

---

# 2. Angular 22 Environment

Angular 22 is an actively supported Angular major release. Angular's official compatibility table lists Angular 22.0.x with Node.js `^22.22.3 || ^24.15.0`, TypeScript `>=5.9.0 <6.0.0`, and RxJS `^6.5.3 || ^7.4.0`.

Use a current Node.js version compatible with Angular 22.

Check:

```bash
node -v
npm -v
```

Install Angular CLI 22:

```bash
npm install -g @angular/cli@^22
```

Check:

```bash
ng version
```

You should see Angular CLI 22 and Angular packages 22.x.

Angular's official documentation recommends checking the installed version with:

```bash
ng version
```

---

# 3. Create the Project

Open Command Prompt or PowerShell.

Run:

```bash
ng new angular-interview-poc
```

When Angular asks questions, choose a modern standalone application.

Recommended choices:

```text
Routing: Yes
Stylesheet: CSS
SSR/SSG: No
Zoneless: Yes/default if offered
```

If your CLI presents slightly different questions, accept the modern standalone defaults.

Move into the project:

```bash
cd angular-interview-poc
```

Run:

```bash
ng serve
```

Open:

```text
http://localhost:4200
```

Stop the server with:

```text
Ctrl + C
```

---

# 4. Understand the Initial Angular Project

You will have something similar to:

```text
angular-interview-poc/
|
+-- src/
|   |
|   +-- app/
|   |   +-- app.ts
|   |   +-- app.html
|   |   +-- app.css
|   |   +-- app.routes.ts
|   |
|   +-- main.ts
|
+-- angular.json
+-- package.json
+-- tsconfig.json
```

The exact filenames can vary slightly depending on CLI options.

Important files:

### `main.ts`

This is the application bootstrap entry point.

Conceptually:

```text
Browser
   |
   v
main.ts
   |
   v
Angular application
   |
   v
Root component
```

### Root component

The root component is the starting UI component.

### `app.routes.ts`

Contains route definitions.

### `package.json`

Contains dependencies and scripts.

---

# 5. Install Nothing Extra Yet

Do not install a UI framework initially.

We want to learn Angular itself.

Use:

- Angular
- TypeScript
- RxJS
- HttpClient
- CSS

Later, you can add Angular Material if you want a nicer UI.

---

# 6. DummyJSON API

Base URL:

```text
https://dummyjson.com
```

Useful endpoints:

```text
GET  /products
GET  /products/1
GET  /products/search?q=phone
GET  /products/categories
GET  /products/category/smartphones

GET  /users
GET  /users/1
GET  /users/search?q=John

POST /products/add
PUT  /products/1
PATCH /products/1
DELETE /products/1

POST /auth/login
GET  /auth/me
POST /auth/refresh
```

DummyJSON supports pagination with `limit` and `skip`, search, sorting and category filtering.

For example:

```text
https://dummyjson.com/products?limit=10&skip=0
```

Search:

```text
https://dummyjson.com/products/search?q=phone
```

Delay an API response to test loading states:

```text
https://dummyjson.com/products?delay=2000
```

This is useful for learning loading indicators and RxJS.

---

# 7. First Practice — Components vs Services

## What is a Component?

A component represents a piece of UI.

Examples:

```text
ProductListComponent
ProductDetailsComponent
LoginComponent
DashboardComponent
```

A component normally contains:

```text
TypeScript
HTML
CSS
```

The TypeScript controls behavior and state.

The HTML displays the UI.

The CSS controls presentation.

### Simple mental model

```text
Component = UI + UI behavior
```

A component should not become a giant class containing all application logic.

---

## What is a Service?

A service is a reusable class that normally contains logic shared by multiple components.

For example:

```text
ProductService
```

can contain:

```text
getProducts()
getProduct()
searchProducts()
addProduct()
updateProduct()
deleteProduct()
```

Mental model:

```text
Component
   |
   | asks
   v
Service
   |
   | calls
   v
API
```

This separation makes the application easier to maintain and test.

---

# 8. Generate Product Components

Run:

```bash
ng generate component features/products/product-list
```

Short form:

```bash
ng g c features/products/product-list
```

Generate details:

```bash
ng g c features/products/product-details
```

Generate form:

```bash
ng g c features/products/product-form
```

Generate dashboard:

```bash
ng g c features/dashboard
```

Generate login:

```bash
ng g c features/login
```

Generate users:

```bash
ng g c features/users/user-list
```

---

# 9. Generate the Product Service

Run:

```bash
ng generate service core/services/product
```

You will get something similar to:

```text
src/app/core/services/product.service.ts
```

A service is where we put API-related logic.

---

# 10. Dependency Injection

Dependency Injection means Angular creates and provides an object for you instead of forcing a component to manually create it.

Bad mental model:

```typescript
productService = new ProductService();
```

Angular approach:

```typescript
constructor(private productService: ProductService) {}
```

Modern Angular can also use:

```typescript
private productService = inject(ProductService);
```

The second style is very common in modern Angular.

The important interview concept is:

> The component declares what dependency it needs, and Angular's dependency injection system supplies that dependency.

---

# 11. Product Model

Create:

```text
src/app/core/models/product.ts
```

Add:

```typescript
export interface Product {
  id: number;
  title: string;
  description: string;
  price: number;
  discountPercentage: number;
  rating: number;
  stock: number;
  brand?: string;
  category: string;
  thumbnail: string;
}
```

Also create:

```text
src/app/core/models/product-response.ts
```

```typescript
import { Product } from './product';

export interface ProductResponse {
  products: Product[];
  total: number;
  skip: number;
  limit: number;
}
```

Why use interfaces?

Because TypeScript can tell us what shape of data we expect.

---

# 12. Configure HttpClient

In your application bootstrap configuration, import:

```typescript
import { provideHttpClient } from '@angular/common/http';
```

Then add:

```typescript
provideHttpClient()
```

to the application providers.

Conceptually:

```typescript
bootstrapApplication(AppComponent, {
  providers: [
    provideHttpClient()
  ]
});
```

If your generated Angular 22 project already has `provideHttpClient()` configured, do not add it twice.

---

# 13. Product Service — First API Call

Open:

```text
product.service.ts
```

Use:

```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ProductResponse } from '../models/product-response';
import { Product } from '../models/product';

@Injectable({
  providedIn: 'root'
})
export class ProductService {

  private http = inject(HttpClient);

  private readonly apiUrl = 'https://dummyjson.com/products';

  getProducts(): Observable<ProductResponse> {
    return this.http.get<ProductResponse>(this.apiUrl);
  }

  getProduct(id: number): Observable<Product> {
    return this.http.get<Product>(`${this.apiUrl}/${id}`);
  }
}
```

---

# 14. Observable — Beginner Explanation

An Observable represents a stream of values that can arrive over time.

For HTTP:

```text
Angular
   |
   | HTTP request
   v
API
   |
   | response later
   v
Observable
```

The important point is that calling an Observable-producing method does not normally mean the result has already been delivered to your component. You subscribe to consume the stream. Angular's HttpClient returns RxJS Observables for HTTP operations.

Think:

```text
Observable = promise of a stream/value that can be subscribed to
```

For a normal HTTP GET, you generally receive one response and then the Observable completes.

---

# 15. `subscribe()` — Beginner Explanation

`subscribe()` is how you consume an Observable.

Example:

```typescript
this.productService.getProducts()
  .subscribe(response => {
    console.log(response);
  });
```

Think:

```text
getProducts()
      |
      v
Observable
      |
      v
subscribe()
      |
      v
response
```

The callback executes when the Observable emits.

Interview answer:

> `subscribe()` starts/consumes an Observable and lets us react to emitted values, errors and completion.

For modern Angular applications, also learn the `async` pipe and signal-based approaches so that you don't manually subscribe everywhere.

---

# 16. Display Products

In `product-list.ts`:

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { ProductService } from '../../../core/services/product.service';
import { Product } from '../../../core/models/product';

@Component({
  selector: 'app-product-list',
  standalone: true,
  templateUrl: './product-list.html',
  styleUrl: './product-list.css'
})
export class ProductListComponent implements OnInit {

  private productService = inject(ProductService);

  products: Product[] = [];

  ngOnInit(): void {
    this.productService.getProducts()
      .subscribe(response => {
        this.products = response.products;
      });
  }
}
```

Template:

```html
<h2>Products</h2>

<div>
  @for (product of products; track product.id) {
    <div>
      <h3>{{ product.title }}</h3>
      <p>{{ product.description }}</p>
      <strong>${{ product.price }}</strong>
    </div>
  }
</div>
```

Run:

```bash
ng serve
```

---

# 17. Lifecycle Hooks

A lifecycle hook lets you execute code at a particular stage of a component's life.

Important hooks for your interview:

```text
ngOnInit
ngOnChanges
ngAfterViewInit
ngOnDestroy
```

For this POC, focus first on:

```text
ngOnInit
ngOnDestroy
```

`ngOnInit()` runs after Angular initializes the component's inputs. It is commonly used for initial data loading.

`ngOnDestroy()` runs when the component is destroyed. It is commonly used for cleanup, such as manually managed subscriptions, timers or event listeners.

Example:

```typescript
ngOnInit() {
  console.log('Product list initialized');
}

ngOnDestroy() {
  console.log('Product list destroyed');
}
```

---

# 18. Exercise — Prove Lifecycle Hooks

Add:

```typescript
ngOnInit() {
  console.log('ProductList ngOnInit');
}

ngOnDestroy() {
  console.log('ProductList ngOnDestroy');
}
```

Navigate away from the component.

Look at the browser console.

You should observe:

```text
ProductList ngOnInit
```

when created and:

```text
ProductList ngOnDestroy
```

when destroyed.

This is much better than memorizing lifecycle definitions.

---

# 19. `pipe()` — Beginner Explanation

RxJS `pipe()` lets you build a chain of operators that transform, inspect or handle an Observable.

Example:

```typescript
this.productService.getProducts().pipe(
  map(response => response.products)
);
```

Think:

```text
Observable
   |
   v
pipe()
   |
   +--> map
   |
   +--> filter
   |
   +--> tap
   |
   +--> catchError
   |
   v
new Observable
```

`pipe()` itself does not mean "subscribe".

It means:

> Take this Observable and apply these RxJS operators to it.

---

# 20. `map()` — Beginner Explanation

`map()` transforms each emitted value into another value.

Suppose the API gives:

```typescript
{
  products: [...],
  total: 194,
  skip: 0,
  limit: 30
}
```

But your component only wants:

```typescript
Product[]
```

Use:

```typescript
map(response => response.products)
```

Then:

```text
API response
     |
     v
map()
     |
     v
products array
```

Example:

```typescript
getProducts(): Observable<Product[]> {
  return this.http.get<ProductResponse>(this.apiUrl).pipe(
    map(response => response.products)
  );
}
```

Now the component does not need to know about the API wrapper.

---

# 21. `filter()` — Beginner Explanation

RxJS `filter()` allows an emitted value to continue only when a condition is true.

Example:

```typescript
of(1, 2, 3, 4, 5).pipe(
  filter(x => x > 3)
)
```

The output is:

```text
4
5
```

Important distinction:

```text
RxJS filter()
```

filters Observable emissions.

JavaScript:

```typescript
array.filter(...)
```

filters array elements.

In your POC, use both deliberately so you understand the difference.

---

# 22. `tap()` — Beginner Explanation

`tap()` is used when you want to observe an Observable without changing its value.

Example:

```typescript
this.productService.getProducts().pipe(
  tap(response => {
    console.log('API response:', response);
  }),
  map(response => response.products)
);
```

The response continues through the pipeline unchanged.

Use `tap()` for things such as:

```text
logging
debugging
setting UI state
analytics
```

Do not use `tap()` as your main transformation operator. Use `map()` for transformation.

---

# 23. Refactor Product Service with `pipe()`

Change:

```typescript
getProducts(): Observable<ProductResponse> {
  return this.http.get<ProductResponse>(this.apiUrl);
}
```

to:

```typescript
getProducts(): Observable<Product[]> {
  return this.http.get<ProductResponse>(this.apiUrl).pipe(
    tap(response => console.log('Raw API response:', response)),
    map(response => response.products)
  );
}
```

Import:

```typescript
import { map, tap } from 'rxjs';
```

Now the component receives only:

```text
Product[]
```

---

# 24. `catchError()` — Beginner Explanation

`catchError()` lets you handle an error inside an RxJS pipeline.

Example:

```typescript
catchError(error => {
  console.error('Product API failed', error);
  return of([]);
})
```

Why return `of([])`?

Because the Observable pipeline still needs to return an Observable.

Think:

```text
API
 |
 X error
 |
 v
catchError
 |
 +----> log error
 |
 +----> return fallback value
 |
 v
[]
```

For a list page, returning an empty array can be a reasonable demonstration.

In a real application, you may instead rethrow the error or convert it to a domain-specific error.

---

# 25. Add Error Handling

```typescript
import { catchError, map, of, tap } from 'rxjs';

getProducts(): Observable<Product[]> {
  return this.http.get<ProductResponse>(this.apiUrl).pipe(
    tap(response => console.log(response)),
    map(response => response.products),
    catchError(error => {
      console.error('Failed to load products', error);
      return of([]);
    })
  );
}
```

---

# 26. Add Loading State

In the component:

```typescript
loading = false;
```

Then:

```typescript
this.loading = true;

this.productService.getProducts()
  .subscribe({
    next: products => {
      this.products = products;
      this.loading = false;
    },
    error: error => {
      console.error(error);
      this.loading = false;
    }
  });
```

Template:

```html
@if (loading) {
  <p>Loading...</p>
}

@if (!loading) {
  <p>Products loaded.</p>
}
```

Later we will improve this using `finalize()` and signals.

---

# 27. Search Products

DummyJSON supports:

```text
GET /products/search?q=phone
```

Add this to your service:

```typescript
searchProducts(term: string): Observable<Product[]> {
  return this.http
    .get<ProductResponse>(
      `${this.apiUrl}/search?q=${encodeURIComponent(term)}`
    )
    .pipe(
      map(response => response.products)
    );
}
```

---

# 28. Reactive Forms

Reactive Forms are forms where the form model is created in TypeScript.

Example:

```typescript
productForm = this.fb.group({
  title: ['', Validators.required],
  price: [0, [Validators.required, Validators.min(0)]],
  stock: [0, [Validators.required, Validators.min(0)]],
  category: ['', Validators.required]
});
```

The form is explicit and strongly controlled from TypeScript.

This is particularly useful for larger forms, dynamic forms, complex validation and testable form logic.

---

# 29. Add Reactive Forms Imports

In the standalone component:

```typescript
import {
  FormBuilder,
  ReactiveFormsModule,
  Validators
} from '@angular/forms';
```

Add:

```typescript
imports: [ReactiveFormsModule]
```

Then:

```typescript
private fb = inject(FormBuilder);
```

---

# 30. Create Product Form

```typescript
productForm = this.fb.group({
  title: ['', Validators.required],
  price: [0, [Validators.required, Validators.min(0)]],
  stock: [0, [Validators.required, Validators.min(0)]],
  category: ['', Validators.required]
});
```

Template:

```html
<form [formGroup]="productForm" (ngSubmit)="save()">

  <label>Title</label>
  <input formControlName="title">

  @if (
    productForm.controls.title.touched &&
    productForm.controls.title.invalid
  ) {
    <p>Title is required.</p>
  }

  <label>Price</label>
  <input type="number" formControlName="price">

  <label>Stock</label>
  <input type="number" formControlName="stock">

  <label>Category</label>
  <input formControlName="category">

  <button type="submit" [disabled]="productForm.invalid">
    Save
  </button>

</form>
```

---

# 31. Submit Reactive Form

```typescript
save(): void {
  if (this.productForm.invalid) {
    this.productForm.markAllAsTouched();
    return;
  }

  console.log(this.productForm.value);
}
```

You now have:

```text
FormGroup
FormControl
FormBuilder
Validators
ReactiveFormsModule
```

---

# 32. `valueChanges`

Reactive Forms expose an Observable called `valueChanges`.

Example:

```typescript
this.productForm.controls.title.valueChanges
  .subscribe(value => {
    console.log('Title changed:', value);
  });
```

This is an excellent way to connect Forms with RxJS.

---

# 33. Template-Driven Forms

Create a tiny contact form or login form using:

```html
<form #loginForm="ngForm">
  <input
    name="username"
    [(ngModel)]="username"
    required
  >

  <button [disabled]="loginForm.invalid">
    Login
  </button>
</form>
```

Template-driven forms put more form configuration in the HTML.

Mental comparison:

```text
Template-driven:
HTML is more important

Reactive:
TypeScript form model is more important
```

For interview purposes, know both, but spend more time on Reactive Forms.

---

# 34. Template-driven vs Reactive Forms

Template-driven forms are simpler for small forms and rely heavily on directives such as `ngModel` and `ngForm`. Reactive forms create an explicit form model in TypeScript and are generally easier to scale when you have complex validation, dynamic controls, conditional fields and extensive testing.

Interview answer:

> "I use Template-driven Forms for simple forms where the validation and structure are straightforward. For complex enterprise forms, I prefer Reactive Forms because the form model, validation and value changes are explicitly managed in TypeScript."

---

# 35. Subject

A `Subject` is both an Observable and an Observer.

It can:

```text
receive values
AND
broadcast values
```

Example:

```typescript
private refreshSubject = new Subject<void>();

refresh$ = this.refreshSubject.asObservable();

refreshProducts(): void {
  this.refreshSubject.next();
}
```

A Subject is useful for event-style communication.

Think:

```text
Component A
    |
    | next()
    v
 Subject
    |
    +----> Component B
    |
    +----> Component C
```

---

# 36. BehaviorSubject

A `BehaviorSubject` is like a Subject that stores the latest value and immediately gives that current value to a new subscriber.

Example:

```typescript
private userSubject =
  new BehaviorSubject<User | null>(null);

user$ = this.userSubject.asObservable();
```

After login:

```typescript
this.userSubject.next(user);
```

A component subscribing later can immediately receive the current user.

Mental model:

```text
Subject:
"What is happening now?"

BehaviorSubject:
"What is the current state?"
```

Use BehaviorSubject in this POC for current authentication/user state.

---

# 37. Create Auth Service

Generate:

```bash
ng g s core/services/auth
```

Use:

```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, tap } from 'rxjs';

export interface LoginResponse {
  id: number;
  username: string;
  firstName: string;
  lastName: string;
  accessToken: string;
  refreshToken: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  private http = inject(HttpClient);

  private userSubject =
    new BehaviorSubject<LoginResponse | null>(null);

  user$ = this.userSubject.asObservable();

  login(username: string, password: string): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(
      'https://dummyjson.com/auth/login',
      {
        username,
        password,
        expiresInMins: 30
      }
    ).pipe(
      tap(user => {
        localStorage.setItem('accessToken', user.accessToken);
        this.userSubject.next(user);
      })
    );
  }

  logout(): void {
    localStorage.removeItem('accessToken');
    this.userSubject.next(null);
  }

  isLoggedIn(): boolean {
    return !!localStorage.getItem('accessToken');
  }

  getToken(): string | null {
    return localStorage.getItem('accessToken');
  }
}
```

DummyJSON documents the login endpoint and provides a test credential such as `emilys` / `emilyspass`; it returns access and refresh tokens. Use those only for this demo API, not for a real application.

---

# 38. HTTP Interceptor

An HTTP interceptor sits between your application and HTTP backend.

Think:

```text
Component
   |
   v
HttpClient
   |
   v
Interceptor
   |
   v
API
```

A common use is adding an access token:

```text
Authorization: Bearer <token>
```

Other uses:

```text
logging
loading indicators
global error handling
correlation IDs
headers
retry policies
```

---

# 39. Generate Interceptor

Run:

```bash
ng g interceptor core/interceptors/auth
```

Use a functional interceptor:

```typescript
import {
  HttpInterceptorFn
} from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const authInterceptor: HttpInterceptorFn =
  (req, next) => {

    const authService = inject(AuthService);
    const token = authService.getToken();

    if (!token) {
      return next(req);
    }

    const clonedRequest = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`
      }
    });

    return next(clonedRequest);
  };
```

Important:

HTTP requests are immutable, so you clone the request when you need to modify it.

---

# 40. Register the Interceptor

In application providers:

```typescript
import {
  provideHttpClient,
  withInterceptors
} from '@angular/common/http';

import {
  authInterceptor
} from './app/core/interceptors/auth.interceptor';
```

Then:

```typescript
provideHttpClient(
  withInterceptors([
    authInterceptor
  ])
)
```

Now requests pass through the interceptor.

---

# 41. Route Guards

A route guard decides whether navigation to a route is allowed.

Mental model:

```text
User clicks /products
        |
        v
     Guard
        |
    +---+---+
    |       |
 allowed  denied
    |       |
    v       v
Products  Login
```

Use a guard for authentication/authorization.

---

# 42. Generate Auth Guard

Run:

```bash
ng g guard core/guards/auth
```

Choose functional guard if prompted.

Example:

```typescript
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = () => {

  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isLoggedIn()) {
    return true;
  }

  return router.createUrlTree(['/login']);
};
```

---

# 43. Routing

Your route configuration can look conceptually like:

```typescript
export const routes: Routes = [
  {
    path: '',
    redirectTo: 'dashboard',
    pathMatch: 'full'
  },

  {
    path: 'login',
    loadComponent: () =>
      import('./features/login/login')
        .then(m => m.LoginComponent)
  },

  {
    path: 'dashboard',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./features/dashboard/dashboard')
        .then(m => m.DashboardComponent)
  },

  {
    path: 'products',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./features/products/product-list/product-list')
        .then(m => m.ProductListComponent)
  }
];
```

The exact generated filenames may differ depending on your CLI's naming style. Adjust the import paths to match your generated files.

---

# 44. Lazy Loading

Lazy loading means a feature is loaded when it is needed rather than loading everything at initial startup.

Example:

```typescript
{
  path: 'products',
  loadComponent: () =>
    import('./features/products/product-list/product-list')
      .then(m => m.ProductListComponent)
}
```

Mental model:

```text
Initial application
       |
       +--> Login
       +--> basic shell

User clicks Products
       |
       v
Load Product component
```

This can reduce initial JavaScript work for larger applications.

---

# 45. Login Component

Use Reactive Forms.

Fields:

```text
username
password
```

Form:

```typescript
loginForm = this.fb.group({
  username: ['emilys', Validators.required],
  password: ['emilyspass', Validators.required]
});
```

On submit:

```typescript
login(): void {

  if (this.loginForm.invalid) {
    this.loginForm.markAllAsTouched();
    return;
  }

  const { username, password } = this.loginForm.getRawValue();

  this.authService.login(username!, password!)
    .subscribe({
      next: () => {
        this.router.navigate(['/dashboard']);
      },
      error: error => {
        console.error('Login failed', error);
      }
    });
}
```

---

# 46. `switchMap`

This is one of the most important RxJS interview concepts.

Suppose the user types:

```text
p
ph
pho
phon
phone
```

Each value could create an HTTP request.

If the user types again before the previous request finishes, you normally care about the latest search.

That is a perfect `switchMap` scenario.

Conceptually:

```text
search term
    |
    v
debounce
    |
    v
switchMap
    |
    v
HTTP request
```

When a new value arrives, `switchMap` switches to the newest inner Observable.

Interview answer:

> "I use switchMap when only the latest operation matters, such as type-ahead search. When a new value arrives, it switches to the new inner Observable and unsubscribes from the previous one."

---

# 47. Search Box with `debounceTime`

Add:

```typescript
searchControl = new FormControl('');
```

Then:

```typescript
ngOnInit(): void {

  this.searchControl.valueChanges.pipe(
    debounceTime(400),
    distinctUntilChanged(),
    switchMap(term =>
      this.productService.searchProducts(term ?? '')
    )
  ).subscribe(products => {
    this.products = products;
  });

}
```

---

# 48. `debounceTime`

Without debounce:

```text
p       -> API
ph      -> API
pho     -> API
phon    -> API
phone   -> API
```

With:

```typescript
debounceTime(400)
```

Angular waits until the user stops typing for approximately 400ms before allowing the value through.

So:

```text
p
ph
pho
phon
phone
       |
       | user pauses
       v
    phone
       |
       v
      API
```

This reduces unnecessary API calls.

---

# 49. `distinctUntilChanged`

Suppose:

```text
phone
phone
phone
```

Without `distinctUntilChanged`, each value can continue.

With:

```typescript
distinctUntilChanged()
```

duplicate consecutive values are ignored.

So:

```text
phone
phone
phone
laptop
laptop
```

becomes:

```text
phone
laptop
```

This is useful with search inputs and filters.

---

# 50. Complete Search Pipeline

Your final search pipeline:

```typescript
this.searchControl.valueChanges.pipe(

  debounceTime(400),

  distinctUntilChanged(),

  tap(term => {
    console.log('Searching:', term);
  }),

  switchMap(term =>
    this.productService.searchProducts(term ?? '')
  ),

  catchError(error => {
    console.error('Search failed:', error);
    return of([]);
  })

).subscribe(products => {
  this.products = products;
});
```

Understand every operator:

```text
valueChanges
      |
      v
debounceTime
      |
      v
distinctUntilChanged
      |
      v
tap
      |
      v
switchMap
      |
      v
HTTP API
      |
      v
catchError
      |
      v
subscribe
```

This is an excellent interview example.

---

# 51. `mergeMap`

`mergeMap` subscribes to inner Observables concurrently.

Example scenario:

```text
Load several users
      |
      +---- API user 1
      |
      +---- API user 2
      |
      +---- API user 3
```

The requests can be active at the same time.

Use it when operations are independent and you do not need previous requests cancelled.

Do NOT use `mergeMap` blindly for search, because old searches can remain active.

---

# 52. Practice `mergeMap`

Create:

```typescript
import { from } from 'rxjs';
import { mergeMap } from 'rxjs/operators';
```

Conceptual example:

```typescript
from([1, 2, 3]).pipe(
  mergeMap(id => this.productService.getProduct(id))
).subscribe(product => {
  console.log(product);
});
```

Open browser Network tools.

Observe that multiple requests can be in progress concurrently.

---

# 53. `concatMap`

`concatMap` queues inner Observables and waits for each to complete before subscribing to the next one.

Think:

```text
Request 1
   |
   v
complete
   |
   v
Request 2
   |
   v
complete
   |
   v
Request 3
```

Use it when order matters.

Typical examples:

```text
Sequential save operations
Ordered commands
Queued operations
```

---

# 54. Practice `concatMap`

```typescript
from([1, 2, 3]).pipe(
  concatMap(id => this.productService.getProduct(id))
).subscribe(product => {
  console.log(product);
});
```

Observe the Network tab and compare it with `mergeMap`.

---

# 55. Compare the Three Mapping Operators

Remember this table:

| Operator | Main idea | Typical use |
|---|---|---|
| `switchMap` | Latest wins | Search |
| `mergeMap` | Run concurrently | Independent requests |
| `concatMap` | Queue in order | Sequential operations |

The interview question is not only:

> "What is switchMap?"

It is:

> "Why did you choose switchMap instead of mergeMap?"

Your answer should be based on the business requirement.

---

# 56. `shareReplay`

Suppose multiple components call:

```typescript
getProducts()
```

You could accidentally create multiple HTTP requests.

`shareReplay(1)` can share and replay the latest emitted value to later subscribers.

Example:

```typescript
products$ = this.http
  .get<ProductResponse>(this.apiUrl)
  .pipe(
    map(response => response.products),
    shareReplay({ bufferSize: 1, refCount: true })
  );
```

Mental model:

```text
              +--> Component A
API -> shared stream
              +--> Component B
              +--> Component C
```

Instead of each consumer necessarily causing a new subscription to the source, the shared observable can reuse the latest result.

Be careful with caching. `shareReplay` is not a magic "cache forever" button; its behavior depends on configuration and source lifecycle.

---

# 57. Use `shareReplay` in Product Service

```typescript
private products$?: Observable<Product[]>;

getProducts(): Observable<Product[]> {

  if (!this.products$) {

    this.products$ = this.http
      .get<ProductResponse>(this.apiUrl)
      .pipe(
        map(response => response.products),
        shareReplay({
          bufferSize: 1,
          refCount: true
        })
      );
  }

  return this.products$;
}
```

This is one possible demonstration of caching/sharing.

---

# 58. Signals

Signals are Angular's reactive state primitive.

A signal stores a value:

```typescript
count = signal(0);
```

Read it:

```typescript
count()
```

Update it:

```typescript
count.set(10);
```

Increment:

```typescript
count.update(value => value + 1);
```

Template:

```html
<p>{{ count() }}</p>
```

Think:

```text
Signal value changes
       |
       v
Angular knows the template depends on it
       |
       v
UI updates
```

---

# 59. `computed()`

A computed signal derives a value from other signals.

Example:

```typescript
price = signal(100);
quantity = signal(2);

total = computed(() =>
  this.price() * this.quantity()
);
```

Template:

```html
<p>Total: {{ total() }}</p>
```

You do not manually update `total`.

When `price` or `quantity` changes, Angular recomputes it.

---

# 60. `effect()`

An effect runs side-effect code when signals it reads change.

Example:

```typescript
effect(() => {
  console.log('Count:', this.count());
});
```

Use effects for side effects, not as a replacement for every computed value.

Good mental distinction:

```text
signal()
    = state

computed()
    = derived state

effect()
    = side effect
```

---

# 61. Add Signal-Based Loading

Instead of:

```typescript
loading = false;
```

try:

```typescript
loading = signal(false);
```

Before request:

```typescript
this.loading.set(true);
```

After response:

```typescript
this.loading.set(false);
```

Template:

```html
@if (loading()) {
  <p>Loading...</p>
}
```

---

# 62. Change Detection

Change detection is Angular's process of determining when views need to be synchronized with application state.

For interview preparation, understand:

```text
State changes
     |
     v
Angular determines affected views
     |
     v
Template is refreshed
```

Do not think of change detection as "Angular constantly checks every variable in the whole application."

Modern Angular's reactive APIs, including signals, give Angular information about state changes.

---

# 63. OnPush

Create a child component:

```text
ProductCardComponent
```

Use:

```typescript
changeDetection: ChangeDetectionStrategy.OnPush
```

Example:

```typescript
@Component({
  selector: 'app-product-card',
  changeDetection: ChangeDetectionStrategy.OnPush,
  ...
})
```

OnPush encourages more predictable input/reference-driven and reactive updates.

For zoneless applications, Angular's official guidance recommends OnPush as a useful compatibility practice, although OnPush is not itself required for zoneless operation.

---

# 64. Zoneless in Angular 22

Important:

Angular's official documentation states that zoneless change detection is the default in Angular v21 and later.

Therefore, for Angular 22 you normally do not need to add a special provider just to turn zoneless on.

Do NOT blindly add:

```typescript
provideZoneChangeDetection()
```

because that configures ZoneJS-based change detection.

Angular's `provideZonelessChangeDetection()` API exists, but in Angular 22 it is generally unnecessary because zoneless is already the default.

The important interview point is:

> Angular can schedule change detection from Angular-aware notifications such as signal updates, component input changes, template listeners and other framework mechanisms rather than relying on ZoneJS to detect asynchronous activity.

---

# 65. Experiment with Zoneless

Use a signal:

```typescript
count = signal(0);

increment() {
  this.count.update(value => value + 1);
}
```

Template:

```html
<button (click)="increment()">
  Count: {{ count() }}
</button>
```

This works naturally with zoneless Angular because the signal update is a framework-aware notification.

The important thing is not to memorize:

```text
Zoneless = faster
```

Instead understand:

```text
ZoneJS
  -> observes async activity
  -> schedules change detection

Zoneless
  -> Angular-aware notifications
  -> schedules synchronization when relevant
```

Angular's official documentation describes zoneless as the default from Angular v21 onward.

---

# 66. API Error Handling

You should practice three levels.

## Level 1 — Local component handling

```typescript
this.productService.getProducts()
  .subscribe({
    next: products => {
      this.products = products;
    },
    error: error => {
      console.error(error);
      this.errorMessage = 'Unable to load products';
    }
  });
```

## Level 2 — Service/RxJS handling

```typescript
catchError(error => {
  console.error(error);
  return of([]);
})
```

## Level 3 — HTTP interceptor

Use the interceptor for cross-cutting behavior such as:

```text
401
403
500
network failures
logging
```

Do not put every possible business error in the interceptor.

---

# 67. HTTP Status Code Practice

Intentionally test different situations.

```text
200
Success

401
Not authenticated

403
Authenticated but not allowed

404
Resource not found

500
Server-side failure
```

Your UI should give the user a useful message instead of showing a raw technical exception.

---

# 68. Product Details

Create:

```text
/product/:id
```

Route:

```typescript
{
  path: 'products/:id',
  loadComponent: () =>
    import('./features/products/product-details/product-details')
      .then(m => m.ProductDetailsComponent)
}
```

In the component:

```typescript
private route = inject(ActivatedRoute);
private productService = inject(ProductService);

product?: Product;

ngOnInit(): void {

  const id = Number(
    this.route.snapshot.paramMap.get('id')
  );

  this.productService.getProduct(id)
    .subscribe(product => {
      this.product = product;
    });
}
```

---

# 69. `ActivatedRoute`

`ActivatedRoute` gives you information about the current route.

For:

```text
/products/5
```

the route parameter is:

```text
id = 5
```

Use:

```typescript
route.snapshot.paramMap.get('id')
```

for a one-time read.

For more reactive route handling, use the route parameter Observable.

---

# 70. Product Add

DummyJSON supports:

```text
POST /products/add
```

Service:

```typescript
addProduct(product: Partial<Product>): Observable<Product> {
  return this.http.post<Product>(
    `${this.apiUrl}/add`,
    product
  );
}
```

Call:

```typescript
this.productService.addProduct({
  title: this.productForm.value.title ?? '',
  price: this.productForm.value.price ?? 0
});
```

Remember:

DummyJSON simulates the operation. It returns a created product, but it does not permanently add it to the remote database.

---

# 71. Product Update

```typescript
updateProduct(
  id: number,
  product: Partial<Product>
): Observable<Product> {
  return this.http.patch<Product>(
    `${this.apiUrl}/${id}`,
    product
  );
}
```

---

# 72. Product Delete

```typescript
deleteProduct(id: number): Observable<Product> {
  return this.http.delete<Product>(
    `${this.apiUrl}/${id}`
  );
}
```

---

# 73. Practice `map()` with Real Data

Create:

```typescript
products$ = this.productService.getProducts().pipe(
  map(products =>
    products.map(product => ({
      ...product,
      displayPrice: `$${product.price}`
    }))
  )
);
```

This teaches an important distinction:

```text
RxJS map
    +
JavaScript Array.map
```

The outer `map()` transforms the Observable emission.

The inner `.map()` transforms elements of the array.

---

# 74. Practice `filter()` with Real Data

```typescript
products$ = this.productService.getProducts().pipe(
  map(products =>
    products.filter(product => product.stock > 0)
  )
);
```

Now only products with stock remain.

---

# 75. Practice `tap()` for Debugging

```typescript
products$ = this.productService.getProducts().pipe(
  tap(products =>
    console.log('Products before filtering:', products)
  ),
  map(products =>
    products.filter(product => product.stock > 0)
  ),
  tap(products =>
    console.log('Products after filtering:', products)
  )
);
```

This gives you a practical debugging example.

---

# 76. Practice `catchError()` Correctly

Example:

```typescript
products$ = this.productService.getProducts().pipe(
  catchError(error => {
    console.error('API failed:', error);

    this.errorMessage.set(
      'Products could not be loaded.'
    );

    return of([]);
  })
);
```

Remember:

`catchError()` changes the error path into another Observable.

---

# 77. Better Loading Management

Use `finalize()`.

```typescript
this.loading.set(true);

this.productService.getProducts()
  .pipe(
    finalize(() => this.loading.set(false))
  )
  .subscribe({
    next: products => {
      this.products = products;
    },
    error: error => {
      console.error(error);
    }
  });
```

The `finalize()` callback runs when the Observable terminates through completion or error.

This is often cleaner than setting loading to false in multiple branches.

---

# 78. Dashboard

Create dashboard cards:

```text
Products: 194
Users: 208
Cart items: ...
```

Call multiple APIs.

This gives you another opportunity to practice RxJS.

---

# 79. Practice `forkJoin`

Although not on your original list, learn this because it naturally appears when working with multiple HTTP calls.

```typescript
forkJoin({
  products: this.productService.getProducts(),
  users: this.userService.getUsers()
})
.subscribe(result => {
  console.log(result.products);
  console.log(result.users);
});
```

Concept:

```text
Products API ----\
                  \
                   -> forkJoin -> result
                  /
Users API -------/
```

It waits for all supplied Observables to complete.

This is a useful addition for your interview preparation.

---

# 80. User Service

Generate:

```bash
ng g s core/services/user
```

Example:

```typescript
@Injectable({
  providedIn: 'root'
})
export class UserService {

  private http = inject(HttpClient);

  getUsers(): Observable<UserResponse> {
    return this.http.get<UserResponse>(
      'https://dummyjson.com/users'
    );
  }

  getUser(id: number): Observable<User> {
    return this.http.get<User>(
      `https://dummyjson.com/users/${id}`
    );
  }

  searchUsers(term: string): Observable<UserResponse> {
    return this.http.get<UserResponse>(
      `https://dummyjson.com/users/search?q=${encodeURIComponent(term)}`
    );
  }
}
```

---

# 81. Authentication Flow

Your final flow should be:

```text
Login page
   |
   v
Reactive Form
   |
   v
AuthService.login()
   |
   v
POST /auth/login
   |
   v
accessToken
   |
   v
localStorage
   |
   v
BehaviorSubject
   |
   v
AuthGuard
   |
   v
Dashboard
```

Then:

```text
Dashboard API request
   |
   v
HttpClient
   |
   v
Auth Interceptor
   |
   v
Authorization header
   |
   v
DummyJSON
```

This is a very strong end-to-end Angular interview scenario.

---

# 82. Current User

After login, call:

```text
GET /auth/me
```

with:

```http
Authorization: Bearer <accessToken>
```

This gives you practice with authenticated API calls.

Service:

```typescript
getCurrentUser(): Observable<LoginResponse> {
  return this.http.get<LoginResponse>(
    'https://dummyjson.com/auth/me'
  );
}
```

The interceptor should automatically add the token.

---

# 83. Share Auth State

Use:

```typescript
private userSubject =
  new BehaviorSubject<LoginResponse | null>(null);

user$ = this.userSubject.asObservable();
```

Navbar:

```typescript
this.authService.user$
  .subscribe(user => {
    this.user = user;
  });
```

Better later:

```html
@if (authService.user$ | async; as user) {
  <p>Welcome {{ user.firstName }}</p>
}
```

This lets you discuss Observable-based state.

---

# 84. Do Not Overuse Subjects

A common interview trap is:

> "Can I use BehaviorSubject for everything?"

No.

Use the simplest state mechanism that fits the problem.

Examples:

```text
Local component state -> signal
Derived state -> computed
API stream -> Observable
Current shared state -> signal/service or BehaviorSubject depending on design
Event stream -> Subject
```

The goal is not to use every RxJS feature everywhere.

The goal is to understand why you choose each one.

---

# 85. Error Interceptor

You can create a second interceptor:

```bash
ng g interceptor core/interceptors/error
```

Example:

```typescript
export const errorInterceptor: HttpInterceptorFn =
  (req, next) => {

    return next(req).pipe(
      catchError(error => {

        if (error.status === 401) {
          console.error('Unauthorized');
        }

        if (error.status === 403) {
          console.error('Forbidden');
        }

        if (error.status === 404) {
          console.error('Not found');
        }

        if (error.status >= 500) {
          console.error('Server error');
        }

        return throwError(() => error);
      })
    );
  };
```

Register it:

```typescript
provideHttpClient(
  withInterceptors([
    authInterceptor,
    errorInterceptor
  ])
)
```

---

# 86. Why Rethrow the Error?

Notice:

```typescript
return throwError(() => error);
```

The interceptor handled the cross-cutting logging.

But it still allows the component/service to handle the error.

Flow:

```text
API error
   |
   v
Interceptor
   |
   +--> log
   |
   v
throwError
   |
   v
Component/service
```

This separation is important.

---

# 87. Navigation Layout

Create a simple navigation bar:

```html
<nav>
  <a routerLink="/dashboard">Dashboard</a>
  <a routerLink="/products">Products</a>
  <a routerLink="/users">Users</a>
  <button (click)="logout()">Logout</button>
</nav>

<router-outlet />
```

This turns your individual experiments into a real application.

---

# 88. Final Folder Structure

Aim for something similar to:

```text
src/app/
|
+-- core/
|   |
|   +-- guards/
|   |   +-- auth.guard.ts
|   |
|   +-- interceptors/
|   |   +-- auth.interceptor.ts
|   |   +-- error.interceptor.ts
|   |
|   +-- models/
|   |   +-- product.ts
|   |   +-- product-response.ts
|   |   +-- user.ts
|   |
|   +-- services/
|       +-- auth.service.ts
|       +-- product.service.ts
|       +-- user.service.ts
|
+-- features/
|   |
|   +-- login/
|   |
|   +-- dashboard/
|   |
|   +-- products/
|   |   +-- product-list/
|   |   +-- product-details/
|   |   +-- product-form/
|   |
|   +-- users/
|       +-- user-list/
|
+-- app.routes.ts
+-- app.ts
+-- app.html
```

---

# 89. Your Complete Learning Map

## Components vs Services

```text
Component
    -> UI
    -> user interaction

Service
    -> reusable logic
    -> API calls
    -> shared state
```

Interview sentence:

> "I keep presentation and user interaction in components, while reusable API and business-related logic goes into injectable services."

---

## Dependency Injection

```text
Component
   |
   | requests ProductService
   v
Angular DI
   |
   v
ProductService instance
```

Interview sentence:

> "Dependency Injection allows Angular to provide dependencies to classes instead of those classes creating dependencies manually."

---

## Lifecycle Hooks

```text
create
  |
ngOnInit
  |
running
  |
ngOnDestroy
  |
destroyed
```

Use:

```text
ngOnInit -> initialization
ngOnDestroy -> cleanup
```

---

## Observable

```text
stream of values over time
```

HTTP is a common Angular Observable source.

---

## Subject

```text
Observable + Observer
```

Useful for event-style multicasting.

---

## BehaviorSubject

```text
Subject + current value
```

Useful for shared current state.

---

## pipe()

```text
Observable
   |
pipe()
   |
operators
   |
new Observable
```

---

## subscribe()

```text
Observable
   |
subscribe()
   |
consume emitted value
```

---

## map()

```text
value A
  |
 map
  |
value B
```

Transforms.

---

## filter()

```text
values
  |
condition
  |
matching values
```

Filters.

---

## tap()

```text
value
  |
tap
  |
same value continues
```

Observes without transforming.

---

## switchMap()

```text
new value
  |
cancel/switch from previous inner stream
  |
latest stream
```

Best mental example:

```text
search
```

---

## mergeMap()

```text
source
 |
 +--> request 1
 +--> request 2
 +--> request 3
```

Concurrent.

---

## concatMap()

```text
request 1
   |
complete
   |
request 2
   |
complete
   |
request 3
```

Sequential.

---

## catchError()

```text
error
  |
catchError
  |
fallback/rethrow
```

---

## debounceTime()

```text
typing
typing
typing
pause
  |
value continues
```

Reduces rapid emissions.

---

## distinctUntilChanged()

```text
A
A
A
B
B
C
```

becomes:

```text
A
B
C
```

for consecutive duplicates.

---

## shareReplay()

```text
source
  |
shared Observable
  |
  +--> subscriber A
  +--> subscriber B
```

Can share and replay the latest value depending on configuration.

---

## HTTP Interceptor

```text
HTTP request
    |
interceptor
    |
modify/log/handle
    |
API
```

---

## Route Guard

```text
navigation
    |
guard
    |
allowed / redirected
```

---

## Lazy Loading

```text
application starts
      |
feature not loaded yet
      |
user opens route
      |
feature loaded
```

---

## Change Detection

Angular synchronizes application state with the rendered view.

For your interview, understand how signals, inputs, template listeners and other Angular notifications interact with modern change detection.

---

## Signals

```text
signal
   = state

computed
   = derived state

effect
   = side effect
```

---

## Zoneless

Angular 21+ defaults to zoneless change detection.

Angular 22 therefore gives you a modern environment where Angular does not need ZoneJS to decide that every asynchronous browser activity should schedule a change-detection cycle.

Focus on understanding Angular-aware notifications rather than memorizing an implementation detail.

---

# 90. Final Interview Scenarios

After completing the POC, practice these questions aloud.

## Scenario 1

> User types into a product search box. How do you avoid sending an API request for every keystroke?

Answer structure:

```text
FormControl.valueChanges
        |
debounceTime
        |
distinctUntilChanged
        |
switchMap
        |
API
```

---

## Scenario 2

> Why switchMap instead of mergeMap?

Answer:

> Search only needs the latest request, so switchMap prevents previous search streams from remaining relevant. mergeMap allows inner operations to run concurrently, which is useful when all operations are independent and should continue.

---

## Scenario 3

> Where do you put API calls?

Answer:

> In injectable services rather than directly in UI components, so API logic is reusable, testable and separated from presentation.

---

## Scenario 4

> How does authentication work?

```text
Login
 ↓
API
 ↓
access token
 ↓
store token
 ↓
interceptor
 ↓
Authorization header
 ↓
protected API
```

---

## Scenario 5

> How does a route guard work?

```text
Navigation
 ↓
Guard
 ↓
isAuthenticated?
 ↓
yes -> route
no  -> login
```

---

## Scenario 6

> What is the difference between Subject and BehaviorSubject?

Answer:

> Subject does not replay a current value to a new subscriber, while BehaviorSubject stores the latest value and immediately emits it to a new subscriber.

---

## Scenario 7

> Why do we need pipe()?

Answer:

> pipe() lets us compose RxJS operators such as map, filter, tap, switchMap and catchError into a readable Observable transformation pipeline.

---

## Scenario 8

> What is shareReplay used for?

Answer:

> It can share an Observable subscription and replay recent emissions to later subscribers, which can be useful for sharing/cache-like behavior such as previously loaded reference data.

---

## Scenario 9

> How do you handle API errors?

Answer:

```text
Local expected error
    -> component/service

RxJS pipeline error
    -> catchError

Cross-cutting HTTP errors
    -> interceptor

Unexpected application errors
    -> global error handling
```

---

# 91. Practice Method — Very Important

Do NOT build this by blindly copying the entire guide.

Use this cycle:

```text
1. Read concept
       ↓
2. Build tiny example
       ↓
3. Run it
       ↓
4. Break it deliberately
       ↓
5. Observe browser console/network
       ↓
6. Fix it
       ↓
7. Explain it without notes
```

For example, with switchMap:

```text
First:
switchMap

Then:
replace with mergeMap

Observe:
old requests continue

Then:
replace with concatMap

Observe:
requests queue

Finally:
explain why switchMap is appropriate for search
```

That gives you actual recall.

---

# 92. Browser DevTools Exercises

Open:

```text
F12
```

Use:

```text
Network
Console
Application
Sources
```

For API learning, Network is especially important.

Observe:

```text
Request URL
Request method
Request headers
Authorization header
Query parameters
Response
Status code
Timing
```

For search, watch:

```text
/products/search?q=...
```

For authentication:

```text
Authorization: Bearer ...
```

For errors:

```text
401
403
404
500
```

This is excellent interview preparation because you learn to troubleshoot rather than only write code.

---

# 93. Suggested Order to Actually Build It

Do NOT try to complete every topic in one sitting.

## Phase 1

```text
Create Angular 22 project
        ↓
Components
        ↓
Services
        ↓
DI
        ↓
HttpClient
        ↓
GET products
```

## Phase 2

```text
Observable
subscribe
pipe
map
filter
tap
catchError
```

## Phase 3

```text
Reactive Forms
Template-driven Forms
valueChanges
```

## Phase 4

```text
Search
debounceTime
distinctUntilChanged
switchMap
```

## Phase 5

```text
Subject
BehaviorSubject
Authentication
```

## Phase 6

```text
Interceptor
Guard
Lazy loading
```

## Phase 7

```text
mergeMap
concatMap
shareReplay
```

## Phase 8

```text
Signals
computed
effect
Change Detection
OnPush
Zoneless
```

## Phase 9

```text
Error handling
loading
401
403
404
500
network errors
```

## Phase 10

```text
Delete your notes
Rebuild the core application
Explain every piece orally
```

---

# 94. Final POC Architecture

At the end, you should be able to explain this entire flow:

```text
                         Angular 22
                             |
                 +-----------+-----------+
                 |                       |
             Components               Router
                 |                       |
                 |                  Auth Guard
                 |                       |
                 v                       v
              Services              Lazy Loading
                 |
                 v
              HttpClient
                 |
                 v
             Interceptors
                 |
                 v
              RxJS
                 |
      +----------+----------+
      |          |          |
    map       switchMap   catchError
               |
        debounceTime
               |
   distinctUntilChanged
                 |
                 v
            DummyJSON API
                 |
        +--------+--------+
        |        |        |
    Products   Users     Auth
```

And state:

```text
Signals
  |
  +--> loading
  +--> counters
  +--> local UI state

BehaviorSubject
  |
  +--> current authenticated user

Observable
  |
  +--> API streams
```

---

# 95. The One Thing I Want You to Remember

Do not learn these as 20 independent definitions.

Learn them as one application flow:

```text
User
 |
 | types "phone"
 v
Reactive FormControl
 |
 | valueChanges
 v
debounceTime
 |
 v
distinctUntilChanged
 |
 v
switchMap
 |
 v
ProductService
 |
 v
HttpClient
 |
 v
HTTP Interceptor
 |
 v
DummyJSON
 |
 v
Observable response
 |
 v
map
 |
 v
tap
 |
 v
catchError
 |
 v
Component
 |
 v
Signal/state
 |
 v
Angular change detection
 |
 v
UI
```

If you can build this flow yourself and explain **why every piece exists**, you will have much stronger Angular interview knowledge than someone who has only memorized definitions.

---

# Official References

Angular version/release information:
https://angular.dev/reference/releases

Angular installation:
https://angular.dev/installation

Angular version compatibility:
https://angular.dev/reference/versions

Angular zoneless:
https://angular.dev/guide/zoneless

Angular `provideZonelessChangeDetection`:
https://angular.dev/api/core/provideZonelessChangeDetection

DummyJSON:
https://dummyjson.com/

DummyJSON products:
https://dummyjson.com/docs/products

DummyJSON users:
https://dummyjson.com/docs/users

DummyJSON authentication:
https://dummyjson.com/docs/auth

---

# Completion Checklist

Use this checklist as you progress:

- [ ] Angular 22 project created
- [ ] Product component created
- [ ] Product service created
- [ ] Dependency Injection understood
- [ ] HttpClient configured
- [ ] Products loaded from API
- [ ] Observable understood
- [ ] subscribe understood
- [ ] pipe understood
- [ ] map practiced
- [ ] filter practiced
- [ ] tap practiced
- [ ] catchError practiced
- [ ] Reactive Form created
- [ ] Template-driven form created
- [ ] Subject practiced
- [ ] BehaviorSubject practiced
- [ ] Login implemented
- [ ] Token stored
- [ ] HTTP interceptor implemented
- [ ] Route guard implemented
- [ ] Lazy loading implemented
- [ ] Search implemented
- [ ] debounceTime implemented
- [ ] distinctUntilChanged implemented
- [ ] switchMap implemented
- [ ] mergeMap practiced
- [ ] concatMap practiced
- [ ] shareReplay practiced
- [ ] Signals practiced
- [ ] computed practiced
- [ ] effect practiced
- [ ] OnPush practiced
- [ ] Zoneless understood
- [ ] API errors handled
- [ ] Loading state handled
- [ ] 401/403/404/500 scenarios tested
- [ ] Browser Network tab used for debugging
- [ ] Entire flow explained orally without notes
