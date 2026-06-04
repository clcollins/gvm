#!/usr/bin/env bats

load 'test_helper'

setup_file() {
    setup_gvm_environment
}

teardown_file() {
    teardown_gvm_environment
}

setup() {
    load_gvm_shell_function
}

@test "gvm unrecognized command fails" {
    run "$GVM_ROOT/bin/gvm" notacommand
    assert_failure
    assert_output --partial "Unrecognized command"
}

@test "gvm use without version shows error" {
    run gvm use
    assert_failure
}

@test "gvm use nonexistent version fails" {
    run gvm use go99.99.99
    assert_failure
}

@test "gvm uninstall nonexistent version fails" {
    run gvm uninstall go99.99.99
    assert_failure
}

@test "gvm alias create without arguments fails" {
    run gvm alias create
    assert_failure
}

@test "gvm alias delete nonexistent fails" {
    run gvm alias delete nonexistent_alias_xyz
    assert_failure
}

@test "gvm install with no version fails" {
    run gvm install
    assert_failure
}
