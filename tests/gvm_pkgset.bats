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
    gvm use "$GO_TEST_VERSION" > /dev/null 2>&1
}

@test "gvm pkgset with no args shows help" {
    run gvm pkgset
    assert_success
    assert_output --partial "gvm pkgset"
    assert_output --partial "create"
    assert_output --partial "delete"
}

@test "gvm pkgset create makes a new package set" {
    run gvm pkgset create testpkgset
    assert_success
    assert [ -d "$GVM_ROOT/pkgsets/$GO_TEST_VERSION/testpkgset" ]
}

@test "gvm pkgset list shows created package set" {
    gvm pkgset create listtest > /dev/null 2>&1
    run gvm pkgset list
    assert_success
    assert_output --partial "listtest"
}

@test "gvm pkgset use switches to package set" {
    gvm pkgset create usetest > /dev/null 2>&1
    gvm pkgset use usetest
    [[ "$gvm_pkgset_name" == "usetest" ]]
}

@test "gvm pkgset empty clears package set contents" {
    gvm pkgset create emptytest > /dev/null 2>&1
    gvm pkgset use emptytest
    touch "$GVM_ROOT/pkgsets/$GO_TEST_VERSION/emptytest/dummy.txt"
    run gvm pkgset empty
    assert_success
    assert [ ! -f "$GVM_ROOT/pkgsets/$GO_TEST_VERSION/emptytest/dummy.txt" ]
}

@test "gvm pkgset delete removes package set" {
    gvm pkgset create deletetest > /dev/null 2>&1
    run gvm pkgset delete deletetest
    assert_success
    assert [ ! -d "$GVM_ROOT/pkgsets/$GO_TEST_VERSION/deletetest" ]
}

@test "gvm pkgset create duplicate fails" {
    gvm pkgset create duptest > /dev/null 2>&1
    run gvm pkgset create duptest
    assert_failure
}

@test "gvm pkgset delete nonexistent fails" {
    run gvm pkgset delete nonexistent
    assert_failure
}

@test "gvm pkgset list shows global by default" {
    run gvm pkgset list
    assert_success
    assert_output --partial "global"
}
