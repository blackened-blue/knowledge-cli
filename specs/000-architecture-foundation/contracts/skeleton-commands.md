# Contract: Skeleton Commands

The skeleton exposes one product command and one contributor command. It holds no other product behavior (FR-023).

## Product command

```text
knowledge --version
```

| Aspect | Contract |
|---|---|
| Output | One line on standard output: the product name, then the version, for example `knowledge 0.0.0` |
| Exit code | 0 |
| Network | None |
| Layers | The command runs through every layer of the architecture, so a broken connection between layers fails it |
| Language | English (FR-018) |

Any other arguments print a short English usage message on standard error and exit with code 2. This is the only error path in the skeleton.

## Contributor command

One documented command that builds, lints and tests the skeleton (FR-021): `npm run check`. It must run the same way on macOS, Linux and Windows, so it cannot depend on a tool that Windows lacks.

| Aspect | Contract |
|---|---|
| Steps | Type check, formatter check, unit tests, dependency-direction check, build |
| Exit code | 0 only when every step passes |
| Dependency check | A forbidden dependency between components fails the command and names the dependency (FR-022) |
| Time | Under 10 minutes on a clean machine (SC-010) |

## Not in the skeleton

No setup, join, sync, search, share, status, doctor or skill behavior. Those belong to feature specs.
