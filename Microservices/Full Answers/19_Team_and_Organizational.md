# Microservices Interview Answers - Team & Organizational (Questions 361-380)

## 361. How do you organize teams for microservices?

**Team Organization:**

1. **Service Ownership**
   - Team per service
   - Full ownership
   - Autonomy

2. **Cross-Functional Teams**
   - Developers, DevOps, QA
   - Full stack
   - Self-sufficient

3. **2-Pizza Teams**
   - Small teams
   - 5-9 people
   - Effective communication

4. **Platform Team**
   - Infrastructure
   - Tooling
   - Support

**Best Practices:**
- Service ownership
- Cross-functional teams
- Small teams
- Platform support
- Clear responsibilities

---

## 362. What is the difference between functional teams and cross-functional teams?

**Functional Teams:**
- **Structure**: By function
- **Example**: Dev team, QA team, DevOps team
- **Coordination**: High coordination needed
- **Speed**: Slower

**Cross-Functional Teams:**
- **Structure**: By service/product
- **Example**: Order service team (dev, QA, DevOps)
- **Coordination**: Low coordination
- **Speed**: Faster

**Comparison:**

| Aspect | Functional | Cross-Functional |
|--------|-----------|------------------|
| **Structure** | By function | By service |
| **Coordination** | High | Low |
| **Speed** | Slower | Faster |

**Best Practices:**
- Prefer cross-functional teams
- Service ownership
- Faster delivery
- Better alignment

---

## 363. How do you implement Conway's Law in microservices?

**Conway's Law:**
- Organizations design systems that mirror their communication structure
- Team structure → System structure

**Implementation:**

1. **Team Structure**
   - Team per service
   - Service boundaries
   - Team autonomy

2. **Communication**
   - Team communication
   - Service interfaces
   - API contracts

3. **Ownership**
   - Team owns service
   - Full responsibility
   - Autonomy

**Best Practices:**
- Align teams with services
- Team per service
- Clear ownership
- Autonomy
- Communication structure

---

## 364. What is the difference between team structure and service structure?

**Team Structure:**
- **Focus**: Organization
- **Scope**: Teams, people
- **Purpose**: How teams organized

**Service Structure:**
- **Focus**: Architecture
- **Scope**: Services, code
- **Purpose**: How services organized

**Relationship:**
- Team structure influences service structure
- Conway's Law
- Align for success

**Best Practices:**
- Align team and service structure
- Team per service
- Clear mapping
- Autonomy

---

## 365. How do you handle communication between teams?

**Team Communication:**

1. **API Contracts**
   - Well-defined APIs
   - Contracts
   - Documentation

2. **Events**
   - Event-driven
   - Async communication
   - Loose coupling

3. **Documentation**
   - API documentation
   - Architecture docs
   - Runbooks

4. **Regular Syncs**
   - Standups
   - Architecture reviews
   - Knowledge sharing

**Best Practices:**
- API contracts
- Event-driven
- Good documentation
- Regular syncs
- Clear communication

---

## 366. What is the difference between synchronous and asynchronous team communication?

**Synchronous:**
- **Type**: Real-time
- **Examples**: Meetings, calls
- **Use Case**: Immediate discussion
- **Efficiency**: Lower

**Asynchronous:**
- **Type**: Delayed
- **Examples**: Email, docs, chat
- **Use Case**: Non-urgent
- **Efficiency**: Higher

**Comparison:**

| Aspect | Synchronous | Asynchronous |
|--------|-------------|--------------|
| **Type** | Real-time | Delayed |
| **Efficiency** | Lower | Higher |
| **Use Case** | Urgent | Non-urgent |

**Best Practices:**
- Async for non-urgent
- Sync for urgent
- Balance both
- Respect time zones

---

## 367. How do you implement shared ownership in microservices?

**Shared Ownership:**

1. **Platform Team**
   - Shared infrastructure
   - Tooling
   - Support

2. **Shared Standards**
   - Coding standards
   - Architecture patterns
   - Best practices

3. **Knowledge Sharing**
   - Documentation
   - Training
   - Cross-team learning

**Best Practices:**
- Platform team for infrastructure
- Shared standards
- Knowledge sharing
- Balance ownership
- Avoid shared code

---

## 368. What is the difference between shared ownership and service ownership?

**Shared Ownership:**
- **Scope**: Multiple services
- **Team**: Multiple teams
- **Control**: Shared
- **Use Case**: Infrastructure

**Service Ownership:**
- **Scope**: Single service
- **Team**: Single team
- **Control**: Full
- **Use Case**: Services

**Comparison:**

| Aspect | Shared | Service |
|--------|--------|---------|
| **Scope** | Multiple | Single |
| **Control** | Shared | Full |
| **Use Case** | Infrastructure | Services |

**Best Practices:**
- Service ownership for services
- Shared ownership for infrastructure
- Clear boundaries
- Avoid shared code

---

## 369. How do you handle knowledge sharing in microservices?

**Knowledge Sharing:**

1. **Documentation**
   - API documentation
   - Architecture docs
   - Runbooks

2. **Training**
   - Cross-team training
   - Workshops
   - Knowledge sessions

3. **Code Reviews**
   - Cross-team reviews
   - Learning opportunity
   - Best practices

4. **Communities**
   - Tech communities
   - Architecture reviews
   - Knowledge forums

**Best Practices:**
- Comprehensive documentation
- Regular training
- Code reviews
- Communities
- Knowledge sharing culture

---

## 370. What is the difference between documentation and runbooks?

**Documentation:**
- **Purpose**: General information
- **Audience**: All developers
- **Content**: Architecture, APIs, design
- **Scope**: Broad

**Runbooks:**
- **Purpose**: Operational procedures
- **Audience**: Operations team
- **Content**: How to operate, troubleshoot
- **Scope**: Operational

**Comparison:**

| Aspect | Documentation | Runbooks |
|--------|--------------|-----------|
| **Purpose** | Information | Operations |
| **Audience** | Developers | Operations |
| **Content** | Architecture | Procedures |

**Best Practices:**
- Both are important
- Documentation for developers
- Runbooks for operations
- Keep updated
- Clear and concise

---

## 371. How do you implement on-call rotation for microservices?

**On-Call Rotation:**

1. **Service Ownership**
   - Team owns service
   - On-call for their service
   - Clear responsibility

2. **Rotation Schedule**
   - Rotate weekly/monthly
   - Fair distribution
   - Backup on-call

3. **Escalation**
   - Escalation path
   - Clear procedures
   - Support structure

4. **Tools**
   - PagerDuty, Opsgenie
   - Alerting
   - Incident management

**Best Practices:**
- Service ownership
- Fair rotation
- Escalation path
- Good tooling
- Clear procedures

---

## 372. What is the difference between on-call and support rotation?

**On-Call:**
- **Purpose**: Production incidents
- **Scope**: Critical issues
- **Response**: Immediate
- **Use Case**: Production support

**Support Rotation:**
- **Purpose**: General support
- **Scope**: All issues
- **Response**: Business hours
- **Use Case**: Customer support

**Comparison:**

| Aspect | On-Call | Support |
|--------|---------|---------|
| **Purpose** | Incidents | Support |
| **Response** | Immediate | Business hours |
| **Scope** | Critical | All |

**Best Practices:**
- On-call for incidents
- Support for general
- Clear distinction
- Appropriate response times

---

## 373. How do you handle incident management in microservices?

**Incident Management:**

1. **Detection**
   - Monitoring
   - Alerting
   - Early detection

2. **Response**
   - On-call response
   - Escalation
   - Communication

3. **Resolution**
   - Troubleshooting
   - Fix deployment
   - Verification

4. **Post-Mortem**
   - Root cause analysis
   - Learnings
   - Improvements

**Best Practices:**
- Quick detection
- Fast response
- Clear communication
- Post-mortems
- Continuous improvement

---

## 374. What is the difference between incident and problem management?

**Incident:**
- **Focus**: Immediate issue
- **Goal**: Restore service
- **Scope**: Single occurrence
- **Timeline**: Immediate

**Problem:**
- **Focus**: Root cause
- **Goal**: Prevent recurrence
- **Scope**: Underlying issue
- **Timeline**: Long-term

**Comparison:**

| Aspect | Incident | Problem |
|--------|----------|---------|
| **Focus** | Immediate | Root cause |
| **Goal** | Restore | Prevent |
| **Timeline** | Immediate | Long-term |

**Best Practices:**
- Handle incidents first
- Then investigate problems
- Root cause analysis
- Prevent recurrence

---

## 375. How do you implement post-mortem in microservices?

**Post-Mortem:**

1. **Timing**
   - Within 48 hours
   - While fresh
   - Before details forgotten

2. **Participants**
   - All involved
   - Cross-functional
   - Open discussion

3. **Structure**
   - What happened
   - Root cause
   - Impact
   - Actions

4. **Follow-Up**
   - Action items
   - Track progress
   - Prevent recurrence

**Best Practices:**
- Timely post-mortems
- Blameless culture
- Root cause focus
- Action items
- Follow-up

---

## 376. What is the difference between post-mortem and retrospective?

**Post-Mortem:**
- **Trigger**: Incident
- **Focus**: What went wrong
- **Timing**: After incident
- **Scope**: Specific incident

**Retrospective:**
- **Trigger**: Regular (sprint)
- **Focus**: Improvement
- **Timing**: Regular intervals
- **Scope**: General

**Comparison:**

| Aspect | Post-Mortem | Retrospective |
|--------|-------------|---------------|
| **Trigger** | Incident | Regular |
| **Focus** | What went wrong | Improvement |
| **Timing** | After incident | Regular |

**Best Practices:**
- Post-mortems for incidents
- Retrospectives for improvement
- Both are valuable
- Regular practice

---

## 377. How do you handle code reviews in microservices?

**Code Reviews:**

1. **Service Ownership**
   - Team reviews own code
   - Service-specific
   - Domain expertise

2. **Cross-Team Reviews**
   - For shared code
   - API changes
   - Architecture changes

3. **Automated Checks**
   - Linting
   - Tests
   - Security scanning

**Best Practices:**
- Team reviews own code
- Cross-team for shared
- Automated checks
- Constructive feedback
- Learning opportunity

---

## 378. What is the difference between code review and pair programming?

**Code Review:**
- **Timing**: After code written
- **Approach**: Asynchronous
- **Efficiency**: Review multiple PRs
- **Use Case**: Quality check

**Pair Programming:**
- **Timing**: During coding
- **Approach**: Synchronous
- **Efficiency**: Real-time
- **Use Case**: Learning, quality

**Comparison:**

| Aspect | Code Review | Pair Programming |
|--------|-------------|------------------|
| **Timing** | After | During |
| **Approach** | Async | Sync |
| **Efficiency** | Review multiple | Real-time |

**Best Practices:**
- Code reviews standard
- Pair programming for complex
- Both valuable
- Choose based on needs

---

## 379. How do you implement knowledge transfer in microservices?

**Knowledge Transfer:**

1. **Documentation**
   - Comprehensive docs
   - API documentation
   - Architecture docs

2. **Training**
   - Onboarding
   - Cross-training
   - Workshops

3. **Pairing**
   - Pair programming
   - Shadowing
   - Mentoring

4. **Communities**
   - Tech communities
   - Knowledge sharing
   - Forums

**Best Practices:**
- Comprehensive documentation
- Regular training
- Pairing and mentoring
- Communities
- Knowledge sharing culture

---

## 380. What is the difference between knowledge transfer and documentation?

**Knowledge Transfer:**
- **Type**: Active process
- **Method**: Training, pairing
- **Timing**: Ongoing
- **Interaction**: Person-to-person

**Documentation:**
- **Type**: Passive resource
- **Method**: Written docs
- **Timing**: As needed
- **Interaction**: Self-service

**Comparison:**

| Aspect | Knowledge Transfer | Documentation |
|--------|-------------------|--------------|
| **Type** | Active | Passive |
| **Method** | Training | Written |
| **Timing** | Ongoing | As needed |

**Best Practices:**
- Both are important
- Documentation for reference
- Knowledge transfer for learning
- Complement each other
- Comprehensive approach

