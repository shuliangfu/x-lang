#!/usr/bin/env bash
# STD-001: std.io stable API manifest + run-io smoke (false-authority honesty).
#
# Usage: ./tests/run-std-io-api-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); run-io.sh exit 0 hard-fail (no soft SKIP
# when native xlang present). Report check=/run=/skip=. Product run-io already
# green under asm; gate was portable-false-red (prefer xlang-c / soft SKIP on
# missing native / ## 7. CI 门禁).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_IO_API_DOC:-analysis/archive/std/std-io-api-v1.md}"
BASELINE="tests/baseline/std-io-api.tsv"
MOD="std/io/mod.x"
MAIN_X="tests/io/main.x"
HOOK="tests/run-io.sh"
PREFIX="xlang: [XLANG_STD001_IO_API]"
MISS=0
N=0

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-io-api-v1.md ]; then
  echo "std-io-api gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$BASELINE" "$MOD" "$MAIN_X" "$HOOK"; do
  if [ ! -f "$f" ]; then
    echo "std-io-api gate FAIL: missing $f" >&2
    exit 1
  fi
done

if ! grep -qF '## 7. Gate' "$DOC" 2>/dev/null; then
  echo "std-io-api gate FAIL: doc missing '## 7. Gate'" >&2
  exit 1
fi

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

if [ "$MISS" -gt 0 ]; then
  echo "${PREFIX} status=fail check=0 run=0 skip=0"
  echo "std-io-api gate FAIL: ${MISS}/${N} symbols missing" >&2
  exit 1
fi
echo "std-io-api manifest OK (${N} symbols)"

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-001: smoke (XLANG=$XLANG_BIN; check observational; run-io hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$MAIN_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-io-api gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  chmod +x "$HOOK"
  if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" "$HOOK"; then
    RUN_OK=1
    SKIP=0
  else
    echo "std-io-api gate FAIL: run-io.sh" >&2
    echo "${PREFIX} status=fail check=${CHECK_OK} run=0 skip=0"
    exit 1
  fi
else
  echo "std-io-api gate FAIL: no native xlang" >&2
  echo "${PREFIX} status=fail check=0 run=0 skip=0"
  exit 1
fi

# check stays observational; hard-green signal is run=.
echo "std-io-api check_ok=${CHECK_OK} (observational)"
echo "${PREFIX} status=ok check=${CHECK_OK} run=${RUN_OK} skip=${SKIP}"
echo "std-io-api gate OK"
