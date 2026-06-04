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
    gvm alias delete testalias > /dev/null 2>&1 || true
}

@test "gvm alias with no args shows help" {
    run gvm alias
    assert_success
}

@test "gvm alias create succeeds" {
    run gvm alias create testalias "$GO_TEST_VERSION"
    assert_success
}

@test "gvm alias list shows created alias" {
    gvm alias create testalias "$GO_TEST_VERSION"
    run gvm alias list
    assert_success
    assert_output --partial "testalias"
    assert_output --regexp "go1\.22\.4"
}

@test "gvm use works with alias" {
    gvm alias create testalias "$GO_TEST_VERSION"
    gvm use testalias
    run "$GVM_ROOT/gos/$GO_TEST_VERSION/bin/go" version
    assert_success
    assert_output --partial "go1.22.4"
}

@test "gvm alias delete removes alias" {
    gvm alias create testalias "$GO_TEST_VERSION"
    run gvm alias delete testalias
    assert_success
    run gvm alias list
    refute_output --partial "testalias"
}
