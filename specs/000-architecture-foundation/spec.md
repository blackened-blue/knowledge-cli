# Feature Specification: Architecture Foundation

**Feature Branch**: `000-architecture-foundation`

**Created**: 2026-10-13

**Status**: Draft

**Input**: User description: "Before any feature is built, design the project structure, the system architecture and the business architecture, and choose the tech stack, so the product reaches the best quality. Then create the project skeleton as the last stage of this spec. Do this as spec 000, then return to the plan of 001-team-knowledge-skill."

## Clarifications

### Session 2026-10-13

- Q: Where does the project skeleton belong? -> A: In this spec, as its last stage, after the project owner approves the tech stack and the project structure. It is not part of spec 001.
- Q: In what order do quality goals win when they conflict? -> A: Safe data, then simple design, then portability, then speed. This order guides every trade-off in the architecture and the stack.
- Q: Which operating systems does the first release support? -> A: macOS, Linux and Windows. The architecture and the stack must support all three from the start. This changes the platform assumption in spec 001.
- Q: How does the product relate to the wiki skills for ingest, query and lint? -> A: The wiki skills are an optional companion. They are not bundled and not a dependency. The default layout stays compatible with them.
- Q: Does the product send usage data anywhere? -> A: No. The first release sends nothing out of the member's machine except access to the team's own repository. It has no usage reporting, analytics or crash reports.
- Q: What happens when a tool meets a wiki written in a newer format? -> A: The marker states a format version. A tool that meets a newer version than it understands changes nothing and tells the member to update.
- Q: Is the installer checked for integrity? -> A: Yes. The installer verifies what it downloads against information from the publisher and stops with a message if the check fails.
- Q: What must already be on a member's machine? -> A: An AI assistant that can run commands, and Git. A language runtime may also be required, as in the team tooling this product learns from, but only if the installer checks for it first and tells the assistant exactly what to do when it is missing. The stack decision weighs a distribution that needs no separate runtime as a high-priority criterion.
- Q: When can the plan for spec 001 resume, and when can 001 be implemented? -> A: The plan for 001 resumes as soon as the owner has approved all decisions of this spec. The skeleton must be finished before the implementation of 001 starts, not before its plan. (Refined by the entry "When can the plan for spec 001 resume, given decisions that wait for experiments?" in this session: the plan also waits for experiments E9 and E3, or an owner waiver.)
- Q: Must the system architecture include a threat model? -> A: Yes. It is a required deliverable: the assets to protect, the likely threats, and the mechanisms that answer them, including the secret scan and the installer integrity check.
- Q: How is the product updated? -> A: It never updates itself silently. The health check reports a newer version, and the assistant updates it only when the member asks, with the same integrity check as the first install.
- Q: Does the product keep logs? -> A: Yes, only on the member's machine. The log is size-limited, never holds page content or secrets, and is never sent anywhere. The health check uses it.
- Q: Do SC-013 to SC-018 require behavior tests in this feature? -> A: No. This feature delivers only a skeleton with a version command (SC-012), so these criteria require the architecture to record the mechanism and a verification approach. The 100% pass-rate tests belong to the acceptance tests of spec 001.
- Q: How do members get the product? -> A: As an npm package with provenance (research D-036), following the reference project. The install message checks the prerequisites first (research D-037).
- Q: When can the plan for spec 001 resume, given decisions that wait for experiments? -> A: When experiments E9 (npm provenance and integrity) and E3 (session-start hooks on Windows) have reported their results, or when the project owner has waived them in writing. Decisions accepted pending E9 (D-005, D-027, D-036) and the draft decision D-008 do not block the plan once that condition is met. This refines the earlier answer, which required every decision to be approved.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Agree on the business architecture (Priority: P1)

The project owner reads one business architecture and understands who uses the product, what the product must be able to do, how value moves from one person to another, and which business rules always hold. Every capability traces to a story in the feature specs, and every business rule traces to a principle in the constitution.

**Why this priority**: Every later decision depends on what the product is for. If the business view is vague, the system design and the tech stack are chosen against guesses.

**Independent Test**: Give the business architecture to a reviewer who has not seen the specs. The test passes when the reviewer can name the roles, the capabilities and the main value flows, and can point to the spec story behind each capability.

**Acceptance Scenarios**:

1. **Given** the feature specs and the constitution, **When** the business architecture is written, **Then** it lists every role, every capability and every business rule, and each one links to a story or principle.
2. **Given** a capability with no story behind it, **When** the owner reviews the document, **Then** the capability is flagged as unjustified and removed or backed by a new story.
3. **Given** a story with no capability, **When** the owner reviews the document, **Then** the gap is listed and assigned.

---

### User Story 2 - Agree on the system architecture (Priority: P1)

The project owner reads one system architecture that shows the parts of the product, what each part is responsible for, how the parts talk to each other, where data lives, where trust changes, and what happens when something fails. For each principle in the constitution, the document names the mechanism that upholds it.

**Why this priority**: The principles only help if the structure makes them hard to break. The architecture is where that is decided.

**Independent Test**: Take each constitution principle and each quality target from spec 001. The test passes when each one maps to a named part or interaction in the architecture and to a way to verify it.

**Acceptance Scenarios**:

1. **Given** the nine constitution principles, **When** the owner checks the architecture, **Then** each principle maps to at least one mechanism.
2. **Given** a failure such as no network, a slow sync or a name collision, **When** the owner traces it through the architecture, **Then** the document states what the product does and what the member sees.
3. **Given** a point where data crosses from one trust level to another, **When** the owner reviews it, **Then** the architecture states what is checked there.

---

### User Story 3 - Choose the tech stack with evidence (Priority: P1)

The project owner sees, for every technology concern, the options that were considered, the criteria they were judged against, the choice that won and the reasons, and the options that lost. Where a choice rests on an assumption nobody has proven, a short experiment tests it before the choice is accepted.

**Why this priority**: A tech stack is expensive to change. A choice made without evidence is the most likely source of later rework.

**Independent Test**: Pick any three stack decisions at random. The test passes when each one shows its criteria, at least two candidates (or the constraint that left only one), the reasons for the winner, and the reasons for each loser.

**Acceptance Scenarios**:

1. **Given** a technology concern, **When** a decision is recorded, **Then** it lists the criteria, the candidates, the choice, the rationale and the rejected alternatives.
2. **Given** a choice that depends on an unproven assumption, **When** the decision is reviewed, **Then** an experiment result is attached, or the decision stays in draft.
3. **Given** a constraint from the constitution or from spec 001, **When** a candidate violates it, **Then** the candidate is rejected with the constraint named.

---

### User Story 4 - Define the project structure (Priority: P2)

A contributor opens the project and knows where each kind of file belongs: product code, tests, documentation, specifications, scripts and release material. The structure document also states how the parts of the code may depend on one another, how things are named, and how changes reach the main line.

**Why this priority**: A clear structure keeps the architecture from eroding as contributors come and go. It matters once the architecture is agreed.

**Independent Test**: Give five reviewers the structure document and a list of ten new files to place. The test passes when at least four reviewers place at least nine of the ten files where the document says they belong.

**Acceptance Scenarios**:

1. **Given** a new module, test or document, **When** a contributor consults the structure document, **Then** the document names the exact place for it.
2. **Given** two parts of the code, **When** a contributor wants one to depend on the other, **Then** the document states whether that dependency is allowed.
3. **Given** a change ready for review, **When** the contributor follows the workflow in the document, **Then** it matches the development workflow in the constitution.

---

### User Story 5 - Verify the architecture against spec 001 (Priority: P2)

Before the plan for spec 001 resumes, the owner sees a traceability map from every requirement and success criterion in spec 001 to a part of the architecture and to a decision. The four items spec 001 deliberately left open are resolved here or assigned: how unreviewed pages reach members, the marker file format, where the local copy lives, and how the wiki skills' commit checks are enabled on each member's machine.

**Why this priority**: This turns the foundation into something the plan can build on directly, instead of leaving it as a separate document.

**Independent Test**: Count the requirements and success criteria in spec 001 and check the map. The test passes when every one has an entry and the four open items each have an accepted decision.

**Acceptance Scenarios**:

1. **Given** the requirements and success criteria of spec 001, **When** the traceability map is complete, **Then** none is missing, and any gap is listed with an owner.
2. **Given** the five core scenarios (setup, join, share, sync, search), **When** each is walked through the architecture on paper, **Then** every step lands on a named part with no unresolved gap.
3. **Given** a requirement the architecture cannot meet, **When** it is found, **Then** it is raised as a change to spec 001 or to the constitution, not hidden.

---

### User Story 6 - Keep decisions maintainable (Priority: P3)

A future contributor finds every decision with its status, its date and the conditions under which it should be revisited. A decision that is replaced links to the one that replaces it.

**Why this priority**: Decisions drift if nobody can tell which ones still hold.

**Independent Test**: Pick a decision and ask a reviewer why it was made and when to revisit it. The test passes when the reviewer finds both answers in the record within two minutes.

**Acceptance Scenarios**:

1. **Given** an accepted decision, **When** a contributor reads it, **Then** it states its status, its date and its review triggers.
2. **Given** a replaced decision, **When** a contributor reads it, **Then** it points to its replacement.

---

### User Story 7 - Start from a working project skeleton (Priority: P2)

After the owner approves the tech stack and the project structure, a contributor clones the project and gets a skeleton that follows both. A single documented command builds it, lints it and runs its tests, and a check fails any change that breaks an allowed dependency direction. One minimal command runs through every layer of the architecture and reports the product version, to prove the parts connect. The skeleton contains no product behavior.

**Why this priority**: The skeleton shows that the decisions work together, and it removes the setup work from every feature that follows.

**Independent Test**: On a clean machine, clone the project and follow the documented steps. The test passes when build, lint and tests succeed, the version command runs through every layer, and a deliberate dependency violation makes the check fail.

**Acceptance Scenarios**:

1. **Given** approved decisions for the tech stack and the project structure, **When** the skeleton is created, **Then** its layout matches the project structure document and it uses only the approved stack.
2. **Given** a clean machine, **When** a contributor follows the documented steps, **Then** build, lint and tests succeed in one command.
3. **Given** a change that adds a forbidden dependency between two parts, **When** the checks run, **Then** they fail and name the dependency.
4. **Given** the finished skeleton, **When** a reviewer looks for product behavior, **Then** none exists beyond the minimal version command.
5. **Given** the decisions are not yet approved, **When** someone tries to create the skeleton, **Then** the work does not start.

---

### Edge Cases

- Two quality goals conflict, such as the smallest design against the strongest safety. The trade-off is written down and the owner decides.
- An experiment contradicts an assumption behind a favored option. The decision is reopened and the option is dropped or the assumption is restated.
- No candidate meets every constraint. The conflicting constraint is named and the owner decides whether to relax it or amend the constitution.
- Spec 001 changes after the architecture is accepted. The traceability map is updated and affected decisions are re-reviewed.
- A candidate technology is attractive but would lock the product to one AI assistant. It is rejected under the constitution's harness-neutral principle unless a neutral fallback exists.
- A decision is needed that this feature cannot test without building the product. It is accepted as a recorded risk with a trigger to test it first during implementation.
- On Windows, two page paths differ only in letter case, or a path uses a reserved system name or is very long. The architecture states how each case is handled and what the member sees.
- The runtime the product needs is missing, or is installed but too old. The installer detects it before doing anything else, says which runtime and version are needed, and tells the assistant the exact step to fix it.
- A session-start hook runs in an environment that does not see the member's usual search path, so it cannot find the tool or its runtime. The architecture states how the tool is located from a hook on each system.
- A newer version of the product exists but the member has not asked to update. The health check reports it and nothing is installed.
- A tool meets a wiki whose marker states a newer format version. It changes nothing in the wiki or the local copy and tells the member to update.
- A download fails its integrity check, for example because it was altered on the way. The installer stops, installs nothing and says why.
- The skeleton shows that an approved decision does not work in practice. The decision is reopened, and the skeleton waits until it is settled again.
- A contributor adds product behavior to the skeleton to save time. The review rejects it, because the skeleton holds no product behavior.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The feature MUST produce a business architecture that lists every role, capability, value flow and business rule of the product, and links each to a story in a feature spec or a principle in the constitution.
- **FR-002**: The feature MUST produce a system architecture that names each part of the product, its responsibility, its interfaces, where its data lives, where trust changes, and how it behaves when it fails. It MUST include a threat model: the assets to protect, the likely threats, and the mechanism that answers each one, including the secret scan and the installer integrity check.
- **FR-003**: The system architecture MUST map each constitution principle to at least one mechanism and one way to verify it.
- **FR-004**: The feature MUST state a measurable target and a verification approach for every quality goal that spec 001 sets, including the 5-second session start, the support for 5,000 pages in each of 5 wikis, repeatable search results, Thai and English search, and offline use. It MUST add targets for reliability, security, portability, maintainability and testability.
- **FR-005**: The feature MUST produce a tech stack decision for each technology concern the product needs, including implementation language and runtime, distribution to members, the search index, test tooling, packaging and automation.
- **FR-006**: Every stack decision MUST record its criteria, the candidates considered, the choice, the rationale and the rejected alternatives. Where only one candidate was possible, it MUST name the constraint that left no other.
- **FR-007**: Stack criteria MUST include the constitution's constraints and the constraints in spec 001: macOS, Linux and Windows, any AI assistant that can run commands and load a skill, one-message installation, offline operation, and a command-line tool that never calls a language model.
- **FR-008**: A stack decision that depends on an unproven assumption MUST be backed by an experiment of at most one working day whose result is recorded, or it MUST stay in draft.
- **FR-009**: The feature MUST produce a project structure document covering the repository layout, module boundaries, allowed dependency directions, test layout, documentation layout, naming rules, and the path of a change from branch to main line.
- **FR-010**: The project structure MUST be consistent with the development workflow in the constitution.
- **FR-011**: The feature MUST produce a traceability map from every functional requirement and success criterion of spec 001 to a part of the architecture and a decision, and MUST list any gap with an owner.
- **FR-012**: The feature MUST resolve, or explicitly assign, the four items spec 001 left open: how unreviewed pages reach members, the format of the marker file, where the local copy lives, and how the wiki skills' commit checks are enabled on each member's machine.
- **FR-013**: The feature MUST walk the five core scenarios of spec 001 (setup, join, share, sync, search) through the architecture and record any gap found.
- **FR-014**: Every decision MUST carry a status, a date, its review triggers and a link to the decision that replaces it, if any.
- **FR-015**: A decision MUST become accepted only after the project owner approves it.
- **FR-016**: When the architecture requires a change to the constitution or to a feature spec, the feature MUST raise it as a proposal and MUST NOT apply it silently.
- **FR-017**: Experiments MUST be throwaway and MUST stay out of the main line. The only code this feature delivers is the project skeleton.
- **FR-018**: All documents the feature produces MUST be written in English.
- **FR-019**: The feature MUST create a project skeleton as its last stage, and MUST start it only after the owner has approved the tech stack and the project structure decisions.
- **FR-020**: The skeleton MUST follow the approved project structure and use only the approved stack.
- **FR-021**: One documented command MUST build the skeleton, lint it and run its tests. Contributors MUST be able to run it on a clean machine by following the documented steps.
- **FR-022**: The skeleton MUST include an automatic check that fails any change that adds a forbidden dependency between parts, and the failure MUST name the dependency.
- **FR-023**: The skeleton MUST include one minimal command that reports the product version and runs through every layer of the architecture. The skeleton MUST contain no other product behavior.
- **FR-024**: The skeleton MUST include the automation needed for changes to reach the main line as the constitution's development workflow describes.
- **FR-025**: The architecture and the tech stack MUST support macOS, Linux and Windows in the first release, including path rules, line endings and the way sessions start on each system.
- **FR-026**: The business architecture MUST show the wiki skills for ingest, query and lint as an optional companion that is neither bundled nor a dependency. The product MUST work fully without them.
- **FR-027**: The architecture MUST contain no component that sends usage, analytics or crash data. The only network traffic in normal use MUST be access to the team's own repository.
- **FR-028**: The marker file MUST state a format version. A tool that meets a wiki with a newer format version than it understands MUST NOT change the wiki or the local copy, and MUST tell the member to update.
- **FR-029**: The installer MUST verify the integrity of what it downloads against information from the publisher, and MUST stop with a message and install nothing if the check fails.
- **FR-030**: The product MUST keep a log on the member's machine only. The log MUST be size-limited, MUST NOT contain page content or secrets, and MUST NOT be sent anywhere. The health check MUST be able to use it.
- **FR-031**: The only things a member must already have are an AI assistant that can run commands and Git. A language runtime MAY be required only if the installer checks for it first, reports what is missing or too old, and tells the assistant the exact step to fix it. The member MUST NOT need to use Git directly.
- **FR-032**: The stack decision MUST weigh distribution that needs no separate runtime as a high-priority criterion, and MUST record the cost of choosing a runtime prerequisite if one is chosen.
- **FR-033**: The product MUST NOT update itself silently. The health check MUST report when a newer version exists, and the assistant MUST update the product only when the member asks, with the same integrity check as the first install.

### Key Entities

- **Business Capability**: Something the product must be able to do, linked to the stories that justify it.
- **Role**: A kind of person who uses or governs the product, with the capabilities that role may use.
- **Business Rule**: A condition that always holds, linked to the constitution principle it comes from.
- **Component**: A part of the system with one responsibility, its interfaces, and the data it owns.
- **Quality Target**: A measurable goal for a quality attribute, with the way to verify it.
- **Architecture Decision**: A recorded choice with its criteria, candidates, rationale, rejected alternatives, status, date and review triggers.
- **Experiment**: A short, throwaway test of an assumption, with its result.
- **Traceability Map**: The table linking each requirement and success criterion of a feature spec to a component and a decision.
- **Project Skeleton**: The empty but working project that follows the approved structure and stack, with its checks and one minimal command.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the functional requirements and success criteria in spec 001 appear in the traceability map, each linked to a component and a decision, and every gap has an owner.
- **SC-002**: 100% of stack decisions record their criteria, at least two candidates (or the constraint that left one), the rationale and the rejected alternatives.
- **SC-003**: 9 of 9 constitution principles map to a mechanism and a verification approach.
- **SC-004**: Every quality target from spec 001 has a verification approach, and the two riskiest have a recorded experiment result before their decisions are accepted.
- **SC-005**: The four open items from spec 001 each have an accepted decision.
- **SC-006**: All five core scenarios walk through the architecture without an unresolved gap.
- **SC-007**: In a review with five people, at least four place at least nine of ten sample files where the project structure document says they belong.
- **SC-008**: Before the plan for spec 001 resumes, every decision is accepted by the project owner, except decisions that wait for experiment E9 or E3, whose experiments must have reported or been waived in writing by the owner. The skeleton is finished before the implementation of spec 001 starts.
- **SC-009**: A reviewer finds the reason for any chosen decision, and the conditions for revisiting it, within two minutes.
- **SC-010**: On a clean machine, a contributor builds, lints and tests the skeleton with one documented command in under 10 minutes, in 100% of tested runs on macOS, Linux and Windows.
- **SC-011**: A deliberately added forbidden dependency makes the checks fail in 100% of tests, and the failure names the dependency.
- **SC-012**: The skeleton contains no product behavior beyond the version command, as confirmed by a review of its command list.
- **SC-013**: The architecture states that normal use connects only to the team's repository host (plus the package registry at install and update), and records a verification approach (a network trace of the five core scenarios) that spec 001 uses as an acceptance test with a 100% pass rate.
- **SC-014**: The architecture records how a wiki with a newer format version is left unchanged by an older tool and how the member is told to update, with a verification approach that spec 001 uses as an acceptance test.
- **SC-015**: The architecture records how an install or update that fails its integrity check is rejected with nothing installed, backed by the experiment result for the chosen distribution route, and a verification approach that spec 001 uses as an acceptance test.
- **SC-016**: The architecture records what the local log may and may not contain and its size limit, with a verification approach (seeded secrets and page text) that spec 001 uses as an acceptance test.
- **SC-017**: The architecture records how a missing prerequisite is detected, reported with the exact fix step, and verified on each supported system, with a verification approach that spec 001 uses as an acceptance test.
- **SC-018**: The architecture records how a newer version is reported by the health check and never installed without the member's request, with a verification approach that spec 001 uses as an acceptance test.

## Assumptions

- This feature designs and decides first, then creates the project skeleton as its last stage. The skeleton starts only after the owner approves the tech stack and the project structure. The plan for spec 001 can resume once the owner has approved the decisions, with the exception for experiments E9 and E3 described in SC-008, and the implementation of spec 001 starts from a finished skeleton.
- The skeleton's code lives on the code side of the repository and reaches the main line through the normal workflow. The documents of this feature stay with the specs.
- The documents this feature produces are specification material and live with the specs, not in the product's code.
- The project owner is the decision authority for architecture decisions, the constitution and the specs.
- The business architecture covers the Knowledge product only, not a wider company view.
- When quality goals conflict, the trade-off is recorded and the owner decides. The confirmed order is safe data first, then simple design, then portability, then speed.
- Experiments are limited to one working day each, aimed at the riskiest assumptions, and discarded after their results are recorded.
- The first release supports macOS, Linux and Windows. Spec 001 is updated to match.
- The existing spec 001 and the constitution are the inputs. Spec 001 stays valid unless a proposal from this feature changes it.
- The feature is independent of any other team tooling. It shares no data and no configuration with other products.
