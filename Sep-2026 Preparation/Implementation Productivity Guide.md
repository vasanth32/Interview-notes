# Implementation Productivity Guide

The preparation plan is good, but each item is too large. For example, **Angular + RxJS in 2 to 3 hours** contains several days of work, so implementation can feel endless.

## Daily 90-Minute Block

1. **5 minutes:** Choose one visible output.
2. **50 minutes:** Implement without taking detailed notes.
3. **20 minutes:** Debug and complete it.
4. **10 minutes:** Explain it aloud.
5. **5 minutes:** Record what is done and the next action.

## What Is a Visible Output?

A visible output is something completed and testable, such as:

- One working API endpoint
- One Angular component
- One SQL query with an execution-plan explanation
- One production scenario answered aloud
- Five interview questions recorded

Avoid goals such as **Study RxJS** because they do not have a clear finish line.

## Example: RxJS Session

Instead of:

> Learn `debounceTime`, `distinctUntilChanged`, and `switchMap`.

Set this target:

> Build a search input that waits 300 milliseconds, ignores duplicate text, cancels the previous request, and displays errors.

Stop when that works. Do not expand the scope during the session.

## Important Rules

- Spend **70% coding or speaking, 20% debugging, and 10% reading**.
- Do not create more plans during implementation time.
- When stuck for 15 minutes, write down the exact problem and investigate only that problem.
- Keep unrelated ideas in a **Later** list.
- Complete one small feature before starting another.
- Track **finished outputs**, not hours studied.

## Example of One Productive Day

```text
Morning: Build one Angular search component
Afternoon: Build one .NET search endpoint
Evening: Explain one production troubleshooting scenario aloud
```

## Next Session

Begin with this single target:

> Create the Angular search box using `debounceTime`, `distinctUntilChanged`, and `switchMap`.

Do not begin another topic until it runs.
