# Knowledge

A shared wiki for a team, kept in one dedicated repository and synced to each member's machine so their AI assistant can read, search and extend it.

## Language

**Team Wiki**:
The whole of one dedicated repository, shared by one team and identified by a name.
_Avoid_: Knowledge base, KB, library

**Marker**:
The single file at the root of a repository that makes it a Team Wiki and holds its name and description.
_Avoid_: Config, manifest, schema

**Page**:
One markdown file in a Team Wiki, identified by its path from the repository root.
_Avoid_: Article, note, entry, document

**Source**:
An original document that a Page cites for a claim.
_Avoid_: Reference, attachment

**Member**:
A person on the team who has joined a Team Wiki on their machine.
_Avoid_: User, contributor

**Local Copy**:
One joined Team Wiki as it exists on one Member's machine.
_Avoid_: Clone, cache, mirror

**Proposal**:
A requested change to a Page in the Main Line that waits for a reviewer's approval.
_Avoid_: Pull request, edit request

**Queue**:
The Pages a Member has shared that have not reached the team yet.
_Avoid_: Outbox, backlog

**Share**:
Sending a new Page, or a Proposal for an existing Page, to the team.
_Avoid_: Publish, push, submit

**Join**:
Putting a Local Copy of an existing Team Wiki on a Member's machine.
_Avoid_: Subscribe, install

**Adopt**:
Turning an existing markdown repository into a Team Wiki by adding the Marker, without changing any Page.
_Avoid_: Import, migrate, convert

**Unreviewed Page**:
A Page that reached the team as a new Page, without a Proposal, and that a reviewer has not yet moved into the main line.
_Avoid_: Draft, pending page

**Main Line**:
The protected default branch of a Team Wiki's repository, where reviewed Pages live.
_Avoid_: Trunk, master, production

**Sync**:
Bringing a Member's Local Copy up to date with the team's version, without overwriting what the Member changed.
_Avoid_: Pull, update, refresh

**Stale**:
A Local Copy whose latest sync failed or ran out of time, so it may be behind the team's version.
_Avoid_: Outdated, offline
