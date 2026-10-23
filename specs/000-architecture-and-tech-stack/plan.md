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

All decisions D-001 to D-009 were approved by the owner on 2026-10-24 (SC-005). Open items
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
| I. Test-First | Pass | D-009 defines three test kinds, one per part; tasks put the failing test first |
| II. Domain Independence | Pass | `domain` imports nothing outside itself; the outside world is reached only through four ports (below) |
| III. Architecture Before Features | Pass, pending owner approval | This plan is the architecture; SC-005 blocks spec 001 until it is approved |
| IV. Simplicity | Pass | three parts, four ports, zero third-party runtime dependencies (D-001 to D-005) |
| V. CLI Text I/O | Pass | [contracts/cli-conventions.md](./contracts/cli-conventions.md) fixes stdout, stderr, exit codes, and the JSON form |
| VI. Versioning | Pass | the same contract file marks output shape and command names as breaking-change surface |
| VII. Observability | Pass | D-007 defines the error form and the `--verbose` log line |

No violation, so Complexity Tracking is empty.

**Re-check after design**: unchanged. The design added no part, port, or dependency beyond
those counted above.

## Architecture

### Parts and allowed dependencies

```text
cli ──────► adapters ──────► domain
 │                             ▲
 └─────────────────────────────┘
```

| Part | Responsibility | May depend on |
|------|----------------|---------------|
| `domain` | Team rules, roles, scope rules, use cases, and the four port definitions | nothing |
| `adapters` | One implementation per port: git, HTTP, Keychain, local files, stderr log | `domain` |
| `cli` | Parse arguments, call a use case, print output, set exit code, wire adapters to ports | `domain`, `adapters` |

`domain` must not import from `adapters` or `cli` (Principle II, SC-004). This is checked by a
test that reads the import lines of every file under `src/domain/` and fails on any import that
leaves the folder or is not a Node built-in type-only import.

### Ports (defined in `domain`)

| Port | Purpose | Implementations |
|------|---------|-----------------|
| `KnowledgeSource` | Read a team's knowledge repo; write to it when the source allows | git adapter (read and write), HTTP adapter (read only) |
| `SecretStore` | Save, read, and delete an API key | Keychain adapter |
| `LocalStore` | Team copies, active team, ownership manifest | file adapter |
| `Log` | Verbose diagnostics to stderr | stderr adapter |

### Project structure

```text
src/
├── domain/        # rules, use cases, port types (no outside imports)
├── adapters/      # git, http, keychain, files, log
└── cli/           # commands, output, wiring, entry point

tests/
├── unit/          # domain with fake ports
├── adapters/      # each adapter against a real local resource
└── cli/           # command run as a child process
```

**Structure Decision**: single project with three source folders that match the three parts.
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
├── research.md          # decision records D-001 to D-009 and open items
├── data-model.md        # parts, ports, capability map
├── quickstart.md        # how to check this spec is met
├── contracts/
│   └── cli-conventions.md
└── checklists/requirements.md
```

`tasks.md` is created later by `$speckit-tasks`.

## Complexity Tracking

No constitution violations. Nothing to justify.
