# Data Model: Architecture and Technology Stack

**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

This spec has no stored data. The model below is the architecture itself: the layers, the
ports, and the map from each first-feature capability to the layer that owns it (SC-001).

## Entities

| Entity | Meaning | Key facts |
|--------|---------|-----------|
| Architecture Record | The agreed layers, dependency direction, and structure | lives in `plan.md`; changes only by amendment (Principle III) |
| Decision Record | One stack or design choice | lives in `research.md` as `D-nnn`; has status, requirement served, alternatives, evidence |
| Capability | One thing the tool does for an actor | owned by exactly one layer |
| Layer | `domain`, `application`, `infrastructure`, or `infrastructure.cli` | one responsibility; allowed dependencies in plan.md |
| Port | An interface defined in `application` | implemented by a gateway in `infrastructure` |
| Team | One knowledge repo a user has joined, with its own local copy | many per user, exactly one active (FR-016) |

## Actors

| Actor | Goal |
|-------|------|
| Admin | Create a knowledge repo and manage members, roles, projects, and env |
| Member | Join a team and read its knowledge |
| Any user | Choose scope, switch the active team, uninstall |

## Capability map (first planned feature: setup and team management)

The owning layer is where the rule or use case lives. A capability may call ports whose
implementations are in `infrastructure`; that does not change the owner.

| # | Capability | Owning layer | Ports used |
|---|------------|-------------|------------|
| 1 | Admin creates a knowledge repo from scratch | `application` | KnowledgeSource, LocalStore |
| 2 | Member joins a team with a repo URL | `application` | KnowledgeSource, LocalStore, SecretStore |
| 3 | Manage members | `application` | KnowledgeSource, LocalStore |
| 4 | Manage roles | `application` | KnowledgeSource, LocalStore |
| 5 | Manage projects | `application` | KnowledgeSource, LocalStore |
| 6 | Manage env | `application` | KnowledgeSource, LocalStore |
| 7 | Uninstall | `application` | LocalStore, SecretStore |
| 8 | Project scope or user scope (`--scope`) | `application` | LocalStore |
| 9 | Single-repo mode (`--self`) | `application` | LocalStore |
| 10 | HTTP knowledge repo without Git, read-only, API key only | `domain` (read-only rule) | KnowledgeSource, SecretStore |
| 11 | Generic git provider | `application` | KnowledgeSource |
| 12 | Switch the active team | `application` | LocalStore |
| 13 | Print results as text or JSON and set exit code | `infrastructure.cli` (controller and presenter) | none |

**Result**: 13 of 13 capabilities have an owner; none is unowned (SC-001).

Capabilities 1 to 12 are owned by `application` (or `domain` where a pure rule decides it)
because they are rules and sequences, not input or output. Capability 13 is owned by
`infrastructure.cli`. The gateways in `infrastructure` implement ports and hold no business
rule (Principle II).

## State transitions

A team's local copy has these states. They matter to FR-015 and FR-018.

| State | Meaning | Read | Change or sync |
|-------|---------|------|----------------|
| Not synced | Joined but the first sync has not finished | error: tell the user to sync | needs connection |
| Synced | Local copy matches the last sync | works offline | needs connection |
| Stale | The remote has moved since the last sync | works offline | rejected until the user syncs (FR-018) |

## Validation rules carried from the spec

- An HTTP source never accepts a write (FR-008).
- An API key is never written outside the Keychain (FR-014).
- Exactly one team is active at a time; every command names or shows it (FR-016).
- Everything the tool creates is listed in the ownership manifest (FR-019).
