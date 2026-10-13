# Implementation Plan: Architecture Foundation

**Branch**: `000-architecture-foundation` | **Date**: 2026-10-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/000-architecture-foundation/spec.md`

## Summary

This feature designs and decides before any product feature is built. It produces a business architecture, a system architecture with a threat model, tech stack decisions backed by experiments, a project structure, and a traceability map from every requirement and success criterion of spec 001. Its last stage creates a thin project skeleton that holds no product behavior.

Phase 0 research ran eight experiments (see [research.md](research.md)). The owner chose TypeScript on Node.js (D-002). The design uses search by character bigrams with an adjacency check, incremental and parallel sync, and a checksum plus signature for downloads. One experiment could not run (session-start hooks on Windows), so one decision stays in draft. The unreviewed-page mechanism works only when promotion uses merge commits, which raises a proposed change to spec 001. The project owner approved decisions D-001 to D-038 on 2026-10-13, with three kept pending experiment E9 (D-005, D-027, D-036), one kept as a draft until E3 (D-008, and the Windows part of D-014), and three conditional on re-measurement in Node (D-003, D-004, D-006).

## Technical Context

**Language/Version**: TypeScript on Node.js (current long-term-support release; the experiments ran Node 26.7). Owner choice in D-002.

**Primary Dependencies**: The Node standard library (including built-in Unicode normalisation); the installed Git program for repository work; `commander` for argument parsing, `tsyringe` with the `reflect-metadata` polyfill for dependency injection (D-035), `tsup` for bundling and `vitest` for tests (the same tools as the reference project, to be confirmed); a Sigstore verification library if E9 selects it (D-027). The bundle ships its dependencies.

**Storage**: Files only. The team's Git repository is the source of truth. Each member's machine holds a working copy, a search index and a queue of pending shares, all rebuildable or retryable (Constitution, Principle II).

**Testing**: `vitest` for unit tests; an end-to-end test harness that drives the built package command against local bare repositories; a dependency-direction check; a fixed-rule secret-scan test set. Test tooling is part of the stack decision and is recorded in research.

**Target Platform**: macOS, Linux and Windows, on x86-64 and ARM64 (FR-025). Only macOS was exercised in the experiments.

**Project Type**: Command-line tool plus a thin assistant skill that calls it.

**Performance Goals**: Session start adds at most 5 seconds across all joined wikis (FR-014). Search on a 5,000-page wiki answers in about a millisecond in the naive prototypes (D-004).

**Constraints**: Works offline from the last sync. No language model in the tool. No telemetry. Only access to the team's repository on the network. Installation by one message. A member needs an AI assistant, Git and Node.js (the prerequisite accepted in spec 000; the install message states it).

**Scale/Scope**: Up to 5,000 pages per wiki and 5 joined wikis per machine (FR-028 of spec 001).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Status | Note |
|---|---|---|
| I. Spec Before Code | Pass | This plan derives from spec 000. The skeleton starts only after approval (FR-019) |
| II. Git Is the Only Store | Pass | No server, database or vector store. The index is a rebuildable cache |
| III. Agent-First, Git-Invisible, Harness-Neutral | Pass with a draft | Hook behavior on Windows is unproven (D-008, E3). A fallback of syncing at the first step of a session keeps it neutral |
| IV. Reviewed Publishing | Pass (amended in constitution 1.1.0) | The old wording ("unique file name", "a change to an existing page MUST go through a pull request") conflicted with spec 001. The owner approved new wording on 2026-10-13 |
| V. Safe and Fast Pull | Pass with evidence | Parallel fetch and incremental indexing fit the 5-second budget on macOS with local remotes (D-004) |
| VI. Deterministic Search, Minimal CLI | Pass (amended in constitution 1.1.0) | Bigrams are deterministic (D-003). The owner approved `pull` renamed to `sync` and the added `skill` command on 2026-10-13. The `skill` command is built in spec 001, not in the skeleton |
| VII. Provenance Required | Pass | Enforced by the assistant as advice, as clarified. No tool rule |
| VIII. Simple Design | Pass with justified exceptions | Owner-chosen layering and DI framework (D-035), factories for objects with a validity rule (D-038), and the Node prerequisite (D-002). See Complexity Tracking |
| IX. Tested Behavior | Pass | The skeleton includes the test harness and the end-to-end record |

**Gate result**: No unjustified violation. Two amendments (Principles IV and VI) were raised under FR-016, approved by the owner on 2026-10-13, and applied as constitution 1.1.0. Principle V's wording ("Pull" to "Sync") was approved afterwards and applied as constitution 1.1.1.

**Post-design re-check**: Unchanged. The contracts and data model add no new command, store or dependency.

## Project Structure

### Documentation (this feature)

```text
specs/000-architecture-foundation/
├── plan.md              # This file
├── research.md          # Phase 0: decisions D-001 to D-010 and experiments E1 to E8
├── data-model.md        # Phase 1: entities of this feature
├── quickstart.md        # Phase 1: how to check the foundation is complete
├── contracts/           # Phase 1: formats of the documents and the skeleton's commands
│   ├── decision-record.md
│   ├── traceability-map.md
│   └── skeleton-commands.md
├── architecture/        # Deliverables written by the implementation of this feature
│   ├── business-architecture.md
│   ├── system-architecture.md
│   ├── threat-model.md
│   ├── project-structure.md
│   └── traceability-map.md
└── tasks.md             # Phase 2 (/speckit-tasks, not created here)
```

### Source Code (repository root)

The structure is proposed. It becomes final when the owner approves the project structure document. It assumes TypeScript (D-002).

```text
src/
├── domain/              # Rules with no IO. Imports nothing outside domain
│   ├── policy/          # Decision rules: path normalisation, format version, bigram tokeniser and ranking, secret-scan rules, collision rules, proposal rules
│   └── factory/         # Domain objects with a validity rule (Marker, Page, Proposal, search query, scan finding, ...) are defined here and built only here, from untrusted input, through their factory. Simple value objects (marked `simple-value`) need no factory
├── application/         # Use cases and ports. Imports domain only
│   ├── ports/           # Interfaces and their tokens: Git, files, index store, clock, release channel, log
│   └── usecase/         # One file per use case (setup, join, share, sync, search, health, install). No subfolders
├── infrastructure/      # Driven adapters that implement the ports. Imports application and domain
│   ├── git/             # Adapter around the installed Git program
│   ├── platform/        # Per-system paths, hooks, line endings, reserved names
│   ├── index/           # Search index files on disk
│   ├── release/         # Version check and update through the package manager
│   └── log/             # Local, size-limited log
└── infrastructure.cli/  # Driving adapter and composition root. May import every other layer
    ├── commands/        # Argument parsing and output for each command
    └── container.ts     # The only place that registers adapters in the DI container
skill/                   # Thin stub that loads the workflow text served by the tool
tools/
└── check/               # One command: build, lint, test, dependency-direction check
tests/
└── e2e/                 # Drives the built command against local bare repositories
docs/                    # Product documentation
.github/workflows/       # Automation for changes reaching the main line
```

**Dependency direction** (Clean Architecture, owner choice D-035): dependencies point inward only. `domain` imports nothing outside `domain`, and no Node module that does IO. `application` imports `domain` only. `infrastructure` imports `application` and `domain`. `infrastructure.cli` may import every layer and is the only place that imports `infrastructure` and the DI framework. No inner layer imports an outer layer. Inside `domain`, `factory` may import `policy` (a factory validates input with policy rules), and `policy` may import only the types of `factory` (type-only imports, no values). Use cases create every domain object that has a validity rule through a factory and never call its constructor; those constructors are not exported outside `domain/factory`, and `tools/check` fails any construction outside it. Types marked `simple-value` are exempt (D-038). Use cases receive ports through their constructors, and the container registers adapters with factory functions, so no decorator or framework import appears in `domain` or `application`. Unit tests of use cases use in-memory fakes; end-to-end tests use the real Git program. The check tool fails the build on any other edge and names it (FR-022).

**Structure Decision**: One TypeScript package with a single bundled entry point. A single package keeps the dependency check simple and avoids a multi-project layout (Principle VIII).

## System Architecture Decisions

| Topic | Decision | Record (status in research.md) |
|---|---|---|
| Process model | No resident process. Detached finisher with a lock file | D-011 |
| Workflow text | Served by the `skill` command (built in spec 001, not in the skeleton), matched to the package version | D-012 |
| Wiki content trust | Never execute wiki code. Pages and search results are untrusted data | D-013 |
| Assistants | Claude Code, KiroCrew, Qoder first-class. Others use the fallback | D-014 |
| Share flow | Secret scan, collision check, push, queue on failure | D-015 |
| Sync failure | A failing or slow wiki uses its old copy and is marked stale | D-016 |
| Index damage | Rebuild automatically from the working copy | D-017 |
| Threat list | Five initial threats, each with a mitigation and a test | D-018 |
| Empty repository | Setup creates the first commit and the unreviewed-pages branch | D-019 |
| No write access | Setup checks first, stops, and says what to ask the admin for | D-020 |
| Join name clash | Join stops and asks the member | D-021 |
| Join without marker | Join refuses and points to setup or adopt | D-022 |
| Concurrent commands | One lock per wiki. A second command skips a locked wiki and says so | D-023 |
| Uninstall | Documentation only. Local copies are never deleted automatically | D-024 |
| CI | Build, check and end-to-end test on macOS, Linux and Windows from the start. Real-machine runs by the owner for the rest | D-025 |
| Version mismatch | The stub stops and tells the member how to update | D-026 |
| Distribution | npm package with provenance (owner choice) | D-036 |
| Prerequisites | The install message checks Git and Node.js first | D-037 |
| Release signing | Sigstore keyless through npm provenance (owner choice). Verification confirmed by E9 | D-027 |
| Roles | Admin, Member, Reviewer, from repository rights. No role stored | D-028 |
| Review | On the host. The tool creates Proposals and reports status | D-029 |
| Business rules | Written once, linked to requirement and test | D-030 |
| Dependencies | Lock file committed, `npm ci` in CI, dependency audit, bundle includes dependencies | D-031 |
| Code checks | Type check, formatter check, `vitest`, dependency-direction check. No extra linter | D-032 |
| Versions | Semantic version for the package. Separate `format_version` in the marker | D-033 |
| Workflow text | Embedded in the package at build time | D-034 |
| Project structure | Clean Architecture: domain, application, infrastructure, infrastructure.cli. `tsyringe` in the composition root only | D-035 |
| Domain objects | `domain/policy` and `domain/factory`. Use cases build every object that has a validity rule through a factory (simple values exempt). `tools/check` enforces it | D-038 |

## Skeleton Stage

The skeleton is the last stage and starts only after the owner approves the stack and the structure (FR-019). It contains the layout above with empty packages, the check tool, the end-to-end harness with one test, the automation, and one command: `knowledge --version`. It holds no product behavior (FR-023). The contract is in `contracts/skeleton-commands.md`.

## Experiments Still Needed

| ID | Why it is still needed | Needs |
|---|---|---|
| E3 | Hook behavior on Windows is unproven | A Windows machine and two assistants |
| Windows and Linux runs of E2, E4, E7 | All timings and behavior are from macOS | Windows and Linux machines |
| E1 rerun | The search corpus had no composed and decomposed Unicode forms (D-003, D-006) | The experiment scripts, Node |
| E5 rerun | The checksum check was built in Go (D-005) | Node, the package manager's own integrity check |
| 5-second budget rerun | Session start must be re-measured with Node start-up included (D-004) | The E2 prototype in Node |
| E9: npm provenance and integrity (D-036, D-027) | Whether the registry's checks plus provenance meet FR-029 is untested | A test package, a registry account, a one-day test |
| macOS notarisation and Windows signing | First-run experience is unknown | Developer accounts, certificates |

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| A factory for every domain object that has a validity rule, with entities kept in `domain/factory` (D-038) | Owner choice. One place turns untrusted input into valid objects, which serves the threat model (D-013, D-018) and the format version rule (FR-028). Simple value objects are exempt, so every factory answers a current requirement (Principle VIII) | Building objects directly in use cases is simpler (Principle VIII) but spreads input validation across use cases |
| Clean Architecture with four layers and a DI framework (`tsyringe` plus `reflect-metadata`) | Owner choice (D-035). Keeps rules free of Git and file access, makes use cases testable with fakes, and makes the "never run wiki code" rule (D-013) a property of one layer | A flat folder-per-feature layout is simpler (Principle VIII) but lets rules import Git and file code directly |
| Node.js as a runtime prerequisite for every member | Owner choice (D-002), following the reference project; accepted in spec 000 | A standalone static executable (the Go option) needs no runtime but was not chosen |
| Amendments to Principles IV and VI (approved, constitution 1.1.0) | The clarified specs conflicted with the wording of IV, and D-012 adds a command beyond the list in VI | Leaving the conflict would make reviewers apply two different rules |
