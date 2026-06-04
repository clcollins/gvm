#!/usr/bin/env bats

load 'test_helper'

setup_file() {
    setup_gvm_environment
}

teardown_file() {
    teardown_gvm_environment
}

@test "gvm version prints version string" {
    run "$GVM_ROOT/bin/gvm" version
    assert_success
    assert_output --partial "Go Version Manager v"
}

@test "gvm version includes version number from VERSION file" {
    local expected_version
    expected_version="$(cat "$GVM_ROOT/VERSION")"
    run "$GVM_ROOT/bin/gvm" version
    assert_success
    assert_output --partial "$expected_version"
}

@test "gvm version includes GVM_ROOT path" {
    run "$GVM_ROOT/bin/gvm" version
    assert_success
    assert_output --partial "$GVM_ROOT"
}
