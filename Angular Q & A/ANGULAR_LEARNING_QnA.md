# Angular Learning - Questions & Answers

This document is for learning Angular concepts through questions and detailed explanations. Ask questions one by one, and I'll add comprehensive explanations here.

---

## 📚 Table of Contents

- [Routing](#routing) ⬅️ **Current Topic**
- [Components](#components) - Coming soon
- [Services](#services) - Coming soon
- [Dependency Injection](#dependency-injection) - Coming soon
- [Data Binding](#data-binding) - Coming soon
- [Directives](#directives) - Coming soon
- [HTTP Client](#http-client) - Coming soon
- [Observables & RxJS](#observables--rxjs) - Coming soon
- [Forms](#forms) - Coming soon
- [Lifecycle Hooks](#lifecycle-hooks) - Coming soon

---

## 🗺️ Routing

### **Q1: What is Routing in Angular?**

**Answer:**

Routing in Angular is a mechanism that allows navigation between different views/components in a Single Page Application (SPA) **without refreshing the entire page**.

#### **Simple Explanation:**

Think of routing like a **GPS navigation system**:
- You tell it where to go (click a link or navigate programmatically)
- It changes the URL in the browser
- It loads the corresponding component
- **No page refresh!** - Only the content changes

#### **Real-World Analogy:**

Imagine a **restaurant with multiple rooms**:
- Each room (route) has different content
- You can move between rooms (navigate) without leaving the restaurant (page refresh)
- The address (URL) tells you which room you're in

#### **Why Use Routing?**

- ✅ **Better User Experience**: No page reloads = faster navigation
- ✅ **Maintains State**: JavaScript state persists between navigations
- ✅ **SEO Friendly**: Each route has its own URL
- ✅ **Bookmarkable**: Users can bookmark specific pages
- ✅ **Browser History**: Back/forward buttons work correctly

---

### **Q2: How Does Routing Work in Angular?**

**Answer:**

Angular routing works through the **Router Module** and follows these steps:

#### **Step-by-Step Process:**

1. **Define Routes** - Tell Angular which URLs map to which components
2. **Configure Router** - Set up routing in your app
3. **Add Router Outlet** - Place where components will be displayed
4. **Navigate** - Use router links or programmatic navigation

#### **Code Example:**

```typescript
// 1. Define Routes (app.routes.ts)
import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { FeeListComponent } from './components/fee-list/fee-list.component';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'fees', component: FeeListComponent },
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: '**', component: NotFoundComponent } // Wildcard - catch all
];
```

```typescript
// 2. Configure Router (app.config.ts)
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes)  // Enable routing
  ]
};
```

```html
<!-- 3. Add Router Outlet (app.component.html) -->
<router-outlet></router-outlet>
<!-- Components will appear here -->
```

```html
<!-- 4. Navigate (any component template) -->
<a routerLink="/login">Login</a>
<a routerLink="/fees">View Fees</a>
```

#### **What Happens When User Clicks a Link:**

```
User clicks "View Fees" link
    ↓
URL changes to: /fees
    ↓
Angular Router checks routes array
    ↓
Finds: { path: 'fees', component: FeeListComponent }
    ↓
Angular loads FeeListComponent
    ↓
Component appears in <router-outlet>
    ↓
No page refresh! ✅
```

---

### **Q3: What is Router Outlet?**

**Answer:**

`<router-outlet>` is a **directive** that acts as a **placeholder** where Angular displays the component for the current route.

#### **Simple Explanation:**

Think of `<router-outlet>` as a **picture frame**:
- The frame stays in the same place
- Different pictures (components) can be placed inside it
- When you navigate, the picture changes, but the frame stays

#### **Visual Example:**

```html
<!-- app.component.html -->
<header>
  <nav>
    <a routerLink="/login">Login</a>
    <a routerLink="/fees">Fees</a>
  </nav>
</header>

<!-- This is where routed components appear -->
<router-outlet></router-outlet>

<footer>
  <p>Footer content</p>
</footer>
```

**When user navigates:**
- `/login` → LoginComponent appears in `<router-outlet>`
- `/fees` → FeeListComponent appears in `<router-outlet>`
- Header and footer stay the same!

#### **Key Points:**

- ✅ Only **one** `<router-outlet>` per route level
- ✅ Can have **nested** router outlets for child routes
- ✅ Components are **dynamically loaded** here
- ✅ Old component is **destroyed** when new one loads

---

### **Q4: What is routerLink and How Does It Work?**

**Answer:**

`routerLink` is a **directive** that creates navigation links in Angular templates.

#### **Simple Explanation:**

`routerLink` is like a **smart link** that:
- Changes the URL without page refresh
- Tells Angular which component to load
- Updates the browser history

#### **Basic Usage:**

```html
<!-- Simple link -->
<a routerLink="/login">Login</a>
<a routerLink="/fees">View Fees</a>

<!-- With parameters -->
<a [routerLink]="['/fees', feeId]">View Fee Details</a>

<!-- With query parameters -->
<a [routerLink]="['/fees']" [queryParams]="{page: 1, sort: 'date'}">
  View Fees
</a>
```

#### **Comparison: routerLink vs href**

```html
<!-- ❌ Regular link - Causes page refresh -->
<a href="/login">Login</a>

<!-- ✅ Router link - No page refresh -->
<a routerLink="/login">Login</a>
```

#### **Programmatic Navigation (Alternative to routerLink):**

```typescript
// In component
import { Router } from '@angular/router';

constructor(private router: Router) {}

navigateToFees() {
  this.router.navigate(['/fees']);
}

navigateToFeeDetails(feeId: string) {
  this.router.navigate(['/fees', feeId]);
}

navigateWithQueryParams() {
  this.router.navigate(['/fees'], {
    queryParams: { page: 1, sort: 'date' }
  });
}
```

#### **When to Use Each:**

- **routerLink**: Use in templates (HTML)
- **router.navigate()**: Use in TypeScript code (programmatic navigation)

---

### **Q5: What are Route Parameters and Query Parameters?**

**Answer:**

Route parameters and query parameters are two ways to pass data through URLs.

#### **Route Parameters (Path Parameters)**

**What they are:**
- Part of the URL path
- Required for the route
- Example: `/fees/123` where `123` is the fee ID

**How to define:**
```typescript
// app.routes.ts
{ path: 'fees/:id', component: FeeDetailComponent }
//                    ↑ :id is a route parameter
```

**How to use:**
```typescript
// In component
import { ActivatedRoute } from '@angular/router';

constructor(private route: ActivatedRoute) {}

ngOnInit() {
  // Get parameter
  const feeId = this.route.snapshot.paramMap.get('id');
  
  // Or subscribe to changes
  this.route.paramMap.subscribe(params => {
    const feeId = params.get('id');
  });
}
```

**Example URLs:**
- `/fees/123` → `id = "123"`
- `/fees/456` → `id = "456"`

#### **Query Parameters**

**What they are:**
- Optional parameters after `?` in URL
- Used for filtering, sorting, pagination
- Example: `/fees?page=1&sort=date`

**How to use:**
```typescript
// In component
import { ActivatedRoute } from '@angular/router';

constructor(private route: ActivatedRoute) {}

ngOnInit() {
  // Get query parameter
  const page = this.route.snapshot.queryParamMap.get('page');
  const sort = this.route.snapshot.queryParamMap.get('sort');
  
  // Or subscribe
  this.route.queryParamMap.subscribe(params => {
    const page = params.get('page');
    const sort = params.get('sort');
  });
}
```

**Example URLs:**
- `/fees?page=1` → `page = "1"`
- `/fees?page=1&sort=date` → `page = "1"`, `sort = "date"`

#### **Comparison:**

| Feature | Route Parameters | Query Parameters |
|---------|-----------------|------------------|
| **Location** | In URL path | After `?` |
| **Required** | Yes (for that route) | Optional |
| **Example** | `/fees/123` | `/fees?page=1` |
| **Use Case** | Resource ID | Filters, sorting |

#### **Complete Example:**

```typescript
// Route definition
{ path: 'fees/:id', component: FeeDetailComponent }

// URL: /fees/123?edit=true
// Route param: id = "123"
// Query param: edit = "true"

// In component
ngOnInit() {
  const feeId = this.route.snapshot.paramMap.get('id'); // "123"
  const isEdit = this.route.snapshot.queryParamMap.get('edit'); // "true"
}
```

---

### **Q6: What is Route Guard and Why Do We Need It?**

**Answer:**

Route guards are **interfaces** that control whether a user can navigate to or away from a route.

#### **Simple Explanation:**

Think of route guards like **security guards**:
- They check if you have permission
- They can allow or deny access
- They can redirect you if needed

#### **Types of Route Guards:**

1. **CanActivate** - Can user access this route?
2. **CanDeactivate** - Can user leave this route?
3. **CanActivateChild** - Can user access child routes?
4. **CanLoad** - Can the module be loaded?
5. **Resolve** - Pre-fetch data before route loads

#### **Example: Auth Guard (CanActivate)**

```typescript
// auth.guard.ts
import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { AuthService } from './services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  canActivate(): boolean {
    if (this.authService.isLoggedIn()) {
      return true; // Allow access
    } else {
      this.router.navigate(['/login']); // Redirect to login
      return false; // Deny access
    }
  }
}
```

**How to use:**
```typescript
// app.routes.ts
import { AuthGuard } from './guards/auth.guard';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { 
    path: 'fees', 
    component: FeeListComponent,
    canActivate: [AuthGuard] // Protected route
  }
];
```

#### **Real-World Use Cases:**

1. **Authentication Guard**
   - Check if user is logged in
   - Redirect to login if not

2. **Role-Based Guard**
   - Check if user has required role
   - Allow/deny based on permissions

3. **Unsaved Changes Guard**
   - Check if form has unsaved changes
   - Warn user before leaving

#### **Example: Unsaved Changes Guard (CanDeactivate)**

```typescript
// unsaved-changes.guard.ts
import { CanDeactivate } from '@angular/router';

export interface CanComponentDeactivate {
  canDeactivate(): boolean;
}

@Injectable()
export class UnsavedChangesGuard implements CanDeactivate<CanComponentDeactivate> {
  canDeactivate(component: CanComponentDeactivate): boolean {
    if (component.canDeactivate()) {
      return true;
    } else {
      return confirm('You have unsaved changes. Are you sure you want to leave?');
    }
  }
}
```

---

### **Q7: What is Lazy Loading and Why Is It Important?**

**Answer:**

Lazy loading is a technique where Angular **loads modules/components only when they're needed**, rather than loading everything at startup.

#### **Simple Explanation:**

Think of lazy loading like **ordering food à la carte**:
- **Eager loading**: Order everything at once (slow, wasteful)
- **Lazy loading**: Order only what you need, when you need it (fast, efficient)

#### **Benefits:**

- ✅ **Faster Initial Load**: Only load what's needed first
- ✅ **Smaller Bundle Size**: Split code into chunks
- ✅ **Better Performance**: Load on demand
- ✅ **Better User Experience**: App starts faster

#### **How It Works:**

**Without Lazy Loading (Eager Loading):**
```typescript
// app.routes.ts
import { FeeListComponent } from './components/fee-list/fee-list.component';
import { FeeFormComponent } from './components/fee-form/fee-form.component';

export const routes: Routes = [
  { path: 'fees', component: FeeListComponent }, // Loaded immediately
  { path: 'fees/new', component: FeeFormComponent } // Loaded immediately
];
```
**Problem**: All components loaded even if user never visits them.

**With Lazy Loading:**
```typescript
// app.routes.ts
export const routes: Routes = [
  {
    path: 'fees',
    loadChildren: () => import('./features/fees/fees.module').then(m => m.FeesModule)
  }
];
```

**What happens:**
- Fees module is **not loaded** at startup
- When user navigates to `/fees`, Angular **dynamically imports** the module
- Module and its components are loaded **on demand**

#### **Complete Example:**

```typescript
// fees.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { FeeListComponent } from './fee-list/fee-list.component';
import { FeeFormComponent } from './fee-form/fee-form.component';

const routes: Routes = [
  { path: '', component: FeeListComponent },
  { path: 'new', component: FeeFormComponent }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  declarations: [FeeListComponent, FeeFormComponent]
})
export class FeesModule { }
```

```typescript
// app.routes.ts
export const routes: Routes = [
  { path: 'fees', loadChildren: () => import('./features/fees/fees.module').then(m => m.FeesModule) }
];
```

#### **How to Verify Lazy Loading:**

1. Open browser DevTools → Network tab
2. Navigate to a lazy-loaded route
3. You'll see a new chunk file loaded (e.g., `fees-module.js`)

---

### **Q8: What is Router State and How to Access It?**

**Answer:**

Router state contains information about the current route, including parameters, query parameters, and navigation data.

#### **Simple Explanation:**

Router state is like a **GPS system's memory**:
- It remembers where you are
- It knows how you got there
- It stores information about your journey

#### **How to Access Router State:**

```typescript
import { Router, ActivatedRoute } from '@angular/router';

export class MyComponent {
  constructor(
    private router: Router,
    private route: ActivatedRoute
  ) {}

  ngOnInit() {
    // Access current route
    console.log(this.router.url); // Current URL
    
    // Access route parameters
    const id = this.route.snapshot.paramMap.get('id');
    
    // Access query parameters
    const page = this.route.snapshot.queryParamMap.get('page');
    
    // Access route data
    const routeData = this.route.snapshot.data;
  }
}
```

#### **Router State Properties:**

```typescript
// Router properties
this.router.url              // Current URL
this.router.config           // All route configurations
this.router.events           // Navigation events

// ActivatedRoute properties
this.route.snapshot          // Current route snapshot
this.route.params            // Observable of route parameters
this.route.queryParams       // Observable of query parameters
this.route.data              // Static data associated with route
this.route.fragment          // URL fragment (#section)
```

#### **Example: Getting Route Data**

```typescript
// app.routes.ts
export const routes: Routes = [
  {
    path: 'fees',
    component: FeeListComponent,
    data: { title: 'Fee Management', requiresAuth: true }
  }
];
```

```typescript
// In component
ngOnInit() {
  const title = this.route.snapshot.data['title']; // "Fee Management"
  const requiresAuth = this.route.snapshot.data['requiresAuth']; // true
}
```

---

## 🎯 Interview Questions on Routing

### **Q1: Explain the difference between routerLink and router.navigate()**

**Answer:**

| Feature | routerLink | router.navigate() |
|---------|-----------|-------------------|
| **Usage** | Template (HTML) | TypeScript code |
| **When to use** | User clicks link | Programmatic navigation |
| **Example** | `<a routerLink="/fees">` | `this.router.navigate(['/fees'])` |
| **Conditional** | Limited | Full control |

**When to use each:**
- **routerLink**: Navigation from user interaction (clicks)
- **router.navigate()**: Navigation from code logic (after login, error handling)

---

### **Q2: What is the difference between ActivatedRoute and Router?**

**Answer:**

| Feature | ActivatedRoute | Router |
|---------|---------------|--------|
| **Purpose** | Read route information | Navigate and control routing |
| **What it does** | Gets params, query params, data | Navigates, checks routes |
| **Use case** | Read current route info | Change routes |

**Example:**
```typescript
// ActivatedRoute - Read information
const id = this.route.snapshot.paramMap.get('id');

// Router - Navigate
this.router.navigate(['/fees', id]);
```

---

### **Q3: How do you handle 404 (Not Found) routes?**

**Answer:**

Use a **wildcard route** (`**`) that catches all unmatched routes:

```typescript
export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'fees', component: FeeListComponent },
  { path: '**', component: NotFoundComponent } // Must be last!
];
```

**Important**: Wildcard route must be **last** in the array, as Angular matches routes in order.

---

### **Q4: What is the difference between pathMatch: 'full' and pathMatch: 'prefix'?**

**Answer:**

- **`pathMatch: 'full'`**: URL must match the entire path
- **`pathMatch: 'prefix'`**: URL must start with the path

**Example:**
```typescript
{ path: '', redirectTo: '/login', pathMatch: 'full' }
```

- `/` → Redirects to `/login` ✅
- `/something` → Does NOT redirect ❌

If `pathMatch: 'prefix'`:
- `/` → Redirects ✅
- `/something` → Also redirects (because it starts with `/`) ❌

**Best Practice**: Use `pathMatch: 'full'` for empty path redirects.

---

### **Q5: How do you pass data between routes?**

**Answer:**

Three ways:

1. **Route Parameters** (in URL path)
   ```typescript
   this.router.navigate(['/fees', feeId]);
   // URL: /fees/123
   ```

2. **Query Parameters** (after `?`)
   ```typescript
   this.router.navigate(['/fees'], { queryParams: { page: 1 } });
   // URL: /fees?page=1
   ```

3. **Route Data** (static data)
   ```typescript
   { path: 'fees', component: FeeListComponent, data: { title: 'Fees' } }
   ```

4. **State** (browser state - not in URL)
   ```typescript
   this.router.navigate(['/fees'], { state: { fee: feeData } });
   // Access: history.state.fee
   ```

---

### **Q6: What are Navigation Events and how do you use them?**

**Answer:**

Navigation events are emitted by the Router during navigation lifecycle.

**Types of Events:**
- `NavigationStart` - Navigation begins
- `RoutesRecognized` - Routes matched
- `NavigationEnd` - Navigation complete
- `NavigationCancel` - Navigation cancelled
- `NavigationError` - Navigation error

**Example:**
```typescript
import { Router, NavigationStart, NavigationEnd } from '@angular/router';

constructor(private router: Router) {
  this.router.events.subscribe(event => {
    if (event instanceof NavigationStart) {
      console.log('Navigation started');
      this.isLoading = true;
    }
    if (event instanceof NavigationEnd) {
      console.log('Navigation ended');
      this.isLoading = false;
    }
  });
}
```

---

### **Q7: How do you implement nested routes?**

**Answer:**

Use child routes with a nested `<router-outlet>`:

```typescript
// Parent route
{
  path: 'fees',
  component: FeeListComponent,
  children: [
    { path: '', component: FeeListComponent },
    { path: ':id', component: FeeDetailComponent },
    { path: 'new', component: FeeFormComponent }
  ]
}
```

```html
<!-- FeeListComponent template -->
<h1>Fee List</h1>
<router-outlet></router-outlet> <!-- Child routes appear here -->
```

**URLs:**
- `/fees` → FeeListComponent
- `/fees/123` → FeeListComponent + FeeDetailComponent
- `/fees/new` → FeeListComponent + FeeFormComponent

---

### **Q8: What is the difference between snapshot and subscribe for route parameters?**

**Answer:**

| Feature | snapshot | subscribe |
|---------|----------|-----------|
| **When to use** | One-time read | Watch for changes |
| **Performance** | Faster | Slightly slower |
| **Use case** | Component won't re-use | Component can be re-used |

**Example:**
```typescript
// Snapshot - One-time read
const id = this.route.snapshot.paramMap.get('id');
// If route param changes, this won't update!

// Subscribe - Watch for changes
this.route.paramMap.subscribe(params => {
  const id = params.get('id');
  // Updates when route param changes
});
```

**When to use each:**
- **snapshot**: Component is destroyed/recreated on navigation
- **subscribe**: Component is reused (e.g., navigating from `/fees/1` to `/fees/2`)

---

## 📝 Practice Exercises

### **Exercise 1: Create Routes**

Create routes for:
- `/` → Redirect to `/login`
- `/login` → LoginComponent
- `/fees` → FeeListComponent
- `/fees/:id` → FeeDetailComponent
- `/fees/new` → FeeFormComponent
- `/**` → NotFoundComponent

### **Exercise 2: Add Route Guard**

Create an AuthGuard that:
- Checks if user is logged in
- Redirects to `/login` if not
- Protects `/fees` route

### **Exercise 3: Implement Lazy Loading**

Convert the fees routes to lazy loading:
- Create FeesModule
- Use loadChildren in app routes
- Verify lazy loading in Network tab

---

## 🎓 Key Takeaways

1. ✅ Routing enables SPA navigation without page refresh
2. ✅ `<router-outlet>` is where components appear
3. ✅ `routerLink` for template navigation, `router.navigate()` for code
4. ✅ Route guards protect routes
5. ✅ Lazy loading improves performance
6. ✅ Route params for required data, query params for optional
7. ✅ Use snapshot for one-time reads, subscribe for watching changes

---

## 📚 Next Topics

- [ ] Components
- [ ] Services
- [ ] Dependency Injection
- [ ] Data Binding
- [ ] Directives
- [ ] HTTP Client
- [ ] Observables & RxJS
- [ ] Forms
- [ ] Lifecycle Hooks

---

**Ask your next question, and I'll add it here with a detailed explanation! 🚀**

