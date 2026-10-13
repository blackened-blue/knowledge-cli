# Quickstart: Validate the Architecture Foundation

This guide shows how to check that the foundation is complete. Steps 1 to 4 apply to the design stage. Steps 5 and 6 apply after the skeleton exists.

## Prerequisites

- The spec, plan and research files in this folder.
- The documents under `architecture/` once they are written.
- For steps 5 and 6, a clean machine of each supported system with Git and the toolchain the accepted stack requires.

## Steps

1. **Decisions are complete.** Open `research.md`. Every decision shows a status, a date and review triggers. Every stack decision lists its criteria, candidates and rejected alternatives. Pass: none is missing (SC-002, SC-009).
2. **Draft decisions are explained.** Each decision that is still draft points to the experiment that must run first. Pass: no draft decision lacks that pointer (FR-008).
3. **Traceability is complete.** Compare the row count in `architecture/traceability-map.md` with the requirements and success criteria in spec 001. Pass: they match, and each gap has an owner (SC-001).
4. **Principles are covered.** Check that nine of nine constitution principles map to a mechanism and a verification approach in `architecture/system-architecture.md` (SC-003), and that the threat model lists assets, threats and mechanisms (FR-002).
5. **Skeleton checks pass.** On each supported system, run the one documented contributor command. Pass: build, lint, tests and the dependency check succeed in under 10 minutes (SC-010). Add a forbidden import on purpose. Pass: the command fails and names it (SC-011).
6. **Skeleton has no product behavior.** Run `knowledge --version`. Pass: one line, exit code 0, no network use. List the commands. Pass: only the version command exists (SC-012). Watch the network during a run. Pass: no connection is made (FR-027).

## Evidence to keep

The record of each run (command, system, result) goes into the pull request description, as the constitution requires for changes to runtime behavior (Principle IX).

## Known gaps today

Experiment E3 (session-start hooks on Windows) and E9 (npm provenance and integrity) have not run. The Windows and Linux runs of E2, E4 and E7 are missing. The 5-second session-start budget, the E1 search corpus with composed and decomposed Unicode forms, and the E5 integrity check must be re-run in Node (see "Experiments Still Needed" in plan.md). Steps 5 and 6 cannot be performed until the owner accepts the stack and the structure (FR-019).
