# Angular Learn-by-Doing POC

Goal: stop passively reading Q&A. For every question in `Angular/Q&A/`, you build a tiny, working piece of it inside **one real Angular app**, then move to the next question.

## 1. The project

One Angular workspace covers the whole Q&A series: **`angular-fundamentals-poc`**, created from scratch in [Part-1-Fundamentals-POC.md](./Part-1-Fundamentals-POC.md) (step 0). It lives at:

```
Angular/POC-Learning/angular-fundamentals-poc/
```

Every question becomes its own clearly-named **feature folder + route** inside `src/app/features/`, e.g. `features/user-profile-card/` served at `/user-profile`. No cryptic `q01`, `q02` names — folder, component, and route names describe what they demonstrate, so the project reads like a real feature list, not a quiz.

Keep this **same app and workspace** for every question across all six Q&A parts — you're building one growing app, not throwaway snippets per question.

## 2. How we'll work, question by question

For each question:

1. **You read** the question + explanation in the matching `Q&A/Part X` file.
2. **I give you a "POC Prompt"** — a concrete, scoped task (create feature X, do Y, verify Z) with a real, readable feature/component name.
3. **You implement it** in `angular-fundamentals-poc` (I can also implement directly if you ask me to).
4. **We verify** with the checklist in the guide (run app, check console/output).
5. Check the box in [PROGRESS.md](./PROGRESS.md) and move to the next question.

## 3. Guides (one file per Q&A part)

- [Part 1 – Fundamentals & Components](./Part-1-Fundamentals-POC.md) ✅ ready — includes from-scratch project setup
- Part 2 – Services, DI & Routing — generate when you reach it
- Part 3 – Forms, HTTP, Observables — generate when you reach it
- Part 4 – Directives & Advanced Topics — generate when you reach it
- Part 5 – Modules, Architecture & Testing — generate when you reach it
- Part 6 – Performance, TypeScript & State Management — generate when you reach it

> Say "generate Part 2 POC guide" when you finish Part 1, and I'll create it in the same style so files stay small and focused, reusing the same `angular-fundamentals-poc` project.

## 4. Ground rules

- No copy-pasting big blocks from the Q&A doc into the app — type it yourself so it sticks.
- Every question gets a real, readable feature name and a matching route (e.g. `/pipes-demo`, `/change-detection`) so you can visually confirm it works.
- If a question is purely conceptual (e.g. "what is AOT compilation?"), the POC prompt will instead be a small experiment (e.g. compare build output) or a "explain in your own words" checkpoint instead of a component.
- Track progress in [PROGRESS.md](./PROGRESS.md).
