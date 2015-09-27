#
# Dependencies to variables:
#
# TEMPLATE_PATH
# SWUPDATE_PATH
# ORIGIN_PROJECT_PATH
#
# FULL_PROJECT_PATH
# COMPONENT_PATH
# SUBCOMPONENT_PATH
#
# REPO_EXT
# SHARNESS_TRASH_DIRECTORY
# SHARNESS_BUILD_DIRECTORY
# INSTALL_DIR
# SUT_DIR

set_config() {
    git config project.template "${TEMPLATE_PATH}"
    git config project.update-repo "${SWUPDATE_PATH}"
    git config user.email "test@test.com"
    git config user.name "test user"
}

init_repo_variable() {
    local name=$1
    local varname=$(echo $1 | tr '[a-z]' '[A-Z]')
    printf -v "${varname}_PATH" "${SHARNESS_TRASH_DIRECTORY}/${name}${REPO_EXT}"
}


# $1 - repo-directory
# creates a simulated remote (bare) repository with repo.info file
create_remote_repo() {
    local repo_dir="$1"
    create_empty_remote_repo "${repo_dir}"
    add_to_remote_repo "${repo_dir}" "Added repo.info" "echo ${repo_dir} > repo.info"
}

# $1 - repo directory
# creates a simulated empty remote (bare) repository
create_empty_remote_repo() {
    local repo_dir="$1"
    (mkdir -p "${repo_dir}" &&
     pushd "${repo_dir}" &&
     git init --bare &&
     popd)
}

# $1 - repo directory
# creates a local repository
create_repo() {
    local repo_dir="$1"
    (mkdir -p "${repo_dir}" && cd "${repo_dir}" && git init)
}

# $1 - repo
# $2 - commit message
# $3 - commands to be run before commit
# adds to a remote repository by committing all changes caused by commands.
add_to_remote_repo() {
    local repo="$1"
    shift
    local msg="$1"
    shift
    commands="$@"
    local dir=$(basename "${repo}" ${REPO_EXT})
    (git clone --recurse-submodules "${repo}" "${dir}" &&
     add_to_repo "${dir}" "${msg}" "${commands}" &&
     pushd "${dir}" &&
     git push origin master:master &&
     popd;
     result=$?;
     rm -rf "${dir}"; return $result)
}

# $1 - repo
# $2 - commit message
# $3 - commands to be run before commit
# adds to a local repository by committing all changes caused by commands.
add_to_repo() {
    local repo="$1"
    shift
    local msg="$1"
    shift
    commands="$@"
    (pushd "${repo}" &&
        eval "${commands}" &&
        git add --all . &&
        (unset GIT_CONFIG;
            git config user.name "test user" &&
            git config user.email "test@test.com" &&
            git commit -m "${msg}") &&
        popd)
}

# $1 - parent repo
# $2 - module repo
# $3 - module path
add_submodule_to_remote_repo() {
    local parent_repo="$1"; shift
    local module_repo="$1"; shift
    local module_path="$1"; shift
    local dir=$(basename "${parent_repo}" ${REPO_EXT})
    (git clone "${parent_repo}" "${dir}" &&
    add_submodule_to_repo "${dir}" "${module_repo}" "${module_path}" &&
    pushd "${dir}" &&
    git push origin master:master &&
    popd;
    result=$?;
    rm -rf "${dir}"; return $result)
}

# $1 - parent repo
# $2 - module repo
# $3 - module path
add_submodule_to_repo() {
    local parent_repo="$1"; shift
    local module_repo="$1"; shift
    local module_path="$1"; shift
    local msg="Added submodule (path=${module_path}, repo=${module_repo})"
    local commands='
        git submodule add -b master "${module_repo}" ${module_path} &&
        git add ${module_path}
    '
    add_to_repo "${parent_repo}" "${msg}" "${commands}"
}


# $@ make arguments
run_make() {
    cd "${SHARNESS_BUILD_DIRECTORY}" &&
    make --no-print-directory "$@"
}

# creates a simulated remote repo called template
create_template() {
    create_remote_repo "${TEMPLATE_PATH}" &&
    add_to_remote_repo "${TEMPLATE_PATH}" 'added src directory' '
        mkdir src &&
        echo "src" > src/src.info
        '
}

# create a simulated remote swupdate repo based on latest commit in local repo
create_update_repo() {
    create_remote_repo "${SWUPDATE_PATH}" &&
    (cd "${SHARNESS_BUILD_DIRECTORY}" &&
    git push -f "${SWUPDATE_PATH}" master:master)
}

# creates a simulated empty remote repo called project
create_project_origin_repo() {
    create_empty_remote_repo "${ORIGIN_PROJECT_PATH}"
}

create_component_repo() {
    create_remote_repo "${COMPONENT_PATH}"
}

create_subcomponent_repo() {
    create_remote_repo "${SUBCOMPONENT_PATH}"
}

create_full_project_repo() {
    create_remote_repo "${FULL_PROJECT_PATH}"
    create_component_repo
    create_subcomponent_repo
    add_submodule_to_remote_repo "${COMPONENT_PATH}" "${SUBCOMPONENT_PATH}" "component"
    add_submodule_to_remote_repo "${FULL_PROJECT_PATH}" "${COMPONENT_PATH}" "component"
}

create_user_installation_using_variables() {
    local dest=$(test -z "$1" || echo "/${1}")
    run_make install KEEP_BUILD_FILES=y DESTDIR="${INSTALL_DIR}${dest}" PREFIX="/local" COMPLETIONPREFIX="/bash" \
        HTMLPREFIX="/html" GITCONFIG=
}

create_user_installation_using_config() {
    run_make install KEEP_BUILD_FILES=y FROM_CONFIG=y GITCONFIG=
}

remove_user_installation_using_variables() {
    local dest=$(test -z "$1" || echo "/${1}")
    run_make uninstall DESTDIR="${INSTALL_DIR}${dest}" PREFIX="/local" COMPLETIONPREFIX="/bash" \
        HTMLPREFIX="/html" GITCONFIG=
}

remove_user_installation_using_config() {
    run_make uninstall FROM_CONFIG=y GITCONFIG=
}

install_sut() {
    test_exec run_make install KEEP_BUILD_FILES=y DESTDIR="${SUT_DIR}" PREFIX="/local" COMPLETIONPREFIX="/bash" \
        HTMLPREFIX="/html" GITCONFIG=
    export MANPATH="$(git config project.install.man):$(manpath)"
    export PATH="$(git config project.install.bin):${PATH}"
}

uninstall_sut() {
    test_exec run_make uninstall DESTDIR="${SUT_DIR}" PREFIX="/local" COMPLETIONPREFIX="/bash" \
        HTMLPREFIX="/html" GITCONFIG=
    rm -rf "${SUT_DIR}"
}
