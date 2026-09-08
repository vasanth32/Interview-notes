# Part 1 POC Guide — Fundamentals & Components

Companion to [Angular/Q&A/Part 1 - Fundamentals & Components.md](../Q&A/Part%201%20-%20Fundamentals%20&%20Components.md). Work top to bottom. Each block = read the question in that file → follow the POC prompt here → verify → check it off in [PROGRESS.md](./PROGRESS.md).

Project created below: **`angular-fundamentals-poc`**, at `Angular/POC-Learning/angular-fundamentals-poc/`. Every question gets its own clearly-named feature folder under `src/app/features/` and a matching route — no `q01`/`q02` style names.

---

## Q0. Create the project from scratch

**Type:** one-time setup — do this before Q1.
**POC Prompt:**

```powershell
npm install -g @angular/cli
cd "d:\PracticeProjects\@Notes\Angular\POC-Learning"

# NgModule-based (not standalone) so Q3's module-encapsulation demo makes sense
ng new angular-fundamentals-poc --routing --style=scss --standalone=false

cd angular-fundamentals-poc
mkdir src/app/features
ng serve -o
```

Confirm the default page loads at `http://localhost:4200`, then leave `ng serve` running in a terminal for the rest of Part 1 — most feature routes hot-reload automatically.

Add a simple nav shell so you can jump between features as you build them — edit `src/app/app.component.html`:

```html
<nav style="display:flex; gap:12px; padding:8px; flex-wrap:wrap;">
  <a routerLink="/architecture-overview">Architecture Overview</a>
  <a routerLink="/feature-module-demo">Feature Module Demo</a>
  <a routerLink="/user-profile">User Profile Card</a>
  <a routerLink="/custom-directives">Custom Directives</a>
  <a routerLink="/data-binding">Data Binding</a>
  <a routerLink="/pipes-demo">Pipes</a>
  <a routerLink="/pipe-purity">Pipe Purity</a>
  <a routerLink="/change-detection">Change Detection</a>
  <a routerLink="/lifecycle-hooks">Lifecycle Hooks</a>
  <a routerLink="/counter">Counter Input/Output</a>
  <a routerLink="/view-children">View Children</a>
  <a routerLink="/content-projection">Content Projection</a>
  <a routerLink="/ngif-vs-hidden">*ngIf vs [hidden]</a>
</nav>
<router-outlet></router-outlet>
```

**Verify:** app compiles, nav links appear (routes will 404 until you build each feature — that's expected at this stage).

---

## Q1. Angular vs AngularJS

**Type:** conceptual (no code needed)
**POC Prompt:** Write a 3-line comparison table in your own words (language, architecture, DI) as a comment at the top of `src/app/app.component.ts`. No need to install AngularJS — this is a recall checkpoint, not a build task.
**Verify:** You can explain it out loud without looking at the notes.

---

## Q2. Angular architecture & core concepts

**Type:** scaffold
**Feature name:** `architecture-overview`
**POC Prompt:**

1. `ng generate component features/architecture-overview`.
2. `ng generate service features/architecture-overview/greeting`.
3. In `GreetingService`, add a method `getMessage(): string` returning `'Hello from a service'`.
4. Inject it into `ArchitectureOverviewComponent`'s constructor and display the message in the template.
5. Add a route path `architecture-overview` pointing to `ArchitectureOverviewComponent` in `app-routing.module.ts`.

**Verify:** Navigate to `/architecture-overview`, see the message rendered — proves module→component→service→template flow works end to end.

---

## Q3. Angular modules

**Type:** hands-on
**Feature name:** `feature-module-demo`
**POC Prompt:**

1. `ng generate module features/feature-module-demo --routing`.
2. `ng generate component features/feature-module-demo/feature-module-home`.
3. Import `FeatureModuleDemoModule` into `AppModule`.
4. Add a route inside `feature-module-demo-routing.module.ts` (not `AppModule`) for path `feature-module-demo` → `FeatureModuleHomeComponent`.

**Verify:** `/feature-module-demo` renders without you adding anything to `AppModule`'s `declarations` — proves modules encapsulate their own components.

---

## Q4. What is a component

**Type:** hands-on
**Feature name:** `user-profile-card`
**POC Prompt:**

1. `ng generate component features/user-profile-card`.
2. Add `@Input() userId!: number;` and a `user` property.
3. In `ngOnInit`, fake-fetch: `this.user = { id: this.userId, name: 'Test User' };`.
4. Render `user.name` and `{{ userId }}` in the template.
5. Add route `user-profile` → `UserProfileCardComponent`, and pass an input value from a parent usage, e.g. in `ArchitectureOverviewComponent`'s template add `<app-user-profile-card [userId]="42"></app-user-profile-card>`.

**Verify:** `/user-profile` (or wherever you embedded it) shows both the fake user's name and the passed `userId`, confirming `@Input` wiring works.

---

## Q5. Directives & types

**Type:** hands-on (build all 3 kinds)
**Feature name:** `custom-directives-demo`
**POC Prompt:**

1. Component directive: reuse `UserProfileCardComponent` (already a directive under the hood).
2. Structural directive: `ng generate directive features/custom-directives-demo/unless`. Implement `appUnless` exactly like the example in the notes (opposite of `*ngIf`).
3. Attribute directive: `ng generate directive features/custom-directives-demo/highlight`. Implement `appHighlight` that changes `backgroundColor` via `@HostBinding`.
4. `ng generate component features/custom-directives-demo` (the demo page) using both: `<p *appUnless="isLoggedIn">Please login</p>` and `<p appHighlight="lightblue">Highlighted</p>`.
5. Add route `custom-directives` → this component.

**Verify:** Toggle `isLoggedIn` (add a button) and watch the paragraph appear/disappear. Confirm the highlighted paragraph has the background color.

---

## Q6. Data binding (all 4 types)

**Type:** hands-on
**Feature name:** `data-binding-demo`
**POC Prompt:** `ng generate component features/data-binding-demo`, add route `data-binding`. In one template add all four bindings:

- Interpolation: `{{ title }}`
- Property binding: `<button [disabled]="isLoading">Submit</button>`
- Event binding: `<button (click)="toggleLoading()">Toggle</button>`
- Two-way binding: `<input [(ngModel)]="title">` (import `FormsModule` in `AppModule`)

**Verify:** Typing in the input updates the interpolated `{{ title }}` live; clicking "Toggle" enables/disables the Submit button.

---

## Q7. Interpolation vs property binding vs event binding

**Type:** experiment
**POC Prompt:** In `DataBindingDemoComponent`, deliberately break property binding by writing `disabled="isLoading"` (no brackets) instead of `[disabled]="isLoading"`. Observe the button is now always disabled regardless of the boolean — because it's treated as a string attribute, not bound. Revert afterward.
**Verify:** You can explain why `[prop]` differs from `prop` after seeing the bug live.

---

## Q8. Pipes

**Type:** hands-on
**Feature name:** `pipes-demo`
**POC Prompt:** `ng generate component features/pipes-demo`, add route `pipes-demo`. Add `price = 1234.5`, `today = new Date()`, `name = 'john doe'`. Render:

```html
{{ today | date:'fullDate' }} {{ price | currency:'USD' }} {{ name | titlecase
}} {{ name | uppercase }}
```

Then `ng generate pipe features/pipes-demo/truncate` implementing `transform(value: string, limit = 10)`.

**Verify:** All built-in pipes render formatted output; `{{ longSentence | truncate:15 }}` correctly cuts the string.

---

## Q9. Pure vs impure pipes

**Type:** experiment (proves the concept, don't skip)
**Feature name:** `pipe-purity-demo`
**POC Prompt:**

1. `ng generate component features/pipe-purity-demo`, add route `pipe-purity`.
2. `ng generate pipe features/pipe-purity-demo/random-pure` (default `pure: true`).
3. `ng generate pipe features/pipe-purity-demo/random-impure`, then manually set `pure: false` in its `@Pipe` decorator.
4. Both pipes: `transform(seed: number) { return Math.random() * seed; }`.
5. Template: bind both to the same `seed` value and add a button that changes an _unrelated_ counter property to trigger change detection.

**Verify:** Clicking the unrelated button re-renders `random-impure`'s number every click, while `random-pure`'s number stays frozen until `seed` itself changes.

---

## Q10. Change detection

**Type:** hands-on + experiment
**Feature name:** `change-detection-demo`
**POC Prompt:**

1. `ng generate component features/change-detection-demo --change-detection=OnPush`, add route `change-detection`.
2. Give it `@Input() user!: { name: string };` and use it from a parent (e.g. `AppComponent`) passing an object.
3. Add a "Mutate in place" button in the parent that does `this.user.name = 'changed'` — observe the child view does **not** update.
4. Add a "Replace reference" button that does `this.user = { ...this.user, name: 'changed2' }` — observe the child view **does** update.

**Verify:** You directly witness OnPush requiring a new reference — the classic interview gotcha, better understood by seeing it fail first.

---

## Q11. Component lifecycle hooks

**Type:** hands-on
**Feature name:** `lifecycle-hooks-demo`
**POC Prompt:** `ng generate component features/lifecycle-hooks-demo`, add route `lifecycle-hooks`. Implement `OnChanges, OnInit, DoCheck, AfterViewInit, AfterViewChecked, OnDestroy` and `console.log` each hook name. Give it an `@Input() value: string`. From the parent, add a button to change `value` and a `*ngIf` toggle to destroy/recreate the component.

**Verify:** Open devtools console; confirm order matches the notes (`ngOnChanges → ngOnInit → ngDoCheck → ngAfterViewInit → ngAfterViewChecked`, then `ngOnDestroy` when removed via `*ngIf`).

---

## Q12. ngOnInit vs constructor

**Type:** experiment
**POC Prompt:** In `LifecycleHooksDemoComponent`'s constructor, try to `console.log(this.value)` (the `@Input`). Compare with logging it in `ngOnInit`.
**Verify:** Constructor log prints `undefined`; `ngOnInit` log prints the real value.

---

## Q13. @Input and @Output

**Type:** hands-on
**Feature name:** `counter-input-output`
**POC Prompt:** `ng generate component features/counter-input-output`, add route `counter`. Build it exactly like the notes' counter example: `@Input() count`, `@Output() countChange`, increment/decrement buttons. Use it from a parent with `[(count)]="totalCount"` (banana-in-a-box).

**Verify:** Clicking +/- in the child updates a value displayed in the parent template.

---

## Q14. Parent → child data

**Type:** recap (already covered in Q4/Q13)
**POC Prompt:** `ng generate service features/counter-input-output/shared-user`. Implement it with a `BehaviorSubject<User>` exposing `user$` and `setUser()`. Parent calls `sharedUserService.setUser(...)`, `CounterInputOutputComponent` subscribes in `ngOnInit` and displays it.
**Verify:** Child displays the value set by parent through the service, not through `@Input`.

---

## Q15. Child → parent data

**Type:** hands-on
**POC Prompt:** In the parent hosting `CounterInputOutputComponent`, add `@ViewChild(CounterInputOutputComponent) counterRef!: CounterInputOutputComponent;` and a parent button that calls a public `reset()` method directly on the child, alongside the existing `@Output` approach.
**Verify:** Parent button resets the counter by calling the child's method directly.

---

## Q16. ViewChild / ViewChildren

**Type:** hands-on
**Feature name:** `view-children-demo`
**POC Prompt:** `ng generate component features/view-children-demo`, add route `view-children`. Render a list with `*ngFor` of 3 `UserProfileCardComponent` instances (or a small dedicated child component). Use `@ViewChildren(...) children: QueryList<...>` in the parent and, in `ngAfterViewInit`, loop through and call a method on each (e.g. `child.highlight()`).

**Verify:** All 3 children visibly change (e.g. background color) right after view init, driven purely from the parent.

---

## Q17. ContentChild / ContentChildren

**Type:** hands-on
**Feature name:** `content-projection-card`
**POC Prompt:** `ng generate component features/content-projection-card`, add route `content-projection`. Build it with `<ng-content>`. From a consumer, project an `<h2 #title>` into it. In `ContentProjectionCardComponent`, use `@ContentChild('title') titleRef!: ElementRef;` and log its `nativeElement.textContent` in `ngAfterContentInit`.

**Verify:** Console shows the projected title text, proving `@ContentChild` reads projected content, not the card's own template.

---

## Q18. Component communication methods (recap)

**Type:** review
**POC Prompt:** No new code — open every feature built so far (`architecture-overview` through `content-projection-card`) and annotate each with a one-line comment: which communication method it demonstrates.
**Verify:** You can point to a concrete file for every technique in the notes' summary table.

---

## Q19. ng-content

**Type:** hands-on
**POC Prompt:** Extend `ContentProjectionCardComponent` to support **named slots**: `<ng-content select="[slot=header]">` and `<ng-content select="[slot=footer]">` plus a default slot. Use it from the consumer with header/body/footer content.
**Verify:** Header, body, footer render in the correct card regions.

---

## Q20. \*ngIf vs [hidden]

**Type:** experiment
**Feature name:** `ngif-vs-hidden-demo`
**POC Prompt:** `ng generate component features/ngif-vs-hidden-demo`, add route `ngif-vs-hidden`. Put a small child component with `constructor() { console.log('constructed'); }` once behind `*ngIf="show"` and once behind `[hidden]="!show2"`. Toggle both with buttons and watch the console.

**Verify:** The `*ngIf` version logs "constructed" every time you show it again (recreated); the `[hidden]` version logs it only once (stays in DOM, just visually hidden).

---

## Done with Part 1?

Update all checkboxes in [PROGRESS.md](./PROGRESS.md), then tell me: "generate Part 2 POC guide" and I'll build the same style guide for Services, DI & Routing, reusing the same `angular-fundamentals-poc` project.
