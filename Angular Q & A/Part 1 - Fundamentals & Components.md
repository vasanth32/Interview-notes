# Angular Q&A - Part 1: Fundamentals & Components

## 🔹 Angular Fundamentals

### What is Angular, and how does it differ from AngularJS?

**Angular** (v2+) is a modern TypeScript-based framework for building single-page applications (SPAs). It's a complete rewrite of AngularJS with significant architectural changes.

**Key Differences:**

1. **Language**: Angular uses TypeScript (with optional ES6+), while AngularJS uses JavaScript
2. **Architecture**: Angular uses component-based architecture; AngularJS uses MVC/MVVM
3. **Performance**: Angular has better performance with change detection, AOT compilation, and tree-shaking
4. **Mobile**: Angular has better mobile support with Angular Mobile Toolkit
5. **Dependency Injection**: Angular uses hierarchical DI; AngularJS uses string-based DI
6. **Directives**: Angular separates structural (*ngIf, *ngFor) and attribute directives
7. **Routing**: Angular uses @angular/router (more powerful); AngularJS uses ngRoute or ui-router

**Practical Example:**
```typescript
// AngularJS (old way)
app.controller('UserController', function($scope) {
  $scope.users = [];
});

// Angular (modern way)
@Component({
  selector: 'app-user',
  template: '<div *ngFor="let user of users">{{user.name}}</div>'
})
export class UserComponent {
  users: User[] = [];
}
```

---

### Explain the Angular architecture and core concepts.

Angular follows a **component-based architecture** with a clear separation of concerns:

**Core Concepts:**

1. **Components**: Building blocks that control a view
   - Contains template (HTML), styles (CSS), and logic (TypeScript)
   - Encapsulates data and behavior

2. **Modules (@NgModule)**: Organize application into cohesive blocks
   - Declares components, directives, pipes
   - Imports other modules
   - Provides services

3. **Services**: Reusable business logic and data services
   - Injectable classes
   - Shared across components

4. **Dependency Injection**: Framework-provided DI system
   - Loose coupling
   - Testability

5. **Directives**: Extend HTML with custom behavior
   - Structural: *ngIf, *ngFor
   - Attribute: [ngClass], [ngStyle]

6. **Pipes**: Transform data in templates
   - Built-in: date, currency, json
   - Custom pipes for specific transformations

7. **Routing**: Navigate between views
   - Lazy loading
   - Route guards
   - Route parameters

**Architecture Flow:**
```
Module → Component → Template → Directives → Pipes → Services
```

**Real-world analogy**: Think of Angular like a building:
- **Module** = Floor (organizes rooms)
- **Component** = Room (has furniture, decor, functionality)
- **Service** = Utilities (shared across rooms)
- **Directive** = Smart features (automatic lights, sensors)
- **Pipe** = Transformers (water filter, air purifier)

---

### What are Angular modules, and why are they used?

**Angular Modules (@NgModule)** are containers that organize related code into functional units.

**Why use modules?**

1. **Organization**: Group related components, directives, pipes
2. **Lazy Loading**: Load modules on-demand for better performance
3. **Encapsulation**: Control what's exported and imported
4. **Separation of Concerns**: Feature modules, shared modules, core modules
5. **Reusability**: Share modules across applications

**Module Structure:**
```typescript
@NgModule({
  declarations: [UserComponent, UserListComponent], // Components, directives, pipes
  imports: [CommonModule, RouterModule],           // Other modules
  providers: [UserService],                        // Services
  exports: [UserComponent],                        // What other modules can use
  bootstrap: [AppComponent]                        // Root component (AppModule only)
})
export class UserModule { }
```

**Common Module Types:**

- **AppModule**: Root module, bootstraps the application
- **Feature Module**: Encapsulates a feature (UserModule, ProductModule)
- **Shared Module**: Common components/pipes used across features
- **Core Module**: Singleton services, app-wide components (header, footer)
- **Routing Module**: Route configuration

**Best Practice**: Create a `SharedModule` for common UI components and a `CoreModule` for singleton services.

---

### What is a component in Angular?

A **Component** is a TypeScript class decorated with `@Component` that controls a view (HTML template) and its behavior.

**Component Structure:**
```typescript
@Component({
  selector: 'app-user-profile',        // How to use: <app-user-profile></app-user-profile>
  templateUrl: './user-profile.component.html',  // View
  styleUrls: ['./user-profile.component.css'],  // Styles
  // OR inline:
  // template: '<div>User Profile</div>',
  // styles: ['div { color: blue; }']
})
export class UserProfileComponent implements OnInit {
  @Input() userId: number;
  @Output() userUpdated = new EventEmitter<User>();
  
  user: User;
  
  constructor(private userService: UserService) {}
  
  ngOnInit() {
    this.loadUser();
  }
  
  loadUser() {
    this.userService.getUser(this.userId).subscribe(user => {
      this.user = user;
    });
  }
}
```

**Component Responsibilities:**
- Display data in the template
- Handle user interactions
- Communicate with services
- Emit events to parent components
- Manage component state

**Component Lifecycle:**
Angular creates, updates, and destroys components, calling lifecycle hooks at each stage.

---

### What is a directive? Name the types.

**Directives** are classes that add behavior to elements in the DOM. They're the building blocks Angular uses to build component templates.

**Types of Directives:**

1. **Components** (most common directive type)
   - Has a template
   - Example: `<app-user></app-user>`

2. **Structural Directives**
   - Change DOM structure by adding/removing elements
   - Prefixed with `*`
   - Examples: `*ngIf`, `*ngFor`, `*ngSwitch`

3. **Attribute Directives**
   - Change appearance or behavior of existing elements
   - Examples: `[ngClass]`, `[ngStyle]`, `[ngModel]`

**Custom Directive Example:**
```typescript
// Structural Directive
@Directive({
  selector: '[appUnless]'
})
export class UnlessDirective {
  @Input() set appUnless(condition: boolean) {
    if (!condition) {
      this.viewContainer.createEmbeddedView(this.templateRef);
    } else {
      this.viewContainer.clear();
    }
  }
  
  constructor(
    private templateRef: TemplateRef<any>,
    private viewContainer: ViewContainerRef
  ) {}
}

// Usage: <div *appUnless="isLoggedIn">Please login</div>

// Attribute Directive
@Directive({
  selector: '[appHighlight]'
})
export class HighlightDirective {
  @HostBinding('style.backgroundColor') backgroundColor: string;
  
  @Input() set appHighlight(color: string) {
    this.backgroundColor = color || 'yellow';
  }
}

// Usage: <p appHighlight="lightblue">Highlighted text</p>
```

---

### Explain data binding in Angular.

**Data Binding** connects component data with the DOM. Angular supports **four types** of binding:

1. **Interpolation** `{{ }}`
   - One-way: Component → View
   - Displays component data in template
   ```html
   <h1>Welcome {{user.name}}!</h1>
   <p>Total: {{items.length}} items</p>
   ```

2. **Property Binding** `[property]="expression"`
   - One-way: Component → View
   - Sets element/component properties
   ```html
   <img [src]="imageUrl" [alt]="imageAlt">
   <button [disabled]="isLoading">Submit</button>
   <app-child [data]="parentData"></app-child>
   ```

3. **Event Binding** `(event)="handler()"`
   - One-way: View → Component
   - Listens to DOM events
   ```html
   <button (click)="onSubmit()">Click</button>
   <input (keyup)="onKeyUp($event)">
   <app-child (dataChange)="handleChange($event)"></app-child>
   ```

4. **Two-Way Binding** `[(ngModel)]="property"`
   - Two-way: Component ↔ View
   - Combines property and event binding
   ```html
   <input [(ngModel)]="userName">
   <!-- Equivalent to: -->
   <input [ngModel]="userName" (ngModelChange)="userName = $event">
   ```

**Binding Summary:**
```
Interpolation:     {{value}}           Component → DOM
Property:          [property]="value"  Component → DOM
Event:             (event)="handler"   DOM → Component
Two-way:           [(ngModel)]="prop" Component ↔ DOM
```

---

### What is the difference between interpolation, property binding, and event binding?

| Feature | Interpolation | Property Binding | Event Binding |
|---------|--------------|------------------|---------------|
| **Syntax** | `{{expression}}` | `[property]="expression"` | `(event)="handler()"` |
| **Direction** | Component → View | Component → View | View → Component |
| **Use Case** | Display text | Set properties/attributes | Handle user actions |
| **Expression** | Always string | Any type | Function call |
| **When to Use** | Simple text display | Dynamic properties, boolean attributes | User interactions |

**Practical Examples:**

```html
<!-- Interpolation: Simple text -->
<h1>Hello {{name}}</h1>
<p>Count: {{count}}</p>

<!-- Property Binding: Dynamic attributes -->
<img [src]="imageUrl" [alt]="description">
<button [disabled]="isLoading">Submit</button>
<div [class.active]="isActive"></div>
<div [style.color]="textColor"></div>

<!-- Event Binding: User interactions -->
<button (click)="handleClick()">Click Me</button>
<input (keyup)="onKeyUp($event)" (blur)="onBlur()">
<form (submit)="onSubmit($event)">...</form>
```

**Key Differences:**

1. **Interpolation** converts everything to a string. Use for text content.
2. **Property Binding** preserves types (boolean, number, object). Use for attributes/properties.
3. **Event Binding** executes functions. Use for handling events.

**When to use what:**
- **Interpolation**: Displaying data in text nodes
- **Property Binding**: Setting element properties, component inputs, directives
- **Event Binding**: Handling clicks, form submissions, custom events

---

### What are pipes in Angular? Give examples.

**Pipes** transform data in templates. They take input data and return formatted output.

**Syntax:** `{{ value | pipeName:parameter }}`

**Built-in Pipes:**

```html
<!-- Date Pipe -->
{{ today | date }}                          <!-- Dec 15, 2024 -->
{{ today | date:'short' }}                  <!-- 12/15/24, 3:45 PM -->
{{ today | date:'fullDate' }}               <!-- Monday, December 15, 2024 -->
{{ today | date:'yyyy-MM-dd HH:mm:ss' }}    <!-- 2024-12-15 15:45:30 -->

<!-- Currency Pipe -->
{{ price | currency }}                       <!-- $1,234.56 -->
{{ price | currency:'EUR':'symbol':'1.2-2' }} <!-- €1,234.56 -->

<!-- Decimal Pipe -->
{{ number | number:'1.2-2' }}               <!-- 1,234.56 -->
{{ number | number:'3.1-1' }}               <!-- 001.2 -->

<!-- Percent Pipe -->
{{ ratio | percent }}                       <!-- 45% -->
{{ ratio | percent:'1.2-2' }}               <!-- 45.00% -->

<!-- Uppercase/Lowercase -->
{{ text | uppercase }}                      <!-- HELLO WORLD -->
{{ text | lowercase }}                      <!-- hello world -->

<!-- Title Case -->
{{ text | titlecase }}                      <!-- Hello World -->

<!-- JSON Pipe (debugging) -->
{{ object | json }}                         <!-- {"name":"John","age":30} -->

<!-- Slice Pipe -->
{{ array | slice:0:5 }}                     <!-- First 5 items -->
{{ text | slice:0:10 }}                     <!-- First 10 characters -->

<!-- Async Pipe (handles Observables/Promises) -->
{{ data$ | async }}                         <!-- Automatically subscribes -->
```

**Custom Pipe Example:**
```typescript
@Pipe({
  name: 'truncate'
})
export class TruncatePipe implements PipeTransform {
  transform(value: string, limit: number = 20, trail: string = '...'): string {
    if (!value) return '';
    return value.length > limit 
      ? value.substring(0, limit) + trail 
      : value;
  }
}

// Usage: {{ longText | truncate:50:'...' }}
```

**Chaining Pipes:**
```html
{{ user.birthDate | date:'short' | uppercase }}
{{ price | currency:'USD' | slice:1 }}
```

---

### What is the difference between pure and impure pipes?

**Pure Pipes:**
- Angular executes only when the input reference changes
- Angular uses change detection to determine if input changed
- More performant (fewer executions)
- Should not have side effects
- Default behavior

**Impure Pipes:**
- Angular executes on every change detection cycle
- Runs even if input hasn't changed
- Less performant (more executions)
- Can have side effects
- Must explicitly mark with `pure: false`

**Example:**
```typescript
// Pure Pipe (default)
@Pipe({
  name: 'filter',
  pure: true  // Default, can be omitted
})
export class FilterPipe implements PipeTransform {
  transform(items: any[], filter: string): any[] {
    if (!items || !filter) return items;
    return items.filter(item => item.name.includes(filter));
  }
}

// Impure Pipe
@Pipe({
  name: 'random',
  pure: false  // Executes on every change detection
})
export class RandomPipe implements PipeTransform {
  transform(value: number): number {
    return Math.random() * value;  // Side effect: generates new random
  }
}
```

**When to use Impure:**
- Need to detect changes inside objects/arrays (reference doesn't change)
- Need to execute on every change detection cycle
- Example: Filtering arrays, sorting, formatting with current time

**Performance Impact:**
```typescript
// Pure: Executes only when items reference changes
{{ items | filter:searchTerm }}

// Impure: Executes on EVERY change detection (expensive!)
{{ items | filter:searchTerm }}
// If items array is mutated (push, pop), pure pipe won't detect it
// Impure pipe will detect it, but at performance cost
```

**Best Practice:** Keep pipes pure unless absolutely necessary. For array filtering/sorting, consider using component methods or computed properties.

---

### Explain Angular's change detection mechanism.

**Change Detection** is Angular's mechanism to detect changes in data and update the DOM accordingly.

**How it works:**

1. **Zone.js** patches async operations (setTimeout, HTTP, events)
2. When async operation completes, Zone.js notifies Angular
3. Angular runs change detection from root component
4. Checks all bindings in component tree
5. Updates DOM if values changed

**Change Detection Strategies:**

1. **Default Strategy** (CheckAlways)
   - Checks all components on every change detection cycle
   - Runs when: events, timers, HTTP, any async operation
   ```typescript
   @Component({
     changeDetection: ChangeDetectionStrategy.Default
   })
   ```

2. **OnPush Strategy**
   - Only checks when:
     - Input reference changes
     - Event originates from component
     - Observable emits (with async pipe)
     - Manual trigger (markForCheck, detectChanges)
   ```typescript
   @Component({
     changeDetection: ChangeDetectionStrategy.OnPush
   })
   ```

**Change Detection Flow:**
```
Event/Timer/HTTP → Zone.js → Angular Change Detection → 
Check Components → Update DOM → Done
```

**Optimization Techniques:**

1. **OnPush Strategy:**
   ```typescript
   @Component({
     selector: 'app-user',
     changeDetection: ChangeDetectionStrategy.OnPush
   })
   export class UserComponent {
     @Input() user: User;  // Only checks when user reference changes
   }
   ```

2. **Immutable Data:**
   ```typescript
   // Bad: Mutates array (OnPush won't detect)
   this.users.push(newUser);
   
   // Good: New reference (OnPush detects)
   this.users = [...this.users, newUser];
   ```

3. **TrackBy Function:**
   ```typescript
   trackByUserId(index: number, user: User): number {
     return user.id;  // Prevents unnecessary DOM updates
   }
   
   // Template:
   <div *ngFor="let user of users; trackBy: trackByUserId">
   ```

4. **Manual Control:**
   ```typescript
   constructor(private cdr: ChangeDetectorRef) {}
   
   // Mark for check (OnPush)
   this.cdr.markForCheck();
   
   // Force immediate check
   this.cdr.detectChanges();
   
   // Detach from change detection
   this.cdr.detach();
   ```

**Performance Tips:**
- Use OnPush for leaf components
- Use immutable data structures
- Use trackBy with *ngFor
- Avoid complex expressions in templates
- Use async pipe for Observables

---

## 🔹 Components & Templates

### What is the component lifecycle? List the lifecycle hooks.

**Component Lifecycle** is the sequence of stages a component goes through from creation to destruction.

**Lifecycle Hooks (in order):**

1. **constructor()** - Not a hook, but runs first
   - Initialize class properties
   - Inject dependencies
   - Don't access @Input properties here

2. **ngOnChanges()** - Called before ngOnInit and when input properties change
   - Receives SimpleChanges object
   - Only called for inputs with new references

3. **ngOnInit()** - Called once after first ngOnChanges
   - Initialize component
   - Fetch data
   - Setup subscriptions (be careful!)

4. **ngDoCheck()** - Called during every change detection cycle
   - Custom change detection logic
   - Use sparingly (performance impact)

5. **ngAfterContentInit()** - Called after ng-content is projected
   - Access projected content
   - Called once

6. **ngAfterContentChecked()** - Called after every content check
   - React to projected content changes

7. **ngAfterViewInit()** - Called after component's view is initialized
   - Access @ViewChild/@ViewChildren
   - Called once

8. **ngAfterViewChecked()** - Called after every view check
   - React to view changes

9. **ngOnDestroy()** - Called before component is destroyed
   - Cleanup: unsubscribe, clear timers, remove listeners

**Lifecycle Flow:**
```
constructor → ngOnChanges → ngOnInit → ngDoCheck → 
ngAfterContentInit → ngAfterContentChecked → 
ngAfterViewInit → ngAfterViewChecked → 
(change detection cycles) → ngOnDestroy
```

**Practical Example:**
```typescript
export class UserComponent implements 
  OnInit, OnChanges, AfterViewInit, OnDestroy {
  
  @Input() userId: number;
  private subscription: Subscription;
  
  constructor(private userService: UserService) {
    console.log('1. Constructor');
    // Don't access @Input here - it's undefined!
  }
  
  ngOnChanges(changes: SimpleChanges) {
    console.log('2. ngOnChanges', changes);
    if (changes.userId && !changes.userId.firstChange) {
      this.loadUser(changes.userId.currentValue);
    }
  }
  
  ngOnInit() {
    console.log('3. ngOnInit');
    this.loadUser(this.userId);
  }
  
  ngAfterViewInit() {
    console.log('4. ngAfterViewInit');
    // Now @ViewChild is available
  }
  
  ngOnDestroy() {
    console.log('5. ngOnDestroy');
    this.subscription?.unsubscribe();
  }
}
```

---

### Explain ngOnInit vs constructor.

**Constructor:**
- TypeScript/JavaScript class constructor
- Runs when class is instantiated
- Used for dependency injection
- Don't access @Input properties (they're undefined)
- Don't access DOM elements
- Initialize simple properties

**ngOnInit:**
- Angular lifecycle hook
- Runs after Angular sets up component
- @Input properties are available
- Perfect for initialization logic
- Fetch data, setup subscriptions

**When to use what:**

```typescript
export class UserComponent implements OnInit {
  @Input() userId: number;
  users: User[] = [];
  
  constructor(
    private userService: UserService,
    private router: Router
  ) {
    // ✅ Good: Dependency injection
    // ✅ Good: Initialize simple properties
    this.users = [];
    
    // ❌ Bad: @Input is undefined
    // console.log(this.userId); // undefined!
    
    // ❌ Bad: DOM not ready
    // document.getElementById('user'); // null!
  }
  
  ngOnInit() {
    // ✅ Good: @Input is available
    console.log(this.userId); // Works!
    
    // ✅ Good: Fetch data
    this.loadUser();
    
    // ✅ Good: Setup logic
    this.initializeComponent();
  }
}
```

**Best Practice:**
- **Constructor**: Only dependency injection and simple initialization
- **ngOnInit**: All component initialization logic

---

### What is @Input and @Output?

**@Input**: Passes data from parent to child component
**@Output**: Emits events from child to parent component

**@Input Example:**
```typescript
// Child Component
@Component({
  selector: 'app-user-card',
  template: '<div>{{user.name}}</div>'
})
export class UserCardComponent {
  @Input() user: User;
  @Input() isActive: boolean = false;
  @Input('displayName') name: string;  // Alias
}

// Parent Component Template
<app-user-card 
  [user]="selectedUser" 
  [isActive]="true"
  [displayName]="userName">
</app-user-card>
```

**@Output Example:**
```typescript
// Child Component
@Component({
  selector: 'app-user-form',
  template: '<button (click)="onSave()">Save</button>'
})
export class UserFormComponent {
  @Output() userSaved = new EventEmitter<User>();
  @Output() cancelled = new EventEmitter<void>();
  
  onSave() {
    const user = { name: 'John', age: 30 };
    this.userSaved.emit(user);
  }
  
  onCancel() {
    this.cancelled.emit();
  }
}

// Parent Component Template
<app-user-form 
  (userSaved)="handleUserSaved($event)"
  (cancelled)="handleCancel()">
</app-user-form>

// Parent Component
handleUserSaved(user: User) {
  console.log('User saved:', user);
  // Update parent state
}
```

**Input/Output Together:**
```typescript
// Two-way binding pattern
@Component({
  selector: 'app-counter',
  template: `
    <button (click)="decrement()">-</button>
    <span>{{count}}</span>
    <button (click)="increment()">+</button>
  `
})
export class CounterComponent {
  @Input() count: number = 0;
  @Output() countChange = new EventEmitter<number>();
  
  increment() {
    this.count++;
    this.countChange.emit(this.count);
  }
  
  decrement() {
    this.count--;
    this.countChange.emit(this.count);
  }
}

// Usage with two-way binding:
<app-counter [(count)]="totalCount"></app-counter>
// Equivalent to:
<app-counter [count]="totalCount" (countChange)="totalCount = $event"></app-counter>
```

---

### How do you pass data from parent to child component?

**Method 1: @Input Property Binding**
```typescript
// Parent Component
@Component({
  selector: 'app-parent',
  template: `
    <app-child [user]="currentUser" [isActive]="true"></app-child>
  `
})
export class ParentComponent {
  currentUser: User = { id: 1, name: 'John' };
}

// Child Component
@Component({
  selector: 'app-child',
  template: '<div>{{user.name}}</div>'
})
export class ChildComponent {
  @Input() user: User;
  @Input() isActive: boolean;
}
```

**Method 2: Using Services (Shared State)**
```typescript
// Shared Service
@Injectable({ providedIn: 'root' })
export class DataService {
  private userSubject = new BehaviorSubject<User>(null);
  user$ = this.userSubject.asObservable();
  
  setUser(user: User) {
    this.userSubject.next(user);
  }
}

// Parent Component
export class ParentComponent {
  constructor(private dataService: DataService) {}
  
  updateUser() {
    this.dataService.setUser({ id: 1, name: 'John' });
  }
}

// Child Component
export class ChildComponent implements OnInit {
  user: User;
  
  constructor(private dataService: DataService) {}
  
  ngOnInit() {
    this.dataService.user$.subscribe(user => {
      this.user = user;
    });
  }
}
```

**Method 3: Template Reference Variables**
```typescript
// Parent Template
<app-child #childComponent [data]="parentData"></app-child>
<button (click)="childComponent.updateData()">Update</button>

// Child Component
export class ChildComponent {
  @Input() data: any;
  
  updateData() {
    // Method accessible from parent
  }
}
```

---

### How do you pass data from child to parent component?

**Method 1: @Output EventEmitter**
```typescript
// Child Component
@Component({
  selector: 'app-child',
  template: '<button (click)="sendData()">Send</button>'
})
export class ChildComponent {
  @Output() dataEvent = new EventEmitter<string>();
  
  sendData() {
    this.dataEvent.emit('Hello from child!');
  }
}

// Parent Component Template
<app-child (dataEvent)="handleData($event)"></app-child>

// Parent Component
export class ParentComponent {
  handleData(data: string) {
    console.log('Received:', data);
  }
}
```

**Method 2: @ViewChild**
```typescript
// Parent Component
@Component({
  selector: 'app-parent',
  template: '<app-child #childRef></app-child>'
})
export class ParentComponent implements AfterViewInit {
  @ViewChild('childRef') childComponent: ChildComponent;
  
  ngAfterViewInit() {
    // Access child component
    this.childComponent.childData.subscribe(data => {
      console.log('Child data:', data);
    });
  }
}

// Child Component
export class ChildComponent {
  childData = new Subject<string>();
  
  sendData() {
    this.childData.next('Data from child');
  }
}
```

**Method 3: Services (Shared State)**
```typescript
// Same service approach as parent-to-child
@Injectable({ providedIn: 'root' })
export class CommunicationService {
  private messageSubject = new Subject<string>();
  message$ = this.messageSubject.asObservable();
  
  sendMessage(message: string) {
    this.messageSubject.next(message);
  }
}
```

---

### What is ViewChild and ViewChildren?

**@ViewChild**: Gets reference to a single child element/component/directive
**@ViewChildren**: Gets reference to multiple child elements/components/directives

**@ViewChild Example:**
```typescript
@Component({
  selector: 'app-parent',
  template: `
    <app-child #childRef></app-child>
    <input #inputRef type="text">
    <div appHighlight #highlightRef>Content</div>
  `
})
export class ParentComponent implements AfterViewInit {
  // Get child component
  @ViewChild('childRef') childComponent: ChildComponent;
  
  // Get by component type
  @ViewChild(ChildComponent) child: ChildComponent;
  
  // Get DOM element
  @ViewChild('inputRef', { read: ElementRef }) inputElement: ElementRef;
  
  // Get directive
  @ViewChild('highlightRef', { read: HighlightDirective }) highlight: HighlightDirective;
  
  // Static: Available in ngOnInit (default: false, available in ngAfterViewInit)
  @ViewChild('childRef', { static: true }) staticChild: ChildComponent;
  
  ngAfterViewInit() {
    // Access child component
    this.childComponent.doSomething();
    
    // Access DOM element
    this.inputElement.nativeElement.focus();
    
    // Access directive
    this.highlight.changeColor('blue');
  }
}
```

**@ViewChildren Example:**
```typescript
@Component({
  selector: 'app-parent',
  template: `
    <app-child *ngFor="let item of items"></app-child>
  `
})
export class ParentComponent implements AfterViewInit {
  @ViewChildren(ChildComponent) children: QueryList<ChildComponent>;
  
  ngAfterViewInit() {
    // QueryList is iterable
    this.children.forEach(child => {
      child.initialize();
    });
    
    // Listen to changes
    this.children.changes.subscribe(() => {
      console.log('Children changed');
    });
    
    // Get count
    console.log('Total children:', this.children.length);
  }
}
```

**Common Use Cases:**
- Access child component methods
- Focus input elements
- Scroll to elements
- Access directive instances
- Manipulate DOM directly (when necessary)

---

### What is ContentChild and ContentChildren?

**@ContentChild/@ContentChildren**: Access projected content (ng-content), not view children.

**Difference:**
- **@ViewChild**: Elements in component's template
- **@ContentChild**: Elements projected via `<ng-content>`

**Example:**
```typescript
// Parent Component
@Component({
  selector: 'app-parent',
  template: `
    <app-card>
      <h2 #title>Card Title</h2>
      <p #content>Card content goes here</p>
    </app-card>
  `
})
export class ParentComponent {}

// Card Component (Child)
@Component({
  selector: 'app-card',
  template: `
    <div class="card">
      <ng-content></ng-content>  <!-- Projected content -->
    </div>
  `
})
export class CardComponent implements AfterContentInit {
  // Access projected content
  @ContentChild('title') titleElement: ElementRef;
  @ContentChild('content') contentElement: ElementRef;
  
  // Access by component type
  @ContentChild(ButtonComponent) button: ButtonComponent;
  
  // Multiple
  @ContentChildren('item') items: QueryList<ElementRef>;
  
  ngAfterContentInit() {
    // Access projected elements
    console.log(this.titleElement.nativeElement.textContent);
  }
}
```

**When to use:**
- Building reusable wrapper components
- Accessing projected content
- Creating flexible component APIs

---

### Explain component communication methods.

**1. Parent → Child: @Input**
```typescript
// Parent
<app-child [data]="parentData"></app-child>

// Child
@Input() data: any;
```

**2. Child → Parent: @Output**
```typescript
// Child
@Output() event = new EventEmitter();
this.event.emit(data);

// Parent
<app-child (event)="handleEvent($event)"></app-child>
```

**3. Two-way Binding: @Input + @Output**
```typescript
// Child
@Input() value: string;
@Output() valueChange = new EventEmitter<string>();

// Parent
<app-child [(value)]="parentValue"></app-child>
```

**4. ViewChild/ViewChildren**
```typescript
@ViewChild(ChildComponent) child: ChildComponent;
// Access child methods/properties
```

**5. Services (Shared State)**
```typescript
@Injectable({ providedIn: 'root' })
export class SharedService {
  private dataSubject = new BehaviorSubject<any>(null);
  data$ = this.dataSubject.asObservable();
  
  updateData(data: any) {
    this.dataSubject.next(data);
  }
}
```

**6. RxJS Subjects/BehaviorSubjects**
```typescript
// Service
export class CommunicationService {
  message$ = new Subject<string>();
}

// Component A
this.communicationService.message$.next('Hello');

// Component B
this.communicationService.message$.subscribe(msg => {
  console.log(msg);
});
```

**7. State Management (NgRx, Akita, etc.)**
```typescript
// Store-based communication
this.store.dispatch(new LoadUsers());
this.store.select(selectUsers).subscribe(users => {
  // Handle users
});
```

**When to use what:**
- **@Input/@Output**: Direct parent-child relationship
- **Services**: Sibling components, distant components
- **ViewChild**: Need to call child methods
- **State Management**: Complex application state

---

### What is ng-content?

**ng-content** is Angular's content projection mechanism. It allows you to insert external content into a component's template.

**Basic Usage:**
```typescript
// Card Component
@Component({
  selector: 'app-card',
  template: `
    <div class="card">
      <div class="card-header">
        <ng-content select="[slot=header]"></ng-content>
      </div>
      <div class="card-body">
        <ng-content></ng-content>  <!-- Default slot -->
      </div>
      <div class="card-footer">
        <ng-content select="[slot=footer]"></ng-content>
      </div>
    </div>
  `
})
export class CardComponent {}

// Usage
<app-card>
  <div slot="header">Card Title</div>
  <p>Card body content</p>
  <div slot="footer">Card Footer</div>
</app-card>
```

**Multiple Projection Slots:**
```typescript
// Component with multiple slots
@Component({
  selector: 'app-layout',
  template: `
    <header>
      <ng-content select="app-header"></ng-content>
    </header>
    <main>
      <ng-content select="app-main"></ng-content>
    </main>
    <footer>
      <ng-content select="app-footer"></ng-content>
    </footer>
  `
})
export class LayoutComponent {}

// Usage
<app-layout>
  <app-header>Header Content</app-header>
  <app-main>Main Content</app-main>
  <app-footer>Footer Content</app-footer>
</app-layout>
```

**Use Cases:**
- Reusable wrapper components
- Flexible component APIs
- Layout components
- Modal/dialog components

---

### What is the difference between *ngIf and [hidden]?

***ngIf**: Structural directive - removes/adds element from DOM
**[hidden]**: Attribute directive - hides/shows element with CSS

**Key Differences:**

| Feature | *ngIf | [hidden] |
|---------|-------|----------|
| **DOM** | Removes from DOM | Stays in DOM |
| **Performance** | Better (no DOM element) | Element still exists |
| **CSS** | No CSS involved | Uses `display: none` |
| **Lifecycle** | Component lifecycle runs | Component always initialized |
| **Use Case** | Expensive components | Simple show/hide |

**Example:**
```html
<!-- *ngIf: Element removed from DOM when false -->
<div *ngIf="isVisible">
  <expensive-component></expensive-component>
</div>

<!-- [hidden]: Element in DOM, just hidden -->
<div [hidden]="!isVisible">
  Simple content
</div>
```

**When to use:**

**Use *ngIf when:**
- Component is expensive to render
- Component has heavy initialization
- You want to free up memory
- Condition rarely changes

**Use [hidden] when:**
- Simple show/hide toggle
- Frequent toggling (better performance)
- Need to preserve component state
- Element is lightweight

**Performance Example:**
```typescript
// Expensive component - use *ngIf
<div *ngIf="showChart">
  <app-chart [data]="largeDataset"></app-chart>  <!-- Only created when needed -->
</div>

// Simple toggle - use [hidden]
<div [hidden]="!isLoading">
  <span>Loading...</span>  <!-- Stays in DOM, just hidden -->
</div>
```

**Best Practice:**
- Default to `*ngIf` for better performance
- Use `[hidden]` only when you need to preserve state or for frequent toggles

