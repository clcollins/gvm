#!/usr/bin/env bats

# bats test_tags=network

load 'test_helper'

setup_file() {
    setup_gvm_environment
}

teardown_file() {
    teardown_gvm_environment
}

@test "gvm listall shows available versions" {
    run gvm listall
    assert_success
    assert_output --partial "gvm gos (available)"
}

@test "gvm listall includes release versions" {
    run gvm listall
    assert_success
    assert_output --partial "go1."
}
