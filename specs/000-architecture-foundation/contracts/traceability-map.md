# Contract: Traceability Map

A single table in `architecture/traceability-map.md`. One row per functional requirement and per success criterion of spec 001 (and later, of other feature specs).

## Columns

| Column | Rule |
|---|---|
| Source | Spec number and id, for example `001/FR-014` |
| Requirement | The requirement shortened to one line |
| Components | One or more component ids from the system architecture |
| Decisions | One or more decision ids |
| Verification | The test, experiment or walkthrough that proves it |
| Gap | Empty, or a short note followed by an owner |

## Rules

1. Every requirement and success criterion of spec 001 has a row (SC-001).
2. A row with no component or no decision is a gap. A gap needs an owner.
3. When a spec changes, the affected rows are updated and the decisions they cite are re-reviewed.
4. A requirement the architecture cannot meet is raised as a proposal to change the spec or the constitution, and is never hidden in a gap note (Story 5, scenario 3).

## Check

The row count equals the number of requirements plus success criteria in spec 001. The five core scenarios (setup, join, share, sync, search) are walked through the architecture and any gap is recorded here (FR-013, SC-006).
