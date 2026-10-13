# Research: Architecture Foundation

Decisions use the form Decision, Rationale, Alternatives considered. The status of each decision is on its own **Status** line (draft, proposed, accepted or superseded). Under FR-015 a decision becomes **accepted** only after the project owner approves it. Under FR-008 a decision that rests on an unproven assumption stays **draft** until an experiment backs it.

## How the experiments were run

- Machine: one Apple silicon Mac (macOS). **No Windows machine and no Linux machine were available**, so every result below is for macOS only unless stated. Cross-compiled binaries for other systems were built but not run.
- Tool versions on the machine: Go 1.26.5, Node 26.7.0 (ICU 78.3, Unicode 17.0), Python 3.14.7, .NET 10.0.302, Git 2.53.0. Rust, Bun and Deno were not installed and were not evaluated.
- Each experiment was throwaway code in a temporary directory outside the repository (FR-017). Only results are kept here. Test pages in Thai and Chinese existed only in that temporary directory. This document holds no Thai or Chinese text.
- All timings are single runs on one machine. They show orders of magnitude, not guarantees.

## Experiment results at a glance

| ID | Subject | Status | Result in one line |
|---|---|---|---|
| E1 | Deterministic search for Thai, Chinese and English | Done (macOS) | Character bigrams with an adjacency check gave full recall and precision on the test set, with identical tokens in three languages |
| E2 | Session start within 5 seconds for 5 wikis of 5,000 pages | Done (macOS, local remotes) | Rebuilding the index each session is too slow; incremental update and parallel fetch fit the budget |
| E3 | Session-start hook on Windows and other systems | **Not run** | Needs a Windows machine and at least two assistants |
| E4 | Distribution without a separate runtime | Done (macOS builds; other systems built, not run) | A Go executable is about 1.7 MB per system; a self-contained .NET executable is about 73 to 80 MB |
| E5 | Download integrity check | Done | A checksum rejected 300 of 300 flipped bytes and a truncated file |
| E6 | Unreviewed pages with plain Git | Done (macOS, local remotes, no hosting rules) | The mechanism works, but promotion must use merge commits. Squash promotion with a reviewer fix caused a conflict |
| E7 | Path collisions on case-insensitive systems | Done (macOS only) | Case-only collisions are silently collapsed by Git; a normalised-path check catches them |
| E8 | Fixed secret rules | Done | 50 of 50 seeded secrets flagged after one rule fix; 4 false alarms in 23,703 real lines |

## D-001: A wiki is a dedicated repository, and its internal layout is the team's choice

**Status**: Accepted, 2026-10-13 (owner approval). Earlier note: Proposed (carried from the earlier decision record)

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

## D-002: Implement in TypeScript on Node.js (owner choice, replaces the Go proposal)

**Status**: Accepted, 2026-10-13 (owner choice). The research proposal was Go; the owner chose TypeScript on Node.js. Earlier note: Owner choice, 2026-10-13. The research proposal was Go. The owner chose TypeScript to follow the tool this product learns from, whose runtime prerequisite the owner already accepted in spec 000. The Go analysis below is kept as the record of the alternative.

**Decision**: Write the product in TypeScript and ship it as a bundled package that runs on Node.js. Use the installed Git program for all repository work. Use the Node standard library wherever it is enough. Unicode normalisation uses the built-in `String.prototype.normalize`, so the extra module the Go option needed is not required.

**Consequences accepted with this choice**:

- Every member's machine needs Node.js as well as Git and an AI assistant. This is the prerequisite that spec 000 accepted ("follow teamai-cli"); the install message and the prerequisite check must say so (FR-031, FR-032).
- The 5-second session-start budget must be re-measured with Node start-up included. E2 and E4 numbers for Node are naive prototypes, and no Node-based executable bundle was available in E4.
- Word segmentation and normalisation depend on the Node runtime's ICU version (see D-003). The search design uses character bigrams precisely so it does not depend on segmentation.
- The dependency tree is larger than with Go (see D-031), which raises the supply-chain surface.

**Rationale for the original Go proposal** (kept for the record): The confirmed order of concern is safe data, then simple design, then portability, then speed. A static executable removes the runtime prerequisite that FR-031 and FR-032 treat as costly, so a member needs only an AI assistant and Git. Experiment E4 shows:

| Candidate | Result of E4 |
|---|---|
| Go | Executables of 1.63 to 1.73 MB for macOS, Linux and Windows on two processor families. All five were built from one Mac with no extra toolchain: the four cross builds took 2.2 to 2.4 seconds each and the native macOS build 0.5 seconds. The macOS build ran and printed its version in under 20 ms |
| .NET (self-contained, single file) | 73.5 to 80.0 MB per system. Cross-publishing to Windows and Linux from the Mac worked. First start took 1.7 seconds once, then 20 ms |
| Node single executable | Not available in the installed Node build ("Single executable application is disabled"). Inconclusive, not a rejection |

Using the installed Git program fits FR-031 (Git is already required), uses the member's existing credentials and credential helpers (FR-022), and avoids embedding a Git library.

**Alternatives considered**:

- Go (the original proposal). Single static executable, about 1.7 MB per system, no runtime. Not chosen by the owner.
- Node with TypeScript. **Chosen** (see the decision above).
- .NET self-contained. Works, but the executable is about 45 times larger than the Go one in this test.
- Python. Needs a runtime on the machine. Packaging into a single file was not tested.
- Rust. **Decision: not evaluated in this round.** The toolchain was not installed, an assessment would cost about a further working day, and Go already meets every measured constraint (static executable, five targets from one machine, no runtime). Rust is not rejected on merit. Reopen it if Go fails an experiment for a reason Rust would not share (E3, E6 or Windows builds), if signing and notarisation prove much harder with Go, or if the owner or the team prefers Rust.

**Risks and open items**:

- With TypeScript the normalisation module of the Go option is not needed. E1 used a corpus that was already NFC, so the parity result does not cover normalisation yet; add composed and decomposed forms to the test set.
- macOS code signing and notarisation, and the Windows SmartScreen warning for unsigned executables, were not tested. They affect how members see a first run.
- Windows and Linux executables were built but never run.
- Team familiarity with Go was not measured. It is the owner's call.

## D-003: Search uses character bigrams with an adjacency check

**Status**: Accepted, 2026-10-13 (owner approval), conditional on re-measurement in Node (the Node prototype and the Unicode test set). Reopen if the re-measurement fails. Earlier note: Proposed. E1 supports it on a small test set.

**Decision**: Normalise text to NFC and lower case. Split it into runs of letters, numbers and **combining marks**. For a run that contains Thai or CJK characters, index overlapping two-character tokens (a single character stays as one token). For any other run, index the whole word. Match a query only when its tokens appear in the page at consecutive positions.

**Rationale**: Thai and Chinese have no spaces between words. This scheme needs no dictionary and no runtime-specific library, so results do not change with the runtime or its ICU version.

Evidence from E1 (macOS):

| Check | Result |
|---|---|
| Whitespace tokens on the Thai and Chinese test pages | Recall 0 (fails) |
| ICU word segmenter (Node, ICU 78.3) | Recall 1.0, precision 1.0 on 12 pages per language |
| Character bigrams | Recall 1.0, precision 1.0 on the same pages |
| Repeat the same query 100 times | Identical results for all three methods |
| Token streams from Node, Python and Go | Identical for every page |
| Bigrams, "all tokens present" only, on 5,000 synthetic pages and 60 queries | 2,931 false matches against 87,585 true matches (about 3.2% extra results) |
| Bigrams plus adjacency check, same data | 0 false matches and 0 missed |

A pitfall that the experiment found: a token class of letters and numbers only splits Thai words at vowel and tone marks, which are combining marks. Node and Python then produced 6,641 terms where a class including marks produced 6,786, matching Go. The tokeniser must include combining marks.

**Alternatives considered**:

- The runtime word segmenter. Rejected as the primary method: results depend on the ICU data version and on the runtime, which weakens the repeatable-results requirement across three systems. It remains an optional ranking aid.
- A dictionary-based segmentation library. Rejected: adds a dependency and a language-specific data file.

**Limits of the evidence**: The test set is small and hand-written. The 5,000-page set is synthetic, random word sequences. Ranking quality (relevance order) was not measured. Latin-script stemming was not tested.

## D-004: Sync is incremental, parallel and bounded

**Status**: Accepted, 2026-10-13 (owner approval), conditional on re-measurement in Node (the Node prototype and the Unicode test set). Reopen if the re-measurement fails. Earlier note: Proposed. E2 supports it on macOS with local remotes.

**Decision**: Fetch all joined wikis in parallel. Keep the search index on disk and update it only for pages that changed. Build the full index once, at join time. Give the whole sync a 5-second budget; if it runs over, open the session first and finish in the background. Store the index in a compact on-disk format.

**Rationale**: Measured on one Mac, five test wikis of 5,000 pages each (about 6 KB per page):

| Measurement | Result |
|---|---|
| Fetch with no change, five wikis, one after another (local remote) | 0.14 s |
| Fetch with no change, five wikis in parallel (local remote) | 0.06 s |
| Fetch and fast-forward with 50 new and 20 edited pages, five wikis one after another | 1.82 s |
| Real round trip to GitHub (`git ls-remote`), five one after another | 3.73 s |
| The same five in parallel | 0.75 s |
| Full index build of one wiki, three naive implementations (Go, Node, Python) | 1.5 s, 1.6 to 1.9 s, 2.5 s |
| Incremental update of 70 changed pages | 7 to 16 ms |
| Query on a 5,050-page index | 0.4 to 0.65 ms (Go, Node), 2.6 ms (Python) |
| Memory of the naive in-memory index for one wiki | about 470 to 720 MB |

Rebuilding five full indexes at every session start would cost roughly 7.5 to 12.5 seconds, above the budget. Sequential network round trips alone would cost 3.7 seconds for five wikis. Parallel fetching and incremental updates fit.

**Alternatives considered**:

- Rebuild the index every session. Rejected by the numbers above.
- Sequential fetches. Rejected: 3.7 seconds of latency before any data moves.
- In-memory index structures like the ones tested. Rejected: memory use of several hundred megabytes for one wiki.

**Limits of the evidence**: Remotes were local, so transfer time is missing. The GitHub measurement shows latency only. The index code was naive, not an optimised design, so its memory and build time show the problem, not the final numbers. Windows and Linux were not run. Windows Git is usually slower on large checkouts, which is untested here.

## D-005: Check downloads against a publisher checksum, and add a signature

**Status**: Accepted pending experiment E9, 2026-10-13 (owner approval). If E9 fails, the decision returns to the owner. Earlier note: Proposed. The signature scheme is an open item.

**Decision**: What a member installs is verified against information from the publisher, and nothing is installed if the check fails. With the package route chosen in D-036, the registry's integrity data for the package is checked at install, and the publisher's signed provenance attestation is checked as well, so that a compromised download location cannot replace both the package and its checksum. The original proposal (download a file and its checksum, then verify) applied to a standalone executable and is kept only as the record of the alternative.

**Rationale**: E5 built a verifier in Go (before the language choice moved to TypeScript; the check must be re-run in Node, which has the needed hash functions built in). It rejected 300 of 300 files with one flipped bit at a random position, and it rejected a file shortened by one byte. A checksum alone protects against corruption and tampering in transit. It does not protect against a publisher location that is itself compromised, which is why the signature is part of the decision.

**Alternatives considered**:

- Checksum only. Rejected for the reason above.
- No check. Rejected by FR-029.

**Open items**: The way verification runs inside the installer is not evaluated (see D-027). Windows and macOS platform signing were not tested.

## D-006: A page path is compared after Unicode and case normalisation

**Status**: Accepted, 2026-10-13 (owner approval), conditional on re-measurement in Node (the Node prototype and the Unicode test set). Reopen if the re-measurement fails. Earlier note: Proposed. E7 covered macOS only.

**Decision**: When a page is shared, compare its path with team paths after NFC normalisation and case folding. A match with a different original path is a collision and is held for the member (FR-026). Also flag Windows reserved names (such as CON, PRN, AUX, NUL, COM1 to COM9, LPT1 to LPT9) and over-long paths before sending.

**Rationale**: E7 on macOS, whose default file system ignores case:

- A repository containing `Alpha.md` and `alpha.md` was cloned with a warning, and only one file appeared on disk. Without a check, a member could silently lose one page.
- Git on macOS precomposed an accented name, so composed and decomposed forms became one entry.
- A normalise-and-fold check found the case-only collision, and a name table found the reserved name `CON.md`.

**Limits of the evidence**: The reserved-name rule was checked as table logic. It was not tried on Windows. Linux was not run. Long-path behaviour was not tested.

## D-007: Secret scan uses a fixed set of ten rules

**Status**: Accepted, 2026-10-13 (owner approval), with the false-alarm threshold set at no more than 3% of clean pages and zero missed seeded secrets. Earlier note: Proposed. The acceptable false-alarm rate is **not set**.

**Decision**: Scan every page at share time with ten fixed rules for cloud keys, source host tokens, chat tokens, private key blocks, signed web tokens, API keys and generic password or token assignments. Teams cannot add rules in the first release.

**Rationale**: E8 seeded 50 fake secrets (10 kinds, five each, in four kinds of context) and scanned 130 real markdown files (23,703 lines) from local documentation.

| Check | Result |
|---|---|
| First run on seeded secrets | 49 of 50 flagged. The miss was a Google-style key ending with a hyphen, caused by a word-boundary mistake in the rule |
| After fixing that rule | 50 of 50 flagged |
| False alarms on real documents | 4 lines in 3 of 130 files, all from the generic assignment rule, all example or placeholder values |

**Alternatives considered**: A language-model scan was rejected by FR-009.

**Threshold (set at the owner's request, proposed)**: In a clean sample of at least 100 real pages, at most 3% of pages may trigger a warning, and 100% of seeded secrets must be flagged. The measured 2.3% of files (3 of 130) passes by a small margin, and the missed-secret count is zero. The reason for choosing a per-page bound is that a member sees one warning per page shared, so about 1 share in 43 would show a false warning at the measured rate. Each warning names the rule and the line, and one confirmation lets the member continue. A shorter rule for generic assignments that ignores values written as references or obvious placeholders is the first remedy if the rate rises.

**Limits**: The sample is tool documentation, not wiki pages, and may differ from real wikis with code samples. The seeded secrets were generated by the same person who wrote the rules, which favours the result. Re-run on a real team wiki before accepting.

## D-008: Session-start hooks on Windows and other systems

**Status**: Draft. Experiment E3 (session-start hooks on Windows) has not run. Kept as a draft by the owner on 2026-10-13. Earlier note: **Draft. Experiment E3 not run.**

**What is known**: The team tooling this product learns from writes a wrapper at a fixed location in the user's home, because some assistants' hooks cannot see the member's search path. On Windows it calls a Git shell by absolute path so the hook does not land in the Windows Subsystem for Linux. These are observations from reading its code, not tests of this product.

**What E3 must show**: With at least two assistants on Windows and one on macOS, a hook finds and runs the product command by absolute path, exits 0 within 5 seconds, and fails softly when the executable is missing.

**Interim proposal**: Install the package so that its command has a fixed per-user location, register hooks with the command's absolute path, and keep a fallback of syncing at the first step of a session (FR-012).

## D-009: Unreviewed pages with plain Git

**Status**: Accepted, 2026-10-13 (owner approval), with the merge-commit promotion rule now applied to spec 001 (FR-002, FR-003, FR-017). Earlier note: Proposed. E6 supports it with one required rule (merge-commit promotion). The simulation had no hosting rules.

**Proposed mechanism**: Keep a second long-lived branch that always contains the reviewed branch plus unreviewed pages. Members read from that second branch. A new page is committed and pushed to it without a pull request. A page that sits on the second branch but not on the reviewed branch counts as unreviewed. Reviewers promote pages with an ordinary pull request.

**Results of E6** (two local scripts, bare repositories as remotes, branches named `trunk` for the reviewed branch and `review` for the second one):

| Case | Result |
|---|---|
| A shares a new page | Pushed on the first try |
| Two members share different pages after fetching | Both pushed on the first try |
| **Real race**: two members commit different pages without fetching, then both push | The second push was rejected as non-fast-forward. After a fetch and merge it was pushed, and both pages were present |
| Second member shares the same path as an unreviewed page | The share was held before sending (FR-026) |
| List of unreviewed pages | `git diff --name-status` between the two branches listed exactly the three unreviewed pages |
| Squash promotion with identical content, then an edit | No conflict |
| **Squash promotion where the reviewer fixed the page while promoting**, then the author edited it | **1 conflicted file** when a member merged the reviewed branch into the second branch |
| **Merge-commit promotion where the reviewer's fix was a commit on the second branch**, then the author edited it | 0 conflicts |

**Rule that follows**: Promotion must use merge commits, and a reviewer's fixes must be committed onto the second branch before promotion. Squash or rebase merging breaks the shared history and can create a conflict that a member cannot resolve without knowing Git (Principle III).

**Consequences**:

- Setup must tell the admin to allow merge commits for the promotion pull request, and the health check should warn when the reviewed branch shows squash-style promotion. This is a change to spec 001's setup behavior and is raised as a proposal below, not applied.
- A fallback is still needed for the case where a repository only allows squash merges: for unreviewed pages, the sync keeps the member's version and reports the page, as FR-013 already requires.

**Limits of the evidence**: Local bare repositories only. No hosting rules, no pull-request tooling, no branch protection were simulated. A rebase merge was not tested. Windows and Linux were not run.

## D-010: The marker file, the local copy location and the commit checks

**Status**: Accepted, 2026-10-13 (owner approval).

These are three of the four items spec 001 left open (FR-012). The fourth, unreviewed pages, is D-009.

**Marker file** (proposed): A file named `knowledge.yaml` at the repository root with three fields: `name`, `description` and `format_version` (an integer, starting at 1). Experiments E2 and E6 used a file of this shape. A tool that reads a larger `format_version` than it knows changes nothing and tells the member to update (FR-028).

**Local copy location** (proposed): One folder per joined wiki, named by the wiki name, under a per-user data directory: `~/.knowledge/wikis/<name>` on macOS and Linux, and the user's local application data folder on Windows. The search index and the queue sit beside the working copy. The repository holds none of these paths (FR-002). Not tested on Windows.

**Commit checks of the wiki skills** (proposed, needs owner attention): The default layout of the wiki skills carries a pre-commit hook that runs Python scripts through an extra program, and Git does not carry the hook setting into a clone. Enabling it would add Python as a prerequisite and break FR-031. Proposal: this product does **not** enable those hooks. The share step runs its own checks (secret scan, path rules, collisions). The wiki skills keep their own checks when a member uses them.

## D-011: No resident process

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: The tool runs only while a command runs. There is no daemon, service or scheduler. Work that must outlive the session-start hook (finishing a slow fetch, retrying the queue of pending shares) runs in a detached finisher process started by the command, guarded by a lock file so two finishers never run together.

**Why**: Principles II and VIII (no server, simple design). A daemon needs per-system service setup and breaks the one-message install.

**Alternatives rejected**: A background service (setup cost on three systems, a new failure mode). Doing everything inside the hook (breaks the 5-second budget).

## D-012: A `skill` command serves the workflow text

**Status**: Accepted, 2026-10-13 (owner approval). The matching amendment to Principle VI is applied in constitution 1.1.0; the command is built in spec 001.

**Decision**: The command list gains one command, `skill`, which prints the workflow text that matches the installed package version. The assistant stub calls it, so text and tool never drift apart. The amendment to Principle VI that adds this command was approved by the owner on 2026-10-13 and applied as constitution 1.1.0. The command is built in spec 001, not in the skeleton.

## D-013: The tool never executes code that comes from a wiki repository

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: The tool never runs hooks, scripts, filters or helper programs from a wiki repository. It sets no `core.hooksPath` to a path inside the working copy, runs no `bin/` content of the wiki skills, and enables no Git filters or attributes that call programs. Page content and search results are untrusted data: the workflow text tells the assistant to treat them as information and never as instructions.

**Why**: A wiki is written by many members, so its content is an attack path into every member's machine and assistant (see the threat model). This also supports D-010, which already declines the wiki skills' commit hooks.

## D-014: First-class assistants are Claude Code, KiroCrew and Qoder

**Status**: Accepted, 2026-10-13 (owner approval), except the Windows behavior of the three hooks, which stays draft until E3 reports.

**Decision**: Three assistants are supported with a session-start step each (Claude Code `SessionStart`, KiroCrew `AgentSpawn`, Qoder hooks). Other assistants use the fallback: sync at the first step of a session (D-008). Windows behavior of all three hooks remains unproven (E3).

## D-015: Share runs in a fixed order

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: Share runs these steps in order: (1) secret scan with the fixed rules (D-007), (2) path normalisation and collision check against the current team version (D-006, D-009), (3) commit and push, (4) on a push that cannot complete, store the share in the local queue and retry at the next command. A failed step stops the later steps and reports the reason. A colliding page is held for the member and never renamed.

## D-016: One failing wiki never blocks the others

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: During sync, if the fetch of one wiki fails or exceeds its share of the 5-second budget (D-004), the tool keeps that wiki's existing copy, marks it stale in the output, and continues with the other wikis. The finisher process (D-011) completes the slow fetch afterwards.

## D-017: The search index is disposable

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: If the index is missing, damaged or built by a different index version, the tool rebuilds it from the pages in the working copy without asking the member. The index is never a source of truth (Principle II). Search results during a rebuild come from a full scan or a clear "rebuilding" message.

## D-018: The first threat list has five items

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: The threat model starts with these threats, each with a mitigation and a test: (1) a forged installer or update, mitigated by D-005; (2) instructions hidden in a wiki page aimed at the assistant, mitigated by D-013; (3) a secret leaking through share, mitigated by D-007 and D-015; (4) path traversal through a crafted page path, mitigated by D-006, the path rules in `domain/policy` and the path factory in `domain/factory` (D-038); (5) a removed member who still holds a local copy, mitigated by documenting that history already cloned cannot be recalled and that revoking access stops future sync. Further threats may be added during implementation of the threat model document.

## D-019: Setup can create a wiki in an empty repository

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: When the repository has no commits, setup creates the first commit on the default branch (the host's default, or `main` if none is set). The commit holds the marker file, the starting layout the admin chose and the contributor guide. Setup then pushes it and creates the branch for unreviewed pages from that commit. The admin does not need to add a file first.

## D-020: Setup checks write access before changing anything

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: Setup checks that the member can write to the repository before it creates or changes anything. If the member cannot, setup stops, changes nothing, and tells the member what to ask the repository admin for (write access, or permission to push the first commit and the unreviewed-pages branch). The same rule applies when a host rule blocks the first push.

## D-021: Join stops on a name clash

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: When the name in the marker file matches a wiki already joined on the machine but the repository URL differs, join stops, changes nothing, and asks the member what to do. It never overwrites the existing wiki's local copy.

## D-022: Join refuses a repository with no marker file

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: When the repository has no marker file, join refuses and tells the member to ask the admin to run setup or adopt (FR-003 of spec 001). It does not join silently or with only a warning.

## D-023: One lock per wiki

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: Sync and share take a lock per wiki. If a second command finds the lock held, it skips that wiki, says so, and carries on with the others. The lock is released when the holder exits, and a lock left by a dead process is detected and ignored.

## D-024: Uninstall is documentation only

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: There is no uninstall command. The documentation lists the steps to remove the package, the assistant stub and the session-start step. The tool never deletes a local copy of a wiki by itself, because it may hold changes not yet shared.

## D-025: CI runs on three systems from the first commit

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: The skeleton's automation runs build, the check command and the end-to-end test on macOS, Linux and Windows from the start. Results for Linux and Windows that CI cannot give (for example assistant session-start hooks, see E3) come from runs on real machines by the project owner, who will clone this repository to run them. Tasks that wait on those results are listed in the next section.

## D-026: A version mismatch stops the stub

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: When the stub and the package are different versions and cannot work together, the stub stops, changes nothing, and tells the member how to update. It does not update by itself (FR-032 of spec 000: updates happen when the member asks).

## Work waiting on real-machine results

The project owner will run these on Linux and Windows machines. Every one of them must be reported back to the owner when its task comes up.

| Item | Needs |
|---|---|
| E3: session-start hooks of Claude Code, KiroCrew and Qoder on Windows | Windows machine, the three assistants |
| E2 (sync timing), E4 (executable size and start time), E7 (path and Unicode behavior) on Linux and Windows | Linux and Windows machines, the experiment scripts |
| Share, sync, join and setup end-to-end checks on Linux and Windows beyond CI | Linux and Windows machines |
| D-008 (hook fallback) stays a draft until E3 reports | E3 result |

## D-027: Release signing uses Sigstore keyless (owner choice)

**Status**: Accepted pending experiment E9, 2026-10-13 (owner approval). If E9 fails, the decision returns to the owner.

**Decision** (owner choice, scheme details proposed): The release workflow signs the checksum file with Sigstore keyless signing, tied to the identity of the release workflow. The recommendation was an ed25519 key checked with the Go standard library; the owner chose Sigstore instead.

**Consequences that need a decision before the installer is built**:

- Checking a Sigstore signature in the installer needs either a Sigstore verification library (the npm `sigstore` package, which adds a dependency tree to the product) or the `cosign` program (a new prerequisite). With the TypeScript choice (D-002) the library route is the natural one; its size and its network use still need the E9 measurement.
- Verification needs network access to public Sigstore services at install time, and the signing identity is tied to the hosting platform of the release workflow.
- The installer message must carry the expected signer identity instead of a public key.

**Required next step**: Experiment E9 now tests the package route of D-036: publish a test package with provenance, check it with `npm audit signatures`, and confirm that a tampered package or a missing attestation is rejected. It also compares this with checking a signature inside the installer (library or `cosign`) on size, start time, prerequisite and offline behavior. Until E9 reports, the verification method stays open and D-005 stays proposed. We believe npm provenance is built on Sigstore, but this is not yet tested. If the cost is too high, the owner may revisit this choice.

## D-028: Three business roles, taken from repository rights

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: The business architecture names three roles: Admin, Member and Reviewer. Each role is a set of repository rights on the host. The tool stores no role.

## D-029: Review happens on the host

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: Reviewing a Proposal and promoting unreviewed pages happen on the host (pull requests), outside the tool. The tool creates a Proposal and reports its status.

## D-030: Each business rule is written once

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: Each business rule appears once in the business architecture document, with links to the requirement of spec 001 and the test that proves it. Other documents link to the rule and never copy it.

## D-031: Dependencies come from a committed lock file and are checked

**Status**: Accepted, 2026-10-13 (owner choice).

**Decision**: The package lock file is committed, installs in CI use the lock file only (`npm ci`), and the published bundle includes its dependencies so a member's machine installs nothing at run time. A dependency audit runs in CI. Note for D-027: a Sigstore library brings a large dependency tree into the lock file, which belongs in the E9 comparison. The earlier idea of a committed `vendor` folder applied to Go and is dropped. The owner confirmed this lock-file rule on 2026-10-13.

## D-032: Code checks are the type check, the formatter check, tests and the dependency-direction check

**Status**: Accepted, 2026-10-13 (owner choice).

**Decision**: The check command runs the TypeScript type check, a formatter check, the unit tests and the project's own dependency-direction check. Tests use the same tool as the reference project (`vitest`) and the bundle uses `tsup`. No extra external linter is added. The owner confirmed these check tools on 2026-10-13.

## D-033: Two version numbers

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: The package uses semantic versioning. The marker's `format_version` (D-010) is a separate whole number that changes only when the repository format changes. A tool that reads a larger `format_version` than it knows changes nothing and tells the member to update.

## D-034: Workflow text is embedded in the package

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: The workflow text is embedded in the bundle at build time, so the `skill` command (D-012) always prints text that matches the running version. The text is not downloaded from a server.

## D-035: Clean Architecture with four layers (owner choice)

**Status**: Accepted, 2026-10-13 (owner choice).

**Decision** (owner choice, 2026-10-13): The project structure follows Clean Architecture. The layers are `domain`, `application` (use cases and ports), `infrastructure` (driven adapters) and `infrastructure.cli` (the driving adapter and composition root). Dependencies point inward only. Folders are grouped by layer first. Inside `domain` the folders are `policy/` and `factory/` (D-038); inside `infrastructure` and `infrastructure.cli` they are grouped by feature (the owner tried a flat layout and chose to keep subfolders, 2026-10-13). In `application`, all use cases are files in one folder, `src/application/usecase/`, with no subfolders (owner choice), and the ports are in `src/application/ports/`. Search rules (bigram tokeniser, ranking, adjacency) live in `domain`; the index store is a port in `application` with an adapter in `infrastructure`. Use cases take ports through their constructors. The DI framework is `tsyringe` with explicit tokens and the `reflect-metadata` polyfill, used only in `infrastructure.cli`.

**Owner choices that changed the first proposal**: the proposal was three layers with `cli` merged into `infrastructure`, and no DI framework; the owner chose a separate fourth layer named `infrastructure.cli` and a DI framework.

**Trade-offs accepted**:

- More layers and interfaces for a command-line tool of this size, which pulls against Principle VIII (Simple Design). Recorded in Complexity Tracking in plan.md.
- Two more dependencies (`tsyringe`, `reflect-metadata`) in the supply chain (D-031).
- `tsyringe` expects decorator metadata, which the bundler does not emit. The decision keeps decorators out of `domain` and `application`: ports use explicit tokens and the container registers adapters with factory functions in `infrastructure.cli/container.ts`. The skeleton must prove that the bundled build works this way (task T052).

**Review triggers**: reopen if the layer count slows contributors (US4 test fails), or if the bundle with `tsyringe` fails on any of the three systems.

## D-036: Members get the product as an npm package (owner choice)

**Status**: Accepted pending experiment E9, 2026-10-13 (owner approval). If E9 fails, the decision returns to the owner.

**Decision** (owner choice, 2026-10-13): The product is published as a package on the npm registry, with provenance, and installed with the package manager that comes with Node.js. This is the same route as the reference project. The one-message install (FR-001) has the assistant run the install command after the prerequisite check of D-037.

**Why**: The package manager already checks the integrity of what it downloads, so the project does not write download and checksum code of its own. Provenance gives the signed publisher attestation that D-005 and D-027 need.

**Consequences**:

- A public or private registry account and a publishing workflow are needed. This is a new owner task (T030 of tasks.md).
- Whether the registry's integrity data plus provenance fully meets FR-029 (stop with a message and install nothing) is tested in E9.
- The bundle is no longer a standalone executable: the words "executable" in earlier records refer to the original Go proposal.
- Hook paths (D-008) point at the command that the package manager places on the member's machine. E3 must check that these paths work on Windows.

**Review triggers**: reopen if E9 fails, or if the registry cannot be used by the team.

## D-037: Prerequisites are checked by the install message, not by the product

**Status**: Accepted, 2026-10-13 (owner approval).

**Decision**: The install message tells the assistant to run `git --version` and `node --version` first. If either is missing, or Node.js is older than the minimum version, the assistant reports what is missing and the exact step to fix it, and installs nothing until it is fixed. The product cannot check for a missing Node.js itself, because it needs Node.js to run. The minimum Node.js version is the oldest long-term-support release at the time of the first release (decided in T026 of tasks.md).

**Why**: FR-031 allows a runtime prerequisite only if the installer checks for it first and reports exactly what to install. In this design "the installer" is the install message and the steps the assistant runs from it (the one-message install of FR-001), not code inside the package.

## D-038: Domain has policies and factories, and use cases build objects only through factories (owner choice)

**Status**: Accepted, 2026-10-13 (owner choice).

**Decision** (owner choice, 2026-10-13): `src/domain/` has two folders instead of the feature folders wiki, search and share: `policy/` (decision rules) and `factory/` (domain objects with a validity rule are defined and built there). Use cases create every domain object that has a validity rule, or that is built from outside input, through a factory, never directly. Simple value objects (immutable data with no validity rule that never comes from untrusted input, for example a count or a status label) need no factory (owner relaxation, 2026-10-13). There is no separate `entity` folder: entity types live in `factory/`.

**Mechanism** (so that `tools/check` can enforce the rule): a domain object with a validity rule is a class, or a branded type, whose constructor is not exported outside `domain/factory/`, so the only way to get one is a factory function. `tools/check` fails any construction of such an object outside `domain/factory/`. A simple value object is marked with the comment `simple-value` on its declaration; the check allows construction of marked types anywhere, and a reviewer confirms the mark in the pull request.

**Why**: Wiki content is untrusted (D-013). A factory is the one place where raw input (a path, a marker file, a page) becomes a valid domain object, which answers the path traversal threat of D-018 and the format version rule of FR-028 once, in one place.

**Owner choices that changed the first proposal**: the review suggested a third folder `domain/entity`; the owner chose to keep entities in `factory/`. The owner first asked for a factory for every domain object and then relaxed it for simple value objects, after the analysis showed that a factory for objects without a validity rule is not justified by a current requirement (Principle VIII).

**Trade-offs accepted**:

- A factory for every object with a validity rule adds indirection (Principle VIII). It is recorded in Complexity Tracking and justified by the untrusted-input boundary of D-013 and the rules of D-018 and FR-028.
- The line between "simple value" and "has a validity rule" is a judgement. The `simple-value` mark makes it visible, and a reviewer checks it.
- Without an `entity` folder, `factory/` holds both the object definitions and the code that builds them, and `policy` depends on `factory` types. To avoid a cycle, `policy` may import types only from `factory`, and `factory` may import policy rules.
- Factories take any outside value (time, identifiers) as parameters, because `domain` cannot use ports.
- Feature grouping (wiki, search, share) is no longer visible in folders; file names in `policy/` and `factory/` carry it.

**Review triggers**: reopen if `factory/` grows beyond a size reviewers can navigate (US4 test), or if the type-only import rule between `policy` and `factory` causes repeated check failures.

## D-039: Diagram standard for the architecture documents (owner choice)

**Status**: Accepted, 2026-10-13 (owner choice).

**Decision**: The documents in `architecture/` use a fixed set of Mermaid diagrams, each answering one question:

| Diagram | Question it answers | Document |
|---|---|---|
| C4 Context (`C4Context`) | Who uses the system and what it touches outside | business-architecture.md |
| C4 Container (`C4Container`) | The main units inside, where data lives, the member's machine boundary | system-architecture.md, Parts |
| C4 Component (`C4Component`) | The four layers and the direction of dependencies | project-structure.md |
| Sequence diagram, one per flow | Who calls whom in order, with the failure branches | system-architecture.md, Data flows (setup, join, share, sync, search) |
| State diagram | How a wiki page changes status | business-architecture.md, Business rules |
| Flowchart with groups | Trust zones and where the threats cross a boundary | system-architecture.md and threat-model.md |
| One SVG figure (`diagrams/layers.svg`) | Why inner layers do not know outer layers (concentric circles) | project-structure.md |

**Rules**: One diagram answers one question. Labels are in English. Each diagram has a caption. A diagram has at most about 8 boxes. Each C4 diagram has a flowchart fallback in a collapsed block of the same document.

**Not used**: block diagram, event modeling, `C4Dynamic` and `C4Deployment`. `C4Dynamic` lists steps in order and cannot show alternative branches, which the flows need. The system runs in one place, so a deployment diagram adds nothing.

**Risks**: The C4 diagram types of Mermaid are labelled experimental, so the syntax may change and the hosting site may not render them. The fallbacks cover this. No diagram has been rendered yet; each must be checked in a renderer when it is written.

**Alternatives considered**: flowcharts only (stable, but no shared C4 vocabulary); C4 Dynamic for flows (no branches); block diagrams (manual layout, new); event modeling (needs a recent Mermaid version and fits event-driven systems).

**Review triggers**: reopen if the hosting site cannot render the C4 types, or if a diagram needs more than about 8 boxes to answer its question.

## Spec proposals raised by the experiments (FR-016)

**Status**: Both proposals were approved by the project owner on 2026-10-13 and applied to `specs/001-team-knowledge-skill/spec.md` (FR-002, FR-003, FR-017, and a new Clarifications entry that records the limits of the E6 evidence).

| Spec | Proposed change |
|---|---|
| 001 FR-002 and FR-003 (setup and adopt) | Setup tells the admin to allow merge commits for promoting unreviewed pages, and records that the repository should not force squash or rebase merging for that pull request |
| 001 FR-017 (health check) | Warn when the reviewed branch shows squash-style promotion of unreviewed pages |

## Constitution amendment proposals (FR-016)

**Status**: Both amendments below were approved by the project owner on 2026-10-13 and applied as constitution 1.1.0. A follow-up wording change, Principle V "Pull" to "Sync", was approved afterwards and applied as constitution 1.1.1.

The clarified spec conflicted with the wording of Principle IV. The table records what was proposed.

| Constitution text now | Spec 001 and 000 say | Proposed change (MINOR) |
|---|---|---|
| "using a unique file name so concurrent contributors never collide" | Pages are identified by path. A collision is held for the member, never renamed | Replace the clause with "identified by path; a colliding page is held for the member" |
| "A change to an existing page MUST go through a pull request" | A change to a page in the main line needs a proposal. A change to an unreviewed page, based on the current team version, is sent directly | Say "a change to a reviewed page" and add the rule for unreviewed pages |
| Principle VI lists seven commands: setup, join, pull, search, share, status, doctor | Spec 001 and the architecture call the action "sync" (FR-012). D-012 serves workflow text by version through the tool | Rename `pull` to `sync` and add an eighth command, `skill` (MINOR, one amendment). The `skill` command is built in spec 001 after approval, not in the skeleton |

## Open decisions for the owner

Decided on 2026-10-13 (T004): D-001 to D-038 are accepted, except as listed below.

1. Still open: Provide Windows and Linux machines, or approve a cloud alternative, to run E3 and the Windows and Linux parts of E2, E4 and E7. D-008 and the Windows part of D-014 stay draft until E3 reports.
2. Still open: Provide the npm registry account and publishing permission for E9. D-005, D-027 and D-036 are accepted pending E9 and return to the owner if E9 fails.
3. Done: the false-alarm threshold for D-007 (at most 3% of clean pages, zero missed seeded secrets) is accepted.
4. Done: the two spec proposals from E6 are applied to spec 001 (T006).
5. Done: the amendments to Principles IV, V and VI are applied (constitution 1.1.1).
6. Conditional: D-003, D-004 and D-006 are accepted on macOS evidence and must be re-measured in Node (tasks for the 5-second budget, the E1 rerun and the Unicode test set).
