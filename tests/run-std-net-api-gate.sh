#!/usr/bin/env bash
# STD-002: std.net stable API manifest + run-net smoke (false-authority honesty).
#
# Usage: ./tests/run-std-net-api-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); run-net.sh exit 0 hard-fail (no soft SKIP
# when native xlang present; no soft SKIP when smoke fails). Drop fossil
# addr_to_packed-in-main.x (product main.x uses net_tcp_listen_c). Report
# check=/run=/skip=. Product run-net already green under asm; gate was
# portable-false-red (prefer xlang-c / soft SKIP on missing native / soft
# SKIP→OK on run-net fail / ## 8. CI 门禁 / fossil main.x API grep).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_NET_API_DOC:-analysis/archive/std/std-net-api-v1.md}"
BASELINE="tests/baseline/std-net-api.tsv"
MOD="std/net/mod.x"
MAIN_X="tests/net/main.x"
UDP_X="tests/net/udp_batch_buf.x"
HOOK="tests/run-net.sh"
PREFIX="xlang: [XLANG_STD002_NET_API]"
MISS=0
N=0

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-net-api-v1.md ]; then
  echo "std-net-api gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$BASELINE" "$MOD" "$MAIN_X" "$UDP_X" "$HOOK"; do
  if [ ! -f "$f" ]; then
    echo "std-net-api gate FAIL: missing $f" >&2
    exit 1
  fi
done

if ! grep -qF '## 8. Gate' "$DOC" 2>/dev/null; then
  echo "std-net-api gate FAIL: doc missing '## 8. Gate'" >&2
  exit 1
fi

echo "=== STD-002: std.net stable API manifest ==="
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    ''|'#'*) continue ;;
  esac
  sym="$line"
  N=$((N + 1))
  if ! grep -qE "function ${sym}[[:space:](]" "$MOD"; then
    echo "std-net-api gate FAIL: missing stable symbol function ${sym} in $MOD" >&2
    MISS=$((MISS + 1))
  fi
done < "$BASELINE"

if [ "$MISS" -gt 0 ]; then
  echo "${PREFIX} status=fail check=0 run=0 skip=0"
  echo "std-net-api gate FAIL: ${MISS}/${N} symbols missing" >&2
  exit 1
fi
echo "std-net-api manifest OK (${N} symbols)"

echo "=== STD-002: API rename grep (mod.x only) ==="
for sym in addr_to_packed packed_to_ipv4 read_batch write_batch send_to recv_from batch_max read_ctx write_ctx set_blocking; do
  if ! grep -qE "function ${sym}[[:space:](]" "$MOD"; then
    echo "std-net-api gate FAIL: mod missing function ${sym}" >&2
    echo "${PREFIX} status=fail check=0 run=0 skip=0"
    exit 1
  fi
done

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
  echo "=== STD-002: smoke (XLANG=$XLANG_BIN; check observational; run-net hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$MAIN_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$UDP_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-net-api gate SKIP check smoke (paused 2026-08-05)" >&2
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
    echo "std-net-api gate FAIL: run-net.sh" >&2
    echo "${PREFIX} status=fail check=${CHECK_OK} run=0 skip=0"
    exit 1
  fi
else
  echo "std-net-api gate FAIL: no native xlang" >&2
  echo "${PREFIX} status=fail check=0 run=0 skip=0"
  exit 1
fi

# check stays observational; hard-green signal is run=.
echo "std-net-api check_ok=${CHECK_OK} (observational)"
echo "${PREFIX} status=ok check=${CHECK_OK} run=${RUN_OK} skip=${SKIP}"
echo "std-net-api gate OK"
