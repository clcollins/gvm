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

@test "gvm list shows header" {
    run gvm list
    assert_success
    assert_output --partial "gvm gos (installed)"
}

@test "gvm list shows installed version" {
    run gvm list
    assert_success
    assert_output --partial "$GO_TEST_VERSION"
}

@test "gvm list marks active version" {
    load_gvm_shell_function
    gvm use "$GO_TEST_VERSION" > /dev/null 2>&1
    run gvm list
    assert_success
    assert_output --partial "=> $GO_TEST_VERSION"
}
