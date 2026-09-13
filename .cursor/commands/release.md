# Tag and push a release

Guide and execute the end-to-end release process for TapBeat using semantic versioning and GitHub Actions. This command follows the release procedure documented in `AGENTS.md` and modeled on the steps performed in the release workflow.

## Overview

TapBeat releases are automated via GitHub Actions triggered by pushing a version tag matching `v*`. The release workflow (`.github/workflows/release.yml`) validates iOS and watchOS targets, compiles a universal macOS Release binary, packages an ad-hoc signed `.app` bundle into a zip archive with SHA-256 checksum, and creates a GitHub Release with download assets.

## Invocation & Arguments

- `/release` — inspect commits since the last tag and choose the next SemVer bump
- `/release patch` — force a patch bump (`vX.Y.(Z+1)`)
- `/release minor` — force a minor bump (`vX.(Y+1).0`)
- `/release major` — force a major bump (`v(X+1).0.0`)
- `/release vX.Y.Z` (or `/release X.Y.Z`) — use an explicit version

---

## Release Procedure

Follow these steps in sequential order. Do not skip steps.

### Step 1: Pre-flight Verification & Prerequisites

1. Check current git status, branch, and upstream tracking:
   ```bash
   git status
   git branch -vv
   ```
2. Verify branch requirements:
   - Must be on `main`.
   - Must be up to date with `origin/main`.
3. Check the working tree:
   ```bash
   git status && git diff
   ```
   - If there are intentional release-related changes (e.g., workflow updates, documentation, project version updates), stage and commit them following repository commit conventions (`git log -5 --oneline --format='%s'`):
     ```bash
     git add <files>
     git commit -m "<Concise commit message>"
     git push origin HEAD
     ```
   - **CRITICAL**: All release-related commits and the release workflow file (`.github/workflows/release.yml`) **must already be pushed to `origin/main`** before creating and pushing the tag.
   - If there are uncommitted, unrelated, or unfinished changes, stop and prompt the user to stash, commit, or resolve them before proceeding.

### Step 2: Determine Semantic Version (SemVer)

1. Check existing release tags sorted by version:
   ```bash
   git tag -l 'v*' --sort=v:refname
   ```
2. Identify the latest existing tag (e.g., `v1.1.0`). If no previous tags exist, default to `v1.0.0`.
3. If an explicit version or bump level (`major`, `minor`, `patch`) was provided in the command invocation, use it.
4. Otherwise, inspect all commits since the last tag to determine the appropriate SemVer bump:
   ```bash
   LAST_TAG=$(git tag -l 'v*' --sort=v:refname | tail -1)
   git log "${LAST_TAG}..HEAD" --oneline
   ```
   Apply standard Semantic Versioning guidelines (`vMAJOR.MINOR.PATCH`):
   - **PATCH** (`vX.Y.(Z+1)`): Bug fixes, minor UI adjustments, documentation updates, dependency updates, and internal refactors.
   - **MINOR** (`vX.(Y+1).0`): New features, new platform targets (such as iOS or watchOS support), backwards-compatible enhancements.
   - **MAJOR** (`v(X+1).0.0`): Breaking changes, major architectural overhauls, or incompatible design changes.
5. Confirm the tag format:
   - Tag must be prefixed with `v` (e.g., `v1.2.0`).
   - The GitHub Actions workflow automatically strips the leading `v` to set `MARKETING_VERSION` (`VERSION="${TAG#v}"`).
   - `CURRENT_PROJECT_VERSION` is set to the GitHub Actions run number.
6. State the chosen version and a brief summary of included changes before proceeding.

### Step 3: Create and Push Annotated Git Tag

1. Create an annotated git tag (never create a lightweight tag):
   ```bash
   git tag -a v<VERSION> -m "TapBeat <VERSION>"
   ```
   Example:
   ```bash
   git tag -a v1.2.0 -m "TapBeat 1.2.0"
   ```
2. Push the annotated tag to GitHub:
   ```bash
   git push origin v<VERSION>
   ```

### Step 4: Monitor the GitHub Actions Release Workflow

1. Pushing the tag triggers the `Release` workflow in `.github/workflows/release.yml`.
2. List recent runs for the release workflow:
   ```bash
   gh run list --workflow=release.yml --limit 3
   ```
3. Watch the workflow until completion:
   ```bash
   gh run watch --exit-status $(gh run list --workflow=release.yml --limit 1 --json databaseId -q '.[0].databaseId')
   ```
4. Workflow build verification details:
   - Validates iOS simulator build (`xcodebuild -scheme TapBeat-iOS ...`).
   - Validates watchOS build (`xcodebuild -target TapBeat-Watch ...`).
   - Builds universal macOS Release binary (`arm64` and `x86_64`) with ad-hoc signing (`CODE_SIGN_IDENTITY="-"`).
   - Packages `TapBeat.app` into `TapBeat-<version>-macos.zip` with `ditto -c -k --keepParent`.
   - Computes SHA-256 checksum (`shasum -a 256`).
   - Publishes the GitHub Release with both assets.

### Step 5: Verify GitHub Release and Assets

1. Inspect the newly created GitHub Release:
   ```bash
   gh release view v<VERSION>
   ```
2. Verify the workflow run completed with success:
   ```bash
   gh run view <RUN_ID> --json conclusion,status,url -q '{conclusion,status,url}'
   ```
3. Verify required release assets are attached:
   - `TapBeat-<version>-macos.zip`
   - `TapBeat-<version>-macos.zip.sha256`
4. Report the live release URL to the user:
   `https://github.com/mattdeco/tapbeat/releases/tag/v<VERSION>`

---

## Guardrails & Prohibitions

- **Never push a tag before code is on `main`**: The release workflow and all release code must already be on the default remote branch before the tag is pushed.
- **Never force-push or retag casually**: If a tag must be moved or recreated, delete the GitHub Release first, delete the remote tag (`git push origin :refs/tags/v<VERSION>`), delete the local tag, and recreate only if explicitly instructed by the user.
- **Ad-hoc signed builds only**: Do not invent local upload mechanisms or add Apple Developer ID signing/notarization secrets unless explicitly enrolled in the paid Apple Developer Program.
- **Gatekeeper first-open caveat**: Because builds are ad-hoc signed, macOS Gatekeeper may block downloads on first run. Remind users of the documented workaround: **Control-click → Open** in Finder (or System Settings → Privacy & Security → Open Anyway).
