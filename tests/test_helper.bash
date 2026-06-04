#!/usr/bin/env bash

export GVM_PROJECT_ROOT
GVM_PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}" && while [[ ! -f VERSION ]] && [[ "$PWD" != "/" ]]; do cd ..; done; pwd)"

load "${GVM_PROJECT_ROOT}/tests/libs/bats-support/load"
load "${GVM_PROJECT_ROOT}/tests/libs/bats-assert/load"

setup_gvm_environment() {
    export GVM_TEST_ROOT
    GVM_TEST_ROOT="$(mktemp -d "${BATS_FILE_TMPDIR}/gvm-test.XXXXXX")"

    export GVM_NO_UPDATE_PROFILE=1
    export GVM_NO_GIT_BAK=1
    export SRC_REPO="$GVM_PROJECT_ROOT"
    export TERM="${TERM:-xterm}"

    local branch
    branch="$(git -C "$GVM_PROJECT_ROOT" rev-parse --abbrev-ref HEAD)"

    bash "$GVM_PROJECT_ROOT/binscripts/gvm-installer" "$branch" "$GVM_TEST_ROOT" > /dev/null 2>&1

    if [[ -d "$GVM_TEST_ROOT/gvm" ]]; then
        export GVM_ROOT="$GVM_TEST_ROOT/gvm"
    elif [[ -d "$GVM_TEST_ROOT/.gvm" ]]; then
        export GVM_ROOT="$GVM_TEST_ROOT/.gvm"
    else
        echo "ERROR: GVM installation not found in $GVM_TEST_ROOT" >&2
        return 1
    fi

    # gvm's cd override (scripts/env/cd) may return non-zero when no
    # default environment exists (fresh install). This is expected but
    # bats runs setup_file with set -e, so we must temporarily disable it.
    set +e
    source "$GVM_ROOT/scripts/gvm"
    set -e
}

teardown_gvm_environment() {
    if [[ -n "${GVM_TEST_ROOT:-}" && -d "${GVM_TEST_ROOT:-}" ]]; then
        rm -rf "$GVM_TEST_ROOT"
    fi
}

source_gvm_functions() {
    export GVM_ROOT="${GVM_ROOT:-/tmp/fake-gvm-root}"
    source "$GVM_PROJECT_ROOT/scripts/functions"
}

load_gvm_shell_function() {
    set +e
    source "$GVM_ROOT/scripts/gvm"
    set -e
}
