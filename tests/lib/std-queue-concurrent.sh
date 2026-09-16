#!/usr/bin/env bash
# std-queue-concurrent.sh — STD-048 helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_queue_conc_symbols_ok MOD_X QUEUE_X TSV
#   std_queue_conc_run_smoke XLANG_BIN SRC [TAG]
#   std_queue_conc_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / XLANG fallthrough /
# bootstrap-link remap / soft ensure_std_c_o rebuild / extra CLI .o /
# C contention auto-make; report run=/obs=/skip= (retired
# check=/main=/sync=/c=/skip=).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_QUEUE_CONC_PREFIX="${XLANG_STD_QUEUE_CONCURRENT_PREFIX:-xlang: [XLANG_STD_QUEUE_CONCURRENT]}"

# Validate manifest symbol/file/api; echo miss count; return 0 iff miss==0.
# Kinds: api / symbol / file / smoke / section.
# Full-path TSV anchors preferred. Do not invoke make.
# PLATFORM: SHARED archaeology — inventory only.
std_queue_conc_symbols_ok() {
  local mod_x="$1"
  local queue_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-queue-concurrent FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-queue-concurrent FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/queue/queue.x) mod_path="$queue_x" ;;
          std/queue/queue_glue.c) mod_path="$queue_x" ;;
          *) mod_path="$mod_x" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-queue-concurrent FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-queue-concurrent FAIL: missing smoke '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|anchor)
        # DOC ## 4. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Product tip -o smoke. Caller treats main.x failure as hard die;
# sync_queue_roundtrip.x failure is observational (queue-sync UNDEF).
# PLATFORM: SHARED archaeology — product honesty path.
# Do not restore set -e between steps: return 1 must not trip the gate's set -e.
# Refuse RUN_XLANG / bootstrap-link remap (Darwin must not silently asm→c).
# Refuse extra CLI .o (product -o is the hard path; host-C archaeology is obs).
std_queue_conc_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std048_queue_conc_${tag}_$$"
  local log="/tmp/xlang_std048_queue_conc_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-queue-concurrent FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-queue-concurrent FAIL: compile $src" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-queue-concurrent FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired check=/main=/sync=/c=).
# Hard-green signal = main.x product -o (run=1);
# check / sync_queue_roundtrip / host-C archaeology = obs.
std_queue_conc_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_QUEUE_CONC_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
