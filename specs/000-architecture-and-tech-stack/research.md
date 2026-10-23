# Research and Decision Records: Architecture and Technology Stack

**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-23

Every record below has a status. `Proposed` means the assistant recommends it and the owner has
not approved it yet (SC-005, FR-012). Nothing here is `Approved` until the owner says so.

## How facts are labelled

- **Verified locally**: checked by running a command on the maintainer machine (macOS, Apple
  silicon) on 2026-10-23.
- **Unverified**: stated from general knowledge and not checked here. It is listed in the open
  items at the end.

Toolchain found on the maintainer machine (verified locally): Node v26.7.0 with npm 11.19.0,
Python 3.14.7, Go 1.26.5, Swift 6.3.3, git 2.53.0 at `/usr/bin/git`. Rust (`cargo`) is not
installed.

## D-001: Implementation language and runtime

- **Status**: Approved by the owner on 2026-10-24 (chose TypeScript on Node.js through npm over
  Python and Go). The owner's reasons were not stated; the rationale below is the assistant's.
- **Serves**: FR-013 (installable as a command through the language package manager),
  FR-006 (macOS only), Principle IV (simplicity)
- **Decision**: TypeScript on Node.js, installed through npm.
- **Rationale**:
  - npm installs a package as a command through its `bin` entry (Unverified here; widely
    documented behaviour).
  - Node's built-in test runner runs a test file with no extra dependency (Verified locally:
    `node --test` passed a one-test file). This serves Principle I without a test framework.
  - Node runs a `.ts` file directly with no build flag (Verified locally on v26.7.0). This keeps
    the development loop short.
  - Node is already installed on the maintainer machine, so the first task can start at once.
- **Alternatives considered**:
  - **Python (pipx)**: installs as a command and is installed locally (3.14.7). Rejected as the
    first choice because the type checking needed for a Domain with ports adds a separate tool.
    Remains the fallback if the owner prefers it.
  - **Go (`go install`)**: installed locally and gives one fast binary. Rejected because the
    owner chose "install through the language package manager, runtime required", and
    `go install` compiles from source and needs the full toolchain on every user machine.
  - **Swift (SwiftPM)**: calls Keychain natively. Rejected because SwiftPM has no registry that
    installs a package as a command (Unverified), which fails FR-013.
  - **Rust (`cargo install`)**: rejected because `cargo` is not installed here (Verified
    locally), so nothing could be built or tested on the maintainer machine.
- **Minimum runtime version**: Node 26.7.0, the only version verified. A lower minimum is
  allowed only after a test run on that version (open item O-1).

## D-002: How the tool is shipped to users

- **Status**: Proposed
- **Serves**: FR-013
- **Decision**: Publish compiled JavaScript with type declarations. Development runs `.ts`
  directly; the published package contains `.js`.
- **Rationale**: Node refuses to strip types for files inside `node_modules` (Unverified),
  so a published package cannot ship `.ts` as its entry point.
- **Alternatives considered**: shipping `.ts` and requiring a loader flag (rejected: every
  user would need the flag); a single bundled executable (out of scope per the owner's answer
  to the installation question).

## D-003: Secret storage (API key)

- **Status**: Proposed
- **Serves**: FR-014
- **Decision**: Call the built-in `/usr/bin/security` command through a `SecretStore` port.
  No native module and no third-party package.
- **Rationale**: The command exists on every Mac (Verified locally: `/usr/bin/security`
  answered a lookup with "item could not be found"). It needs no compiler and adds no
  dependency, which serves Principle IV.
- **Alternatives considered**:
  - **Native Keychain binding (npm package)**: rejected because it adds a compiled dependency
    that must build on each user's Mac.
  - **Config file with restricted permissions**: rejected by the owner (FR-014 requires
    Keychain).
- **Risk**: passing the key as a command argument can expose it in the process list. The
  adapter MUST pass the key on standard input where the command allows it. Whether the command
  accepts it that way is open item O-2; if it does not, this decision is reopened.

## D-004: Git access

- **Status**: Proposed
- **Serves**: FR-017, FR-018
- **Decision**: Run the user's installed `git` as a child process through the `KnowledgeSource`
  port. The tool never reads or stores a git password.
- **Rationale**: Git is installed at `/usr/bin/git` (Verified locally, version 2.53.0) and the
  owner chose to rely on the user's own git setup. A git library would duplicate
  authentication that git already does.
- **Alternatives considered**: a pure-JavaScript git library (rejected: it needs its own
  credential handling, which contradicts FR-017).
- **Conflict rule (FR-018)**: use a fast-forward-only update. If the remote moved, the push is
  rejected, the tool stops, and tells the user to sync and retry.

## D-005: HTTP knowledge repo access

- **Status**: Proposed
- **Serves**: FR-008, FR-014
- **Decision**: Use the HTTP client built into Node, behind the same `KnowledgeSource` port.
  The adapter is read-only: its write method is not implemented and returns a clear
  "read-only source" error.
- **Rationale**: no extra dependency (Principle IV). The wire format of the HTTP repo is not
  defined by any spec yet, so it is open item O-3 and is decided in spec 001.

## D-006: Local copy (offline reads)

- **Status**: Proposed
- **Serves**: FR-015, FR-016, FR-019, SC-006
- **Decision**: One directory per team under one tool-owned root in the user's home directory,
  plus one small state file that names the active team and lists everything the tool created
  (the ownership manifest). Read commands read only from the local copy.
- **Rationale**: reads then never touch the network, so the 1-second target (SC-006) depends
  on local disk only. The manifest is what lets uninstall remove everything (FR-019).
- **Alternatives considered**: a local database (rejected: 5,000 files do not need one and it
  adds a dependency); scattering files with no manifest (rejected: uninstall could not be
  complete).
- **Exact paths**: decided in the first task of spec 001's plan, not here.

## D-007: Logging format (deferred category: Observability)

- **Status**: Proposed
- **Serves**: Principle VII, FR-011
- **Decision**: One line per event on stderr, only when `--verbose` is set:
  `LEVEL component: message key=value ...`. No log files. Errors always print on stderr in the
  form `error: <what failed>. <how to fix it>` with or without `--verbose`.
- **Rationale**: simplest format that satisfies Principle VII; nothing is written to disk, so
  there is nothing to clean up at uninstall. Secrets are never logged (FR-014).
- **Alternatives considered**: JSON log lines (rejected for now: no consumer needs them; can
  be added later as a MINOR change); log files (rejected: they add files to track and rotate).

## D-008: Where architecture and decision records live (deferred category)

- **Status**: Proposed
- **Decision**: The architecture record is `plan.md` plus `data-model.md` in this feature
  directory. Decision records are this file (`research.md`). Project-wide terms go in
  `.specify/memory/`. No new top-level folder such as `docs/adr/`.
- **Rationale**: uses Spec Kit's own locations, so no custom layout is invented. Amendments go
  through the Governance process in the constitution.
- **Alternatives considered**: a root `docs/adr/` folder and a root `GLOSSARY.md` (rejected:
  the owner previously chose Spec Kit's own locations).

## D-009: Test strategy

- **Status**: Proposed
- **Serves**: Principle I, FR-010
- **Decision**: Three kinds of tests, all with `node --test`.
  - **Unit tests** cover the Domain with fake ports. No disk, network, or Keychain.
  - **Adapter tests** cover each adapter against a real local resource: a temporary git
    repository, a local HTTP server on the loopback address, and a throwaway Keychain item.
  - **CLI tests** run the command as a child process and check stdout, stderr, and exit code.
- **Rationale**: each kind covers one part, so a failure points to one part (FR-010).
- **Local limits**: macOS only, so everything can be run on the maintainer machine. Nothing
  here is CI-only.

## Open items

| ID | Item | Decides |
|----|------|---------|
| O-1 | Lowest Node version that passes the test suite | Owner, after a test run |
| O-2 | Whether `security` accepts the key on standard input (D-003) | Assistant, first adapter task |
| O-3 | Wire format of the HTTP knowledge repo | Owner, in spec 001 |
| O-4 | `bin` install and the `node_modules` type-stripping behaviour (D-001, D-002) | Assistant, first packaging task |
