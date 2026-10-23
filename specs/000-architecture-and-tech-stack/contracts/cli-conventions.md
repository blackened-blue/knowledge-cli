# Contract: CLI Conventions

**Spec**: [spec.md](../spec.md) | **Plan**: [plan.md](../plan.md)

These rules apply to every command, present and future. They are the public surface covered by
Principle V (text I/O) and Principle VI (versioning). Individual commands are defined by the
spec that introduces them, not here.

## Streams and exit codes

| Item | Rule |
|------|------|
| Results | written to stdout only |
| Errors | written to stderr only |
| Diagnostics (`--verbose`) | written to stderr only, never stdout |
| Exit code 0 | the command did what was asked |
| Exit code 1 | the command failed (error printed on stderr) |
| Exit code 2 | the command was used wrongly (unknown option, missing argument) |

Input comes from arguments or standard input.

## Output forms

- Default: human-readable text.
- `--json`: one JSON document on stdout and nothing else on stdout.
- A command that returns data MUST support both forms (FR-011). A command that returns nothing
  prints nothing on success in either form.

## Error message form

```text
error: <what failed>. <how to fix it>
```

One error per line, on stderr, with or without `--verbose`. A message never contains an API key
or any other secret (FR-014).

## Verbose log line

Only with `--verbose`, on stderr:

```text
LEVEL component: message key=value key=value
```

`LEVEL` is `debug`, `info`, `warn`, or `error`. `component` is the part and adapter name.

## Active team

A command that acts on a team prints the team name in its human-readable output, or includes a
`team` field in its `--json` output (FR-016).

## What counts as a breaking change (Principle VI)

These changes require a MAJOR version bump and a release-note entry:

- removing or renaming a command or an option
- changing an exit code meaning
- removing or renaming a field in `--json` output, or changing its type
- changing the error line form or the verbose line form above

Adding a command, an option, or a new `--json` field is not breaking.

## Open

The `--json` field names for each command are defined by the spec that adds the command (spec
001 onward). This file fixes only the conventions above.
