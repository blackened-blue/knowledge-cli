# Implementation Plan: Architecture and Technology Stack

**Branch**: none created (work is on `develop`) | **Date**: 2026-10-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/000-architecture-and-tech-stack/spec.md`

## Summary

Spec 000 produces the architecture record and the technology stack decisions that
constitution Principle III requires before any user-facing feature. This plan contains the
architecture (parts, dependency direction, project structure). The stack decisions with their
evidence and rejected alternatives are in [research.md](./research.md). The capability-to-part
map that tests the architecture against the first planned feature is in
[data-model.md](./data-model.md).

All decisions D-001 to D-010 were approved by the owner on 2026-10-24 (SC-005). Open items
O-1 (lowest Node version) and O-3 (HTTP knowledge repo format) remain; see research.md.

## Technical Context

**Language/Version**: TypeScript on Node.js; minimum Node 26.7.0 (only version verified, D-001)

**Primary Dependencies**: none beyond Node built-ins (HTTP client, test runner, child
processes); the user's own `git` and macOS `/usr/bin/security` are called as programs

**Storage**: files in one tool-owned directory per team plus one state file (D-006)

**Testing**: `node --test`; unit, adapter, and CLI tests (D-009)

**Target Platform**: macOS only (spec clarification)

**Project Type**: CLI

**Performance Goals**: a typical read command finishes in 1 second or less (SC-006)

**Constraints**: offline reads after first sync (FR-015); no secret in file, log, or output
(FR-014); installed through npm with Node already present (FR-013)

**Scale/Scope**: up to 100 members and 5,000 files per team (spec clarification)

## Constitution Check

*GATE: passes before research; re-checked after design.*

| Principle | Result | How this plan satisfies it |
|-----------|--------|----------------------------|
| I. Test-First | Pass | D-009 defines three test kinds, each covering named layers; tasks put the failing test first |
| II. Domain Independence | Pass | `domain` and `application` import nothing from `infrastructure` or `infrastructure.cli`; the outside world is reached only through four ports (below) |
| III. Architecture Before Features | Pass | This plan is the architecture; the owner approved D-001 to D-009 and then chose the four-layer form (D-010) |
| IV. Simplicity | Pass with a recorded exception | four layers, four ports, zero third-party runtime dependencies; the extra layer is the owner's choice, recorded in Complexity Tracking |
| V. CLI Text I/O | Pass | [contracts/cli-conventions.md](./contracts/cli-conventions.md) fixes stdout, stderr, exit codes, and the JSON form |
| VI. Versioning | Pass | the same contract file marks output shape and command names as breaking-change surface |
| VII. Observability | Pass | D-007 defines the error form and the `--verbose` log line |

One exception is recorded in Complexity Tracking (the fourth layer).

**Re-check after design**: unchanged. The design added no layer, port, or dependency beyond
those counted above.

**Term**: the constitution and the spec say "Domain". The independence rule (Principle II)
applies to the two innermost layers together, `domain` and `application`.

## Architecture

The architecture is Clean Architecture in four layers (D-010), with the folder names chosen by
the owner. Dependencies point inward only.

### Layers and allowed dependencies

```text
infrastructure.cli ──► infrastructure ──► application ──► domain
```

| Layer | Responsibility | May depend on |
|-------|----------------|---------------|
| `domain` | Team, member, role, scope, and the rules that hold in every use case | nothing |
| `application` | One function per capability (join a team, switch team, uninstall, and so on) and the four port definitions | `domain` |
| `infrastructure` | Gateways that implement the ports (git, HTTP, Keychain, local files, stderr log) and the raw tools they use (process runner, file system, HTTP client) | `application`, `domain` |
| `infrastructure.cli` | Controllers that turn arguments into a use-case call, presenters that turn a result into text or JSON, and the entry point that wires everything | `infrastructure`, `application`, `domain` |

`domain` and `application` must not import from `infrastructure` or `infrastructure.cli`, and
`domain` must not import from `application` (Principle II, SC-004). A test reads the import
lines of every file under `src/domain/` and `src/application/` and fails on any import that
points outward.

### Ports (defined in `application`)

| Port | Purpose | Implementations (in `infrastructure`) |
|------|---------|----------------------------------------|
| `KnowledgeSource` | Read a team's knowledge repo; write to it when the source allows | git gateway (read and write), HTTP gateway (read only) |
| `SecretStore` | Save, read, and delete an API key | Keychain gateway |
| `LocalStore` | Team copies, active team, ownership manifest | local-files gateway |
| `Log` | Verbose diagnostics to stderr | stderr gateway |

A use case returns a plain result value. It does not call a presenter port; the controller
passes the result to the presenter. This keeps the number of ports at four.

### Project structure

```text
src/
├── application/
├── domain/
├── infrastructure/
└── infrastructure.cli/

tests/
├── application/          # use cases with fake ports
├── domain/               # rules, no ports needed
├── infrastructure/       # each gateway against a real local resource
└── infrastructure.cli/   # command run as a child process
```

`tests/` mirrors `src/`: each source folder has a test folder of the same name, and a test for
a file in `src/<layer>/` lives in `tests/<layer>/`. The kind of test follows the layer (D-009):
fakes for `domain` and `application`, real local resources for `infrastructure`, a child
process for `infrastructure.cli`.

**Structure Decision**: single project with four source folders that match the four layers.
No monorepo and no separate packages. Files inside a folder are named after what they do; this
plan does not fix file names.

### How the stack choices map to requirements

| Requirement | Where it is met |
|-------------|-----------------|
| FR-006 macOS only | D-001, D-003 |
| FR-008 git or HTTP repo | `KnowledgeSource` port, D-004, D-005 |
| FR-009 project or user scope, single-repo mode | scope rules in `domain`, [data-model.md](./data-model.md) |
| FR-011 output forms and failures | [contracts/cli-conventions.md](./contracts/cli-conventions.md), D-007 |
| FR-013 install as a command | D-001, D-002 |
| FR-014 key in Keychain | `SecretStore` port, D-003 |
| FR-015 offline reads | `LocalStore` port, D-006 |
| FR-016 several teams, one active | state file in D-006, `Team` in data-model.md |
| FR-017 and FR-018 git behaviour | D-004 |
| FR-019 complete uninstall | ownership manifest in D-006 |

## Documentation (this feature)

```text
specs/000-architecture-and-tech-stack/
├── spec.md
├── plan.md              # this file
├── research.md          # decision records D-001 to D-010 and open items
├── data-model.md        # layers, ports, capability map
├── quickstart.md        # how to check this spec is met
├── contracts/
│   └── cli-conventions.md
└── checklists/requirements.md
```

`tasks.md` is created later by `$speckit-tasks`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principle IV: four layers (`domain`, `application`, `infrastructure`, `infrastructure.cli`), where the earlier proposal had three parts | Owner decision of 2026-10-24 to use Clean Architecture in four layers (D-010). The owner's reasons: use cases kept separate from business rules; the project is expected to grow; the team already uses this standard form; outside tools should be easy to replace (see D-010) | The three-part form (`domain`, `adapters`, `cli`, with use cases inside `domain`) was the assistant's recommendation. The owner chose the four-layer form instead, so it was not adopted |
