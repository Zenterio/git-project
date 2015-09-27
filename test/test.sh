# Source libraries first. They should NOT depend on any variables during sourcing.
# In functions is fine, just not during source stage

. ./lib/zenterio.sharness.extensions.sh
. ./lib/test_lib.sh
# sharness changes PWD to the work-area, so we need it to be last.
# To get back to original path, use ${SHARNESS_TEST_SRCDIR}.
. ./lib/sharness.sh

REPO_EXT=.git

set_install_dir() {
    local script=$(basename $0 ".${SHARNESS_TEST_EXTENSION}")
    local install="sut-${script:0:4}"
    INSTALL_DIR=${SHARNESS_TEST_DIRECTORY}/${install}
}
set_install_dir

set_sut_dir() {
    local script=$(basename $0 ".${SHARNESS_TEST_EXTENSION}")
    local sut="sut-${script:0:4}"
    SUT_DIR="${SHARNESS_TEST_DIRECTORY}/${sut}"
}
set_sut_dir

# Git configuration file to be used through out the test
# A note though! You need to unset this variable if using git config
# with --system|--global|--local. Otherwise git will complain.
export GIT_CONFIG="${SHARNESS_TRASH_DIRECTORY}/gitconfig.test"

# Development test, hence testing on the SUT installation
test -z "${SYSTEM_TEST}" && test_set_prereq DEV_TEST

# System test, testing on a version installed on the system
# Since we do software update and other stuff, be careful.
# And also, it might require sudo rights since we do sw update.
test ! -z "${SYSTEM_TEST}" && test_set_prereq SYSTEM_TEST

init_repo_variable template
init_repo_variable origin_project
init_repo_variable full_project
init_repo_variable swupdate
init_repo_variable component
init_repo_variable subcomponent

# Do a SUT installation if we are doing development test
if test_have_prereq DEV_TEST; then
    install_sut
    cleanup 'uninstall_sut'
fi

# Set config, need to be done after any SUT installation
set_config

## Headers, should be done after SUT-installation
print_headers() {
    say_color header ""
    say_color header "$(basename ${SHARNESS_TEST_FILE} ".${SHARNESS_TEST_EXTENSION}") :: ${test_description}"
    say_color info "path: $(dirname $(which git-project))"
    say_color info ""
}
print_headers

## Pre condition check, last thing that happens before test case takes over
precondition_check() {
    if test_have_prereq DEV_TEST; then
        if [ "$(dirname $(which git-project))" != "${SUT_DIR}/local/bin" ]; then
            skip_all="Installation of SUT failed. Skipping all tests."
            test_done
        fi
    fi
}
precondition_check
