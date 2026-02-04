# Angular Learning - Questions & Answers

This document is for learning Angular concepts through questions and detailed explanations. Ask questions one by one, and I'll add comprehensive explanations here.

---

## 📚 Table of Contents

- [Routing](#routing)
- [Components](#components) ⬅️ **Current Topic**
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

---

## 🧩 Components

### **Q1: What is a Component in Angular?**

**Answer:**

A component is a **building block** of an Angular application that controls a **view** (a portion of the screen) and its **logic**.

#### **Simple Explanation:**

Think of a component like a **LEGO block**:
- Each block (component) has a specific purpose
- You can combine blocks to build something bigger
- Each block has its own shape (template) and behavior (logic)

#### **Real-World Analogy:**

Imagine a **restaurant menu card**:
- Each section (Appetizers, Main Course, Desserts) is like a component
- Each section has its own content (template)
- Each section has its own rules (logic) - e.g., "Vegetarian items only"

#### **Component Structure:**

Every Angular component consists of:

1. **Template (HTML)** - What the user sees
2. **Class (TypeScript)** - The logic and data
3. **Metadata (Decorator)** - Configuration

```typescript
// Example Component
import { Component } from '@angular/core';

@Component({
  selector: 'app-user-card',        // How to use: <app-user-card></app-user-card>
  templateUrl: './user-card.component.html',  // HTML template
  styleUrls: ['./user-card.component.css']     // CSS styles
})
export class UserCardComponent {
  userName = 'John Doe';  // Data
  userEmail = 'john@example.com';

  // Methods (Logic)
  getUserInfo() {
    return `${this.userName} - ${this.userEmail}`;
  }
}
```

```html
<!-- user-card.component.html (Template) -->
<div class="user-card">
  <h3>{{ userName }}</h3>
  <p>{{ userEmail }}</p>
  <button (click)="getUserInfo()">Get Info</button>
</div>
```

#### **Why Use Components?**

- ✅ **Reusability**: Use the same component multiple times
- ✅ **Modularity**: Break app into smaller, manageable pieces
- ✅ **Maintainability**: Easy to find and fix issues
- ✅ **Testability**: Test components independently

---

### **Q2: How to Create a Component?**

**Answer:**

You can create a component using Angular CLI (recommended) or manually.

#### **Method 1: Using Angular CLI (Recommended)**

```bash
# Generate a component
ng generate component user-card
# Short form:
ng g c user-card

# With options
ng g c user-card --skip-tests  # Skip test file
ng g c user-card --inline-template  # Inline template
ng g c user-card --inline-style  # Inline styles
```

**What gets created:**
```
src/app/user-card/
├── user-card.component.ts      # Component class
├── user-card.component.html    # Template
├── user-card.component.css     # Styles
└── user-card.component.spec.ts # Tests
```

#### **Method 2: Manual Creation**

**Step 1: Create files**
```typescript
// user-card.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-user-card',
  templateUrl: './user-card.component.html',
  styleUrls: ['./user-card.component.css']
})
export class UserCardComponent {
  userName = 'John Doe';
}
```

**Step 2: Create template**
```html
<!-- user-card.component.html -->
<div>
  <h3>{{ userName }}</h3>
</div>
```

**Step 3: Create styles**
```css
/* user-card.component.css */
div {
  padding: 10px;
  border: 1px solid #ccc;
}
```

**Step 4: Register in module (if using NgModule)**
```typescript
// app.module.ts
import { UserCardComponent } from './user-card/user-card.component';

@NgModule({
  declarations: [UserCardComponent],  // Register component
  // ...
})
export class AppModule { }
```

**Or use standalone (Angular 14+):**
```typescript
@Component({
  selector: 'app-user-card',
  standalone: true,  // Standalone component
  templateUrl: './user-card.component.html',
  styleUrls: ['./user-card.component.css']
})
export class UserCardComponent { }
```

#### **How to Use the Component:**

```html
<!-- In any template -->
<app-user-card></app-user-card>
```

---

### **Q3: What is Component Selector?**

**Answer:**

The selector is a **CSS selector** that tells Angular where to insert the component in the HTML.

#### **Simple Explanation:**

The selector is like a **name tag** that identifies your component:
- When Angular sees this name in HTML, it replaces it with your component

#### **Types of Selectors:**

**1. Element Selector (Most Common)**
```typescript
@Component({
  selector: 'app-user-card'  // Use as: <app-user-card></app-user-card>
})
```

**2. Attribute Selector**
```typescript
@Component({
  selector: '[app-user-card]'  // Use as: <div app-user-card></div>
})
```

**3. Class Selector**
```typescript
@Component({
  selector: '.app-user-card'  // Use as: <div class="app-user-card"></div>
})
```

**4. ID Selector (Not Recommended)**
```typescript
@Component({
  selector: '#app-user-card'  // Use as: <div id="app-user-card"></div>
})
```

#### **Best Practices:**

- ✅ Use **element selector** (most common)
- ✅ Prefix with `app-` to avoid conflicts
- ✅ Use kebab-case (lowercase with hyphens)
- ❌ Avoid ID selector (IDs should be unique)

---

### **Q4: What is Component Template?**

**Answer:**

The template is the **HTML markup** that defines what the component renders on the screen.

#### **Simple Explanation:**

The template is like a **blueprint** for what the user sees:
- It defines the structure (HTML)
- It can display data (interpolation)
- It can handle events (click, input, etc.)

#### **Two Ways to Define Templates:**

**1. External Template (Recommended)**
```typescript
@Component({
  selector: 'app-user-card',
  templateUrl: './user-card.component.html'  // External file
})
```

```html
<!-- user-card.component.html -->
<div class="card">
  <h3>{{ userName }}</h3>
  <p>{{ userEmail }}</p>
</div>
```

**2. Inline Template**
```typescript
@Component({
  selector: 'app-user-card',
  template: `
    <div class="card">
      <h3>{{ userName }}</h3>
      <p>{{ userEmail }}</p>
    </div>
  `  // Template directly in TypeScript
})
```

#### **Template Features:**

- **Interpolation**: `{{ userName }}` - Display data
- **Property Binding**: `[disabled]="isDisabled"` - Set properties
- **Event Binding**: `(click)="handleClick()"` - Handle events
- **Directives**: `*ngIf`, `*ngFor`, etc.
- **Pipes**: `{{ date | date }}` - Transform data

---

### **Q5: What is Component Class?**

**Answer:**

The component class is the **TypeScript class** that contains the component's **data** and **logic**.

#### **Simple Explanation:**

The class is like the **brain** of the component:
- It stores data (properties)
- It contains methods (functions)
- It handles business logic

#### **Component Class Structure:**

```typescript
import { Component } from '@angular/core';

export class UserCardComponent {
  // 1. Properties (Data)
  userName: string = 'John Doe';
  userEmail: string = 'john@example.com';
  isActive: boolean = true;
  userCount: number = 0;

  // 2. Methods (Logic)
  getUserInfo(): string {
    return `${this.userName} - ${this.userEmail}`;
  }

  toggleActive(): void {
    this.isActive = !this.isActive;
  }

  incrementCount(): void {
    this.userCount++;
  }

  // 3. Lifecycle Hooks (Special methods)
  ngOnInit(): void {
    console.log('Component initialized');
  }
}
```

#### **Key Points:**

- ✅ Use `this` to access properties and methods
- ✅ Properties are accessible in the template
- ✅ Methods can be called from the template
- ✅ Follow TypeScript best practices (types, access modifiers)

---

### **Q6: What is Data Binding in Components?**

**Answer:**

Data binding is the mechanism that **connects** the component class (TypeScript) with the template (HTML).

#### **Simple Explanation:**

Data binding is like a **bridge** between your code and the UI:
- Changes in code → automatically update the UI
- User actions in UI → trigger code execution

#### **Types of Data Binding:**

**1. Interpolation (One-way: Class → Template)**
```typescript
// Class
userName = 'John Doe';
```
```html
<!-- Template -->
<p>{{ userName }}</p>  <!-- Displays: John Doe -->
```

**2. Property Binding (One-way: Class → Template)**
```typescript
// Class
isDisabled = true;
imageUrl = 'https://example.com/image.jpg';
```
```html
<!-- Template -->
<button [disabled]="isDisabled">Click</button>
<img [src]="imageUrl" alt="User">
```

**3. Event Binding (One-way: Template → Class)**
```typescript
// Class
handleClick() {
  console.log('Button clicked!');
}
```
```html
<!-- Template -->
<button (click)="handleClick()">Click Me</button>
```

**4. Two-way Binding (Both ways)**
```typescript
// Class
userName = '';
```
```html
<!-- Template -->
<input [(ngModel)]="userName" placeholder="Enter name">
<!-- Changes in input update userName, changes in userName update input -->
```

#### **Visual Summary:**

```
Component Class          Template
─────────────────       ────────────────
userName = 'John'   →   {{ userName }}        (Interpolation)
isDisabled = true   →   [disabled]="isDisabled" (Property Binding)
                      →   (click)="handleClick()" (Event Binding)
userName            ↔   [(ngModel)]="userName"   (Two-way Binding)
```

---

### **Q7: What are Component Inputs and Outputs?**

**Answer:**

Inputs and Outputs allow components to **communicate** with parent components.

#### **Simple Explanation:**

- **@Input()**: Component **receives** data from parent (like function parameters)
- **@Output()**: Component **sends** data to parent (like function return value)

#### **@Input() - Receiving Data from Parent**

```typescript
// child.component.ts
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-user-card',
  template: `
    <div>
      <h3>{{ userName }}</h3>
      <p>{{ userEmail }}</p>
    </div>
  `
})
export class UserCardComponent {
  @Input() userName: string = '';      // Receives from parent
  @Input() userEmail: string = '';     // Receives from parent
}
```

```typescript
// parent.component.ts
export class ParentComponent {
  users = [
    { name: 'John', email: 'john@example.com' },
    { name: 'Jane', email: 'jane@example.com' }
  ];
}
```

```html
<!-- parent.component.html -->
<app-user-card 
  [userName]="users[0].name"
  [userEmail]="users[0].email">
</app-user-card>
```

#### **@Output() - Sending Data to Parent**

```typescript
// child.component.ts
import { Component, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-user-card',
  template: `
    <div>
      <h3>{{ userName }}</h3>
      <button (click)="onDelete()">Delete</button>
    </div>
  `
})
export class UserCardComponent {
  @Input() userName: string = '';
  
  @Output() userDeleted = new EventEmitter<string>();  // Sends to parent

  onDelete() {
    this.userDeleted.emit(this.userName);  // Emit event
  }
}
```

```html
<!-- parent.component.html -->
<app-user-card 
  [userName]="user.name"
  (userDeleted)="handleUserDeleted($event)">
</app-user-card>
```

```typescript
// parent.component.ts
export class ParentComponent {
  handleUserDeleted(userName: string) {
    console.log('User deleted:', userName);
    // Remove user from list, etc.
  }
}
```

#### **Complete Example: Parent-Child Communication**

```typescript
// parent.component.ts
export class UserListComponent {
  users = ['John', 'Jane', 'Bob'];
  
  onUserDeleted(userName: string) {
    this.users = this.users.filter(u => u !== userName);
  }
}
```

```html
<!-- parent.component.html -->
<div *ngFor="let user of users">
  <app-user-card 
    [userName]="user"
    (userDeleted)="onUserDeleted($event)">
  </app-user-card>
</div>
```

---

### **Q8: What are Component Lifecycle Hooks?**

**Answer:**

Lifecycle hooks are **special methods** that Angular calls at specific points in a component's life.

#### **Simple Explanation:**

Think of lifecycle hooks like **milestones** in a component's life:
- Birth (creation)
- Growth (changes)
- Death (destruction)

Angular calls these methods automatically at the right time.

#### **Common Lifecycle Hooks:**

**1. ngOnInit() - Component Initialized**
```typescript
export class UserCardComponent implements OnInit {
  ngOnInit(): void {
    console.log('Component initialized');
    // Perfect for: API calls, initialization logic
  }
}
```
**When**: After Angular creates the component and sets up data binding.

**2. ngOnChanges() - Input Properties Changed**
```typescript
import { OnChanges, SimpleChanges } from '@angular/core';

export class UserCardComponent implements OnChanges {
  @Input() userName: string = '';

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['userName']) {
      console.log('userName changed:', changes['userName'].currentValue);
    }
  }
}
```
**When**: When input properties change.

**3. ngAfterViewInit() - View Initialized**
```typescript
import { AfterViewInit, ViewChild, ElementRef } from '@angular/core';

export class UserCardComponent implements AfterViewInit {
  @ViewChild('myDiv') myDiv!: ElementRef;

  ngAfterViewInit(): void {
    console.log('View initialized');
    // Access DOM elements here
    this.myDiv.nativeElement.style.color = 'red';
  }
}
```
**When**: After Angular initializes the component's view.

**4. ngOnDestroy() - Component Destroyed**
```typescript
import { OnDestroy } from '@angular/core';
import { Subscription } from 'rxjs';

export class UserCardComponent implements OnDestroy {
  private subscription!: Subscription;

  ngOnDestroy(): void {
    console.log('Component destroyed');
    // Cleanup: unsubscribe, clear timers, etc.
    this.subscription?.unsubscribe();
  }
}
```
**When**: Just before Angular destroys the component.

#### **Lifecycle Hook Order:**

```
1. constructor()           - Component created
2. ngOnChanges()            - Inputs changed
3. ngOnInit()               - Component initialized
4. ngDoCheck()              - Change detection
5. ngAfterContentInit()     - Content projected
6. ngAfterContentChecked()  - Content checked
7. ngAfterViewInit()       - View initialized
8. ngAfterViewChecked()    - View checked
9. ngOnDestroy()            - Component destroyed
```

#### **When to Use Each:**

- **ngOnInit()**: API calls, initialization
- **ngOnChanges()**: React to input changes
- **ngAfterViewInit()**: Access DOM elements
- **ngOnDestroy()**: Cleanup (unsubscribe, clear timers)

---

## 🎯 Interview Questions on Components

### **Q1: What is the difference between @Component and @Directive?**

**Answer:**

| Feature | @Component | @Directive |
|---------|-----------|------------|
| **Template** | Has template | No template |
| **Purpose** | Create UI elements | Modify behavior/appearance |
| **Selector** | Usually element | Usually attribute |
| **Use case** | UserCardComponent | HighlightDirective, ClickDirective |

**Example:**
```typescript
// Component - Has template
@Component({
  selector: 'app-user-card',
  template: '<div>User Card</div>'
})

// Directive - No template, modifies existing element
@Directive({
  selector: '[appHighlight]'
})
```

---

### **Q2: What is the difference between ngOnInit and constructor?**

**Answer:**

| Feature | constructor | ngOnInit |
|---------|------------|----------|
| **When** | Component class instantiated | After Angular initializes component |
| **Purpose** | Dependency injection | Component initialization |
| **Access to inputs** | ❌ No | ✅ Yes |
| **Best for** | Injecting services | API calls, setup logic |

**Example:**
```typescript
export class UserCardComponent {
  @Input() userName: string = '';

  constructor(private http: HttpClient) {
    // ❌ Can't access userName here (not initialized yet)
    // ✅ Can inject services
  }

  ngOnInit() {
    // ✅ Can access userName here
    // ✅ Perfect for API calls
    this.loadUserData();
  }
}
```

---

### **Q3: How do you pass data from parent to child component?**

**Answer:**

Use **@Input()** decorator:

```typescript
// Child component
@Component({
  selector: 'app-child',
  template: '<p>{{ message }}</p>'
})
export class ChildComponent {
  @Input() message: string = '';
}
```

```html
<!-- Parent template -->
<app-child [message]="parentMessage"></app-child>
```

```typescript
// Parent component
export class ParentComponent {
  parentMessage = 'Hello from parent!';
}
```

---

### **Q4: How do you pass data from child to parent component?**

**Answer:**

Use **@Output()** with **EventEmitter**:

```typescript
// Child component
@Component({
  selector: 'app-child',
  template: '<button (click)="sendData()">Send</button>'
})
export class ChildComponent {
  @Output() dataSent = new EventEmitter<string>();

  sendData() {
    this.dataSent.emit('Data from child');
  }
}
```

```html
<!-- Parent template -->
<app-child (dataSent)="handleData($event)"></app-child>
```

```typescript
// Parent component
export class ParentComponent {
  handleData(data: string) {
    console.log('Received:', data);
  }
}
```

---

### **Q5: What is ViewChild and how do you use it?**

**Answer:**

`@ViewChild` allows a parent component to **access** a child component or DOM element.

```typescript
import { ViewChild, ElementRef, Component } from '@angular/core';

export class ParentComponent {
  @ViewChild('myInput') inputElement!: ElementRef;
  @ViewChild(ChildComponent) childComponent!: ChildComponent;

  ngAfterViewInit() {
    // Access DOM element
    this.inputElement.nativeElement.focus();
    
    // Access child component
    this.childComponent.someMethod();
  }
}
```

```html
<!-- Parent template -->
<input #myInput type="text">
<app-child></app-child>
```

---

### **Q6: What is Content Projection (ng-content)?**

**Answer:**

Content projection allows you to **insert** content from parent into child component.

```typescript
// Child component
@Component({
  selector: 'app-card',
  template: `
    <div class="card">
      <div class="card-header">
        <ng-content select="[card-header]"></ng-content>
      </div>
      <div class="card-body">
        <ng-content></ng-content>
      </div>
    </div>
  `
})
export class CardComponent { }
```

```html
<!-- Parent template -->
<app-card>
  <h2 card-header>Card Title</h2>
  <p>Card content goes here</p>
</app-card>
```

**Result:**
```html
<div class="card">
  <div class="card-header">
    <h2>Card Title</h2>
  </div>
  <div class="card-body">
    <p>Card content goes here</p>
  </div>
</div>
```

---

### **Q7: What is the difference between template and templateUrl?**

**Answer:**

| Feature | template | templateUrl |
|---------|----------|-------------|
| **Location** | Inline in TypeScript | External HTML file |
| **Use case** | Small templates | Large templates |
| **Syntax** | Backticks (``) | File path string |

**Example:**
```typescript
// Inline template
@Component({
  template: `<div>{{ message }}</div>`
})

// External template
@Component({
  templateUrl: './component.component.html'
})
```

**Best Practice**: Use `templateUrl` for templates longer than 3-4 lines.

---

### **Q8: What are Standalone Components?**

**Answer:**

Standalone components (Angular 14+) are components that **don't need** to be declared in an NgModule.

```typescript
// Standalone component
@Component({
  selector: 'app-user-card',
  standalone: true,  // ← Standalone flag
  imports: [CommonModule],  // Import what you need
  templateUrl: './user-card.component.html'
})
export class UserCardComponent { }
```

**Benefits:**
- ✅ No NgModule needed
- ✅ Lazy loading is simpler
- ✅ Better tree-shaking
- ✅ Modern Angular approach

---

## 📝 Practice Exercises

### **Exercise 1: Create a User Card Component**

Create a component that:
- Displays user name and email
- Has a "Delete" button
- Emits event when deleted
- Uses @Input() for user data
- Uses @Output() for delete event

### **Exercise 2: Implement Lifecycle Hooks**

Create a component that:
- Logs message in ngOnInit()
- Logs message in ngOnDestroy()
- Makes API call in ngOnInit()
- Unsubscribes in ngOnDestroy()

### **Exercise 3: Parent-Child Communication**

Create:
- Parent component with list of users
- Child component that displays user card
- Pass data from parent to child
- Handle delete event from child to parent

---

## 🎓 Key Takeaways

1. ✅ Components are building blocks of Angular apps
2. ✅ Component = Template + Class + Metadata
3. ✅ Use @Input() to receive data from parent
4. ✅ Use @Output() to send data to parent
5. ✅ Lifecycle hooks run at specific times
6. ✅ ngOnInit() is perfect for initialization
7. ✅ ngOnDestroy() is perfect for cleanup
8. ✅ Standalone components are the modern approach

---

## 📚 Next Topics

- [x] Components
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

