# Angular Q&A - Part 4: Directives & Advanced Topics

## 🔹 Directives

### What are structural directives?

**Structural Directives** change the DOM structure by adding or removing elements. They're prefixed with `*`.

**Built-in Structural Directives:**

1. **\*ngIf** - Conditionally includes/excludes elements
2. **\*ngFor** - Repeats elements for each item in a collection
3. **\*ngSwitch** - Switches between multiple views

**How They Work:**
The `*` is syntactic sugar. Angular transforms:
```html
<div *ngIf="condition">Content</div>
```

Into:
```html
<ng-template [ngIf]="condition">
  <div>Content</div>
</ng-template>
```

**\*ngIf Example:**
```html
<!-- Basic -->
<div *ngIf="isLoggedIn">Welcome!</div>

<!-- With else -->
<div *ngIf="user; else loading">
  <p>Hello, {{user.name}}</p>
</div>
<ng-template #loading>Loading...</ng-template>

<!-- With then/else -->
<div *ngIf="condition; then thenBlock; else elseBlock"></div>
<ng-template #thenBlock>True content</ng-template>
<ng-template #elseBlock>False content</ng-template>
```

**\*ngFor Example:**
```html
<!-- Basic -->
<div *ngFor="let user of users">
  {{user.name}}
</div>

<!-- With index -->
<div *ngFor="let user of users; let i = index">
  {{i + 1}}. {{user.name}}
</div>

<!-- With trackBy (performance) -->
<div *ngFor="let user of users; trackBy: trackByUserId">
  {{user.name}}
</div>
```

**Creating Custom Structural Directive:**
```typescript
import { Directive, Input, TemplateRef, ViewContainerRef } from '@angular/core';

@Directive({
  selector: '[appUnless]'
})
export class UnlessDirective {
  @Input() set appUnless(condition: boolean) {
    if (!condition && !this.hasView) {
      this.viewContainer.createEmbeddedView(this.templateRef);
      this.hasView = true;
    } else if (condition && this.hasView) {
      this.viewContainer.clear();
      this.hasView = false;
    }
  }
  
  private hasView = false;
  
  constructor(
    private templateRef: TemplateRef<any>,
    private viewContainer: ViewContainerRef
  ) {}
}
```

```html
<!-- Usage -->
<div *appUnless="isLoggedIn">
  Please log in
</div>
```

---

### What are attribute directives?

**Attribute Directives** change the appearance or behavior of existing elements without changing the DOM structure.

**Built-in Attribute Directives:**

1. **ngClass** - Dynamically add/remove CSS classes
2. **ngStyle** - Dynamically set inline styles
3. **ngModel** - Two-way data binding

**ngClass Example:**
```html
<!-- Object syntax -->
<div [ngClass]="{active: isActive, disabled: isDisabled}">Content</div>

<!-- Array syntax -->
<div [ngClass]="['class1', 'class2', isActive ? 'active' : '']">Content</div>

<!-- String syntax -->
<div [ngClass]="'class1 class2'">Content</div>

<!-- Method -->
<div [ngClass]="getClasses()">Content</div>
```

```typescript
getClasses() {
  return {
    'btn': true,
    'btn-primary': this.isPrimary,
    'btn-disabled': this.isDisabled
  };
}
```

**ngStyle Example:**
```html
<!-- Object syntax -->
<div [ngStyle]="{color: textColor, 'font-size.px': fontSize}">Content</div>

<!-- Multiple styles -->
<div [ngStyle]="getStyles()">Content</div>
```

```typescript
getStyles() {
  return {
    'color': this.isActive ? 'blue' : 'gray',
    'font-weight': this.isBold ? 'bold' : 'normal',
    'font-size.px': 16
  };
}
```

**Creating Custom Attribute Directive:**
```typescript
import { Directive, ElementRef, Input, HostListener, HostBinding } from '@angular/core';

@Directive({
  selector: '[appHighlight]'
})
export class HighlightDirective {
  @Input() appHighlight: string = 'yellow';
  @Input() defaultColor: string = 'transparent';
  
  @HostBinding('style.backgroundColor') backgroundColor: string;
  
  @HostListener('mouseenter') onMouseEnter() {
    this.backgroundColor = this.appHighlight || this.defaultColor;
  }
  
  @HostListener('mouseleave') onMouseLeave() {
    this.backgroundColor = this.defaultColor;
  }
  
  constructor(private el: ElementRef) {
    this.backgroundColor = this.defaultColor;
  }
}
```

```html
<!-- Usage -->
<p appHighlight="lightblue" defaultColor="white">
  Hover to highlight
</p>
```

---

### How do you create a custom directive?

**Step 1: Generate Directive**
```bash
ng generate directive highlight
```

**Step 2: Implement Directive**
```typescript
import { Directive, ElementRef, Input, Renderer2, OnInit } from '@angular/core';

@Directive({
  selector: '[appHighlight]'
})
export class HighlightDirective implements OnInit {
  @Input() appHighlight: string = 'yellow';
  @Input() appHighlightDelay: number = 0;
  
  constructor(
    private el: ElementRef,
    private renderer: Renderer2
  ) {}
  
  ngOnInit() {
    setTimeout(() => {
      this.renderer.setStyle(
        this.el.nativeElement,
        'background-color',
        this.appHighlight
      );
    }, this.appHighlightDelay);
  }
}
```

**Step 3: Declare in Module**
```typescript
@NgModule({
  declarations: [HighlightDirective],
  // ...
})
export class AppModule {}
```

**Step 4: Use in Template**
```html
<p appHighlight="lightblue" [appHighlightDelay]="1000">
  This will be highlighted
</p>
```

**Advanced: Directive with Host Binding**
```typescript
@Directive({
  selector: '[appButton]'
})
export class ButtonDirective {
  @HostBinding('class.btn') get hasBtnClass() { return true; }
  @HostBinding('class.btn-primary') @Input() isPrimary: boolean = false;
  @HostBinding('attr.role') role = 'button';
  
  @HostListener('click', ['$event'])
  onClick(event: Event) {
    console.log('Button clicked', event);
  }
}
```

---

### Explain *ngFor with trackBy.

**trackBy** is a performance optimization for `*ngFor` that helps Angular identify which items have changed.

**Problem Without trackBy:**
```html
<div *ngFor="let user of users">
  {{user.name}}
</div>
```
When `users` array changes, Angular destroys and recreates all DOM elements, even if items are the same.

**Solution with trackBy:**
```typescript
// Component
export class UserListComponent {
  users: User[] = [];
  
  trackByUserId(index: number, user: User): number {
    return user.id;  // Unique identifier
  }
  
  // OR track by index (less ideal)
  trackByIndex(index: number, item: any): number {
    return index;
  }
}
```

```html
<!-- Template -->
<div *ngFor="let user of users; trackBy: trackByUserId">
  {{user.name}}
</div>
```

**Benefits:**
- Better performance (only updates changed items)
- Preserves component state
- Smoother animations
- Better for large lists

**Example:**
```typescript
// Without trackBy: All items recreated
users = [
  { id: 1, name: 'John' },
  { id: 2, name: 'Jane' }
];
// Change to:
users = [
  { id: 1, name: 'John Updated' },  // Recreated
  { id: 2, name: 'Jane' }            // Recreated
];

// With trackBy: Only changed item updated
users = [
  { id: 1, name: 'John' },
  { id: 2, name: 'Jane' }
];
// Change to:
users = [
  { id: 1, name: 'John Updated' },  // Updated (same id)
  { id: 2, name: 'Jane' }            // Unchanged
];
```

**Best Practice:** Always use `trackBy` with `*ngFor` when rendering lists, especially with dynamic data.

---

### What is *ngSwitch?

**\*ngSwitch** is a structural directive that displays one element from multiple options based on a condition.

**Syntax:**
```html
<div [ngSwitch]="value">
  <div *ngSwitchCase="'option1'">Option 1</div>
  <div *ngSwitchCase="'option2'">Option 2</div>
  <div *ngSwitchDefault>Default</div>
</div>
```

**Example:**
```typescript
export class StatusComponent {
  status: 'loading' | 'success' | 'error' = 'loading';
}
```

```html
<div [ngSwitch]="status">
  <div *ngSwitchCase="'loading'">
    <spinner></spinner>
  </div>
  
  <div *ngSwitchCase="'success'">
    <success-message></success-message>
  </div>
  
  <div *ngSwitchCase="'error'">
    <error-message></error-message>
  </div>
  
  <div *ngSwitchDefault>
    Unknown status
  </div>
</div>
```

**Comparison with *ngIf:**
```html
<!-- Multiple *ngIf (less efficient) -->
<div *ngIf="status === 'loading'">Loading</div>
<div *ngIf="status === 'success'">Success</div>
<div *ngIf="status === 'error'">Error</div>

<!-- *ngSwitch (more efficient) -->
<div [ngSwitch]="status">
  <div *ngSwitchCase="'loading'">Loading</div>
  <div *ngSwitchCase="'success'">Success</div>
  <div *ngSwitchCase="'error'">Error</div>
</div>
```

**When to Use:**
- Multiple mutually exclusive conditions
- Better performance than multiple `*ngIf`
- Cleaner code for switch-like logic

---

## 🔹 Advanced Topics

### What is AOT (Ahead-of-Time) compilation?

**AOT (Ahead-of-Time) Compilation** compiles Angular templates and components at build time, before the browser downloads and runs the code.

**How it Works:**
1. Angular compiler runs during build
2. Templates converted to JavaScript
3. Type checking performed
4. Optimized code generated
5. Smaller bundle size

**Benefits:**
- **Faster Rendering**: No compilation in browser
- **Smaller Bundle**: Tree-shaking, dead code elimination
- **Better Security**: Templates compiled, no eval()
- **Early Errors**: Template errors caught at build time
- **Better Performance**: Optimized code

**AOT vs JIT:**

| Feature | AOT | JIT |
|---------|-----|-----|
| **When** | Build time | Runtime |
| **Bundle Size** | Smaller | Larger |
| **Startup** | Faster | Slower |
| **Errors** | Build time | Runtime |
| **Default** | ✅ Yes (production) | Development |

**Enabling AOT:**
```bash
# Production build (AOT by default)
ng build --prod

# Development with AOT
ng build --aot

# JIT (development default)
ng serve  # JIT
```

**AOT Requirements:**
- Metadata must be statically analyzable
- No dynamic component creation (mostly)
- Functions in templates must be exported
- Lambdas in decorators must be static

---

### What is JIT (Just-in-Time) compilation?

**JIT (Just-in-Time) Compilation** compiles Angular templates and components at runtime in the browser.

**How it Works:**
1. Browser downloads TypeScript/JavaScript
2. Angular compiler runs in browser
3. Templates compiled on-the-fly
4. Components rendered

**When Used:**
- Development mode (default)
- Faster rebuilds
- Easier debugging

**Disadvantages:**
- Larger bundle (includes compiler)
- Slower initial load
- Runtime compilation overhead
- Template errors at runtime

**JIT Example:**
```typescript
// JIT allows dynamic templates (not recommended)
@Component({
  template: this.getTemplate()  // Dynamic - only works in JIT
})
```

**Best Practice:** Use AOT for production, JIT for development.

---

### What are Angular decorators? List common ones.

**Decorators** are functions that modify classes, properties, methods, or parameters. They're TypeScript/JavaScript features used extensively in Angular.

**Common Decorators:**

1. **@Component** - Marks class as Angular component
2. **@Directive** - Marks class as directive
3. **@Injectable** - Marks class as injectable service
4. **@NgModule** - Marks class as Angular module
5. **@Input** - Marks property as input binding
6. **@Output** - Marks property as output event
7. **@ViewChild** - Gets reference to child element/component
8. **@ViewChildren** - Gets references to multiple children
9. **@ContentChild** - Gets reference to projected content
10. **@ContentChildren** - Gets references to projected content
11. **@HostBinding** - Binds to host element property
12. **@HostListener** - Listens to host element events
13. **@Inject** - Injects dependency with token
14. **@Optional** - Marks dependency as optional
15. **@Self** - Limits DI to current injector
16. **@SkipSelf** - Skips current injector
17. **@Host** - Limits DI to host element

**Examples:**
```typescript
// Component
@Component({
  selector: 'app-user',
  templateUrl: './user.component.html'
})
export class UserComponent {
  @Input() user: User;
  @Output() userChange = new EventEmitter();
  
  @ViewChild('input') input: ElementRef;
  @ViewChildren(UserItemComponent) items: QueryList<UserItemComponent>;
  
  @HostBinding('class.active') isActive = false;
  @HostListener('click', ['$event']) onClick(event: Event) {}
  
  constructor(
    @Optional() @Inject(USER_TOKEN) private userService: UserService
  ) {}
}
```

---

### What is @ViewChild and @ViewChildren?

**@ViewChild**: Gets reference to a single child element/component/directive in the component's view.

**@ViewChildren**: Gets references to multiple child elements/components/directives.

**@ViewChild Example:**
```typescript
import { ViewChild, ElementRef, AfterViewInit } from '@angular/core';

export class UserComponent implements AfterViewInit {
  // Get by template reference
  @ViewChild('inputRef') inputElement: ElementRef;
  
  // Get by component type
  @ViewChild(ChildComponent) childComponent: ChildComponent;
  
  // Get by directive
  @ViewChild(HighlightDirective) highlight: HighlightDirective;
  
  // Static: Available in ngOnInit (default: false)
  @ViewChild('inputRef', { static: true }) staticInput: ElementRef;
  
  // Read specific token
  @ViewChild('inputRef', { read: ElementRef }) element: ElementRef;
  @ViewChild('inputRef', { read: ViewContainerRef }) viewContainer: ViewContainerRef;
  
  ngAfterViewInit() {
    // @ViewChild available here
    this.inputElement.nativeElement.focus();
    this.childComponent.doSomething();
  }
}
```

```html
<!-- Template -->
<input #inputRef type="text">
<app-child></app-child>
<div appHighlight #highlightRef>Content</div>
```

**@ViewChildren Example:**
```typescript
import { ViewChildren, QueryList } from '@angular/core';

export class UserListComponent implements AfterViewInit {
  @ViewChildren(UserItemComponent) items: QueryList<UserItemComponent>;
  @ViewChildren('itemRef') itemElements: QueryList<ElementRef>;
  
  ngAfterViewInit() {
    // QueryList is iterable
    this.items.forEach(item => {
      item.initialize();
    });
    
    // Listen to changes
    this.items.changes.subscribe(() => {
      console.log('Items changed:', this.items.length);
    });
    
    // Get array
    const itemsArray = this.items.toArray();
  }
}
```

```html
<div *ngFor="let user of users">
  <app-user-item #itemRef></app-user-item>
</div>
```

**Use Cases:**
- Focus input elements
- Access child component methods
- Scroll to elements
- Manipulate DOM (when necessary)

---

### What is @HostListener and @HostBinding?

**@HostListener**: Listens to events on the host element (the element the directive/component is attached to).

**@HostBinding**: Binds to a property of the host element.

**@HostListener Example:**
```typescript
@Directive({
  selector: '[appClickOutside]'
})
export class ClickOutsideDirective {
  @HostListener('document:click', ['$event'])
  onClick(event: MouseEvent) {
    if (!this.el.nativeElement.contains(event.target)) {
      // Clicked outside
      this.onClickOutside.emit();
    }
  }
  
  @HostListener('mouseenter') onMouseEnter() {
    console.log('Mouse entered');
  }
  
  @HostListener('mouseleave') onMouseLeave() {
    console.log('Mouse left');
  }
  
  constructor(private el: ElementRef) {}
}
```

**@HostBinding Example:**
```typescript
@Directive({
  selector: '[appHighlight]'
})
export class HighlightDirective {
  @HostBinding('style.backgroundColor') backgroundColor: string = 'transparent';
  @HostBinding('class.active') isActive: boolean = false;
  @HostBinding('attr.role') role: string = 'button';
  @HostBinding('attr.aria-label') label: string = 'Highlighted';
  
  @Input() set appHighlight(color: string) {
    this.backgroundColor = color;
    this.isActive = true;
  }
}
```

**Combined Example:**
```typescript
@Directive({
  selector: '[appToggle]'
})
export class ToggleDirective {
  @HostBinding('class.active') isActive = false;
  
  @HostListener('click', ['$event'])
  onClick(event: Event) {
    this.isActive = !this.isActive;
    event.stopPropagation();
  }
}
```

```html
<!-- Usage -->
<div appToggle>Click to toggle</div>
<!-- Becomes: -->
<div class="active">Click to toggle</div>  <!-- After click -->
```

---

### Explain Angular's change detection strategy (OnPush).

**Change Detection Strategy** controls when Angular checks a component for changes.

**Strategies:**

1. **Default (CheckAlways)** - Checks on every change detection cycle
2. **OnPush** - Checks only when:
   - Input reference changes
   - Event originates from component
   - Observable emits (with async pipe)
   - Manual trigger

**Default Strategy:**
```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.Default  // Default
})
export class UserComponent {
  @Input() user: User;
  
  // Checked on every change detection cycle
}
```

**OnPush Strategy:**
```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserComponent {
  @Input() user: User;  // Only checked when user reference changes
  
  // More performant, but requires immutable data
}
```

**OnPush Requirements:**
```typescript
// ❌ Bad: Mutation (OnPush won't detect)
this.user.name = 'New Name';  // Reference unchanged

// ✅ Good: New reference (OnPush detects)
this.user = { ...this.user, name: 'New Name' };

// ✅ Good: Array mutation
this.users = [...this.users, newUser];  // New array reference
```

**OnPush with Observables:**
```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserComponent {
  user$ = this.userService.getUser();
  
  // Async pipe triggers change detection
}
```

```html
<div>{{ user$ | async }}</div>  <!-- Triggers change detection -->
```

**Manual Trigger:**
```typescript
import { ChangeDetectorRef } from '@angular/core';

export class UserComponent {
  constructor(private cdr: ChangeDetectorRef) {}
  
  updateUser() {
    // Mutate data
    this.user.name = 'New Name';
    
    // Manually trigger change detection
    this.cdr.markForCheck();  // Marks for check in next cycle
    // OR
    this.cdr.detectChanges();  // Immediate check
  }
}
```

**Benefits of OnPush:**
- Better performance (fewer checks)
- Predictable change detection
- Encourages immutable patterns
- Better for large applications

**Best Practice:** Use OnPush for leaf components and components with simple inputs.

---

### What is ChangeDetectorRef?

**ChangeDetectorRef** is a service that provides methods to manually control change detection.

**Methods:**

1. **markForCheck()** - Marks component for check in next cycle
2. **detectChanges()** - Immediately runs change detection
3. **detach()** - Detaches from change detection tree
4. **reattach()** - Reattaches to change detection tree

**Example:**
```typescript
import { ChangeDetectorRef } from '@angular/core';

export class UserComponent {
  user: User;
  
  constructor(private cdr: ChangeDetectorRef) {}
  
  updateUser() {
    // Mutate data (OnPush won't detect)
    this.user.name = 'New Name';
    
    // Mark for check
    this.cdr.markForCheck();
  }
  
  forceCheck() {
    // Immediate check
    this.cdr.detectChanges();
  }
  
  disableChangeDetection() {
    // Detach from change detection
    this.cdr.detach();
    
    // Later, reattach
    this.cdr.reattach();
  }
}
```

**Use Cases:**
- OnPush components with mutations
- Third-party libraries that mutate data
- Performance optimization
- Manual control over change detection

---

### What are Angular animations?

**Angular Animations** provide a way to animate DOM elements using CSS transitions/animations or JavaScript.

**Setup:**
```typescript
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

@NgModule({
  imports: [BrowserAnimationsModule]
})
export class AppModule {}
```

**Basic Animation:**
```typescript
import { trigger, state, style, transition, animate } from '@angular/animations';

@Component({
  selector: 'app-fade',
  template: '<div [@fadeInOut]="isVisible">Content</div>',
  animations: [
    trigger('fadeInOut', [
      state('in', style({ opacity: 1 })),
      state('out', style({ opacity: 0 })),
      transition('in => out', animate('300ms')),
      transition('out => in', animate('300ms'))
    ])
  ]
})
export class FadeComponent {
  isVisible = 'in';
  
  toggle() {
    this.isVisible = this.isVisible === 'in' ? 'out' : 'in';
  }
}
```

**Common Animations:**
```typescript
animations: [
  // Fade
  trigger('fade', [
    transition(':enter', [
      style({ opacity: 0 }),
      animate('300ms', style({ opacity: 1 }))
    ]),
    transition(':leave', [
      animate('300ms', style({ opacity: 0 }))
    ])
  ]),
  
  // Slide
  trigger('slide', [
    transition(':enter', [
      style({ transform: 'translateX(-100%)' }),
      animate('300ms', style({ transform: 'translateX(0)' }))
    ])
  ]),
  
  // Scale
  trigger('scale', [
    transition(':enter', [
      style({ transform: 'scale(0)' }),
      animate('300ms', style({ transform: 'scale(1)' }))
    ])
  ])
]
```

**Usage:**
```html
<div [@fade] *ngIf="isVisible">Content</div>
<div [@slide] *ngFor="let item of items">Item</div>
```

---

### What is ngZone?

**NgZone** is Angular's zone that patches async operations to trigger change detection.

**How it Works:**
- Zone.js patches async operations (setTimeout, HTTP, events)
- When async operation completes, NgZone notifies Angular
- Angular runs change detection

**Running Outside NgZone:**
```typescript
import { NgZone } from '@angular/core';

export class PerformanceComponent {
  constructor(private ngZone: NgZone) {}
  
  heavyOperation() {
    // Run outside Angular zone (no change detection)
    this.ngZone.runOutsideAngular(() => {
      // Heavy computation
      for (let i = 0; i < 1000000; i++) {
        // Do work
      }
      
      // Manually trigger change detection when done
      this.ngZone.run(() => {
        this.result = computedValue;
      });
    });
  }
}
```

**Use Cases:**
- Performance optimization
- Third-party libraries
- Heavy computations
- Frequent updates (canvas, animations)

---

### What is the difference between markForCheck() and detectChanges()?

**markForCheck()**: Marks component for check in the next change detection cycle
**detectChanges()**: Immediately runs change detection

**markForCheck() Example:**
```typescript
export class UserComponent {
  constructor(private cdr: ChangeDetectorRef) {}
  
  updateUser() {
    this.user.name = 'New Name';
    this.cdr.markForCheck();  // Schedules check for next cycle
    // Change detection runs later (async)
  }
}
```

**detectChanges() Example:**
```typescript
export class UserComponent {
  constructor(private cdr: ChangeDetectorRef) {}
  
  updateUser() {
    this.user.name = 'New Name';
    this.cdr.detectChanges();  // Runs immediately (sync)
    // Change detection runs now
  }
}
```

**Key Differences:**

| Feature | markForCheck() | detectChanges() |
|---------|----------------|-----------------|
| **Timing** | Next cycle (async) | Immediate (sync) |
| **Scope** | Component and parents | Component and children |
| **Use Case** | OnPush components | Immediate updates needed |
| **Performance** | Better (batched) | Can be expensive |

**When to Use:**

**Use markForCheck() when:**
- OnPush component with mutations
- Want to batch changes
- Normal use case

**Use detectChanges() when:**
- Need immediate update
- Working with third-party libraries
- Testing scenarios

**Best Practice:** Prefer `markForCheck()` for most cases. Use `detectChanges()` only when immediate update is required.

