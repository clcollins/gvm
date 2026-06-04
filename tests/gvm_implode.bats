#!/usr/bin/env bats

load 'test_helper'

setup_file() {
    setup_gvm_environment
}

@test "gvm implode can be cancelled" {
    load_gvm_shell_function
    run bash -c "source '$GVM_ROOT/scripts/gvm' && echo 'n' | gvm implode"
    assert_success
    assert_output --partial "Action cancelled"
    assert [ -d "$GVM_ROOT" ]
}

@test "gvm implode removes GVM_ROOT" {
    load_gvm_shell_function
    run bash -c "source '$GVM_ROOT/scripts/gvm' && echo 'y' | gvm implode"
    assert_success
    assert_output --partial "GVM successfully removed"
    assert [ ! -d "$GVM_ROOT" ]
}
