#!/usr/bin/env bash

# shellcheck source=./ubm_funcs.sh
source "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/ubm_funcs.sh"

UBM_FUNC_NAME=$(basename "$0")

if [ "$UBM_FUNC_NAME" != "check_ubm_func_support" ]; then
    check_ubm_func_support || exit $?
fi

[ "$UBM_FUNC_NAME" == "ubm_func_wrapper.sh" ] && perror "Intended to be executed via symlink" && exit 2

"$UBM_FUNC_NAME" "$@"
