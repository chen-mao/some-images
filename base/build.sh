#!/bin/bash

set -euo pipefail

XDXCT_IMAGE="hub.xdxct.com/xdxct"

IMAGE_NAME=""
CGL_INTER_IMAGE_NAME_SUFFIX="/build-intermediate"
OS=""
OS_VERSION=""
OS_PATH_NAME=""
ARCHES=""
LOAD_ARG=""
PUSH_ARG=""
BASE_PATH=""
IMAGE_SUFFIX=""

args=("$@")
script_name=$(basename $0)
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
run_cmd_output=""
run_cmd_return=0
debug_flag=0
dry_run=0
use_kitpick=0

err() {
    local mesg=$1; shift
    printf "ERROR: $(basename ${BASH_SOURCE[${SOURCE_LINE_OVERRIDE:-1}]})#${BASH_LINENO[${BASH_LINE_OVERRIDE:-0}]} ${mesg}\n\n" "$mesg" 1>&2
    if [[ $# -gt 0 ]]; then
        printf '%s ' "${@}" 1>&2
        printf '\n\n'
    fi
    exit 1
}

msg() {
    local mesg=$1; shift
    printf ">>> $(basename ${BASH_SOURCE[1]})#${BASH_LINENO[0]} %s\n\n" "$mesg"
    if [[ $# -gt 0 ]]; then
        printf '%s ' "${@}"
        printf '\n\n'
    fi
}

debug() {
    # $1: The message to print.
    if [[ ${debug_flag} -eq 1 ]]; then
        local mesg=$1; shift
        printf "%s\n\n" "### DEBUG: $(basename ${BASH_SOURCE[${SOURCE_LINE_OVERRIDE:-1}]})#${BASH_LINENO[${BASH_LINE_OVERRIDE:-0}]} ${mesg}" 1>&2
        if [[ $# -gt 0 ]]; then
            printf '%s ' "${@}" 1>&2
            printf '\n\n'
        fi
    fi
}

warning() {
    local mesg=$1; shift
    printf "WARNING: $(basename ${BASH_SOURCE[${SOURCE_LINE_OVERRIDE:-1}]})#${BASH_LINENO[${BASH_LINE_OVERRIDE:-0}]} ${mesg}\n\n" "$mesg" 1>&2
    if [[ $# -gt 0 ]]; then
        printf '%s ' "${@}" 1>&2
        printf '\n\n'
    fi
}

norun() {
    local mesg=$1; shift
    printf ">>> NORUN: $(basename ${BASH_SOURCE[${SOURCE_LINE_OVERRIDE:-1}]})#${BASH_LINENO[${BASH_LINE_OVERRIDE:-0}]} ${mesg}\n\n" "$mesg"
    if [[ $# -gt 0 ]]; then
        printf '%s ' "$@"
        printf '\n\n'
    fi
}

git_clone_pull() {
    # $1 path
    # $2 repo
    # $3 branch
    ORIG=`pwd`
    debug "git_clone_pull: \$1: $1, \$2: $2"
    if [[ -d "$1" ]]; then
        cd "$1"
        msg "Pulling $2 into $PWD"
        # careful!
        # run_cmd "git reset --hard HEAD"
        run_cmd "git pull --all"
        run_cmd "git checkout ${OS}${OS_VERSION}"
    else
        msg "Cloning into $PWD"
        run_cmd "git clone --branch=${OS}${OS_VERSION} $2 $1"
    fi
    cd $ORIG
}

usage() {
    echo "${script_name} - BASE XDXCT Image Build Helper"
    echo
    echo "Usage: ${script_name} [options]"
    echo
    echo "OPTIONS"
    echo
    echo "    -h, --help            - Show this message."
    echo "    -n, --dry-run         - Show commands but don't do anything."
    echo "    -d, --debug           - Show debug output."
    ## TODO: allow the user to pass arguments to docker buildx
    echo "    --load                - Load the images on the build host. (Out of the docker cache)."
    # TODO
    # echo "    --push                - Push the images to the remote repository."
    echo "    --image-name=str      - The image name to use. Default: hub.xdxct.com/xdxct"
    echo "    --os=str              - The target operating system."
    echo "    --arch=csv            - Target architectures as a comma separated string."
    echo "    --kitpick             - Build from the kitpick directory."
    echo
    exit 155
}

# Runs a command. Output is not captured
# To use this function, define the following in your calling script:
# run_cmd_return=""
run_cmd() {
    run_cmd_return=0
    run_cmd_return=0
    # $@: The command and args to run
    if [[ ${dry_run} -eq 1 ]]; then
        SOURCE_LINE_OVERRIDE=2 BASH_LINE_OVERRIDE=1 norun "CMD:" "$@"
    else
        printf "%s\n\n" "$(basename ${BASH_SOURCE[${SOURCE_LINE_OVERRIDE:-1}]})#${BASH_LINENO[${BASH_LINE_OVERRIDE:-0}]} Running command:"
        printf "%s " "${@}"
        printf "\n\n"
        printf "Output: \n\n"
        echo -e "$@" | source /dev/stdin
        run_cmd_return=$?
        echo
        printf "Command returned: %s\n\n" "${run_cmd_return}"
        return $run_cmd_return
    fi
}

if [[ ${#args[@]} -eq 0 ]]; then
  echo
  err "No arguments specified!"
  usage
fi

check_vars() {
    if [[ -z ${ARCHES} ]]; then
        err "ARCHES argument not set!"
    elif [[ -z ${OS} ]]; then
        err "OS argument not set!"
    elif [[ -z ${OS_VERSION} ]]; then
        err "OS_VERSION argument not set!"
    fi
    OS_PATH_NAME="${OS}${OS_VERSION}"
    if [[ "${OS_VERSION}" =~ .*\..* ]]; then
        # delete the dot in os string
        msg "Setting OS_PATH_NAME to '${OS}${OS_VERSION//.}'"
        OS_PATH_NAME="${OS}${OS_VERSION//.}"
        debug "OS_PATH_NAME: ${OS_PATH_NAME}"
    fi
    PLATFORM_ARG=`printf '%s ' '--platform'; for var in $(echo $ARCHES | sed "s/,/ /g"); do printf 'linux/%s,' "$var"; done | sed 's/,*$//g'`
    if [[ "${PLATFORM_ARG}" =~ .*,.* ]]; then
        warning "Multiple platforms detected, removing '--load' argument from docker build... (https://github.com/docker/buildx/issues/59)"
        warning "Try doing one platform at a time as a workaround..."
        LOAD_ARG=""
    fi
    if [[ ${use_kitpick} -eq 1 ]]; then
        BASE_PATH="kitpick"
        IMAGE_SUFFIX=$(grep -oP "(?<=base-${OS}${OS_VERSION}-).*(?=\ as\ base)" "kitpick/${OS_PATH_NAME}/runtime/Dockerfile")
        debug "IMAGE_SUFFIX: '${IMAGE_SUFFIX}'"
    else
        BASE_PATH="dist"
    fi
}

main() {
    printf "\n"
    msg "${script_name} START"

    for (( a = 0; a < ${#args[@]}; a++ )); do
        if [[ ${args[$a]} == "-h" ]] || [[ ${args[$a]} == "--help" ]]; then
            usage
        elif [[ ${args[$a]} == "-n" ]] || [[ ${args[$a]} == "--dry-run" ]]; then
            debug "found arg 'dry-run'"
            dry_run=1
        elif [[ ${args[$a]} == "-d" ]] || [[ ${args[$a]} == "--debug" ]]; then
            debug "found arg 'debug'"
            debug_flag=1
        elif [[ ${args[$a]} == "--load" ]]; then
            debug "found command '${args[$a]}'"
            LOAD_ARG=${args[$a]}
        # TODO push images to harbor. 
        # elif [[ ${args[$a]} == "--push" ]]; then
        #     debug "found command '${args[$a]}'"
        #     PUSH_ARG=${args[$a]}
        elif [[ ${args[$a]} == "--kitpick" ]]; then
            debug "found command '${args[$a]}'"
            use_kitpick=1
        elif [[ ${args[$a]} == "--image-name" ]]; then
            debug "found command '${args[$a]}'"
            IMAGE_NAME=${args[(($a+1))]}
            debug "IMAGE_NAME=${IMAGE_NAME}"
            ((a=a+1))
        elif [[ ${args[$a]} == "--os" ]]; then
            debug "found command '${args[$a]}'"
            OS=${args[(($a+1))]}
            debug "OS=${OS}"
            ((a=a+1))
        elif [[ ${args[$a]} == "--os-version" ]]; then
            debug "found command '${args[$a]}'"
            OS_VERSION=${args[(($a+1))]}
            debug "OS_VERSION=${OS_VERSION}"
            ((a=a+1))
        elif [[ ${args[$a]} == "--arch" ]]; then
            debug "found command '${args[$a]}'"
            ARCHES=${args[(($a+1))]}
            debug "ARCHES=${ARCHES}"
            ((a=a+1))
        else
            err "Unknown argument '${args[$a]}'!"
            usage
        fi
    done

    check_vars

    run_cmd docker buildx build --pull ${LOAD_ARG} ${PUSH_ARG} ${PLATFORM_ARG} \
        -t "${IMAGE_NAME}:base-${OS}${OS_VERSION}${IMAGE_SUFFIX:+-${IMAGE_SUFFIX}}" \
        "${BASE_PATH}/${OS_PATH_NAME}/base"

    # run_cmd docker buildx build --pull ${LOAD_ARG} ${PUSH_ARG} ${PLATFORM_ARG} \
    #     -t "${IMAGE_NAME}:runtime-${OS}${OS_VERSION}${IMAGE_SUFFIX:+-${IMAGE_SUFFIX}}" \
    #     --build-arg "IMAGE_NAME=${IMAGE_NAME}" \
    #     "${BASE_PATH}/${OS_PATH_NAME}/runtime"

    # run_cmd docker buildx build --pull ${LOAD_ARG} ${PUSH_ARG} ${PLATFORM_ARG} \
    #     -t "${IMAGE_NAME}:devel-${OS}${OS_VERSION}${IMAGE_SUFFIX:+-${IMAGE_SUFFIX}}" \
    #     --build-arg "IMAGE_NAME=${IMAGE_NAME}" \
    #     "${BASE_PATH}/${OS_PATH_NAME}/devel"

    msg "${script_name} END"
}

main
