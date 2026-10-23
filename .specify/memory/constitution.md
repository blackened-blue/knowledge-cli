# knowledge-cli Constitution

knowledge-cli is a command-line tool for managing a knowledge base from the terminal.

## Core Principles

### I. Test-First (NON-NEGOTIABLE)
Every feature MUST follow Red-Green-Refactor: tests are written first, MUST fail for the
expected reason, and only then is the implementation written. A change that adds or alters
behavior without a prior failing test MUST NOT be merged.
Rationale: tests written after the code tend to confirm what the code does, not what it should do.

### II. Domain Independence
The Domain layer MUST NOT depend on infrastructure: no database drivers, ORMs, file-system or
network libraries, or application frameworks. Domain code reaches the outside world only
through ports (interfaces) that it defines and infrastructure implements. Dependencies MUST
point inward only.
Rationale: business rules stay testable without I/O and survive changes of storage or framework.

### III. Architecture Before Features
No feature work starts until the architecture is agreed and recorded: business architecture,
system architecture, the technology stack with the evidence for choosing it, and the project
structure. A change that contradicts the recorded architecture MUST first amend it.
Rationale: settling structure up front is cheaper than reworking features built on a wrong one.

### IV. Simplicity
Use the fewest classes and interfaces that solve the problem. A new abstraction (interface,
base class, layer, or wrapper) MUST be justified in the plan by a concrete present need, not
a speculative future one. Prefer extending an existing type over adding a parallel one.
Rationale: every extra type is code to read, test, and maintain.

### V. CLI Text I/O
Every command MUST read from arguments or stdin and write results to stdout and errors to
stderr. Every command that returns data MUST offer both a human-readable format and a JSON
format. Exit codes MUST be zero on success and non-zero on failure.
Rationale: a predictable text protocol makes the tool scriptable and easy to test.

### VI. Versioning
The tool follows semantic versioning (MAJOR.MINOR.PATCH). Removing or renaming a command or
option, or changing an output format that existing users rely on, is a breaking change and
MUST bump MAJOR and be listed in the release notes.
Rationale: users script against the CLI, so breaking changes must be visible and deliberate.

### VII. Observability
Failures MUST produce an error message that states what failed and how to fix it. The tool
MUST support a verbose or debug mode that writes diagnostic logs to stderr, never to stdout.
Rationale: problems must be diagnosable from the terminal output alone.

## Additional Constraints

- The technology stack is chosen only through the process in Principle III and MUST be
  recorded with its supporting evidence.
- Third-party dependencies MUST be justified in the plan and MUST NOT be used in the Domain
  layer (Principle II).
- Command output formats are part of the public contract and are covered by Principle VI.

## Development Workflow

- Work follows the Spec Kit sequence: specify, clarify, plan, tasks, analyze, implement.
- Each plan MUST include a Constitution Check against Principles I to VII before design starts.
- Every pull request MUST show that its tests were written first and that it complies with
  this constitution; reviewers MUST reject changes that do not.
- Complexity that violates Principle IV MUST be recorded and justified in the plan.

## Governance

This constitution supersedes other practices in this repository. An amendment MUST be
proposed in writing with its rationale, approved by the project owner, and merged together
with any changes needed to bring existing artifacts into compliance.
Versioning of this document: MAJOR for removing or redefining a principle in a backward
incompatible way, MINOR for adding a principle or section or materially expanding guidance,
PATCH for clarifications and wording fixes.
Compliance is reviewed in every plan (Constitution Check) and every pull request.

**Version**: 1.0.0 | **Ratified**: 2026-10-23 | **Last Amended**: 2026-10-23
