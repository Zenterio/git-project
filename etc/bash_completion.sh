# bash completion support for git-project.
#
# cur = current typed word
# command = git command
# last completed word = ${COMP_WORDS[-2]}
# COMP_CWORD = number of words
# COMP_WORDS = array with words
#
# Used for debugging:
# echo "" >> /tmp/complete.txt
# echo "command=${command}" >> /tmp/complete.txt
# echo "lastword=${lastword}" >> /tmp/complete.txt

_git_project_clone(){
    _git_clone
}

_git_project_init(){
    if [ ${COMP_CWORD} -le 4 ]; then
        local lastword=${COMP_WORDS[-2]}
        case "${lastword}" in
            -h|--help|-p|--print-template)
                __gitcomp
                return
                ;;
            -o|--origin)
                __gitcomp "-t --template"
                return
                ;;
            -t|--template)
                __gitcomp "-o --origin"
                return
                ;;
        esac
        __gitcomp "-h --help -t -o -p --origin --print-template --template"
        return
    else
        __gitcomp ""
    fi
}

_git_project_manual(){
    if [ ${COMP_CWORD} -le 3 ]; then
        __gitcomp "-h --help"
    else
        __gitcomp ""
    fi
}

_git_project_status(){
   if [ ${COMP_CWORD} -le 3 ]; then
        __gitcomp "-h --help"
    else
        __gitcomp ""
    fi
}

_git_project_sw-update(){
    if [ ${COMP_CWORD} -le 4 ]; then
        local lastword=${COMP_WORDS[-2]}
        case "${lastword}" in
            -h|--help|-p|--print-repo)
                __gitcomp
                return
                ;;
            -u|--user-install)
                __gitcomp "-r --repo"
                return
                ;;
            -r|--repo)
                __gitcomp "-u --user-install"
                return
                ;;
        esac
        __gitcomp "-h --help -p -r -u --print-repo --repo --user-install"
        return
    else
        __gitcomp ""
    fi
}

__git_project(){
    local lastword=${COMP_WORDS[-2]}
    case "${lastword}" in
        -h|--help|-v|--version)
            __gitcomp
            return
            ;;
    esac
    default="-h --help -v --version --sw-update --commands $(git project --commands)"
    __gitcomp "$default"
}

_git_project(){
    if [ ${COMP_CWORD} -ge 3 ]; then
        local projcmd=${COMP_WORDS[2]}
        if [ "${projcmd}" = "--sw-update" ]; then
            _git_project_sw-update
            return
        else
            local e
            for e in $(git project --commands); do
                if [ "$e" = "$projcmd" ]; then
                    _git_project_${projcmd}
                    return
                fi
            done
            __git_project
            return
        fi
    else
        __git_project
        return
    fi
}

