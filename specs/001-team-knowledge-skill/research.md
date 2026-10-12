# Research: Team Knowledge Skill

Decisions recorded here use the form Decision, Rationale, Alternatives considered. `/speckit-plan` extends this file in Phase 0.

## D-001: A wiki is a dedicated repository, and its internal layout is the team's choice

**Decision**: Each Team Wiki is the whole of its own repository, marked by a single Marker file at the root. knowledge-cli does not impose a folder layout on Pages. Any markdown file is a Page, identified by its path from the repository root.

**Rationale**: Teams already keep wikis in many shapes. A CLI that supports only one layout shuts those teams out. A CLI that adapts to every layout needs judgment it is not allowed to have (Constitution, Principle VI). With a dedicated repository, sync, share and search need to know only three things: which files are Pages, which Page paths already exist, and whether a repository is a Team Wiki.

**Alternatives considered**:

- Require the layout of the existing wiki skills. Rejected: not every team uses those skills, and the layout would force a conversion before a team could join.
- Allow a wiki inside a subfolder of a repository that holds other content. Rejected: sync, share and search would each need rules for which files belong to the wiki, and a share could touch files the wiki does not own.
- Convert foreign formats inside the CLI. Rejected: conversion means choosing slugs, categories and links, which is non-deterministic work. It belongs in an agent skill whose output a reviewer approves as a Proposal.

**Consequences**:

- A team that keeps its wiki inside another repository must move it into a repository of its own before it can join. This is a one-time step outside the CLI.
- A team with a markdown wiki in its own repository can Adopt it by adding the Marker, with no Page changed.
- Ingest and query skills may still assume a particular layout. They are separate from this decision and can check for the layout they need.

**Carry-over notes for planning**: The existing wiki skills write a machine-specific absolute path into their schema file, and they enable their commit checks through repository-local configuration that a fresh clone does not carry. When the default layout is chosen, setup and join must handle both on each member's machine, so the repository holds no machine-specific data (FR-002, FR-005).
