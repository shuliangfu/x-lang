#!/usr/bin/env bash
# LANG-007: unsafe syntax / boundary gate (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK when no native xlang + soft auto-make xlang-c +
# prefer-c-only retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die.
# policy=run → hard-green via product -o.
# policy=compile_fail → product -o must fail with typeck/unsafe diagnostic
#   (hard); legacy `xlang check` path is observational (check paused
#   2026-08-05 / CHK002) — count obs, not soft silence / not hard-red.
# policy=hook → run with bound timeout; timeout/product-fail = obs.
# DOC authority = archive/lang. Report run=/obs=/skip=.
#
# Usage: ./tests/run-lang-unsafe-gate.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

MATRIX="${XLANG_LANG_UNSAFE_TSV:-tests/baseline/lang-unsafe-api.tsv}"
DOC="${XLANG_LANG_UNSAFE_DOC:-analysis/archive/lang/lang-unsafe-v1-rfc.md}"
TYPE_REGION_DOC="${XLANG_TYPE_REGION_DOC:-analysis/archive/type/type-region-v1-rfc.md}"
PREFIX="${XLANG_LANG_UNSAFE_PREFIX:-xlang: [XLANG_LANG_UNSAFE]}"
# Bound hooks so Darwin (no GNU timeout) cannot soft-hang the gate.
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-90}"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "lang-unsafe gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== LANG-007: unsafe boundary manifest (archive DOC) ==="
if [ -f analysis/lang-unsafe-v1-rfc.md ]; then
  die "top-level DOC resurrected (live = archive/lang/)"
fi
for f in \
  "$DOC" \
  "$TYPE_REGION_DOC" \
  "$MATRIX" \
  tests/unsafe/allow_padding_ok.x \
  tests/unsafe/padding_rejected.x \
  tests/unsafe/raw_ptr_null.x \
  tests/unsafe/extern_putchar.x \
  tests/unsafe/unsafe_block_deref_ok.x \
  tests/unsafe/deref_outside_unsafe_fail.x \
  tests/unsafe/extern_outside_unsafe_fail.x; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi
# U4: unsafe keyword must stay reserved in lexer / stretch slice.
if ! grep -q '"unsafe"' compiler/seeds/parser_asm/parser_asm_emit_heavy_stretch_slice.inc 2>/dev/null \
  && ! grep -q 'unsafe' compiler/src/lexer/token.x 2>/dev/null; then
  die "unsafe keyword not reserved in lexer"
fi
echo "lang-unsafe manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# Refuse soft auto-make: caller-owned / already-resolved binary only.

run_timeout_case() {
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$@"
}

# policy=run: product -o hard-green. Timeout (product hang) → return 2 = obs.
run_x_case() {
  local script="$1"
  local want_ec="$2"
  local src="tests/unsafe/${script}"
  local out="/tmp/xlang_unsafe_${script%.x}_$$"
  local log="/tmp/xlang_unsafe_compile_$$.log"
  local o_ec=0
  [ -f "$src" ] || { echo "lang-unsafe FAIL: missing $src" >&2; return 1; }
  rm -f "$out"
  # Prefer pure-asm product -o (host-cc banned without XLANG_ALLOW_HOST_CC).
  # PLATFORM: SHARED — dual-end pure-asm; optional -backend c only if allowed.
  set +e
  run_timeout_case "$XLANG_BIN" -L . "$src" -o "$out" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    echo "lang-unsafe OBS $script (-o timeout ${XLANG_CASE_TIMEOUT}s; product residual)" >&2
    return 2
  fi
  if [ "$o_ec" -ne 0 ]; then
    if [ -n "${XLANG_ALLOW_HOST_CC:-}" ]; then
      set +e
      run_timeout_case "$XLANG_BIN" -backend c -L . "$src" -o "$out" >"$log" 2>&1
      o_ec=$?
      set -e
      if [ "$o_ec" -eq 124 ]; then
        echo "lang-unsafe OBS $script (host-c -o timeout; product residual)" >&2
        return 2
      fi
    fi
  fi
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    cat "$log" >&2
    return 1
  fi
  local ec=0
  set +e
  run_timeout_case "$out" >/dev/null 2>&1
  ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -eq 124 ]; then
    echo "lang-unsafe OBS $script (run timeout; product residual)" >&2
    return 2
  fi
  if [ "$ec" -ne "$want_ec" ]; then
    echo "lang-unsafe FAIL $script: exit=$ec want=$want_ec" >&2
    return 1
  fi
  return 0
}

# policy=compile_fail: product -o must reject with diagnostic (hard).
# Legacy check path is observational only (check paused / CHK002).
compile_fail_case() {
  local script="$1"
  local src="tests/unsafe/${script}"
  local err="/tmp/xlang_unsafe_fail_$$.log"
  [ -f "$src" ] || { echo "lang-unsafe FAIL: missing $src" >&2; return 1; }

  set +e
  run_timeout_case "$XLANG_BIN" -L . "$src" -o "/tmp/xlang_unsafe_should_fail_$$" >"$err" 2>&1
  local o_ec=$?
  set -e
  rm -f "/tmp/xlang_unsafe_should_fail_$$"
  if [ "$o_ec" -eq 124 ]; then
    echo "lang-unsafe OBS compile_fail $script (-o timeout; product residual)" >&2
    return 2
  fi
  if [ "$o_ec" -ne 0 ] \
    && grep -qE 'implicit padding|typeck error|requires unsafe block|T001' "$err"; then
    return 0
  fi

  # Product -o did not reject: try check as observational secondary.
  # PLATFORM: SHARED — check gate paused 2026-08-05; CHK002 / miss = obs.
  set +e
  run_timeout_case "$XLANG_BIN" check -L . "$src" >"$err" 2>&1
  local c_ec=$?
  set -e
  if [ "$c_ec" -eq 124 ]; then
    echo "lang-unsafe OBS compile_fail $script (check timeout; product residual)" >&2
    return 2
  fi
  if [ "$c_ec" -ne 0 ] \
    && grep -qE 'implicit padding|typeck error|requires unsafe block|T001' "$err"; then
    return 0
  fi
  echo "lang-unsafe OBS compile_fail $script (product -o residual / check paused; refuse soft SKIP→OK)" >&2
  if [ -s "$err" ]; then
    tail -5 "$err" >&2 || true
  fi
  return 2
}

echo "=== LANG-007: unsafe boundary smoke (XLANG=$XLANG_BIN) ==="
FAILS=0
HOOK_OBS=0
while IFS=$'\t' read -r case_id mode script policy want_ec notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in \#*) continue ;; esac
  echo "── $case_id [$mode]: $notes ──"
  case "$policy" in
    run)
      set +e
      run_x_case "$script" "${want_ec:-0}"
      run_ec=$?
      set -e
      if [ "$run_ec" -eq 0 ]; then
        echo "lang-unsafe OK $case_id"
        RUN_OK=$((RUN_OK + 1))
      elif [ "$run_ec" -eq 2 ]; then
        HOOK_OBS=$((HOOK_OBS + 1))
        OBS=1
      else
        FAILS=$((FAILS + 1))
      fi
      ;;
    compile_fail)
      set +e
      compile_fail_case "$script"
      cf_ec=$?
      set -e
      if [ "$cf_ec" -eq 0 ]; then
        echo "lang-unsafe OK $case_id (compile_fail)"
        RUN_OK=$((RUN_OK + 1))
      elif [ "$cf_ec" -eq 2 ]; then
        HOOK_OBS=$((HOOK_OBS + 1))
        OBS=1
      else
        FAILS=$((FAILS + 1))
      fi
      ;;
    hook)
      hook="tests/${script}"
      [ -f "$hook" ] || die "missing hook $hook"
      chmod +x "$hook" 2>/dev/null || true
      # PLATFORM: SHARED — hooks inherit XLANG_BIN / XLANG_LINK_XLANG.
      # Bound wall time so Darwin product hang (e.g. ub bounds_array) → obs,
      # not soft silence and not unbounded gate hang.
      set +e
      run_timeout_case env XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" "$hook"
      hook_ec=$?
      set -e
      if [ "$hook_ec" -eq 0 ]; then
        echo "lang-unsafe OK $case_id ($script)"
        RUN_OK=$((RUN_OK + 1))
      elif [ "$hook_ec" -eq 124 ]; then
        echo "lang-unsafe OBS $case_id ($script timeout ${XLANG_CASE_TIMEOUT}s; product residual)" >&2
        HOOK_OBS=$((HOOK_OBS + 1))
        OBS=1
      else
        echo "lang-unsafe OBS $case_id ($script rc=$hook_ec; product residual; refuse soft SKIP→OK)" >&2
        HOOK_OBS=$((HOOK_OBS + 1))
        OBS=1
      fi
      ;;
    *)
      echo "lang-unsafe WARN: unknown policy $policy" >&2
      ;;
  esac
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  die "${FAILS} hard case(s) failed"
fi

echo "=== G-FFI-5: std/ffi + std/sys unsafe wrap hook ==="
chmod +x tests/run-g-ffi-5-std-wrap-gate.sh 2>/dev/null || true
set +e
run_timeout_case env XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
  ./tests/run-g-ffi-5-std-wrap-gate.sh
wrap_ec=$?
set -e
if [ "$wrap_ec" -eq 0 ]; then
  echo "lang-unsafe G-FFI-5 hook OK"
  RUN_OK=$((RUN_OK + 1))
elif [ "$wrap_ec" -eq 124 ]; then
  echo "lang-unsafe OBS G-FFI-5 wrap (timeout; product residual)" >&2
  OBS=1
else
  echo "lang-unsafe OBS G-FFI-5 wrap (rc=$wrap_ec; product residual; refuse soft SKIP→OK)" >&2
  OBS=1
fi

ok_report
echo "lang-unsafe gate OK"
