#!/usr/bin/env bats

# bats test_tags=network

load 'test_helper'

GO_TEST_VERSION="go1.22.4"

setup_file() {
    setup_gvm_environment
    gvm install "$GO_TEST_VERSION" --binary > /dev/null 2>&1
}

teardown_file() {
    teardown_gvm_environment
}

setup() {
    load_gvm_shell_function
}

@test "gvm use selects version" {
    gvm use "$GO_TEST_VERSION"
    [[ "$gvm_go_name" == "$GO_TEST_VERSION" ]]
}

@test "gvm use updates GOROOT" {
    gvm use "$GO_TEST_VERSION"
    [[ "$GOROOT" == "$GVM_ROOT/gos/$GO_TEST_VERSION" ]]
}

@test "go binary points to gvm-managed version after gvm use" {
    gvm use "$GO_TEST_VERSION"
    run "$GVM_ROOT/gos/$GO_TEST_VERSION/bin/go" version
    assert_success
    assert_output --partial "$GO_TEST_VERSION"
}

@test "gvm use sets default with --default flag" {
    gvm use "$GO_TEST_VERSION" --default
    assert [ -f "$GVM_ROOT/environments/default" ]
}
