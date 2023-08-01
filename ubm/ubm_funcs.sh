# ubm_funcs.sh - source to include ubm helper functions
#
# Part of 45drives-tools
#
# Authors
# Josh Boudreau <jboudreau@45drives.com>

# shellcheck shell=bash

[ -z "$BASH" ] && echo "Must use bash" >&2 && exit 1

[ "${BASH_SOURCE[0]}" -ef "$0" ] && echo "This script should only be sourced, not executed." >&2 && exit 1

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

SERVER_INFO_FILE=/etc/45drives/server_info/server_info.json

SLOT_NAME_MAP_FILE="$SCRIPT_DIR/ubm_slot_name_map.txt"

perror() {
  local EXIT_CODE=$1
  shift
  echo "${BASH_SOURCE[0]}: ${FUNCNAME[1]}:" "$@" "($EXIT_CODE)" >&2
  return "$EXIT_CODE"
}

die() {
  local EXIT_CODE=$1
  shift
  echo "${BASH_SOURCE[0]}: ${FUNCNAME[1]}:" "$@" "($EXIT_CODE)" >&2
  exit "$EXIT_CODE"
}

get_alias_style() {
  jq -re '."Alias Style"' "$SERVER_INFO_FILE" || perror $? "Failed to get alias style"
  return $?
}

# will exit script on error
alias_style() {
  if [[ -z "$ALIAS_STYLE" ]]; then
    ALIAS_STYLE=$(get_alias_style) || exit $?
    export ALIAS_STYLE
  fi
  echo "$ALIAS_STYLE"
  return 0
}

normalize_block_dev_name() {
  local BLOCK_DEV_NAME=$1
  BLOCK_DEV_NAME=${BLOCK_DEV_NAME#/dev/}
  BLOCK_DEV_NAME=${BLOCK_DEV_NAME#/sys/block/}
  # if its a partition:
  local PARENT_DEV
  if PARENT_DEV=$(lsblk -dno PKNAME "/dev/$BLOCK_DEV_NAME") && [[ -n "$PARENT_DEV" ]]; then
    BLOCK_DEV_NAME="$PARENT_DEV"
  fi
  echo "$BLOCK_DEV_NAME"
  return 0
}

block_dev_to_storcli_ctrlr() {
  local BLOCK_DEV_NAME=$1
  local BLOCK_DEV_SYS_PATH
  BLOCK_DEV_SYS_PATH=$(realpath -- "/sys/block/$BLOCK_DEV_NAME") || perror $? "Failed to resolve $BLOCK_DEV_NAME sys path" || return $?
  cat "$BLOCK_DEV_SYS_PATH"/../../../../scsi_host/host*/unique_id || perror $? "Failed to get $BLOCK_DEV_NAME storcli2 controller index"
  return $?
}

block_dev_to_slot_num() {
  local BLOCK_DEV_NAME=$1
  local CTRL_NUM=$2
  [[ -n "$CTRL_NUM" ]] || CTRL_NUM=$(block_dev_to_storcli_ctrlr "$BLOCK_DEV_NAME") || return $?
  (
    set -o pipefail
    /opt/45drives/tools/storcli2 /c"$CTRL_NUM"/eall/sall show all J | jq -re '
[
  .Controllers[] |
  select(."Command Status"."Status" == "Success") |
  ."Response Data"."Drives List"[] |
  select(
    ."Drive Detailed Information"."OS Drive Name" | endswith("'"$BLOCK_DEV_NAME"'")
  )
] | if length == 1 then .[] else empty end |
."Drive Information"."EID:Slt" | split(":")[1]
'
  ) || perror $? "Failed to get slot number for $BLOCK_DEV_NAME"
  return $?
}

slot_num_to_slot_name() {
  local SLOT_NUM=$1
  [[ $SLOT_NUM =~ ^[0-9]+$ ]] || perror 1 Invalid slot number: "$SLOT_NUM" || return $?
  awk '
  BEGIN {
    found_style = 0
  }
  $1 == "'"$(alias_style)"'" {
    found_style = 1
    print $'"$((2 + "$SLOT_NUM"))"'
  }
  END {
    if (!found_style) {
      print "alias style lookup failed ('"$(alias_style)"')" > "/dev/stderr"
      exit 1
    }
    exit 0
  }
  ' "$SLOT_NAME_MAP_FILE" || perror $? "Failed to lookup slot name for slot $SLOT_NUM"
  return $?
}

slot_name_to_slot_num() {
  local SLOT_NAME=$1
  awk '
  BEGIN {
    found_style = 0
    found_slot = 0
  }
  $1 == "'"$(alias_style)"'" {
    found_style = 1
    for (i = 2; i<=NF; ++i) {
      if ($i == "'"$SLOT_NAME"'") {
        found_slot = 1
        print i - 2
      }
    }
  }
  END {
    if (!found_style) {
      print "alias style lookup failed" > "/dev/stderr"
      exit 1
    }
    if (!found_slot) {
      print "slot column lookup failed" > "/dev/stderr"
      exit 1
    }
    exit 0
  }
  ' "$SLOT_NAME_MAP_FILE"
  return $?
}

block_dev_to_slot_name() {
  local BLOCK_DEV_NAME=$1
  local CTRL_NUM=$2
  [[ -n "$CTRL_NUM" ]] || CTRL_NUM=$(block_dev_to_storcli_ctrlr "$BLOCK_DEV_NAME") || return $?
  local SLOT_NUM
  SLOT_NUM=$(block_dev_to_slot_num "$BLOCK_DEV_NAME" "$CTRL_NUM") || return $?
  slot_num_to_slot_name "$SLOT_NUM"
}

all_slot_names() {
  (
    set -o pipefail
    grep "^$(alias_style)" "$SLOT_NAME_MAP_FILE" | cut -d' ' -f2- | xargs printf '%s\n'
  ) || perror $? "Failed to lookup all slot names"
  return $?
}
