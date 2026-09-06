# Angular Q&A - Part 3: Forms, HTTP & Observables

## 🔹 Forms

### What are the two approaches to forms in Angular?

Angular provides **two approaches** for handling forms:

1. **Template-Driven Forms** - Forms defined in the template
2. **Reactive Forms** - Forms defined in the component (programmatic)

**Template-Driven Forms:**
- Forms logic in template
- Uses `ngModel` directive
- Two-way data binding
- Simpler for basic forms
- Less control, harder to test

**Reactive Forms:**
- Forms logic in component
- Uses `FormControl`, `FormGroup`, `FormArray`
- Immutable, functional approach
- More control, easier to test
- Better for complex forms

**When to Use:**

| Use Template-Driven When | Use Reactive When |
|-------------------------|-------------------|
| Simple forms | Complex forms |
| Quick prototypes | Dynamic forms |
| Familiar with AngularJS | Need fine-grained control |
| | Need complex validation |
| | Need to test form logic |

---

### What is the difference between template-driven and reactive forms?

**Template-Driven Forms:**

```typescript
// Component
export class UserFormComponent {
  user = {
    name: '',
    email: ''
  };
  
  onSubmit(form: NgForm) {
    if (form.valid) {
      console.log(this.user);
    }
  }
}
```

```html
<!-- Template -->
<form #userForm="ngForm" (ngSubmit)="onSubmit(userForm)">
  <input 
    name="name" 
    [(ngModel)]="user.name" 
    required 
    minlength="3"
    #name="ngModel">
  <div *ngIf="name.invalid && name.touched">
    <span *ngIf="name.errors?.['required']">Name is required</span>
    <span *ngIf="name.errors?.['minlength']">Min 3 characters</span>
  </div>
  
  <input 
    name="email" 
    [(ngModel)]="user.email" 
    required 
    email
    #email="ngModel">
  
  <button type="submit" [disabled]="userForm.invalid">Submit</button>
</form>
```

**Reactive Forms:**

```typescript
// Component
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

export class UserFormComponent implements OnInit {
  userForm: FormGroup;
  
  constructor(private fb: FormBuilder) {}
  
  ngOnInit() {
    this.userForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]]
    });
  }
  
  onSubmit() {
    if (this.userForm.valid) {
      console.log(this.userForm.value);
    }
  }
}
```

```html
<!-- Template -->
<form [formGroup]="userForm" (ngSubmit)="onSubmit()">
  <input formControlName="name">
  <div *ngIf="userForm.get('name')?.invalid && userForm.get('name')?.touched">
    <span *ngIf="userForm.get('name')?.errors?.['required']">Name required</span>
    <span *ngIf="userForm.get('name')?.errors?.['minlength']">Min 3 chars</span>
  </div>
  
  <input formControlName="email">
  
  <button type="submit" [disabled]="userForm.invalid">Submit</button>
</form>
```

**Key Differences:**

| Feature | Template-Driven | Reactive |
|---------|----------------|----------|
| **Setup** | Template | Component |
| **Data Model** | Two-way binding | FormControl/FormGroup |
| **Validation** | Template directives | Validator functions |
| **Testing** | Harder | Easier |
| **Dynamic Forms** | Difficult | Easy |
| **Custom Validators** | Possible but complex | Straightforward |
| **Form State** | Less control | Full control |
| **Immutable** | No | Yes |

**Best Practice:** Use **Reactive Forms** for production applications - they're more powerful, testable, and maintainable.

---

### Explain FormControl, FormGroup, and FormArray.

**FormControl**: Represents a single form control (input, select, etc.)
**FormGroup**: Collection of FormControls
**FormArray**: Array of FormControls (dynamic lists)

**FormControl Example:**
```typescript
import { FormControl } from '@angular/forms';

export class MyComponent {
  // Create FormControl
  nameControl = new FormControl('John');  // Initial value: 'John'
  
  // With validators
  emailControl = new FormControl('', [
    Validators.required,
    Validators.email
  ]);
  
  // Access value
  getValue() {
    console.log(this.nameControl.value);  // Current value
    console.log(this.nameControl.valid);   // Validation status
    console.log(this.nameControl.errors);  // Validation errors
  }
  
  // Update value
  updateValue() {
    this.nameControl.setValue('Jane');
    this.nameControl.patchValue({ name: 'Jane' });  // Partial update
  }
}
```

```html
<!-- Template -->
<input [formControl]="nameControl">
<div *ngIf="nameControl.invalid && nameControl.touched">
  Errors: {{ nameControl.errors | json }}
</div>
```

**FormGroup Example:**
```typescript
import { FormGroup, FormControl } from '@angular/forms';

export class UserFormComponent {
  // Manual creation
  userForm = new FormGroup({
    name: new FormControl(''),
    email: new FormControl('', [Validators.required, Validators.email]),
    age: new FormControl(0, [Validators.min(18)])
  });
  
  // OR using FormBuilder (recommended)
  constructor(private fb: FormBuilder) {}
  
  userForm = this.fb.group({
    name: [''],
    email: ['', [Validators.required, Validators.email]],
    age: [0, [Validators.min(18)]]
  });
  
  onSubmit() {
    if (this.userForm.valid) {
      console.log(this.userForm.value);  // { name: '', email: '', age: 0 }
      console.log(this.userForm.get('email')?.value);  // Access specific control
    }
  }
  
  // Update form
  updateForm() {
    this.userForm.patchValue({
      name: 'John',
      email: 'john@example.com'
    });
    
    // OR setValue (must provide all fields)
    this.userForm.setValue({
      name: 'John',
      email: 'john@example.com',
      age: 25
    });
  }
}
```

```html
<!-- Template -->
<form [formGroup]="userForm" (ngSubmit)="onSubmit()">
  <input formControlName="name">
  <input formControlName="email">
  <input formControlName="age" type="number">
  
  <button [disabled]="userForm.invalid">Submit</button>
</form>
```

**FormArray Example:**
```typescript
import { FormArray } from '@angular/forms';

export class SkillsFormComponent {
  skillsForm = this.fb.group({
    name: [''],
    skills: this.fb.array([])  // Dynamic array
  });
  
  constructor(private fb: FormBuilder) {}
  
  // Getter for easy access
  get skills() {
    return this.skillsForm.get('skills') as FormArray;
  }
  
  // Add skill
  addSkill() {
    const skillControl = this.fb.control('', Validators.required);
    this.skills.push(skillControl);
  }
  
  // Remove skill
  removeSkill(index: number) {
    this.skills.removeAt(index);
  }
  
  // Initialize with existing skills
  initializeSkills(skills: string[]) {
    const skillControls = skills.map(skill => 
      this.fb.control(skill, Validators.required)
    );
    this.skillsForm.setControl('skills', this.fb.array(skillControls));
  }
  
  onSubmit() {
    console.log(this.skillsForm.value);
    // { name: 'John', skills: ['Angular', 'TypeScript'] }
  }
}
```

```html
<!-- Template -->
<form [formGroup]="skillsForm" (ngSubmit)="onSubmit()">
  <input formControlName="name">
  
  <div formArrayName="skills">
    <div *ngFor="let skill of skills.controls; let i = index" [formGroupName]="i">
      <input [formControl]="skill">
      <button type="button" (click)="removeSkill(i)">Remove</button>
    </div>
  </div>
  
  <button type="button" (click)="addSkill()">Add Skill</button>
  <button type="submit">Submit</button>
</form>
```

**Nested FormGroups:**
```typescript
userForm = this.fb.group({
  personalInfo: this.fb.group({
    firstName: [''],
    lastName: ['']
  }),
  address: this.fb.group({
    street: [''],
    city: ['']
  })
});
```

```html
<form [formGroup]="userForm">
  <div formGroupName="personalInfo">
    <input formControlName="firstName">
    <input formControlName="lastName">
  </div>
  
  <div formGroupName="address">
    <input formControlName="street">
    <input formControlName="city">
  </div>
</form>
```

---

### What are validators? How do you create custom validators?

**Validators** are functions that validate form control values. Angular provides built-in validators, and you can create custom ones.

**Built-in Validators:**
```typescript
import { Validators } from '@angular/forms';

this.form = this.fb.group({
  // Required
  name: ['', Validators.required],
  
  // Email
  email: ['', [Validators.required, Validators.email]],
  
  // Min/Max length
  password: ['', [Validators.required, Validators.minLength(8), Validators.maxLength(20)]],
  
  // Min/Max value
  age: [0, [Validators.min(18), Validators.max(100)]],
  
  // Pattern (regex)
  phone: ['', Validators.pattern('^[0-9]{10}$')],
  
  // Custom validator
  username: ['', [Validators.required, this.customValidator]]
});
```

**Custom Validator (Function):**
```typescript
// Synchronous validator
export function noSpacesValidator(control: AbstractControl): ValidationErrors | null {
  if (control.value && control.value.includes(' ')) {
    return { noSpaces: true };  // Error object
  }
  return null;  // Valid
}

// Usage
username: ['', [Validators.required, noSpacesValidator]]
```

**Custom Validator (Class):**
```typescript
import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

// Factory function (recommended)
export function passwordStrengthValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;  // Don't validate empty values
    }
    
    const hasUpperCase = /[A-Z]/.test(control.value);
    const hasLowerCase = /[a-z]/.test(control.value);
    const hasNumeric = /[0-9]/.test(control.value);
    const hasSpecial = /[!@#$%^&*]/.test(control.value);
    
    const valid = hasUpperCase && hasLowerCase && hasNumeric && hasSpecial;
    
    return valid ? null : { passwordStrength: true };
  };
}

// Usage
password: ['', [Validators.required, passwordStrengthValidator()]]
```

**Async Validator:**
```typescript
import { AbstractControl, AsyncValidatorFn } from '@angular/forms';
import { Observable, of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

export function uniqueUsernameValidator(userService: UserService): AsyncValidatorFn {
  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    if (!control.value) {
      return of(null);
    }
    
    return userService.checkUsername(control.value).pipe(
      map(exists => exists ? { usernameTaken: true } : null),
      catchError(() => of(null))
    );
  };
}

// Usage
username: ['', 
  [Validators.required],  // Sync validators
  [uniqueUsernameValidator(this.userService)]  // Async validators
]
```

**Cross-Field Validator:**
```typescript
export function passwordMatchValidator(): ValidatorFn {
  return (formGroup: AbstractControl): ValidationErrors | null => {
    const password = formGroup.get('password');
    const confirmPassword = formGroup.get('confirmPassword');
    
    if (!password || !confirmPassword) {
      return null;
    }
    
    if (password.value !== confirmPassword.value) {
      confirmPassword.setErrors({ passwordMismatch: true });
      return { passwordMismatch: true };
    } else {
      confirmPassword.setErrors(null);
      return null;
    }
  };
}

// Usage
this.form = this.fb.group({
  password: ['', Validators.required],
  confirmPassword: ['', Validators.required]
}, { validators: passwordMatchValidator() });
```

**Validator with Parameters:**
```typescript
export function minAgeValidator(minAge: number): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;
    }
    
    const age = new Date().getFullYear() - new Date(control.value).getFullYear();
    return age >= minAge ? null : { minAge: { required: minAge, actual: age } };
  };
}

// Usage
birthDate: ['', [Validators.required, minAgeValidator(18)]]
```

**Accessing Errors:**
```typescript
// In component
const emailControl = this.form.get('email');
if (emailControl?.hasError('required')) {
  console.log('Email is required');
}
if (emailControl?.hasError('email')) {
  console.log('Invalid email format');
}

// In template
<div *ngIf="form.get('email')?.hasError('required')">
  Email is required
</div>
<div *ngIf="form.get('email')?.hasError('email')">
  Invalid email format
</div>
```

---

### What is the difference between valid, invalid, touched, dirty, and pristine?

These are **form control states** that track validation and user interaction.

**States:**

1. **valid / invalid** - Validation status
   - `valid`: Control passes all validators
   - `invalid`: Control fails at least one validator

2. **touched / untouched** - User interaction
   - `touched`: User has focused and blurred the control
   - `untouched`: User has never focused the control

3. **dirty / pristine** - Value changes
   - `dirty`: User has changed the value
   - `pristine`: Value is unchanged from initial

4. **pending** - Async validation
   - `pending`: Async validator is running

**State Combinations:**
```typescript
// Control states
const control = this.form.get('email');

console.log(control?.valid);      // true/false
console.log(control?.invalid);    // true/false
console.log(control?.touched);    // true/false
console.log(control?.untouched); // true/false
console.log(control?.dirty);      // true/false
console.log(control?.pristine);  // true/false
console.log(control?.pending);   // true/false
```

**Common Patterns:**
```html
<!-- Show errors only when touched and invalid -->
<div *ngIf="form.get('email')?.invalid && form.get('email')?.touched">
  <span *ngIf="form.get('email')?.hasError('required')">Required</span>
  <span *ngIf="form.get('email')?.hasError('email')">Invalid email</span>
</div>

<!-- Disable submit if form is invalid or pristine -->
<button [disabled]="form.invalid || form.pristine">Submit</button>

<!-- Show "unsaved changes" warning if dirty -->
<div *ngIf="form.dirty">
  You have unsaved changes
</div>
```

**State Flow:**
```
Initial: pristine, untouched, invalid
  ↓ User focuses
untouched → touched (on blur)
  ↓ User types
pristine → dirty
  ↓ Validation runs
invalid → valid (if passes)
```

**Practical Example:**
```typescript
export class UserFormComponent {
  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]]
  });
  
  get emailControl() {
    return this.form.get('email');
  }
  
  // Check if should show errors
  shouldShowErrors() {
    return this.emailControl?.invalid && this.emailControl?.touched;
  }
  
  // Check if form can be submitted
  canSubmit() {
    return this.form.valid && this.form.dirty;
  }
}
```

```html
<input formControlName="email">
<div *ngIf="shouldShowErrors()">
  <span *ngIf="emailControl?.hasError('required')">Required</span>
  <span *ngIf="emailControl?.hasError('email')">Invalid email</span>
</div>

<button [disabled]="!canSubmit()">Submit</button>
```

---

### How do you handle form submission?

**Template-Driven Form Submission:**
```typescript
export class UserFormComponent {
  user = { name: '', email: '' };
  
  onSubmit(form: NgForm) {
    if (form.valid) {
      console.log('Form submitted:', this.user);
      // Send to server
      this.userService.createUser(this.user).subscribe(
        response => console.log('Success:', response),
        error => console.error('Error:', error)
      );
    } else {
      // Mark all fields as touched to show errors
      Object.keys(form.controls).forEach(key => {
        form.controls[key].markAsTouched();
      });
    }
  }
}
```

```html
<form #userForm="ngForm" (ngSubmit)="onSubmit(userForm)">
  <input name="name" [(ngModel)]="user.name" required>
  <input name="email" [(ngModel)]="user.email" required email>
  <button type="submit" [disabled]="userForm.invalid">Submit</button>
</form>
```

**Reactive Form Submission:**
```typescript
export class UserFormComponent {
  form: FormGroup;
  isSubmitting = false;
  
  constructor(
    private fb: FormBuilder,
    private userService: UserService
  ) {
    this.form = this.fb.group({
      name: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]]
    });
  }
  
  onSubmit() {
    if (this.form.valid) {
      this.isSubmitting = true;
      
      this.userService.createUser(this.form.value).subscribe({
        next: (response) => {
          console.log('Success:', response);
          this.form.reset();  // Reset form
          this.isSubmitting = false;
        },
        error: (error) => {
          console.error('Error:', error);
          this.handleError(error);
          this.isSubmitting = false;
        }
      });
    } else {
      // Mark all fields as touched
      this.markFormGroupTouched(this.form);
    }
  }
  
  private markFormGroupTouched(formGroup: FormGroup) {
    Object.keys(formGroup.controls).forEach(key => {
      const control = formGroup.get(key);
      control?.markAsTouched();
      
      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }
  
  private handleError(error: any) {
    if (error.status === 400) {
      // Handle validation errors from server
      const serverErrors = error.error.errors;
      Object.keys(serverErrors).forEach(key => {
        const control = this.form.get(key);
        if (control) {
          control.setErrors({ serverError: serverErrors[key] });
        }
      });
    }
  }
}
```

```html
<form [formGroup]="form" (ngSubmit)="onSubmit()">
  <input formControlName="name">
  <div *ngIf="form.get('name')?.invalid && form.get('name')?.touched">
    <span *ngIf="form.get('name')?.hasError('serverError')">
      {{ form.get('name')?.errors?.['serverError'] }}
    </span>
  </div>
  
  <input formControlName="email">
  
  <button type="submit" [disabled]="form.invalid || isSubmitting">
    {{ isSubmitting ? 'Submitting...' : 'Submit' }}
  </button>
</form>
```

**Prevent Default Submission:**
```typescript
onSubmit(event: Event) {
  event.preventDefault();
  // Handle submission
}
```

---

### What is ngModel and when is it used?

**ngModel** is a directive used in **template-driven forms** for two-way data binding.

**Basic Usage:**
```html
<!-- Two-way binding -->
<input [(ngModel)]="userName" name="userName">

<!-- One-way binding (property) -->
<input [ngModel]="userName" name="userName">

<!-- One-way binding (event) -->
<input (ngModelChange)="onNameChange($event)" name="userName">
```

**With Forms:**
```typescript
export class UserFormComponent {
  user = {
    name: '',
    email: ''
  };
}
```

```html
<form #userForm="ngForm">
  <!-- Must have 'name' attribute for ngModel to work in forms -->
  <input 
    name="name" 
    [(ngModel)]="user.name" 
    required
    #name="ngModel">
  
  <input 
    name="email" 
    [(ngModel)]="user.email" 
    required 
    email
    #email="ngModel">
  
  <!-- Access form state -->
  <div>Form valid: {{ userForm.valid }}</div>
  <div>Name touched: {{ name.touched }}</div>
  
  <button [disabled]="userForm.invalid">Submit</button>
</form>
```

**When to Use ngModel:**
- Template-driven forms
- Simple forms with two-way binding
- Quick prototypes
- Standalone inputs (not in reactive forms)

**When NOT to Use ngModel:**
- Reactive forms (use FormControl instead)
- Complex validation
- Dynamic forms

**Standalone ngModel (Angular 9+):**
```typescript
// No need to import FormsModule for standalone
@Component({
  standalone: true,
  imports: [CommonModule]  // ngModel available
})
```

---

### How do you set default values in reactive forms?

**Method 1: FormBuilder (Initial Values)**
```typescript
this.form = this.fb.group({
  name: ['John Doe'],  // Default value
  email: ['john@example.com'],
  age: [25]
});
```

**Method 2: setValue (All Fields Required)**
```typescript
this.form.setValue({
  name: 'John Doe',
  email: 'john@example.com',
  age: 25
});
```

**Method 3: patchValue (Partial Update)**
```typescript
this.form.patchValue({
  name: 'John Doe',
  email: 'john@example.com'
  // age not required
});
```

**Method 4: Load from Service**
```typescript
export class UserEditComponent implements OnInit {
  form: FormGroup;
  
  ngOnInit() {
    this.form = this.fb.group({
      name: [''],
      email: ['']
    });
    
    // Load user data
    this.userService.getUser(this.userId).subscribe(user => {
      this.form.patchValue(user);  // Set form values from API
    });
  }
}
```

**Method 5: Using Resolver**
```typescript
// Resolver loads data before component
@Injectable()
export class UserResolver implements Resolve<User> {
  resolve(route: ActivatedRouteSnapshot): Observable<User> {
    return this.userService.getUser(route.params['id']);
  }
}

// Component
export class UserEditComponent implements OnInit {
  form: FormGroup;
  
  ngOnInit() {
    this.form = this.fb.group({
      name: [''],
      email: ['']
    });
    
    // Data pre-loaded by resolver
    const user = this.route.snapshot.data['user'];
    this.form.patchValue(user);
  }
}
```

**Method 6: Reset with Defaults**
```typescript
this.form.reset({
  name: 'John Doe',
  email: 'john@example.com',
  age: 25
});
```

**Nested FormGroups:**
```typescript
this.form = this.fb.group({
  personalInfo: this.fb.group({
    firstName: ['John'],
    lastName: ['Doe']
  }),
  address: this.fb.group({
    street: ['123 Main St'],
    city: ['New York']
  })
});

// Set nested values
this.form.patchValue({
  personalInfo: {
    firstName: 'Jane',
    lastName: 'Smith'
  }
});
```

**FormArray Defaults:**
```typescript
this.form = this.fb.group({
  skills: this.fb.array([
    this.fb.control('Angular'),
    this.fb.control('TypeScript')
  ])
});
```

---

## 🔹 HTTP & Observables

### What is HttpClient?

**HttpClient** is Angular's service for making HTTP requests. It's built on top of RxJS Observables.

**Setup:**
```typescript
// app.module.ts
import { HttpClientModule } from '@angular/common/http';

@NgModule({
  imports: [HttpClientModule]
})
export class AppModule {}
```

**Basic Usage:**
```typescript
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class UserService {
  private apiUrl = 'https://api.example.com';
  
  constructor(private http: HttpClient) {}
  
  // GET request
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(`${this.apiUrl}/users`);
  }
  
  // GET with params
  getUser(id: number): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/users/${id}`);
  }
  
  // POST request
  createUser(user: User): Observable<User> {
    return this.http.post<User>(`${this.apiUrl}/users`, user);
  }
  
  // PUT request
  updateUser(id: number, user: User): Observable<User> {
    return this.http.put<User>(`${this.apiUrl}/users/${id}`, user);
  }
  
  // DELETE request
  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/users/${id}`);
  }
  
  // PATCH request
  patchUser(id: number, updates: Partial<User>): Observable<User> {
    return this.http.patch<User>(`${this.apiUrl}/users/${id}`, updates);
  }
}
```

**Request Options:**
```typescript
// With headers
getUsers(): Observable<User[]> {
  return this.http.get<User[]>(`${this.apiUrl}/users`, {
    headers: {
      'Authorization': 'Bearer token',
      'Content-Type': 'application/json'
    }
  });
}

// With query parameters
searchUsers(query: string): Observable<User[]> {
  const params = new HttpParams().set('q', query).set('limit', '10');
  return this.http.get<User[]>(`${this.apiUrl}/users`, { params });
}

// With response type
downloadFile(): Observable<Blob> {
  return this.http.get(`${this.apiUrl}/file`, {
    responseType: 'blob'
  });
}

// Full request options
this.http.request('GET', url, {
  headers: {},
  params: {},
  responseType: 'json',
  observe: 'response'  // Get full HttpResponse
});
```

**Using in Component:**
```typescript
export class UserListComponent implements OnInit {
  users: User[] = [];
  
  constructor(private userService: UserService) {}
  
  ngOnInit() {
    this.userService.getUsers().subscribe({
      next: (users) => this.users = users,
      error: (error) => console.error('Error:', error)
    });
  }
}
```

---

### What are Observables and how do they differ from Promises?

**Observables** are streams of data that can emit multiple values over time. They're part of RxJS.

**Key Differences:**

| Feature | Observable | Promise |
|---------|-----------|---------|
| **Values** | Multiple (stream) | Single |
| **Execution** | Lazy (only when subscribed) | Eager (immediate) |
| **Cancellation** | Yes (unsubscribe) | No |
| **Operators** | Many (map, filter, etc.) | Limited (then, catch) |
| **Multiple Listeners** | Yes (multicast) | No (single) |

**Observable Example:**
```typescript
import { Observable } from 'rxjs';

// Create observable
const observable = new Observable(observer => {
  observer.next(1);
  observer.next(2);
  observer.next(3);
  setTimeout(() => observer.next(4), 1000);
  observer.complete();
});

// Subscribe
const subscription = observable.subscribe({
  next: value => console.log(value),  // 1, 2, 3, 4
  error: err => console.error(err),
  complete: () => console.log('Done')
});

// Cancel
subscription.unsubscribe();
```

**Promise Example:**
```typescript
// Create promise
const promise = new Promise((resolve, reject) => {
  resolve(1);
  // Can only resolve once
});

// Use
promise.then(value => console.log(value));
```

**HTTP Example:**
```typescript
// Observable (can be cancelled)
const subscription = this.http.get('/api/users').subscribe(users => {
  console.log(users);
});

// Cancel if component destroyed
ngOnDestroy() {
  subscription.unsubscribe();
}

// Promise (cannot be cancelled)
this.http.get('/api/users').toPromise().then(users => {
  console.log(users);
});
```

**When to Use:**
- **Observables**: HTTP requests, events, streams, cancellable operations
- **Promises**: One-time async operations, simple async/await patterns

---

### What is RxJS?

**RxJS (Reactive Extensions for JavaScript)** is a library for reactive programming using Observables.

**Key Concepts:**
- **Observable**: Stream of data
- **Observer**: Consumer of data
- **Operators**: Functions to transform streams
- **Subscription**: Connection between Observable and Observer

**Common Operators:**
```typescript
import { of, from } from 'rxjs';
import { map, filter, tap, catchError, switchMap, mergeMap } from 'rxjs/operators';

// Creation
const numbers$ = of(1, 2, 3, 4, 5);
const array$ = from([1, 2, 3]);

// Transformation
numbers$.pipe(
  map(x => x * 2),        // [2, 4, 6, 8, 10]
  filter(x => x > 5),     // [6, 8, 10]
  tap(x => console.log(x)) // Side effect
).subscribe();

// Error handling
this.http.get('/api/users').pipe(
  catchError(error => {
    console.error(error);
    return of([]);  // Return fallback
  })
).subscribe();
```

**RxJS in Angular:**
- HTTP requests return Observables
- Forms use Observables (valueChanges, statusChanges)
- Router events are Observables
- Async pipe subscribes automatically

---

### Explain operators: map, filter, switchMap, mergeMap, concatMap.

**map**: Transforms each emitted value
```typescript
of(1, 2, 3).pipe(
  map(x => x * 2)
).subscribe(console.log);  // 2, 4, 6
```

**filter**: Filters emitted values
```typescript
of(1, 2, 3, 4, 5).pipe(
  filter(x => x > 3)
).subscribe(console.log);  // 4, 5
```

**switchMap**: Cancels previous inner observable when new value arrives
```typescript
// Use case: Search with cancellation
this.searchControl.valueChanges.pipe(
  switchMap(query => this.userService.searchUsers(query))
).subscribe(users => {
  // Previous search cancelled if new search starts
  this.users = users;
});
```

**mergeMap (flatMap)**: Runs all inner observables concurrently
```typescript
// Use case: Multiple parallel requests
of(1, 2, 3).pipe(
  mergeMap(id => this.userService.getUser(id))
).subscribe(user => {
  // All requests run in parallel
  console.log(user);
});
```

**concatMap**: Runs inner observables sequentially
```typescript
// Use case: Sequential requests
of(1, 2, 3).pipe(
  concatMap(id => this.userService.getUser(id))
).subscribe(user => {
  // Requests run one after another
  console.log(user);
});
```

**Comparison:**
```typescript
// switchMap: Latest only (cancels previous)
// mergeMap: All concurrent (parallel)
// concatMap: Sequential (one after another)
// exhaustMap: Ignore new until current completes
```

---

### What is the difference between subscribe() and async pipe?

**subscribe()**: Manual subscription management
**async pipe**: Automatic subscription/unsubscription

**subscribe() Example:**
```typescript
export class UserComponent implements OnInit, OnDestroy {
  users: User[] = [];
  private subscription: Subscription;
  
  ngOnInit() {
    this.subscription = this.userService.getUsers().subscribe(users => {
      this.users = users;
    });
  }
  
  ngOnDestroy() {
    this.subscription.unsubscribe();  // Must unsubscribe!
  }
}
```

**async pipe Example:**
```typescript
export class UserComponent {
  users$ = this.userService.getUsers();  // Observable
  
  // No need for subscribe/unsubscribe
  // No need for OnDestroy
}
```

```html
<!-- Template -->
<div *ngFor="let user of users$ | async">
  {{ user.name }}
</div>

<!-- With loading state -->
<ng-container *ngIf="users$ | async as users; else loading">
  <div *ngFor="let user of users">{{ user.name }}</div>
</ng-container>
<ng-template #loading>Loading...</ng-template>
```

**Key Differences:**

| Feature | subscribe() | async pipe |
|---------|-------------|------------|
| **Unsubscribe** | Manual | Automatic |
| **Memory Leaks** | Risk if forgotten | Safe |
| **OnDestroy** | Required | Not needed |
| **Change Detection** | Manual (OnPush issues) | Automatic |
| **Multiple Subscriptions** | Possible | One per template |

**Best Practice:** Use **async pipe** in templates when possible. Use `subscribe()` only when you need side effects or complex logic.

---

### How do you handle HTTP errors?

**Method 1: catchError Operator**
```typescript
import { catchError } from 'rxjs/operators';
import { throwError, of } from 'rxjs';

this.userService.getUsers().pipe(
  catchError(error => {
    console.error('Error:', error);
    
    // Return fallback value
    return of([]);
    
    // OR rethrow
    // return throwError(() => error);
  })
).subscribe(users => {
  this.users = users;
});
```

**Method 2: Error Handling in Subscribe**
```typescript
this.userService.getUsers().subscribe({
  next: (users) => this.users = users,
  error: (error) => {
    console.error('Error:', error);
    this.handleError(error);
  },
  complete: () => console.log('Complete')
});
```

**Method 3: Global Error Handler**
```typescript
@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  handleError(error: any): void {
    console.error('Global error:', error);
    // Log to service, show notification, etc.
  }
}

// app.module.ts
providers: [
  { provide: ErrorHandler, useClass: GlobalErrorHandler }
]
```

**Method 4: HTTP Interceptor (Recommended)**
```typescript
@Injectable()
export class ErrorInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    return next.handle(req).pipe(
      catchError(error => {
        if (error.status === 401) {
          // Handle unauthorized
          this.router.navigate(['/login']);
        } else if (error.status === 500) {
          // Handle server error
          this.notificationService.showError('Server error');
        }
        
        return throwError(() => error);
      })
    );
  }
}
```

**Method 5: Retry Logic**
```typescript
import { retry, retryWhen, delay, take } from 'rxjs/operators';

this.http.get('/api/users').pipe(
  retry(3),  // Retry 3 times
  // OR
  retryWhen(errors => 
    errors.pipe(
      delay(1000),
      take(3)
    )
  )
).subscribe();
```

**Error Response Types:**
```typescript
interface HttpErrorResponse {
  status: number;
  statusText: string;
  error: any;
  message: string;
}

// Handle specific errors
catchError((error: HttpErrorResponse) => {
  switch (error.status) {
    case 400:
      return throwError(() => 'Bad request');
    case 401:
      return throwError(() => 'Unauthorized');
    case 404:
      return throwError(() => 'Not found');
    case 500:
      return throwError(() => 'Server error');
    default:
      return throwError(() => 'Unknown error');
  }
})
```

---

### What are Subjects? Types of Subjects.

**Subject** is a special type of Observable that allows multicasting (multiple subscribers).

**Types of Subjects:**

1. **Subject** - No initial value, no replay
2. **BehaviorSubject** - Has initial value, replays last value
3. **ReplaySubject** - Replays specified number of values
4. **AsyncSubject** - Emits only last value on completion

**Subject Example:**
```typescript
import { Subject } from 'rxjs';

const subject = new Subject<string>();

// Subscribe before emitting
subject.subscribe(value => console.log('A:', value));
subject.subscribe(value => console.log('B:', value));

// Emit values
subject.next('Hello');  // Both subscribers receive
subject.next('World');  // Both subscribers receive

// Output:
// A: Hello
// B: Hello
// A: World
// B: World
```

**BehaviorSubject Example:**
```typescript
import { BehaviorSubject } from 'rxjs';

const subject = new BehaviorSubject<string>('Initial');  // Initial value

// Subscribe after initial value
subject.subscribe(value => console.log('A:', value));  // Receives 'Initial'

subject.next('Hello');

// New subscriber
subject.subscribe(value => console.log('B:', value));  // Receives 'Hello' (last value)

// Output:
// A: Initial
// A: Hello
// B: Hello
```

**ReplaySubject Example:**
```typescript
import { ReplaySubject } from 'rxjs';

const subject = new ReplaySubject<string>(2);  // Replay last 2 values

subject.next('A');
subject.next('B');
subject.next('C');

subject.subscribe(value => console.log(value));  // Receives 'B', 'C'

// Output:
// B
// C
```

**Use Cases:**
```typescript
// Service with BehaviorSubject
@Injectable({ providedIn: 'root' })
export class UserService {
  private userSubject = new BehaviorSubject<User>(null);
  user$ = this.userSubject.asObservable();
  
  setUser(user: User) {
    this.userSubject.next(user);
  }
  
  getCurrentUser(): User {
    return this.userSubject.value;  // Synchronous access
  }
}
```

---

### What is the difference between BehaviorSubject and Observable?

| Feature | Observable | BehaviorSubject |
|---------|-----------|-----------------|
| **Initial Value** | No | Yes |
| **Replay** | No | Last value |
| **Multicast** | Unicast (per subscription) | Multicast (shared) |
| **Synchronous Access** | No | Yes (`.value`) |
| **Creation** | Factory functions | `new BehaviorSubject(value)` |

**Observable:**
```typescript
const observable = of(1, 2, 3);
observable.subscribe(console.log);  // 1, 2, 3
observable.subscribe(console.log);  // 1, 2, 3 (new execution)
```

**BehaviorSubject:**
```typescript
const subject = new BehaviorSubject(0);
subject.subscribe(console.log);  // 0 (initial value)
subject.next(1);  // 1
subject.subscribe(console.log);  // 1 (last value)
```

**When to Use:**
- **Observable**: HTTP requests, one-time data streams
- **BehaviorSubject**: Shared state, current value needed, multiple subscribers

---

### How do you cancel HTTP requests?

**Method 1: Unsubscribe**
```typescript
export class UserComponent implements OnInit, OnDestroy {
  private subscription: Subscription;
  
  ngOnInit() {
    this.subscription = this.userService.getUsers().subscribe(users => {
      this.users = users;
    });
  }
  
  ngOnDestroy() {
    this.subscription?.unsubscribe();  // Cancels request
  }
}
```

**Method 2: takeUntil Pattern (Recommended)**
```typescript
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

export class UserComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  
  ngOnInit() {
    this.userService.getUsers().pipe(
      takeUntil(this.destroy$)
    ).subscribe(users => {
      this.users = users;
    });
  }
  
  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

**Method 3: AbortController (Modern)**
```typescript
// In service
getUsers(abortSignal?: AbortSignal): Observable<User[]> {
  return this.http.get<User[]>('/api/users', {
    signal: abortSignal
  });
}

// In component
private abortController = new AbortController();

loadUsers() {
  this.userService.getUsers(this.abortController.signal).subscribe(users => {
    this.users = users;
  });
}

ngOnDestroy() {
  this.abortController.abort();
}
```

---

### What is HttpInterceptor? How do you use it?

**HttpInterceptor** intercepts HTTP requests/responses for cross-cutting concerns (auth, logging, error handling).

**Creating Interceptor:**
```typescript
import { Injectable } from '@angular/core';
import { HttpInterceptor, HttpRequest, HttpHandler, HttpEvent } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    // Clone request and add header
    const authReq = req.clone({
      setHeaders: {
        Authorization: `Bearer ${this.getToken()}`
      }
    });
    
    return next.handle(authReq);
  }
  
  private getToken(): string {
    return localStorage.getItem('token') || '';
  }
}
```

**Registering Interceptor:**
```typescript
// app.module.ts
import { HTTP_INTERCEPTORS } from '@angular/common/http';

@NgModule({
  providers: [
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true  // Allow multiple interceptors
    }
  ]
})
export class AppModule {}
```

**Common Use Cases:**

**1. Authentication:**
```typescript
intercept(req: HttpRequest<any>, next: HttpHandler) {
  const token = this.authService.getToken();
  if (token) {
    req = req.clone({
      setHeaders: { Authorization: `Bearer ${token}` }
    });
  }
  return next.handle(req);
}
```

**2. Error Handling:**
```typescript
intercept(req: HttpRequest<any>, next: HttpHandler) {
  return next.handle(req).pipe(
    catchError(error => {
      if (error.status === 401) {
        this.authService.logout();
        this.router.navigate(['/login']);
      }
      return throwError(() => error);
    })
  );
}
```

**3. Loading Indicator:**
```typescript
intercept(req: HttpRequest<any>, next: HttpHandler) {
  this.loadingService.show();
  return next.handle(req).pipe(
    finalize(() => this.loadingService.hide())
  );
}
```

**4. Logging:**
```typescript
intercept(req: HttpRequest<any>, next: HttpHandler) {
  console.log('Request:', req.method, req.url);
  return next.handle(req).pipe(
    tap(event => {
      if (event instanceof HttpResponse) {
        console.log('Response:', event.status, event.body);
      }
    })
  );
}
```

**Multiple Interceptors:**
```typescript
// Order matters - executed in registration order
providers: [
  { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
  { provide: HTTP_INTERCEPTORS, useClass: LoggingInterceptor, multi: true },
  { provide: HTTP_INTERCEPTORS, useClass: ErrorInterceptor, multi: true }
]
```

