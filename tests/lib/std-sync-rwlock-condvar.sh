#!/usr/bin/env bash
# std-sync-rwlock-condvar.sh — STD-045 helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_sync_rc_symbols_ok MOD_X SYNC_OS_GLUE TSV
#   std_sync_rc_run_smoke XLANG_BIN SRC [TAG]
#   std_sync_rc_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / XLANG fallthrough /
# bootstrap-link remap / soft ensure_std_c_o rebuild / extra CLI .o /
# TSAN ensure/auto-make; report run=/obs=/skip= (retired
# check=/rwlock=/condvar=/main=/tsan=/skip=).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SYNC_RC_PREFIX="${XLANG_STD_SYNC_RWLOCK_CONDVAR_PREFIX:-xlang: [XLANG_STD_SYNC_RWLOCK_CONDVAR]}"

# Validate manifest symbol/file/api; echo miss count; return 0 iff miss==0.
# Kinds: api / symbol / file / smoke / section.
# Full-path TSV anchors preferred. Do not invoke make.
# PLATFORM: SHARED archaeology — inventory only.
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

# Product tip -o smoke. Caller treats rwlock_condvar.x / main.x failure as hard die.
# PLATFORM: SHARED archaeology — product honesty path.
# Do not restore set -e between steps: return 1 must not trip the gate's set -e.
# Refuse RUN_XLANG / bootstrap-link remap (Darwin must not silently asm→c).
# Refuse extra CLI .o (product -o is the hard path; host-C archaeology is obs).
std_sync_rc_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std045_sync_rc_${tag}_$$"
  local log="/tmp/xlang_std045_sync_rc_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-sync-rwlock-condvar FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-sync-rwlock-condvar FAIL: compile $src" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-sync-rwlock-condvar FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired
# check=/rwlock=/condvar=/main=/tsan=).
# Hard-green signal = rwlock_condvar.x + main.x product -o (run=2);
# check / TSAN host-C / host-C archaeology = obs.
std_sync_rc_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_SYNC_RC_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
