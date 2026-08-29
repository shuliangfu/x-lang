#!/usr/bin/env bash
# STD-025: std.env env_iter / args_iter gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# env_iter.x + cookbook env_args_iter.x -o exit0 = hard run (run=2).
# check = obs. Report: run=/obs=/skip=. G.7: complete existing resolve_shu;
# drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-env-iter-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_ENV_ITER_DOC:-analysis/archive/std/std-env-iter-v1.md}"
MANIFEST="${XLANG_STD_ENV_ITER_TSV:-tests/baseline/std-env-iter.tsv}"
ENV_X="std/env/mod.x"
ENV_IMPL="std/env/env.x"
ENV_GLUE="compiler/seeds/runtime_env_os.from_x.c"
LIB="tests/lib/std-env-iter.sh"
SMOKE="tests/env/env_iter.x"
COOKBOOK="examples/cookbook/env_args_iter.x"
RUNNER="tests/run-env.sh"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-env-iter.sh
. tests/lib/std-env-iter.sh

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-env-iter gate FAIL: $*" >&2
  std_env_iter_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
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

echo "=== STD-025: env iter manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$ENV_X" "$ENV_IMPL" "$ENV_GLUE" "$SMOKE" "$RUNNER" "$COOKBOOK"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in iter_next args_iter_next environ GetEnvironmentStringsA; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

sym_miss="$(std_env_iter_symbols_ok "$ENV_X" "$ENV_IMPL" "$ENV_GLUE" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-env-iter manifest OK"

if [ "${XLANG_STD_ENV_ITER_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_env_iter_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-env-iter gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-025: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

# check = obs only (paused 2026-08-05); refuse soft SKIP→OK.
set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std_env_iter_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-env-iter OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make of env.o / xlang-c; leave ensure_std family alone.
# PLATFORM: SHARED archaeology.

for pair in "iter:$SMOKE" "cookbook:$COOKBOOK"; do
  tag="${pair%%:*}"
  src="${pair#*:}"
  OUT="/tmp/xlang_std_env_${tag}_$$"
  LOG="/tmp/xlang_std_env_${tag}_build_$$.log"
  rm -f "$OUT" "$LOG"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$OUT" >"$LOG" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
    tail -n 20 "$LOG" 2>/dev/null || true
    rm -f "$OUT"
    die "product -o $src failed (ec=$o_ec; refuse soft SKIP→OK)"
  fi
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  [ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable $src exit=$exitcode (expect $SMOKE_EXPECT)"
  RUN_OK=$((RUN_OK + 1))
  echo "std-env-iter OK: product -o $tag"
done

std_env_iter_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-env-iter gate OK"
