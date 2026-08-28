#!/usr/bin/env bash
# std-log-rotate-async.sh — STD-106 helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_log_rotate_async_symbols_ok MOD_X LOG_X LOG_GLUE TSV
#   std_log_rotate_async_run_c_smoke   # existing .o only; no soft rebuild
#   std_log_rotate_async_run_smoke XLANG_BIN SRC [TAG]
#   std_log_rotate_async_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / XLANG fallthrough /
# bootstrap-link remap / soft ensure_std_c_o rebuild; report
# run=/obs=/skip= (retired check=/run=/skip= check-as-hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_LOG_ROTATE_ASYNC_PREFIX="${XLANG_STD106_LOG_ROTATE_ASYNC_PREFIX:-xlang: [XLANG_STD106_LOG_ROTATE_ASYNC]}"

# Validate manifest; echo miss count. Rotate/async C symbols live in runtime_log_os.
# Kinds: api / symbol / file / smoke / script / section.
# Full-path TSV anchors preferred. Do not invoke make.
# PLATFORM: SHARED archaeology — inventory only.
std_log_rotate_async_symbols_ok() {
  local mod_x="$1"
  local log_x="$2"
  local log_glue="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-log-rotate-async FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        path="$mod_path"
        case "$path" in
          std/log/log.c|std/log/log.x) path="$log_x" ;;
          std/log/log_os_glue.c|compiler/seeds/runtime_log_os.from_x.c) path="$log_glue" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-log-rotate-async FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-log-rotate-async FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        path="$anchor"
        if [ ! -f "$path" ]; then
          path="${mod_path:-}"
        fi
        if [ ! -f "$path" ]; then
          echo "std-log-rotate-async FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        # DOC ## 5. Gate / section anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Observational host-C archaeology smoke (existing log.o + runtime_log_os.o).
# Not a hard-green signal; callers count failure as obs.
# Refuse soft auto-make / soft ensure_std_c_o rebuild.
# Do not restore set -e between steps: return 1 must not trip the gate's set -e.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
std_log_rotate_async_run_c_smoke() {
  local src="tests/std-log/rotate_async_smoke_ok.c"
  local out="/tmp/xlang_std_log_rotate_async_$$"
  local log_o="std/log/log.o"
  local rt_o="compiler/runtime_log_os.o"
  if [ ! -f "$src" ] || [ ! -f "$log_o" ] || [ ! -f "$rt_o" ]; then
    return 1
  fi
  set +e
  cc -std=c11 -O1 -o "$out" "$src" "$log_o" "$rt_o" >/dev/null 2>&1
  local cc_ec=$?
  if [ "$cc_ec" -ne 0 ] || [ ! -x "$out" ]; then
    rm -f "$out"
    return 1
  fi
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# Product tip -o smoke. Caller treats failure as hard die (rotate_async.x).
# PLATFORM: SHARED archaeology — product honesty path.
# Do not restore set -e between steps: return 1 must not trip the gate's set -e.
# Refuse RUN_XLANG / bootstrap-link remap (Darwin must not silently asm→c).
std_log_rotate_async_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std106_log_ra_${tag}_$$"
  local log="/tmp/xlang_std106_log_ra_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-log-rotate-async FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-log-rotate-async OBS tip product -o $src (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-log-rotate-async OBS tip run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired check= as hard).
# Hard-green signal = rotate_async.x product -o (run=1); check/host-C = obs.
std_log_rotate_async_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_LOG_ROTATE_ASYNC_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
