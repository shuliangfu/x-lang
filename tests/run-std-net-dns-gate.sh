#!/usr/bin/env bash
# STD-029: std.net DNS error codes + IPv6 gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft auto-make + soft ensure_std_c_o + check=/resolve=/main=/skip= retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c / soft
# ensure). Product resolve_dns.x + main.x -o exit0 = hard run (run=2).
# check = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-net-dns-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_NET_DNS_DOC:-analysis/archive/std/std-net-dns-v1.md}"
MANIFEST="${XLANG_STD_NET_DNS_TSV:-tests/baseline/std-net-dns.tsv}"
NET_X="std/net/mod.x"
NET_DNS_X="std/net/dns.x"
LIB="tests/lib/std-net-dns.sh"
RESOLVE_X="tests/net/resolve_dns.x"
MAIN_X="tests/net/main.x"
MIN_APIS=4

# shellcheck source=tests/lib/std-net-dns.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-net-dns gate FAIL: $*" >&2
  std_net_dns_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
if [ -f analysis/std-net-dns-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

echo "=== STD-029: net DNS manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$NET_X" "$NET_DNS_X" "$RESOLVE_X" "$MAIN_X" std/net/dns.x std/net/alpn.x; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-029 resolve_ex resolve_ipv6 resolve_err IPv6; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 5. Gate' "$DOC" 2>/dev/null || die "doc missing '## 5. Gate'"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      grep -qE "function ${anchor}\\(" "$NET_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_net_dns_symbols_ok "$NET_X" "$NET_DNS_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-net-dns manifest OK"

if [ "${XLANG_STD_NET_DNS_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_net_dns_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-net-dns gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-029: smoke (XLANG=$XLANG_BIN; check obs; resolve/main product hard) ==="

set +e
"$XLANG_BIN" check -L . "$RESOLVE_X" >/tmp/xlang_std029_resolve_check.log 2>&1
chk_r=$?
"$XLANG_BIN" check -L . "$MAIN_X" >/tmp/xlang_std029_main_check.log 2>&1
chk_m=$?
set -e
if [ "$chk_r" -ne 0 ] || [ "$chk_m" -ne 0 ]; then
  echo "std-net-dns OBS check (paused / CHK residual resolve=$chk_r main=$chk_m; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make / soft ensure (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

if std_net_dns_run_smoke "$XLANG_BIN" "$RESOLVE_X" "resolve_dns"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-net-dns OK: resolve_dns"
else
  die "resolve_dns.x exit!=0 (refuse soft SKIP→OK)"
fi
if std_net_dns_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-net-dns OK: main"
else
  die "main.x exit!=0 (refuse soft SKIP→OK)"
fi

std_net_dns_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-net-dns gate OK"
