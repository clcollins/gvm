#!/usr/bin/env bats

# bats test_tags=network

load 'test_helper'

GO_TEST_VERSION="go1.22.4"

setup_file() {
    setup_gvm_environment
}

teardown_file() {
    teardown_gvm_environment
}

@test "gvm install binary version" {
    run gvm install "$GO_TEST_VERSION" --binary
    assert_success
    assert [ -d "$GVM_ROOT/gos/$GO_TEST_VERSION" ]
}

@test "gvm install creates environment file" {
    assert [ -f "$GVM_ROOT/environments/$GO_TEST_VERSION" ]
}

@test "gvm install creates global pkgset" {
    assert [ -d "$GVM_ROOT/pkgsets/$GO_TEST_VERSION/global" ]
}

@test "gvm install prefer-binary" {
    run gvm install go1.22.3 --prefer-binary
    assert_success
    assert [ -d "$GVM_ROOT/gos/go1.22.3" ]
}

@test "gvm uninstall removes version" {
    run gvm uninstall go1.22.3
    assert_success
    assert [ ! -d "$GVM_ROOT/gos/go1.22.3" ]
}
