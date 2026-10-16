# E9: package provenance

Throwaway test package for experiment E9 (task T029, decisions D-005, D-027, D-036). It is not the product.

## Publish (owner runs the tag, the workflow publishes)

Each publish needs a new version. Edit `version` in `package.json`, commit to `speckit`, then:

```text
git tag e9-0.0.1 <commit>
git push origin e9-0.0.1
```

The workflow is `.github/workflows/e9-publish.yml` on the `speckit` branch. It needs the repository secret `NPM_TOKEN`. A published version cannot be reused, so bump the version for every retry.

## What E9 must record (FR-029)

1. Whether npm accepts a provenance publish from a workflow that is not on the default branch (`main`).
2. `npm audit signatures` in a clean folder after installing the package: passes for the real package.
3. A tampered tarball (one byte changed) is rejected and nothing is installed.
4. A package without an attestation is detected, and the install stops with a message.
5. Size, start time, prerequisites and offline behavior of this route against a signature check inside the installer (library or `cosign`).
6. Delete the test tag and this workflow when the result is recorded under D-027 and D-036.
