# Angular Q&A - Part 5: Modules, Architecture & Testing

## 🔹 Modules & Architecture

### What is the difference between declarations, imports, providers, and exports in @NgModule?

**@NgModule** decorator configures Angular modules with four main properties:

**1. declarations** - Components, directives, pipes that belong to this module
```typescript
@NgModule({
  declarations: [
    UserComponent,      // Component
    HighlightDirective, // Directive
    UppercasePipe       // Pipe
  ]
})
```
- Must declare all components/directives/pipes used in module templates
- Cannot declare the same class in multiple modules
- Only declare what this module owns

**2. imports** - Other modules whose exported classes this module needs
```typescript
@NgModule({
  imports: [
    CommonModule,        // For *ngIf, *ngFor, etc.
    FormsModule,         // For ngModel
    ReactiveFormsModule,  // For reactive forms
    HttpClientModule,    // For HTTP
    RouterModule,        // For routing
    FeatureModule        // Other feature modules
  ]
})
```
- Import modules to use their exported declarations
- Import only what you need

**3. providers** - Services available to this module and its children
```typescript
@NgModule({
  providers: [
    UserService,         // Provided at module level
    { provide: API_URL, useValue: 'https://api.example.com' }
  ]
})
```
- Services available for dependency injection
- Module-level providers create new instances per module
- Use `providedIn: 'root'` instead (recommended)

**4. exports** - Classes that other modules can import
```typescript
@NgModule({
  declarations: [UserComponent, SharedPipe],
  exports: [
    UserComponent,      // Other modules can use this
    SharedPipe          // Other modules can use this
  ]
})
```
- Makes declarations available to importing modules
- Only export what should be reusable

**Complete Example:**
```typescript
@NgModule({
  declarations: [
    // What this module owns
    UserListComponent,
    UserDetailComponent,
    UserCardComponent
  ],
  imports: [
    // What this module needs
    CommonModule,
    FormsModule,
    UserRoutingModule
  ],
  providers: [
    // Services for this module (prefer providedIn: 'root')
    // UserService  // Not needed if using providedIn: 'root'
  ],
  exports: [
    // What other modules can use
    UserCardComponent  // Reusable component
  ]
})
export class UserModule {}
```

**Summary:**

| Property | Purpose | Contains |
|----------|---------|----------|
| **declarations** | Define what module owns | Components, directives, pipes |
| **imports** | Use other modules | Other Angular modules |
| **providers** | Provide services | Services, tokens |
| **exports** | Share with others | Components, directives, pipes |

---

### What is a feature module?

**Feature Module** is a module that encapsulates a specific feature or domain of the application.

**Characteristics:**
- Groups related functionality
- Can be lazy-loaded
- Has its own routing
- Declares feature-specific components
- Provides feature-specific services

**Example:**
```typescript
// users/users.module.ts
@NgModule({
  declarations: [
    UserListComponent,
    UserDetailComponent,
    UserFormComponent
  ],
  imports: [
    CommonModule,
    UsersRoutingModule,  // Feature routing
    SharedModule         // Shared components
  ],
  providers: [
    UserService  // Feature-specific service
  ]
})
export class UsersModule {}
```

**Feature Module Structure:**
```
users/
  ├── users.module.ts
  ├── users-routing.module.ts
  ├── user-list/
  │   └── user-list.component.ts
  ├── user-detail/
  │   └── user-detail.component.ts
  └── services/
      └── user.service.ts
```

**Benefits:**
- **Organization**: Related code grouped together
- **Lazy Loading**: Load on demand
- **Encapsulation**: Feature is self-contained
- **Reusability**: Can be reused in other apps
- **Team Collaboration**: Different teams work on different modules

**Lazy-Loaded Feature Module:**
```typescript
// app-routing.module.ts
const routes: Routes = [
  {
    path: 'users',
    loadChildren: () => import('./users/users.module').then(m => m.UsersModule)
  }
];
```

---

### What is a shared module?

**Shared Module** is a module that exports commonly used components, directives, pipes, and modules that are used across multiple feature modules.

**Purpose:**
- Avoid duplicating common declarations
- Centralize shared UI components
- Export commonly used modules

**Example:**
```typescript
// shared/shared.module.ts
@NgModule({
  declarations: [
    // Shared components
    ButtonComponent,
    CardComponent,
    ModalComponent,
    // Shared directives
    HighlightDirective,
    ClickOutsideDirective,
    // Shared pipes
    TruncatePipe,
    CurrencyPipe
  ],
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule
  ],
  exports: [
    // Export what other modules need
    ButtonComponent,
    CardComponent,
    ModalComponent,
    HighlightDirective,
    TruncatePipe,
    // Re-export modules
    CommonModule,        // So other modules don't need to import
    FormsModule,
    ReactiveFormsModule
  ]
})
export class SharedModule {}
```

**Usage in Feature Modules:**
```typescript
// users/users.module.ts
@NgModule({
  declarations: [UserListComponent],
  imports: [
    SharedModule  // Get all shared components, directives, pipes
  ]
})
export class UsersModule {}

// Now UserListComponent can use:
// - ButtonComponent
// - CardComponent
// - *ngIf, *ngFor (from CommonModule)
// - ngModel (from FormsModule)
```

**Best Practices:**
- Don't provide services in SharedModule (use CoreModule or providedIn: 'root')
- Only export what's truly shared
- Re-export commonly used modules (CommonModule, FormsModule)
- Keep it focused (don't make it a dumping ground)

---

### What is a core module?

**Core Module** is a module that provides singleton services and app-wide components that should be imported only once (in AppModule).

**Purpose:**
- Provide singleton services
- App-wide components (header, footer, navigation)
- Ensure single instance of services
- Prevent multiple imports

**Example:**
```typescript
// core/core.module.ts
@NgModule({
  declarations: [
    HeaderComponent,
    FooterComponent,
    NavigationComponent
  ],
  imports: [
    CommonModule,
    RouterModule
  ],
  exports: [
    HeaderComponent,
    FooterComponent,
    NavigationComponent
  ],
  providers: [
    // Singleton services (though providedIn: 'root' is preferred)
    AuthService,
    LoggerService,
    NotificationService
  ]
})
export class CoreModule {
  // Prevent multiple imports
  constructor(@Optional() @SkipSelf() parentModule: CoreModule) {
    if (parentModule) {
      throw new Error(
        'CoreModule is already loaded. Import it in the AppModule only.'
      );
    }
  }
}
```

**Usage:**
```typescript
// app.module.ts
@NgModule({
  imports: [
    BrowserModule,
    AppRoutingModule,
    CoreModule  // Import only once
  ]
})
export class AppModule {}
```

**Modern Approach (Angular 6+):**
```typescript
// Prefer providedIn: 'root' instead
@Injectable({ providedIn: 'root' })
export class AuthService {}

// No need for CoreModule providers
// But still use CoreModule for app-wide components
```

**Core Module Structure:**
```
core/
  ├── core.module.ts
  ├── services/
  │   ├── auth.service.ts
  │   ├── logger.service.ts
  │   └── notification.service.ts
  ├── components/
  │   ├── header/
  │   ├── footer/
  │   └── navigation/
  └── interceptors/
      └── auth.interceptor.ts
```

---

### What is the difference between forRoot() and forChild()?

**forRoot()** and **forChild()** are static methods used to configure modules differently for root and feature modules.

**Purpose:**
- Prevent multiple instances of services
- Configure modules appropriately
- Common pattern for modules that provide services

**forRoot() Example:**
```typescript
// shared/shared.module.ts
@NgModule({})
export class SharedModule {
  static forRoot(config: Config): ModuleWithProviders<SharedModule> {
    return {
      ngModule: SharedModule,
      providers: [
        {
          provide: CONFIG_TOKEN,
          useValue: config
        },
        LoggerService  // Singleton service
      ]
    };
  }
  
  static forChild(): ModuleWithProviders<SharedModule> {
    return {
      ngModule: SharedModule
      // No providers - uses root providers
    };
  }
}
```

**Usage:**
```typescript
// app.module.ts (Root)
@NgModule({
  imports: [
    SharedModule.forRoot({ apiUrl: 'https://api.example.com' })
  ]
})
export class AppModule {}

// feature.module.ts (Child)
@NgModule({
  imports: [
    SharedModule.forChild()  // No providers, uses root config
  ]
})
export class FeatureModule {}
```

**Common Use Case - RouterModule:**
```typescript
// App module - use forRoot
@NgModule({
  imports: [
    RouterModule.forRoot(routes)  // Creates router singleton
  ]
})
export class AppModule {}

// Feature module - use forChild
@NgModule({
  imports: [
    RouterModule.forChild(featureRoutes)  // Uses existing router
  ]
})
export class FeatureModule {}
```

**Why Use This Pattern:**
- **Prevent Duplicates**: Services provided only once
- **Configuration**: Root gets config, children use it
- **Best Practice**: Standard Angular pattern

**Example Implementation:**
```typescript
@NgModule({})
export class ConfigModule {
  static forRoot(config: AppConfig): ModuleWithProviders<ConfigModule> {
    return {
      ngModule: ConfigModule,
      providers: [
        { provide: APP_CONFIG, useValue: config },
        ConfigService
      ]
    };
  }
  
  static forChild(): ModuleWithProviders<ConfigModule> {
    return {
      ngModule: ConfigModule
      // No providers - uses root providers
    };
  }
}
```

---

## 🔹 Testing

### How do you test Angular components?

**Angular Testing** uses Jasmine (testing framework) and Karma (test runner) with Angular's testing utilities.

**Basic Component Test:**
```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { UserComponent } from './user.component';

describe('UserComponent', () => {
  let component: UserComponent;
  let fixture: ComponentFixture<UserComponent>;
  
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [UserComponent],
      imports: [CommonModule]
    }).compileComponents();
    
    fixture = TestBed.createComponent(UserComponent);
    component = fixture.componentInstance;
  });
  
  it('should create', () => {
    expect(component).toBeTruthy();
  });
  
  it('should display user name', () => {
    component.user = { id: 1, name: 'John' };
    fixture.detectChanges();  // Trigger change detection
    
    const compiled = fixture.nativeElement;
    expect(compiled.querySelector('h1').textContent).toContain('John');
  });
  
  it('should emit event on button click', () => {
    spyOn(component.userSelected, 'emit');
    
    const button = fixture.nativeElement.querySelector('button');
    button.click();
    
    expect(component.userSelected.emit).toHaveBeenCalled();
  });
});
```

**Testing with Dependencies:**
```typescript
describe('UserListComponent', () => {
  let component: UserListComponent;
  let fixture: ComponentFixture<UserListComponent>;
  let userService: jasmine.SpyObj<UserService>;
  
  beforeEach(async () => {
    const spy = jasmine.createSpyObj('UserService', ['getUsers']);
    
    await TestBed.configureTestingModule({
      declarations: [UserListComponent],
      providers: [
        { provide: UserService, useValue: spy }
      ]
    }).compileComponents();
    
    userService = TestBed.inject(UserService) as jasmine.SpyObj<UserService>;
    fixture = TestBed.createComponent(UserListComponent);
    component = fixture.componentInstance;
  });
  
  it('should load users on init', () => {
    const mockUsers = [{ id: 1, name: 'John' }];
    userService.getUsers.and.returnValue(of(mockUsers));
    
    fixture.detectChanges();
    
    expect(userService.getUsers).toHaveBeenCalled();
    expect(component.users).toEqual(mockUsers);
  });
});
```

**Testing Template:**
```typescript
it('should render user list', () => {
  component.users = [
    { id: 1, name: 'John' },
    { id: 2, name: 'Jane' }
  ];
  fixture.detectChanges();
  
  const compiled = fixture.nativeElement;
  const userElements = compiled.querySelectorAll('.user-item');
  
  expect(userElements.length).toBe(2);
  expect(userElements[0].textContent).toContain('John');
});
```

**Testing Events:**
```typescript
it('should handle form submission', () => {
  spyOn(component, 'onSubmit');
  
  const form = fixture.nativeElement.querySelector('form');
  form.dispatchEvent(new Event('submit'));
  
  expect(component.onSubmit).toHaveBeenCalled();
});
```

---

### What is Jasmine and Karma?

**Jasmine** is a behavior-driven development (BDD) testing framework for JavaScript.

**Jasmine Features:**
- Describe blocks (test suites)
- It blocks (test cases)
- Expectations (assertions)
- Spies (mocks)
- Matchers (expectations)

**Jasmine Syntax:**
```typescript
describe('UserService', () => {
  let service: UserService;
  
  beforeEach(() => {
    service = new UserService();
  });
  
  it('should return users', () => {
    const users = service.getUsers();
    expect(users).toBeDefined();
    expect(users.length).toBeGreaterThan(0);
  });
  
  it('should handle errors', () => {
    expect(() => service.getUser(-1)).toThrow();
  });
});
```

**Karma** is a test runner that executes tests in real browsers.

**Karma Features:**
- Runs tests in browsers
- Watches files for changes
- Generates coverage reports
- Integrates with CI/CD

**Karma Configuration (karma.conf.js):**
```javascript
module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine', '@angular-devkit/build-angular'],
    browsers: ['Chrome'],
    autoWatch: true,
    singleRun: false
  });
};
```

**Running Tests:**
```bash
# Run tests
ng test

# Run with coverage
ng test --code-coverage

# Run once and exit
ng test --watch=false
```

---

### How do you test services?

**Service Testing:**
```typescript
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
  
  afterEach(() => {
    httpMock.verify();  // Verify no outstanding requests
  });
  
  it('should be created', () => {
    expect(service).toBeTruthy();
  });
  
  it('should fetch users', () => {
    const mockUsers = [{ id: 1, name: 'John' }];
    
    service.getUsers().subscribe(users => {
      expect(users).toEqual(mockUsers);
    });
    
    const req = httpMock.expectOne('/api/users');
    expect(req.request.method).toBe('GET');
    req.flush(mockUsers);
  });
  
  it('should handle errors', () => {
    service.getUsers().subscribe({
      next: () => fail('should have failed'),
      error: (error) => {
        expect(error.status).toBe(500);
      }
    });
    
    const req = httpMock.expectOne('/api/users');
    req.error(new ErrorEvent('Server error'), { status: 500 });
  });
});
```

**Service with Dependencies:**
```typescript
describe('UserService', () => {
  let service: UserService;
  let logger: jasmine.SpyObj<LoggerService>;
  
  beforeEach(() => {
    const loggerSpy = jasmine.createSpyObj('LoggerService', ['log']);
    
    TestBed.configureTestingModule({
      providers: [
        UserService,
        { provide: LoggerService, useValue: loggerSpy }
      ]
    });
    
    service = TestBed.inject(UserService);
    logger = TestBed.inject(LoggerService) as jasmine.SpyObj<LoggerService>;
  });
  
  it('should log when getting users', () => {
    service.getUsers();
    expect(logger.log).toHaveBeenCalledWith('Fetching users');
  });
});
```

---

### What is TestBed?

**TestBed** is Angular's testing utility that creates a dynamic testing module.

**Purpose:**
- Configure testing module
- Create components/services
- Provide dependencies
- Simulate Angular environment

**Basic Usage:**
```typescript
beforeEach(async () => {
  await TestBed.configureTestingModule({
    declarations: [UserComponent],
    imports: [CommonModule],
    providers: [UserService]
  }).compileComponents();
});
```

**TestBed Methods:**
```typescript
// Configure module
TestBed.configureTestingModule({...});

// Create component
const fixture = TestBed.createComponent(UserComponent);

// Get service
const service = TestBed.inject(UserService);

// Override provider
TestBed.overrideProvider(UserService, {
  useValue: mockUserService
});

// Reset (between tests)
TestBed.resetTestingModule();
```

**Complete Example:**
```typescript
describe('UserComponent', () => {
  let component: UserComponent;
  let fixture: ComponentFixture<UserComponent>;
  let userService: UserService;
  
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [UserComponent],
      imports: [HttpClientTestingModule],
      providers: [UserService]
    }).compileComponents();
    
    fixture = TestBed.createComponent(UserComponent);
    component = fixture.componentInstance;
    userService = TestBed.inject(UserService);
  });
  
  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
```

---

### How do you test HTTP calls?

**Testing HTTP with HttpClientTestingModule:**
```typescript
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';

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
  
  afterEach(() => {
    httpMock.verify();  // Ensure no outstanding requests
  });
  
  it('should GET users', () => {
    const mockUsers = [{ id: 1, name: 'John' }];
    
    service.getUsers().subscribe(users => {
      expect(users).toEqual(mockUsers);
    });
    
    // Expect one request
    const req = httpMock.expectOne('/api/users');
    expect(req.request.method).toBe('GET');
    
    // Respond with mock data
    req.flush(mockUsers);
  });
  
  it('should POST user', () => {
    const newUser = { name: 'Jane' };
    const createdUser = { id: 2, name: 'Jane' };
    
    service.createUser(newUser).subscribe(user => {
      expect(user).toEqual(createdUser);
    });
    
    const req = httpMock.expectOne('/api/users');
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual(newUser);
    req.flush(createdUser);
  });
  
  it('should handle 404 error', () => {
    service.getUser(999).subscribe({
      next: () => fail('should have failed'),
      error: (error) => {
        expect(error.status).toBe(404);
      }
    });
    
    const req = httpMock.expectOne('/api/users/999');
    req.flush('Not found', { status: 404, statusText: 'Not Found' });
  });
  
  it('should handle network error', () => {
    service.getUsers().subscribe({
      next: () => fail('should have failed'),
      error: (error) => {
        expect(error.error).toBeInstanceOf(ErrorEvent);
      }
    });
    
    const req = httpMock.expectOne('/api/users');
    req.error(new ErrorEvent('Network error'));
  });
});
```

**Testing with Query Parameters:**
```typescript
it('should send query parameters', () => {
  service.searchUsers('john').subscribe();
  
  const req = httpMock.expectOne(req => 
    req.url === '/api/users' && 
    req.params.get('q') === 'john'
  );
  
  expect(req.request.method).toBe('GET');
  req.flush([]);
});
```

**Testing Interceptors:**
```typescript
describe('AuthInterceptor', () => {
  let httpMock: HttpTestingController;
  let http: HttpClient;
  
  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [
        { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true }
      ]
    });
    
    http = TestBed.inject(HttpClient);
    httpMock = TestBed.inject(HttpTestingController);
  });
  
  it('should add auth header', () => {
    http.get('/api/users').subscribe();
    
    const req = httpMock.expectOne('/api/users');
    expect(req.request.headers.has('Authorization')).toBeTruthy();
    req.flush([]);
  });
});
```

**Best Practices:**
- Always call `httpMock.verify()` in `afterEach`
- Use `expectOne()` to verify requests
- Flush mock responses
- Test error scenarios
- Test request methods, URLs, headers, body

