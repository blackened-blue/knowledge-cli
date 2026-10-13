# Data Model: Architecture Foundation

These are the entities this feature produces and the rules between them. They describe documents and records, not product data. Product data (pages, markers, the queue) is modelled by spec 001's plan.

## Entities

### Business Capability

| Field | Meaning |
|---|---|
| id | `BC-` followed by a number |
| name | Short noun phrase |
| description | One sentence |
| stories | Stories in feature specs that justify it (at least one) |
| roles | Roles that may use it |

Rule: a capability with no story is flagged as unjustified (Story 1, scenario 2).

### Role

| Field | Meaning |
|---|---|
| id | `R-` followed by a number |
| name | For example, admin, member, reviewer |
| capabilities | Capabilities the role may use |

### Business Rule

| Field | Meaning |
|---|---|
| id | `BR-` followed by a number |
| statement | The condition that always holds |
| source | The constitution principle it comes from (exactly one) |

### Component

| Field | Meaning |
|---|---|
| id | `C-` followed by a number |
| name | Matches a package or part in the project structure |
| responsibility | One sentence |
| interfaces | What it offers to other components |
| data owned | Data it creates and is allowed to change |
| trust boundary | Whether data crossing into it is checked, and how |
| failure behavior | What it does when it fails, and what the member sees |
| depends on | Components it may import (checked by the dependency check) |

Rule: a component may depend only on components in its allowed list.

### Quality Target

| Field | Meaning |
|---|---|
| id | `QT-` followed by a number |
| attribute | For example, performance, security, portability |
| target | A measurable value |
| verification | How it is checked, and by which experiment or test |
| source | The requirement it comes from in spec 000 or 001 |

### Architecture Decision

| Field | Meaning |
|---|---|
| id | `D-` followed by a number |
| title | Short statement |
| status | draft, proposed, accepted, superseded |
| date | Date of the last status change |
| criteria | What the candidates were judged on |
| candidates | At least two, or the constraint that left one |
| choice | The chosen candidate |
| rationale | Why |
| rejected | Each rejected candidate with the reason |
| review triggers | Conditions that reopen the decision |
| replaced by | Link to the replacing decision, if any |

State transitions: draft to proposed when evidence is attached. Proposed to accepted only when the owner approves (FR-015). Accepted to superseded when replaced. A decision that depends on an unproven assumption cannot leave draft until an experiment result is attached (FR-008).

### Experiment

| Field | Meaning |
|---|---|
| id | `E-` followed by a number |
| assumption | What it tests |
| method | What was done, on which systems |
| time spent | At most one working day |
| result | Numbers and a pass or fail against the stated criterion |
| limits | What the experiment did not cover |
| decisions | Decisions it supports |

Rule: experiments are throwaway. Only the record is kept.

### Traceability Map

One row per requirement or success criterion of a feature spec.

| Field | Meaning |
|---|---|
| source id | For example, `001/FR-014` |
| text | The requirement, shortened |
| components | One or more components that satisfy it |
| decisions | One or more decisions that shape it |
| verification | The test or experiment that proves it |
| gap | Empty, or a note with an owner |

Rule: a row with no component or no decision is a gap and needs an owner (FR-011).

### Project Skeleton

| Field | Meaning |
|---|---|
| layout | Matches the approved project structure |
| check command | The one documented command that builds, lints and tests |
| dependency check | Fails on a forbidden edge and names it |
| version command | The only product command |
| automation | What lets changes reach the main line as the constitution describes |

## Relationships

- A Business Capability has one or more Roles, and is justified by one or more stories.
- A Business Rule has exactly one constitution principle as its source.
- A Component is named after a part of the project structure and satisfies one or more rows of the Traceability Map.
- An Architecture Decision shapes one or more Components and may be supported by one or more Experiments.
- A Quality Target is verified by an Experiment or a test.

## Validation rules from the spec

- Every functional requirement and success criterion of spec 001 has a Traceability Map row (SC-001).
- Every stack decision lists at least two candidates or names the constraint that left one (SC-002).
- Nine of nine constitution principles map to a mechanism and a verification approach (SC-003).
- Every decision has a status, a date and review triggers (FR-014).
- The skeleton step cannot start while any stack or structure decision is not accepted (FR-019).
