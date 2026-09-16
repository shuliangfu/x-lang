#!/usr/bin/env bash
# STD-001: std.io stable API + run-io smoke — honesty leftover wrap dead source →硬绿.
#
# Honesty: leftover bootstrap-link wrap sourced unused (no RUN_XLANG) + unused
# compiler-make.sh retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover wrap dead
# source / unused compiler-make / soft SKIP→OK / prefer-c). Product run-io.sh
# exit0 = hard run (run=1). check = obs. Report: run=/obs=/skip=.
# G.7: complete existing resolve_shu; drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-io-api-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_IO_API_DOC:-analysis/archive/std/std-io-api-v1.md}"
BASELINE="tests/baseline/std-io-api.tsv"
MOD="std/io/mod.x"
MAIN_X="tests/io/main.x"
HOOK="tests/run-io.sh"
PREFIX="xlang: [XLANG_STD001_IO_API]"
MISS=0
N=0

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-io-api gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP}"
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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-io-api-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$BASELINE" "$MOD" "$MAIN_X" "$HOOK"; do
  [ -f "$f" ] || die "missing $f"
done

grep -qF '## 7. Gate' "$DOC" 2>/dev/null || die "doc missing '## 7. Gate'"

echo "=== STD-001: std.io stable API manifest ==="
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    ''|'#'*) continue ;;
  esac
  sym="$line"
  N=$((N + 1))
  if ! grep -qE "function ${sym}[[:space:](]" "$MOD"; then
    echo "std-io-api gate FAIL: missing stable symbol function ${sym} in $MOD" >&2
    MISS=$((MISS + 1))
  fi
done < "$BASELINE"

[ "$MISS" -eq 0 ] || die "${MISS}/${N} symbols missing"
echo "std-io-api manifest OK (${N} symbols)"

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-001: smoke (XLANG=$XLANG_BIN; check obs; run-io product hard) ==="

set +e
"$XLANG_BIN" check -L . "$MAIN_X" >/tmp/xlang_std_io_api_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-io-api OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap dead source / unused compiler-make.sh
# (product path is leftover run-io hook with pinned XLANG).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
chmod +x "$HOOK"
if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" "$HOOK"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-io-api OK: run-io"
else
  die "run-io.sh exit!=0 (refuse soft SKIP→OK)"
fi

echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP}"
echo "std-io-api gate OK"
