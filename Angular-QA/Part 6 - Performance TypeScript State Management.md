# Angular Q&A - Part 6: Performance, TypeScript, State Management & Miscellaneous

## 🔹 Performance & Best Practices

### How do you optimize Angular application performance?

**Performance Optimization Strategies:**

**1. OnPush Change Detection**
```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserComponent {
  @Input() user: User;  // Only checks when reference changes
}
```
- Reduces change detection cycles
- Use immutable data patterns

**2. Lazy Loading**
```typescript
{
  path: 'users',
  loadChildren: () => import('./users/users.module').then(m => m.UsersModule)
}
```
- Load modules on demand
- Smaller initial bundle

**3. TrackBy Function**
```typescript
trackByUserId(index: number, user: User): number {
  return user.id;
}
```
```html
<div *ngFor="let user of users; trackBy: trackByUserId">
```
- Prevents unnecessary DOM updates

**4. Async Pipe**
```html
<div>{{ data$ | async }}</div>
```
- Automatic subscription management
- Works with OnPush

**5. Virtual Scrolling**
```typescript
import { ScrollingModule } from '@angular/cdk/scrolling';
```
```html
<cdk-virtual-scroll-viewport itemSize="50">
  <div *cdkVirtualFor="let user of users">{{user.name}}</div>
</cdk-virtual-scroll-viewport>
```
- Renders only visible items

**6. Tree Shaking**
```typescript
// Import only what you need
import { map } from 'rxjs/operators';
// Not: import * as operators from 'rxjs/operators';
```

**7. AOT Compilation**
```bash
ng build --prod  # AOT by default
```
- Smaller bundle
- Faster rendering

**8. Production Build**
```bash
ng build --prod --aot --build-optimizer
```
- Minification
- Dead code elimination
- Optimizations

**9. Bundle Analysis**
```bash
ng build --stats-json
npx webpack-bundle-analyzer dist/stats.json
```
- Identify large dependencies
- Optimize imports

**10. Image Optimization**
- Use WebP format
- Lazy load images
- Use CDN

**11. Service Worker (PWA)**
```bash
ng add @angular/pwa
```
- Caching
- Offline support
- Faster subsequent loads

**12. Avoid Heavy Computations in Templates**
```typescript
// ❌ Bad: Computed in template
<div>{{ expensiveComputation() }}</div>

// ✅ Good: Computed in component
get computedValue() {
  return this.expensiveComputation();
}

// ✅ Better: Use memoization
private _computedValue: any;
get computedValue() {
  if (!this._computedValue) {
    this._computedValue = this.expensiveComputation();
  }
  return this._computedValue;
}
```

---

### What is OnPush change detection strategy?

**OnPush Change Detection** is a strategy that only checks components when:
- Input reference changes
- Event originates from component
- Observable emits (with async pipe)
- Manual trigger (markForCheck, detectChanges)

**Benefits:**
- Better performance
- Predictable change detection
- Encourages immutable patterns

**Implementation:**
```typescript
@Component({
  selector: 'app-user',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: '<div>{{user.name}}</div>'
})
export class UserComponent {
  @Input() user: User;
}
```

**Requirements:**
- Use immutable data
- New object references for changes
- Use async pipe for Observables

**Example:**
```typescript
// ❌ Bad: Mutation (OnPush won't detect)
this.user.name = 'New Name';

// ✅ Good: New reference (OnPush detects)
this.user = { ...this.user, name: 'New Name' };
```

---

### How do you implement lazy loading?

**Lazy Loading Implementation:**

**Step 1: Create Feature Module**
```typescript
// users/users.module.ts
@NgModule({
  declarations: [UserListComponent],
  imports: [UsersRoutingModule]
})
export class UsersModule {}
```

**Step 2: Create Feature Routing**
```typescript
// users/users-routing.module.ts
const routes: Routes = [
  { path: '', component: UserListComponent }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class UsersRoutingModule {}
```

**Step 3: Configure Lazy Loading**
```typescript
// app-routing.module.ts
const routes: Routes = [
  {
    path: 'users',
    loadChildren: () => import('./users/users.module').then(m => m.UsersModule)
  }
];
```

**Preloading Strategy:**
```typescript
RouterModule.forRoot(routes, {
  preloadingStrategy: PreloadAllModules
})
```

---

### What are the best practices for Angular development?

**Angular Best Practices:**

**1. Use TypeScript Strict Mode**
```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true
  }
}
```

**2. Use providedIn: 'root' for Services**
```typescript
@Injectable({ providedIn: 'root' })
export class UserService {}
```

**3. Use Reactive Forms**
```typescript
// Prefer reactive forms over template-driven
this.form = this.fb.group({...});
```

**4. Use Async Pipe**
```html
<div>{{ data$ | async }}</div>
```

**5. Unsubscribe Properly**
```typescript
// Use takeUntil pattern
private destroy$ = new Subject<void>();

ngOnInit() {
  this.data$.pipe(takeUntil(this.destroy$)).subscribe();
}

ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

**6. Use OnPush for Leaf Components**
```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush
})
```

**7. Use TrackBy with *ngFor**
```html
<div *ngFor="let item of items; trackBy: trackById">
```

**8. Avoid Logic in Templates**
```typescript
// ❌ Bad
<div>{{ computeValue() }}</div>

// ✅ Good
get computedValue() { return this.compute(); }
```

**9. Use Interfaces for Types**
```typescript
export interface User {
  id: number;
  name: string;
}
```

**10. Organize Code Structure**
```
feature/
  ├── feature.module.ts
  ├── feature-routing.module.ts
  ├── components/
  ├── services/
  └── models/
```

**11. Use Environment Files**
```typescript
// environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000'
};
```

**12. Handle Errors Properly**
```typescript
this.http.get('/api/users').pipe(
  catchError(error => {
    this.handleError(error);
    return of([]);
  })
).subscribe();
```

---

### How do you handle memory leaks in Angular?

**Memory Leak Prevention:**

**1. Unsubscribe from Observables**
```typescript
export class UserComponent implements OnInit, OnDestroy {
  private subscription: Subscription;
  
  ngOnInit() {
    this.subscription = this.data$.subscribe();
  }
  
  ngOnDestroy() {
    this.subscription?.unsubscribe();
  }
}
```

**2. Use takeUntil Pattern**
```typescript
private destroy$ = new Subject<void>();

ngOnInit() {
  this.data1$.pipe(takeUntil(this.destroy$)).subscribe();
  this.data2$.pipe(takeUntil(this.destroy$)).subscribe();
}

ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

**3. Use Async Pipe**
```html
<div>{{ data$ | async }}</div>
```
- Automatic unsubscription

**4. Clear Timers**
```typescript
private timer: any;

ngOnInit() {
  this.timer = setInterval(() => {
    // Do work
  }, 1000);
}

ngOnDestroy() {
  clearInterval(this.timer);
}
```

**5. Remove Event Listeners**
```typescript
@HostListener('window:resize', ['$event'])
onResize(event: Event) {
  // Handled by Angular
}

// Manual listeners
ngOnInit() {
  this.resizeListener = () => this.onResize();
  window.addEventListener('resize', this.resizeListener);
}

ngOnDestroy() {
  window.removeEventListener('resize', this.resizeListener);
}
```

**6. Clear References**
```typescript
ngOnDestroy() {
  this.data = null;
  this.users = [];
  this.subscription = null;
}
```

---

### What is tree-shaking?

**Tree Shaking** is the process of removing unused code from the final bundle.

**How it Works:**
- Analyzes import/export statements
- Removes unused code
- Reduces bundle size

**Example:**
```typescript
// ❌ Bad: Imports entire library
import * as _ from 'lodash';
const result = _.map([1, 2, 3], x => x * 2);

// ✅ Good: Imports only what's needed
import { map } from 'lodash';
const result = map([1, 2, 3], x => x * 2);
```

**Angular Tree Shaking:**
- AOT compilation enables tree shaking
- providedIn: 'root' is tree-shakeable
- ES6 modules support tree shaking

**Best Practices:**
- Use ES6 imports/exports
- Avoid side effects in modules
- Use providedIn: 'root'
- Import only what you need

---

### How do you reduce bundle size?

**Bundle Size Reduction:**

**1. Lazy Loading**
```typescript
loadChildren: () => import('./feature/feature.module').then(m => m.FeatureModule)
```

**2. Tree Shaking**
- Import only what you need
- Use providedIn: 'root'

**3. Production Build**
```bash
ng build --prod
```
- Minification
- Dead code elimination

**4. Analyze Bundle**
```bash
ng build --stats-json
npx webpack-bundle-analyzer dist/stats.json
```

**5. Remove Unused Dependencies**
```bash
npm uninstall unused-package
```

**6. Use CDN for Large Libraries**
```html
<script src="https://cdn.jsdelivr.net/npm/lodash@4.17.21/lodash.min.js"></script>
```

**7. Code Splitting**
- Feature modules
- Route-based splitting

**8. Optimize Images**
- Use WebP
- Compress images
- Lazy load

**9. Gzip Compression**
- Server-side compression
- Reduces transfer size

---

## 🔹 TypeScript & Angular

### What TypeScript features are important for Angular?

**Key TypeScript Features:**

**1. Types and Interfaces**
```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

const user: User = { id: 1, name: 'John', email: 'john@example.com' };
```

**2. Classes**
```typescript
export class UserComponent {
  user: User;
  
  constructor(private userService: UserService) {}
}
```

**3. Decorators**
```typescript
@Component({...})
@Injectable({...})
@Input()
@Output()
```

**4. Generics**
```typescript
interface ApiResponse<T> {
  data: T;
  status: number;
}

const response: ApiResponse<User> = {
  data: user,
  status: 200
};
```

**5. Access Modifiers**
```typescript
export class UserService {
  private users: User[] = [];
  public getUsers(): User[] { return this.users; }
  protected validate(user: User): boolean { return true; }
}
```

**6. Optional Chaining**
```typescript
const name = user?.profile?.name;
```

**7. Nullish Coalescing**
```typescript
const name = user?.name ?? 'Unknown';
```

**8. Async/Await**
```typescript
async loadUser() {
  this.user = await this.userService.getUser(1).toPromise();
}
```

**9. Enums**
```typescript
enum UserRole {
  Admin = 'admin',
  User = 'user'
}
```

**10. Type Assertions**
```typescript
const element = document.getElementById('input') as HTMLInputElement;
```

---

### What are interfaces and when to use them?

**Interfaces** define the shape of objects and provide type checking.

**Basic Interface:**
```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

const user: User = {
  id: 1,
  name: 'John',
  email: 'john@example.com'
};
```

**Optional Properties:**
```typescript
interface User {
  id: number;
  name: string;
  email?: string;  // Optional
}
```

**Readonly Properties:**
```typescript
interface User {
  readonly id: number;  // Cannot be modified
  name: string;
}
```

**Extending Interfaces:**
```typescript
interface Person {
  name: string;
  age: number;
}

interface User extends Person {
  email: string;
  role: string;
}
```

**When to Use:**
- Define data models
- Type function parameters
- Type API responses
- Type component inputs/outputs
- Define contracts

**Example:**
```typescript
// API Response
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}

// Component Input
export interface UserInput {
  name: string;
  email: string;
}

@Component({...})
export class UserFormComponent {
  @Input() user: UserInput;
}
```

---

### What are generics in TypeScript?

**Generics** allow creating reusable components that work with multiple types.

**Basic Generic:**
```typescript
function identity<T>(arg: T): T {
  return arg;
}

const number = identity<number>(42);
const string = identity<string>('hello');
```

**Generic Interface:**
```typescript
interface Repository<T> {
  findById(id: number): T;
  findAll(): T[];
  save(entity: T): T;
}

class UserRepository implements Repository<User> {
  findById(id: number): User { /* ... */ }
  findAll(): User[] { /* ... */ }
  save(user: User): User { /* ... */ }
}
```

**Generic Class:**
```typescript
class DataService<T> {
  private data: T[] = [];
  
  add(item: T): void {
    this.data.push(item);
  }
  
  getAll(): T[] {
    return this.data;
  }
}

const userService = new DataService<User>();
const productService = new DataService<Product>();
```

**Generic Constraints:**
```typescript
interface HasId {
  id: number;
}

function findById<T extends HasId>(items: T[], id: number): T | undefined {
  return items.find(item => item.id === id);
}
```

**Angular Examples:**
```typescript
// HTTP
this.http.get<User[]>('/api/users');

// Observable
const users$: Observable<User[]> = this.userService.getUsers();

// FormControl
const control = new FormControl<User>(null);
```

---

## 🔹 State Management

### How do you manage state in Angular applications?

**State Management Approaches:**

**1. Component State (Simple)**
```typescript
export class UserComponent {
  users: User[] = [];
  selectedUser: User;
  
  loadUsers() {
    this.userService.getUsers().subscribe(users => {
      this.users = users;
    });
  }
}
```

**2. Service with BehaviorSubject**
```typescript
@Injectable({ providedIn: 'root' })
export class UserStateService {
  private usersSubject = new BehaviorSubject<User[]>([]);
  users$ = this.usersSubject.asObservable();
  
  setUsers(users: User[]) {
    this.usersSubject.next(users);
  }
  
  addUser(user: User) {
    const current = this.usersSubject.value;
    this.usersSubject.next([...current, user]);
  }
}
```

**3. NgRx (Redux Pattern)**
```typescript
// Actions
export const loadUsers = createAction('[User] Load Users');
export const loadUsersSuccess = createAction(
  '[User] Load Users Success',
  props<{ users: User[] }>()
);

// Reducer
export const userReducer = createReducer(
  initialState,
  on(loadUsersSuccess, (state, { users }) => ({
    ...state,
    users
  }))
);

// Selector
export const selectUsers = createSelector(
  selectUserState,
  state => state.users
);
```

**4. Akita (Alternative State Management)**
```typescript
@StoreConfig({ name: 'users' })
export class UsersStore extends EntityStore<UsersState> {
  constructor() {
    super();
  }
}
```

**When to Use:**
- **Component State**: Simple, local state
- **Service State**: Shared state, medium complexity
- **NgRx**: Complex state, time-travel debugging, large apps
- **Akita**: Simpler than NgRx, good DX

---

### What is NgRx? When would you use it?

**NgRx** is a state management library for Angular based on Redux pattern.

**Core Concepts:**
- **Store**: Single source of truth
- **Actions**: Events that trigger state changes
- **Reducers**: Pure functions that update state
- **Effects**: Handle side effects (HTTP, etc.)
- **Selectors**: Query state

**When to Use NgRx:**
- Complex application state
- Multiple components need same state
- Time-travel debugging needed
- Predictable state updates
- Large team collaboration

**Basic Example:**
```typescript
// Actions
export const loadUsers = createAction('[User] Load Users');
export const loadUsersSuccess = createAction(
  '[User] Load Users Success',
  props<{ users: User[] }>()
);

// Reducer
export const userReducer = createReducer(
  { users: [] },
  on(loadUsersSuccess, (state, { users }) => ({
    ...state,
    users
  }))
);

// Effects
export const loadUsers$ = createEffect(() =>
  this.actions$.pipe(
    ofType(loadUsers),
    switchMap(() =>
      this.userService.getUsers().pipe(
        map(users => loadUsersSuccess({ users }))
      )
    )
  )
);

// Component
export class UserComponent {
  users$ = this.store.select(selectUsers);
  
  constructor(private store: Store) {}
  
  loadUsers() {
    this.store.dispatch(loadUsers());
  }
}
```

**When NOT to Use:**
- Simple applications
- Small state
- Overhead not justified
- Team unfamiliar with Redux

---

### What are Actions, Reducers, Effects, and Selectors in NgRx?

**Actions**: Events that describe state changes
```typescript
export const loadUsers = createAction('[User] Load Users');
export const loadUsersSuccess = createAction(
  '[User] Load Users Success',
  props<{ users: User[] }>()
);
export const loadUsersFailure = createAction(
  '[User] Load Users Failure',
  props<{ error: string }>()
);
```

**Reducers**: Pure functions that update state
```typescript
export interface UserState {
  users: User[];
  loading: boolean;
  error: string | null;
}

export const userReducer = createReducer(
  { users: [], loading: false, error: null },
  on(loadUsers, state => ({ ...state, loading: true })),
  on(loadUsersSuccess, (state, { users }) => ({
    ...state,
    users,
    loading: false
  })),
  on(loadUsersFailure, (state, { error }) => ({
    ...state,
    error,
    loading: false
  }))
);
```

**Effects**: Handle side effects (HTTP, etc.)
```typescript
export class UserEffects {
  loadUsers$ = createEffect(() =>
    this.actions$.pipe(
      ofType(loadUsers),
      switchMap(() =>
        this.userService.getUsers().pipe(
          map(users => loadUsersSuccess({ users })),
          catchError(error => of(loadUsersFailure({ error: error.message })))
        )
      )
    )
  );
  
  constructor(
    private actions$: Actions,
    private userService: UserService
  ) {}
}
```

**Selectors**: Query state
```typescript
export const selectUserState = (state: AppState) => state.users;

export const selectUsers = createSelector(
  selectUserState,
  state => state.users
);

export const selectLoading = createSelector(
  selectUserState,
  state => state.loading
);
```

---

## 🔹 Miscellaneous

### What is Angular CLI?

**Angular CLI** is a command-line interface for Angular development.

**Common Commands:**
```bash
# Create new project
ng new my-app

# Generate component
ng generate component user
ng g c user

# Generate service
ng generate service user
ng g s user

# Generate module
ng generate module users
ng g m users

# Generate directive
ng generate directive highlight
ng g d highlight

# Generate pipe
ng generate pipe uppercase
ng g p uppercase

# Build
ng build
ng build --prod

# Serve
ng serve
ng serve --port 4200

# Test
ng test
ng test --code-coverage

# Lint
ng lint

# Update
ng update
ng update @angular/core @angular/cli
```

**Configuration:**
- `angular.json` - Project configuration
- `tsconfig.json` - TypeScript configuration
- `package.json` - Dependencies

---

### How do you build an Angular application for production?

**Production Build:**
```bash
# Basic production build
ng build --prod

# With additional optimizations
ng build --prod --aot --build-optimizer

# Output to specific directory
ng build --prod --output-path=dist/prod
```

**Build Optimizations:**
- AOT compilation
- Minification
- Tree shaking
- Dead code elimination
- Bundle optimization

**Environment Configuration:**
```typescript
// environment.prod.ts
export const environment = {
  production: true,
  apiUrl: 'https://api.production.com'
};
```

---

### What is environment.ts?

**environment.ts** files store environment-specific configuration.

**Structure:**
```typescript
// environment.ts (development)
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000',
  enableLogging: true
};

// environment.prod.ts (production)
export const environment = {
  production: true,
  apiUrl: 'https://api.production.com',
  enableLogging: false
};
```

**Usage:**
```typescript
import { environment } from '../environments/environment';

if (environment.production) {
  // Production code
}

this.http.get(`${environment.apiUrl}/users`);
```

**File Replacement:**
Angular automatically uses `environment.prod.ts` in production builds.

---

### What are Angular schematics?

**Schematics** are code generators that create and modify files.

**Built-in Schematics:**
```bash
ng generate component user
ng generate service user
ng generate module users
ng generate directive highlight
ng generate pipe uppercase
ng generate guard auth
ng generate interceptor auth
```

**Custom Schematics:**
```bash
ng generate @my-org/my-schematic:my-feature
```

**Collection:**
```json
{
  "$schema": "../node_modules/@angular-devkit/schematics/collection-schema.json",
  "schematics": {
    "my-schematic": {
      "description": "My custom schematic",
      "factory": "./my-schematic/index#mySchematic"
    }
  }
}
```

---

### How do you handle internationalization (i18n)?

**Angular i18n Setup:**

**1. Extract Messages**
```bash
ng xi18n --output-path locale
```

**2. Translate Messages**
```xml
<!-- messages.xlf -->
<trans-unit id="greeting">
  <source>Hello</source>
  <target>Hola</target>
</trans-unit>
```

**3. Build for Locale**
```bash
ng build --prod --i18n-file=locale/messages.es.xlf --i18n-locale=es --i18n-format=xlf
```

**4. Use in Templates**
```html
<h1 i18n="@@greeting">Hello</h1>
```

**Alternative: ngx-translate**
```typescript
// Install
npm install @ngx-translate/core @ngx-translate/http-loader

// Setup
import { TranslateModule, TranslateLoader } from '@ngx-translate/core';
import { HttpClient } from '@angular/common/http';

export function HttpLoaderFactory(http: HttpClient) {
  return new TranslateHttpLoader(http);
}

@NgModule({
  imports: [
    TranslateModule.forRoot({
      loader: {
        provide: TranslateLoader,
        useFactory: HttpLoaderFactory,
        deps: [HttpClient]
      }
    })
  ]
})
```

**Usage:**
```html
<h1>{{ 'greeting' | translate }}</h1>
```

```typescript
this.translate.get('greeting').subscribe(text => {
  console.log(text);
});
```

---

### What is the difference between ng serve and ng build?

**ng serve:**
- Development server
- Watches files for changes
- Hot module replacement
- JIT compilation
- Not optimized
- Runs continuously

**ng build:**
- Production build
- Creates output files
- AOT compilation
- Optimized
- One-time execution

**Comparison:**

| Feature | ng serve | ng build |
|---------|----------|----------|
| **Purpose** | Development | Production |
| **Output** | In-memory | dist/ folder |
| **Optimization** | None | Full |
| **AOT** | No (JIT) | Yes |
| **Watching** | Yes | No |
| **Speed** | Fast rebuild | Slower build |

---

### How do you debug Angular applications?

**Debugging Methods:**

**1. Browser DevTools**
- Chrome DevTools
- Angular DevTools extension
- Network tab
- Console

**2. Source Maps**
```typescript
// tsconfig.json
{
  "compilerOptions": {
    "sourceMap": true
  }
}
```

**3. Augury (Angular DevTools)**
- Component tree
- Router tree
- NgModules

**4. Console Logging**
```typescript
console.log('Debug:', this.user);
console.table(this.users);
```

**5. Breakpoints**
- VS Code debugger
- Browser DevTools
- `debugger;` statement

**6. Angular Error Handler**
```typescript
@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  handleError(error: any): void {
    console.error('Error:', error);
    // Log to service
  }
}
```

**7. RxJS Debugging**
```typescript
this.data$.pipe(
  tap(data => console.log('Data:', data)),
  catchError(error => {
    console.error('Error:', error);
    return throwError(() => error);
  })
).subscribe();
```

**8. Change Detection Debugging**
```typescript
import { ApplicationRef } from '@angular/core';

constructor(private appRef: ApplicationRef) {
  // Enable change detection debugging
  this.appRef.tick();
}
```

**9. Network Debugging**
- Chrome DevTools Network tab
- HTTP interceptors with logging

**10. State Debugging (NgRx)**
- Redux DevTools
- Store inspection

