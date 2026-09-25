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

## Pause and Verify — Environment and API

No source-code change is required for this checkpoint.

1. Open a terminal in the Angular project folder, the folder that contains `package.json`.
2. Run:

```bash
ng serve
```

3. Wait for `Application bundle generation complete` or another successful compilation message.
4. Open the URL printed in the terminal, normally `http://localhost:4200`.
5. Confirm the Angular starter page appears and the terminal shows no compilation error.
6. In another browser tab, open `https://dummyjson.com/products?limit=1`.
7. Confirm the response is JSON containing a `products` array with one item.

Expected result:

```text
Angular page works         -> local application is running
DummyJSON response works   -> remote practice API is available
```

Stop and explain why `localhost:4200` and `dummyjson.com` are two separate applications. Do not continue until both URLs work.

---

# 7. First Practice — Components vs Services

## What is a Component?

A component represents a piece of UI.

Examples:

```text
ProductList
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
ng generate service core/services/product --type=service
```

You will get something similar to:

```text
src/app/core/services/product.service.ts
src/app/core/services/product.service.spec.ts
```

The `--type=service` option gives the file and class unambiguous service names: `product.service.ts` and `ProductService`. Without this option, the concise Angular 22 naming convention may generate `product.ts` with a class named `Product`, which conflicts with the `Product` model.

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
import { Product } from "./product";

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

Open:

```text
src/app/app.config.ts
```

Add this import at the top of that file:

```typescript
import { provideHttpClient } from "@angular/common/http";
```

Then add `provideHttpClient()` inside the existing `providers` array in the same file:

```typescript
import { ApplicationConfig } from "@angular/core";
import { provideHttpClient } from "@angular/common/http";
import { provideRouter } from "@angular/router";
import { routes } from "./app.routes";

export const appConfig: ApplicationConfig = {
  providers: [provideRouter(routes), provideHttpClient()],
};
```

Keep any providers already generated in `app.config.ts`, such as zoneless change detection or global error listeners. Only add `provideHttpClient()` to that existing array; do not replace the other providers.

Do not add `provideHttpClient()` to `product.ts` or `app.ts`. The generated `main.ts` already passes `appConfig` to `bootstrapApplication()`, so no change to `main.ts` is normally required.

If `app.config.ts` already contains `provideHttpClient()`, do not add it twice.

---

# 13. Product Service — First API Call

Open:

```text
src/app/core/services/product.service.ts
```

Keep Angular's `Injectable` decorator. Angular does not provide a `Service` decorator, so do not use `import { Service }` or `@Service()`.

Replace the entire contents of `src/app/core/services/product.service.ts` with:

```typescript
import { Injectable, inject } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { ProductResponse } from "../models/product-response";
import { Product } from "../models/product";

@Injectable({
  providedIn: "root",
})
export class ProductService {
  private http = inject(HttpClient);

  private readonly apiUrl = "https://dummyjson.com/products";

  getProducts(): Observable<ProductResponse> {
    return this.http.get<ProductResponse>(this.apiUrl);
  }

  getProduct(id: number): Observable<Product> {
    return this.http.get<Product>(`${this.apiUrl}/${id}`);
  }
}
```

The two names have different responsibilities:

```text
Product         -> interface in core/models/product.ts
ProductService  -> injectable API service in core/services/product.service.ts
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
this.productService.getProducts().subscribe((response) => {
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
import { Component, OnInit, inject } from "@angular/core";
import { ProductService } from "../../../core/services/product.service";
import { Product } from "../../../core/models/product";

@Component({
  selector: "app-product-list",
  standalone: true,
  templateUrl: "./product-list.html",
  styleUrl: "./product-list.css",
})
export class ProductList implements OnInit {
  private productService = inject(ProductService);

  products: Product[] = [];

  ngOnInit(): void {
    this.productService.getProducts().subscribe((response) => {
      this.products = response.products;
    });
  }
}
```

Angular 22's concise component naming generates the class as `ProductList`. Check the `export class ...` line in your generated file and use that exact class name in the route below.

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

The generated welcome page can hide routed content. In `src/app/app.ts`, keep `RouterOutlet` in the component imports and replace `templateUrl` with this inline template:

```typescript
import { Component } from "@angular/core";
import { RouterOutlet } from "@angular/router";

@Component({
  imports: [RouterOutlet],
  selector: "app-root",
  styleUrl: "./app.css",
  template: "<router-outlet />",
})
export class App {}
```

Before running the application, open `src/app/app.routes.ts` and add a temporary route for the product list:

```typescript
import { Routes } from "@angular/router";

export const routes: Routes = [
  {
    path: "products",
    loadComponent: () =>
      import("./features/products/product-list/product-list").then(
        (component) => component.ProductList,
      ),
  },
  { path: "", redirectTo: "products", pathMatch: "full" },
];
```

Keep any routes already present instead of deleting them. Add the `products` route to the existing `routes` array and add the redirect only if the empty path is not already configured.

Run from the project folder:

```bash
ng serve
```

When the terminal says the application compiled successfully, open:

```text
http://localhost:4200/products
```

Because the example also redirects the empty path, `http://localhost:4200` will open the same product list. If Angular reports a different port because `4200` is already in use, open the URL printed in the terminal and append `/products`.

## Pause and Verify — Component, Service, DI and HTTP

Files used:

```text
src/app/core/services/product.service.ts
src/app/features/products/product-list/product-list.ts
src/app/features/products/product-list/product-list.html
src/app/app.routes.ts
src/app/app.config.ts
```

Before running, confirm:

1. `app.config.ts` contains one `provideHttpClient(...)` provider.
2. `app.routes.ts` contains the `products` route.
3. `product-list.ts` calls `this.productService.getProducts()` inside `ngOnInit()`.
4. `product-list.html` contains the `@for` block that displays products.

Now verify:

1. From the project folder, run `ng serve` and keep it running.
2. Open `http://localhost:4200/products`.
3. Confirm product titles, descriptions and prices appear.
4. Press `F12`, open Network, and refresh the page.
5. Select the request named `products`.
6. Confirm Method is `GET`, Status is `200`, and Response contains a `products` array.

Expected flow:

```text
ProductList.ngOnInit()
  -> ProductService.getProducts()
  -> HttpClient.get()
  -> DummyJSON
  -> response.products
  -> this.products
  -> HTML @for block
```

If the request succeeds but the page is empty, open Console and check that `product-list.ts` assigns `response.products` to `this.products`. Stop and explain why the service performs the HTTP call while the component controls the screen.

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

## Pause and Verify — Lifecycle Hooks

File to edit:

```text
src/app/features/products/product-list/product-list.ts
src/app/app.routes.ts
```

1. Add `OnDestroy` to the Angular import and to the class declaration:

   ```typescript
   import { Component, OnDestroy, OnInit, inject } from "@angular/core";

   export class ProductList implements OnInit, OnDestroy {
   ```

2. Keep the existing product-loading code in `ngOnInit()` and add the log:

   ```typescript
   ngOnInit(): void {
     console.log("ProductList ngOnInit");

     this.productService.getProducts().subscribe((response) => {
       this.products = response.products;
     });
   }

   ngOnDestroy(): void {
     console.log("ProductList ngOnDestroy");
   }
   ```

3. Generate a small temporary component from the project folder:

   ```bash
   ng g c features/lifecycle-check
   ```

4. Open the generated `src/app/features/lifecycle-check/lifecycle-check.ts`, note its exported class name, and add this route to the `routes` array in `app.routes.ts`:

   ```typescript
   {
     path: "lifecycle-check",
     loadComponent: () =>
       import("./features/lifecycle-check/lifecycle-check").then(
         (component) => component.LifecycleCheck,
       ),
   },
   ```

   Replace `LifecycleCheck` if the generated `export class` line uses another name.

5. Run `ng serve`, open `/products`, press `F12`, and select Console.
6. Confirm `ProductList ngOnInit` appears.
7. Open `/lifecycle-check` in the same tab. Confirm `ProductList ngOnDestroy` appears.
8. Return to `/products` and confirm `ngOnInit` appears again for the new component instance.

Expected result: entering the route creates the component; navigating to the placeholder route destroys it. After this test, remove the `lifecycle-check` route and generated component folder. Keep the lifecycle methods, but remove the log statements when you no longer need them.

---

# 19. `pipe()` — Beginner Explanation

RxJS `pipe()` lets you build a chain of operators that transform, inspect or handle an Observable.

Example:

```typescript
this.productService.getProducts().pipe(map((response) => response.products));
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
map((response) => response.products);
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
of(1, 2, 3, 4, 5).pipe(filter((x) => x > 3));
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
  tap((response) => {
    console.log("API response:", response);
  }),
  map((response) => response.products),
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

This refactor changes the return type of `getProducts()`. You must update both the service and every component that subscribes to this method.

## Step 1 — Update the service

Open:

```text
src/app/core/services/product.service.ts
```

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

Also replace the existing RxJS import:

```typescript
import { Observable } from "rxjs";
```

with:

```typescript
import { map, Observable, tap } from "rxjs";
```

The type flowing out of the service has now changed:

```text
Before: Observable<ProductResponse>
After:  Observable<Product[]>
```

The `map()` operator extracts `response.products`, so subscribers no longer receive the wrapper object containing `products`, `total`, `skip` and `limit`. They receive only the product array.

## Step 2 — Update the subscribing component

Open:

```text
src/app/features/products/product-list/product-list.ts
```

Change:

```typescript
this.productService.getProducts().subscribe((response) => {
  this.products = response.products;
});
```

to:

```typescript
this.productService.getProducts().subscribe((products) => {
  this.products = products;
});
```

Why? The subscription value is now already:

```text
Product[]
```

Therefore, `response.products` is invalid after this refactor. TypeScript reports:

```text
TS2339: Property 'products' does not exist on type 'Product[]'.
```

Mental flow after the change:

```text
DummyJSON ProductResponse
  |
  v
map(response => response.products)
  |
  v
Product[]
  |
  v
subscribe(products => this.products = products)
```

## Pause and Verify — `pipe`, `map`, `filter` and `tap`

Files to edit:

```text
src/app/core/services/product.service.ts
src/app/features/products/product-list/product-list.ts
```

First, confirm `getProducts()` in `product.service.ts` currently looks like this:

```typescript
getProducts(): Observable<Product[]> {
  return this.http.get<ProductResponse>(this.apiUrl).pipe(
    tap(response => console.log("Raw API response:", response)),
    map(response => response.products)
  );
}
```

Also confirm the subscriber in `product-list.ts` receives the array directly:

```typescript
this.productService.getProducts().subscribe((products) => {
  this.products = products;
});
```

Now perform the temporary filter experiment:

1. In `product.service.ts`, add a second `map` immediately after `map(response => response.products)`:

   ```typescript
   getProducts(): Observable<Product[]> {
     return this.http.get<ProductResponse>(this.apiUrl).pipe(
       tap(response => console.log("Raw API response:", response)),
       map(response => response.products),
       map(products => products.filter(product => product.stock > 50))
     );
   }
   ```

2. Run `ng serve` and open `/products`.
3. In Console, expand `Raw API response` and note how many products arrived from the API.
4. On the page, confirm only products with `stock > 50` are displayed.
5. Change `50` to another number and observe the displayed list change.

Restore the intended code before continuing by deleting the second `map`:

```typescript
map((response) => response.products);
```

Stop and explain: `tap` logs the unchanged response, the first RxJS `map` extracts the array, and the second RxJS `map` uses JavaScript `Array.filter` to remove array items.

---

# 24. `catchError()` — Beginner Explanation

`catchError()` lets you handle an error inside an RxJS pipeline.

Example:

```typescript
catchError((error) => {
  console.error("Product API failed", error);
  return of([]);
});
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

this.productService.getProducts().subscribe({
  next: (products) => {
    this.products = products;
    this.loading = false;
  },
  error: (error) => {
    console.error(error);
    this.loading = false;
  },
});
```

Template:

```html
@if (loading) {
<p>Loading...</p>
} @if (!loading) {
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

## Pause and Verify — Error, Loading and Service Search

Files to edit:

```text
src/app/core/services/product.service.ts
src/app/features/products/product-list/product-list.ts
src/app/features/products/product-list/product-list.html
```

### Test 1 — Loading state with a delayed response

1. In `product.service.ts`, find this line inside `getProducts()`:

   ```typescript
   return this.http.get<ProductResponse>(this.apiUrl).pipe(
   ```

2. Temporarily change only that line to:

   ```typescript
   return this.http
     .get<ProductResponse>(`${this.apiUrl}?delay=2000`)
     .pipe(
   ```

3. In `product-list.ts`, confirm the component has:

   ```typescript
   loading = false;
   ```

4. Confirm `ngOnInit()` sets loading before the request and clears it afterward:

   ```typescript
   ngOnInit(): void {
     this.loading = true;

     this.productService.getProducts().subscribe({
       next: (products) => {
         this.products = products;
         this.loading = false;
       },
       error: (error) => {
         console.error(error);
         this.loading = false;
       },
     });
   }
   ```

5. In `product-list.html`, place this before the product list:

   ```html
   @if (loading) {
   <p>Loading...</p>
   }
   ```

6. Run `ng serve` and refresh `/products`. Expected result: `Loading...` remains visible for approximately two seconds, then products appear.

### Test 2 — `catchError` fallback

1. In the same HTTP call in `product.service.ts`, temporarily replace the URL with an invalid endpoint:

   ```typescript
   .get<ProductResponse>("https://dummyjson.com/invalid-products")
   ```

2. Confirm `getProducts()` ends with:

   ```typescript
   catchError((error) => {
     console.error("Failed to load products", error);
     return of([]);
   });
   ```

3. Refresh `/products` and open Console.
4. Expected result: Console shows `Failed to load products`, the page displays no products, and the application does not crash.
5. Because `of([])` converts the error into a normal empty-array emission, the subscription's `next` handler runs with `[]`.

### Test 3 — `searchProducts("phone")`

The search input is added later. Test the service temporarily from `product-list.ts` by adding this at the end of `ngOnInit()`:

```typescript
this.productService.searchProducts("phone").subscribe((products) => {
  console.log("Temporary phone search:", products);
});
```

Refresh `/products`, open Network, and confirm a request ends with `/products/search?q=phone`. Confirm Console shows the matching array.

Before continuing:

1. Restore the normal products call to `this.http.get<ProductResponse>(this.apiUrl)`.
2. Remove the temporary `searchProducts("phone")` subscription.
3. Keep the loading UI and `catchError` implementation.

Stop and explain why `catchError` returns `of([])` instead of returning a plain array.

---

# 28. Reactive Forms

Reactive Forms are forms where the form model is created in TypeScript.

Example:

```typescript
productForm = this.fb.group({
  title: ["", Validators.required],
  price: [0, [Validators.required, Validators.min(0)]],
  stock: [0, [Validators.required, Validators.min(0)]],
  category: ["", Validators.required],
});
```

The form is explicit and strongly controlled from TypeScript.

This is particularly useful for larger forms, dynamic forms, complex validation and testable form logic.

---

# 29. Add Reactive Forms Imports

In the standalone component:

```typescript
import { FormBuilder, ReactiveFormsModule, Validators } from "@angular/forms";
```

Add:

```typescript
imports: [ReactiveFormsModule];
```

Then:

```typescript
private fb = inject(FormBuilder);
```

---

# 30. Create Product Form

```typescript
productForm = this.fb.group({
  title: ["", Validators.required],
  price: [0, [Validators.required, Validators.min(0)]],
  stock: [0, [Validators.required, Validators.min(0)]],
  category: ["", Validators.required],
});
```

Template:

```html
<form [formGroup]="productForm" (ngSubmit)="save()">
  <label>Title</label>
  <input formControlName="title" />

  @if ( productForm.controls.title.touched && productForm.controls.title.invalid
  ) {
  <p>Title is required.</p>
  }

  <label>Price</label>
  <input type="number" formControlName="price" />

  <label>Stock</label>
  <input type="number" formControlName="stock" />

  <label>Category</label>
  <input formControlName="category" />

  <button type="submit" [disabled]="productForm.invalid">Save</button>
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
this.productForm.controls.title.valueChanges.subscribe((value) => {
  console.log("Title changed:", value);
});
```

This is an excellent way to connect Forms with RxJS.

---

# 33. Template-Driven Forms

Create a tiny contact form or login form using:

```html
<form #loginForm="ngForm">
  <input name="username" [(ngModel)]="username" required />

  <button [disabled]="loginForm.invalid">Login</button>
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

## Pause and Verify — Angular Forms

Files to edit:

```text
src/app/features/products/product-form/product-form.ts
src/app/features/products/product-form/product-form.html
src/app/app.routes.ts
```

### Make the form page reachable

1. Open `product-form.ts` and check its exported class name. Angular 22 may generate `ProductForm`; use the exact name from your file.
2. Confirm its `@Component` imports contain `ReactiveFormsModule`:

   ```typescript
   imports: [ReactiveFormsModule],
   ```

3. Add this temporary route to the `routes` array in `app.routes.ts`, replacing `ProductForm` if your exported class has another name:

   ```typescript
   {
     path: "products/form",
     loadComponent: () =>
       import("./features/products/product-form/product-form").then(
         (component) => component.ProductForm,
       ),
   },
   ```

4. Place the reactive form HTML from section 30 in `product-form.html`.
5. Place `productForm` and `save()` from sections 30–31 inside the class in `product-form.ts`.
6. To test `valueChanges`, implement `OnInit` and add:

   ```typescript
   ngOnInit(): void {
     this.productForm.controls.title.valueChanges.subscribe((value) => {
       console.log("Title changed:", value);
     });
   }
   ```

### Run and verify

1. Run `ng serve` and open `/products/form`.
2. Focus and leave the title empty. Confirm `Title is required` appears after the control becomes touched.
3. Enter `-1` for price or stock. Confirm the Save button remains disabled.
4. Enter valid values in every required field. Confirm Save becomes enabled.
5. Click Save and confirm Console displays the form value.
6. Type several title values and confirm Console logs `Title changed:`.

The template-driven example requires `FormsModule` and a separate template. Do not expect it to work merely by pasting its HTML into this reactive component. Build it as a separate small component when practising section 33.

Stop and explain: the reactive form model and validators are declared in TypeScript, while a template-driven form is mainly configured in HTML.

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

Angular 22's concise naming convention normally generates:

```text
src/app/core/services/auth.ts
src/app/core/services/auth.spec.ts
```

The files have different purposes:

```text
auth.ts       -> AuthService implementation used by the application
auth.spec.ts  -> unit tests for AuthService
```

## Step 1 — Update `auth.ts`

Replace the entire contents of `src/app/core/services/auth.ts` with:

```typescript
import { Injectable, inject } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { BehaviorSubject, Observable, tap } from "rxjs";

export interface LoginResponse {
  id: number;
  username: string;
  firstName: string;
  lastName: string;
  accessToken: string;
  refreshToken: string;
}

@Injectable({
  providedIn: "root",
})
export class AuthService {
  private http = inject(HttpClient);

  private userSubject = new BehaviorSubject<LoginResponse | null>(null);

  user$ = this.userSubject.asObservable();

  login(username: string, password: string): Observable<LoginResponse> {
    return this.http
      .post<LoginResponse>("https://dummyjson.com/auth/login", {
        username,
        password,
        expiresInMins: 30,
      })
      .pipe(
        tap((user) => {
          localStorage.setItem("accessToken", user.accessToken);
          this.userSubject.next(user);
        }),
      );
  }

  logout(): void {
    localStorage.removeItem("accessToken");
    this.userSubject.next(null);
  }

  isLoggedIn(): boolean {
    return !!localStorage.getItem("accessToken");
  }

  getToken(): string | null {
    return localStorage.getItem("accessToken");
  }
}
```

## Step 2 — Update `auth.spec.ts`

The generated test may still import a class named `Auth`. Because the implementation above exports `AuthService`, replace the entire contents of `src/app/core/services/auth.spec.ts` with:

```typescript
import { TestBed } from "@angular/core/testing";
import { provideHttpClient } from "@angular/common/http";
import { provideHttpClientTesting } from "@angular/common/http/testing";
import { AuthService } from "./auth";

describe("AuthService", () => {
  let service: AuthService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });

    service = TestBed.inject(AuthService);
  });

  it("should be created", () => {
    expect(service).toBeTruthy();
  });
});
```

The application logic belongs only in `auth.ts`. The spec file should contain tests, not a second copy of the service.

DummyJSON documents the login endpoint and provides a test credential such as `emilys` / `emilyspass`; it returns access and refresh tokens. Use those only for this demo API, not for a real application.

## Pause and Verify — Subject, BehaviorSubject and Auth Service

Files used:

```text
src/app/core/services/auth.ts
src/app/core/services/auth.spec.ts
```

At this stage, the login page is not connected yet. Test the service through its spec file.

1. Confirm `auth.ts` contains:

```typescript
private userSubject = new BehaviorSubject<LoginResponse | null>(null);
user$ = this.userSubject.asObservable();
```

2. Keep the existing `should be created` test in `auth.spec.ts` and add this second test inside `describe("AuthService", ...)`:

```typescript
it("should expose null as the initial user", (done) => {
  service.user$.subscribe((user) => {
    expect(user).toBeNull();
    done();
  });
});
```

3. From the Angular project folder, run:

```bash
ng test
```

4. Confirm both AuthService tests pass.
5. In `auth.spec.ts`, try typing `service.user$.next(null)`. TypeScript should report that `next` does not exist on `Observable<LoginResponse | null>`. Delete that invalid line afterward.
6. Run `ng serve` once more and confirm the application compiles without a missing `HttpClient` provider error.

Expected result: `AuthService` can change the private subject internally, while components can only subscribe to the public `user$`. Stop and explain how `asObservable()` protects shared authentication state.

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
import { HttpInterceptorFn } from "@angular/common/http";
import { inject } from "@angular/core";
import { AuthService } from "../services/auth";

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getToken();

  if (!token) {
    return next(req);
  }

  const clonedRequest = req.clone({
    setHeaders: {
      Authorization: `Bearer ${token}`,
    },
  });

  return next(clonedRequest);
};
```

Important:

HTTP requests are immutable, so you clone the request when you need to modify it.

---

# 40. Register the Interceptor

Open `src/app/app.config.ts` again. Update the imports in that file:

```typescript
import { provideHttpClient, withInterceptors } from "@angular/common/http";

import { authInterceptor } from "./core/interceptors/auth.interceptor";
```

Replace the existing `provideHttpClient()` entry in the `providers` array with:

```typescript
provideHttpClient(withInterceptors([authInterceptor]));
```

Do not keep both versions. There should be only one `provideHttpClient(...)` entry in `app.config.ts`. Now requests pass through the interceptor.

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
import { inject } from "@angular/core";
import { CanActivateFn, Router } from "@angular/router";
import { AuthService } from "../services/auth";

export const authGuard: CanActivateFn = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isLoggedIn()) {
    return true;
  }

  return router.createUrlTree(["/login"]);
};
```

---

# 43. Routing

Your route configuration can look conceptually like:

```typescript
export const routes: Routes = [
  {
    path: "",
    redirectTo: "dashboard",
    pathMatch: "full",
  },

  {
    path: "login",
    loadComponent: () =>
      import("./features/login/login").then((m) => m.LoginComponent),
  },

  {
    path: "dashboard",
    canActivate: [authGuard],
    loadComponent: () =>
      import("./features/dashboard/dashboard").then(
        (m) => m.DashboardComponent,
      ),
  },

  {
    path: "products",
    canActivate: [authGuard],
    loadComponent: () =>
      import("./features/products/product-list/product-list").then(
        (m) => m.ProductList,
      ),
  },
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
      .then(m => m.ProductList)
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
  username: ["emilys", Validators.required],
  password: ["emilyspass", Validators.required],
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

## Pause and Verify — Login, Guard, Routing and Lazy Loading

Files to check before running:

```text
src/app/core/services/auth.ts
src/app/core/interceptors/auth.interceptor.ts
src/app/core/guards/auth.guard.ts
src/app/features/login/login.ts
src/app/features/login/login.html
src/app/app.config.ts
src/app/app.routes.ts
```

### Required wiring

1. In `app.config.ts`, confirm there is exactly one HTTP provider:

```typescript
provideHttpClient(withInterceptors([authInterceptor]));
```

2. In `app.routes.ts`, confirm `/login` is unguarded and `/dashboard` is guarded with `canActivate: [authGuard]`.
3. Open `login.ts`, use its exact exported class name in the lazy route, and confirm it injects `FormBuilder`, `AuthService`, and `Router`.
4. Confirm `login.html` contains a form connected with `[formGroup]="loginForm"` and `(ngSubmit)="login()"`.

### Run and verify

1. Run `ng serve`.
2. Open DevTools with `F12`, select Application, expand Local Storage, right-click the application origin, and choose Clear. This removes an old token.
3. Enter `http://localhost:4200/dashboard` directly.
4. Expected result: `authGuard` redirects the browser to `/login`.
5. Submit `emilys` / `emilyspass` on the login form.
6. In Network, select the `login` request. Confirm Method is `POST` and the response contains `accessToken`.
7. In Application > Local Storage, confirm the key `accessToken` now exists.
8. Confirm the browser navigates to `/dashboard`.
9. Refresh `/dashboard`. Expected result: the guard allows navigation because `isLoggedIn()` finds the stored token.

If a route fails to load, open Console and compare the lazy import path and `.then(...)` class name with the actual generated filename and `export class` declaration.

Stop and explain this order:

```text
protected navigation -> guard -> login -> API token
-> localStorage -> guard allows protected navigation
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
searchControl = new FormControl("");
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
debounceTime(400);
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
distinctUntilChanged();
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
this.searchControl.valueChanges
  .pipe(
    debounceTime(400),

    distinctUntilChanged(),

    tap((term) => {
      console.log("Searching:", term);
    }),

    switchMap((term) => this.productService.searchProducts(term ?? "")),

    catchError((error) => {
      console.error("Search failed:", error);
      return of([]);
    }),
  )
  .subscribe((products) => {
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

## Pause and Verify — Search Pipeline

Files to edit:

```text
src/app/features/products/product-list/product-list.ts
src/app/features/products/product-list/product-list.html
```

### Connect the search box

1. In `product-list.ts`, import `FormControl` and `ReactiveFormsModule` from `@angular/forms`.
2. Add `ReactiveFormsModule` to the component's `imports` array.
3. Add this property inside the class:

```typescript
searchControl = new FormControl("");
```

4. Place the complete search pipeline from section 50 inside `ngOnInit()` after the initial product-loading subscription.
5. Add the input near the top of `product-list.html`:

```html
<label for="product-search">Search products</label>
<input
  id="product-search"
  type="search"
  [formControl]="searchControl"
  placeholder="Try phone or laptop"
/>
```

### Run and verify

1. Run `ng serve`, open `/products`, press `F12`, and select Network.
2. Type `phone` quickly without pausing between letters.
3. Wait at least 400 ms. Expected result: one request to `/products/search?q=phone` appears after the pause.
4. Type `laptop`, pause, and confirm a new request appears and the list changes.

### Verify `distinctUntilChanged` exactly

Temporarily add these lines immediately after the search subscription in `ngOnInit()`:

```typescript
this.searchControl.setValue("phone");
this.searchControl.setValue("phone");
```

Refresh once and inspect Network. Expected result: only one consecutive `phone` search request is made after the debounce period. Remove both temporary `setValue` lines afterward.

To make cancellation easier to observe, temporarily add `?delay=2000` inside `searchProducts()` and type two different terms more than 400 ms apart but less than two seconds apart. The first request should appear cancelled in DevTools and only the latest result should update the list. Restore the normal search URL afterward.

Stop and explain the sequence: `debounceTime` waits, `distinctUntilChanged` removes consecutive duplicates, `tap` observes, `switchMap` keeps the latest search, and `catchError` supplies a fallback.

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
import { from } from "rxjs";
import { mergeMap } from "rxjs/operators";
```

Conceptual example:

```typescript
from([1, 2, 3])
  .pipe(mergeMap((id) => this.productService.getProduct(id)))
  .subscribe((product) => {
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
from([1, 2, 3])
  .pipe(concatMap((id) => this.productService.getProduct(id)))
  .subscribe((product) => {
    console.log(product);
  });
```

Observe the Network tab and compare it with `mergeMap`.

---

# 55. Compare the Three Mapping Operators

Remember this table:

| Operator    | Main idea        | Typical use           |
| ----------- | ---------------- | --------------------- |
| `switchMap` | Latest wins      | Search                |
| `mergeMap`  | Run concurrently | Independent requests  |
| `concatMap` | Queue in order   | Sequential operations |

The interview question is not only:

> "What is switchMap?"

It is:

> "Why did you choose switchMap instead of mergeMap?"

Your answer should be based on the business requirement.

## Pause and Verify — Mapping Operator Choice

Temporary practice file:

```text
src/app/features/products/product-list/product-list.ts
```

Do not run `mergeMap` and `concatMap` at the same time. Test one, remove it, and then test the other.

### Test `mergeMap`

1. Add `from` and `mergeMap` to the RxJS import in `product-list.ts`:

   ```typescript
   import { from, mergeMap } from "rxjs";
   ```

2. At the end of `ngOnInit()`, temporarily add:

   ```typescript
   from([1, 2, 3])
     .pipe(mergeMap((id) => this.productService.getProduct(id)))
     .subscribe((product) => {
       console.log("mergeMap product:", product.id);
     });
   ```

3. Run `ng serve`, open `/products`, and use Network's filter box to search for `products/`.
4. Refresh once. Expected result: requests for products 1, 2 and 3 are allowed to run concurrently. Their completion order is not guaranteed.
5. Remove the temporary block and remove the unused `mergeMap` import.

### Test `concatMap`

1. Import `from` and `concatMap`:

   ```typescript
   import { concatMap, from } from "rxjs";
   ```

2. Add this temporary block at the end of `ngOnInit()`:

   ```typescript
   from([1, 2, 3])
     .pipe(concatMap((id) => this.productService.getProduct(id)))
     .subscribe((product) => {
       console.log("concatMap product:", product.id);
     });
   ```

3. Refresh and inspect Network. Expected result: request 2 starts after request 1 completes, and request 3 starts after request 2 completes.
4. Delete the temporary block and remove the unused imports.

Revisit the search input for `switchMap`: start one delayed search, then start another. Only the latest result should update the list.

Stop and answer aloud:

```text
switchMap -> latest operation matters
mergeMap  -> all independent operations may run concurrently
concatMap -> all operations must run in order
```

---

# 56. `shareReplay`

Suppose multiple components call:

```typescript
getProducts();
```

You could accidentally create multiple HTTP requests.

`shareReplay(1)` can share and replay the latest emitted value to later subscribers.

Example:

```typescript
products$ = this.http.get<ProductResponse>(this.apiUrl).pipe(
  map((response) => response.products),
  shareReplay({ bufferSize: 1, refCount: true }),
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

## Pause and Verify — Shared Product Stream

Files to edit:

```text
src/app/core/services/product.service.ts
src/app/features/products/product-list/product-list.ts
```

1. In `product.service.ts`, confirm `shareReplay` is imported from `rxjs` and `getProducts()` uses the private `products$` field shown in section 57.
2. In `product-list.ts`, keep the existing first subscription that assigns products to the page.
3. Immediately after it, temporarily add a second subscription:

   ```typescript
   this.productService.getProducts().subscribe((products) => {
     console.log("Second subscriber received:", products.length);
   });
   ```

4. Run `ng serve`, open DevTools Network, clear the request list, and refresh `/products` once.
5. Expected result: Console confirms both subscribers received data, but Network contains only one `GET /products` request.
6. Press `F5` for a full browser reload. Expected result: one new request appears because reloading creates a new Angular application and service instance.
7. Remove the temporary second subscription from `product-list.ts`.

Do not remove the `shareReplay` implementation. Stop and explain that it shares/replays data within the current service instance; it is not permanent browser or server storage.

---

# 58. Signals

Signals are Angular's reactive state primitive.

A signal stores a value:

```typescript
count = signal(0);
```

Read it:

```typescript
count();
```

Update it:

```typescript
count.set(10);
```

Increment:

```typescript
count.update((value) => value + 1);
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

total = computed(() => this.price() * this.quantity());
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
  console.log("Count:", this.count());
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
changeDetection: ChangeDetectionStrategy.OnPush;
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
provideZoneChangeDetection();
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
<button (click)="increment()">Count: {{ count() }}</button>
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

## Pause and Verify — Signals, OnPush and Zoneless

Use the generated product-card component for this experiment:

```text
src/app/features/products/product-card/product-card.ts
src/app/features/products/product-card/product-card.html
src/app/features/products/product-list/product-list.ts
src/app/features/products/product-list/product-list.html
src/app/app.config.ts
```

If the component does not exist, generate it:

```bash
ng g c features/products/product-card
```

### Add a small signal experiment

1. In `product-card.ts`, import `ChangeDetectionStrategy`, `Component`, `computed`, `effect`, and `signal` from `@angular/core`.
2. Add `changeDetection: ChangeDetectionStrategy.OnPush` to `@Component`.
3. Add these members inside the class:

   ```typescript
   price = signal(100);
   quantity = signal(2);
   total = computed(() => this.price() * this.quantity());

   constructor() {
     effect(() => {
       console.log("Signal total:", this.total());
     });
   }

   increaseQuantity(): void {
     this.quantity.update((value) => value + 1);
   }
   ```

4. In `product-card.html`, add:

   ```html
   <p>Price: {{ price() }}</p>
   <p>Quantity: {{ quantity() }}</p>
   <p>Total: {{ total() }}</p>
   <button type="button" (click)="increaseQuantity()">Increase quantity</button>
   ```

5. Import `ProductCard` into the `imports` array of `product-list.ts`, using the exact generated class name.
6. Add `<app-product-card />` near the top of `product-list.html`.

### Run and verify

1. Run `ng serve` and open `/products`.
2. Click Increase quantity. Expected result: quantity and total update immediately.
3. Open Console and confirm `Signal total:` logs the recalculated total.
4. Open `app.config.ts` and confirm you did not add `provideZoneChangeDetection()` for this experiment.

The button test demonstrates signals, `computed`, `effect`, OnPush, and Angular-aware change notification. Passing real product input data into the card is a separate extension; do it only after defining an input and rendering one card per product.

Stop and explain: `signal` owns state, `computed` derives state, `effect` performs a side effect, and OnPush remains compatible with signal updates.

---

# 66. API Error Handling

You should practice three levels.

## Level 1 — Local component handling

```typescript
this.productService.getProducts().subscribe({
  next: (products) => {
    this.products = products;
  },
  error: (error) => {
    console.error(error);
    this.errorMessage = "Unable to load products";
  },
});
```

## Level 2 — Service/RxJS handling

```typescript
catchError((error) => {
  console.error(error);
  return of([]);
});
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

## Pause and Verify — HTTP Error Handling

Files used:

```text
src/app/core/services/product.service.ts
src/app/features/products/product-list/product-list.ts
```

### Test a service fallback

1. In `product.service.ts`, temporarily change only the `getProducts()` URL to:

```typescript
"https://dummyjson.com/products-does-not-exist";
```

2. Keep the existing `catchError` that logs the error and returns `of([])`.
3. Run `ng serve`, open `/products`, and inspect Console and Network.
4. Expected result: Network shows a failed request, Console logs the technical error, and the page safely receives an empty product list.
5. Restore the URL to `this.apiUrl` immediately.

### Test a network failure

1. Open DevTools > Network.
2. Change the throttling dropdown from `No throttling` to `Offline`.
3. Refresh `/products`.
4. Expected result: the request fails with status `0` or a network error, and the fallback still prevents an application crash.
5. Change the dropdown back to `No throttling` and refresh again.

### Test authentication failure later

After `getCurrentUser()` is implemented, place an invalid token in Application > Local Storage:

```text
accessToken = invalid-token
```

Call `/auth/me` and inspect the returned status. Restore a valid token by logging in again.

DummyJSON does not reliably provide controlled `403` and `500` responses. At this stage, read and explain those handling branches; test them later with `HttpTestingController` rather than changing unrelated production code.

Stop and explain: a component chooses the user-facing message, a service can provide operation-specific fallback behavior, and an interceptor handles application-wide HTTP concerns.

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
route.snapshot.paramMap.get("id");
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
  title: this.productForm.value.title ?? "",
  price: this.productForm.value.price ?? 0,
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

## Pause and Verify — Product Details and CRUD

Files to edit:

```text
src/app/core/services/product.service.ts
src/app/features/products/product-details/product-details.ts
src/app/features/products/product-details/product-details.html
src/app/app.routes.ts
```

### Product details

1. Confirm `product.service.ts` contains `getProduct`, `addProduct`, `updateProduct`, and `deleteProduct` from sections 68–72.
2. Open `product-details.ts` and use its exact exported class name in the route.
3. Add this route to `app.routes.ts` after any more-specific product routes such as `products/form`:

   ```typescript
   {
     path: "products/:id",
     loadComponent: () =>
       import("./features/products/product-details/product-details").then(
         (component) => component.ProductDetails,
       ),
   },
   ```

4. Place the `ActivatedRoute` and `getProduct(id)` code from section 68 in `product-details.ts`.
5. Add a minimal template to `product-details.html`:

   ```html
   @if (product) {
   <h2>{{ product.title }}</h2>
   <p>{{ product.description }}</p>
   <strong>${{ product.price }}</strong>
   } @else {
   <p>Loading product...</p>
   }
   ```

6. Run `ng serve`, open `/products/1`, and confirm Network shows `GET /products/1` and the page shows product 1.
7. Open `/products/2` and confirm product 2 appears.

Before calling the API, validate the route value:

```typescript
const id = Number(this.route.snapshot.paramMap.get("id"));

if (!Number.isInteger(id) || id <= 0) {
  console.error("Invalid product id");
  return;
}
```

### CRUD methods without a completed form UI

Until buttons and forms are wired, temporarily call one method at a time from `ngOnInit()` in `product-details.ts`. For example:

```typescript
this.productService
  .updateProduct(1, { title: "Temporary interview title" })
  .subscribe((updatedProduct) => {
    console.log("Temporary update result:", updatedProduct);
  });
```

Inspect Network for `PATCH /products/1`, then delete this temporary call. Repeat separately for `addProduct(...)` and `deleteProduct(1)` if you want to inspect POST and DELETE.

Expected result: DummyJSON returns simulated success responses, but a fresh GET does not contain permanent changes. Remove every temporary CRUD call before continuing.

---

# 73. Practice `map()` with Real Data

Create:

```typescript
products$ = this.productService.getProducts().pipe(
  map((products) =>
    products.map((product) => ({
      ...product,
      displayPrice: `$${product.price}`,
    })),
  ),
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
products$ = this.productService
  .getProducts()
  .pipe(map((products) => products.filter((product) => product.stock > 0)));
```

Now only products with stock remain.

---

# 75. Practice `tap()` for Debugging

```typescript
products$ = this.productService.getProducts().pipe(
  tap((products) => console.log("Products before filtering:", products)),
  map((products) => products.filter((product) => product.stock > 0)),
  tap((products) => console.log("Products after filtering:", products)),
);
```

This gives you a practical debugging example.

---

# 76. Practice `catchError()` Correctly

Example:

```typescript
products$ = this.productService.getProducts().pipe(
  catchError((error) => {
    console.error("API failed:", error);

    this.errorMessage.set("Products could not be loaded.");

    return of([]);
  }),
);
```

Remember:

`catchError()` changes the error path into another Observable.

---

# 77. Better Loading Management

Use `finalize()`.

```typescript
this.loading.set(true);

this.productService
  .getProducts()
  .pipe(finalize(() => this.loading.set(false)))
  .subscribe({
    next: (products) => {
      this.products = products;
    },
    error: (error) => {
      console.error(error);
    },
  });
```

The `finalize()` callback runs when the Observable terminates through completion or error.

This is often cleaner than setting loading to false in multiple branches.

## Pause and Verify — Real Data Operators and `finalize`

Files to edit:

```text
src/app/features/products/product-list/product-list.ts
src/app/features/products/product-list/product-list.html
```

Keep these experiments in the component so the service continues to return the original `Product[]` model.

1. In `product-list.ts`, create the stream shown in sections 73–76:

   ```typescript
   products$ = this.productService.getProducts().pipe(
     tap((products) => console.log("Before filtering:", products)),
     map((products) =>
       products
         .filter((product) => product.stock > 0)
         .map((product) => ({
           ...product,
           displayPrice: `$${product.price.toFixed(2)}`,
         })),
     ),
     tap((products) => console.log("After filtering:", products)),
     catchError((error) => {
       console.error("Display stream failed:", error);
       return of([]);
     }),
   );
   ```

2. To display this separate practice stream, import `AsyncPipe` from `@angular/common`, add it to component `imports`, and temporarily add this to `product-list.html`:

   ```html
   @if (products$ | async; as displayProducts) { @for (product of
   displayProducts; track product.id) {
   <p>{{ product.title }} - {{ product.displayPrice }}</p>
   } }
   ```

3. Run `ng serve` and open `/products`.
4. Confirm prices use two decimal places and compare the before/after Console arrays.

To verify loading cleanup, keep `finalize` on the subscription that controls `loading`:

```typescript
this.loading = true;

this.productService
  .getProducts()
  .pipe(finalize(() => (this.loading = false)))
  .subscribe((products) => {
    this.products = products;
  });
```

Test once with the valid service URL and once with a temporary invalid URL. Expected result: `loading` becomes false in both cases. Restore the valid URL, and remove the duplicate practice template/stream if you no longer need it.

Stop and explain: RxJS `map` transforms one emitted array; JavaScript `filter` and `Array.map` transform items inside that array; `finalize` runs when the stream completes or errors.

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
  users: this.userService.getUsers(),
}).subscribe((result) => {
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
  providedIn: "root",
})
export class UserService {
  private http = inject(HttpClient);

  getUsers(): Observable<UserResponse> {
    return this.http.get<UserResponse>("https://dummyjson.com/users");
  }

  getUser(id: number): Observable<User> {
    return this.http.get<User>(`https://dummyjson.com/users/${id}`);
  }

  searchUsers(term: string): Observable<UserResponse> {
    return this.http.get<UserResponse>(
      `https://dummyjson.com/users/search?q=${encodeURIComponent(term)}`,
    );
  }
}
```

## Pause and Verify — Dashboard, `forkJoin` and User Service

Files to edit:

```text
src/app/core/services/user.ts
src/app/features/dashboard/dashboard.ts
src/app/features/dashboard/dashboard.html
src/app/app.routes.ts
```

1. Put the `UserService` code from section 80 in `user.ts`. Ensure the required `User` and `UserResponse` interfaces exist and are imported.
2. In `dashboard.ts`, inject `ProductService` and `UserService`.
3. Add fields for the counts:

   ```typescript
   productCount = 0;
   userCount = 0;
   ```

4. Add this to `ngOnInit()`:

   ```typescript
   forkJoin({
     products: this.productService.getProducts(),
     users: this.userService.getUsers(),
   }).subscribe({
     next: (result) => {
       this.productCount = result.products.length;
       this.userCount = result.users.users.length;
     },
     error: (error) => {
       console.error("Dashboard load failed", error);
     },
   });
   ```

5. Add to `dashboard.html`:

   ```html
   <h2>Dashboard</h2>
   <p>Products: {{ productCount }}</p>
   <p>Users: {{ userCount }}</p>
   ```

6. Confirm `app.routes.ts` has a dashboard route using the exact exported dashboard class name.
7. Run `ng serve`, open `/dashboard`, and inspect Network.
8. Expected result: `/products` and `/users` can run in parallel; counts update after both complete.

To test failure behavior, temporarily change only the UserService URL to `https://dummyjson.com/users-invalid`. Refresh and confirm `Dashboard load failed` appears. Restore the valid users URL immediately.

To test `getUser(1)` and `searchUsers("John")`, add these temporary subscriptions at the end of dashboard `ngOnInit()`:

```typescript
this.userService.getUser(1).subscribe((user) => {
  console.log("Temporary user 1:", user);
});

this.userService.searchUsers("John").subscribe((response) => {
  console.log("Temporary user search:", response.users);
});
```

Refresh Dashboard. In Network, confirm the URLs end with `/users/1` and `/users/search?q=John`, and inspect both Console results. Remove both temporary subscriptions afterward.

Stop and explain why `forkJoin` is appropriate for HTTP calls that emit once and complete.

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
this.authService.user$.subscribe((user) => {
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

## Pause and Verify — Current User and Shared Auth State

Files to edit:

```text
src/app/core/services/auth.ts
src/app/features/dashboard/dashboard.ts
src/app/features/dashboard/dashboard.html
```

The navigation bar is added later, so use Dashboard as the first visible consumer of `user$`.

1. Add `getCurrentUser()` from section 82 inside `AuthService` in `auth.ts`.
2. Add a public method so the service, not a component, updates its private subject:

   ```typescript
   loadCurrentUser(): Observable<LoginResponse> {
     return this.getCurrentUser().pipe(
       tap((user) => this.userSubject.next(user)),
     );
   }
   ```

3. In `dashboard.ts`, expose the stream and load the user:

   ```typescript
   authService = inject(AuthService);
   user$ = this.authService.user$;

   ngOnInit(): void {
     this.authService.loadCurrentUser().subscribe({
       error: (error) => console.error("Current user failed", error),
     });

     // Keep the existing dashboard loading code here too.
   }
   ```

4. Import `AsyncPipe` from `@angular/common` and add it to the Dashboard component's `imports` array.
5. Add to `dashboard.html`:

   ```html
   @if (user$ | async; as user) {
   <p>Welcome {{ user.firstName }}</p>
   }

   <button type="button" (click)="authService.logout()">Logout</button>
   ```

6. Run `ng serve`, log in, and open `/dashboard`.
7. In Network, select `/auth/me` and inspect Request Headers. Confirm `Authorization: Bearer ...` exists.
8. Confirm Dashboard displays the user's first name.
9. Click Logout. Confirm the welcome text disappears and Application > Local Storage no longer contains `accessToken`.
10. Open `/dashboard` again. The guard should redirect to `/login`.

Important: after a full page refresh, the `BehaviorSubject` starts at `null`; the token survives because it is in Local Storage. `loadCurrentUser()` rebuilds in-memory user state from `/auth/me`.

---

# 85. Error Interceptor

You can create a second interceptor:

```bash
ng g interceptor core/interceptors/error
```

Example:

```typescript
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  return next(req).pipe(
    catchError((error) => {
      if (error.status === 401) {
        console.error("Unauthorized");
      }

      if (error.status === 403) {
        console.error("Forbidden");
      }

      if (error.status === 404) {
        console.error("Not found");
      }

      if (error.status >= 500) {
        console.error("Server error");
      }

      return throwError(() => error);
    }),
  );
};
```

Register it:

```typescript
provideHttpClient(withInterceptors([authInterceptor, errorInterceptor]));
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

## Pause and Verify — Error Interceptor

Files to edit:

```text
src/app/core/interceptors/error.interceptor.ts
src/app/app.config.ts
src/app/core/services/product.service.ts
src/app/features/products/product-list/product-list.ts
```

1. Put the error interceptor code from section 85 in `error.interceptor.ts` and import `catchError` and `throwError` from `rxjs`.
2. In `app.config.ts`, replace the existing HTTP provider with exactly one combined provider:

   ```typescript
   provideHttpClient(withInterceptors([authInterceptor, errorInterceptor]));
   ```

3. To trigger a controlled `404`, temporarily add this service method to `ProductService`:

   ```typescript
   testMissingEndpoint(): Observable<unknown> {
     return this.http.get("https://dummyjson.com/endpoint-does-not-exist");
   }
   ```

4. Temporarily call it at the end of `ProductList.ngOnInit()`:

   ```typescript
   this.productService.testMissingEndpoint().subscribe({
     error: (error) => {
       console.error("Component received rethrown error", error);
     },
   });
   ```

5. Run `ng serve`, open `/products`, and inspect Console.
6. Expected result: the interceptor logs `Not found`, followed by `Component received rethrown error`. This proves `throwError` passed the error onward.
7. Remove `testMissingEndpoint()` and its temporary subscription.
8. Refresh `/products` with the normal API. Confirm products still load without error-interceptor messages.

Stop and explain why the auth interceptor is registered first to add the token, while the error interceptor observes failed responses and rethrows them to local handlers.

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

## Pause and Verify — Complete Application

Files to check:

```text
src/app/app.ts
src/app/app.routes.ts
src/app/app.config.ts
src/app/core/services/
src/app/core/guards/
src/app/core/interceptors/
src/app/features/
```

### Before running

1. In `app.ts`, confirm the root template contains `<router-outlet />`. If navigation is in `app.html`, confirm `app.ts` uses that template and imports `RouterOutlet` and `RouterLink` as required.
2. In `app.routes.ts`, confirm routes exist for Login, Dashboard, Products, Product Details, Product Form and Users. Use each file's exact exported class name.
3. Confirm protected routes contain `canActivate: [authGuard]`, while Login does not.
4. In `app.config.ts`, confirm there is only one `provideHttpClient(...)` call and it registers both interceptors.
5. Search the project for `Temporary`, `invalid-products`, `users-invalid`, `setValue("phone")`, and `testMissingEndpoint`. Remove all temporary experiment code.

### End-to-end browser test

1. Run `ng serve`.
2. Clear Local Storage and open `/dashboard`. Expected: redirect to `/login`.
3. Log in with `emilys` / `emilyspass`. Expected: token is stored and Dashboard opens.
4. Navigate to Products. Expected: one products request loads the list.
5. Search for `phone`. Expected: one debounced search request updates the list.
6. Open `/products/1`. Expected: product details load.
7. Open the product form. Expected: validation blocks invalid values and accepts valid values.
8. Exercise one simulated add, update, or delete call and inspect its Network request.
9. Refresh a protected page. Expected: the stored token allows the guard, and `/auth/me` can rebuild user state.
10. Click Logout and try `/dashboard`. Expected: redirect to Login.
11. Inspect Console for uncaught errors and Network for unexpected failed or duplicate requests.

### Tests

1. Stop `ng serve` with `Ctrl+C`.
2. Run the test script defined in `package.json`, normally:

```bash
ng test
```

3. Confirm the AuthService test and generated component/service tests pass.

If something fails, write down the exact route, action, Console message, Network status, and relevant file before continuing. Finally, explain one complete flow from user action to component, service, RxJS pipeline, interceptor, API response, state update and rendered UI.

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
|       +-- auth.ts
|       +-- product.service.ts
|       +-- user.ts
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
