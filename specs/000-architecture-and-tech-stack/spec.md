# Feature Specification: Architecture and Technology Stack

**Feature Branch**: none created (work is on `develop`; branch choice is left to the owner)

**Created**: 2026-10-23

**Status**: Draft

**Input**: User description: "Spec the architecture and tech stack first (constitution Principle III). The first user-facing feature, to be specified afterwards as spec 001, is: Setup and team management. An admin creates a knowledge repo from scratch; a member joins a team with a repo URL; manage members, roles, projects and env; uninstall; project or user scope (--scope); single-repo mode (--self) where the current repo is the knowledge repo; an HTTP knowledge repo without Git (read-only, needs only an API key); provider support: generic git."

## Clarifications

### Session 2026-10-23

- Q: Which operating systems must knowledge-cli support? -> A: macOS only
- Q: How do team members install knowledge-cli? -> A: Through the package manager of the chosen language; the user must already have its runtime installed
- Q: Where is the API key of an HTTP knowledge repo stored on the user machine? -> A: macOS Keychain
- Q: Should read commands work without an internet connection? -> A: Yes, after the first sync; changes still need a connection
- Q: How fast must a typical read command finish from the local copy? -> A: Within 1 second
- Q: Can one user belong to several teams (several knowledge repos) on the same machine? -> A: Yes, but only one team is active at a time
- Q: How does the tool authenticate to a private git repo? -> A: It uses the git already set up on the user machine (SSH key or credential helper) and stores no git password itself
- Q: What happens when two admins change the same git knowledge repo at once and the changes conflict? -> A: The tool stops, tells the user to sync, and the user retries; it never overwrites another change
- Q: What does uninstall remove from the user machine? -> A: Everything the tool created (local copies, settings, stored API keys), after the user confirms
- Q: How large can one team's knowledge repo be? -> A: Up to 100 members and 5,000 files

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Agreed architecture before any feature work (Priority: P1)

The project owner wants one agreed description of how knowledge-cli is structured, so that no
feature is built on a guess. The description covers the business view (who uses the tool and
why), the system view (the main parts and how they relate), and the project structure.

**Why this priority**: Constitution Principle III forbids feature work until this exists. Every
later spec depends on it.

**Independent Test**: The owner reads the architecture record and can answer, without asking
anyone: who the actors are, what the main parts are, which part may depend on which, and where
a new piece of code belongs.

**Acceptance Scenarios**:

1. **Given** the architecture record is complete, **When** the owner picks any capability from the
   first-feature list, **Then** the record shows which part owns it and which parts it may use.
2. **Given** the architecture record, **When** a reviewer checks the dependency direction,
   **Then** the Domain part depends on no infrastructure (Principle II).
3. **Given** a proposed change that contradicts the record, **When** it is reviewed, **Then**
   the record must be amended first (Principle III).

---

### User Story 2 - Technology stack chosen with evidence (Priority: P1)

The owner wants the programming language, runtime, test tools and key libraries chosen with
written evidence and rejected alternatives, rather than by habit.

**Why this priority**: Principle III requires the stack to be recorded with its supporting
evidence, and planning cannot start without it.

**Independent Test**: For each stack choice, a reader finds the requirement it serves, at least
one rejected alternative, and the reason for the decision.

**Acceptance Scenarios**:

1. **Given** a stack choice, **When** the owner opens its record, **Then** it names the
   requirement it serves, the alternatives considered, and the evidence used.
2. **Given** that macOS is the only supported platform, **When** the stack is reviewed,
   **Then** every stack choice runs on macOS.
3. **Given** a third-party dependency, **When** it is reviewed, **Then** it is justified and is
   not used in the Domain part (Constitution, Additional Constraints).

---

### User Story 3 - The architecture supports the first feature (Priority: P2)

The owner wants proof that the architecture can carry the first planned feature (setup and team
management) without redesign, even though that feature is specified separately later.

**Why this priority**: A structure that cannot carry the known first feature would be wrong
the moment spec 001 starts.

**Independent Test**: Each capability in the first-feature list is mapped to the part that
owns it, with no capability left unowned.

**Acceptance Scenarios**:

1. **Given** the first-feature capabilities (create a knowledge repo, join a team by URL,
   manage members, roles, projects and env, uninstall, project or user scope, single-repo
   mode, HTTP knowledge repo without Git that is read-only and needs only an API key, generic
   git provider), **When** they are
   mapped to the architecture, **Then** each has an owning part.
2. **Given** that the knowledge repo can be a git repository or an HTTP knowledge repo without
   Git (read-only, API key only),
   **When** the architecture is reviewed, **Then** the Domain part sees both through the same
   port without knowing which one is used.

---

### Edge Cases

- What happens when two stack options both satisfy the requirements? The record states the
  tie-break reason (for example simplicity under Principle IV), not just the winner.
- What happens when a user runs the tool on an operating system other than macOS? The record
  states that it is unsupported and not tested.
- What happens when a user reads data before the first sync has ever finished? The tool reports
  that no local copy exists yet and tells the user to sync.
- What happens when two admins change the same git knowledge repo at once? The second change
  is stopped with a message to sync and retry; nothing is overwritten.
- What happens when the first-feature list changes before spec 001 starts? The mapping is
  updated and the architecture is amended through the Governance process.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The architecture record MUST describe the business view: actors, goals, and the
  main capabilities the tool provides to each actor.
- **FR-002**: The architecture record MUST describe the system view: the main parts, their
  responsibilities, and the allowed direction of dependencies.
- **FR-003**: The architecture record MUST state that the Domain part depends on no
  infrastructure and MUST show how outside systems are reached through ports.
- **FR-004**: The architecture record MUST define the project structure: where each kind of
  code, test, and document lives.
- **FR-005**: Every technology choice MUST be recorded with the requirement it serves, the
  alternatives considered, and the evidence for the decision.
- **FR-006**: The stack decision MUST state macOS as the only supported platform, and MUST
  state that other operating systems are out of scope.
- **FR-007**: The architecture MUST map every capability of the first planned feature to an
  owning part, and MUST list capabilities that have none.
- **FR-008**: The architecture MUST allow the knowledge repo to be either a git repository or an
  HTTP knowledge repo without Git, which is read-only and needs only an API key, without
  changing the Domain part.
- **FR-009**: The architecture MUST support commands that act on a project scope or a user
  scope, and a single-repository mode, without duplicating Domain rules.
- **FR-010**: The architecture MUST show how the test-first rule (Principle I) is applied: which
  kinds of tests exist and which part each kind covers.
- **FR-011**: The architecture MUST show how command output supports both human-readable and
  JSON forms (Principle V) and how failures are reported (Principle VII).
- **FR-012**: The record MUST state which choices are open and who decides them.
- **FR-013**: The stack decision MUST choose a language whose package manager can install the
  tool as a command, and MUST state the minimum runtime version a user needs to have installed.
- **FR-014**: The architecture MUST store the API key of an HTTP knowledge repo in the macOS
  Keychain, reached through a port so the Domain part does not depend on it, and MUST NOT
  write the key to a plain file, a log, or command output.
- **FR-015**: The architecture MUST keep a local copy of the knowledge repo after the first
  sync so that read commands work without a connection, and MUST show a clear message when a
  command that changes data or syncs is run without a connection.
- **FR-016**: The architecture MUST let a user join several teams on one machine, keep a
  separate local copy for each, and act on exactly one active team at a time; commands MUST
  name or show the active team.
- **FR-017**: For a git knowledge repo, the architecture MUST use the git already installed and
  configured on the user machine (SSH key or credential helper), MUST NOT store any git
  password or token itself, and MUST show a clear message when git is missing or access is
  denied.
- **FR-018**: When a change to a git knowledge repo conflicts with another change made at the
  same time, the architecture MUST stop without overwriting anything, tell the user to sync and
  retry, and leave the local copy unchanged.
- **FR-019**: The architecture MUST record everything the tool creates on the user machine
  (local copies, settings, Keychain entries) so that uninstall can remove all of it, and
  uninstall MUST ask the user to confirm before deleting anything.

### Key Entities *(include if feature involves data)*

- **Architecture Record**: The agreed description of actors, parts, dependency direction, and
  project structure. Changes only through amendment.
- **Decision Record**: One stack or design choice with its requirement, alternatives, evidence,
  and owner approval.
- **Capability**: One thing the tool does for an actor, such as joining a team; each is owned by
  exactly one part.
- **Team**: One knowledge repo a user has joined, with its own local copy. A user can have
  several teams, and exactly one is active at a time.
- **Part**: A named area of the system with one responsibility and a list of parts it may use.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the first-feature capabilities are mapped to an owning part, with none
  left unowned.
- **SC-002**: 100% of technology choices have a decision record with at least one rejected
  alternative.
- **SC-003**: The owner can locate where a new piece of code belongs in under 2 minutes using
  only the architecture record.
- **SC-004**: Zero dependency-direction violations are found when the structure is reviewed
  against Principle II.
- **SC-005**: The owner approves the architecture and stack records before any user-facing
  feature plan starts.
- **SC-006**: A typical read command run against the local copy of a team with up to 100
  members and 5,000 files finishes in 1 second or less on a supported Mac, and the architecture
  names how this is measured.

## Assumptions

- knowledge-cli is a command-line tool for managing a team knowledge base, as stated in the
  constitution.
- The first user-facing feature (setup and team management) is specified separately as spec 001
  after this spec is complete; it is used here only to test the architecture.
- The knowledge repo is a shared source of skills, rules, documents and environment settings,
  and its exact content model is decided in spec 001, not here.
- The tool runs on macOS only; Linux and Windows are out of scope for this version.
- Users already have the chosen language runtime installed; a standalone executable is out of
  scope for this version.
- The owner approves decision records; this spec does not choose the technology itself.
