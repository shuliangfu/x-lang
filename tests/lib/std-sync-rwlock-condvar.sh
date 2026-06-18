#!/usr/bin/env bash
# std-sync-rwlock-condvar.sh — STD-045 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_sync_rc_symbols_ok MOD_SU SYNC_C TSV
#   std_sync_rc_run_smoke SHU_BIN SU TAG
#   std_sync_rc_try_tsan SYNC_C
#   std_sync_rc_emit_report status rwlock_ok condvar_ok main_ok tsan_ok skip

STD_SYNC_RC_PREFIX="${SHU_STD_SYNC_RWLOCK_CONDVAR_PREFIX:-shu: [SHU_STD_SYNC_RWLOCK_CONDVAR]}"

std_sync_rc_symbols_ok() {
  local mod_su="$1"
  local sync_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-sync-rwlock-condvar FAIL: missing api '$anchor' in $mod_su" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/sync/sync.c) mod_path="$sync_c" ;;
          *) mod_path="$mod_su" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-sync-rwlock-condvar FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-sync-rwlock-condvar FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_sync_rc_run_smoke() {
  local shu="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shu_std_sync_rc_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-sync-rwlock-condvar FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-sync-rwlock-condvar FAIL: compile $src" >&2
    "$shu" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-sync-rwlock-condvar FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# TSAN 正例：RwLock 保护计数；有工具链时返回 0，否则 echo skip。
std_sync_rc_try_tsan() {
  local sync_c="$1"
  local src="tests/sync/sync_tsan_ok.c"
  local out="/tmp/shu_sync_tsan_ok_$$"
  # shellcheck source=tests/lib/safe-race.sh
  if [ -f tests/lib/safe-race.sh ]; then
    . tests/lib/safe-race.sh
  else
    echo "skip"
    return 0
  fi
  if ! safe_race_tsan_ok; then
    echo "skip"
    return 0
  fi
  local sync_o
  sync_o="$(dirname "$sync_c")/sync.o"
  if [ ! -f "$sync_o" ]; then
    echo "std-sync-rwlock-condvar FAIL: missing $sync_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -fsanitize=thread -fno-omit-frame-pointer \
    -o "$out" "$src" "$sync_o" -lpthread 2>/dev/null; then
    echo "skip"
    rm -f "$out"
    return 0
  fi
  set +e
  TSAN_OPTIONS="${TSAN_OPTIONS:-halt_on_error=1:exitcode=66}" "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-sync-rwlock-condvar FAIL: sync_tsan_ok exit=$ec" >&2
    return 1
  fi
  echo "ok"
  return 0
}

std_sync_rc_emit_report() {
  local status="$1"
  local rwlock_ok="$2"
  local condvar_ok="$3"
  local main_ok="$4"
  local tsan_ok="$5"
  local skip="$6"
  echo "${STD_SYNC_RC_PREFIX} status=${status} rwlock=${rwlock_ok} condvar=${condvar_ok} main=${main_ok} tsan=${tsan_ok} skip=${skip}"
}
