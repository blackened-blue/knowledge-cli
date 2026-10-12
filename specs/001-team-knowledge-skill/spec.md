# Feature Specification: Team Knowledge Skill

**Feature Branch**: `001-team-knowledge-skill`

**Created**: 2026-10-12

**Status**: Draft

**Input**: User description: "A team sends one message to its AI assistant to install the Knowledge skill and set up the team's shared wiki from scratch. After setup, members use `/knowledge` to set up a new team, join an existing team by repository URL, and share wiki pages with the team. The wiki is synced to each member's machine at the start of every session and can be searched locally."

## Clarifications

### Session 2026-10-12

- Q: Can a member join more than one wiki on the same machine? -> A: Yes. Each joined wiki has its own name. Search covers every joined wiki by default and can be limited to one by name. Wikis are never merged.
- Q: How does the tool get access to the shared repository? -> A: It uses the access the member already has and never stores or manages credentials. When access is missing, it names what is missing.
- Q: What must a wiki repository look like, and what may it contain? -> A: Each wiki lives in its own dedicated repository, and the whole repository is the wiki. The only required structure is one marker file at the root that holds the wiki's name and description. Pages are markdown files in any folder layout the team chooses. The repository holds no machine-specific data. Setup and join configure the machine-specific parts on each member's machine.
- Q: What layout does setup create for a new wiki? -> A: The admin chooses. The default is the layout of the existing wiki skills, so the ingest and query skills work at once. The alternative is an empty markdown layout.
- Q: How does a team bring in a wiki it already has? -> A: A wiki that is already markdown in its own repository is adopted by adding only the marker file, with no page changed. A wiki inside a repository that holds other content must first be moved into a repository of its own. Content that is not markdown must first be converted. Moving and converting are outside this feature.
- Q: How is a page identified, and what happens when two members add a page at the same path? -> A: A page is identified by its path from the repository root. If that path already exists on the team's side, the later share becomes a proposal against the existing page. Paths are never changed automatically.
- Q: Are deleting and renaming a page ordinary shares? -> A: No. Both are changes to existing pages and always go out as proposals, because they can break links from other pages.

### Session 2026-10-13

- Q: What happens when a queued page reaches the team and its path now exists there? -> A: Nothing is sent automatically. The page stays in the queue. The system reports whether the two versions are identical, and the assistant reads both versions and recommends one action with its reason: send as a proposal against the existing page, share under a different path as a new page, or discard the queued page when it is identical. The member decides.
- Q: Must search work on pages written in languages without spaces between words, such as Thai and Chinese? -> A: Yes. Search covers pages in any language, returns the same ranked results every time, and does not call a language model. Tool messages stay in English.
- Q: What size must the feature support? -> A: Up to 5,000 pages per wiki and up to 5 joined wikis per machine. The 5-second limit at session start covers all joined wikis together. If syncing takes longer, the session opens first and the rest finishes afterward.
- Q: How does the member choose which pages to share? -> A: Share lists every new, changed, deleted and renamed page in the local copy. The member can remove pages from the list before confirming.
- Q: What is the status of a new page that reached the team without review? -> A: Every member syncs and searches it at once. Status reports how many pages are unreviewed. A reviewer moves them into the main line with the repository's own tools. This feature adds no command for it.
- Q: Who checks that claims in a page have sources? -> A: The assistant reads the page and gives advice the member may skip. It is not a fixed rule enforced by the tool.
- Q: How are suspected secrets detected? -> A: With a fixed set of rules for common credential patterns, with no language model. Teams cannot add rules in the first release.
- Q: Can a member leave a wiki? -> A: Not in the first release. A member removes the local copy by hand, and status reports whether pages are still waiting in the queue.
- Q: How are edits and deletions of an unreviewed page shared? -> A: Directly, like a new page, and the page stays unreviewed. Only pages already in the main line need a proposal. If the member's version is not based on the current team version, the page is not sent. It follows the collision handling in FR-026.
- Q: What if an assistant has no session-start support? -> A: The skill tells the assistant to sync as its first step in each session, and the health check reports which mode is active.
- Q: Which repository hosts are supported? -> A: Every step works on any Git host, except that proposals are opened automatically only on GitHub. On other hosts the tool pushes the proposal's branch and tells the member what to do next.
- Q: What happens when a secret reaches the wiki? -> A: The first release does not rewrite repository history. The assistant tells the member to change the secret's value at once and explains that removing it from history is the repository owner's job.
- Q: Should search results mark unreviewed pages? -> A: Yes. Every unreviewed page in the results carries an "unreviewed" label, so members and assistants can tell it from a page in the main line.
- Q: What does status show about a member's proposals? -> A: On GitHub, the member's open and rejected proposals. A rejected proposal never deletes the member's version, which stays in the local copy as a local edit. On other hosts, status shows only the branches that were pushed.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Set up a team wiki from scratch (Priority: P1)

A team admin pastes one message into their AI assistant. The message names the Knowledge skill and asks for a new team wiki. The assistant installs the skill and walks the admin through a few choices: the wiki's name, a short description, a starting layout, and the dedicated repository that will hold it. When the assistant finishes, the repository holds an empty wiki with its marker file, the chosen layout, and a short guide for contributors. The admin's machine has a working copy and is ready for the first session.

**Why this priority**: Nothing else works until a team wiki exists. This is the entry point for every team.

**Independent Test**: Start with an empty shared repository and a machine that has the AI assistant but no Knowledge skill. Send the one-line message. The test passes when the repository holds the wiki structure and contributor guide, and the admin can run a search without errors.

**Acceptance Scenarios**:

1. **Given** an empty shared repository and no skill installed, **When** the admin sends the setup message, **Then** the skill is installed, the wiki structure and contributor guide are created, and a health check reports no problems.
2. **Given** a repository that already contains a wiki, **When** the admin asks to set up a new team wiki in it, **Then** the assistant stops, says the wiki exists, and offers to join it instead of overwriting it.
3. **Given** the admin has no write access to the repository, **When** setup tries to create the structure, **Then** the assistant says which access is missing and changes nothing.
4. **Given** a repository that already holds markdown pages but no marker file, **When** the admin asks to set up a wiki in it, **Then** the assistant offers to adopt it by adding only the marker file and leaves every page unchanged.

---

### User Story 2 - Join an existing team wiki (Priority: P1)

A new member has a repository URL from their team. They ask their assistant to join that wiki. The assistant installs the skill if needed, copies the wiki to the member's machine, and confirms that the member can read and search it.

**Why this priority**: A wiki is only useful when more than one person can reach it. Setup and join together make the first usable release.

**Independent Test**: With a populated team wiki and a second machine, send the join request with the repository URL. The test passes when the wiki's pages are on the second machine and a search finds a known page.

**Acceptance Scenarios**:

1. **Given** a valid repository URL, **When** the member asks to join, **Then** the wiki is copied to the machine and a search for a known page title returns that page.
2. **Given** a URL that is unreachable or not a team wiki, **When** the member asks to join, **Then** the assistant explains what it found and changes nothing on the machine. If the repository holds markdown pages but no marker file, the assistant says an admin can adopt it.
3. **Given** the member already joined this wiki, **When** they ask to join again, **Then** the assistant reports the existing setup and refreshes it without duplicating anything.

---

### User Story 3 - Share a page with the team (Priority: P2)

A member has written or changed a wiki page and wants the team to have it. They ask their assistant to share it. A page that is new reaches the team without a review step. A change to a page already in the main line goes out as a proposal that a reviewer must approve. A change to an unreviewed page goes out directly. Before anything leaves the machine, the assistant checks the content for suspected secrets.

**Why this priority**: Sharing closes the loop and keeps the wiki growing, but it only matters once teams can set up and join.

**Independent Test**: On a joined machine, create one new page and edit one existing page. Share both. The test passes when the new page appears for other members after their next sync, and the edit appears only after a reviewer approves it.

**Acceptance Scenarios**:

1. **Given** a new page with no suspected secrets, **When** the member shares it, **Then** other members receive it at their next sync, no review is needed, and status counts it as unreviewed until a reviewer moves it into the main line.
2. **Given** an edit to an existing page, **When** the member shares it, **Then** a proposal is opened for review and the team's current page stays unchanged until approval.
3. **Given** a page that contains a suspected secret, **When** the member shares it, **Then** the assistant names the suspect text, warns the member, and publishes only after the member confirms a second time.
4. **Given** no network connection, **When** the member shares a page, **Then** the page is kept in a local queue and sent automatically once the connection returns.
5. **Given** a page whose path already exists in the main line, **When** the member shares it, **Then** it is sent as a proposal against the existing page and its path is not changed.
6. **Given** a member deletes or renames a page, **When** the member shares the change, **Then** it is sent as a proposal and lists the pages that link to the affected page.
7. **Given** a page without source references for its claims, **When** the member shares it, **Then** the assistant lists the unsourced claims and offers to cite them or mark them unverified, and the member can skip the offer.
8. **Given** a page whose path exists as an unreviewed page on the team's side and the member's version is not based on it, including a queued new page that collides after the connection returns, **When** the member shares it, **Then** the page stays in the queue, the assistant says whether the two versions are identical and recommends an action with its reason, and nothing is sent until the member chooses.
9. **Given** several changed pages in the local copy, **When** the member asks to share, **Then** the assistant lists every new, changed, deleted and renamed page and lets the member remove pages from the list before confirming.
10. **Given** an edit or deletion of an unreviewed page that is based on the current team version, **When** the member shares it, **Then** it is sent directly without a proposal and the page stays unreviewed.
11. **Given** a secret that was shared by mistake, **When** the member or the assistant finds it later, **Then** the assistant tells the member to change the secret's value at once and explains that removing it from history is the repository owner's job.

---

### User Story 4 - Stay in sync at every session start (Priority: P2)

When a member opens their AI assistant, the team's latest wiki pages arrive on their machine automatically. The member does nothing and sees no delay. If the member has changed a local page that the team also changed, the member's version is kept and the assistant says so.

**Why this priority**: A wiki that members must refresh by hand goes stale. Automatic sync is what makes the shared wiki feel current.

**Independent Test**: Have one member share a new page. Open a session on another machine. The test passes when the page is present within the sync time limit and no locally edited page was overwritten.

**Acceptance Scenarios**:

1. **Given** a joined wiki with new team pages, **When** the member starts a session, **Then** the new pages are present on the machine before the member's first request, provided the sync finishes within the time limit.
2. **Given** the member edited a page locally and the team changed the same page, **When** the session starts, **Then** the local version is kept and the assistant tells the member which page was kept.
3. **Given** no network connection, **When** the session starts, **Then** the session opens normally with the last synced copy and without an error.
4. **Given** several joined wikis whose combined sync would exceed the time limit, **When** the session starts, **Then** the session opens within the limit and the remaining sync finishes afterward.
5. **Given** an assistant without session-start support, **When** a session begins, **Then** the skill instructs the assistant to sync as its first step.

---

### User Story 5 - Search the wiki (Priority: P3)

A member or their assistant searches the local copy of the wiki by keyword and gets a ranked list of matching pages. The same query on the same wiki always returns the same order.

**Why this priority**: Search makes a growing wiki usable, but a small wiki can be read without it.

**Independent Test**: On a joined machine with a known set of pages, run the same query twice. The test passes when both runs return identical results and a page that contains the query term ranks above one that does not.

**Acceptance Scenarios**:

1. **Given** a joined wiki, **When** the member searches for a term that appears in some pages, **Then** those pages are listed, ranked by relevance, each with its wiki name and path.
2. **Given** a term that appears nowhere, **When** the member searches, **Then** the result says nothing matched and does not guess.
3. **Given** the same wiki and query, **When** the search runs twice, **Then** both results are identical.
4. **Given** a search result that includes an unreviewed page, **When** the results are listed, **Then** that page carries an "unreviewed" label.
5. **Given** pages written in Thai or Chinese, **When** the member searches for a word that appears in them, **Then** those pages are listed in the same ranked order every time.

---

### User Story 6 - Check that everything works (Priority: P3)

A member who sees odd behavior asks the assistant to check their setup. The assistant reports each problem by name together with the step that fixes it, and reports the current sync state of the wiki.

**Why this priority**: It reduces support work, but it adds nothing until the other stories exist.

**Independent Test**: Break one thing, such as removing the session-start sync. Run the check. The test passes when the check names that problem and gives a working fix.

**Acceptance Scenarios**:

1. **Given** a healthy setup, **When** the member runs the check, **Then** every item reports success.
2. **Given** a missing session-start sync, **When** the member runs the check, **Then** the check names it and states the step that restores it.
3. **Given** an assistant without session-start support, **When** the member runs the check, **Then** the check reports that sync runs by instruction and not automatically.

---

### Edge Cases

- A member loses network access in the middle of a share. Nothing is lost, and the queued page is sent later.
- A queued page collides with a page added by someone else while the member was offline. The page stays queued until the member chooses what to do.
- Two members add a page at the same path at the same time. The first share is accepted as a new page. The second is held and follows the collision handling in FR-026, and no path is changed automatically.
- A repository contains files that are not markdown. They sync like any other file, and search ignores them.
- A member deletes or renames a page that other pages link to. The change goes out as a proposal, and the reviewer sees which pages link to it.
- The shared repository has been renamed or moved. Sync reports the old address and says how to point the wiki at the new one.
- A wiki page is very large or in a format the search cannot read. Search skips it and says which pages it skipped.
- A member uses a different AI assistant from their teammates. Every command in this spec works the same way in any assistant that can run commands and load a skill.
- A sync is slower than the time limit. The session still opens, and the sync finishes or is retried later.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Members MUST be able to install the skill and start team setup by sending a single message to their AI assistant.
- **FR-002**: Setup MUST create a wiki in a dedicated repository with a marker file at the root that holds the wiki's name and description, a starting layout the admin chooses, and a contributor guide. The choices are the layout of the existing wiki skills (the default) and an empty markdown layout. The repository MUST NOT contain machine-specific data.
- **FR-003**: Setup MUST refuse to overwrite an existing wiki (a repository with a marker file) and MUST offer to join it instead. For a repository that holds markdown pages but no marker file, setup MUST offer to adopt it.
- **FR-004**: Members MUST be able to join an existing team wiki from a repository URL alone, and MUST be able to join more than one wiki on the same machine.
- **FR-005**: Joining MUST be repeatable: running it again on a joined machine refreshes the setup and creates no duplicates. Setup and join MUST configure every machine-specific part on the member's machine.
- **FR-006**: Members MUST be able to share a new page, and a new page MUST reach the team without a review step. A page is new only when no page at its path exists on the team's side. Members MUST be able to sync and search a new page at once, and the system MUST NOT add a command for moving unreviewed pages into the main line. An edit or deletion of an unreviewed page that is based on the current team version MUST be shared directly, and the page stays unreviewed.
- **FR-007**: A change to a page in the main line, including deleting or renaming it, MUST be sent as a proposal that a reviewer approves before it replaces the team's page. A shared page whose path already exists in the main line MUST be treated as a change to that page, and the system MUST NOT change its path automatically.
- **FR-008**: Sharing rights MUST come from the repository's own write access. The feature MUST NOT add its own permission layer.
- **FR-009**: Before publishing, the system MUST scan content for suspected secrets with a fixed set of rules for common credential patterns, MUST NOT use a language model for the scan, warn the member, and require a second confirmation. Teams cannot add rules in the first release. The system MUST NOT rewrite repository history. When a secret is found in a shared page afterward, the assistant MUST tell the member to change the secret's value at once and explain that removing it from history is the repository owner's job.
- **FR-010**: Before publishing, the assistant MUST read the page, list claims that lack a source, and offer to add a source or mark the claim unverified. This is advice the member can skip. The tool MUST NOT enforce it with a fixed rule.
- **FR-011**: When the network is unavailable, a shared page MUST be queued locally and sent automatically later without data loss.
- **FR-012**: The wiki MUST sync to the member's machine automatically at the start of every session. For an assistant without session-start support, the skill MUST instruct the assistant to sync as its first step in each session, and the health check MUST report which mode is active. Members MUST be able to ask for a sync at any time during a session.
- **FR-013**: Sync MUST NOT overwrite a page the member changed locally. It MUST keep that page and tell the member.
- **FR-014**: Sync MUST add no more than 5 seconds to session start across all joined wikis together. If syncing takes longer, the session MUST open first and the rest MUST finish afterward. Sync MUST open the session even when it fails, and MUST work offline from the last synced copy.
- **FR-015**: Every command that writes MUST offer a preview that shows its changes without making them.
- **FR-016**: Search MUST run on the local copies, MUST return the same ranked results for the same wikis and query, and MUST NOT call a language model. By default it covers every joined wiki, and a member can limit it to one wiki by name. Each result MUST show its wiki name and path, and MUST label every unreviewed page as unreviewed. It MUST find pages written in any language, including languages without spaces between words, such as Thai and Chinese.
- **FR-017**: The system MUST provide a health check that names each problem and the step that fixes it, and a status view of each wiki's sync state, including how many pages are unreviewed and how many are waiting in the queue. On GitHub, status MUST also list the member's open and rejected proposals. A rejected proposal MUST NOT delete the member's version, which stays in the local copy as a local edit. On other hosts, status MUST list the proposal branches that were pushed.
- **FR-018**: Members MUST NOT need to know how the repository works. The assistant runs every command and explains outcomes in the member's terms.
- **FR-019**: The feature MUST work in any AI assistant that can run shell commands and load a skill.
- **FR-020**: All commands, messages, and generated files MUST be written in English.
- **FR-021**: Each joined wiki MUST have a name that is unique on the machine. Joining a wiki whose name is already taken by a different repository MUST ask the member for another name and change nothing.
- **FR-022**: The system MUST use the access the member already has to the shared repository and MUST NOT store or manage credentials. When access is missing, it MUST say which access is missing.
- **FR-023**: A wiki MUST be the whole of its dedicated repository. The system MUST NOT support a wiki that lives in a subfolder of a repository that holds other content.
- **FR-024**: Pages MUST be markdown files in any folder layout. The system MUST NOT impose a folder structure on pages, and a page is identified by its path from the repository root.
- **FR-025**: Adopting an existing markdown repository MUST add only the marker file and MUST leave every existing page unchanged.
- **FR-026**: When a page to be shared has a path that exists as an unreviewed page on the team's side and the member's version is not based on it, including a queued new page that collides after the connection returns, the system MUST keep the page queued and MUST NOT send or rename it automatically. It MUST report whether the two versions are identical. The assistant MUST read both versions and recommend one action with its reason: updating the unreviewed page, sharing under a different path, or discarding the queued page when it is identical. The member chooses.
- **FR-027**: Share MUST list every new, changed, deleted and renamed page in the local copy and MUST let the member remove pages from the list before confirming.
- **FR-028**: The system MUST support wikis of up to 5,000 pages and up to 5 joined wikis per machine.
- **FR-029**: Every step MUST work on any Git host, except that proposals are opened automatically only on GitHub. On other hosts, the system MUST push the proposal's branch and tell the member what to do next.

### Key Entities

- **Team Wiki**: The whole of one dedicated repository, shared by one team, with a name, a description, and a contributor guide. A marker file at the root identifies the repository as a team wiki.
- **Page**: One markdown file in the wiki, identified by its path from the repository root, with a body and source references for its claims.
- **Member**: A person on the team with a local copy of the wiki, who may have local edits.
- **Local Copy**: One joined wiki as it exists on one member's machine, including its search index and the queue of pages waiting to be shared. A member has one local copy per joined wiki.
- **Proposal**: A requested change to a page in the main line that waits for a reviewer's approval.
- **Queue**: Pages and proposals a member has shared that have not reached the team yet.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An admin with an empty repository finishes team setup, from the first message to a passing health check, in under 5 minutes.
- **SC-002**: A new member joins an existing wiki and finds a known page by search in under 3 minutes.
- **SC-003**: A page shared by one member is available on a second member's machine at that member's next session start, in 100% of tested cases where the second machine is online.
- **SC-004**: With 5 joined wikis of 5,000 pages each, session start adds no more than 5 seconds of wait for the member, and the session opens normally in 100% of tested offline cases.
- **SC-005**: In tests with locally edited pages, no local edit is overwritten by a sync.
- **SC-006**: The same query on the same wiki returns identical results in 100% of repeated runs.
- **SC-007**: In tests with seeded secrets, every seeded secret is flagged before publishing.
- **SC-008**: Members complete setup, join, and share without any step that requires knowledge of the repository's inner workings, as confirmed by usability testing with at least five people who have not seen the tool before.
- **SC-009**: A team with a markdown wiki in its own repository adopts it, and a member then finds a known page by search, in under 10 minutes with no existing page changed.
- **SC-010**: In tests with pages written in Thai and in English, a search for a word from each page returns that page, and repeated runs return identical results.

## Assumptions

- Each team has, or can create, one dedicated repository for its wiki, with write access for its contributors and a protected default branch. This spec calls that branch the main line.
- Members use a computer running macOS or Linux and an AI assistant that can run shell commands and load a skill.
- The wiki is made of text pages. Images and other binary files are out of scope for the first release.
- In the default layout, the original source documents that pages cite live in the wiki repository next to the pages, so every member can trace a citation. Teams that choose another layout decide where their sources live.
- Repository history is never rewritten by this feature, and removing a leaked secret from history is the repository owner's job.
- Leaving a wiki is outside the first release. A member removes the local copy by hand.
- Teams are not required to use the existing wiki skills. Moving a wiki into a repository of its own, and converting content that is not markdown, are outside this feature.
- Ingesting outside sources into the wiki and answering questions from it are handled by the assistant's own skills, not by commands in this feature.
- A team has one wiki per repository. A member can join several wikis, but wikis are never merged and pages do not link across them.
- The feature is independent of any other team tooling. It shares no data and no configuration with other products.
- Members have a stable enough connection for the occasional sync, and the offline cases above are the exception.
