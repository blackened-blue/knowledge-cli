---

description: "Task list for the architecture foundation"
---

# Tasks: Architecture Foundation

**Input**: Design documents from `specs/000-architecture-foundation/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Only the skeleton stage has tests (the end-to-end test and the dependency-direction check), because spec FR-021 to FR-023 require them. The documents are checked by the independent test of each story.

**Organization**: Tasks are grouped by user story. Documents are written to `specs/000-architecture-foundation/architecture/`. The skeleton is written at the repository root of the product and starts only after the owner approves the stack and the structure (FR-019).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: The user story the task belongs to (US1 to US7)
- **[OWNER]**: A task only the project owner can complete (approval, a machine, an account). The assistant reports it to the owner when it comes up.

## Path Conventions

- Documents: `specs/000-architecture-foundation/architecture/`
- Decisions: `specs/000-architecture-foundation/research.md` (format in `contracts/decision-record.md`)
- Skeleton: repository root (`src/`, `tools/check/`, `tests/e2e/`, `skill/`, `.github/workflows/`), as in plan.md

---

## Phase 1: Setup

**Purpose**: Make the place for the documents and the working rules.

- [ ] T001 Create the folder `specs/000-architecture-foundation/architecture/` with a short `README.md` that lists the five documents and their order, and states the diagram standard of D-039 (diagram types, English labels, a caption under each diagram, at most about 8 boxes per diagram). The subfolder `architecture/diagrams/` already holds the draft `layers.svg` and the temporary `drafts.md` (unchecked diagram drafts; delete it when the real documents are written)
- [ ] T002 [P] Check that every decision D-001 to D-038 in `specs/000-architecture-foundation/research.md` has the fields required by `contracts/decision-record.md` (status, date, review triggers, replaced-by link). List the gaps at the end of `research.md` under "Record gaps"
- [ ] T003 [P] Copy the glossary terms used by the documents (Team Wiki, Marker, Page, Member, Local Copy, Proposal, Queue, Share, Join, Adopt, Unreviewed Page, Main Line, Stale) into a "Terms" section of `architecture/README.md` as links to `.specify/memory/glossary.md`

---

## Phase 2: Foundational (blocks all stories)

**Purpose**: Settle what every document depends on.

**CRITICAL**: No story document may be marked complete until these tasks are done.

- [x] T004 [OWNER] Approve or change the proposals in the "Open decisions for the owner" list of `specs/000-architecture-foundation/research.md` (items 1 to 5) and record the result and date in each decision's status field. Done 2026-10-13: D-001 to D-038 accepted; D-005, D-027 and D-036 accepted pending E9; D-008 and the Windows part of D-014 stay draft until E3; D-003, D-004 and D-006 conditional on re-measurement in Node
- [x] T005 [OWNER] Approve or reject the constitution amendment proposals for Principle IV and Principle VI listed in `research.md`. Apply an approved amendment to `.specify/memory/constitution.md` only after approval (FR-015, FR-016), with a version bump. Done 2026-10-13: both approved and applied as constitution 1.1.0. Follow-up done: Principle V "Pull" changed to "Sync", approved and applied as constitution 1.1.1
- [x] T006 [OWNER] Approve or reject the spec 001 proposals from E6 (merge commits for promotion, health warning) in `research.md`. Apply an approved change to `specs/001-team-knowledge-skill/spec.md` and note it in its Clarifications section. Done 2026-10-13: both approved and applied (FR-002, FR-003, FR-017, new Clarifications entry)
- [ ] T007 Add the terms that the approved decisions introduce to `.specify/memory/glossary.md` (only terms, no implementation detail)
- [ ] T008 Re-measure the 5-second session-start budget (FR-014 of spec 001) for the TypeScript choice: run the E2 sync prototype in Node with start-up included, on the same 5,050-page corpus, and record the result under D-004 in `research.md`

**Checkpoint**: Decisions have owner status. The stack is known.

---

## Phase 3: User Story 1 - Agree on the business architecture (Priority: P1)

**Goal**: One document that lists every role, capability, value flow and business rule, each linked to a story or principle.

**Independent Test**: A reviewer who has not seen the specs can name the roles, the capabilities and the main value flows, and can point to the spec story behind each capability.

- [ ] T009 [US1] Write `architecture/business-architecture.md` section "Roles": Admin, Member and Reviewer as sets of repository rights, with the note that the tool stores no role (D-028), and how each role appears in the five core scenarios
- [ ] T010 [P] [US1] Write the section "Capabilities": create or adopt a wiki, join, share, review (on the host, D-029), sync, search, health and update. Link each to its user story in `specs/001-team-knowledge-skill/spec.md`
- [ ] T011 [P] [US1] Write the section "Value flows": one short flow each for setup, join, share, sync and search, from the member's point of view, with no component names. Add the C4 Context diagram (Mermaid `C4Context`: Member, Admin, Reviewer, the AI assistant, the Git host, the npm registry) with a flowchart fallback in a collapsed block (D-039)
- [ ] T012 [US1] Write the section "Business rules": every rule once (D-030), each with a link to the spec 001 requirement and to the test that proves it. Include the rules for reviewed and unreviewed pages, collision handling, secret scan advice, and no permission layer. Add a state diagram of a page (new, unreviewed, proposed, in the main line, held, queued) with a caption (D-039)
- [ ] T013 [US1] Write the section "Optional companion" showing the wiki skills for ingest, query and lint as neither bundled nor a dependency, and the product working fully without them (FR-026)
- [ ] T014 [US1] Run the independent test of this story with a reviewer and record the outcome at the end of `architecture/business-architecture.md`

**Checkpoint**: The business architecture is reviewable alone.

---

## Phase 4: User Story 2 - Agree on the system architecture (Priority: P1)

**Goal**: Parts, responsibilities, interfaces, data placement, trust boundaries, failure behavior and the threat model.

**Independent Test**: Each constitution principle and each quality target of spec 001 maps to a named part or interaction and to a way to verify it.

- [ ] T015 [US2] Write `architecture/system-architecture.md` section "Parts": the layers and folders in `plan.md` (domain, application with its ports and use cases, infrastructure adapters, infrastructure.cli, skill stub; D-035) with the responsibility and interface of each, and where its data lives. Add the C4 Container diagram (Mermaid `C4Container`: skill stub, knowledge package, local data inside the member's machine, plus the Git host and the npm registry) with a flowchart fallback in a collapsed block (D-039)
- [ ] T016 [US2] Write the section "Processes": no resident process, detached finisher and lock file (D-011), one lock per wiki (D-023), version mismatch behavior (D-026)
- [ ] T017 [P] [US2] Write the section "Data flows" for setup (D-019, D-020), join (D-021, D-022), share (D-015), sync (D-016) and search (D-017), each as numbered steps naming the parts involved and the failure branch of each step. Draw one Mermaid sequence diagram per flow, with the failure branches shown (for example a held path collision, a queued share, a stale wiki, a rebuilt index), not C4Dynamic (D-039)
- [ ] T018 [US2] Write the section "Per-system rules" in `architecture/system-architecture.md`: path rules, line endings, reserved names, and how a session starts on macOS, Linux and Windows (FR-025), with the fallback of D-008
- [ ] T019 [US2] Write the sections "Format version", "Local log" and "Updates" in `architecture/system-architecture.md`: a tool that meets a newer `format_version` changes nothing and tells the member to update (FR-028, D-033); the log is local, size-limited and holds no page content or secrets (FR-030); the product never updates silently and the health check reports a newer version (FR-033, D-026). For each, record the verification approach that spec 001 uses as an acceptance test (SC-014, SC-016, SC-018)
- [ ] T020 [P] [US2] Write the section "Trust boundaries": the member's machine, the host, the wiki content (untrusted, D-013), the assistant, and the release channel (the npm registry, D-036). Draw the trust zones as a Mermaid flowchart with one group per zone and mark where the five threats of D-018 cross a boundary (D-039)
- [ ] T021 [US2] Write the section "Principles to mechanisms": a table of the nine constitution principles, each with at least one mechanism and one way to verify it (FR-003)
- [ ] T022 [US2] Write the section "Quality targets": a measurable target and a verification approach for every quality goal in spec 001 (5-second session start, 5,000 pages, 5 joined wikis, offline use, no telemetry), per FR-004
- [ ] T023 [US2] Write `architecture/threat-model.md`: the five initial threats of D-018, each with the attack, the mitigation, the decision it comes from and the test that proves it. Add threats found while writing T017 and T020
- [ ] T024 [US2] Walk the five core scenarios of spec 001 through `architecture/system-architecture.md` and record each gap found, with its owner, at the end of the document (FR-013)
- [ ] T025 [US2] Confirm that the architecture contains no component that sends usage, analytics or crash data, and that the only network traffic in normal use is the team's repository plus the release channel at install and update (FR-027). Record the check in the document

**Checkpoint**: The system architecture and the threat model are reviewable.

---

## Phase 5: User Story 3 - Choose the tech stack with evidence (Priority: P1)

**Goal**: Each stack decision shows criteria, candidates, choice, rationale and rejected alternatives, backed by experiments where the assumption is unproven.

**Independent Test**: Any three stack decisions show their criteria, at least two candidates (or the constraint that left one) and the reasons.

- [ ] T026 [US3] Re-check each stack decision in `research.md` (D-002 to D-008, D-010, D-027, D-031 to D-038) against the TypeScript choice and the npm package route (D-036). Edit any text that still assumes Go or a standalone executable and record each change in the decision's status line. Fix the minimum Node.js version (the oldest long-term-support release at the time of the first release) in D-037
- [ ] T027 [P] [US3] Re-run E5 (checksum verification, rejection of flipped and shortened files) in Node with the built-in hash functions. Keep the script outside the main line and record the result under D-005
- [ ] T028 [P] [US3] Re-run E1 with composed and decomposed Unicode forms added to the corpus, so the normalisation gap noted in D-002 is closed. Record the result under D-003 and D-006
- [ ] T029 [US3] Run E9: publish a test package with provenance, check it with `npm audit signatures`, and confirm that a tampered package and a missing attestation are rejected with nothing installed (FR-029). Also compare with a signature check inside the installer (library or `cosign`) on size, start time, prerequisite and offline behavior. Record the result under D-027 and D-036 (one working day at most, FR-008)
- [ ] T030 [OWNER] [US3] Provide the npm registry account (or the private registry) and the publishing permission needed for E9 and for releases (D-036), and confirm the package name
- [ ] T031 [US3] Write the install prerequisites into `architecture/tech-stack.md`: the install message runs `git --version` and `node --version` first, reports each missing or too-old item with the exact fix step, and installs nothing until fixed (D-037, FR-031, SC-017)
- [ ] T032 [OWNER] Run E3 on a Windows machine: do the session-start steps of Claude Code, KiroCrew and Qoder run? Record the result under D-008 and D-014. D-008 stays a draft until this is done
- [x] T033 Copy the throwaway experiment scripts from the scratch folder into `specs/000-architecture-foundation/experiments/` on the `speckit` branch only, never into the product's main line (FR-017), with a README that says they are throwaway and are not part of the product, so the owner can run them after cloning. Done: scripts, `README.md`, and the E3 probe and checklist are in `experiments/` (Thai and Chinese test text is stored as escape sequences so every file is English-only)
- [ ] T034 [OWNER] Run E2, E4 and E7 on Linux and on Windows using the experiment scripts (the scripts are copied into the repository's experiments folder in T033). Record the results under D-004, D-002 and D-006
- [ ] T035 [US3] Write `architecture/tech-stack.md`: one table of every technology concern (language and runtime, distribution, search, Git access, secret scan, signing, tests, packaging) with the decision, its status and a link to its record in `research.md`

**Checkpoint**: Every stack decision is accepted, or has a named open item.

---

## Phase 6: User Story 4 - Define the project structure (Priority: P2)

**Goal**: A document that tells a contributor where any new file goes.

**Independent Test**: Five reviewers place ten new files; at least four place at least nine correctly.

- [ ] T036 [US4] Write `architecture/project-structure.md` section "Layout": the folders from `plan.md` with a one-line purpose each, including the four layers under `src/` (`domain/`, `application/`, `infrastructure/`, `infrastructure.cli/`), `skill/`, `tools/check/`, `tests/e2e/`, `docs/`, `.github/workflows/`. Add the C4 Component diagram of the four layers (Mermaid `C4Component`, with layer colors set by `UpdateElementStyle`) and a flowchart fallback in a collapsed block, and include `architecture/diagrams/layers.svg` (concentric circles) once as the explanatory figure (D-039)
- [ ] T037 [US4] Write the sections "Module boundaries" and "Allowed dependency directions": the inward-only rules of D-035 from `plan.md` (domain imports nothing outside domain; application imports domain; infrastructure imports application and domain; infrastructure.cli imports all and alone registers adapters in the DI container; no decorators in domain or application), the domain rules of D-038 (`domain/policy` and `domain/factory`; every domain object with a validity rule is a class or branded type defined in `factory`, with a constructor not exported outside it, and built only by its factory function; use cases never call such a constructor; types marked `simple-value` are exempt and a reviewer confirms the mark; `policy` imports only types from `factory`), the rule that `src/application/usecase/` holds files only (the check tool enforces it), and the failure message format of the check tool (names the forbidden edge, FR-022)
- [ ] T038 [P] [US4] Write the sections "Test layout", "Documentation layout" and "Naming rules" (files, folders, commands)
- [ ] T039 [P] [US4] Write the section "Development workflow": how a change reaches the main line, consistent with the constitution's Development Workflow (FR-010)
- [ ] T040 [US4] Write the section "Where does a new file go": ten worked examples (a new command, a new secret rule, a new platform path rule, a new e2e test, a new decision, and so on)
- [ ] T041 [US4] Run the independent test with five reviewers and record the result at the end of the document

**Checkpoint**: The structure is reviewable. The owner's approval of it is the gate for Phase 9 (FR-019).

---

## Phase 7: User Story 5 - Verify the architecture against spec 001 (Priority: P2)

**Goal**: Every requirement and success criterion of spec 001 has a part and a decision. The four open items are resolved.

**Independent Test**: Count the requirements and success criteria of spec 001 and check the map; the four open items each have an accepted decision.

- [ ] T042 [US5] Create `architecture/traceability-map.md` in the format of `contracts/traceability-map.md` with one row for each of FR-001 to FR-030 and SC-001 to SC-011 of spec 001, plus the columns part, decision and verification
- [ ] T043 [US5] List every gap in a "Gaps" section with a proposed owner and a proposed fix. Raise any change to spec 001 or the constitution as a proposal, never apply it silently (FR-016)
- [ ] T044 [US5] Record the four open items of spec 001 (unreviewed pages D-009, marker file D-010, local copy location D-010, commit checks D-010) in a "Resolved items" section, each with its status
- [ ] T045 [US5] Add a section "Keeping the map complete" to `architecture/traceability-map.md` that describes how the number of rows is compared with the number of requirements and success criteria in spec 001, so the map cannot silently fall behind

**Checkpoint**: The map is complete, or lists its gaps.

---

## Phase 8: User Story 6 - Keep decisions maintainable (Priority: P3)

**Goal**: A reader finds why a decision was made and when to revisit it within two minutes.

**Independent Test**: A reviewer finds both answers in the record within two minutes.

- [ ] T046 [US6] Add a "Decision index" at the top of `research.md`: id, title, status, date, next review trigger, one line each
- [ ] T047 [US6] Fill in the gaps listed by T002, and set status values (proposed, accepted, draft, superseded) following `contracts/decision-record.md`
- [ ] T048 [US6] Run the independent test with a reviewer and record the outcome in `architecture/README.md`

**Checkpoint**: Decisions are indexed and dated.

---

## Phase 9: User Story 7 - Start from a working project skeleton (Priority: P2)

**Goal**: A working project with the approved layout and no product behavior, plus one version command that runs through every layer.

**Independent Test**: On a clean machine, clone the project and follow the documented steps. Build, lint and tests pass, the version command runs through every layer, and a deliberate dependency violation makes the check fail.

**Gate**: Do not start before T048 and the owner approval of the tech stack and the project structure (T004, T041, FR-019). This gate is T049.

- [ ] T049 [OWNER] [US7] Record the owner's approval of the tech stack (`architecture/tech-stack.md`) and the project structure (`architecture/project-structure.md`) with the date, at the top of `architecture/project-structure.md`
- [ ] T050 [US7] Create the package files at the repository root: `package.json` (name, `bin` entry, the scripts `build`, `check`, `test`), `tsconfig.json` and `tsup.config.ts`, with the dependencies approved in D-002, D-027, D-031, D-032 and D-035 (including `tsyringe` and `reflect-metadata`) and a committed lock file
- [ ] T051 [P] [US7] Create the empty layer folders with one placeholder module each, following `architecture/project-structure.md`: `src/domain/{policy,factory}/`, `src/application/ports/` and `src/application/usecase/` (use case files only, no subfolders), `src/infrastructure/{git,platform,index,release,log}/`, `src/infrastructure.cli/commands/`
- [ ] T052 [US7] Implement the version command according to `contracts/skeleton-commands.md`: `src/infrastructure.cli/index.ts` parses the argument, `src/infrastructure.cli/container.ts` registers one placeholder adapter with `tsyringe` through a factory function and an explicit token, a version use case file in `src/application/usecase/` reads the version through a port and builds a version object through a factory in `src/domain/factory/` (never directly), and a placeholder rule in `src/domain/policy/` checks it, so the command runs through all four layers. `knowledge --version` prints `knowledge 0.0.0` and exits 0; any other argument exits 2. Prove that the `tsup` bundle runs with `tsyringe` on all three systems (D-035 review trigger)
- [ ] T053 [US7] Add the placeholder `skill/SKILL.md` and a placeholder workflow text file under `skill/` that the build embeds in the bundle (D-034). The skeleton has no `skill` command and the stub calls nothing: the `skill` command is built in spec 001 after the Principle VI amendment is approved (FR-023, SC-012)
- [ ] T054 [US7] Write the dependency-direction check in `tools/check/` that reads the layer rules of `architecture/project-structure.md` and fails any forbidden import between layers (including a decorator or `tsyringe` import inside `domain` or `application`), and fails any construction of a domain object with a validity rule outside `src/domain/factory/` (types marked `simple-value` are allowed) and any value import from `factory` inside `policy` (type-only imports are allowed, D-038), naming the edge (FR-022)
- [ ] T055 [P] [US7] Add a unit test of the dependency-direction check in `tools/check/` that uses deliberate violations (a forbidden layer import, a domain object with a validity rule built directly in a use case, and a `simple-value` type built in a use case that must pass, a value import from `factory` inside `policy`) and expects a failure naming the edge each time
- [ ] T056 [US7] Write the end-to-end harness in `tests/e2e/` that builds the bundle, runs `knowledge --version` and checks the output, exit code 0 and the exit code 2 for another argument
- [ ] T057 [US7] Create the one documented command (`npm run check`) that type-checks, runs the formatter check, runs the unit tests and the dependency-direction check, and builds the bundle (FR-021)
- [ ] T058 [US7] Create `.github/workflows/ci.yml` that runs `npm ci`, a dependency audit and `npm run check` on macOS, Linux and Windows (D-025, FR-024), and the end-to-end test. Add a pull request template that asks which constitution principles the change touches and for the end-to-end record of Principle IX
- [ ] T059 [US7] Write the contributor steps for a clean machine in `docs/getting-started.md` (prerequisites: Git and Node.js; clone; install; run the one command)
- [ ] T060 [OWNER] [US7] On a clean macOS, a clean Linux and a clean Windows machine (SC-010), follow `docs/getting-started.md` and report whether build, check and tests pass. Record the result in `quickstart.md` under "Known gaps"

**Checkpoint**: The skeleton passes `quickstart.md`.

---

## Phase 10: Polish and cross-cutting

- [ ] T061 [P] Re-read all documents in `architecture/` for English-only text and consistent terms (FR-018, glossary)
- [ ] T062 [P] Run every scenario in `quickstart.md` and update the "Known gaps" section with the real state
- [ ] T063 Re-run the Constitution Check of `plan.md` after the design is final and record the result; update "Experiments Still Needed" to match the real state
- [ ] T064 [OWNER] Review the full set of documents and mark the feature complete, or list what remains

---

## Dependencies and Order

- **Gate to resume the plan for spec 001**: the owner tasks for E9 (the registry account and the E9 result) and E3 (the Windows run) must have reported, or the owner must waive them in writing (spec 000 Clarifications). D-005, D-027, D-036 and D-008 do not block the plan after that.

- **Constitution gate**: T005 (the Principle IV and Principle VI amendments, including `pull` to `sync` and the `skill` command) is closed: approved and applied as constitution 1.1.0 on 2026-10-13. The wording of Principle V ("Pull" to "Sync") was approved afterwards and applied as constitution 1.1.1.

- Phase 1 first. Phase 2 blocks every story: T004 to T006 need the owner; T008 needs the Node prototype.
- US1, US2 and US3 (all P1) can run in parallel after Phase 2. US2's T023 uses T020. US3's T035 waits for T026 to T029.
- US4 (P2) starts after US2's T015 and T016, because the structure follows the parts.
- US5 (P2) starts after US2 and US4.
- US6 (P3) runs after US3 and can run alongside US5.
- US7 (P2) is last and starts only at T049.
- T032 and T034 need the owner's Windows and Linux machines and do not block the documents. They block only the final status of D-008 and the cross-platform claims.

## Parallel Examples

- After Phase 2: T009 (US1), T015 (US2) and T026 (US3) in parallel.
- Within US2: T017 and T020 in parallel.
- Within US3: T027, T028 and T033 in parallel.
- Within US7: T051 and T055 in parallel after T050.

## Implementation Strategy

1. Finish Phase 1 and Phase 2 (owner decisions come first).
2. Deliver US1 to US3 (all P1) as the minimum useful foundation: the business architecture, the system architecture with the threat model, and the evidence-backed stack.
3. Add US4 and US5 so the structure and the map are reviewable.
4. Finish US6, then pass the gate in T049 and build the skeleton in US7.
5. Owner tasks (T004 to T006, T032, T034, T049, T060, T064) are reported to the owner when they come up.

## Notes

- Experiments are throwaway and stay out of the main line (FR-017). The only product code delivered is the skeleton.
- Every document is in English (FR-018).
