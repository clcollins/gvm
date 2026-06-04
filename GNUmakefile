.PHONY: test test-unit test-integration

test: test-unit test-integration

test-unit:
	bats tests/unit/

test-integration:
	TERM=xterm GVM_NO_UPDATE_PROFILE=1 GVM_NO_GIT_BAK=1 bats tests/gvm_help.bats tests/gvm_version.bats tests/gvm_install.bats tests/gvm_list.bats tests/gvm_listall.bats tests/gvm_use.bats tests/gvm_alias.bats tests/gvm_pkgset.bats tests/gvm_error_handling.bats tests/gvm_implode.bats
