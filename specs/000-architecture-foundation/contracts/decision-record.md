# Contract: Decision Record

Every architecture decision is a section in `research.md` (or, once accepted, a file under `architecture/`) that follows this shape. A reviewer can check a record against the list below without reading anything else.

## Required fields

| Field | Rule |
|---|---|
| Heading | `D-NNN: <short statement>` with a number that never changes |
| Status | One of draft, proposed, accepted, superseded |
| Date | Date of the last status change, ISO form |
| Decision | One or two sentences naming the choice |
| Rationale | Why, tied to the criteria, with evidence or a link to an experiment |
| Alternatives considered | At least two, or the constraint that left only one. Each has its reason for rejection |
| Review triggers | Conditions that reopen the decision |
| Replaced by | A link, only for a superseded decision |

## Rules

1. A decision that depends on an unproven assumption stays draft until an experiment result is attached (FR-008).
2. Only the project owner moves a decision to accepted (FR-015).
3. A decision that needs a change to the constitution or a feature spec links to a written proposal and does not apply the change (FR-016).
4. Evidence states its limits: which systems were not run, and what the sample did not cover.
5. The record is written in English only (FR-018).

## Check

A reviewer finds the reason for any decision and its review triggers within two minutes (SC-009).
