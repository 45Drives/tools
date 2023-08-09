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

CACHE_DIR='/var/cache/45drives/ubm'

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

get_map_key() {
  if [[ -z "$UBM_MAP_KEY" ]]; then
    if [[ ! -r "$CACHE_DIR/map_key" ]]; then
      mkdir -p "$CACHE_DIR" >/dev/null
      local LOOKUP_KEY
      LOOKUP_KEY=$(
        (
          set -o pipefail
          ipmitool fru | awk -F: '
            BEGIN {
              found_key = 0
            }
            $1 ~ "Product Name" {
              found_key=1
              key=toupper($2);
              sub(/-(TURBO|BASE|ENHANCED).*$/, "", key);
              sub(/\s+/, "", key);
              print key;
              exit
            }
            END {
              if (!found_key) {
                print "map key lookup failed" > "/dev/stderr"
                exit 1
              }
            }
            '
        )
      ) || die $? "Failed to get Product Name from FRU"
      echo "$LOOKUP_KEY" >"$CACHE_DIR/map_key"
    fi
    UBM_MAP_KEY="$(<"$CACHE_DIR/map_key")"
    export UBM_MAP_KEY
  fi
  echo "$UBM_MAP_KEY"
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

slot_num_to_storcli_ctrlr() {
  local SLOT_NUM=$1
  (
    set -o pipefail
    /opt/45drives/tools/storcli2 /call/eall show all J | jq -re '
[
  .Controllers[] |
  select( (."Command Status"."Status" == "Success") and ()  ) |
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
  local MAP_KEY
  MAP_KEY=$(get_map_key) || return $?
  awk '
  BEGIN {
    found_style = 0
  }
  $1 == "'"$MAP_KEY"'" {
    found_style = 1
    print $'"$((2 + "$SLOT_NUM"))"'
    exit
  }
  END {
    if (!found_style) {
      print "map key lookup failed ('"$MAP_KEY"')" > "/dev/stderr"
      exit 1
    }
  }
  ' "$SLOT_NAME_MAP_FILE" || perror $? "Failed to lookup slot name for slot $SLOT_NUM"
  return $?
}

slot_name_to_slot_num() {
  local SLOT_NAME=$1
  local MAP_KEY
  MAP_KEY=$(get_map_key) || return $?
  awk '
  BEGIN {
    found_key = 0
    found_slot = 0
  }
  $1 == "'"$MAP_KEY"'" {
    found_key = 1
    for (i = 2; i<=NF; ++i) {
      if ($i == "'"$SLOT_NAME"'") {
        found_slot = 1
        print i - 2
        exit
      }
    }
  }
  END {
    if (!found_key) {
      print "map key lookup failed" > "/dev/stderr"
      exit 1
    }
    if (!found_slot) {
      print "slot column lookup failed" > "/dev/stderr"
      exit 1
    }
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
  local MAP_KEY
  MAP_KEY=$(get_map_key) || return $?
  (
    set -o pipefail
    grep "^$MAP_KEY" "$SLOT_NAME_MAP_FILE" | cut -d' ' -f2- | xargs printf '%s\n'
  ) || perror $? "Failed to lookup all slot names"
  return $?
}

all_slot_nums() {
  local MAP_KEY
  MAP_KEY=$(get_map_key) || return $?
  awk '
  BEGIN {
    found_key = 0
  }
  $1 == "'"$MAP_KEY"'" {
    found_key = 1
    for (i = 2; i<=NF; ++i) {
      print i - 2
    }
    exit
  }
  END {
    if (!found_key) {
      print "map key lookup failed" > "/dev/stderr"
      exit 1
    }
  }
  ' "$SLOT_NAME_MAP_FILE" || perror $? "Failed to lookup all slot numbers"
  return $?
}
