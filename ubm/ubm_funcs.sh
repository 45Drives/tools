# ubm_funcs.sh - source to include ubm helper functions
#
# Part of 45drives-tools
#
# Authors
# Josh Boudreau <jboudreau@45drives.com>

# shellcheck shell=bash

: <<'USAGE'
# shellcheck source=./ubm_funcs.sh
source "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/ubm_funcs.sh"
USAGE

[ -z "$BASH" ] && echo "Must use bash" >&2 && exit 2

[ "${BASH_SOURCE[0]}" -ef "$0" ] && echo "This script should only be sourced, not executed." >&2 && exit 2

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

CACHE_DIR='/var/cache/45drives/ubm'

# perror [ EXIT_CODE ] MESSAGE
#
# Print message to stderr, capturing and returning original exit code
# optionally pass overriding exit code as first arg
#
# e.g.
# cmd_that_fails || perror "cmd_that_fails failed!" || exit $?
# [ -z "$VAR" ] && perror 2 "VAR shouldn't be empty!" || exit $?
perror() {
  local EXIT_CODE=$?
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    EXIT_CODE=$1
    shift
  fi
  printf -- '%s: %s: %s' "$0" "${FUNCNAME[1]}" "$*" >&2
  [ "$EXIT_CODE" -ne "0" ] && printf ' (exited %d)' "$EXIT_CODE" >&2
  echo >&2
  return "$EXIT_CODE"
}

# die [ EXIT_CODE ] MESSAGE
#
# print message to stderr and exit script with captured exit code
# optionally pass overriding exit code as first arg
#
# e.g.
# cmd_that_fails || die "cmd_that_fails failed!"
# [ -z "$VAR" ] && die 2 "VAR shouldn't be empty!"
die() {
  perror "$@"
  exit $?
}

# get_map_key
# print map key for table lookups
#
# e.g.
# get_map_key -> "STORNADO-F2"
get_map_key() {
  if [[ -z "$UBM_MAP_KEY" ]]; then
    if [[ -r "$CACHE_DIR/map_key" ]]; then
      UBM_MAP_KEY="$(<"$CACHE_DIR/map_key")"
    else
      UBM_MAP_KEY=$(
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
      ) || perror "Failed to get Product Name from FRU" || return $?
      [ -d "$CACHE_DIR" ] || mkdir -p "$CACHE_DIR" >/dev/null
      TMPFILE=$(mktemp -p "$CACHE_DIR") || return $?
      echo "$UBM_MAP_KEY" >"$TMPFILE"
      mv "$TMPFILE" "$CACHE_DIR/map_key" || return $?
    fi
  fi
  echo "$UBM_MAP_KEY"
  return 0
}

# normalize_block_dev_name DEV_PATH|SYSFS_PATH|DEV_OS_NAME
#
# Takes block device path or sysfs block device path and returns block device name
#
# e.g.
# normalize_block_dev_name /dev/sda -> "sda"
# normalize_block_dev_name /sys/block/sda -> "sda"
normalize_block_dev_name() {
  local BLOCK_DEV_NAME=$1
  [ -z "$BLOCK_DEV_NAME" ] && perror "Must pass something as argument" && return 2
  [ $# -ne 1 ] && perror "Too many arguments" && return 2
  BLOCK_DEV_NAME=${BLOCK_DEV_NAME#/dev/}
  BLOCK_DEV_NAME=${BLOCK_DEV_NAME#/sys/block/}
  [ ! -b "/dev/$BLOCK_DEV_NAME" ] && perror "Not a block device: /dev/$BLOCK_DEV_NAME" && return 2
  echo "$BLOCK_DEV_NAME"
  return 0
}

# partition_to_parent_name DEV_PATH|SYSFS_PATH|DEV_OS_NAME
#
# First normalizes block dev name then determines parent block device
#
# e.g.
# partition_to_parent_name sda1 -> "sda"
# partition_to_parent_name /dev/sda1 -> "sda"
# partition_to_parent_name /sys/block/sda1 -> "sda"
partition_to_parent_name() {
  local BLOCK_DEV_NAME=$1
  local PARENT_DEV
  BLOCK_DEV_NAME=$(normalize_block_dev_name "$BLOCK_DEV_NAME") || return $?
  PARENT_DEV=$(lsblk -dno PKNAME "/dev/$BLOCK_DEV_NAME") || perror "Failed to parent block dev name" || return $?
  if [[ -n "$PARENT_DEV" ]]; then
    BLOCK_DEV_NAME="$PARENT_DEV"
  fi
  echo "$BLOCK_DEV_NAME"
  return 0
}

# block_dev_to_storcli_ctrlr() {
#   local BLOCK_DEV_NAME=$1
#   local BLOCK_DEV_SYS_PATH
#   BLOCK_DEV_SYS_PATH=$(realpath -- "/sys/block/$BLOCK_DEV_NAME") || perror $? "Failed to resolve $BLOCK_DEV_NAME sys path" || return $?
#   cat "$BLOCK_DEV_SYS_PATH"/../../../../scsi_host/host*/unique_id || perror $? "Failed to get $BLOCK_DEV_NAME storcli2 controller index"
#   return $?
# }

# slot_num_to_storcli_ctrlr() {
#   local SLOT_NUM=$1
#   (
#     set -o pipefail
#     /opt/45drives/tools/storcli2 /call/eall show all J | jq -re '
# [
#   .Controllers[] |
#   select( (."Command Status"."Status" == "Success") and ()  ) |
#   ."Response Data"."Drives List"[] |
#   select(
#     ."Drive Detailed Information"."OS Drive Name" | endswith("'"$BLOCK_DEV_NAME"'")
#   )
# ] | if length == 1 then .[] else empty end |
# ."Drive Information"."EID:Slt" | split(":")[1]
# '
#   ) || perror $? "Failed to get slot number for $BLOCK_DEV_NAME"
#   return $?
# }

# block_dev_to_slot_num DEV_PATH|SYSFS_PATH|DEV_OS_NAME [ STORCLI2_CTRL_NUM ]
#
# Get slot number from block device name/path
# Optionally pass controller number if known
# Will try to get from sysfs attribute `slot` but will fail back to using storcli2
#
# e.g.
# block_dev_to_slot_num sda -> 4
block_dev_to_slot_num() {
  local BLOCK_DEV_NAME=$1
  local CTRL_NUM=$2
  BLOCK_DEV_NAME=$(normalize_block_dev_name "$BLOCK_DEV_NAME") || return $?
  if [[ -f "/sys/block/$BLOCK_DEV_NAME/slot" ]]; then
    cat "/sys/block/$BLOCK_DEV_NAME/slot"
    return 0
  fi
  [[ -z "$CTRL_NUM" ]] && CTRL_NUM=all
  (
    set -o pipefail
    /opt/45drives/tools/storcli2 "/c$CTRL_NUM/eall/sall" show all J | jq -re '
    [
      .Controllers[] |
      select(."Command Status"."Status" == "Success" ) |
      select(."Response Data" != null) | ."Response Data" |
      select(."Drives List" != null) | ."Drives List" | .[] |
      select(
        ."Drive Detailed Information"."OS Drive Name" | endswith("'"$BLOCK_DEV_KERNEL_NAME"'")
      )
    ] | if length == 1 then .[] else empty end |
    ."Drive Information"."EID:Slt" | split(":")[1]
    '
  ) || perror "Failed to get slot number for $BLOCK_DEV_NAME"
}

# table_lookup_val TABLE_FILE_PATH ROW_SEARCH_COL ROW_SEARCH_VAL OUTPUT_COL
#
# Uses awk to find matching row in TABLE_FILE_PATH where [ROW_SEARCH_COL]==ROW_SEARCH_VAL,
# then prints value at [OUTPUT_COL].
# All columns are zero-indexed, unlike awk.
#
# e.g.
# table_lookup_val "$SCRIPT_DIR/slot_name_map.txt" 0 STORNADO-F2 3 -> "1-4"
table_lookup_val() {
  local TABLE_FILE=$1
  local ROW_SEARCH_COL=$2
  local ROW_SEARCH_VAL=$3
  local OUTPUT_COL=$4
  [[ ! -r "$TABLE_FILE" ]] && perror "Can't read '$TABLE_FILE', does it exist?" && return 2
  [[ ! "$ROW_SEARCH_COL" =~ ^[0-9]+$ ]] && perror "Invalid row search column: $ROW_SEARCH_COL" && return 2
  [[ -z "$ROW_SEARCH_VAL" ]] && perror "Row search value is empty" && return 2
  [[ ! "$OUTPUT_COL" =~ ^[0-9]+$ ]] && perror "Invalid output column: $OUTPUT_COL" && return 2
  awk -v ROW_SEARCH_COL=$((ROW_SEARCH_COL+1)) -v ROW_SEARCH_VAL="$ROW_SEARCH_VAL" -v OUTPUT_COL=$((OUTPUT_COL+1)) '
  BEGIN {
    found_row = 0
  }
  $ROW_SEARCH_COL == ROW_SEARCH_VAL {
    found_row = 1
    print $OUTPUT_COL
    exit 0
  }
  END {
    if (!found_row) {
      print "row lookup failed" > "/dev/stderr"
      exit 1
    }
  }
  ' "$TABLE_FILE"
}

# table_lookup_col TABLE_FILE_PATH ROW_SEARCH_COL ROW_SEARCH_VAL COL_SEARCH_VAL
#
# Uses awk to find matching row in TABLE_FILE_PATH where [ROW_SEARCH_COL]==ROW_SEARCH_VAL,
# then prints the column index containing the value COL_SEARCH_VAL.
# All columns are zero-indexed, unlike awk.
#
# e.g.
# table_lookup_val "$SCRIPT_DIR/slot_name_map.txt" 0 STORNADO-F2 1-4 -> "3"
table_lookup_col() {
  local TABLE_FILE=$1
  local ROW_SEARCH_COL=$2
  local ROW_SEARCH_VAL=$3
  local COL_SEARCH_VAL=$4
  [[ ! -r "$TABLE_FILE" ]] && perror "Can't read '$TABLE_FILE', does it exist?" && return 2
  [[ ! "$ROW_SEARCH_COL" =~ ^[0-9]+$ ]] && perror "Invalid row search column: $ROW_SEARCH_COL" && return 2
  [[ -z "$ROW_SEARCH_VAL" ]] && perror "Row search value is empty" && return 2
  [[ -z "$COL_SEARCH_VAL" ]] && perror "Column search value is empty" && return 2
  awk -v ROW_SEARCH_COL=$((ROW_SEARCH_COL+1)) -v ROW_SEARCH_VAL="$ROW_SEARCH_VAL" -v COL_SEARCH_VAL="$COL_SEARCH_VAL" '
  BEGIN {
    found_row = 0
    found_col = 0
  }
  $ROW_SEARCH_COL == ROW_SEARCH_VAL {
    found_row = 1
    for (i = 1; i<=NF; ++i) {
      if ($i == COL_SEARCH_VAL) {
        found_col = 1
        print i - 1
        exit 0
      }
    }
  }
  END {
    if (!found_row) {
      print "row lookup failed" > "/dev/stderr"
      exit 1
    }
    if (!found_col) {
      print "found row, but column lookup failed" > "/dev/stderr"
      exit 1
    }
  }
  ' "$TABLE_FILE"
}

# slot_num_to_slot_name SLOT_NUM
#
# Get slot name (e.g. 3-4) from numerical slot index (e.g. 28)
#
# e.g.
# slot_num_to_slot_name 2 -> "1-3"
slot_num_to_slot_name() {
  local SLOT_NUM=$1
  UBM_MAP_KEY=$(get_map_key) || return $?
  table_lookup_val "$SCRIPT_DIR/slot_name_map.txt" 0 "$UBM_MAP_KEY" $((1 + SLOT_NUM)) || perror "table_lookup_val failed"
}

# slot_name_to_slot_num SLOT_NAME
#
# Get slot numerical index (e.g. 7) from slot name (e.g. 1-8)
#
# e.g.
# slot_name_to_slot_num 2-3 -> "10"
slot_name_to_slot_num() {
  local SLOT_NAME=$1
  UBM_MAP_KEY=$(get_map_key) || return $?
  table_lookup_col "$SCRIPT_DIR/slot_name_map.txt" 0 "$UBM_MAP_KEY" "$SLOT_NAME" || perror "table_lookup_col failed"
}

# block_dev_to_slot_name DEV_PATH|SYSFS_PATH|DEV_OS_NAME [ STORCLI2_CTRL_NUM ]
#
# Get slot name from block device name/path
# Optionally pass controller number if known
#
# e.g.
# block_dev_to_slot_num sda -> 4
block_dev_to_slot_name() {
  local SLOT_NUM
  SLOT_NUM=$(block_dev_to_slot_num "$@") || perror "block_dev_to_slot_name failed" || return $?
  slot_num_to_slot_name "$SLOT_NUM" || perror "slot_num_to_slot_name failed"
}

all_slot_names() {
  UBM_MAP_KEY=$(get_map_key) || return $?
  (
    set -o pipefail
    grep "^$UBM_MAP_KEY" "$SCRIPT_DIR/slot_name_map.txt" | cut -d' ' -f2-
  ) || perror $? "Failed to lookup all slot names"
}

all_slot_nums() {
  UBM_MAP_KEY=$(get_map_key) || return $?
  awk -v MAP_KEY="$UBM_MAP_KEY" '
  BEGIN {
    found_key = 0
  }
  $1 == MAP_KEY {
    found_key = 1
    for (i = 2; i<=NF; ++i) {
      printf "%d", i - 2
      if (i+1 <= NF) {
        printf " "
      }
    }
    exit
  }
  END {
    if (!found_key) {
      print "map key lookup failed" > "/dev/stderr"
      exit 1
    }
    print ""
  }
  ' "$SLOT_NAME_MAP_FILE" || perror $? "Failed to lookup all slot numbers"
}
