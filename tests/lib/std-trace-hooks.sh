#!/usr/bin/env bash
# std-trace-hooks.sh — STD-118 helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_trace_hooks_symbols_ok MOD_X TRACE_X TSV
#   std_trace_hooks_run_smoke XLANG_BIN SRC [TAG]
#   std_trace_hooks_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / XLANG fallthrough /
# bootstrap-link remap / soft ensure_std_c_o rebuild / extra CLI .o /
# C smoke auto-make of runtime_time_os.o / runtime_random_fill.o;
# report run=/obs=/skip= (retired c=/x=/skip= as hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_TRACE_HOOKS_PREFIX="${XLANG_STD118_TRACE_HOOKS_PREFIX:-xlang: [XLANG_STD118_TRACE_HOOKS]}"

# Validate manifest symbol/file/api; echo miss count; return 0 iff miss==0.
# Kinds: api / symbol / file / smoke / section / script.
# Full-path TSV anchors preferred. Do not invoke make.
# Fossil TSV names hook_span_begin / hook_io_*_ctx remapped in the
# manifest itself to live product short names (hook_begin / io_read / …).
# PLATFORM: SHARED archaeology — inventory only.
std_trace_hooks_symbols_ok() {
  local mod_x="$1"
  local trace_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-trace-hooks FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/trace/trace.c|std/trace/trace.x|std/trace/trace_span_glue.c|"")
            path="$trace_x"
            ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-trace-hooks FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-trace-hooks FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|vectors)
        # DOC ## 3. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Product tip -o smoke. Caller treats hooks_smoke.x UNDEF as obs
# (product debt; refuse soft SKIP→OK). Do not restore set -e between
# steps: return 1 must not trip the gate's set -e.
# Refuse RUN_XLANG / bootstrap-link remap (Darwin must not silently asm→c).
# Refuse extra CLI .o (product -o is the hard path; host-C archaeology is obs).
# PLATFORM: SHARED archaeology — product honesty path.
std_trace_hooks_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std118_hooks_${tag}_$$"
  local log="/tmp/xlang_std118_hooks_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-trace-hooks FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-trace-hooks FAIL: compile $src" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-trace-hooks FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired c=/x=).
# Hard-green signal = hooks_smoke.x product -o when it actually links
# (run=1); tip std_trace_* UNDEF = obs. check / C smoke compile/run /
# host-C archaeology = obs.
std_trace_hooks_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_TRACE_HOOKS_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
