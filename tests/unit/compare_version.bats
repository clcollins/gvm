#!/usr/bin/env bats

load '../test_helper'

setup() {
    source "$GVM_PROJECT_ROOT/scripts/function/compare_version"
}

@test "equal versions return 0" {
    run compare_version "1.4.3" "1.4.3"
    assert_equal "$status" 0
}

@test "first version greater returns 1" {
    run compare_version "1.7.6" "1.4.3"
    assert_equal "$status" 1
}

@test "first version lesser returns 2" {
    run compare_version "1.4.3" "1.7.6"
    assert_equal "$status" 2
}

@test "handles different field counts" {
    run compare_version "1.4" "1.4.3"
    assert_equal "$status" 2
}

@test "single-segment versions" {
    run compare_version "1" "1"
    assert_equal "$status" 0
}

@test "major version difference" {
    run compare_version "2.0.0" "1.99.99"
    assert_equal "$status" 1
}

@test "patch version difference" {
    run compare_version "1.21.5" "1.21.4"
    assert_equal "$status" 1
}
