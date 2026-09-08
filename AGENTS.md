# Agent notes

## Shipping a release

Releases are produced by GitHub Actions when a version tag matching `v*` is pushed. Builds are **ad-hoc signed only** (no Developer ID / notarization). Do not invent a local release upload path unless the workflow is broken.

### Prerequisites

- Working tree clean (or only intentional release-related commits).
- On `main`, up to date with `origin/main`.
- The release workflow must already be on the default branch before the tag is pushed (`.github/workflows/release.yml`).

### Versioning

- Tags: `vMAJOR.MINOR.PATCH` (example: `v1.0.0`).
- The workflow strips the leading `v` and sets `MARKETING_VERSION` from the tag.
- `CURRENT_PROJECT_VERSION` is the Actions run number.
- Default local versions live in `TapBeat.xcodeproj` (`MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`); Info.plist uses `$(MARKETING_VERSION)` / `$(CURRENT_PROJECT_VERSION)`.

### Steps (in order)

1. Ensure release-related changes (workflow, docs, app) are **committed and pushed to `main`** first.
2. Choose the next semver tag. Check existing tags: `git tag -l 'v*' --sort=v:refname`.
3. Create and push the annotated tag from the commit that should ship:

   ```bash
   git tag -a v1.0.0 -m "TapBeat 1.0.0"
   git push origin v1.0.0
   ```

4. Watch the workflow: `gh run watch` or the Actions tab for the `Release` workflow.
5. Confirm the GitHub Release exists with assets:
   - `TapBeat-<version>-macos.zip`
   - `TapBeat-<version>-macos.zip.sha256`

   ```bash
   gh release view v1.0.0
   ```

### Do not

- Push a tag before the workflow file is on `main`.
- Force-push or retag casually; if a tag must be moved, delete the GitHub Release first, delete the remote tag, then recreate (only when the user explicitly asks).
- Add Apple signing/notarization secrets unless the user has enrolled in the paid Apple Developer Program and asked for that path.

### User-facing install caveat

Unsigned downloads may be blocked by Gatekeeper. README documents **Control-click → Open**. Keep that docs path accurate when changing distribution.
