#!/usr/bin/env bash
# std-sync-rwlock-condvar.sh — STD-045 manifest + smoke helpers
#
# Usage (after source):
#   std_sync_rc_symbols_ok MOD_X SYNC_OS_GLUE TSV
#   std_sync_rc_run_smoke XLANG_BIN X TAG
#   std_sync_rc_try_tsan SYNC_OS_GLUE
#   std_sync_rc_emit_report status check_ok rwlock_ok condvar_ok main_ok tsan_ok skip
# 2026-08-26: report check=/rwlock=/condvar=/main=/tsan=/skip= (honesty; prefer asm).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SYNC_RC_PREFIX="${XLANG_STD_SYNC_RWLOCK_CONDVAR_PREFIX:-xlang: [XLANG_STD_SYNC_RWLOCK_CONDVAR]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_sync_rc_symbols_ok() {
  local mod_x="$1"
  local sync_os_glue="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-sync-rwlock-condvar FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/sync/sync.c|std/sync/sync_os_glue.c|compiler/seeds/runtime_sync_os.from_x.c) mod_path="$sync_os_glue" ;;
          *) mod_path="$mod_x" ;;
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
      section|script|gate|anchor|hook_script)
        # DOC ## 5. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
# PLATFORM: SHARED archaeology — product honesty path.
std_sync_rc_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_sync_rc_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-sync-rwlock-condvar FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-sync-rwlock-condvar FAIL: compile $src" >&2
      $RUN_XLANG build -L . "$src" -o "$exe" 2>&1 | tail -10 >&2 || true
      rm -f "$exe"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-sync-rwlock-condvar FAIL: compile $src" >&2
      "$xlang" -L . "$src" 2>&1 | tail -10 >&2 || true
      rm -f "$exe"
      return 1
    fi
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

# TSAN positive case: RwLock-protected counter. Echo ok/skip; return 1 only on hard fail.
# PLATFORM: POSIX — TSAN toolchain optional; no TSAN → skip (not hard-fail).
std_sync_rc_try_tsan() {
  local sync_os_glue="$1"
  local src="tests/sync/sync_tsan_ok.c"
  local out="/tmp/xlang_sync_tsan_ok_$$"
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
  local sync_o="std/sync/sync.o"
  local rt_os="compiler/runtime_sync_os.o"
  local rt_tls="compiler/runtime_sync_lock_diag_tls.o"
  if [ ! -f "$sync_o" ]; then
    # shellcheck source=tests/lib/build-std-c-o.sh
    . tests/lib/build-std-c-o.sh
    ensure_std_c_o ../std/sync/sync.o 2>/dev/null || true
  fi
  ensure_runtime_sync_os_o 2>/dev/null || true
  ensure_runtime_sync_lock_diag_tls_o 2>/dev/null || true
  if [ ! -f "$sync_o" ] || [ ! -f "$rt_os" ]; then
    echo "std-sync-rwlock-condvar FAIL: missing sync.o or runtime_sync_os.o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -fsanitize=thread -fno-omit-frame-pointer \
    -o "$out" "$src" "$sync_o" "$rt_os" "$rt_tls" -lpthread 2>/dev/null; then
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

# Structured report line (honesty: check=/rwlock=/condvar=/main=/tsan=/skip=).
# Hard-green signal = rwlock= + condvar= + main=; check observational; tsan optional.
std_sync_rc_emit_report() {
  local status="$1"
  local check_ok="$2"
  local rwlock_ok="$3"
  local condvar_ok="$4"
  local main_ok="$5"
  local tsan_ok="$6"
  local skip="$7"
  echo "${STD_SYNC_RC_PREFIX} status=${status} check=${check_ok} rwlock=${rwlock_ok} condvar=${condvar_ok} main=${main_ok} tsan=${tsan_ok} skip=${skip}"
}
