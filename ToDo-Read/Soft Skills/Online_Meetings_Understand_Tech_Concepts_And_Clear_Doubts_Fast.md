# Online Meetings: Understand Tech Concepts & Clear Doubts Fast (Soft Skills)

When someone is explaining a technical concept in an online meeting, your goal is to **extract the structure** quickly and ask **high-signal questions** without derailing the flow.

---

## Before the meeting (2–10 minutes)

- **Know the purpose**: “Are we deciding, designing, debugging, or sharing knowledge?”
- **Skim context** (if available):
  - Ticket/PR/Doc link
  - Architecture diagram
  - Current behavior + expected behavior
- **Prepare a mini template** in notes (copy/paste):
  - Goal:
  - Current state:
  - Proposed change:
  - Key components:
  - Data/contracts:
  - Risks/unknowns:
  - Decisions:
  - Action items:

---

## During the meeting: how to “observe the whole concept”

### 1) Start by finding the 4 anchors
Listen for (or ask for) these early:

- **Problem**: What pain are we solving?
- **Scope**: What is in / out?
- **Flow**: What’s the end-to-end path?
- **Decision**: What do we need to agree on today?

If it’s not obvious, ask:
- “Just to align: what decision are we trying to make by the end of this call?”

---

### 2) Build a quick mental model (in layers)
Capture explanations in this order:

- **Inputs/Outputs**: request, event, user action → response, side effects
- **Happy path**: step-by-step “what happens”
- **Key components**: services/modules/DB tables/queues
- **State & data**: what data changes, where it’s stored, contracts
- **Failure modes**: timeouts, retries, partial failures, idempotency
- **Non-functional**: performance, security, observability, cost

Tip: Write it as **1–2 simple diagrams** in your notes:
- boxes + arrows (systems)
- sequence list (1 → 2 → 3)

---

### 3) Use “checkpoint summaries” (fast clarity, low interruption)
Every 5–10 minutes (or after a big chunk), summarize in 1–2 sentences:

- “Let me repeat to confirm: client calls **A**, which calls **B**, then we publish event **C**, and worker **D** updates table **E**. Correct?”

This:
- catches misunderstandings early
- signals you’re following
- invites corrections without friction

---

### 4) Ask short, high-signal questions (without slowing the meeting)

#### The best question formats
- **Goal check**: “What outcome do we want for users/business?”
- **Boundary check**: “What’s explicitly out of scope for this change?”
- **Assumption check**: “Are we assuming X is always true? What if not?”
- **Interface check**: “What’s the contract here—payload/schema/versioning?”
- **Decision check**: “What trade-off made us choose option A over B?”
- **Observability check**: “How will we detect failures and debug this in prod?”

#### Make questions “cheap to answer”
Instead of: “Can you explain the whole thing again?”
Ask: “In the flow, where exactly do we validate **X**—at API boundary or in the domain service?”

---

### 5) Use the “Parking Lot” to avoid hijacking the discussion
When you have a deep question but the meeting is moving:

- “This might be a deeper dive—can I park it? I’ll note it and follow up after.”

Maintain a **Parking Lot** list:
- question
- owner (who can answer)
- follow-up time (after call / async)

---

### 6) Watch for common ambiguity signals (and clarify immediately)
Clarify when you hear:

- “Usually / sometimes / should / might”
- “We’ll handle it later”
- “It depends”
- “Let’s just…”

Quick clarifiers:
- “What are the exact conditions when it’s not true?”
- “What’s the fallback behavior if that fails?”
- “Who owns that ‘later’ work item?”

---

### 7) Use chat + screen control strategically
- **Ask for links in chat**: docs, diagrams, tickets, dashboards.
- **Confirm spellings**: service names, table names, queue/topic names.
- **Request a quick view**: “Can you show the payload / config / log example?”

If you’re lost:
- “Could you zoom out and show the end-to-end flow once, then we can zoom into step 3?”

---

## Fast doubt-clearing techniques (when time is short)

### The “One missing piece” technique
Identify the single gap blocking understanding:
- “I’m good on most of it—my only missing piece is where **idempotency** is guaranteed.”

### The “Compare to known pattern” technique
Anchor to something familiar:
- “Is this basically a **saga/orchestration** flow, or more like **event-choreography**?”

### The “Example-driven” technique
Ask for one concrete example:
- “Can we walk through a single example with real values (userId/orderId)?”

### The “What breaks first?” technique
Great for senior-level clarity:
- “If this goes wrong in prod, what’s the most likely failure and how will we see it?”

---

## Meeting etiquette that makes you look senior (and speeds clarity)

- **Signal intent**: “Quick clarification so I don’t misunderstand…”
- **Keep it crisp**: one question at a time.
- **Don’t debate prematurely**: ask “what/why/how” before proposing fixes.
- **Call out decisions**: “So the decision is X; can we capture that?”
- **Respect time**: “We’re at 2 minutes—should we decide now or take this async?”

---

## After the meeting (5–15 minutes)

### 1) Send a 6-line recap (high leverage)
Post to chat/email/Teams/Slack:

- **Goal**:
- **Current behavior**:
- **Proposed approach**:
- **Decisions made**:
- **Open questions (Parking Lot)**:
- **Action items + owners + dates**:

### 2) Convert doubts into precise follow-ups
For each open question, add:
- what you need (payload, doc, config, code pointer)
- why (risk/unknown)
- deadline (before PR review / before deploy)

### 3) If you’ll implement later, write a “read path”
Example:
- “Start at controller X → service Y → repo Z → event handler W → table T”

---

## Quick question bank (copy/paste)

- “What’s the **entry point** and what’s the **final side effect**?”
- “Which part is **sync** and which is **async**?”
- “What’s the **source of truth** for this data?”
- “What’s the **retry** policy and **idempotency key**?”
- “What’s the **timeout** and **circuit breaker** behavior?”
- “Where do we log/trace this end-to-end?”
- “What’s the rollback plan if this causes issues?”


