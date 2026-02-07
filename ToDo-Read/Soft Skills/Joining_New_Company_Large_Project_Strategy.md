# Joining New Company: Large Project Strategy Guide

## 🎯 Your Goal

You're joining a new company with a **large existing project**. You want to:

1. ✅ Understand business & technical aspects
2. ✅ Improve yourself
3. ✅ Prove your skills
4. ✅ Grow with good reputation
5. ✅ Become a strong resource
6. ✅ Achieve all this with **consistency**

**This guide shows you how to do it systematically.**

---

## 🧠 The Core Challenge

### What Makes This Hard

- **Large codebase** - Overwhelming, don't know where to start
- **Existing team** - They know things you don't
- **Business context** - Why things are built this way
- **Pressure to perform** - Want to prove yourself quickly
- **Multiple goals** - Learning + contributing + growing

### The Solution: Systematic Approach

> **Don't try to understand everything.**
> **Understand what matters, when it matters.**

---

## 📅 The 30-60-90 Day Framework

### Phase 1: Days 1-30 (Foundation & Observation)

**Goal:** Build foundation, observe, ask questions, establish presence

### Phase 2: Days 31-60 (Contribution & Understanding)

**Goal:** Start contributing, deepen understanding, build relationships

### Phase 3: Days 61-90 (Ownership & Growth)

**Goal:** Take ownership, propose improvements, become go-to person

---

## 🗓️ Phase 1: Days 1-30 (Foundation & Observation)

### Week 1: Setup & Orientation

#### Day 1-2: Infrastructure & Access

**Technical Setup:**
- [ ] Get all access (Git, CI/CD, databases, cloud accounts)
- [ ] Set up local development environment
- [ ] Clone repositories
- [ ] Run project locally (even if it fails, document what fails)
- [ ] Access to documentation/wiki/Confluence
- [ ] Access to monitoring/logging tools
- [ ] Access to project management tools (Jira, Azure DevOps)

**Business Setup:**
- [ ] Understand company structure
- [ ] Know your team members (names, roles)
- [ ] Understand reporting structure
- [ ] Access to business documentation
- [ ] Product documentation/user guides

**Action:**
- Create a "Setup Checklist" document
- Document every issue you face
- Note who helped you (build relationships)

#### Day 3-5: First Impressions & Documentation

**What to Do:**

1. **Create Your Learning Journal**
   ```markdown
   ## Week 1 Learning Journal
   
   ### What I Learned Today
   - [Day 3] Project uses microservices architecture
   - [Day 3] Main services: Auth, Product, Order, Payment
   - [Day 4] Database: PostgreSQL, Redis for caching
   - [Day 5] Deployment: Kubernetes on AWS
   
   ### Questions I Have
   - Why did they choose microservices over monolith?
   - How do services communicate? (REST/Events?)
   - What's the deployment process?
   
   ### People I Met
   - [Name] - Senior Developer, helped with local setup
   - [Name] - Tech Lead, explained architecture
   
   ### Next Steps
   - Understand authentication flow
   - Map out service dependencies
   ```

2. **Read Existing Documentation**
   - README files
   - Architecture diagrams
   - API documentation
   - Runbooks/operational guides
   - **Don't read everything** - Skim, note what's important

3. **Observe Team Dynamics**
   - Who makes decisions?
   - How do they communicate?
   - What's the code review process?
   - What tools do they use?

**Daily Routine (30 minutes):**
- Morning: Read one document (15 min)
- Afternoon: Ask one question (5 min)
- End of day: Write learning journal (10 min)

---

### Week 2: Business Understanding

#### Understand the "Why"

**Business Questions to Answer:**

1. **What problem does this project solve?**
   - Who are the users?
   - What pain points does it address?
   - What's the business value?

2. **How does the business make money?**
   - Revenue model
   - Key metrics
   - Success criteria

3. **What are the business priorities?**
   - Current focus areas
   - Upcoming features
   - Technical debt concerns

**How to Learn:**

1. **Talk to Product Manager/Business Analyst**
   - Schedule 30-min session
   - Ask: "What should I understand about the business?"
   - Take notes

2. **Read User Stories/Requirements**
   - Recent Jira tickets
   - Feature specifications
   - User acceptance criteria

3. **Use the Product**
   - If possible, use it as a user
   - Note what works/doesn't work
   - Understand user journey

**Action:**
- Create "Business Understanding" document
- Map user journeys
- List key business rules

---

### Week 3: Technical Architecture Deep Dive

#### Map the System

**What to Understand:**

1. **High-Level Architecture**
   - System diagram
   - Service boundaries
   - Data flow
   - Integration points

2. **Technology Stack**
   - Languages, frameworks
   - Databases
   - Message queues
   - Caching
   - Cloud services

3. **Key Patterns**
   - Design patterns used
   - Architectural patterns
   - Communication patterns

**How to Learn:**

1. **Draw Architecture Diagram**
   - Start with high-level
   - Add details as you learn
   - Update it daily

2. **Trace One User Flow**
   - Pick a simple flow (e.g., "User logs in")
   - Follow it through the code
   - Document each step

3. **Read Code Reviews**
   - Recent PRs
   - See what patterns they use
   - Understand coding standards

**Daily Routine (30 minutes):**
- Morning: Read code for one service (15 min)
- Afternoon: Update architecture diagram (10 min)
- End of day: Document one pattern you found (5 min)

**Output:**
- Architecture diagram (keep updating)
- Technology stack list
- Pattern documentation

---

### Week 4: Codebase Navigation

#### Learn to Navigate

**What to Do:**

1. **Find Entry Points**
   - Main controllers/endpoints
   - Startup/configuration files
   - Database migrations
   - Test files

2. **Understand Project Structure**
   - Folder organization
   - Naming conventions
   - How code is organized

3. **Identify Key Files**
   - Most frequently changed files
   - Core business logic
   - Shared utilities
   - Configuration files

**How to Learn:**

1. **Use IDE Features**
   - "Find usages" for key classes
   - "Go to definition"
   - Search across codebase

2. **Read Git History**
   - Recent commits
   - See what changed
   - Understand evolution

3. **Run Tests**
   - Run test suite
   - See what passes/fails
   - Understand test structure

**Action:**
- Create "Codebase Map" document
- List key files and their purpose
- Note patterns you discover

---

## 🗓️ Phase 2: Days 31-60 (Contribution & Understanding)

### Week 5-6: First Contributions

#### Start Small, Build Confidence

**What to Contribute:**

1. **Documentation Improvements**
   - Fix outdated README
   - Add missing comments
   - Document unclear code
   - Update architecture diagrams

2. **Small Bug Fixes**
   - Low-risk bugs
   - Simple fixes
   - Good for learning codebase

3. **Test Improvements**
   - Add missing tests
   - Improve test coverage
   - Fix flaky tests

**How to Find Opportunities:**

1. **Ask Your Manager**
   - "What small tasks can I take?"
   - "What documentation needs updating?"

2. **Look for "Good First Issue" Labels**
   - GitHub/GitLab issues
   - Jira tickets marked for newbies

3. **Identify Pain Points**
   - What slows down the team?
   - What's missing?
   - What's confusing?

**Daily Routine (1 hour):**
- Morning: Work on contribution (45 min)
- End of day: Review with team member (15 min)

**Key Principle:**
> **Better to do one thing well than many things poorly.**

---

### Week 7-8: Deeper Understanding

#### Understand Business Logic

**What to Learn:**

1. **Core Business Rules**
   - How calculations work
   - Validation rules
   - Business workflows

2. **Domain Model**
   - Key entities
   - Relationships
   - Business constraints

3. **Integration Points**
   - External APIs
   - Third-party services
   - Data synchronization

**How to Learn:**

1. **Read Business Logic Code**
   - Service classes
   - Domain models
   - Business rule implementations

2. **Trace Complex Flows**
   - Follow a complex user journey
   - Understand decision points
   - Document business rules

3. **Ask "Why" Questions**
   - Why is this done this way?
   - What business need does this solve?
   - What would break if we changed this?

**Action:**
- Create "Business Logic" document
- Document key business rules
- Map domain model

---

## 🗓️ Phase 3: Days 61-90 (Ownership & Growth)

### Week 9-10: Take Ownership

#### Own a Feature/Area

**What to Own:**

1. **A Small Feature**
   - End-to-end responsibility
   - Design, code, test, deploy
   - Full ownership

2. **A Service/Module**
   - Become expert in one area
   - Go-to person for questions
   - Maintain and improve

3. **A Process**
   - Code review process
   - Deployment process
   - Documentation process

**How to Take Ownership:**

1. **Volunteer Proactively**
   - "I can take this"
   - "Let me handle this"
   - Show initiative

2. **Deliver Consistently**
   - Meet deadlines
   - Communicate clearly
   - Ask for help when needed

3. **Improve Continuously**
   - Suggest improvements
   - Refactor when appropriate
   - Share knowledge

**Daily Routine (1-2 hours):**
- Morning: Work on owned feature (1 hour)
- Afternoon: Code review, help others (30 min)
- End of day: Document learnings (30 min)

---

### Week 11-12: Build Reputation

#### Become a Strong Resource

**How to Build Reputation:**

1. **Be Reliable**
   - Do what you say you'll do
   - Meet commitments
   - Communicate proactively

2. **Help Others**
   - Answer questions
   - Share knowledge
   - Pair program
   - Code review thoroughly

3. **Propose Improvements**
   - Technical improvements
   - Process improvements
   - Documentation improvements

4. **Share Knowledge**
   - Write documentation
   - Give presentations
   - Create guides
   - Mentor others

**Daily Actions:**

- **Morning Standup:**
  - Be prepared
  - Share progress clearly
  - Ask for help when needed

- **Code Reviews:**
  - Review thoroughly
  - Give constructive feedback
  - Learn from others' code

- **Meetings:**
  - Participate actively
  - Share insights
  - Ask clarifying questions

**Key Principle:**
> **Reputation = Consistency × Time**

---

## 🔥 Consistency Framework for New Company

### Daily Routine (1-2 hours total)

| Time | Activity | Why |
|------|----------|-----|
| **Morning (30 min)** | Deep learning: Read code/documentation | Build understanding |
| **During Work** | Contribute: Code, review, help | Prove value |
| **End of Day (15 min)** | Journal: What I learned, questions | Consolidate learning |
| **Weekly (1 hour)** | Review: Progress, next steps | Stay on track |

### Weekly Routine

**Monday:**
- Plan week's learning goals
- Identify contribution opportunities
- Schedule knowledge sessions

**Tuesday-Thursday:**
- Daily routine
- Work on contributions
- Learn and apply

**Friday:**
- Weekly review (30 min)
- Update documentation
- Plan next week

**Weekend (Optional, 30 min):**
- Review week's learnings
- Update architecture diagrams
- Prepare questions for next week

---

## 🧠 The 5-Mode System for New Company

### 1️⃣ OBSERVE Mode (Weeks 1-2)

**When:** First 2 weeks

**What to Do:**
- Watch and learn
- Ask questions
- Take notes
- Don't try to change things

**Example:**
- Attend all meetings (observe)
- Read code (understand)
- Ask "why" questions (learn context)

---

### 2️⃣ LEARN Mode (Weeks 3-4)

**When:** Deepening understanding

**What to Do:**
- Focused learning sessions
- Read documentation
- Trace code flows
- Understand patterns

**Example:**
- "Today I'll understand authentication flow"
- "This week I'll map all services"

---

### 3️⃣ CONTRIBUTE Mode (Weeks 5-8)

**When:** Starting to contribute

**What to Do:**
- Small contributions
- Documentation
- Bug fixes
- Test improvements

**Example:**
- "I'll fix this documentation issue"
- "I'll add tests for this module"

---

### 4️⃣ OWN Mode (Weeks 9-12)

**When:** Taking ownership

**What to Do:**
- Own features
- Make decisions
- Propose improvements
- Help others

**Example:**
- "I own this feature end-to-end"
- "I'll improve this process"

---

### 5️⃣ LEAD Mode (Month 4+)

**When:** Established, growing

**What to Do:**
- Mentor others
- Drive improvements
- Share knowledge
- Influence decisions

**Example:**
- "I'll mentor the new developer"
- "I'll propose this architectural improvement"

---

## 📋 Practical Strategies

### Strategy 1: The "One Thing" Rule

**Every day, do ONE thing that:**
- Builds understanding
- OR contributes value
- OR builds relationships

**Examples:**
- ✅ Understand one API endpoint
- ✅ Fix one documentation issue
- ✅ Help one team member
- ✅ Document one pattern

**Why:**
- Prevents overwhelm
- Builds consistency
- Shows progress

---

### Strategy 2: The "Question Log"

**Create a document: "Questions I Have"**

**Structure:**
```markdown
## Questions Log

### Technical Questions
- [ ] Why do we use Redis here instead of database?
- [ ] How does service discovery work?
- [ ] What's the deployment strategy?

### Business Questions
- [ ] Why is this feature important?
- [ ] What's the user journey for this?
- [ ] What metrics do we track?

### Process Questions
- [ ] How do we handle production incidents?
- [ ] What's the code review process?
- [ ] How do we prioritize work?
```

**How to Use:**
- Add questions as they come up
- Review weekly
- Ask in 1-on-1s or team meetings
- Don't let questions pile up

---

### Strategy 3: The "Knowledge Map"

**Create a visual map of what you know/don't know**

**Structure:**
```
┌─────────────────────────────────────┐
│         Architecture                │
│  ✅ High-level (known)              │
│  ⚠️  Service details (learning)      │
│  ❌ Integration patterns (unknown)  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│         Business Logic             │
│  ✅ Core flows (known)              │
│  ⚠️  Edge cases (learning)          │
│  ❌ Complex calculations (unknown)  │
└─────────────────────────────────────┘
```

**Update weekly:**
- Move items from ❌ to ⚠️ to ✅
- See progress visually
- Identify gaps

---

### Strategy 4: The "Contribution Ladder"

**Start small, build up:**

```
Level 1: Documentation
  ↓
Level 2: Small Bug Fixes
  ↓
Level 3: Test Improvements
  ↓
Level 4: Small Features
  ↓
Level 5: Medium Features
  ↓
Level 6: Own Module/Service
  ↓
Level 7: Architectural Improvements
```

**Principle:**
- Master one level before moving up
- Build confidence gradually
- Prove reliability at each level

---

## 🎯 Building Reputation: Practical Actions

### Week 1-4: Foundation

**Actions:**
- ✅ Show up on time
- ✅ Be prepared for meetings
- ✅ Ask thoughtful questions
- ✅ Take notes
- ✅ Follow up on action items

**Reputation:** "Reliable, eager to learn"

---

### Week 5-8: Contribution

**Actions:**
- ✅ Deliver small tasks on time
- ✅ Write good code
- ✅ Help with documentation
- ✅ Participate in code reviews
- ✅ Share learnings

**Reputation:** "Contributing team member"

---

### Week 9-12: Ownership

**Actions:**
- ✅ Own features end-to-end
- ✅ Propose improvements
- ✅ Help others
- ✅ Share knowledge
- ✅ Take initiative

**Reputation:** "Strong resource, go-to person"

---

### Month 4+: Leadership

**Actions:**
- ✅ Mentor others
- ✅ Drive improvements
- ✅ Influence decisions
- ✅ Share expertise
- ✅ Build processes

**Reputation:** "Technical leader, trusted advisor"

---

## 💡 Key Principles

### 1. Consistency Over Intensity

**Wrong:**
- Study 8 hours on weekend
- Burn out
- Skip days

**Right:**
- 30-60 min daily
- Consistent progress
- Sustainable

---

### 2. Quality Over Quantity

**Wrong:**
- Try to understand everything
- Surface-level knowledge
- No deep understanding

**Right:**
- Understand one thing deeply
- Build on that
- Expand gradually

---

### 3. Contribution Over Consumption

**Wrong:**
- Only read and learn
- Never contribute
- No visible value

**Right:**
- Learn AND contribute
- Show progress
- Build reputation

---

### 4. Relationships Over Tasks

**Wrong:**
- Focus only on code
- Ignore people
- Work in isolation

**Right:**
- Build relationships
- Learn from others
- Collaborate effectively

---

## 📊 Progress Tracking

### Weekly Review Template

```markdown
## Week [X] Review

### What I Learned
- [List 3-5 key learnings]

### What I Contributed
- [List contributions]

### Questions Answered
- [List questions you got answers to]

### Relationships Built
- [People you worked with]

### Next Week Goals
- [3 specific goals]
```

### Monthly Review Template

```markdown
## Month [X] Review

### Understanding Progress
- Architecture: [% understood]
- Business Logic: [% understood]
- Technical Stack: [% understood]

### Contributions Made
- [List major contributions]

### Reputation Built
- [How others see you]

### Areas to Improve
- [What to focus on next month]
```

---

## 🚨 Common Mistakes to Avoid

### 1. Trying to Understand Everything at Once

**Problem:** Overwhelm, no progress

**Solution:** Focus on one area at a time

---

### 2. Not Asking Questions

**Problem:** Stay confused, make assumptions

**Solution:** Ask questions regularly

---

### 3. Not Contributing Early

**Problem:** No visible value, slow integration

**Solution:** Start with small contributions

---

### 4. Working in Isolation

**Problem:** Miss context, build wrong things

**Solution:** Collaborate, pair program

---

### 5. Not Documenting

**Problem:** Forget learnings, repeat questions

**Solution:** Document everything

---

## 🎯 Your 90-Day Action Plan

### Days 1-30: Foundation

**Week 1:**
- [ ] Setup environment
- [ ] Meet team
- [ ] Read documentation
- [ ] Create learning journal

**Week 2:**
- [ ] Understand business
- [ ] Map user journeys
- [ ] Create architecture diagram
- [ ] Build relationships

**Week 3:**
- [ ] Deep dive into architecture
- [ ] Trace code flows
- [ ] Understand patterns
- [ ] Update documentation

**Week 4:**
- [ ] Navigate codebase
- [ ] Identify key files
- [ ] Run tests
- [ ] Prepare for contributions

---

### Days 31-60: Contribution

**Week 5-6:**
- [ ] Make first contributions
- [ ] Fix documentation
- [ ] Small bug fixes
- [ ] Improve tests

**Week 7-8:**
- [ ] Understand business logic
- [ ] Trace complex flows
- [ ] Document business rules
- [ ] Take on small features

---

### Days 61-90: Ownership

**Week 9-10:**
- [ ] Own a feature
- [ ] End-to-end responsibility
- [ ] Propose improvements
- [ ] Help others

**Week 11-12:**
- [ ] Build reputation
- [ ] Share knowledge
- [ ] Mentor others
- [ ] Drive improvements

---

## 📝 Daily Checklist

### Morning (15 min)

- [ ] Review today's goals
- [ ] Check calendar/meetings
- [ ] Identify one learning focus
- [ ] Plan one contribution

### During Work

- [ ] Attend standup (be prepared)
- [ ] Work on planned tasks
- [ ] Ask questions when stuck
- [ ] Help others when possible
- [ ] Document learnings

### End of Day (15 min)

- [ ] Update learning journal
- [ ] Note questions for tomorrow
- [ ] Review tomorrow's plan
- [ ] Update progress tracker

---

## 🔥 Quick Wins to Build Reputation

### Week 1-2

- ✅ Fix outdated documentation
- ✅ Add missing comments to code
- ✅ Create onboarding guide for next person
- ✅ Map architecture diagram

### Week 3-4

- ✅ Fix small bugs
- ✅ Improve test coverage
- ✅ Add missing tests
- ✅ Document unclear code

### Week 5-6

- ✅ Implement small features
- ✅ Improve error messages
- ✅ Add logging
- ✅ Optimize slow queries

### Week 7-8

- ✅ Refactor messy code
- ✅ Improve performance
- ✅ Add monitoring
- ✅ Create runbooks

---

## 💬 Communication Tips

### In Meetings

- **Be prepared:** Read agenda, prepare questions
- **Participate:** Share insights, ask questions
- **Take notes:** Don't rely on memory
- **Follow up:** Send summary if needed

### In Code Reviews

- **Be thorough:** Check logic, patterns, tests
- **Be constructive:** Suggest improvements
- **Be respectful:** Focus on code, not person
- **Learn:** Ask questions about patterns

### In 1-on-1s

- **Be honest:** Share challenges
- **Be proactive:** Ask for feedback
- **Be specific:** Give examples
- **Be open:** Accept feedback

---

## 🎓 Learning Resources Strategy

### Internal Resources

1. **Codebase**
   - Read code daily
   - Trace flows
   - Understand patterns

2. **Documentation**
   - README files
   - Architecture docs
   - Runbooks

3. **Team Members**
   - Pair programming
   - Code reviews
   - Knowledge sharing sessions

### External Resources

1. **Technologies Used**
   - Official documentation
   - Tutorials
   - Best practices

2. **Patterns & Practices**
   - Design patterns
   - Architectural patterns
   - Industry best practices

---

## 🏆 Success Metrics

### Technical Understanding

- [ ] Can navigate codebase confidently
- [ ] Understand architecture
- [ ] Know key business rules
- [ ] Can trace user flows
- [ ] Understand deployment process

### Contribution

- [ ] Made meaningful contributions
- [ ] Code merged to main
- [ ] Helped others
- [ ] Improved documentation
- [ ] Fixed bugs/added features

### Reputation

- [ ] Team trusts your work
- [ ] Others ask you questions
- [ ] You're included in decisions
- [ ] You're assigned important work
- [ ] You're considered a strong resource

---

## 🔄 Consistency Framework

### Daily (1-2 hours)

1. **Morning (30 min):** Deep learning
2. **During work:** Contribute
3. **End of day (15 min):** Journal
4. **Weekly (1 hour):** Review

### Weekly

1. **Monday:** Plan week
2. **Tuesday-Thursday:** Execute
3. **Friday:** Review week
4. **Weekend (optional):** Prepare

### Monthly

1. **Week 1:** Foundation
2. **Week 2:** Deep dive
3. **Week 3:** Contribution
4. **Week 4:** Review & plan

---

## 📚 Template: Learning Journal

```markdown
## [Date] Learning Journal

### What I Learned Today
- [Learning 1]
- [Learning 2]
- [Learning 3]

### What I Contributed
- [Contribution 1]
- [Contribution 2]

### Questions I Have
- [Question 1]
- [Question 2]

### People I Interacted With
- [Name] - [Context]

### Tomorrow's Focus
- [Focus area]
- [Specific task]
```

---

## 🎯 Final Checklist: Your First 90 Days

### Month 1: Foundation

- [ ] Environment setup complete
- [ ] Met all team members
- [ ] Understand business basics
- [ ] Created architecture diagram
- [ ] Made first contribution
- [ ] Built initial relationships

### Month 2: Contribution

- [ ] Understand core business logic
- [ ] Made multiple contributions
- [ ] Own small features
- [ ] Help others regularly
- [ ] Build deeper relationships

### Month 3: Ownership

- [ ] Own features end-to-end
- [ ] Propose improvements
- [ ] Share knowledge
- [ ] Mentor others
- [ ] Established reputation

---

## 💡 Key Takeaways

1. **Consistency > Intensity**
   - 30-60 min daily > 8 hours weekly
   - Small daily progress > Big bursts

2. **Quality > Quantity**
   - Understand deeply > Know superficially
   - One good contribution > Many poor ones

3. **Contribution > Consumption**
   - Learn AND contribute
   - Show value early
   - Build reputation

4. **Relationships > Tasks**
   - People matter
   - Collaboration > Isolation
   - Help others

5. **Documentation > Memory**
   - Write everything down
   - Update regularly
   - Share knowledge

---

*"Success in a new company isn't about knowing everything. It's about learning consistently, contributing meaningfully, and building relationships authentically."*

