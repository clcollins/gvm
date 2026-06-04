#!/usr/bin/env bats

load 'test_helper'

setup_file() {
    setup_gvm_environment
}

teardown_file() {
    teardown_gvm_environment
}

@test "gvm with no arguments shows help text" {
    run "$GVM_ROOT/bin/gvm"
    assert_success
    assert_output --partial "GVM is the Go Version Manager"
}

@test "gvm help shows usage" {
    run "$GVM_ROOT/bin/gvm" help
    assert_success
    assert_output --partial "GVM is the Go Version Manager"
}

@test "help text lists available commands" {
    run "$GVM_ROOT/bin/gvm" help
    assert_success
    assert_output --partial "install"
    assert_output --partial "uninstall"
    assert_output --partial "use"
    assert_output --partial "list"
    assert_output --partial "listall"
    assert_output --partial "alias"
    assert_output --partial "pkgset"
}
