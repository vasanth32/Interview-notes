# Angular Q&A - Part 2: Services, DI & Routing

## 🔹 Services & Dependency Injection

### What is a service in Angular?

A **Service** is a TypeScript class decorated with `@Injectable` that contains reusable business logic, data access, or shared functionality across components.

**Characteristics:**
- Singleton by default (when provided in root)
- Shared across components
- Handles data operations, HTTP calls, business logic
- Promotes separation of concerns

**Basic Service Example:**
```typescript
@Injectable({
  providedIn: 'root'  // Makes it a singleton
})
export class UserService {
  private users: User[] = [];
  
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>('/api/users');
  }
  
  getUserById(id: number): Observable<User> {
    return this.http.get<User>(`/api/users/${id}`);
  }
  
  createUser(user: User): Observable<User> {
    return this.http.post<User>('/api/users', user);
  }
  
  updateUser(id: number, user: User): Observable<User> {
    return this.http.put<User>(`/api/users/${id}`, user);
  }
  
  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`/api/users/${id}`);
  }
}
```

**Using Service in Component:**
```typescript
@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html'
})
export class UserListComponent implements OnInit {
  users: User[] = [];
  
  constructor(private userService: UserService) {}  // DI
  
  ngOnInit() {
    this.userService.getUsers().subscribe(users => {
      this.users = users;
    });
  }
}
```

**Service Use Cases:**
- HTTP API calls
- Data transformation
- Business logic
- State management
- Logging, analytics
- Authentication/authorization
- Utility functions

---

### Explain Dependency Injection (DI) in Angular.

**Dependency Injection** is a design pattern where dependencies are provided to a class rather than created inside it. Angular has a built-in DI system.

**Benefits:**
- **Loose Coupling**: Components don't create dependencies
- **Testability**: Easy to mock dependencies in tests
- **Reusability**: Services can be shared
- **Maintainability**: Centralized dependency management

**How Angular DI Works:**

1. **Declare Dependencies**: In constructor
2. **Provide Dependencies**: In module or component
3. **Injector Creates Instances**: Angular's injector manages creation

**Example:**
```typescript
// Service
@Injectable({ providedIn: 'root' })
export class LoggerService {
  log(message: string) {
    console.log(`[${new Date()}] ${message}`);
  }
}

// Component
@Component({...})
export class UserComponent {
  // Angular injects LoggerService automatically
  constructor(private logger: LoggerService) {
    this.logger.log('UserComponent created');
  }
}
```

**DI Hierarchy:**
```
Root Injector (providedIn: 'root')
  └── AppModule Injector
      └── FeatureModule Injector
          └── Component Injector
```

**Manual Injection:**
```typescript
import { Injector } from '@angular/core';

export class SomeClass {
  constructor(private injector: Injector) {
    const service = this.injector.get(LoggerService);
  }
}
```

---

### What are the different ways to provide services?

**1. providedIn: 'root' (Recommended)**
```typescript
@Injectable({
  providedIn: 'root'  // Singleton, tree-shakeable
})
export class UserService {}
```
- Creates singleton instance
- Available app-wide
- Tree-shakeable (removed if unused)

**2. providedIn: 'platform'**
```typescript
@Injectable({
  providedIn: 'platform'  // Shared across multiple apps
})
export class PlatformService {}
```
- Shared across multiple Angular applications
- Rare use case

**3. providedIn: 'any'**
```typescript
@Injectable({
  providedIn: 'any'  // New instance per lazy-loaded module
})
export class AnyService {}
```
- Creates new instance per lazy-loaded module
- Not a true singleton

**4. Module Providers**
```typescript
@NgModule({
  providers: [UserService]  // Provided at module level
})
export class UserModule {}
```
- Service available to module and its children
- Not tree-shakeable

**5. Component Providers**
```typescript
@Component({
  providers: [UserService]  // New instance per component
})
export class UserComponent {}
```
- New instance for each component instance
- Isolated service instance
- Use when component needs isolated state

**6. Lazy-Loaded Module Providers**
```typescript
// feature.module.ts
@NgModule({
  providers: [FeatureService]
})
export class FeatureModule {}
```
- Service instance per lazy-loaded module
- Not shared with other modules

**Comparison:**

| Method | Scope | Instance | Tree-shakeable |
|--------|-------|----------|----------------|
| `providedIn: 'root'` | App-wide | Singleton | ✅ Yes |
| `providedIn: 'any'` | Per lazy module | Multiple | ✅ Yes |
| Module providers | Module scope | Per module | ❌ No |
| Component providers | Component scope | Per component | ❌ No |

**Best Practice:** Use `providedIn: 'root'` for most services unless you need module/component-specific instances.

---

### What is the difference between providedIn: 'root' and providing in a module?

**providedIn: 'root':**
```typescript
@Injectable({
  providedIn: 'root'
})
export class UserService {}
```

**Module Providers:**
```typescript
@NgModule({
  providers: [UserService]
})
export class UserModule {}
```

**Key Differences:**

| Feature | providedIn: 'root' | Module Providers |
|---------|-------------------|------------------|
| **Tree-shaking** | ✅ Removed if unused | ❌ Always included |
| **Scope** | App-wide singleton | Module and children |
| **Lazy Loading** | Shared instance | New instance per lazy module |
| **Bundle Size** | Smaller (tree-shakeable) | Larger (always included) |
| **Best Practice** | ✅ Recommended | Legacy approach |

**Example:**
```typescript
// Tree-shakeable (removed if unused)
@Injectable({ providedIn: 'root' })
export class UnusedService {}  // Won't be in bundle if not used

// Always in bundle
@NgModule({
  providers: [AlwaysIncludedService]  // Always included
})
export class AppModule {}
```

**When to use Module Providers:**
- Need module-specific instance
- Legacy code migration
- Specific scoping requirements

**Best Practice:** Always use `providedIn: 'root'` unless you have a specific reason for module-level providers.

---

### What are injectors and the injector hierarchy?

**Injector** is Angular's mechanism that creates and manages service instances. It follows a hierarchical structure.

**Injector Hierarchy:**
```
Root Injector (platform level)
  └── AppModule Injector
      ├── FeatureModule Injector (eager)
      │   └── Component Injector
      └── LazyModule Injector (lazy-loaded)
          └── Component Injector
```

**How it Works:**
1. Component requests dependency
2. Angular checks component's injector
3. If not found, checks parent injector
4. Continues up hierarchy until found
5. Creates instance if needed

**Example:**
```typescript
// Root level service
@Injectable({ providedIn: 'root' })
export class RootService {}

// Module level service
@NgModule({
  providers: [ModuleService]
})
export class FeatureModule {}

// Component level service
@Component({
  providers: [ComponentService]
})
export class MyComponent {
  constructor(
    private rootService: RootService,      // From root
    private moduleService: ModuleService,   // From module
    private componentService: ComponentService  // From component
  ) {}
}
```

**Injector Resolution:**
```typescript
// Child component
@Component({
  selector: 'app-child',
  providers: [LocalService]  // Component-level
})
export class ChildComponent {
  constructor(private service: LocalService) {
    // Gets LocalService from component injector
    // If not found, checks parent, then module, then root
  }
}
```

**Manual Injector Access:**
```typescript
import { Injector } from '@angular/core';

export class SomeClass {
  constructor(private injector: Injector) {
    // Get service manually
    const service = this.injector.get(UserService);
    
    // Get with optional dependency
    const optionalService = this.injector.get(OptionalService, null);
  }
}
```

**Use Cases:**
- Understanding service scope
- Debugging DI issues
- Creating services dynamically
- Advanced DI patterns

---

### How do you create a singleton service?

**Method 1: providedIn: 'root' (Recommended)**
```typescript
@Injectable({
  providedIn: 'root'  // Single instance app-wide
})
export class SingletonService {
  private data: any;
  
  setData(data: any) {
    this.data = data;
  }
  
  getData() {
    return this.data;
  }
}
```

**Method 2: Module with forRoot() Pattern**
```typescript
// service.module.ts
@NgModule({})
export class ServiceModule {
  static forRoot(): ModuleWithProviders<ServiceModule> {
    return {
      ngModule: ServiceModule,
      providers: [SingletonService]
    };
  }
}

// app.module.ts
@NgModule({
  imports: [ServiceModule.forRoot()]  // Only import once
})
export class AppModule {}
```

**Method 3: Core Module Pattern**
```typescript
// core.module.ts
@NgModule({
  providers: [SingletonService]
})
export class CoreModule {
  constructor(@Optional() @SkipSelf() parentModule: CoreModule) {
    if (parentModule) {
      throw new Error('CoreModule is already loaded. Import only in AppModule.');
    }
  }
}

// app.module.ts
@NgModule({
  imports: [CoreModule]  // Import only once
})
export class AppModule {}
```

**Verifying Singleton:**
```typescript
// Component A
export class ComponentA {
  constructor(private service: SingletonService) {
    this.service.setData('from A');
  }
}

// Component B
export class ComponentB {
  constructor(private service: SingletonService) {
    console.log(this.service.getData());  // 'from A' - same instance!
  }
}
```

**Best Practice:** Use `providedIn: 'root'` - it's the simplest and most efficient way.

---

### What is the @Injectable decorator?

**@Injectable** decorator marks a class as available for dependency injection. It tells Angular's DI system that this class can be injected.

**Basic Usage:**
```typescript
@Injectable({
  providedIn: 'root'
})
export class UserService {
  // Service implementation
}
```

**@Injectable is Required When:**
- Service has dependencies (other services injected)
- Service is provided in module/component (not root)

**@Injectable is Optional When:**
- Service has no dependencies
- Service uses `providedIn: 'root'`
- But it's still recommended for consistency

**Example:**
```typescript
// Without dependencies - @Injectable optional but recommended
@Injectable({
  providedIn: 'root'
})
export class SimpleService {
  getData() {
    return 'data';
  }
}

// With dependencies - @Injectable required
@Injectable({
  providedIn: 'root'
})
export class ComplexService {
  constructor(
    private http: HttpClient,      // Requires @Injectable
    private logger: LoggerService  // Requires @Injectable
  ) {}
}
```

**Configuration Options:**
```typescript
@Injectable({
  providedIn: 'root',           // Where to provide
  // OR
  providedIn: 'platform',
  providedIn: 'any'
})
```

**Best Practice:** Always use `@Injectable` decorator for services, even if optional, for consistency and future-proofing.

---

## 🔹 Routing & Navigation

### How do you set up routing in Angular?

**Step 1: Import RouterModule**
```typescript
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'users', component: UserListComponent },
  { path: 'users/:id', component: UserDetailComponent },
  { path: 'about', component: AboutComponent },
  { path: '**', component: NotFoundComponent }  // Wildcard - 404
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],  // forRoot for app routing
  exports: [RouterModule]
})
export class AppRoutingModule {}
```

**Step 2: Import in AppModule**
```typescript
@NgModule({
  imports: [
    BrowserModule,
    AppRoutingModule  // Import routing module
  ],
  // ...
})
export class AppModule {}
```

**Step 3: Add Router Outlet**
```html
<!-- app.component.html -->
<nav>
  <a routerLink="/">Home</a>
  <a routerLink="/users">Users</a>
  <a routerLink="/about">About</a>
</nav>

<router-outlet></router-outlet>  <!-- Where routed components render -->
```

**Step 4: Configure Router Options (Optional)**
```typescript
RouterModule.forRoot(routes, {
  enableTracing: true,           // Debug routing
  useHash: true,                 // Hash location strategy
  preloadingStrategy: PreloadAllModules,  // Preload lazy modules
  scrollPositionRestoration: 'enabled'    // Restore scroll position
})
```

**Complete Example:**
```typescript
// app-routing.module.ts
const routes: Routes = [
  { path: '', redirectTo: '/home', pathMatch: 'full' },
  { path: 'home', component: HomeComponent },
  { path: 'users', loadChildren: () => import('./users/users.module').then(m => m.UsersModule) },
  { path: '**', component: NotFoundComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
```

---

### What is RouterModule?

**RouterModule** is Angular's module that provides routing functionality. It includes directives, services, and configuration.

**Key Components:**
- `RouterModule.forRoot()` - Configures app-level routing
- `RouterModule.forChild()` - Configures feature module routing
- `RouterOutlet` - Directive that displays routed components
- `RouterLink` - Directive for navigation links
- `Router` - Service for programmatic navigation
- `ActivatedRoute` - Service for accessing route information

**forRoot vs forChild:**
```typescript
// App Module - use forRoot (once)
@NgModule({
  imports: [RouterModule.forRoot(routes)]
})
export class AppRoutingModule {}

// Feature Module - use forChild
@NgModule({
  imports: [RouterModule.forChild(featureRoutes)]
})
export class FeatureModule {}
```

**Why forChild?**
- Prevents multiple router instances
- Allows feature modules to define their own routes
- Maintains single router instance

**RouterModule Exports:**
```typescript
// RouterModule automatically exports:
// - RouterOutlet
// - RouterLink
// - RouterLinkActive
// - etc.
```

---

### Explain route parameters (params, query params, route data).

**1. Route Parameters (Path Params)**
```typescript
// Route definition
{ path: 'users/:id', component: UserDetailComponent }
{ path: 'users/:id/posts/:postId', component: PostDetailComponent }

// Accessing in component
import { ActivatedRoute } from '@angular/router';

export class UserDetailComponent implements OnInit {
  userId: number;
  
  constructor(private route: ActivatedRoute) {}
  
  ngOnInit() {
    // Snapshot (one-time)
    this.userId = +this.route.snapshot.paramMap.get('id');
    
    // Observable (updates on route change)
    this.route.paramMap.subscribe(params => {
      this.userId = +params.get('id');
      this.loadUser(this.userId);
    });
    
    // Multiple params
    const id = this.route.snapshot.paramMap.get('id');
    const postId = this.route.snapshot.paramMap.get('postId');
  }
}

// Navigation
this.router.navigate(['/users', 123]);
// OR
<a [routerLink]="['/users', user.id]">View User</a>
```

**2. Query Parameters**
```typescript
// Route definition (no special config needed)
{ path: 'users', component: UserListComponent }

// Accessing in component
export class UserListComponent implements OnInit {
  constructor(
    private route: ActivatedRoute,
    private router: Router
  ) {}
  
  ngOnInit() {
    // Snapshot
    const page = this.route.snapshot.queryParamMap.get('page');
    const sort = this.route.snapshot.queryParamMap.get('sort');
    
    // Observable
    this.route.queryParamMap.subscribe(params => {
      const page = params.get('page');
      const sort = params.get('sort');
      this.loadUsers(page, sort);
    });
  }
  
  updateFilters() {
    // Update query params
    this.router.navigate([], {
      relativeTo: this.route,
      queryParams: { page: 2, sort: 'name' },
      queryParamsHandling: 'merge'  // Merge with existing
    });
  }
}

// Navigation with query params
this.router.navigate(['/users'], { 
  queryParams: { page: 1, sort: 'name' } 
});
// OR
<a [routerLink]="['/users']" [queryParams]="{page: 1, sort: 'name'}">Users</a>
```

**3. Route Data**
```typescript
// Route definition with data
const routes: Routes = [
  {
    path: 'admin',
    component: AdminComponent,
    data: {
      title: 'Admin Panel',
      requiresAuth: true,
      roles: ['admin']
    }
  },
  {
    path: 'users',
    component: UserListComponent,
    data: {
      pageTitle: 'User Management',
      breadcrumb: 'Users'
    }
  }
];

// Accessing in component
export class AdminComponent implements OnInit {
  constructor(private route: ActivatedRoute) {}
  
  ngOnInit() {
    // Snapshot
    const title = this.route.snapshot.data['title'];
    const requiresAuth = this.route.snapshot.data['requiresAuth'];
    
    // Observable
    this.route.data.subscribe(data => {
      console.log(data.title);
      console.log(data.requiresAuth);
    });
  }
}

// Accessing in resolver
export class UserResolver implements Resolve<User> {
  resolve(route: ActivatedRouteSnapshot): Observable<User> {
    const userId = route.paramMap.get('id');
    const data = route.data;  // Access route data
    return this.userService.getUser(userId);
  }
}
```

**Summary:**

| Type | Syntax | Use Case | Access Method |
|------|--------|----------|---------------|
| **Path Params** | `/users/:id` | Required identifiers | `paramMap.get('id')` |
| **Query Params** | `?page=1&sort=name` | Optional filters | `queryParamMap.get('page')` |
| **Route Data** | `data: {...}` | Static metadata | `data['key']` |

---

### What is the difference between routerLink and router.navigate()?

**routerLink**: Directive for template-based navigation
**router.navigate()**: Method for programmatic navigation

**routerLink Example:**
```html
<!-- Basic navigation -->
<a routerLink="/users">Users</a>

<!-- With parameters -->
<a [routerLink]="['/users', userId]">View User</a>

<!-- With query params -->
<a [routerLink]="['/users']" [queryParams]="{page: 1}">Users</a>

<!-- With fragment -->
<a [routerLink]="['/users']" fragment="top">Go to Top</a>

<!-- Relative navigation -->
<a [routerLink]="['../users']">Users</a>

<!-- Active link styling -->
<a routerLink="/users" routerLinkActive="active">Users</a>
```

**router.navigate() Example:**
```typescript
export class UserComponent {
  constructor(private router: Router) {}
  
  navigateToUser(userId: number) {
    // Absolute path
    this.router.navigate(['/users', userId]);
    
    // With query params
    this.router.navigate(['/users'], {
      queryParams: { page: 1, sort: 'name' }
    });
    
    // Relative navigation
    this.router.navigate(['../users'], { relativeTo: this.route });
    
    // With options
    this.router.navigate(['/users'], {
      queryParams: { page: 1 },
      queryParamsHandling: 'merge',  // or 'preserve'
      fragment: 'top',
      preserveFragment: true
    });
  }
}
```

**Key Differences:**

| Feature | routerLink | router.navigate() |
|---------|------------|-------------------|
| **Location** | Template | TypeScript code |
| **Use Case** | User clicks, static links | Conditional navigation, after actions |
| **Type Safety** | String-based | Array-based (type-safe) |
| **Dynamic** | Can be dynamic with binding | Fully programmatic |

**When to Use:**

**Use routerLink when:**
- Navigation from template (links, buttons)
- Static or simple navigation
- User-initiated navigation

**Use router.navigate() when:**
- Navigation after form submission
- Conditional navigation (guards, errors)
- Navigation from service/utility
- Complex navigation logic

**Best Practice:** Use `routerLink` in templates, `router.navigate()` in component logic.

---

### What are route guards? Name the types.

**Route Guards** are interfaces that control navigation to/from routes. They're used for authentication, authorization, and data loading.

**Types of Guards:**

1. **CanActivate** - Controls route activation
2. **CanActivateChild** - Controls child route activation
3. **CanDeactivate** - Controls route deactivation (e.g., unsaved changes)
4. **CanLoad** - Controls lazy module loading
5. **Resolve** - Pre-fetch data before route activation

**1. CanActivate Example:**
```typescript
@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}
  
  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): boolean | Observable<boolean> | Promise<boolean> {
    if (this.authService.isAuthenticated()) {
      return true;
    }
    
    this.router.navigate(['/login'], {
      queryParams: { returnUrl: state.url }
    });
    return false;
  }
}

// Usage
{ path: 'admin', component: AdminComponent, canActivate: [AuthGuard] }
```

**2. CanActivateChild Example:**
```typescript
@Injectable({ providedIn: 'root' })
export class AdminGuard implements CanActivateChild {
  canActivateChild(
    childRoute: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): boolean {
    return this.authService.hasRole('admin');
  }
}

// Usage
{
  path: 'admin',
  canActivateChild: [AdminGuard],
  children: [
    { path: 'users', component: UsersComponent },
    { path: 'settings', component: SettingsComponent }
  ]
}
```

**3. CanDeactivate Example:**
```typescript
export interface CanComponentDeactivate {
  canDeactivate(): boolean | Observable<boolean>;
}

@Injectable({ providedIn: 'root' })
export class UnsavedChangesGuard implements CanDeactivate<CanComponentDeactivate> {
  canDeactivate(
    component: CanComponentDeactivate
  ): boolean | Observable<boolean> {
    return component.canDeactivate ? component.canDeactivate() : true;
  }
}

// Component
export class UserFormComponent implements CanComponentDeactivate {
  hasUnsavedChanges = false;
  
  canDeactivate(): boolean {
    if (this.hasUnsavedChanges) {
      return confirm('You have unsaved changes. Leave?');
    }
    return true;
  }
}

// Usage
{ path: 'user/edit', component: UserFormComponent, canDeactivate: [UnsavedChangesGuard] }
```

**4. CanLoad Example:**
```typescript
@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanLoad {
  constructor(private authService: AuthService) {}
  
  canLoad(route: Route): boolean {
    return this.authService.isAuthenticated();
  }
}

// Usage
{
  path: 'admin',
  loadChildren: () => import('./admin/admin.module').then(m => m.AdminModule),
  canLoad: [AuthGuard]  // Prevents module loading if not authenticated
}
```

**5. Resolve Example:**
```typescript
@Injectable({ providedIn: 'root' })
export class UserResolver implements Resolve<User> {
  constructor(private userService: UserService) {}
  
  resolve(route: ActivatedRouteSnapshot): Observable<User> {
    const userId = route.paramMap.get('id');
    return this.userService.getUser(+userId);
  }
}

// Usage
{
  path: 'users/:id',
  component: UserDetailComponent,
  resolve: { user: UserResolver }  // Data available in route.data
}

// Component
export class UserDetailComponent implements OnInit {
  constructor(private route: ActivatedRoute) {}
  
  ngOnInit() {
    // Data pre-loaded by resolver
    this.user = this.route.snapshot.data['user'];
  }
}
```

---

### How do you implement route guards?

**Step 1: Create Guard Service**
```typescript
import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}
  
  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): boolean | Observable<boolean> | Promise<boolean> {
    // Synchronous check
    if (this.authService.isAuthenticated()) {
      return true;
    }
    
    // Redirect to login
    this.router.navigate(['/login'], {
      queryParams: { returnUrl: state.url }
    });
    return false;
    
    // OR Asynchronous check
    // return this.authService.checkAuth().pipe(
    //   map(isAuth => {
    //     if (isAuth) return true;
    //     this.router.navigate(['/login']);
    //     return false;
    //   })
    // );
  }
}
```

**Step 2: Register Guard in Routes**
```typescript
const routes: Routes = [
  {
    path: 'admin',
    component: AdminComponent,
    canActivate: [AuthGuard, RoleGuard]  // Multiple guards (all must pass)
  },
  {
    path: 'profile',
    component: ProfileComponent,
    canActivate: [AuthGuard],
    canDeactivate: [UnsavedChangesGuard]
  }
];
```

**Step 3: Provide Guards (if not using providedIn: 'root')**
```typescript
@NgModule({
  providers: [AuthGuard, RoleGuard]
})
export class AppModule {}
```

**Advanced: Guard with Async Check**
```typescript
@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}
  
  canActivate(): Observable<boolean> {
    return this.authService.isAuthenticated$().pipe(
      take(1),
      map(authenticated => {
        if (authenticated) {
          return true;
        }
        this.router.navigate(['/login']);
        return false;
      })
    );
  }
}
```

**Multiple Guards:**
```typescript
// All guards must return true
{
  path: 'admin',
  canActivate: [AuthGuard, RoleGuard, PermissionGuard],
  // Executed in order: AuthGuard → RoleGuard → PermissionGuard
}
```

---

### What is lazy loading?

**Lazy Loading** loads feature modules on-demand instead of at application startup, improving initial load time.

**Benefits:**
- Faster initial load
- Smaller initial bundle
- Better performance
- Code splitting

**How it Works:**
```typescript
// Instead of eager loading:
import { UsersModule } from './users/users.module';

@NgModule({
  imports: [UsersModule]  // Loaded immediately
})

// Use lazy loading:
const routes: Routes = [
  {
    path: 'users',
    loadChildren: () => import('./users/users.module').then(m => m.UsersModule)
  }
];
```

**Lazy Loading Flow:**
1. User navigates to `/users`
2. Angular loads `UsersModule` dynamically
3. Module is loaded and routes are registered
4. Component is rendered

---

### How do you implement lazy loading?

**Step 1: Create Feature Module with Routing**
```typescript
// users/users-routing.module.ts
const routes: Routes = [
  { path: '', component: UserListComponent },
  { path: ':id', component: UserDetailComponent }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],  // forChild, not forRoot!
  exports: [RouterModule]
})
export class UsersRoutingModule {}
```

**Step 2: Create Feature Module**
```typescript
// users/users.module.ts
@NgModule({
  declarations: [UserListComponent, UserDetailComponent],
  imports: [
    CommonModule,
    UsersRoutingModule  // Import routing module
  ]
})
export class UsersModule {}
```

**Step 3: Configure Lazy Loading in App Routing**
```typescript
// app-routing.module.ts
const routes: Routes = [
  { path: '', component: HomeComponent },
  {
    path: 'users',
    loadChildren: () => import('./users/users.module').then(m => m.UsersModule)
  },
  {
    path: 'products',
    loadChildren: () => import('./products/products.module').then(m => m.ProductsModule)
  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
```

**Step 4: Verify Lazy Loading**
```typescript
// Check Network tab - you'll see separate chunk files:
// - main.js (initial bundle)
// - users-users-module.js (loaded on demand)
// - products-products-module.js (loaded on demand)
```

**Preloading Strategy:**
```typescript
// Preload all modules after initial load
RouterModule.forRoot(routes, {
  preloadingStrategy: PreloadAllModules
})

// Custom preloading
@Injectable()
export class CustomPreloadStrategy implements PreloadingStrategy {
  preload(route: Route, load: () => Observable<any>): Observable<any> {
    if (route.data && route.data['preload']) {
      return load();
    }
    return of(null);
  }
}

// Usage
{
  path: 'users',
  loadChildren: () => import('./users/users.module').then(m => m.UsersModule),
  data: { preload: true }
}
```

**Best Practices:**
- Use `forChild()` in feature modules
- Don't import lazy modules in AppModule
- Use preloading for better UX
- Group related routes in feature modules

---

### What is ActivatedRoute?

**ActivatedRoute** is a service that provides access to route information (params, query params, data, etc.) for the currently activated route.

**Key Properties:**
- `paramMap` - Route parameters
- `queryParamMap` - Query parameters
- `data` - Route data
- `snapshot` - Current route snapshot
- `params` - Route parameters (deprecated, use paramMap)
- `queryParams` - Query parameters (deprecated, use queryParamMap)

**Example:**
```typescript
import { ActivatedRoute } from '@angular/router';

export class UserDetailComponent implements OnInit {
  userId: number;
  user: User;
  
  constructor(
    private route: ActivatedRoute,
    private userService: UserService
  ) {}
  
  ngOnInit() {
    // Snapshot (one-time, use when component won't be reused)
    this.userId = +this.route.snapshot.paramMap.get('id');
    
    // Observable (use when component can be reused with different params)
    this.route.paramMap.subscribe(params => {
      this.userId = +params.get('id');
      this.loadUser(this.userId);
    });
    
    // Query params
    const page = this.route.snapshot.queryParamMap.get('page');
    
    // Route data
    this.user = this.route.snapshot.data['user'];  // From resolver
  }
}
```

**When to use Snapshot vs Observable:**

**Use Snapshot when:**
- Component is created/destroyed on navigation
- One-time parameter access
- Simpler code

**Use Observable when:**
- Component is reused (same component, different params)
- Need to react to parameter changes
- Example: `/users/1` → `/users/2` (same component)

**Example with Observable:**
```typescript
export class UserDetailComponent implements OnInit, OnDestroy {
  private subscription: Subscription;
  
  ngOnInit() {
    // React to route changes
    this.subscription = this.route.paramMap.pipe(
      switchMap(params => {
        const id = +params.get('id');
        return this.userService.getUser(id);
      })
    ).subscribe(user => {
      this.user = user;
    });
  }
  
  ngOnDestroy() {
    this.subscription?.unsubscribe();
  }
}
```

---

### What is the difference between canActivate and canActivateChild?

**canActivate**: Guards the route itself
**canActivateChild**: Guards child routes of the route

**canActivate Example:**
```typescript
const routes: Routes = [
  {
    path: 'admin',
    component: AdminComponent,
    canActivate: [AuthGuard]  // Guards /admin route
  }
];
```

**canActivateChild Example:**
```typescript
const routes: Routes = [
  {
    path: 'admin',
    component: AdminComponent,
    canActivateChild: [AdminGuard],  // Guards child routes
    children: [
      { path: 'users', component: UsersComponent },      // Protected
      { path: 'settings', component: SettingsComponent } // Protected
    ]
  }
];
```

**Key Differences:**

| Feature | canActivate | canActivateChild |
|---------|-------------|------------------|
| **Guards** | The route itself | Child routes only |
| **Use Case** | Protect specific route | Protect all child routes |
| **Component** | Route component | Child route components |

**When to Use:**

**Use canActivate when:**
- Protecting a specific route
- Route has no children
- Simple protection

**Use canActivateChild when:**
- Protecting all child routes
- Parent route is a container
- Want to protect children without protecting parent

**Combined Example:**
```typescript
{
  path: 'admin',
  component: AdminComponent,
  canActivate: [AuthGuard],        // Must be authenticated to access /admin
  canActivateChild: [AdminGuard],  // Must be admin for child routes
  children: [
    { path: 'users', component: UsersComponent },
    { path: 'settings', component: SettingsComponent }
  ]
}
```

**Best Practice:** Use `canActivateChild` when you have a parent route with multiple child routes that need the same protection.

