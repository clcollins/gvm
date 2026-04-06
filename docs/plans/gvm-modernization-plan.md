# GVM Modernization Plan

## Overview

This repository is a fork of [moovweb/gvm](https://github.com/moovweb/gvm), a Go Version Manager written in bash. The upstream project was abandoned in August 2023 (last commit: 2023-08-14). No maintenance, review activity, or response to pull requests has occurred since.

This fork is now independently maintained by [Chris Collins](https://github.com/clcollins). A deep analysis of the codebase revealed critical bugs, security issues, dead infrastructure, and modernization opportunities. This plan tracks the work needed to establish independent ownership, fix bugs, and bring the project up to date with modern Go (1.22+).

## Current State Assessment

- **License**: MIT -- permits forking, modification, and redistribution
- **Tests**: 11 test files using Ruby `tf` framework, ~30% feature coverage, 3 tests with no assertions
- **CI**: Travis CI (dead), no GitHub Actions
- **Bugs**: Syntax errors in pkgset-use and find_local_pkgset, broken shell compatibility
- **Security**: No checksum verification on binary Go downloads
- **Ownership**: Multiple files still reference moovweb

## Phases

### Phase 1: Ownership Divorce

- **ISSUE_1**: Replace moovweb ownership references throughout codebase

### Phase 2: Critical Bug Fixes

- **ISSUE_2**: Fix syntax errors in pkgset-use and find_local_pkgset
- **ISSUE_3**: Fix shell compatibility and quoting issues
- **ISSUE_4**: Add SHA256 checksum verification for binary downloads

### Phase 3: Infrastructure Cleanup

- **ISSUE_5**: Remove dead infrastructure files (.travis.yml, Vagrantfile, Gemfile, Rakefile)
- **ISSUE_6**: Add GitHub Actions CI and repository scaffolding
- **ISSUE_7**: Migrate test framework from Ruby tf to bats-core

### Phase 4: Modernization

- **ISSUE_8**: Remove legacy package managers and deprecate gvm cross
- **ISSUE_9**: Make --prefer-binary the default installation behavior
- **ISSUE_10**: Add go.work workspace support

## Issue Details

### ISSUE_1: Replace moovweb ownership references throughout codebase

**Priority**: 1 (do first)

Files to update:
- `binscripts/gvm-installer:58` -- `SRC_REPO` default URL
- `scripts/pkgset:20` -- comment URL
- `scripts/alias:13` -- comment URL
- `scripts/linkthis:12` -- example referencing `github.com/moovweb/gpkg`
- `scripts/install:256` -- `github.com/moovweb/gpkg` go install reference
- `extra/DEBIAN/control:4` -- maintainer email
- `AUTHORS` -- add current maintainer
- `LICENSE` -- preserve original copyright, add clcollins copyright line

Files to delete:
- `config/sources` -- contains `git://github.com/moovweb`, unreferenced by any script

Files to leave unchanged:
- `ChangeLog` -- historical record

**Acceptance criteria**: `grep -r moovweb` returns zero results outside ChangeLog.

---

### ISSUE_2: Fix syntax errors in pkgset-use and find_local_pkgset

**Priority**: 2 (critical bugs)

1. `scripts/env/pkgset-use:92` -- mismatched brackets in elif:
   ```
   elif [[ "${local_pkgset_rematch}" == true ]] && $(( ${#accumulator[@]}%2 )) -eq 0 ]]; then
   ```
   Missing opening `[[` before arithmetic test. The `$((` creates a command substitution instead of an arithmetic comparison inside `[[ ]]`.

2. `scripts/function/find_local_pkgset:7,13` -- broken PWD assignment:
   ```
   PWD= /bin/pwd
   ```
   Sets PWD to empty and runs `/bin/pwd` as a separate command. Should be `PWD=$(/bin/pwd)`. The function never returns the current directory when `.gvm_local` is found.

**Note**: `scripts/env/cd:109` calling `__gvmp_find_closest_dot_go_version` is NOT a bug -- the function is defined at line 163 of the same file and resolves correctly at call time.

**Acceptance criteria**: `bash -n` on both files exits 0; `find_local_pkgset` correctly returns directory containing `.gvm_local`.

---

### ISSUE_3: Fix shell compatibility and quoting issues

**Priority**: 2 (bugs)

1. `binscripts/gvm-installer:117` -- uses `finger` command (deprecated, missing on modern macOS). Replace with `dscl . -read /Users/$(id -u -n) UserShell | awk '{print $2}'`.

2. `binscripts/gvm-installer:23,68` -- uses `which` instead of `command -v`. `which` is not POSIX and behaves inconsistently.

3. `scripts/function/extract_version:8` -- unquoted `$1` in grep: `if [ $(echo $1 | grep release) ]`. Should be `if echo "$1" | grep -q "release"`.

4. `scripts/function/display_{error,message,warning,fatal}` -- TERM check uses exact match `$TERM == "xterm"`. Most modern terminals report `xterm-256color`. Change to pattern match: `$TERM == xterm*`.

5. `scripts/env/applymod` -- unquoted variables in grep patterns (lines 11, 15). Risk of glob expansion and word splitting.

6. Audit all scripts for additional unquoted variable expansions in dangerous contexts.

**Acceptance criteria**: `gvm-installer` works on macOS without `finger`; colors work in `xterm-256color` terminals; `shellcheck` reports no critical warnings on modified files.

---

### ISSUE_4: Add SHA256 checksum verification for binary downloads

**Priority**: 2 (security)

`scripts/install` downloads Go binaries via curl with no integrity verification. Go publishes SHA256 checksums alongside binaries at `https://dl.google.com/go/<filename>.sha256`.

Implementation:
1. After downloading tarball, download corresponding `.sha256` file
2. Verify with `sha256sum -c` (Linux) or `shasum -a 256 -c` (macOS)
3. Fail with clear error if verification fails; remove corrupt download
4. Add `--skip-checksum` flag for edge cases (corporate proxies, etc.)

**Acceptance criteria**: Binary downloads are verified; checksum mismatch produces clear error; `--skip-checksum` bypasses with a warning.

---

### ISSUE_5: Remove dead infrastructure files

**Priority**: 3 (cleanup)

Delete:
- `.travis.yml` -- Travis CI is dead
- `Vagrantfile` -- targets Ubuntu 12.04 (Precise Pangolin), EOL since 2017
- `Gemfile` -- only existed for Ruby `tf` test framework
- `Rakefile` -- test runner for `tf`; replaced by bats in Issue 7

**Acceptance criteria**: Files deleted, no Ruby dependencies remain.

---

### ISSUE_6: Add GitHub Actions CI and repository scaffolding

**Priority**: 3 (infrastructure)
**Depends on**: ISSUE_7 (bats migration, for test runner)

Create:
- `.github/workflows/ci.yml` -- CI on push to main + PRs; Ubuntu + macOS matrix; runs shellcheck + bats
- `.github/CODEOWNERS` -- `* @clcollins`
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `.github/pull_request_template.md`

**Acceptance criteria**: CI runs on every PR and push to main; shellcheck and bats execute in CI.

---

### ISSUE_7: Migrate test framework from Ruby tf to bats-core

**Priority**: 3 (testing)

Steps:
1. Create bats test structure (`tests/test_helper.bash`, `tests/*.bats`)
2. Port existing 11 `*_comment_test.sh` files to bats format
3. Add real assertions to 3 empty tests (gvm_list, gvm_listall, gvm_version)
4. Add new pkgset lifecycle tests (create, use, list, empty, delete)
5. Add error handling tests (invalid version, missing Go)
6. Remove old tf test files and `tests/scenario/` directory

**Acceptance criteria**: `bats tests/` runs successfully; existing coverage preserved; pkgset and error tests added.

---

### ISSUE_8: Remove legacy package managers and deprecate gvm cross

**Priority**: 4 (modernization)
**Depends on**: ISSUE_1 (to avoid merge conflicts on same moovweb lines)

1. Remove `install_gpkg()`, `install_gb()`, `install_goprotobuf()` from `scripts/install` (lines 254-295). These install from dead URLs.
2. Remove `--with-protobuf` and `--with-build-tools` flags from install.
3. Add deprecation warning to `scripts/cross` pointing users to `GOOS=X GOARCH=Y go build`.
4. Remove Mercurial references from docs and scripts (Go uses git exclusively now).

**Acceptance criteria**: Legacy install functions removed; `gvm cross` prints deprecation warning; no Mercurial references remain.

---

### ISSUE_9: Make --prefer-binary the default installation behavior

**Priority**: 4 (modernization)

Currently `gvm install go1.X` compiles from source (6-10 minutes). Binary download takes ~10 seconds. Most users want binaries.

Changes:
1. `gvm install go1.X` with no flags attempts binary first, falls back to source
2. Add `--source` flag for explicit source compilation
3. `--prefer-binary` becomes a no-op (now the default)
4. `-B`/`--binary` still works (binary-only, no fallback)
5. Add `toolchain` directive parsing from `go.mod` to `gvm applymod` (Go 1.22+ feature)

**Acceptance criteria**: Default install tries binary first; `--source` forces source; `gvm applymod` reads `toolchain go1.X.Y` from go.mod.

---

### ISSUE_10: Add go.work workspace support

**Priority**: 4 (modernization)

Go 1.18+ supports workspace files (`go.work`). GVM should recognize them:
1. `gvm applymod` checks `go.work` for version info when present
2. `cd` override detects `go.work` alongside `.go-version`
3. Documentation mentions `go.work` support

**Acceptance criteria**: `gvm applymod` reads version from `go.work`; documented.

## Dependency Graph

```
ISSUE_1 (ownership) ─────────────────────────────> ISSUE_8 (legacy removal)
ISSUE_2 (syntax bugs)      [independent]
ISSUE_3 (shell compat)     [independent]
ISSUE_4 (checksums)         [independent]
ISSUE_5 (dead files)        [independent]
ISSUE_7 (bats migration) ──────────────────────────> ISSUE_6 (GitHub Actions CI)
ISSUE_9 (binary default)   [independent]
ISSUE_10 (go.work)          [independent]
```

Issues 1-5, 7, 9, 10 can all be worked independently. Issue 6 should land after Issue 7. Issue 8 should land after Issue 1.

## Definition of Done

- [ ] All moovweb references replaced (except ChangeLog)
- [ ] Critical syntax errors fixed (pkgset-use, find_local_pkgset)
- [ ] Shell compatibility issues resolved
- [ ] Binary downloads verified with SHA256
- [ ] Dead infrastructure removed
- [ ] GitHub Actions CI running
- [ ] Test framework migrated to bats with expanded coverage
- [ ] Legacy package managers removed
- [ ] Binary-first installation is the default
- [ ] go.work workspace support added
