# knowledge-cli Constitution

## Core Principles

### I. Spec Before Code
Every feature MUST have an approved specification before implementation starts. Specs describe
user-visible behavior and acceptance scenarios; plans and tasks derive from the spec. Code that
has no traceable spec requirement MUST NOT be merged.

### II. Git Is the Only Store
A team's wiki lives in one Git repository. knowledge-cli MUST NOT require a server, a database,
or a vector store. Anything kept on a member's machine (clone, search index, queue) is a
rebuildable cache of the repository or a pending contribution, never a second source of truth.

### III. Agent-First, Git-Invisible, Harness-Neutral
Members use knowledge-cli by talking to their AI assistant. The installed skill is a thin stub;
the workflow text is served by the CLI so it always matches the installed version. The assistant
runs the commands and MUST NOT require a member to understand Git. No feature may depend on one
AI tool: each behavior MUST work in any assistant that can run shell commands and load a skill.

### IV. Reviewed Publishing
Nothing is published to the wiki's main line (its protected default branch) directly. A new
page, meaning one whose path does not exist on the team's side, MAY be published to a dedicated
contributions branch without a pull request. Pages are identified by path. A new page whose path
is already taken is held for the member and never renamed automatically. A change to a page in
the main line, including deleting or renaming it, MUST go through a proposal (pull request) that
a reviewer approves. An edit to an unreviewed page that is based on the current team version MAY
be sent directly to the contributions branch. If the network is unavailable, a contribution MUST
be queued locally and retried later, never lost.

### V. Safe and Fast Sync
Sync MUST run automatically at session start and MUST NOT overwrite a file the member changed
locally; it keeps the file and says so. Sync MUST work offline from the last clone. Any hook MUST
finish within 5 seconds, fail softly (exit 0, record the cause), and never break the session.
`--dry-run` MUST preview every command that writes.

### VI. Deterministic Search, Minimal CLI
The CLI offers setup, join, sync, search, share, status, doctor and skill, and nothing that calls
a language model. (`skill` prints the workflow text that matches the installed version.) Search
MUST be local, deterministic and explainable (keyword ranking over a
local index). Ingesting sources and answering questions are agent skills, not CLI commands. A new
CLI command requires proof that no existing command or option can be extended instead.

### VII. Provenance Required (NON-NEGOTIABLE)
Every factual claim in a wiki page MUST cite its source. A claim without a source MUST be marked
unverified. Pages MUST carry the metadata needed to trace and search them. A contribution that
violates this MUST be rejected at review.

### VIII. Simple Design
Prefer the smallest design that satisfies the spec: fewer files, types and commands. Abstractions
MUST be justified by a current requirement, not a future one. Complexity MUST be recorded with
the simpler alternative that was rejected and why.

### IX. Tested Behavior
Behavior changes MUST ship with automated tests. A change to runtime behavior MUST also record
one end-to-end run of the real built CLI against a real repository. A docs-only or tests-only
change needs no end-to-end record.

## Constraints

- All created artifacts (specs, plans, docs, wiki pages, code, CLI output, commit messages) MUST
  be written in English only.
- Secrets MUST NOT enter the wiki repository. Share MUST scan for suspected secrets, warn, and
  require extra confirmation before publishing.
- Sharing rights come from the repository's own write access. knowledge-cli MUST NOT add its own
  permission layer.
- Diagnostics MUST be actionable: `doctor` names each failure and prints the fix.

## Development Workflow

- Work happens on feature branches. Changes reach `main` through a pull request that a human
  approves. Direct pushes to `main` are forbidden.
- Every spec, plan and task list MUST be checked against this constitution before implementation.
- Every pull request description MUST state which principles it touches and include the
  end-to-end record required by Principle IX when applicable.

## Governance

This constitution supersedes other practices. Amendments require a written proposal, human
approval, and a version bump recorded below. Versioning follows semantic versioning: MAJOR for
removing or redefining a principle, MINOR for adding a principle or materially expanding
guidance, PATCH for clarifications. Reviewers MUST verify compliance on every pull request, and
any justified violation MUST be listed in the plan's complexity section.

**Version**: 1.1.1 | **Ratified**: 2026-10-12 | **Last Amended**: 2026-10-13

Amendment 1.1.0 (MINOR, approved by the project owner on 2026-10-13): Principle IV now matches
the clarified specs (pages identified by path, collisions held for the member, proposals for
changes to the main line, direct edits to unreviewed pages). Principle VI renames `pull` to `sync`
and adds the `skill` command.

Amendment 1.1.1 (PATCH, approved by the project owner on 2026-10-13): Principle V uses "Sync"
instead of "Pull" in its title and text, matching Principle VI and the specs. No rule changed.
