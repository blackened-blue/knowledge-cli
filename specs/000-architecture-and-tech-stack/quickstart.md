# Quickstart: Checking That Spec 000 Is Met

**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

Spec 000 has no code to run. These checks prove the architecture and stack records are
complete. Each check names the success criterion it covers.

## Prerequisites

- The files in this folder: `spec.md`, `plan.md`, `research.md`, `data-model.md`,
  `contracts/cli-conventions.md`.
- A Mac with Node installed, for the toolchain re-check in step 1.

## Checks

1. **Toolchain facts still hold** (research.md, "Verified locally").
   ```bash
   node --version && git --version && command -v security
   ```
   Expected: Node v26.7.0 or newer, a git version, and `/usr/bin/security`.

2. **Every capability has an owner** (SC-001).
   Open `data-model.md`, table "Capability map". Expected: 13 rows, each with an owning part.

3. **Every decision has an alternative** (SC-002).
   Open `research.md`. Expected: each of D-001 to D-009 that makes a technology or design
   choice lists at least one rejected alternative or a stated reason none exists.

4. **Find where new code goes in under 2 minutes** (SC-003).
   Pick any capability from `data-model.md` and, using only `plan.md`, name the folder under
   `src/` where its rule belongs. Expected: `src/domain/`.

5. **Dependency direction** (SC-004).
   Read the "Parts and allowed dependencies" table in `plan.md`. Expected: `domain` depends
   on nothing. A mechanical import check is a first task for spec 001; it does not exist yet.

6. **Read speed target is measurable** (SC-006).
   Expected: `plan.md` Technical Context states the 1-second goal and the scale of 100 members
   and 5,000 files. The measuring method is decided in the first implementation plan.

7. **Owner approval** (SC-005).
   Expected: every `Proposed` record in `research.md` is changed to `Approved` or sent back
   with a change. Spec 001 does not start until this is done.

## Not covered here

Running the CLI, installing it with npm, and timing a read command need code, which does not
exist yet. They belong to the plans of spec 001 onward.
