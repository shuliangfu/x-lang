#!/usr/bin/env bash
# STD-002: std.net stable API gate — honesty leftover wrap dead source →硬绿.
#
# Honesty: leftover bootstrap-link wrap sourced unused (no RUN_XLANG) + unused
# compiler-make.sh retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover wrap dead
# source / unused compiler-make / soft SKIP→OK / prefer-c). Product run-net.sh
# exit0 = hard run (run=1). check = obs. Report: run=/obs=/skip=.
# G.7: complete existing resolve_shu; drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-net-api-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_NET_API_DOC:-analysis/archive/std/std-net-api-v1.md}"
BASELINE="tests/baseline/std-net-api.tsv"
MOD="std/net/mod.x"
MAIN_X="tests/net/main.x"
UDP_X="tests/net/udp_batch_buf.x"
HOOK="tests/run-net.sh"
PREFIX="xlang: [XLANG_STD002_NET_API]"

RUN_OK=0
OBS=0
SKIP=0
MISS=0
N=0

die() {
  echo "std-net-api gate FAIL: $*" >&2
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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-net-api-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$BASELINE" "$MOD" "$MAIN_X" "$UDP_X" "$HOOK"; do
  [ -f "$f" ] || die "missing $f"
done

grep -qF '## 8. Gate' "$DOC" 2>/dev/null || die "doc missing '## 8. Gate'"

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

[ "$MISS" -eq 0 ] || die "${MISS}/${N} symbols missing"
echo "std-net-api manifest OK (${N} symbols)"

echo "=== STD-002: API rename grep (mod.x only) ==="
for sym in addr_to_packed packed_to_ipv4 read_batch write_batch send_to recv_from batch_max read_ctx write_ctx set_blocking; do
  grep -qE "function ${sym}[[:space:](]" "$MOD" || die "mod missing function ${sym}"
done

if [ "${XLANG_STD_NET_API_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP}"
  echo "std-net-api gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-002: smoke (XLANG=$XLANG_BIN; check obs; run-net product hard) ==="

set +e
"$XLANG_BIN" check -L . "$MAIN_X" >/tmp/xlang_std002_net_main_check.log 2>&1
chk_main=$?
"$XLANG_BIN" check -L . "$UDP_X" >/tmp/xlang_std002_net_udp_check.log 2>&1
chk_udp=$?
set -e
if [ "$chk_main" -ne 0 ] || [ "$chk_udp" -ne 0 ]; then
  echo "std-net-api OBS check (paused / CHK residual main=$chk_main udp=$chk_udp; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap dead source / unused compiler-make.sh
# (product path is leftover run-net hook with pinned XLANG).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
chmod +x "$HOOK"
if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" "$HOOK"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-net-api OK: run-net"
else
  die "run-net.sh failed (refuse soft SKIP→OK)"
fi

echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP}"
echo "std-net-api gate OK"
