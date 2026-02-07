# Project Management Tools - Interview Guide

## 1. JIRA

### What is JIRA?

**JIRA** is a project management and issue tracking tool developed by Atlassian. It's widely used for agile software development, bug tracking, and project management.

**Key Features:**
- Issue tracking
- Agile boards (Scrum, Kanban)
- Sprint planning
- Reporting and dashboards
- Custom workflows

---

### Issue Types

**Common Issue Types:**
- **Story**: User story (feature from user perspective)
- **Bug**: Defect or error
- **Task**: General work item
- **Epic**: Large feature broken into stories
- **Subtask**: Part of a larger issue

**Creating Issues:**
1. Click "Create" button
2. Select project
3. Choose issue type
4. Fill required fields:
   - **Summary**: Brief description
   - **Description**: Detailed information
   - **Assignee**: Person responsible
   - **Reporter**: Person who created
   - **Priority**: High, Medium, Low
   - **Labels**: Tags for categorization
   - **Components**: Parts of the system

**Issue Fields:**
- **Key**: Unique identifier (e.g., PROJ-123)
- **Status**: Current state (To Do, In Progress, Done)
- **Resolution**: How issue was resolved
- **Created/Updated**: Timestamps
- **Comments**: Discussion thread
- **Attachments**: Files, screenshots

---

### Workflows

**Definition**: States an issue goes through

**Default Workflow:**
```
To Do → In Progress → Done
```

**Custom Workflows:**
- Define custom states
- Add transitions between states
- Set permissions for transitions
- Add validators and post-functions

**Common States:**
- **To Do**: Not started
- **In Progress**: Currently being worked on
- **In Review**: Code review, testing
- **Done**: Completed
- **Reopened**: Issue found after completion

**Transitions:**
- Actions that move issue between states
- Example: "Start Progress" (To Do → In Progress)
- Can require comments, assignee, etc.

---

### Sprint Planning

**Sprint:**
- Time-boxed iteration (typically 1-4 weeks)
- Team commits to completing set of stories

**Sprint Planning Process:**
1. **Create Sprint**: 
   - Click "Create Sprint"
   - Set start and end dates
   - Name sprint (e.g., "Sprint 1 - Authentication")

2. **Add Stories to Sprint**:
   - Drag issues from backlog to sprint
   - Or use "Sprint" field when creating issue

3. **Estimate Stories**:
   - Use Story Points (Fibonacci: 1, 2, 3, 5, 8, 13)
   - Or time estimates (hours)
   - Team discusses and agrees on estimate

4. **Commit to Sprint**:
   - Team agrees on what can be completed
   - Sprint goal defined

**Sprint Board:**
- Visual representation of sprint
- Columns: To Do, In Progress, Done
- Drag issues between columns
- Shows progress

**Sprint Ceremonies:**
- **Sprint Planning**: Plan what to do
- **Daily Standup**: Daily progress update
- **Sprint Review**: Demo completed work
- **Sprint Retrospective**: What went well, what to improve

---

### User Stories and Epics

**User Story Format:**
```
As a [user type]
I want [goal]
So that [benefit]
```

**Example:**
```
As a customer
I want to reset my password
So that I can regain access to my account
```

**Story Components:**
- **Title**: Brief summary
- **Description**: User story format + details
- **Acceptance Criteria**: Conditions for "Done"
  - Example:
    - User can click "Forgot Password"
    - Email sent with reset link
    - Link expires after 24 hours
- **Story Points**: Effort estimate

**Epic:**
- Large feature or initiative
- Contains multiple user stories
- Example: "User Authentication" epic contains:
  - Story: User login
  - Story: Password reset
  - Story: Two-factor authentication

**Creating Epic:**
1. Create issue, type "Epic"
2. Fill epic name and description
3. Link stories to epic (Epic Link field)

---

### Reporting and Dashboards

**Common Reports:**
- **Burndown Chart**: Work remaining over time
- **Velocity Chart**: Story points completed per sprint
- **Sprint Report**: Sprint summary
- **Created vs Resolved**: Issue creation vs resolution rate
- **Time Tracking**: Time spent on issues

**Dashboards:**
- Customizable views
- Add gadgets (charts, filters, lists)
- Share with team

**Creating Dashboard:**
1. Click "Dashboards" → "Create Dashboard"
2. Add gadgets:
   - **Filter Results**: List of issues
   - **Assigned to Me**: Your issues
   - **Created vs Resolved**: Trend chart
   - **Sprint Burndown**: Sprint progress

**Useful Filters:**
- `assignee = currentUser()`: My issues
- `project = PROJ AND status = "In Progress"`: Active issues
- `sprint in openSprints()`: Current sprint issues

---

### Common JIRA Concepts

**Backlog:**
- List of all issues not in a sprint
- Prioritized list
- Source for sprint planning

**Board:**
- Visual representation of work
- **Scrum Board**: Sprint-focused
- **Kanban Board**: Continuous flow

**Filters:**
- Saved searches
- Reusable queries
- Use JQL (JIRA Query Language)

**JQL Examples:**
```
project = PROJ AND status = "In Progress"
assignee = currentUser() AND priority = High
created >= -7d AND type = Bug
```

**Components:**
- Parts of the system
- Example: "Authentication", "Payment", "UI"
- Helps categorize issues

**Versions:**
- Software releases
- Link issues to versions
- Track what's in each release

---

## 2. ServiceNow

### What is ServiceNow?

**ServiceNow** is a cloud-based platform for IT Service Management (ITSM), IT Operations Management (ITOM), and business process automation.

**Key Modules:**
- Incident Management
- Change Management
- Service Catalog
- Problem Management
- Configuration Management (CMDB)

---

### Incident Management

**Incident:**
- Unplanned interruption to service
- Example: Application is down, user can't login

**Incident Lifecycle:**
1. **Create**: User reports issue
2. **Assign**: Assign to support team/engineer
3. **Investigate**: Analyze and diagnose
4. **Resolve**: Fix the issue
5. **Close**: Confirm resolution with user

**Incident Fields:**
- **Number**: Unique ID (INC0010001)
- **Short Description**: Brief summary
- **Description**: Detailed information
- **State**: New, In Progress, Resolved, Closed
- **Priority**: Based on impact and urgency
- **Assigned to**: Person working on it
- **Category**: Type of issue
- **Work Notes**: Internal notes
- **Comments**: User-visible updates

**Priority Matrix:**
- **Critical**: System down, many users affected
- **High**: Major feature broken
- **Medium**: Minor issue, workaround exists
- **Low**: Cosmetic issue, low impact

**Creating Incident:**
1. Navigate to "Incidents" module
2. Click "New"
3. Fill required fields
4. Submit (creates incident)

**Updating Incident:**
- Add work notes (internal)
- Add comments (user-visible)
- Change state
- Update assignment
- Link related incidents/problems

---

### Change Management

**Change:**
- Modification to IT infrastructure or service
- Example: Deploy new version, update server

**Change Types:**
- **Normal**: Standard change process
- **Standard**: Pre-approved, low risk
- **Emergency**: Urgent, expedited process

**Change Lifecycle:**
1. **Request**: Submit change request
2. **Review**: Change Advisory Board (CAB) reviews
3. **Approve/Reject**: Decision made
4. **Implement**: Execute change
5. **Review**: Post-implementation review
6. **Close**: Change completed

**Change Fields:**
- **Number**: Unique ID (CHG0010001)
- **Short Description**: What is changing
- **Description**: Detailed information
- **State**: New, Assess, Approved, Implement, Review, Closed
- **Risk**: Low, Medium, High
- **Impact**: Low, Medium, High
- **Category**: Type of change
- **Planned Start/End**: Schedule

**Change Advisory Board (CAB):**
- Reviews and approves changes
- Assesses risk and impact
- Schedules changes

**Creating Change:**
1. Navigate to "Changes" module
2. Click "New"
3. Select change type
4. Fill required information
5. Submit for approval

---

### Service Catalog

**Purpose**: Self-service portal for users to request services

**Catalog Items:**
- Predefined services users can request
- Examples:
  - Request new software
  - Request access to system
  - Request hardware
  - Request password reset

**Request Process:**
1. User browses catalog
2. Selects catalog item
3. Fills request form
4. Submits request
5. Request routed to appropriate team
6. Fulfilled and closed

**Catalog Item Types:**
- **Request**: Standard request
- **Order Guide**: Multiple items
- **Content Item**: Information only

**Creating Catalog Item:**
1. Navigate to "Service Catalog"
2. Create catalog item
3. Define:
   - Name and description
   - Category
   - Request form fields
   - Fulfillment workflow
   - Assignment group

---

### Basic Navigation

**Main Modules:**
- **Incidents**: Manage incidents
- **Changes**: Manage changes
- **Problems**: Root cause analysis
- **Service Catalog**: User requests
- **Knowledge**: Knowledge base articles
- **Reports**: Reporting and dashboards

**Navigation Bar:**
- Left sidebar with module links
- Click module to access

**Search:**
- Global search bar (top)
- Search for incidents, changes, users, etc.
- Use filters to narrow results

**Filters:**
- Saved filters for common searches
- Example: "My Open Incidents"
- Create custom filters

**Lists:**
- Table view of records
- Sortable columns
- Filterable
- Exportable

**Forms:**
- Detailed view of single record
- Edit fields
- View related records
- Add comments/notes

**Common Actions:**
- **New**: Create new record
- **Edit**: Modify record
- **Delete**: Remove record
- **Watch**: Get notifications
- **Share**: Share with others

---

## Interview Questions to Prepare

1. **What is JIRA? What are its main features?**
2. **Explain the difference between Story, Bug, and Task.**
3. **What is a sprint? How do you plan a sprint?**
4. **What is the difference between Epic and Story?**
5. **What is a workflow in JIRA?**
6. **What is ServiceNow? What modules does it have?**
7. **Explain the incident management process.**
8. **What is the difference between Incident and Change?**
9. **What is a Service Catalog?**
10. **How do you prioritize incidents in ServiceNow?**

