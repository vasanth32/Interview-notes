# Angular Learning - Questions & Answers

This document is for learning Angular concepts through questions and detailed explanations. Ask questions one by one, and I'll add comprehensive explanations here.

---

## 📚 Table of Contents

- [Routing](#routing)
- [Components](#components)
- [Services](#services) ⬅️ **Current Topic**
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

---

## 🔧 Services

### **Q1: What is a Service in Angular?**

**Answer:**

A service is a **TypeScript class** that contains **reusable business logic** and can be **shared** across multiple components.

#### **Simple Explanation:**

Think of a service like a **shared toolbox**:
- Multiple people (components) can use the same tools (methods)
- Tools are stored in one place (service)
- Everyone uses the same tools, so no duplication

#### **Real-World Analogy:**

Imagine a **restaurant**:
- **Components** = Waiters (they interact with customers)
- **Services** = Kitchen staff (they prepare food, handle orders)
- Waiters don't cook - they call the kitchen (service) to get food
- Multiple waiters can use the same kitchen

#### **Why Use Services?**

- ✅ **Reusability**: Write logic once, use everywhere
- ✅ **Separation of Concerns**: Components focus on UI, services handle business logic
- ✅ **Testability**: Easy to test services independently
- ✅ **Data Sharing**: Share data between components
- ✅ **API Calls**: Centralized HTTP requests

#### **Common Use Cases:**

1. **API Communication** - HTTP requests
2. **Data Sharing** - Share data between components
3. **Business Logic** - Calculations, validations
4. **Logging** - Centralized logging
5. **Authentication** - User login/logout
6. **Local Storage** - Save/retrieve data

---

### **Q2: How to Create a Service?**

**Answer:**

You can create a service using Angular CLI (recommended) or manually.

#### **Method 1: Using Angular CLI (Recommended)**

```bash
# Generate a service
ng generate service services/user
# Short form:
ng g s services/user

# With options
ng g s services/user --skip-tests  # Skip test file
```

**What gets created:**
```
src/app/services/
├── user.service.ts      # Service class
└── user.service.spec.ts # Test file
```

#### **Method 2: Manual Creation**

**Step 1: Create service file**
```typescript
// user.service.ts
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'  // Makes it available app-wide
})
export class UserService {
  // Service logic here
}
```

**Step 2: Use the service**
```typescript
// component.ts
import { UserService } from './services/user.service';

export class UserComponent {
  constructor(private userService: UserService) { }
}
```

#### **Service Structure:**

```typescript
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'  // Singleton - one instance for entire app
})
export class UserService {
  // Properties
  private users: string[] = [];

  // Methods
  getUsers(): string[] {
    return this.users;
  }

  addUser(user: string): void {
    this.users.push(user);
  }

  deleteUser(user: string): void {
    this.users = this.users.filter(u => u !== user);
  }
}
```

---

### **Q3: What is @Injectable Decorator?**

**Answer:**

`@Injectable()` is a **decorator** that marks a class as a service that can be **injected** into other classes.

#### **Simple Explanation:**

`@Injectable()` is like a **label** that says:
- "This is a service"
- "It can be injected into components"
- "Angular can manage its lifecycle"

#### **@Injectable() Options:**

**1. providedIn: 'root' (Recommended - Singleton)**
```typescript
@Injectable({
  providedIn: 'root'  // One instance for entire app
})
export class UserService { }
```
- ✅ **Singleton**: One instance shared across entire app
- ✅ **Lazy Loading**: Service only created when first used
- ✅ **Tree-shaking**: Unused services removed from bundle

**2. providedIn: 'platform'**
```typescript
@Injectable({
  providedIn: 'platform'  // Shared across multiple apps
})
```
- Used for services shared across multiple Angular apps

**3. providedIn: 'any'**
```typescript
@Injectable({
  providedIn: 'any'  // New instance for each module
})
```
- Creates new instance for each lazy-loaded module

**4. Provided in Module (Old Way)**
```typescript
@Injectable()  // No providedIn
export class UserService { }
```

```typescript
// app.module.ts
@NgModule({
  providers: [UserService]  // Register here
})
```

#### **Best Practice:**

Always use `providedIn: 'root'` for most services (modern Angular approach).

---

### **Q4: How to Inject a Service into a Component?**

**Answer:**

You inject a service using **constructor injection** (Dependency Injection).

#### **Simple Explanation:**

Injection is like **ordering food**:
- You tell the waiter (Angular) what you want (service)
- The waiter brings it to you (injects it)
- You use it (call methods)

#### **Step-by-Step:**

**Step 1: Create Service**
```typescript
// user.service.ts
@Injectable({
  providedIn: 'root'
})
export class UserService {
  getUsers(): string[] {
    return ['John', 'Jane', 'Bob'];
  }
}
```

**Step 2: Inject into Component**
```typescript
// user.component.ts
import { Component } from '@angular/core';
import { UserService } from './services/user.service';

@Component({
  selector: 'app-user',
  template: '<div>{{ users }}</div>'
})
export class UserComponent {
  users: string[] = [];

  constructor(private userService: UserService) {
    // Service is injected here
    // 'private' creates a property automatically
  }

  ngOnInit() {
    this.users = this.userService.getUsers();
  }
}
```

#### **Different Ways to Inject:**

**1. Constructor Injection (Recommended)**
```typescript
constructor(private userService: UserService) { }
// 'private' creates: private userService: UserService
```

**2. Explicit Property**
```typescript
userService: UserService;

constructor(userService: UserService) {
  this.userService = userService;
}
```

**3. Public (if needed in template)**
```typescript
constructor(public userService: UserService) { }
// Can use in template: {{ userService.getUsers() }}
```

#### **Key Points:**

- ✅ Use `private` in constructor (creates property automatically)
- ✅ Angular automatically provides the service instance
- ✅ Service must be decorated with `@Injectable()`
- ✅ Service must be provided (providedIn or providers array)

---

### **Q5: How to Share Data Between Components Using Services?**

**Answer:**

Services can act as a **central data store** that multiple components can access.

#### **Simple Explanation:**

Think of a service like a **shared whiteboard**:
- Multiple people (components) can read from it
- Multiple people can write to it
- Everyone sees the same data

#### **Example: Sharing User Data**

```typescript
// user.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class UserService {
  // BehaviorSubject stores current value and emits to subscribers
  private currentUserSubject = new BehaviorSubject<string>('');
  public currentUser$: Observable<string> = this.currentUserSubject.asObservable();

  // Set user
  setCurrentUser(user: string): void {
    this.currentUserSubject.next(user);
  }

  // Get current user
  getCurrentUser(): string {
    return this.currentUserSubject.value;
  }
}
```

```typescript
// component1.ts - Sets user
export class LoginComponent {
  constructor(private userService: UserService) { }

  login(userName: string) {
    this.userService.setCurrentUser(userName);
  }
}
```

```typescript
// component2.ts - Reads user
export class ProfileComponent {
  currentUser: string = '';

  constructor(private userService: UserService) { }

  ngOnInit() {
    // Subscribe to changes
    this.userService.currentUser$.subscribe(user => {
      this.currentUser = user;
    });
  }
}
```

#### **Alternative: Simple Property Sharing**

```typescript
// user.service.ts
@Injectable({
  providedIn: 'root'
})
export class UserService {
  currentUser: string = '';  // Shared property

  setUser(user: string): void {
    this.currentUser = user;
  }

  getUser(): string {
    return this.currentUser;
  }
}
```

```typescript
// component1.ts
setUser() {
  this.userService.setUser('John');
}

// component2.ts
ngOnInit() {
  this.user = this.userService.getUser();
}
```

**Note**: For reactive updates, use RxJS (BehaviorSubject/Observable). For simple cases, properties work fine.

---

### **Q6: How to Make HTTP Requests in a Service?**

**Answer:**

Use Angular's **HttpClient** service to make HTTP requests.

#### **Simple Explanation:**

HttpClient is like a **postal service**:
- You send a request (letter)
- It goes to the server (address)
- You get a response (reply)

#### **Step-by-Step:**

**Step 1: Import HttpClientModule**
```typescript
// app.config.ts (Standalone) or app.module.ts
import { provideHttpClient } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient()  // Enable HTTP
  ]
};
```

**Step 2: Inject HttpClient in Service**
```typescript
// user.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private apiUrl = 'https://api.example.com/users';

  constructor(private http: HttpClient) { }

  // GET request
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
  }

  // POST request
  createUser(user: User): Observable<User> {
    return this.http.post<User>(this.apiUrl, user);
  }

  // PUT request
  updateUser(id: number, user: User): Observable<User> {
    return this.http.put<User>(`${this.apiUrl}/${id}`, user);
  }

  // DELETE request
  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
```

**Step 3: Use in Component**
```typescript
// user.component.ts
export class UserComponent {
  users: User[] = [];

  constructor(private userService: UserService) { }

  ngOnInit() {
    this.userService.getUsers().subscribe({
      next: (users) => {
        this.users = users;
      },
      error: (error) => {
        console.error('Error:', error);
      }
    });
  }
}
```

#### **HTTP Methods:**

```typescript
// GET - Retrieve data
this.http.get<User[]>('/api/users')

// POST - Create new resource
this.http.post<User>('/api/users', userData)

// PUT - Update entire resource
this.http.put<User>('/api/users/1', userData)

// PATCH - Update partial resource
this.http.patch<User>('/api/users/1', { name: 'John' })

// DELETE - Delete resource
this.http.delete<void>('/api/users/1')
```

---

### **Q7: What is Service Scope and Singleton Pattern?**

**Answer:**

Service scope determines **how many instances** of a service are created.

#### **Simple Explanation:**

Think of service scope like **sharing a car**:
- **Singleton**: One car shared by everyone (one instance)
- **Per Component**: Each person has their own car (multiple instances)

#### **Service Scopes:**

**1. Singleton (providedIn: 'root') - Most Common**
```typescript
@Injectable({
  providedIn: 'root'  // One instance for entire app
})
export class UserService {
  private data: string = 'Shared Data';

  getData(): string {
    return this.data;
  }
}
```

**Result:**
- ✅ One instance created
- ✅ Shared across all components
- ✅ Data persists across components
- ✅ Memory efficient

**2. Per Component Instance**
```typescript
@Component({
  selector: 'app-user',
  providers: [UserService]  // New instance for this component
})
export class UserComponent {
  constructor(private userService: UserService) { }
}
```

**Result:**
- ❌ New instance for each component
- ❌ Data not shared between components
- ❌ Each component has its own state

**3. Per Module**
```typescript
@NgModule({
  providers: [UserService]  // One instance per module
})
export class FeatureModule { }
```

#### **When to Use Each:**

- **Singleton (root)**: Most services (API calls, data sharing, utilities)
- **Per Component**: Component-specific state, temporary data
- **Per Module**: Feature-specific services

#### **Example: Singleton Behavior**

```typescript
// user.service.ts
@Injectable({ providedIn: 'root' })
export class UserService {
  private count: number = 0;

  increment(): void {
    this.count++;
  }

  getCount(): number {
    return this.count;
  }
}
```

```typescript
// component1.ts
export class Component1 {
  constructor(private userService: UserService) { }

  increment() {
    this.userService.increment();  // count = 1
  }
}
```

```typescript
// component2.ts
export class Component2 {
  constructor(private userService: UserService) { }

  getCount() {
    return this.userService.getCount();  // Returns 1 (same instance!)
  }
}
```

---

### **Q8: How to Handle Errors in Services?**

**Answer:**

Use **RxJS operators** and **error handling** patterns to handle errors gracefully.

#### **Simple Explanation:**

Error handling is like having a **safety net**:
- If something goes wrong, catch it
- Show a friendly message to user
- Don't let the app crash

#### **Error Handling Patterns:**

**1. Try-Catch (Synchronous)**
```typescript
@Injectable({ providedIn: 'root' })
export class UserService {
  getUsers(): string[] {
    try {
      // Some operation that might fail
      return this.processUsers();
    } catch (error) {
      console.error('Error:', error);
      return [];  // Return empty array on error
    }
  }
}
```

**2. Observable Error Handling (Asynchronous)**
```typescript
import { catchError, throwError } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class UserService {
  constructor(private http: HttpClient) { }

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>('/api/users').pipe(
      catchError((error) => {
        console.error('API Error:', error);
        // Return empty array or throw custom error
        return throwError(() => new Error('Failed to load users'));
      })
    );
  }
}
```

**3. Component-Level Error Handling**
```typescript
// component.ts
ngOnInit() {
  this.userService.getUsers().subscribe({
    next: (users) => {
      this.users = users;
    },
    error: (error) => {
      console.error('Error loading users:', error);
      this.errorMessage = 'Failed to load users. Please try again.';
    }
  });
}
```

**4. Global Error Handler**
```typescript
// error-handler.service.ts
import { Injectable, ErrorHandler } from '@angular/core';

@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  handleError(error: any): void {
    console.error('Global Error:', error);
    // Log to external service, show notification, etc.
  }
}
```

```typescript
// app.config.ts
import { ErrorHandler } from '@angular/core';

export const appConfig: ApplicationConfig = {
  providers: [
    { provide: ErrorHandler, useClass: GlobalErrorHandler }
  ]
};
```

#### **Best Practices:**

- ✅ Always handle errors in HTTP requests
- ✅ Provide fallback values
- ✅ Log errors for debugging
- ✅ Show user-friendly error messages
- ✅ Use try-catch for synchronous code
- ✅ Use RxJS catchError for observables

---

## 🎯 Interview Questions on Services

### **Q1: What is the difference between a Service and a Component?**

**Answer:**

| Feature | Service | Component |
|---------|---------|-----------|
| **Purpose** | Business logic, data | UI, user interaction |
| **Template** | ❌ No template | ✅ Has template |
| **Directive** | ❌ No | ✅ Yes (can be used in HTML) |
| **Lifecycle** | Managed by Angular | Has lifecycle hooks |
| **Use case** | API calls, data sharing | Display UI, handle events |

**Example:**
```typescript
// Service - No template, just logic
@Injectable({ providedIn: 'root' })
export class UserService {
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>('/api/users');
  }
}

// Component - Has template, uses service
@Component({
  selector: 'app-user',
  template: '<div>{{ users }}</div>'
})
export class UserComponent {
  constructor(private userService: UserService) { }
}
```

---

### **Q2: What is the difference between providedIn: 'root' and providers array?**

**Answer:**

| Feature | providedIn: 'root' | providers array |
|---------|-------------------|-----------------|
| **Scope** | App-wide singleton | Module/Component scope |
| **Lazy Loading** | ✅ Tree-shakeable | ❌ Not tree-shakeable |
| **Modern** | ✅ Yes (Angular 6+) | ❌ Old way |
| **Location** | In service file | In module/component |

**Example:**
```typescript
// Modern way (Recommended)
@Injectable({ providedIn: 'root' })
export class UserService { }

// Old way
@Injectable()
export class UserService { }

// In module
@NgModule({
  providers: [UserService]  // Register here
})
```

**Best Practice**: Always use `providedIn: 'root'` for most services.

---

### **Q3: How do you share data between sibling components?**

**Answer:**

Use a **shared service** with RxJS (BehaviorSubject/Observable):

```typescript
// data.service.ts
@Injectable({ providedIn: 'root' })
export class DataService {
  private dataSubject = new BehaviorSubject<string>('');
  public data$ = this.dataSubject.asObservable();

  setData(data: string): void {
    this.dataSubject.next(data);
  }
}
```

```typescript
// component1.ts - Sends data
export class Component1 {
  constructor(private dataService: DataService) { }

  sendData() {
    this.dataService.setData('Hello from Component1');
  }
}
```

```typescript
// component2.ts - Receives data
export class Component2 {
  data: string = '';

  constructor(private dataService: DataService) { }

  ngOnInit() {
    this.dataService.data$.subscribe(data => {
      this.data = data;
    });
  }
}
```

---

### **Q4: What is the difference between Subject and BehaviorSubject?**

**Answer:**

| Feature | Subject | BehaviorSubject |
|---------|---------|-----------------|
| **Initial Value** | ❌ No | ✅ Yes |
| **Current Value** | ❌ Can't get | ✅ Can get (.value) |
| **New Subscribers** | ❌ No initial value | ✅ Gets current value |
| **Use case** | Events, notifications | State management |

**Example:**
```typescript
// Subject - No initial value
const subject = new Subject<string>();
subject.subscribe(value => console.log(value));
subject.next('Hello');  // Subscriber gets: 'Hello'

// BehaviorSubject - Has initial value
const behaviorSubject = new BehaviorSubject<string>('Initial');
behaviorSubject.subscribe(value => console.log(value));  // Gets: 'Initial'
behaviorSubject.next('Hello');  // Gets: 'Hello'
console.log(behaviorSubject.value);  // 'Hello' (can get current value)
```

---

### **Q5: How do you handle HTTP errors globally?**

**Answer:**

Use an **HTTP Interceptor**:

```typescript
// error.interceptor.ts
import { Injectable } from '@angular/core';
import { HttpInterceptor, HttpRequest, HttpHandler, HttpErrorResponse } from '@angular/common/http';
import { catchError } from 'rxjs/operators';
import { throwError } from 'rxjs';

@Injectable()
export class ErrorInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler) {
    return next.handle(req).pipe(
      catchError((error: HttpErrorResponse) => {
        console.error('HTTP Error:', error);
        
        // Handle different error types
        if (error.status === 401) {
          // Unauthorized - redirect to login
        } else if (error.status === 500) {
          // Server error - show message
        }
        
        return throwError(() => error);
      })
    );
  }
}
```

```typescript
// app.config.ts
import { provideHttpClient, withInterceptors } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(withInterceptors([errorInterceptor]))
  ]
};
```

---

### **Q6: How do you test a service?**

**Answer:**

Use **Jasmine** and **Angular Testing Utilities**:

```typescript
// user.service.spec.ts
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { UserService } from './user.service';

describe('UserService', () => {
  let service: UserService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [UserService]
    });
    service = TestBed.inject(UserService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  it('should get users', () => {
    const mockUsers = [{ id: 1, name: 'John' }];

    service.getUsers().subscribe(users => {
      expect(users).toEqual(mockUsers);
    });

    const req = httpMock.expectOne('/api/users');
    expect(req.request.method).toBe('GET');
    req.flush(mockUsers);
  });

  afterEach(() => {
    httpMock.verify();
  });
});
```

---

### **Q7: What is the difference between a Service and a Factory?**

**Answer:**

| Feature | Service | Factory |
|---------|---------|---------|
| **Returns** | Instance of class | Any value/object |
| **Use case** | Business logic | Configuration, complex setup |
| **Modern** | ✅ Standard | ❌ Rarely used |

**Example:**
```typescript
// Service - Returns instance
@Injectable({ providedIn: 'root' })
export class UserService {
  getUsers() { }
}

// Factory - Returns configured object
export function userServiceFactory() {
  return {
    apiUrl: 'https://api.example.com',
    getUsers: () => { }
  };
}
```

**Note**: In modern Angular, services are preferred over factories.

---

### **Q8: How do you create a singleton service?**

**Answer:**

Use `providedIn: 'root'`:

```typescript
@Injectable({
  providedIn: 'root'  // Creates singleton
})
export class UserService {
  // One instance for entire app
}
```

**Verify it's a singleton:**
```typescript
// component1.ts
constructor(private userService: UserService) {
  console.log('Service instance:', this.userService);
}

// component2.ts
constructor(private userService: UserService) {
  console.log('Service instance:', this.userService);
  // Both will log the SAME instance
}
```

---

## 📝 Practice Exercises

### **Exercise 1: Create a User Service**

Create a service that:
- Stores a list of users
- Has methods: getUsers(), addUser(), deleteUser()
- Uses BehaviorSubject for reactive updates
- Inject it into a component and display users

### **Exercise 2: HTTP Service**

Create a service that:
- Makes GET request to fetch users
- Makes POST request to create user
- Handles errors gracefully
- Uses proper TypeScript types

### **Exercise 3: Shared Data Service**

Create a service that:
- Shares data between two sibling components
- Component1 can set data
- Component2 can read data
- Use RxJS for reactive updates

---

## 🎓 Key Takeaways

1. ✅ Services contain reusable business logic
2. ✅ Use `@Injectable({ providedIn: 'root' })` for most services
3. ✅ Inject services via constructor
4. ✅ Services are singletons by default (one instance)
5. ✅ Use HttpClient for API calls
6. ✅ Use RxJS (BehaviorSubject) for reactive data sharing
7. ✅ Always handle errors in HTTP requests
8. ✅ Services are testable and maintainable

---

## 📚 Next Topics

- [x] Components
- [x] Services
- [ ] Dependency Injection
- [ ] Data Binding
- [ ] Directives
- [ ] HTTP Client
- [ ] Observables & RxJS
- [ ] Forms
- [ ] Lifecycle Hooks

---

**Ask your next question, and I'll add it here with a detailed explanation! 🚀**
- [ ] Data Binding
- [ ] Directives
- [ ] HTTP Client
- [ ] Observables & RxJS
- [ ] Forms
- [ ] Lifecycle Hooks

---

**Ask your next question, and I'll add it here with a detailed explanation! 🚀**

