# Data Model: Architecture and Technology Stack

**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

This spec has no stored data. The model below is the architecture itself: the parts, the
ports, and the map from each first-feature capability to the part that owns it (SC-001).

## Entities

| Entity | Meaning | Key facts |
|--------|---------|-----------|
| Architecture Record | The agreed parts, dependency direction, and structure | lives in `plan.md`; changes only by amendment (Principle III) |
| Decision Record | One stack or design choice | lives in `research.md` as `D-nnn`; has status, requirement served, alternatives, evidence |
| Capability | One thing the tool does for an actor | owned by exactly one part |
| Part | `domain`, `adapters`, or `cli` | one responsibility; allowed dependencies in plan.md |
| Port | An interface defined in `domain` | implemented in `adapters` |
| Team | One knowledge repo a user has joined, with its own local copy | many per user, exactly one active (FR-016) |

## Actors

| Actor | Goal |
|-------|------|
| Admin | Create a knowledge repo and manage members, roles, projects, and env |
| Member | Join a team and read its knowledge |
| Any user | Choose scope, switch the active team, uninstall |

## Capability map (first planned feature: setup and team management)

The owning part is where the rule or use case lives. A capability may call ports whose
implementations are in `adapters`; that does not change the owner.

| # | Capability | Owning part | Ports used |
|---|------------|-------------|------------|
| 1 | Admin creates a knowledge repo from scratch | `domain` | KnowledgeSource, LocalStore |
| 2 | Member joins a team with a repo URL | `domain` | KnowledgeSource, LocalStore, SecretStore |
| 3 | Manage members | `domain` | KnowledgeSource, LocalStore |
| 4 | Manage roles | `domain` | KnowledgeSource, LocalStore |
| 5 | Manage projects | `domain` | KnowledgeSource, LocalStore |
| 6 | Manage env | `domain` | KnowledgeSource, LocalStore |
| 7 | Uninstall | `domain` | LocalStore, SecretStore |
| 8 | Project scope or user scope (`--scope`) | `domain` | LocalStore |
| 9 | Single-repo mode (`--self`) | `domain` | LocalStore |
| 10 | HTTP knowledge repo without Git, read-only, API key only | `domain` (read-only rule) | KnowledgeSource, SecretStore |
| 11 | Generic git provider | `domain` | KnowledgeSource |
| 12 | Switch the active team | `domain` | LocalStore |
| 13 | Print results as text or JSON and set exit code | `cli` | none |

**Result**: 13 of 13 capabilities have an owner; none is unowned (SC-001).

Capabilities 1 to 12 are owned by `domain` because they are rules and sequences, not input
or output. Capability 13 is owned by `cli`. `adapters` owns no capability: it only implements
ports, so it holds no business rule (Principle II).

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
