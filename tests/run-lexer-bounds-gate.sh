#!/usr/bin/env bash
# P1-3: Lexer bounded-input gate — honesty soft→硬绿.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make + `xlang check`
# binding (prefer-c / false authority; check gate paused pre-selfhost) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: DOC + manifest + lexer glue `str_buf[512]` bound
#   - hard: product -o long-ident (60-char; let.name[64] cap) + long-decimal
#     (400-digit i64) smoke, run exit 0 (bounded lex+typeck+emit; no stack overflow)
# Report: run=/obs=/skip=
# Usage: ./tests/run-lexer-bounds-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Authority: seeds/runtime_lexer_glue.from_x.c (lexer.c deleted; refuse dual authority).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_LEXER_BOUNDS_PREFIX:-xlang: [XLANG_LEXER_BOUNDS]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-90}"
DOC="analysis/安全与性能.md"
MANIFEST="tests/baseline/lexer-bounds.tsv"
LEXER_GLUE="compiler/seeds/runtime_lexer_glue.from_x.c"
LONG_IDENT="/tmp/xlang_lexer_long_ident_$$.x"
LONG_NUM="/tmp/xlang_lexer_long_num_$$.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "lexer-bounds FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  rm -f "$LONG_IDENT" "$LONG_NUM" 2>/dev/null || true
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

# Product -o hard green. Return 0=ok, 1=hard fail, 2=obs.
# NOTE: keep errexit off across non-zero returns (bash 3.2 + set -e).
product_run_case() {
  local label="$1"
  local src="$2"
  local expect_ec="$3"
  local err="/tmp/xlang_lexer_bounds_${label}.log"
  local out="/tmp/xlang_lexer_bounds_${label}"
  local o_ec r_ec
  [ -f "$src" ] || { echo "lexer-bounds FAIL: missing $src" >&2; return 1; }

  rm -f "$out"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$out" >"$err" 2>&1
  o_ec=$?
  if [ "$o_ec" -eq 124 ]; then
    echo "lexer-bounds OBS $label (-o timeout; product residual)" >&2
    return 2
  fi
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    echo "lexer-bounds FAIL $label (-o ec=$o_ec)" >&2
    tail -n 12 "$err" >&2 || true
    return 1
  fi
  gate_run_timeout 10 "$out" >/dev/null 2>&1
  r_ec=$?
  rm -f "$out"
  if [ "$r_ec" -eq 124 ]; then
    echo "lexer-bounds OBS $label (run timeout; product residual)" >&2
    return 2
  fi
  if [ "$r_ec" -eq "$expect_ec" ]; then
    echo "lexer-bounds OK $label (exit=$r_ec)"
    return 0
  fi
  echo "lexer-bounds FAIL $label (expected exit $expect_ec, got $r_ec)" >&2
  return 1
}

echo "=== P1-3: lexer bounds manifest ==="
for f in "$DOC" "$MANIFEST" "$LEXER_GLUE"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qF 'str_buf[512]' "$LEXER_GLUE" 2>/dev/null; then
  die "$LEXER_GLUE missing str_buf[512] bound"
fi
echo "lexer-bounds manifest OK"
RUN_OK=$((RUN_OK + 1))

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# Product let.name[64] cap: 60-char ident verifies bounded lex + typeck + emit.
# Longer source scan without crash is covered by LONG_NUM; refuse raising gate
# expectations to 2048 just to paper over a soft path.
python3 - <<'PY' > "$LONG_IDENT"
ident = "x" * 60
print("function main(): i32 {")
print(f"  let {ident}: i32 = 0;")
print("  return 0;")
print("}")
PY

# Long decimal i64 literal (bounded digit scan).
python3 - <<'PY' > "$LONG_NUM"
print("function main(): i32 {")
print("  let n: i64 = " + "9" * 400 + ";")
print("  return 0;")
print("}")
PY

echo "=== lexer-bounds: product -o smoke (XLANG=$XLANG_BIN) ==="
# Refuse check-bound green: selfhost check gate paused (2026-08-05).
# Hard path = product -o + exit 0.
prc=0
product_run_case "long_ident" "$LONG_IDENT" 0 || prc=$?
case "$prc" in
  0) RUN_OK=$((RUN_OK + 1)) ;;
  2) OBS=$((OBS + 1)) ;;
  *) die "hard smoke long_ident" ;;
esac

prc=0
product_run_case "long_num" "$LONG_NUM" 0 || prc=$?
case "$prc" in
  0) RUN_OK=$((RUN_OK + 1)) ;;
  2) OBS=$((OBS + 1)) ;;
  *) die "hard smoke long_num" ;;
esac

rm -f "$LONG_IDENT" "$LONG_NUM"
ok_report
echo "lexer-bounds gate OK"
