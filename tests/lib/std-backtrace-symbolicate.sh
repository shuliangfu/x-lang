#!/usr/bin/env bash
# std-backtrace-symbolicate.sh — STD-052 helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_backtrace_sym_symbols_ok MOD_X BT_RUNTIME TSV
#   std_backtrace_sym_run_smoke XLANG_BIN SRC [TAG]
#   std_backtrace_sym_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / XLANG fallthrough /
# bootstrap-link remap / soft ensure_std_c_o rebuild / extra CLI .o /
# C gold auto-make; report run=/obs=/skip= (retired
# check=/c_gold=/x=/skip=).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_BACKTRACE_SYM_PREFIX="${XLANG_STD_BACKTRACE_SYM_PREFIX:-xlang: [XLANG_STD_BACKTRACE_SYM]}"

# Validate manifest symbol/file/api; echo miss count; return 0 iff miss==0.
# Kinds: api / const / symbol / file / smoke / section.
# Full-path TSV anchors preferred. Do not invoke make.
# PLATFORM: SHARED archaeology — inventory only.
std_backtrace_sym_symbols_ok() {
  local mod_x="$1"
  local bt_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-backtrace-symbolicate FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
          echo "std-backtrace-symbolicate FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        # Fossil path std/backtrace/backtrace.x for smoke_c retired → seed.
        if [ -z "$path" ] \
          || [ "$path" = "std/backtrace/backtrace_platform_glue.c" ] \
          || [ "$path" = "compiler/seeds/runtime_backtrace_platform.from_x.c" ] \
          || [ "$path" = "std/backtrace/backtrace.x" ]; then
          path="$bt_c"
        fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-backtrace-symbolicate FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-backtrace-symbolicate FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|anchor|hook_script|cross_ref)
        # DOC ## 5. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Product tip -o smoke. Caller treats symbolicate_known.x failure as hard die.
# PLATFORM: SHARED archaeology — product honesty path.
# Do not restore set -e between steps: return 1 must not trip the gate's set -e.
# Refuse RUN_XLANG / bootstrap-link remap (Darwin must not silently asm→c).
# Refuse extra CLI .o (product -o is the hard path; host-C archaeology is obs).
std_backtrace_sym_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std052_bt_sym_${tag}_$$"
  local log="/tmp/xlang_std052_bt_sym_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-backtrace-symbolicate FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-backtrace-symbolicate FAIL: compile $src" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-backtrace-symbolicate FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired
# check=/c_gold=/x=).
# Hard-green signal = symbolicate_known.x product -o (run=1);
# check / C gold compile/run / host-C archaeology = obs.
std_backtrace_sym_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_BACKTRACE_SYM_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
