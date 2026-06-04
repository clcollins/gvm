#!/usr/bin/env bats

load '../test_helper'

setup() {
    source "$GVM_PROJECT_ROOT/scripts/function/extract_version"
}

@test "strips go prefix" {
    run extract_version "go1.21.5"
    assert_success
    assert_output "1.21.5"
}

@test "handles release tags" {
    run extract_version "release.r60.2"
    assert_success
    assert_output "0.0.1"
}

@test "strips beta suffix" {
    run extract_version "go1.21beta1"
    assert_success
    assert_output "1.21"
}

@test "strips rc suffix" {
    run extract_version "go1.21rc2"
    assert_success
    assert_output "1.21"
}

@test "handles two-segment version" {
    run extract_version "go1.22"
    assert_success
    assert_output "1.22"
}

@test "handles plain version without go prefix" {
    run extract_version "1.21.5"
    assert_success
    assert_output "1.21.5"
}
