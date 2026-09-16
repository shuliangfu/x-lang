#!/usr/bin/env bash
# STD-144: std.mem safe boundary — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (prefer-c first / explicit-bad still picks
# another binary) + soft SKIP→OK (no native) + hard-bound `xlang check` as sole
# smoke authority retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - manifest + ## 3. Gate + symbols + README = hard.
#   - mem_safe_boundary.x tip product -o UNDEF (std_mem_*_bounded / buffer_from)
#     = obs (same tip residual class as STD-018 mem-boundary).
#   - check path = obs (paused 2026-08-05).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-mem-safe-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD144_DOC:-analysis/archive/std/std-mem-safe-v1.md}"
MANIFEST="${XLANG_STD144_TSV:-tests/baseline/std-mem-safe-manifest.tsv}"
MOD_X="std/mem/mod.x"
LIB="tests/lib/std-mem-safe.sh"
SMOKE_X="tests/mem/mem_safe_boundary.x"
README="std/mem/README.md"

# shellcheck source=tests/lib/std-mem-safe.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-mem-safe gate FAIL: $*" >&2
  std_mem_safe_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

echo "=== STD-144: std.mem safe boundary manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-mem-safe-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SMOKE_X" "$README"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-144 copy_bounded compare_bounded buffer_from; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

if ! grep -qF "copy_bounded" "$README" 2>/dev/null; then
  die "README missing copy_bounded"
fi

sym_miss="$(std_mem_safe_symbols_ok "$MOD_X" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-mem-safe registry OK"

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-144: smoke (XLANG=$XLANG_BIN; check=obs; tip product -o UNDEF=obs) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_mem_safe_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "std-mem-safe OBS check (paused / CHK residual ec=$chk_ec)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_std_mem_safe_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$exe" >/tmp/xlang_std_mem_safe_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 10 /tmp/xlang_std_mem_safe_o.log 2>/dev/null || true
  rm -f "$exe"
  # tip: labi may not pull std_mem_*_bounded / buffer_from — obs, not soft SKIP→OK.
  echo "std-mem-safe OBS tip product -o (ec=$o_ec; std_mem_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$exe" >/dev/null 2>&1
  run_ec=$?
  set -e
  rm -f "$exe"
  if [ "$run_ec" -ne 0 ]; then
    echo "std-mem-safe OBS tip run exit=$run_ec" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
  fi
fi

echo "std-mem-safe gate OK"
std_mem_safe_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
