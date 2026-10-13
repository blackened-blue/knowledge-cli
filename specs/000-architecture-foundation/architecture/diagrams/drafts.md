# Diagram Drafts

**Status**: Temporary working file. These drafts follow decision D-039 and have **not been rendered or checked yet**. Open this file in a Mermaid renderer (GitHub preview or an editor) and check each diagram. When the real documents in `architecture/` are written (tasks T011, T012, T015, T017, T020, T036), move each diagram there and delete this file.

Labels are in English. Names of files and folders are examples only.

## 1. C4 Context (goes to business-architecture.md)

```mermaid
C4Context
  title System Context for knowledge-cli

  Person(member, "Member", "Asks the assistant to share, search and sync pages")
  Person(admin, "Admin", "Creates the wiki repository and sets merge rules")
  Person(reviewer, "Reviewer", "Approves proposals on the host")
  System(kc, "knowledge-cli", "Shared team wiki on top of one Git repository")
  System_Ext(assistant, "AI assistant", "Runs commands and loads the skill")
  System_Ext(host, "Git host", "Holds each team's wiki repository")
  System_Ext(registry, "npm registry", "Install and update of the package")

  Rel(member, assistant, "Talks to")
  Rel(assistant, kc, "Runs commands")
  Rel(kc, host, "Fetches and pushes pages")
  Rel(registry, kc, "Install and update, when the member asks")
  Rel(admin, host, "Creates repository, sets merge rules")
  Rel(reviewer, host, "Reviews proposals")
```

<details>
<summary>Fallback (flowchart)</summary>

```mermaid
flowchart LR
  MEM(["Member"])
  ADM(["Admin"])
  REV(["Reviewer"])
  AST["AI assistant"]
  KC["knowledge-cli"]
  HOST["Git host"]
  REG["npm registry"]
  MEM -- "talks to" --> AST
  AST -- "runs commands" --> KC
  KC -- "fetch and push pages" --> HOST
  REG -- "install and update, when the member asks" --> KC
  ADM -- "creates repository, sets merge rules" --> HOST
  REV -- "reviews proposals" --> HOST
```

</details>

Caption: knowledge-cli touches three things outside itself: the AI assistant that runs its commands, the Git host that holds the wiki, and the npm registry at install and update. It sends no usage data anywhere.

## 2. C4 Container (goes to system-architecture.md, Parts)

```mermaid
C4Container
  title Containers of knowledge-cli

  System_Ext(assistant, "AI assistant", "Runs commands and loads the skill")
  System_Ext(host, "Git host", "Wiki repository: main line and unreviewed-pages branch")
  System_Ext(registry, "npm registry", "Package install and update")

  Container_Boundary(machine, "Member's machine") {
    Container(skill, "Skill stub", "Markdown", "Thin; loads the workflow text from the package")
    Container(cli, "knowledge package", "TypeScript on Node.js", "Runs per command, no daemon")
    ContainerDb(data, "Local data", "Files", "Working copy, search index, share queue, log")
  }

  Rel(assistant, skill, "Loads")
  Rel(skill, cli, "Runs")
  Rel(cli, data, "Reads and writes")
  Rel(cli, host, "Fetch and push through the installed Git program", "Page content is untrusted data")
  Rel(registry, cli, "Install and update")
```

<details>
<summary>Fallback (flowchart)</summary>

```mermaid
flowchart LR
  AST["AI assistant"]
  subgraph MACHINE["Member's machine"]
    SKILL["Skill stub"]
    CLI["knowledge package"]
    DATA[("Local data: working copy, index, queue, log")]
  end
  HOST["Git host: wiki repository"]
  REG["npm registry"]
  AST -- "loads" --> SKILL
  SKILL -- "runs" --> CLI
  CLI -- "reads and writes" --> DATA
  CLI -- "fetch and push (page content is untrusted data)" --> HOST
  REG -- "install and update" --> CLI
```

</details>

Caption: Everything inside the member's machine can be rebuilt or sent again. The wiki repository on the Git host is the only source of truth.

## 3. C4 Component (goes to project-structure.md)

```mermaid
C4Component
  title Components of the knowledge package

  Container_Boundary(pkg, "knowledge package") {
    Component(cliLayer, "infrastructure.cli", "TypeScript", "Commands, output, container (composition root)")
    Component(infraLayer, "infrastructure", "TypeScript", "Git, platform, index, release, log adapters")
    Component(appLayer, "application", "TypeScript", "Use cases and ports")
    Component(domLayer, "domain", "TypeScript", "Policy and factory, no IO")
  }

  Rel(cliLayer, appLayer, "Calls use cases")
  Rel(cliLayer, infraLayer, "Registers adapters")
  Rel(infraLayer, appLayer, "Implements ports")
  Rel(appLayer, domLayer, "Builds objects and asks rules")

  UpdateElementStyle(cliLayer, $bgColor="#cfe8ff", $fontColor="#0b2a4a", $borderColor="#0b5394")
  UpdateElementStyle(infraLayer, $bgColor="#ffe0b2", $fontColor="#4a2500", $borderColor="#b45309")
  UpdateElementStyle(appLayer, $bgColor="#c8e6c9", $fontColor="#0d2e12", $borderColor="#1b5e20")
  UpdateElementStyle(domLayer, $bgColor="#e1bee7", $fontColor="#2a0a3a", $borderColor="#6a1b9a")
```

<details>
<summary>Fallback (flowchart)</summary>

```mermaid
flowchart LR
  CLI["CLI: receives commands, wires everything"]
  APP["Application: steps of each task"]
  DOM["Domain: pure rules, no IO"]
  INF["Infrastructure: Git, files, network"]
  CLI -- "calls" --> APP
  APP -- "uses" --> DOM
  INF -- "serves" --> APP
  CLI -- "plugs in" --> INF
```

</details>

Caption: Dependencies point inward only. The domain knows no other layer. Only infrastructure.cli registers adapters in the container.

![Layers of knowledge-cli as concentric circles](layers.svg)

## 4. Sequence: share a page (goes to system-architecture.md, Data flows)

```mermaid
sequenceDiagram
  actor M as Member
  participant A as AI assistant
  participant C as CLI layer
  participant U as Share use case
  participant D as Domain (policy, factory)
  participant G as Git adapter
  participant H as Git host

  M->>A: Share this page
  A->>C: share (preview first)
  C->>U: share request
  U->>D: build the page, scan for secrets
  alt secret suspected
    U-->>C: warn and ask for a second confirmation
  end
  U->>D: check the path against the team version
  alt path exists in the main line
    U-->>C: treat as a proposal against the existing page
  else path exists on the unreviewed branch, or not based on the current team version
    U-->>C: hold the page and recommend an action
  else new path
    U->>G: commit to the unreviewed-pages branch
    G->>H: push
    alt network unavailable
      G-->>U: push failed
      U->>U: store the share in the queue
    else push accepted
      H-->>G: ok
    end
  end
  C-->>A: result
  A-->>M: result
```

Caption: A new page reaches the team without review. A page whose path is taken is held or sent as a proposal and never renamed. A failed push goes to the queue and is retried at the next command.

## 5. State: a wiki page (goes to business-architecture.md, Business rules)

```mermaid
stateDiagram-v2
  [*] --> LocalDraft: member writes a page
  LocalDraft --> Unreviewed: shared as a new page
  LocalDraft --> Queued: network unavailable
  LocalDraft --> Held: path already taken
  Queued --> Unreviewed: sent later
  Queued --> Held: path now taken on the team side
  Held --> Proposed: member sends a proposal
  Held --> LocalDraft: member changes the path
  Held --> [*]: member discards the page
  Unreviewed --> Unreviewed: edit based on the current team version
  Unreviewed --> InMainLine: reviewer promotes it with a merge commit
  InMainLine --> Proposed: a change needs a proposal
  Proposed --> InMainLine: reviewer approves
  Proposed --> Rejected: reviewer rejects
  Rejected --> LocalDraft: stays in the local copy as a local edit
```

Caption: Only reviewers move a page into the main line. A rejected proposal never deletes the member's version.

## 6. Trust zones (goes to system-architecture.md and threat-model.md)

```mermaid
flowchart LR
  subgraph Z1["Zone 1: member's machine (trusted)"]
    CLI["knowledge package"]
    DATA[("Local data")]
  end
  subgraph Z2["Zone 2: AI assistant (runs commands, must not obey page text)"]
    AST["AI assistant"]
  end
  subgraph Z3["Zone 3: Git host and wiki content (untrusted data)"]
    HOST["Wiki repository"]
  end
  subgraph Z4["Zone 4: release channel"]
    REG["npm registry"]
  end

  REG -- "T1 forged installer or update" --> CLI
  HOST -- "T4 crafted page path" --> CLI
  CLI -- "T2 hidden instructions in results" --> AST
  CLI -- "T3 secret leaks through share" --> HOST
  HOST -. "T5 removed member keeps an old copy" .-> DATA
  CLI --- DATA
```

Caption: Threats T1 to T5 are the first five of D-018. Page content and search results cross into the assistant as data, never as instructions (D-013).
