# E3 Checklist: Session-Start Hooks on Windows

Task T032 in `../../tasks.md`. Decisions affected: D-008 (session-start hooks) and the Windows part of D-014 (the three first-class assistants). Effort: about one working day at most (FR-008).

## Question

On Windows, does each assistant run a hook at the start of a session, with a command that starts our product by its **absolute path**, so that the product can sync within the **5-second budget** and **never break the session**?

## Pass criteria (from D-008)

For each assistant that you test:

1. The hook runs at the start of a new session.
2. It finds and runs a command by absolute path, including a path with spaces.
3. It finishes with exit code 0 within 5 seconds.
4. When the command is missing or exits with an error, the session still opens (the hook fails softly).

D-008 can become accepted only if at least two assistants pass on Windows and one passes on macOS. Otherwise the fallback stays in force: the skill tells the assistant to sync as its first step (FR-012).

## Before you start

- A Windows 10 or 11 machine, Git for Windows, and Node.js (the probe is a Node script).
- At least two of: Claude Code, KiroCrew, Qoder. Test all three if you can.
- Copy `probe.mjs` to two places:
  - `C:\kc\probe.mjs` (no spaces)
  - `C:\Users\Test User\kc probe\probe.mjs` (spaces in the path)
- Set the log file for easy reading: `setx KC_E3_LOG "C:\kc\e3.log"` and open a new terminal. Without it the probe writes `kc-e3.log` in the temp folder.
- Delete the log before each test run. Each probe call adds two lines: one when it starts and one when it finishes.
- Note which shell starts your assistant (cmd, PowerShell or Git Bash).

## The probe

```text
node probe.mjs --label <name>             # logs, prints one line, exits 0
node probe.mjs --label <name> --sleep 7   # waits 7 seconds, to test the budget
node probe.mjs --label <name> --exit 1    # exits with an error
```

## Hook setup per assistant

Register the probe as the assistant's session-start hook. Record the exact file you edited and its content in the results table, because this is also the information the installer will need.

| Assistant | Session-start mechanism | Configuration |
|---|---|---|
| Claude Code | `SessionStart` hook | Edit the user settings file `settings.json` in the `.claude` folder of your profile. A hook entry has the form `{"hooks": {"SessionStart": [{"hooks": [{"type": "command", "command": "node \"C:\\kc\\probe.mjs\" --label claude"}]}]}}`. Check the current hooks documentation, because the format may have changed |
| KiroCrew | `AgentSpawn` hook; its standard output is added to the session context. Hooks are stored in `hooks.json` under the `.kiro\crew` folder of your profile | The file format was **not verified**. Create the hook through the KiroCrew settings if it has a screen for hooks, then open `hooks.json` and copy what it wrote |
| Qoder | Hooks (the reference project's assistant matrix lists them) | The file location and format were **not verified**. Follow the Qoder documentation and copy what worked |

## Tests

Run each test once per assistant. In "Observe" write what you saw, in "Pass?" write yes or no.

| # | Test | How | Observe | Pass? |
|---|---|---|---|---|
| 1 | The hook fires | Start a **new** session. Read the log | One start line per session? Time between starting the session and the line | |
| 2 | Path without spaces | Hook command `node "C:\kc\probe.mjs" --label nospace` | Does it run? Which shell ran it (`shellHint` in the log)? | |
| 3 | Path with spaces | Hook command `node "C:\Users\Test User\kc probe\probe.mjs" --label space` | Does it run? Was quoting needed? | |
| 4 | Slash style | Same command with forward slashes `C:/kc/probe.mjs` | Does it run? | |
| 5 | The 5-second budget | Add `--sleep 7`. Start a session and time how long until you can type | Does the session wait 7 seconds, or does the assistant stop the hook sooner? Is there a time limit setting? | |
| 6 | Failing hook | Add `--exit 1` | Does the session open? Is an error shown? | |
| 7 | Missing command | Point the hook at `C:\kc\does-not-exist.mjs` | Does the session open? Is an error shown? | |
| 8 | Standard output | Look for `knowledge-e3-probe ok` text | Is it visible to you? Is it in the assistant's context (ask the assistant what the hook printed)? | |
| 9 | Environment | Read `pathEntries`, `cwd`, `assistantEnvNames` in the log | Does the hook see the same PATH as your terminal? Is `node` found without a full path? | |
| 10 | Resumed session | Resume an older session | Does the hook fire again? Should the product sync on resume? | |

## Fallback check (any assistant)

Remove the hook. Add one line to a test skill: "As your first step in every session, run `node C:\kc\probe.mjs --label fallback`". Start a new session and check whether the assistant runs it without being asked. This tests the fallback in FR-012.

## Results

Fill in one table per assistant (copy this block), then give it to the assistant so D-008 and D-014 in `../../research.md` are updated.

| Item | Value |
|---|---|
| Assistant and version | |
| Windows version | |
| Shell used by the assistant | |
| Configuration file and content | |
| Tests 1 to 10 | pass or fail each, with notes |
| Fallback check | |
| Verdict for D-008 | pass, fail, or partly |

## After the test

Remove the hooks you added from each assistant's configuration, and delete `C:\kc` and the log if you no longer need them.
